;; FitNest Achievement NFTs
(define-non-fungible-token workout-badge uint)

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-token-owner (err u101))
(define-constant err-invalid-badge-type (err u102))

;; Storage
(define-map badge-types uint {name: (string-ascii 64), description: (string-ascii 256)})
(define-map badge-uris uint (string-utf8 256))

;; Counter for token IDs
(define-data-var last-token-id uint u0)

;; Events
(define-data-var total-supply uint u0)

;; Public functions
(define-public (register-badge-type (badge-type uint) (name (string-ascii 64)) (description (string-ascii 256)) (uri (string-utf8 256)))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (map-set badge-types badge-type {name: name, description: description})
    (map-set badge-uris badge-type uri)
    (ok true)))

(define-public (mint (recipient principal) (badge-type uint))
  (let ((token-id (+ (var-get last-token-id) u1)))
    (begin
      (asserts! (is-eq tx-sender contract-owner) err-owner-only)
      (asserts! (is-some (map-get? badge-types badge-type)) err-invalid-badge-type)
      (try! (nft-mint? workout-badge token-id recipient))
      (var-set last-token-id token-id)
      (var-set total-supply (+ (var-get total-supply) u1))
      (print {event: "nft_minted", token_id: token-id, recipient: recipient})
      (ok token-id))))

(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) err-not-token-owner)
    (asserts! (is-some (nft-get-owner? workout-badge token-id)) err-not-token-owner)
    (print {event: "nft_transferred", token_id: token-id, sender: sender, recipient: recipient})
    (nft-transfer? workout-badge token-id sender recipient)))

;; Read only functions
(define-read-only (get-token-uri (token-id uint))
  (map-get? badge-uris token-id))

(define-read-only (get-badge-type (token-id uint))
  (map-get? badge-types token-id))

(define-read-only (get-total-supply)
  (ok (var-get total-supply)))
