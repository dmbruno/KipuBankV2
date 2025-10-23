# KipuBankV2

Este proyecto implementa **KipuBankV2**, un contrato bancario inteligente en Solidity que permite a los usuarios depositar y retirar tanto ETH como tokens ERC20 (ejemplo: USDC) de manera segura y transparente. El desarrollo se ha realizado según consignas prácticas y de buenas prácticas de smart contracts en Ethereum.

---

## 📋 Consignas cumplidas

### 1. **Depósito y retiro de ETH y Tokens ERC20**
- El contrato soporta depósitos y retiros en ETH y en cualquier token ERC20 soportado, como USDC.
- Se utiliza la address cero (`0x000...0000`) para identificar ETH y la address real del token para ERC20.

### 2. **Gestión de Allowance y Approve**
- Antes de depositar tokens ERC20, el usuario debe dar permiso (`approve`) al contrato para mover sus fondos.
- El contrato usa `transferFrom` de ERC20 para mover los tokens, cumpliendo la lógica de seguridad de los estándares.

### 3. **Control y registro de operaciones**
- El contrato registra el número de depósitos y retiros realizados.
- Lleva control del balance actual de cada token.
- Incluye límites (“cap”) para el máximo de tokens aceptados (ejemplo: capUSD).

### 4. **Eventos y transparencia**
- Emite eventos en cada depósito y retiro para máxima trazabilidad.
- Se puede consultar el resumen de actividad con la función `summary`.

### 5. **Uso de interfaces y estándares**
- Se implementa y utiliza la interfaz estándar `IERC20`.
- Se aprovechan librerías de OpenZeppelin para seguridad y robustez.

### 6. **Control de roles y permisos**
- El contrato soporta roles (ejemplo: `PAUSER_ROLE`, `AUDITOR_ROLE`) para gestión administrativa segura.

### 7. **Chequeo de decimales**
- El contrato maneja correctamente los decimales de cada token (ejemplo: 6 decimales para USDC).

---

## 🚀 Cómo usar

### **1. Clonar el repositorio**
```bash
git clone https://github.com/TUUSUARIO/kipubankv2.git
cd kipubankv2
```

### **2. Instalar dependencias**
Si vas a trabajar localmente con herramientas como Hardhat o Foundry, instala las dependencias (si existe package.json):

```bash
npm install
```

O agrega OpenZeppelin si es necesario:
```bash
npm install @openzeppelin/contracts
```

### **3. Abrir en Remix**
Puedes abrir los archivos directamente en [Remix IDE](https://remix.ethereum.org/) arrastrando la carpeta o subiendo los archivos del directorio `contracts/`.

---

### **4. Desplegar el contrato**

1. Compila `KipuBankV2.sol` en Remix.
2. Selecciona el entorno adecuado (por ejemplo, Injected Provider para usar MetaMask).
3. Despliega el contrato desde la pestaña "Deploy & Run Transactions".

---

### **5. Realizar operaciones**

#### **A. Depósito de ETH**
- Llama a la función `deposit`:
  - `token`: `0x0000000000000000000000000000000000000000`
  - `amount`: cantidad en Wei (ej: 0.01 ETH = 10000000000000000)
  - `VALUE` (en Remix): igual al amount (en Wei)

#### **B. Depósito de USDC**
1. Haz `approve` en el contrato USDC:
   - `spender`: dirección de KipuBankV2
   - `amount`: cantidad a aprobar (ej: 10 USDC = 10000000)
2. Llama a `deposit` en KipuBankV2:
   - `token`: `0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238`
   - `amount`: cantidad en decimales USDC (ej: 10 USDC = 10000000)
   - `VALUE`: 0

#### **C. Retiro de ETH**
- Llama a la función `withdraw`:
  - `token`: `0x0000000000000000000000000000000000000000`
  - `amount`: cantidad en Wei
  - `VALUE`: 0

#### **D. Retiro de USDC**
- Llama a la función `withdraw`:
  - `token`: `0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238`
  - `amount`: cantidad en decimales USDC (ej: 5 USDC = 5000000)
  - `VALUE`: 0

---

### **6. Consultar información del contrato**
- Usa la función `summary` para ver los depósitos, retiros y balances.
- Usa `getBalance(token, address)` para consultar el saldo de un usuario en un token específico.
- Revisa los eventos emitidos para auditar operaciones.

---

### **7. Personalizar y extender**
- Puedes agregar soporte para otros tokens ERC20 en la función `addSupportedToken`.
- Utiliza los roles administrativos (`grantRole`, `pause`, etc.) para gestionar la seguridad y el control del banco.
- Ajusta el `capUSD` según las necesidades del proyecto.

---

## 🛡️ Seguridad y buenas prácticas

- Uso estricto de `SafeERC20` y validaciones de amount.
- No se permite depositar ni retirar montos cero.
- Manejo de roles administrativos.
- Eventos para todas las operaciones.
- Lógica de approve y allowance comprobada en testnet.

---

## 📁 Estructura del proyecto

```
contracts/
│   KipuBankV2.sol
│   IERC20.sol
│   (otros contratos o interfaces)
README.md
```

---

## ✨ Créditos

- Implementación: dmbruno
- Basado en consignas del curso/práctica de contratos inteligentes con Remix, OpenZeppelin y ERC20.

---

¿Tienes dudas o sugerencias? ¡Abre un issue o PR!
