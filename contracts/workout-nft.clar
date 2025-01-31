;; FitNest Achievement NFTs
(define-non-fungible-token workout-badge uint)

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-token-owner (err u101))

;; Storage
(define-map badge-types uint {name: (string-ascii 64), description: (string-ascii 256)})
(define-map badge-uris uint (string-utf8 256))

;; Counter for token IDs
(define-data-var last-token-id uint u0)

;; Public functions
(define-public (mint (recipient principal) (badge-type uint))
  (let ((token-id (+ (var-get last-token-id) u1)))
    (begin
      (asserts! (is-eq tx-sender contract-owner) err-owner-only)
      (try! (nft-mint? workout-badge token-id recipient))
      (var-set last-token-id token-id)
      (ok token-id))))

(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) err-not-token-owner)
    (nft-transfer? workout-badge token-id sender recipient)))

;; Read only functions
(define-read-only (get-token-uri (token-id uint))
  (map-get? badge-uris token-id))

(define-read-only (get-badge-type (token-id uint))
  (map-get? badge-types token-id))
