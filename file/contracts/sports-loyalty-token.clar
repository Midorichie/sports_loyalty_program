;; Sports Fan Loyalty Token - Branch 1: Enhanced Redemption & Interactivity
;; Adds merchandise/ticket redemption and interactive elements

;; Maintain existing constants and add new ones
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-token-owner (err u101))
(define-constant err-insufficient-balance (err u102))
(define-constant err-item-not-found (err u103))
(define-constant err-expired (err u104))
(define-constant err-incorrect-prediction (err u105))

;; Keep existing data variables
(define-data-var token-name (string-ascii 32) "SportsLoyaltyToken")
(define-data-var token-symbol (string-ascii 10) "SLT")
(define-data-var token-uri (optional (string-utf8 256)) none)

;; Add new data variables for game mechanics
(define-data-var current-season uint u2024)
(define-data-var total-predictions uint u0)
(define-data-var correct-predictions uint u0)

;; Keep existing maps and add new ones
(define-map balances principal uint)
(define-map approved-operators principal (list 200 principal))

;; New maps for redemption mechanics
(define-map merchandise-catalog uint {
    name: (string-ascii 64),
    price: uint,
    available: uint,
    exclusive: bool
})

(define-map ticket-catalog uint {
    event-name: (string-ascii 64),
    price: uint,
    event-date: uint,
    available: uint
})

(define-map user-redemptions principal (list 100 uint))
(define-map game-predictions uint {
    match-id: uint,
    prediction: uint,
    result: (optional uint),
    tokens-wagered: uint
})

;; Keep existing SFT-20 functions and add new ones

;; New redemption functions
(define-public (add-merchandise (item-id uint) (name (string-ascii 64)) (price uint) (quantity uint) (exclusive bool))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (ok (map-set merchandise-catalog item-id {
            name: name,
            price: price,
            available: quantity,
            exclusive: exclusive
        }))))

(define-public (add-ticket-event (event-id uint) (name (string-ascii 64)) (price uint) (date uint) (quantity uint))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (ok (map-set ticket-catalog event-id {
            event-name: name,
            price: price,
            event-date: date,
            available: quantity
        }))))

(define-public (redeem-merchandise (item-id uint))
    (let ((item (unwrap! (map-get? merchandise-catalog item-id) err-item-not-found))
          (user-balance (get-balance tx-sender)))
        (asserts! (>= user-balance (get price item)) err-insufficient-balance)
        (asserts! (> (get available item) u0) err-item-not-found)
        (try! (decrease-balance tx-sender (get price item)))
        (map-set merchandise-catalog item-id 
            (merge item {available: (- (get available item) u1)}))
        (ok true)))

(define-public (redeem-ticket (event-id uint))
    (let ((event (unwrap! (map-get? ticket-catalog event-id) err-item-not-found))
          (user-balance (get-balance tx-sender)))
        (asserts! (>= user-balance (get price event)) err-insufficient-balance)
        (asserts! (> (get available event) u0) err-item-not-found)
        (asserts! (> (get event-date event) block-height) err-expired)
        (try! (decrease-balance tx-sender (get price event)))
        (map-set ticket-catalog event-id 
            (merge event {available: (- (get available event) u1)}))
        (ok true)))

;; New interactive game functions
(define-public (make-prediction (match-id uint) (prediction uint) (tokens uint))
    (let ((user-balance (get-balance tx-sender)))
        (asserts! (>= user-balance tokens) err-insufficient-balance)
        (try! (decrease-balance tx-sender tokens))
        (map-set game-predictions (var-get total-predictions) {
            match-id: match-id,
            prediction: prediction,
            result: none,
            tokens-wagered: tokens
        })
        (var-set total-predictions (+ (var-get total-predictions) u1))
        (ok true)))

(define-public (resolve-prediction (prediction-id uint) (result uint))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (let ((prediction (unwrap! (map-get? game-predictions prediction-id) err-item-not-found))
              (predictor (unwrap! (get-prediction-maker prediction-id) err-item-not-found)))
            (if (is-eq (get prediction prediction) result)
                (begin
                    (try! (increase-balance predictor (* (get tokens-wagered prediction) u2)))
                    (var-set correct-predictions (+ (var-get correct-predictions) u1))
                    (ok true))
                (ok false)))))

;; Read-only functions
(define-read-only (get-merchandise (item-id uint))
    (map-get? merchandise-catalog item-id))

(define-read-only (get-ticket (event-id uint))
    (map-get? ticket-catalog event-id))

(define-read-only (get-prediction (prediction-id uint))
    (map-get? game-predictions prediction-id))

(define-read-only (get-prediction-maker (prediction-id uint))
    (let ((prediction (unwrap! (map-get? game-predictions prediction-id) err-item-not-found)))
        (some tx-sender)))

;; Utility functions
(define-private (merge (a {available: uint}) (b {available: uint}))
    (merge a b))