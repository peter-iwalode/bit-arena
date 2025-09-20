;; Title: BitArena - Competitive Gaming Protocol
;;
;; Summary:
;; A Bitcoin Layer 2 competitive gaming ecosystem built on Stacks that enables
;; skill-based tournaments, collectible gaming assets, and automated BTC prize pools.
;;
;; Description:
;; BitArena transforms competitive gaming through Bitcoin-native infrastructure.
;; Players compete in skill-based tournaments while earning and trading unique NFT
;; gaming assets. Smart leaderboards track performance metrics and automatically
;; distribute BTC rewards to top performers. The protocol ensures fair play,
;; transparent scoring, and secure asset ownership across the Bitcoin ecosystem.

;; ERROR CONSTANTS

(define-constant ERR-NOT-AUTHORIZED (err u1))
(define-constant ERR-INVALID-GAME-ASSET (err u2))
(define-constant ERR-INSUFFICIENT-FUNDS (err u3))
(define-constant ERR-TRANSFER-FAILED (err u4))
(define-constant ERR-LEADERBOARD-FULL (err u5))
(define-constant ERR-ALREADY-REGISTERED (err u6))
(define-constant ERR-INVALID-REWARD (err u7))
(define-constant ERR-INVALID-INPUT (err u8))
(define-constant ERR-INVALID-SCORE (err u9))
(define-constant ERR-INVALID-FEE (err u10))
(define-constant ERR-INVALID-ENTRIES (err u11))
(define-constant ERR-PLAYER-NOT-FOUND (err u12))

;; PROTOCOL CONFIGURATION

(define-data-var game-fee uint u10)
(define-data-var max-leaderboard-entries uint u50)
(define-data-var total-prize-pool uint u0)
(define-data-var total-game-assets uint u0)

;; NFT DEFINITIONS

(define-non-fungible-token game-asset uint)

(define-map game-asset-metadata 
  { token-id: uint }
  { 
    name: (string-ascii 50),
    description: (string-ascii 200),
    rarity: (string-ascii 20),
    power-level: uint
  }
)

;; PLAYER & ADMIN DATA STRUCTURES

(define-map leaderboard 
  { player: principal }
  { 
    score: uint, 
    games-played: uint,
    total-rewards: uint 
  }
)

(define-map game-admin-whitelist principal bool)

;; VALIDATION FUNCTIONS

(define-read-only (is-game-admin (sender principal))
  (default-to false (map-get? game-admin-whitelist sender))
)

(define-read-only (is-valid-string (input (string-ascii 200)))
  (> (len input) u0)
)

(define-read-only (is-valid-principal (input principal))
  (and 
    (not (is-eq input tx-sender))
    (not (is-eq input (as-contract tx-sender)))
  )
)

(define-read-only (is-safe-principal (input principal))
  (and 
    (is-valid-principal input)
    (or 
      (is-game-admin input)
      (is-some (map-get? leaderboard { player: input }))
    )
  )
)

;; ADMINISTRATIVE FUNCTIONS

(define-public (add-game-admin (new-admin principal))
  (begin
    (asserts! (is-game-admin tx-sender) ERR-NOT-AUTHORIZED)
    (asserts! (is-safe-principal new-admin) ERR-INVALID-INPUT)
    (map-set game-admin-whitelist new-admin true)
    (ok true)
  )
)

(define-public (initialize-game 
  (entry-fee uint) 
  (max-entries uint)
)
  (begin
    (asserts! (is-game-admin tx-sender) ERR-NOT-AUTHORIZED)
    (asserts! (and (>= entry-fee u1) (<= entry-fee u1000)) ERR-INVALID-FEE)
    (asserts! (and (>= max-entries u1) (<= max-entries u500)) ERR-INVALID-ENTRIES)
    
    (var-set game-fee entry-fee)
    (var-set max-leaderboard-entries max-entries)
    
    (ok true)
  )
)

;; NFT ASSET MANAGEMENT

(define-public (mint-game-asset 
  (name (string-ascii 50))
  (description (string-ascii 200))
  (rarity (string-ascii 20))
  (power-level uint)
)
  (let 
    (
      (token-id (+ (var-get total-game-assets) u1))
    )
    (asserts! (is-game-admin tx-sender) ERR-NOT-AUTHORIZED)
    (asserts! (is-valid-string name) ERR-INVALID-INPUT)
    (asserts! (is-valid-string description) ERR-INVALID-INPUT)
    (asserts! (is-valid-string rarity) ERR-INVALID-INPUT)
    (asserts! (and (>= power-level u0) (<= power-level u1000)) ERR-INVALID-INPUT)
    
    (try! (nft-mint? game-asset token-id tx-sender))
    
    (map-set game-asset-metadata 
      { token-id: token-id }
      {
        name: name,
        description: description, 
        rarity: rarity,
        power-level: power-level
      }
    )
    
    (var-set total-game-assets token-id)
    
    (ok token-id)
  )
)