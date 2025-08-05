# VaultCoin Synthetic Asset Protocol

![Stacks](https://img.shields.io/badge/Stacks-Clarity-orange?style=flat-square)
![License](https://img.shields.io/badge/License-MIT-blue?style=flat-square)
![Version](https://img.shields.io/badge/Version-1.0.0-green?style=flat-square)

> A sophisticated decentralized protocol for issuing Bitcoin-backed synthetic assets with dynamic collateral management and automated risk mitigation systems.

## 🚀 Overview

VaultCoin is an advanced DeFi protocol built on the Stacks blockchain that enables users to mint synthetic Bitcoin tokens (VBTC) through an over-collateralized vault system. The protocol features real-time price discovery, automated liquidation mechanisms, and dynamic collateral ratios to maintain peg stability while providing users with liquid, transferable Bitcoin-backed synthetic assets.

### Key Features

- **🔒 Over-Collateralized Vaults**: Secure synthetic asset minting with configurable collateral ratios
- **⚡ Real-Time Price Oracle**: Integrated price feed system for accurate asset valuation
- **🛡️ Automated Liquidations**: Intelligent liquidation system with penalty mechanisms
- **📊 Dynamic Risk Management**: Adjustable collateral requirements and emergency safeguards
- **💰 Yield Optimization**: Built-in stability fees and protocol revenue mechanisms
- **🏛️ Governance Controls**: Administrative functions for protocol parameter management

## 📋 Table of Contents

- [Architecture](#architecture)
- [Smart Contract Functions](#smart-contract-functions)
- [Getting Started](#getting-started)
- [Development](#development)
- [Testing](#testing)
- [Security](#security)
- [Economic Model](#economic-model)
- [API Reference](#api-reference)
- [Contributing](#contributing)
- [License](#license)

## 🏗️ Architecture

### Core Components

1. **Vault System**: Individual user vaults that track collateral deposits and synthetic asset debt
2. **Price Oracle**: Real-time BTC price feed with freshness validation
3. **Liquidation Engine**: Automated system for maintaining protocol solvency
4. **Governance Layer**: Administrative controls for protocol parameters
5. **Analytics Dashboard**: Comprehensive protocol statistics and vault monitoring

### Protocol Parameters

| Parameter | Value | Description |
|-----------|-------|-------------|
| Minimum Collateral Ratio | 120% | Minimum required overcollateralization |
| Maximum Collateral Ratio | 300% | Maximum allowed overcollateralization |
| Liquidation Penalty | 10% | Penalty applied during liquidation events |
| Stability Fee | 0.5% annually | Fee for maintaining synthetic asset positions |
| Price Update Threshold | 24 hours | Maximum age for valid price feeds |

## 🔧 Smart Contract Functions

### Core Operations

#### `mint-synthetic-btc`

```clarity
(mint-synthetic-btc (collateral-amount uint) (mint-amount uint))
```

Creates or adds to an existing vault and mints VBTC tokens against deposited collateral.

#### `redeem-synthetic-btc`

```clarity
(redeem-synthetic-btc (burn-amount uint) (withdraw-collateral uint))
```

Burns VBTC tokens and withdraws collateral from the user's vault.

#### `liquidate-vault`

```clarity
(liquidate-vault (vault-owner principal) (max-debt-to-clear uint))
```

Liquidates undercollateralized vaults to maintain protocol solvency.

### Governance Functions

#### `update-collateral-ratio`

```clarity
(update-collateral-ratio (new-ratio uint))
```

Updates the global minimum collateral ratio (admin only).

#### `emergency-shutdown-protocol` / `resume-protocol`

```clarity
(emergency-shutdown-protocol)
(resume-protocol)
```

Emergency controls for protocol operations (admin only).

### View Functions

#### `get-vault-info`

```clarity
(get-vault-info (vault-owner principal))
```

Returns comprehensive vault information including collateralization ratio.

#### `get-protocol-stats`

```clarity
(get-protocol-stats)
```

Returns global protocol statistics and health metrics.

## 🚀 Getting Started

### Prerequisites

- [Clarinet](https://docs.hiro.so/stacks/clarinet) v2.0+
- [Node.js](https://nodejs.org/) v18+
- [Stacks Wallet](https://wallet.hiro.so/) for testnet interaction

### Installation

1. **Clone the repository**

   ```bash
   git clone https://github.com/gbebo-del/vault-coin.git
   cd vault-coin
   ```

2. **Install dependencies**

   ```bash
   npm install
   ```

3. **Check contract syntax**

   ```bash
   clarinet check
   ```

4. **Run the test suite**

   ```bash
   npm test
   ```

### Quick Start Example

```javascript
// Example vault creation
import { Clarinet, Tx, Chain, Account } from '@hirosystems/clarinet-sdk';

// Mint synthetic BTC with 1.5x collateralization
const mintTx = Tx.contractCall(
  'vault-coin',
  'mint-synthetic-btc',
  [Cl.uint(150000000), Cl.uint(100000000)], // 1.5 BTC collateral, 1 VBTC mint
  deployer.address
);

const receipt = chain.mineBlock([mintTx]).receipts[0];
console.log(receipt.result); // Success response with vault details
```

## 🔬 Development

### Project Structure

```
vault-coin/
├── contracts/
│   └── vault-coin.clar          # Main protocol contract
├── tests/
│   └── vault-coin.test.ts       # Comprehensive test suite
├── settings/
│   ├── Devnet.toml             # Development network settings
│   ├── Testnet.toml            # Testnet configuration
│   └── Mainnet.toml            # Production settings
├── Clarinet.toml               # Project configuration
└── package.json                # Dependencies and scripts
```

### Development Workflow

1. **Start Clarinet console**

   ```bash
   clarinet console
   ```

2. **Deploy to devnet**

   ```bash
   clarinet deploy --network devnet
   ```

3. **Run continuous testing**

   ```bash
   npm run test:watch
   ```

### Code Style Guidelines

- Follow Clarity best practices and naming conventions
- Maintain comprehensive error handling with descriptive error codes
- Include detailed comments for complex business logic
- Ensure all public functions have proper validation
- Use consistent indentation and formatting

## 🧪 Testing

The protocol includes a comprehensive test suite covering:

- **Unit Tests**: Individual function testing with edge cases
- **Integration Tests**: Multi-function workflow validation
- **Security Tests**: Attack vector and edge case testing
- **Gas Optimization**: Cost analysis for all operations

### Running Tests

```bash
# Run all tests
npm test

# Run with coverage report
npm run test:report

# Watch mode for development
npm run test:watch

# Clarinet specific tests
clarinet test
```

### Test Categories

- ✅ Vault creation and management
- ✅ Collateral ratio calculations
- ✅ Liquidation mechanisms
- ✅ Price oracle functionality
- ✅ Emergency procedures
- ✅ Administrative controls

## 🔐 Security

### Security Features

- **Multi-layer Validation**: Comprehensive input validation and business logic checks
- **Emergency Controls**: Protocol-wide shutdown capabilities for crisis management
- **Liquidation Safeguards**: Automated risk mitigation through liquidation mechanisms
- **Oracle Protection**: Price feed freshness validation and failure handling
- **Access Controls**: Strict authorization for administrative functions

### Security Considerations

- Always verify collateral ratios before operations
- Monitor price oracle health and update frequency
- Implement proper slippage protection in frontends
- Use multisig wallets for administrative functions
- Regular security audits and formal verification

### Known Limitations

- Oracle dependency for price feeds
- Static liquidation penalty (future versions may include dynamic penalties)
- Centralized price update mechanism (can be decentralized in future versions)

## 💰 Economic Model

### Tokenomics

- **VBTC Supply**: Dynamically adjusted based on collateral deposits
- **Collateral Requirements**: Minimum 120% overcollateralization
- **Stability Fees**: 0.5% annual fee on outstanding debt
- **Liquidation Penalties**: 10% penalty on liquidated positions

### Revenue Streams

1. **Stability Fees**: Continuous revenue from vault holders
2. **Liquidation Penalties**: Revenue from liquidation events
3. **Protocol Fees**: Future governance-controlled fee mechanisms

### Risk Parameters

| Risk Factor | Mitigation Strategy |
|-------------|-------------------|
| Price Volatility | Dynamic collateral ratios and liquidation thresholds |
| Oracle Failure | Price freshness validation and emergency shutdown |
| Smart Contract Risk | Comprehensive testing and formal verification |
| Liquidity Risk | Automated liquidation and penalty mechanisms |

## 📚 API Reference

### Error Codes

| Code | Error | Description |
|------|-------|-------------|
| u100 | ERR-UNAUTHORIZED | Caller lacks required permissions |
| u101 | ERR-INSUFFICIENT-COLLATERAL | Collateral below minimum requirements |
| u102 | ERR-INVALID-AMOUNT | Invalid input amount (zero or negative) |
| u103 | ERR-PRICE-ORACLE-FAILED | Price feed unavailable or stale |
| u104 | ERR-MINT-FAILED | Token minting operation failed |
| u105 | ERR-BURN-FAILED | Token burning operation failed |
| u106 | ERR-LIQUIDATION-NOT-REQUIRED | Vault is adequately collateralized |
| u107 | ERR-VAULT-NOT-FOUND | No vault exists for the specified user |
| u108 | ERR-INSUFFICIENT-BALANCE | Insufficient token balance for operation |
| u109 | ERR-COLLATERAL-RATIO-INVALID | Invalid collateral ratio parameter |
| u110 | ERR-EMERGENCY-SHUTDOWN | Protocol is in emergency shutdown mode |

### Events and Logging

The protocol emits detailed transaction logs for:

- Vault creation and modification events
- Liquidation occurrences with full details
- Administrative parameter changes
- Emergency shutdown activations

## 🤝 Contributing

We welcome contributions to improve the VaultCoin protocol! Please follow these guidelines:

### Development Process

1. **Fork the repository**
2. **Create a feature branch** (`git checkout -b feature/amazing-feature`)
3. **Write comprehensive tests** for new functionality
4. **Ensure all tests pass** (`npm test`)
5. **Follow code style guidelines**
6. **Submit a pull request** with detailed description

### Code Review Criteria

- ✅ Comprehensive test coverage
- ✅ Clear documentation and comments
- ✅ Security best practices
- ✅ Gas optimization considerations
- ✅ Backward compatibility

### Issue Reporting

Please use GitHub Issues to report:

- 🐛 Bug reports with reproduction steps
- 💡 Feature requests with use case descriptions
- 📖 Documentation improvements
- 🔧 Performance optimization suggestions

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🔗 Links

- **Documentation**: [Stacks Documentation](https://docs.stacks.co/)
- **Clarity Language**: [Clarity Reference](https://docs.stacks.co/clarity/)
- **Testing Framework**: [Clarinet Testing](https://docs.hiro.so/stacks/clarinet-js-sdk)
- **Stacks Explorer**: [Stacks Explorer](https://explorer.stacks.co/)
