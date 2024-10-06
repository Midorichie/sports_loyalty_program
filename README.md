# Sports Fan Loyalty Token (SLT)

## Branch 2 Update: Multi-Team Compatibility & Enhanced Analytics

### New Features
1. **Multi-Team Support**
   - Multiple teams can now participate in the loyalty program
   - Fans can join multiple teams and track achievements across teams
   - League commissioner role for overall governance

2. **Seasonal Achievements**
   - Time-based challenges and rewards
   - Team-specific achievements
   - Point-based progression system

3. **Enhanced Analytics**
   - Comprehensive tracking of fan engagement
   - Team performance metrics
   - Seasonal statistics and historical data

### Technical Updates

#### New Data Structures
```clarity
;; Team Management
(define-map teams uint {
    name: (string-ascii 64),
    owner: principal,
    total-fans: uint,
    season-points: uint
})

;; Fan Analytics
(define-map team-fan-data (tuple (team-id uint) (fan principal)) {
    join-date: uint,
    attendance: uint,
    predictions-made: uint,
    predictions-won: uint,
    items-purchased: uint,
    total-spent: uint
})

;; Achievements
(define-map seasonal-achievements uint {
    name: (string-ascii 64),
    description: (string-ascii 256),
    points-required: uint,
    reward: uint,
    team-id: uint
})
```

#### Key Functions
1. **Team Management**
   - `register-team`: Add a new team to the ecosystem
   - `join-team`: Fans can officially join a team

2. **Achievement System**
   - `add-achievement`: Create new seasonal achievements
   - `claim-achievement`: Fans can claim rewards for completed achievements

3. **Analytics**
   - `get-team-stats`: Retrieve comprehensive team statistics
   - `get-fan-stats`: Get detailed engagement metrics for individual fans

### Usage Examples

#### For League Commissioner
```clarity
;; Register a new team
(contract-call? .sports-loyalty-token register-team u1 "New York Titans")

;; Start a new season
(contract-call? .sports-loyalty-token start-new-season)
```

#### For Team Administrators
```clarity
;; Add a seasonal achievement
(contract-call? .sports-loyalty-token add-achievement u1 
    "Super Fan" 
    "Attend 10 games this season" 
    u1000 
    u500 
    u1)
```

#### For Fans
```clarity
;; Join a team
(contract-call? .sports-loyalty-token join-team u1)

;; Claim an achievement
(contract-call? .sports-loyalty-token claim-achievement u1)

;; Check personal stats
(contract-call? .sports-loyalty-token get-fan-stats u1 tx-sender)
```

### Analytics Dashboard Integration
The enhanced analytics can be integrated with external dashboards using the following endpoints:
- Team Performance: `get-team-stats`
- Fan Engagement: `get-fan-stats`
- Achievement Tracking: User achievements list

### Testing the New Features
```bash
clarinet test test/multi_team_tests.clar
clarinet test test/achievement_tests.clar
clarinet test test/analytics_tests.clar
```

## Deployment and Migration Guide
1. Deploy the updated contract
2. Migrate existing team data to the new multi-team structure
3. Set up the league commissioner role
4. Create initial seasonal achievements

## Future Enhancements
- Cross-team collaborations and joint achievements
- Machine learning integration for personalized fan experiences
- Decentralized governance for league-wide decisions

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