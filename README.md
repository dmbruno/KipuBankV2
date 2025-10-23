# KipuBankV2

## Descripción general y mejoras implementadas

KipuBankV2 es una evolución del contrato original KipuBank, con el objetivo de acercarlo a un estándar de producción y aplicar buenas prácticas de Solidity, seguridad y extensibilidad, todo desarrollado y probado en **Remix IDE**.

### Mejoras realizadas

- **Control de acceso avanzado:** Implementación de roles administrativos y de pausado usando OpenZeppelin AccessControl y Ownable, para mayor seguridad en funciones críticas.
- **Soporte multi-token:** Ahora el banco acepta depósitos y retiros tanto de Ether como de cualquier token ERC20, permitiendo fácilmente la extensión a nuevos activos.
- **Contabilidad multi-token:** Los saldos de cada usuario se gestionan por token soportado, consultables individualmente.
- **Integración con oráculos Chainlink:** El contrato utiliza feeds de precios de Chainlink para convertir el valor de los depósitos a USD y controlar el límite total del banco (“bank cap”).
- **Conversión de decimales y valores:** Se maneja correctamente la diferencia entre decimales de cada token y los feeds, usando una base interna de 6 decimales (como USDC).
- **Eventos y errores personalizados:** Se emiten eventos detallados para depósitos, retiros, pausas y cambios de oráculo, y se usan errores personalizados para facilitar el debugging y ahorrar gas.
- **Seguridad y eficiencia:** Se aplican patrones como checks-effects-interactions, uso de constantes e inmutables, SafeERC20 para transferencias seguras y manejo robusto de Ether.
- **Pausado del banco:** Se puede pausar y reanudar la operación del banco mediante roles, protegiendo a los usuarios ante emergencias.
- **Extensible:** Se pueden agregar nuevos tokens y oráculos fácilmente con `addSupportedToken`, sin cambiar la lógica central.

## Instrucciones de despliegue e interacción (Remix)

### Prerrequisitos

- Tener una wallet compatible con Ethereum (por ejemplo MetaMask) conectada a una testnet (Sepolia).
- Conocer la dirección de los oráculos Chainlink y tokens a usar (por ejemplo, USDC y ETH en Sepolia).

### Despliegue en Remix

1. Entrar en [Remix IDE](https://remix.ethereum.org/)
2. Crear una carpeta `/contracts` y agregar los archivos del contrato KipuBankV2, así como las interfaces necesarias (por ejemplo, IKipuBankV2).
3. En la pestaña "Solidity Compiler", seleccionar la versión **0.8.20**.
4. Compilar el contrato `KipuBankV2.sol`.
5. Ir a la pestaña "Deploy & Run Transactions".
6. Seleccionar el entorno "Injected Provider - Metamask" y conectar tu wallet a Sepolia.
7. Ingresar el parámetro `bankCapUSD` (ejemplo: `1000000` para un límite de 1,000,000 USD) y desplegar el contrato.
8. Guardar la dirección del contrato desplegado para interactuar luego.

### Interacción desde Remix

- **Depositar ETH:**  
  - Seleccionar la función `deposit`.  
  - En el campo `token` poner `0x0000000000000000000000000000000000000000` y en `amount` poner `0`.  
  - Indicar el monto de ETH en el campo "Value" de Remix.
- **Depositar ERC20:**  
  - Primero aprobar el contrato desde el token ERC20 (llamando a `approve`).  
  - Luego llamar a `deposit` con la dirección del token y el monto.
- **Retirar:**  
  - Usar la función `withdraw` indicando el token y el monto a retirar.
- **Consultar saldo:**  
  - Usar `getBalance(token, usuario)` para ver el saldo individual.
- **Agregar token soportado:**  
  - El admin llama a `addSupportedToken(token, decimals, priceFeed)`.
- **Pausar/Despausar:**  
  - Los usuarios con el rol `PAUSER_ROLE` pueden llamar a `pause()` o `unpause()`.

## Decisiones de diseño y trade-offs

- **Control de acceso:** Se eligió AccessControl de OpenZeppelin por su flexibilidad para roles múltiples y administración descentralizada, combinándolo con Ownable para ownership clásico.
- **Contabilidad multi-token:** Un mapping anidado permite balances independientes por usuario y por token, facilitando la extensión.
- **Oráculos y feeds:** Integración con Chainlink para feeds de precios seguros y descentralizados.
- **Conversión de decimales:** Base interna de 6 decimales para homogeneizar la contabilidad y compatibilidad con USDC.
- **Eventos y errores:** Se priorizó la observabilidad y el ahorro de gas, usando eventos claros y errores personalizados.
- **Pausado global:** Permite a los administradores detener el banco ante incidentes.
- **ETH como token:** Uso de address(0) para Ether, siguiendo el estándar de la comunidad.
- **Extensibilidad:** El contrato puede ampliarse fácilmente a nuevos tokens y oráculos sin migrar ni modificar la lógica central.
- **Limitaciones:** El contrato depende de la disponibilidad y precisión de los oráculos Chainlink para la conversión a USD. No implementa intereses ni préstamos.

---

## Cómo correr pruebas (Remix)

- Puedes escribir scripts en la pestaña "Scripts" de Remix o interactuar manualmente usando la interfaz gráfica.
- Para pruebas de depósitos y retiros de ERC20, primero aprueba los tokens y luego llama a las funciones correspondientes.

---

## Contacto

Para dudas, feedback o contribuciones, abre un issue en el repositorio o contáctame por GitHub.
