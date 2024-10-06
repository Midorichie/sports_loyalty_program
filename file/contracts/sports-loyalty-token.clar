;; Sports Fan Loyalty Token
;; Initial implementation of a fan engagement system through tokenized sports loyalty program

;; Define constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-token-owner (err u101))
(define-constant err-insufficient-balance (err u102))

;; Define data variables
(define-data-var token-name (string-ascii 32) "SportsLoyaltyToken")
(define-data-var token-symbol (string-ascii 10) "SLT")
(define-data-var token-uri (optional (string-utf8 256)) none)

;; Define data maps
(define-map balances principal uint)
(define-map approved-operators principal (list 200 principal))

;; SFT-20 compatible interface
(define-public (transfer (amount uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) err-not-token-owner)
    (asserts! (>= (get-balance sender) amount) err-insufficient-balance)
    (try! (decrease-balance sender amount))
    (try! (increase-balance recipient amount))
    (ok true)))

;; Read-only functions
(define-read-only (get-name)
  (ok (var-get token-name)))

(define-read-only (get-symbol)
  (ok (var-get token-symbol)))

(define-read-only (get-balance (account principal))
  (default-to u0 (map-get? balances account)))

;; Administrative functions
(define-public (mint (amount uint) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (try! (increase-balance recipient amount))
    (ok true)))

;; Internal functions
(define-private (decrease-balance (account principal) (amount uint))
  (let ((current-balance (get-balance account)))
    (begin
      (asserts! (>= current-balance amount) err-insufficient-balance)
      (ok (map-set balances account (- current-balance amount))))))

(define-private (increase-balance (account principal) (amount uint))
  (let ((current-balance (get-balance account)))
    (ok (map-set balances account (+ current-balance amount)))))

;; Reward tiers
(define-map reward-tiers uint {
    name: (string-ascii 32),
    required-tokens: uint,
    discount: uint
})

(define-public (add-reward-tier (tier-id uint) (tier-name (string-ascii 32)) (required-tokens uint) (discount uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (ok (map-set reward-tiers tier-id {
      name: tier-name,
      required-tokens: required-tokens,
      discount: discount
    }))))

(define-read-only (get-reward-tier (tier-id uint))
  (map-get? reward-tiers tier-id))