;; FitNest Token Contract
(define-fungible-token fit-token)

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-insufficient-balance (err u101))
(define-constant token-decimals u6)

;; Token info
(define-data-var token-name (string-ascii 32) "FitToken")
(define-data-var token-symbol (string-ascii 10) "FIT")
(define-data-var token-uri (string-utf8 256) "https://fitnest.io/token-metadata")
(define-data-var total-supply uint u0)

;; Public functions
(define-public (transfer (amount uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) (err u1))
    (asserts! (>= (ft-get-balance fit-token sender) amount) err-insufficient-balance)
    (print {event: "token_transfer", amount: amount, sender: sender, recipient: recipient})
    (try! (ft-transfer? fit-token amount sender recipient))
    (ok true)))

(define-public (mint (amount uint) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (var-set total-supply (+ (var-get total-supply) amount))
    (print {event: "token_mint", amount: amount, recipient: recipient})
    (ft-mint? fit-token amount recipient)))

(define-public (burn (amount uint) (owner principal))
  (begin
    (asserts! (is-eq tx-sender owner) err-owner-only)
    (var-set total-supply (- (var-get total-supply) amount))
    (print {event: "token_burn", amount: amount, owner: owner})
    (ft-burn? fit-token amount owner)))

;; Read only functions  
(define-read-only (get-name)
  (ok (var-get token-name)))

(define-read-only (get-symbol) 
  (ok (var-get token-symbol)))

(define-read-only (get-decimals)
  (ok token-decimals))

(define-read-only (get-balance (account principal))
  (ok (ft-get-balance fit-token account)))

(define-read-only (get-total-supply)
  (ok (var-get total-supply)))
