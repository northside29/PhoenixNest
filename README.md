# PhoenixNest: Smart Asset Transfer Protocol

## Overview
PhoenixNest is a Clarity smart contract designed to provide secure, automated asset transfer capabilities with built-in dormancy detection, activity monitoring, and encrypted message storage. It enables users to create digital "nests" that can automatically transfer assets to designated heirs when specific inactivity conditions are met.

## Features

### Core Functionality
- **Nest Creation**: Users can create personal vaults ("nests") with customizable parameters
- **Asset Management**: Secure storage and management of digital assets
- **Heir Designation**: Support for multiple heirs (up to 5)
- **Multi-signature Support**: Configurable number of required signatures for succession
- **Activity Monitoring**: Automated dormancy detection system

### Advanced Features
- **Encrypted Message Storage**: Store up to 10 encrypted messages (scrolls) per nest
- **Activity Alerts**: Configurable watch intervals for activity monitoring
- **Guardian System**: Appoint trusted keepers to oversee succession process
- **Renewal Mechanism**: Built-in timelock for succession process

## Technical Specifications

### Constants
- Maximum number of assets per nest: 100
- Maximum number of heirs per nest: 5
- Maximum number of encrypted messages: 10
- Message size limit: 1024 bytes
- Minimum watch interval: 86400 seconds (1 day)
- Renewal period: 604800 seconds (1 week)

### Error Codes
- `u100`: Admin only error
- `u101`: Resource not found
- `u102`: Unauthorized action
- `u103`: Nest already exists
- `u104`: Nest is dormant
- `u105`: Insufficient signatures
- `u106`: Nest capacity exceeded
- `u107`: Watch interval too short
- `u108`: Message limit reached
- `u109`: Renewal too soon
- `u110`: Invalid keeper
- `u111`: Invalid guardian
- `u112`: Invalid scroll

## Usage

### Creating a Nest
```clarity
(contract-call? .phoenix-nest create-nest
  heirs                ;; List of heir principals
  dormancy-threshold   ;; Inactivity period in seconds
  quorum-size         ;; Required number of signatures
  watch-interval      ;; Alert period in seconds
)
```

### Managing Assets
```clarity
;; Store an asset
(contract-call? .phoenix-nest store-treasure asset-principal)

;; Record activity
(contract-call? .phoenix-nest record-activity)
```

### Succession Process
```clarity
;; Initiate succession
(contract-call? .phoenix-nest begin-succession nest-guardian)

;; Approve succession (for authorized keepers)
(contract-call? .phoenix-nest approve-succession nest-guardian)

;; Complete succession
(contract-call? .phoenix-nest complete-succession nest-guardian)
```

### Encrypted Messages
```clarity
;; Store encrypted message
(contract-call? .phoenix-nest seal-scroll encrypted-message)

;; Retrieve messages
(contract-call? .phoenix-nest unseal-scrolls nest-guardian)
```

## Security Features

### Input Validation
- Guardian validation for all critical operations
- Keeper validation during appointment
- Message content validation
- Principal address validation

### Access Control
- Guardian-only operations
- Keeper authorization system
- Multi-signature requirements for succession
- Dormancy checks for sensitive operations

### Safety Mechanisms
- Activity monitoring system
- Minimum watch intervals
- Renewal timelock
- Maximum capacity limits

## Best Practices

1. **Regular Activity Updates**
   - Record activity regularly to prevent unintended dormancy
   - Monitor watch intervals and respond to alerts

2. **Keeper Management**
   - Appoint multiple trusted keepers
   - Regularly verify keeper access and permissions

3. **Succession Planning**
   - Set appropriate dormancy thresholds
   - Configure realistic quorum requirements
   - Keep heir information updated

4. **Message Security**
   - Encrypt sensitive messages before storage
   - Use strong encryption methods
   - Test message retrieval with heirs

## Contributing

We welcome contributions to the PhoenixNest project. Please ensure that any modifications:
- Maintain or enhance security features
- Include appropriate input validation
- Follow existing naming conventions
- Add comprehensive documentation
- Include relevant test cases

