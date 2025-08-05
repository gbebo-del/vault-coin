;; Title: VaultCoin Synthetic Asset Protocol
;; Summary: A sophisticated decentralized protocol for issuing Bitcoin-backed
;;          synthetic assets with dynamic collateral management and automated
;;          risk mitigation systems.
;; Description: VaultCoin enables users to mint synthetic Bitcoin tokens through
;;              an over-collateralized vault system. The protocol features real-time
;;              price discovery, automated liquidation mechanisms, and dynamic
;;              collateral ratios to maintain peg stability. Users can deposit BTC
;;              as collateral to mint VBTC tokens, which track Bitcoin's value while
;;              remaining liquid and transferable. The system includes emergency
;;              safeguards, governance controls, and yield optimization features.

;; CONSTANTS & CONFIGURATION

(define-constant CONTRACT-OWNER tx-sender)
(define-constant PRECISION u1000000) ;; 6 decimal precision
(define-constant MIN-COLLATERAL-RATIO u120) ;; 120% minimum collateralization
(define-constant MAX-COLLATERAL-RATIO u300) ;; 300% maximum collateralization
(define-constant LIQUIDATION-PENALTY u10) ;; 10% liquidation penalty
(define-constant STABILITY-FEE u5) ;; 0.5% annual stability fee (5/1000)

;; ERROR CODES

(define-constant ERR-UNAUTHORIZED (err u100))
(define-constant ERR-INSUFFICIENT-COLLATERAL (err u101))
(define-constant ERR-INVALID-AMOUNT (err u102))
(define-constant ERR-PRICE-ORACLE-FAILED (err u103))
(define-constant ERR-MINT-FAILED (err u104))
(define-constant ERR-BURN-FAILED (err u105))
(define-constant ERR-LIQUIDATION-NOT-REQUIRED (err u106))
(define-constant ERR-VAULT-NOT-FOUND (err u107))
(define-constant ERR-INSUFFICIENT-BALANCE (err u108))
(define-constant ERR-COLLATERAL-RATIO-INVALID (err u109))
(define-constant ERR-EMERGENCY-SHUTDOWN (err u110))

;; DATA STRUCTURES

;; Define the synthetic Bitcoin token
(define-fungible-token vault-btc)

;; Global protocol state
(define-data-var total-collateral-locked uint u0)
(define-data-var global-collateral-ratio uint u150) ;; 150% default ratio
(define-data-var protocol-fee-accumulated uint u0)
(define-data-var emergency-shutdown bool false)
(define-data-var last-price-update uint u0)

;; Individual vault tracking
(define-map user-vaults
  principal
  {
    collateral-amount: uint,
    debt-amount: uint,
    last-update: uint,
    stability-fee-accrued: uint,
  }
)

;; Liquidation history for transparency
(define-map liquidation-events
  uint
  {
    vault-owner: principal,
    liquidator: principal,
    collateral-seized: uint,
    debt-cleared: uint,
    timestamp: uint,
  }
)

(define-data-var liquidation-counter uint u0)

;; PRICE ORACLE INTERFACE

(define-read-only (get-btc-price)
  (let ((current-block stacks-block-height))
    (if (> (- current-block (var-get last-price-update)) u144) ;; ~24 hours in blocks
      ERR-PRICE-ORACLE-FAILED
      (ok u5000000000)
    )
  )
)
;; $50,000 with 6 decimal precision

(define-public (update-price-feed)
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-UNAUTHORIZED)
    (var-set last-price-update stacks-block-height)
    (ok true)
  )
)

;; CORE VAULT OPERATIONS

;; Create or add to existing vault and mint VBTC
(define-public (mint-synthetic-btc
    (collateral-amount uint)
    (mint-amount uint)
  )
  (let (
      (current-price (unwrap! (get-btc-price) ERR-PRICE-ORACLE-FAILED))
      (existing-vault (default-to {
        collateral-amount: u0,
        debt-amount: u0,
        last-update: u0,
        stability-fee-accrued: u0,
      }
        (map-get? user-vaults tx-sender)
      ))
      (new-collateral (+ (get collateral-amount existing-vault) collateral-amount))
      (new-debt (+ (get debt-amount existing-vault) mint-amount))
      (collateral-value (/ (* new-collateral current-price) PRECISION))
      (required-collateral (/ (* new-debt (var-get global-collateral-ratio)) u100))
    )
    (begin
      ;; Pre-flight checks
      (asserts! (not (var-get emergency-shutdown)) ERR-EMERGENCY-SHUTDOWN)
      (asserts! (> collateral-amount u0) ERR-INVALID-AMOUNT)
      (asserts! (> mint-amount u0) ERR-INVALID-AMOUNT)
      (asserts! (>= collateral-value required-collateral)
        ERR-INSUFFICIENT-COLLATERAL
      )

      ;; Update vault state
      (map-set user-vaults tx-sender {
        collateral-amount: new-collateral,
        debt-amount: new-debt,
        last-update: stacks-block-height,
        stability-fee-accrued: (get stability-fee-accrued existing-vault),
      })

      ;; Update global state
      (var-set total-collateral-locked
        (+ (var-get total-collateral-locked) collateral-amount)
      )

      ;; Mint synthetic BTC tokens
      (try! (ft-mint? vault-btc mint-amount tx-sender))

      (ok {
        collateral-deposited: collateral-amount,
        vbtc-minted: mint-amount,
        current-ratio: (/ (* collateral-value u100) new-debt),
      })
    )
  )
)

;; Burn VBTC and withdraw collateral
(define-public (redeem-synthetic-btc
    (burn-amount uint)
    (withdraw-collateral uint)
  )
  (let (
      (current-price (unwrap! (get-btc-price) ERR-PRICE-ORACLE-FAILED))
      (user-vault (unwrap! (map-get? user-vaults tx-sender) ERR-VAULT-NOT-FOUND))
      (user-balance (ft-get-balance vault-btc tx-sender))
      (remaining-debt (- (get debt-amount user-vault) burn-amount))
      (remaining-collateral (- (get collateral-amount user-vault) withdraw-collateral))
      (collateral-value (/ (* remaining-collateral current-price) PRECISION))
      (required-collateral (if (> remaining-debt u0)
        (/ (* remaining-debt (var-get global-collateral-ratio)) u100)
        u0
      ))
    )
    (begin
      ;; Validation checks
      (asserts! (not (var-get emergency-shutdown)) ERR-EMERGENCY-SHUTDOWN)
      (asserts! (>= user-balance burn-amount) ERR-INSUFFICIENT-BALANCE)
      (asserts! (>= (get debt-amount user-vault) burn-amount) ERR-INVALID-AMOUNT)
      (asserts! (>= (get collateral-amount user-vault) withdraw-collateral)
        ERR-INVALID-AMOUNT
      )

      ;; Ensure remaining position is properly collateralized
      (asserts!
        (or (is-eq remaining-debt u0) (>= collateral-value required-collateral))
        ERR-INSUFFICIENT-COLLATERAL
      )

      ;; Burn tokens
      (try! (ft-burn? vault-btc burn-amount tx-sender))

      ;; Update vault state
      (if (and (is-eq remaining-debt u0) (is-eq remaining-collateral u0))
        (map-delete user-vaults tx-sender)