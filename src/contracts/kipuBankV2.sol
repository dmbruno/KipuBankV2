// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "./IKipuBankV2.sol";

contract KipuBankV2 is Ownable, AccessControl, IKipuBankV2 {
    using SafeERC20 for IERC20;

    string public constant VERSION = "KipuBank v2.0";
    uint8 public constant INTERNAL_DECIMALS = 6;

    // --- TOKENS Y ORÁCULOS PARA SEPOLIA ---
    address public constant USDC_ADDRESS = 0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238;
    address public constant ETH_USD_FEED = 0x694AA1769357215DE4FAC081bf1f309aDC325306;
    address public constant USDC_USD_FEED = 0xA2F78ab2355fe2f984D808B5CeE7FD0A93D5270E;
    address public constant ETH_ADDRESS = address(0);

    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant AUDITOR_ROLE = keccak256("AUDITOR_ROLE");

    event Deposit(address indexed user, address indexed token, uint256 amount, uint256 newBalance, uint256 depositIndex);
    event Withdrawal(address indexed user, address indexed token, uint256 amount, uint256 newBalance, uint256 withdrawalIndex);
    event Paused(address account);
    event Unpaused(address account);
    event OracleUpdated(address indexed token, address indexed oracle);

    error ZeroAddress();
    error ZeroAmount();
    error BankCapExceeded(uint256 attemptedUSD, uint256 capUSD);
    error InsufficientBalance(uint256 available, uint256 required);
    error PausedError();
    error OracleNotSet(address token);

    struct TokenData {
        uint8 decimals;
        address priceFeed;
    }

    mapping(address => mapping(address => uint256)) private balances;
    mapping(address => uint256) public totalTokenBalance;
    mapping(address => TokenData) public tokenData;
    address[] public supportedTokens;

    uint256 public totalDepositsCount;
    uint256 public totalWithdrawalsCount;
    uint256 public immutable bankCapUSD;
    bool public paused = false;

    modifier whenNotPaused() {
        if (paused) revert PausedError();
        _;
    }

    constructor(uint256 _bankCapUSD) Ownable(msg.sender) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);

        bankCapUSD = _bankCapUSD;

        // ETH
        tokenData[ETH_ADDRESS] = TokenData({
            decimals: 18,
            priceFeed: ETH_USD_FEED
        });
        supportedTokens.push(ETH_ADDRESS);

        // USDC Sepolia
        tokenData[USDC_ADDRESS] = TokenData({
            decimals: 6,
            priceFeed: USDC_USD_FEED
        });
        supportedTokens.push(USDC_ADDRESS);
    }

    function pause() external onlyRole(PAUSER_ROLE) {
        paused = true;
        emit Paused(msg.sender);
    }

    function unpause() external onlyRole(PAUSER_ROLE) {
        paused = false;
        emit Unpaused(msg.sender);
    }

    function addSupportedToken(address token, uint8 decimals, address priceFeed) external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (token == address(0) || priceFeed == address(0)) revert ZeroAddress();
        if (tokenData[token].priceFeed != address(0)) revert OracleNotSet(token);
        tokenData[token] = TokenData(decimals, priceFeed);
        supportedTokens.push(token);
        emit OracleUpdated(token, priceFeed);
    }

    function deposit(address token, uint256 amount) external payable override whenNotPaused {
        if (tokenData[token].priceFeed == address(0)) revert OracleNotSet(token);

        if (token == ETH_ADDRESS) {
            if (msg.value == 0) revert ZeroAmount();
            amount = msg.value;
        } else {
            if (amount == 0) revert ZeroAmount();
            IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
        }

        uint256 depositUSD = _toUSD(token, amount);
        uint256 newBankBalanceUSD = getBankBalanceUSD() + depositUSD;
        if (newBankBalanceUSD > bankCapUSD) revert BankCapExceeded(newBankBalanceUSD, bankCapUSD);

        balances[token][msg.sender] += amount;
        totalTokenBalance[token] += amount;
        totalDepositsCount++;

        emit Deposit(msg.sender, token, amount, balances[token][msg.sender], totalDepositsCount);
    }

    function withdraw(address token, uint256 amount) external override whenNotPaused {
        if (amount == 0) revert ZeroAmount();
        if (tokenData[token].priceFeed == address(0)) revert OracleNotSet(token);

        uint256 userBal = balances[token][msg.sender];
        if (userBal < amount) revert InsufficientBalance(userBal, amount);

        balances[token][msg.sender] = userBal - amount;
        totalTokenBalance[token] -= amount;
        totalWithdrawalsCount++;

        if (token == ETH_ADDRESS) {
            (bool sent, ) = msg.sender.call{value: amount}("");
            require(sent, "ETH transfer failed");
        } else {
            IERC20(token).safeTransfer(msg.sender, amount);
        }

        emit Withdrawal(msg.sender, token, amount, balances[token][msg.sender], totalWithdrawalsCount);
    }

    function getBalance(address token, address user) public view override returns (uint256) {
        return balances[token][user];
    }

    function summary() external view override returns (
        uint256 bankBalanceUSD, uint256 deposits, uint256 withdrawals, uint256 capUSD
    ) {
        return (getBankBalanceUSD(), totalDepositsCount, totalWithdrawalsCount, bankCapUSD);
    }

    function getBankBalanceUSD() public view returns (uint256) {
        uint256 sum = 0;
        for (uint i = 0; i < supportedTokens.length; i++) {
            address token = supportedTokens[i];
            sum += _toUSD(token, totalTokenBalance[token]);
        }
        return sum;
    }

    function _toUSD(address token, uint256 amount) internal view returns (uint256) {
        TokenData memory data = tokenData[token];
        if (data.priceFeed == address(0) || amount == 0) return 0;
        (, int256 price,,,) = AggregatorV3Interface(data.priceFeed).latestRoundData();
        uint8 priceDecimals = AggregatorV3Interface(data.priceFeed).decimals();
        if (price <= 0) return 0;
        uint256 factor = 10 ** (data.decimals + priceDecimals - INTERNAL_DECIMALS);
        return (amount * uint256(price)) / factor;
    }

    // ---- RECIBE ETH DIRECTAMENTE ----
    receive() external payable {
        if (msg.value == 0) revert ZeroAmount();
        if (paused) revert PausedError();

        uint256 depositUSD = _toUSD(ETH_ADDRESS, msg.value);
        uint256 newBankBalanceUSD = getBankBalanceUSD() + depositUSD;
        if (newBankBalanceUSD > bankCapUSD) revert BankCapExceeded(newBankBalanceUSD, bankCapUSD);

        balances[ETH_ADDRESS][msg.sender] += msg.value;
        totalTokenBalance[ETH_ADDRESS] += msg.value;
        totalDepositsCount++;

        emit Deposit(msg.sender, ETH_ADDRESS, msg.value, balances[ETH_ADDRESS][msg.sender], totalDepositsCount);
    }
}