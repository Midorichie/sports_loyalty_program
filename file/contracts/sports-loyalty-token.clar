;; Sports Fan Loyalty Token - Branch 2: Multi-Team & Analytics Enhancement
;; Adds multi-team support, seasonal rewards, and comprehensive analytics

;; Keep existing constants and add new ones
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-token-owner (err u101))
(define-constant err-insufficient-balance (err u102))
(define-constant err-item-not-found (err u103))
(define-constant err-expired (err u104))
(define-constant err-incorrect-prediction (err u105))
(define-constant err-team-not-found (err u106))
(define-constant err-achievement-not-found (err u107))

;; Keep existing data variables
(define-data-var token-name (string-ascii 32) "SportsLoyaltyToken")
(define-data-var token-symbol (string-ascii 10) "SLT")
(define-data-var token-uri (optional (string-utf8 256)) none)
(define-data-var current-season uint u2024)
(define-data-var total-predictions uint u0)
(define-data-var correct-predictions uint u0)

;; New data variables for multi-team support
(define-data-var league-commissioner principal contract-owner)

;; Keep existing maps and add new ones
(define-map balances principal uint)
(define-map approved-operators principal (list 200 principal))
(define-map merchandise-catalog uint {name: (string-ascii 64), price: uint, available: uint, exclusive: bool})
(define-map ticket-catalog uint {event-name: (string-ascii 64), price: uint, event-date: uint, available: uint})
(define-map user-redemptions principal (list 100 uint))
(define-map game-predictions uint {match-id: uint, prediction: uint, result: (optional uint), tokens-wagered: uint})

;; New maps for multi-team support and analytics
(define-map teams uint {
    name: (string-ascii 64),
    owner: principal,
    total-fans: uint,
    season-points: uint
})

(define-map team-fan-data (tuple (team-id uint) (fan principal)) {
    join-date: uint,
    attendance: uint,
    predictions-made: uint,
    predictions-won: uint,
    items-purchased: uint,
    total-spent: uint
})

(define-map seasonal-achievements uint {
    name: (string-ascii 64),
    description: (string-ascii 256),
    points-required: uint,
    reward: uint,
    team-id: uint
})

(define-map user-achievements principal (list 100 uint))

;; Multi-team management functions
(define-public (register-team (team-id uint) (team-name (string-ascii 64)))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (ok (map-set teams team-id {
            name: team-name,
            owner: tx-sender,
            total-fans: u0,
            season-points: u0
        }))))

(define-public (join-team (team-id uint))
    (let ((team (unwrap! (map-get? teams team-id) err-team-not-found)))
        (map-set team-fan-data {team-id: team-id, fan: tx-sender} {
            join-date: block-height,
            attendance: u0,
            predictions-made: u0,
            predictions-won: u0,
            items-purchased: u0,
            total-spent: u0
        })
        (ok (map-set teams team-id 
            (merge team {total-fans: (+ (get total-fans team) u1)})))))

;; Seasonal achievement functions
(define-public (add-achievement (achievement-id uint) 
                               (name (string-ascii 64)) 
                               (description (string-ascii 256))
                               (points-required uint)
                               (reward uint)
                               (team-id uint))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (ok (map-set seasonal-achievements achievement-id {
            name: name,
            description: description,
            points-required: points-required,
            reward: reward,
            team-id: team-id
        }))))

(define-public (claim-achievement (achievement-id uint))
    (let ((achievement (unwrap! (map-get? seasonal-achievements achievement-id) err-achievement-not-found))
          (fan-data (unwrap! (map-get? team-fan-data 
                                       {team-id: (get team-id achievement), 
                                        fan: tx-sender}) 
                             err-team-not-found)))
        (asserts! (>= (calculate-fan-points fan-data) (get points-required achievement)) err-insufficient-balance)
        (try! (mint (get reward achievement) tx-sender))
        (ok (map-set user-achievements tx-sender 
            (unwrap! (as-max-len? 
                        (append (default-to (list) (map-get? user-achievements tx-sender)) 
                                achievement-id) 
                        u100) 
                    err-owner-only)))))

;; Enhanced analytics functions
(define-read-only (get-team-stats (team-id uint))
    (map-get? teams team-id))

(define-read-only (get-fan-stats (team-id uint) (fan principal))
    (map-get? team-fan-data {team-id: team-id, fan: fan}))

(define-private (calculate-fan-points (fan-data {attendance: uint, 
                                                predictions-made: uint,
                                                predictions-won: uint,
                                                items-purchased: uint,
                                                total-spent: uint}))
    (+ (* (get attendance fan-data) u10)
       (* (get predictions-won fan-data) u50)
       (* (get items-purchased fan-data) u20)))

;; Update existing redemption functions to track analytics
(define-public (redeem-merchandise (item-id uint))
    (let ((item (unwrap! (map-get? merchandise-catalog item-id) err-item-not-found))
          (user-balance (get-balance tx-sender)))
        (asserts! (>= user-balance (get price item)) err-insufficient-balance)
        (asserts! (> (get available item) u0) err-item-not-found)
        (try! (decrease-balance tx-sender (get price item)))
        (map-set merchandise-catalog item-id 
            (merge item {available: (- (get available item) u1)}))
        (update-fan-stats tx-sender (get price item))
        (ok true)))

;; Internal helper function for updating fan stats
(define-private (update-fan-stats (fan principal) (amount uint))
    (let ((current-stats (unwrap! (map-get? team-fan-data {team-id: u1, fan: fan}) err-team-not-found)))
        (ok (map-set team-fan-data 
                     {team-id: u1, fan: fan}
                     (merge current-stats 
                            {items-purchased: (+ (get items-purchased current-stats) u1),
                             total-spent: (+ (get total-spent current-stats) amount)})))))

;; Season management
(define-public (start-new-season)
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (var-set current-season (+ (var-get current-season) u1))
        (reset-season-stats)
        (ok true)))

(define-private (reset-season-stats)
    (begin
        (var-set total-predictions u0)
        (var-set correct-predictions u0)
        (ok true)))

;; Keep existing utility functions and add new ones as needed
(define-private (merge (a {available: uint}) (b {available: uint}))
    (merge a b))