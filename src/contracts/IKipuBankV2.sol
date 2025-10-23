// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title Interfaz KipuBankV2 - Banco multi-token
interface IKipuBankV2 {
    /**
     * @notice Deposita ETH o un token ERC20
     * @param token Dirección del token (ETH es address(0))
     * @param amount Cantidad a depositar (ETH: ignorado, usar msg.value)
     */
    function deposit(address token, uint256 amount) external payable;

    /**
     * @notice Retira ETH o un token ERC20
     * @param token Dirección del token (ETH es address(0))
     * @param amount Cantidad a retirar
     */
    function withdraw(address token, uint256 amount) external;

    /**
     * @notice Consulta el balance de un usuario para un token
     * @param token Dirección del token (ETH es address(0))
     * @param user Dirección del usuario
     */
    function getBalance(address token, address user) external view returns (uint256);

    /**
     * @notice Devuelve resumen global del banco
     */
    function summary() external view returns (
        uint256 bankBalanceUSD,
        uint256 deposits,
        uint256 withdrawals,
        uint256 capUSD
    );
}