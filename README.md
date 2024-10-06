# Sports Fan Loyalty Token (SLT)

## Branch 1 Update: Enhanced Redemption & Interactivity

### New Features
1. **Merchandise Redemption System**
   - Digital catalog of team merchandise
   - Token-based purchasing mechanism
   - Exclusive items for higher-tier token holders

2. **Ticket Redemption System**
   - Event ticketing integrated into the token ecosystem
   - Automated availability tracking
   - Time-locked redemption based on event dates

3. **Interactive Prediction Game**
   - Make predictions on match outcomes
   - Stake tokens on predictions
   - Earn double tokens for correct predictions

### Technical Updates

#### New Data Structures
```clarity
;; Merchandise Catalog
(define-map merchandise-catalog uint {
    name: (string-ascii 64),
    price: uint,
    available: uint,
    exclusive: bool
})

;; Ticket Catalog
(define-map ticket-catalog uint {
    event-name: (string-ascii 64),
    price: uint,
    event-date: uint,
    available: uint
})

;; Game Predictions
(define-map game-predictions uint {
    match-id: uint,
    prediction: uint,
    result: (optional uint),
    tokens-wagered: uint
})
```

#### New Functions
1. **Redemption Functions**
   - `redeem-merchandise`: Exchange tokens for team merchandise
   - `redeem-ticket`: Purchase event tickets with tokens

2. **Game Functions**
   - `make-prediction`: Stake tokens on match outcomes
   - `resolve-prediction`: Determine winners and distribute rewards

### Usage Examples

#### For Team Administrators
```clarity
;; Add new merchandise
(contract-call? .sports-loyalty-token add-merchandise u1 "Championship Jersey" u500 u100 true)

;; Add new ticket event
(contract-call? .sports-loyalty-token add-ticket-event u1 "Season Opener" u1000 u1682541600 u5000)

;; Resolve a prediction
(contract-call? .sports-loyalty-token resolve-prediction u1 u1)
```

#### For Fans
```clarity
;; Redeem merchandise
(contract-call? .sports-loyalty-token redeem-merchandise u1)

;; Redeem ticket
(contract-call? .sports-loyalty-token redeem-ticket u1)

;; Make a prediction
(contract-call? .sports-loyalty-token make-prediction u1 u1 u100)
```

### Testing the New Features
```bash
clarinet test test/redemption_tests.clar
clarinet test test/prediction_tests.clar
```

## Upcoming in Branch 2
- Enhanced analytics for engagement tracking
- Multi-team compatibility
- Seasonal rewards and achievements

## Contributing
1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License
This project is licensed under the MIT License - see the LICENSE.md file for details

## Contact
Project Link: [(https://github.com/Midorichie/sports-loyalty-token)]

## Acknowledgments
- Bitcoin and Stacks blockchain communities
- Sports teams and fans who provided valuable feedback