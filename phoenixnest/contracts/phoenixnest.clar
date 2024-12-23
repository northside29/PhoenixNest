;; PhoenixNest: Asset Transfer Protocol with Dormancy Detection

;; Constants
(define-constant protocol-admin tx-sender)
(define-constant err-admin-only (err u100))
(define-constant err-missing (err u101))
(define-constant err-forbidden (err u102))
(define-constant err-nest-exists (err u103))
(define-constant err-dormant (err u104))
(define-constant err-quorum-not-met (err u105))
(define-constant err-nest-full (err u106))

;; Data Maps
(define-map nests
  { guardian: principal }
  {
    treasures: (list 100 principal),
    heirs: (list 5 principal),
    dormancy-threshold: uint,
    last-check: uint,
    quorum-size: uint
  }
)

(define-map nest-keepers
  { nest-guardian: principal, keeper: principal }
  { status: bool }
)

(define-map succession-requests
  { nest-guardian: principal }
  {
    timestamp: uint,
    approvals: (list 5 principal)
  }
)

;; Private Functions
(define-private (is-guardian (entity principal))
  (is-eq tx-sender entity)
)

(define-private (get-timestamp)
  (unwrap-panic (get-block-info? time u0))
)

(define-private (check-dormancy (nest-data {
                               treasures: (list 100 principal),
                               heirs: (list 5 principal),
                               dormancy-threshold: uint,
                               last-check: uint,
                               quorum-size: uint
                             }))
  (> (- (get-timestamp) (get last-check nest-data)) (get dormancy-threshold nest-data))
)

;; Public Functions
(define-public (create-nest (heirs (list 5 principal)) (dormancy-threshold uint) (quorum-size uint))
  (let ((nest-data {
          treasures: (list ),
          heirs: heirs,
          dormancy-threshold: dormancy-threshold,
          last-check: (get-timestamp),
          quorum-size: quorum-size
        }))
    (asserts! (is-none (map-get? nests { guardian: tx-sender })) (err err-nest-exists))
    (ok (map-set nests { guardian: tx-sender } nest-data))
  )
)

(define-public (store-treasure (treasure principal))
  (let ((nest (unwrap! (map-get? nests { guardian: tx-sender }) (err err-missing))))
    (let ((updated-treasures (unwrap! (as-max-len? (append (get treasures nest) treasure) u100) (err err-nest-full))))
      (ok (map-set nests
        { guardian: tx-sender }
        (merge nest {
          treasures: updated-treasures,
          last-check: (get-timestamp)
        })
      ))
    )
  )
)

(define-public (record-activity)
  (let ((nest (unwrap! (map-get? nests { guardian: tx-sender }) (err err-missing))))
    (ok (map-set nests
      { guardian: tx-sender }
      (merge nest { last-check: (get-timestamp) })
    ))
  )
)

(define-public (appoint-keeper (keeper principal))
  (let ((nest (unwrap! (map-get? nests { guardian: tx-sender }) (err err-missing))))
    (ok (map-set nest-keepers
      { nest-guardian: tx-sender, keeper: keeper }
      { status: true }
    ))
  )
)

(define-public (begin-succession (nest-guardian principal))
  (let ((nest (unwrap! (map-get? nests { guardian: nest-guardian }) (err err-missing))))
    (asserts! (check-dormancy nest) (err err-forbidden))
    (ok (map-set succession-requests
      { nest-guardian: nest-guardian }
      {
        timestamp: (get-timestamp),
        approvals: (list tx-sender)
      }
    ))
  )
)

(define-public (approve-succession (nest-guardian principal))
  (let (
    (nest (unwrap! (map-get? nests { guardian: nest-guardian }) (err err-missing)))
    (request (unwrap! (map-get? succession-requests { nest-guardian: nest-guardian }) (err err-missing)))
    (keeper-status (default-to { status: false } (map-get? nest-keepers { nest-guardian: nest-guardian, keeper: tx-sender })))
  )
    (asserts! (get status keeper-status) (err err-forbidden))
    (asserts! (check-dormancy nest) (err err-forbidden))
    (let ((updated-approvals (unwrap! (as-max-len? (append (get approvals request) tx-sender) u5) (err err-quorum-not-met))))
      (ok (map-set succession-requests
        { nest-guardian: nest-guardian }
        (merge request { approvals: updated-approvals })
      ))
    )
  )
)

(define-public (complete-succession (nest-guardian principal))
  (let (
    (nest (unwrap! (map-get? nests { guardian: nest-guardian }) (err err-missing)))
    (request (unwrap! (map-get? succession-requests { nest-guardian: nest-guardian }) (err err-missing)))
  )
    (asserts! (check-dormancy nest) (err err-forbidden))
    (asserts! (>= (len (get approvals request)) (get quorum-size nest)) (err err-quorum-not-met))
    (map-delete nests { guardian: nest-guardian })
    (map-delete succession-requests { nest-guardian: nest-guardian })
    (ok true)
  )
)

;; Read-only Functions
(define-read-only (get-nest-details (guardian principal))
  (ok (unwrap! (map-get? nests { guardian: guardian }) (err err-missing)))
)

(define-read-only (get-succession-request (nest-guardian principal))
  (ok (unwrap! (map-get? succession-requests { nest-guardian: nest-guardian }) (err err-missing)))
)