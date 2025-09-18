# Disaster Prediction Network

An early warning system that aggregates environmental data from multiple sources to predict natural disasters, coordinate emergency responses, and provide real-time risk assessment for communities and infrastructure.

## 🌟 Overview

The Disaster Prediction Network is a blockchain-based early warning system designed to save lives and minimize economic losses from natural disasters. By leveraging smart contracts on the Stacks blockchain, the system provides a transparent, immutable, and decentralized approach to disaster prediction and emergency response coordination.

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────────────────┐    ┌──────────────────────┐
│   Data Sources  │───▶│  Environmental Data         │───▶│  Risk Assessment &   │
│                 │    │  Aggregator Contract        │    │  Prediction Engine   │
│ • Weather APIs  │    │                             │    │                      │
│ • Seismic Data  │    │ • Data Validation           │    │ • Risk Scoring       │
│ • Satellite Img │    │ • Historical Storage        │    │ • Threshold Analysis │
│ • IoT Sensors   │    │ • Quality Verification      │    │ • Pattern Recognition│
└─────────────────┘    └─────────────────────────────┘    └──────────────────────┘
                                      │                                │
                                      ▼                                ▼
┌─────────────────┐    ┌─────────────────────────────┐    ┌──────────────────────┐
│  Community      │◀───│  Emergency Response         │◀───│  Automated Alerts &  │
│  Notifications  │    │  Coordinator Contract       │    │  Trigger System      │
│                 │    │                             │    │                      │
│ • SMS Alerts    │    │ • Resource Allocation       │    │ • Risk Thresholds    │
│ • Mobile Apps   │    │ • Evacuation Planning       │    │ • Alert Distribution │
│ • Web Dashboard │    │ • Damage Assessment         │    │ • Emergency Protocols│
└─────────────────┘    └─────────────────────────────┘    └──────────────────────┘
```

## 📋 Core Components

### 🌍 Environmental Data Aggregator Contract
- **Purpose**: Collects and validates environmental data from multiple sources
- **Features**:
  - Data quality verification through cross-referencing
  - Real-time risk scoring (0-100 scale)
  - Historical disaster data pattern recognition
  - Multi-source data validation
  - Predictive analytics engine

### 🚨 Emergency Response Coordinator Contract  
- **Purpose**: Manages emergency alerts and coordinates response efforts
- **Features**:
  - Automated alert distribution based on risk levels
  - Evacuation route optimization
  - Emergency resource allocation
  - Volunteer coordination system
  - Post-disaster damage assessment

## 🛠️ Technology Stack

- **Blockchain**: Stacks (Bitcoin Layer 2)
- **Smart Contract Language**: Clarity
- **Development Framework**: Clarinet
- **Testing**: Clarinet Testing Framework
- **Package Management**: NPM

## 🚀 Quick Start

### Prerequisites
- Node.js (v16 or higher)
- Clarinet CLI
- Git

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/doyinojo08/disaster-prediction-network.git
   cd disaster-prediction-network
   ```

2. **Install dependencies**:
   ```bash
   npm install
   ```

3. **Check contract syntax**:
   ```bash
   clarinet check
   ```

4. **Run tests**:
   ```bash
   clarinet test
   ```

### Local Development

1. **Start Clarinet console**:
   ```bash
   clarinet console
   ```

2. **Deploy contracts locally**:
   ```bash
   clarinet deploy --devnet
   ```

3. **Run integration tests**:
   ```bash
   npm test
   ```

## 📊 Contract Functions

### Environmental Data Aggregator

#### Public Functions
- `submit-environmental-data()` - Submit environmental readings
- `update-risk-threshold()` - Update risk assessment parameters
- `register-data-source()` - Register new data sources

#### Read-Only Functions
- `get-current-risk-score()` - Get real-time risk assessment
- `get-historical-data()` - Retrieve historical disaster data
- `get-data-source-reliability()` - Check data source credibility

### Emergency Response Coordinator

#### Public Functions
- `trigger-emergency-alert()` - Issue emergency alerts (authority only)
- `register-evacuation-route()` - Add evacuation routes
- `allocate-resources()` - Deploy emergency resources
- `report-damage-assessment()` - Submit damage reports

#### Read-Only Functions
- `get-region-status()` - Check current region alert status
- `get-available-resources()` - View available emergency resources
- `get-evacuation-routes()` - Retrieve evacuation route information

## 🧪 Testing

The project includes comprehensive tests covering:

- Contract deployment and initialization
- Data validation and error handling
- Risk assessment algorithms
- Emergency response workflows
- Edge cases and security scenarios

Run all tests:
```bash
clarinet test
```

Run specific test file:
```bash
clarinet test tests/environmental-data-aggregator_test.ts
```

## 🔧 Configuration

### Environment Settings

The project supports multiple environments:

- **Devnet** (`settings/Devnet.toml`) - Local development
- **Testnet** (`settings/Testnet.toml`) - Public testnet
- **Mainnet** (`settings/Mainnet.toml`) - Production deployment

### Contract Configuration

Key parameters in `Clarinet.toml`:
```toml
[contracts.environmental-data-aggregator]
path = "contracts/environmental-data-aggregator.clar"
clarity_version = 2
epoch = 2.4

[contracts.emergency-response-coordinator]
path = "contracts/emergency-response-coordinator.clar"
clarity_version = 2
epoch = 2.4
```

## 🤝 Contributing

We welcome contributions! Please follow these steps:

1. **Fork the repository**
2. **Create a feature branch**:
   ```bash
   git checkout -b feature/your-feature-name
   ```
3. **Make your changes and add tests**
4. **Run the test suite**:
   ```bash
   clarinet check
   clarinet test
   ```
5. **Commit your changes**:
   ```bash
   git commit -m "feat: add your feature description"
   ```
6. **Push to your branch**:
   ```bash
   git push origin feature/your-feature-name
   ```
7. **Create a Pull Request**

### Code Style Guidelines
- Use meaningful variable and function names
- Add comprehensive comments for complex logic
- Follow Clarity best practices
- Include tests for all new functionality
- Update documentation for API changes

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

- **Documentation**: [Stacks Documentation](https://docs.stacks.co/)
- **Community**: [Discord Channel](https://discord.gg/stacks)
- **Issues**: [GitHub Issues](https://github.com/doyinojo08/disaster-prediction-network/issues)

## 🔮 Roadmap

### Phase 1 (Current)
- ✅ Core smart contract development
- ✅ Basic risk assessment algorithms
- ✅ Emergency response coordination

### Phase 2 (Next)
- 🔄 Integration with real-world data sources
- 🔄 Mobile application development
- 🔄 Advanced ML prediction models

### Phase 3 (Future)
- 📋 Multi-chain deployment
- 📋 Government partnership integration
- 📋 Insurance claim automation

## 🏷️ Tags

`blockchain` `disaster-prediction` `emergency-response` `stacks` `clarity` `smart-contracts` `risk-assessment` `early-warning-system`

---

**⚡ Built with passion to save lives and protect communities through blockchain technology.**