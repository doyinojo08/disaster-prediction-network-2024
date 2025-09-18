;; title: emergency-response-coordinator
;; version: 1.0.0
;; summary: Manages emergency alerts and coordinates response efforts for natural disasters
;; description: Automates emergency alert distribution, handles evacuation route optimization,
;;              manages resource allocation, and coordinates post-disaster damage assessment.

;; Error constants
(define-constant err-owner-only (err u200))
(define-constant err-unauthorized-authority (err u201))
(define-constant err-invalid-region (err u202))
(define-constant err-resource-not-found (err u203))
(define-constant err-insufficient-resources (err u204))
(define-constant err-invalid-status (err u205))
(define-constant err-route-not-found (err u206))
(define-constant err-duplicate-resource (err u207))

;; Alert status constants
(define-constant STATUS-SAFE "SAFE")
(define-constant STATUS-WATCH "WATCH")
(define-constant STATUS-ALERT "ALERT")
(define-constant STATUS-EVACUATE "EVACUATE")
(define-constant STATUS-RESCUE "RESCUE")

;; Resource type constants
(define-constant RESOURCE-MEDICAL "MEDICAL")
(define-constant RESOURCE-FOOD "FOOD")
(define-constant RESOURCE-SHELTER "SHELTER")
(define-constant RESOURCE-TRANSPORT "TRANSPORT")
(define-constant RESOURCE-RESCUE-TEAM "RESCUE_TEAM")

;; Priority levels
(define-constant PRIORITY-LOW u1)
(define-constant PRIORITY-MEDIUM u2)
(define-constant PRIORITY-HIGH u3)
(define-constant PRIORITY-CRITICAL u4)

;; Contract owner and authorized emergency authorities
(define-data-var contract-owner principal tx-sender)
(define-data-var emergency-authority principal tx-sender)
(define-data-var active-alerts-count uint u0)
(define-data-var total-evacuations uint u0)
(define-data-var total-resources-deployed uint u0)

;; Regional status tracking
(define-map region-status
    (string-ascii 50) ;; region name
    {
        current-status: (string-ascii 20),
        alert-level: uint,
        last-updated: uint,
        population-affected: uint,
        evacuation-ordered: bool
    }
)

;; Evacuation routes management
(define-map evacuation-routes
    { region: (string-ascii 50), route-id: uint }
    {
        route-name: (string-ascii 100),
        capacity: uint,
        current-load: uint,
        destination: (string-ascii 100),
        estimated-time: uint,
        is-active: bool,
        priority: uint
    }
)

;; Emergency resources tracking
(define-map emergency-resources
    { resource-id: uint, resource-type: (string-ascii 20) }
    {
        name: (string-ascii 100),
        quantity-available: uint,
        quantity-deployed: uint,
        location: (string-ascii 100),
        contact-info: (string-ascii 200),
        last-updated: uint,
        is-operational: bool
    }
)

;; Resource allocation records
(define-map resource-allocations
    uint ;; allocation-id
    {
        region: (string-ascii 50),
        resource-type: (string-ascii 20),
        quantity: uint,
        allocated-by: principal,
        timestamp: uint,
        status: (string-ascii 20)
    }
)

;; Damage assessment reports
(define-map damage-assessments
    { region: (string-ascii 50), report-id: uint }
    {
        assessor: principal,
        damage-level: uint, ;; 0-100 scale
        infrastructure-cost: uint,
        casualties: uint,
        buildings-affected: uint,
        report-timestamp: uint,
        verified: bool
    }
)

;; Volunteer coordination
(define-map volunteer-registry
    principal
    {
        name: (string-ascii 100),
        skills: (string-ascii 200),
        location: (string-ascii 100),
        availability: bool,
        assignments: uint,
        rating: uint
    }
)

;; Emergency alert history
(define-map alert-history
    uint ;; alert-id
    {
        region: (string-ascii 50),
        alert-type: (string-ascii 30),
        message: (string-ascii 500),
        issued-by: principal,
        timestamp: uint,
        recipients-count: uint
    }
)

;; Set emergency authority (owner only)
(define-public (set-emergency-authority (authority principal))
    (begin
        (asserts! (is-eq tx-sender (var-get contract-owner)) err-owner-only)
        (var-set emergency-authority authority)
        (print { event: "emergency-authority-updated", authority: authority })
        (ok true)
    )
)

;; Trigger emergency alert for specific region
(define-public (trigger-emergency-alert 
    (region (string-ascii 50))
    (alert-type (string-ascii 30))
    (message (string-ascii 500))
    (priority uint))
    (let (
        (alert-id (+ (var-get active-alerts-count) u1))
        (current-time (unwrap-panic (get-stacks-block-info? time (- stacks-block-height u1))))
    )
        ;; Only authorized emergency authority can trigger alerts
        (asserts! (or 
            (is-eq tx-sender (var-get contract-owner))
            (is-eq tx-sender (var-get emergency-authority))
        ) err-unauthorized-authority)
        
        (asserts! (<= priority PRIORITY-CRITICAL) err-invalid-status)
        
        ;; Update region status based on alert priority
        (unwrap-panic (update-region-status region 
            (if (>= priority PRIORITY-HIGH) STATUS-EVACUATE STATUS-ALERT)
            priority
        ))
        
        ;; Record alert in history
        (map-set alert-history alert-id {
            region: region,
            alert-type: alert-type,
            message: message,
            issued-by: tx-sender,
            timestamp: current-time,
            recipients-count: u0 ;; Would be updated by notification system
        })
        
        ;; Update alert counter
        (var-set active-alerts-count alert-id)
        
        (print { 
            event: "emergency-alert-triggered", 
            region: region, 
            type: alert-type, 
            priority: priority,
            alert-id: alert-id
        })
        
        (ok alert-id)
    )
)

;; Register evacuation route for a region
(define-public (register-evacuation-route
    (region (string-ascii 50))
    (route-id uint)
    (route-name (string-ascii 100))
    (capacity uint)
    (destination (string-ascii 100))
    (estimated-time uint)
    (priority uint))
    (begin
        (asserts! (or 
            (is-eq tx-sender (var-get contract-owner))
            (is-eq tx-sender (var-get emergency-authority))
        ) err-unauthorized-authority)
        
        (map-set evacuation-routes { region: region, route-id: route-id } {
            route-name: route-name,
            capacity: capacity,
            current-load: u0,
            destination: destination,
            estimated-time: estimated-time,
            is-active: true,
            priority: priority
        })
        
        (print { event: "evacuation-route-registered", region: region, route-id: route-id })
        (ok true)
    )
)

;; Allocate emergency resources to a region
(define-public (allocate-resources
    (region (string-ascii 50))
    (resource-type (string-ascii 20))
    (quantity uint))
    (let (
        (allocation-id (+ (var-get total-resources-deployed) u1))
        (current-time (unwrap-panic (get-stacks-block-info? time (- stacks-block-height u1))))
    )
        (asserts! (or 
            (is-eq tx-sender (var-get contract-owner))
            (is-eq tx-sender (var-get emergency-authority))
        ) err-unauthorized-authority)
        
        (asserts! (> quantity u0) err-insufficient-resources)
        
        ;; Record resource allocation
        (map-set resource-allocations allocation-id {
            region: region,
            resource-type: resource-type,
            quantity: quantity,
            allocated-by: tx-sender,
            timestamp: current-time,
            status: "ALLOCATED"
        })
        
        ;; Update deployment counter
        (var-set total-resources-deployed allocation-id)
        
        (print { 
            event: "resources-allocated", 
            region: region, 
            type: resource-type, 
            quantity: quantity,
            allocation-id: allocation-id
        })
        
        (ok allocation-id)
    )
)

;; Submit damage assessment report
(define-public (report-damage-assessment
    (region (string-ascii 50))
    (report-id uint)
    (damage-level uint)
    (infrastructure-cost uint)
    (casualties uint)
    (buildings-affected uint))
    (let ((current-time (unwrap-panic (get-stacks-block-info? time (- stacks-block-height u1)))))
        (asserts! (<= damage-level u100) err-invalid-status)
        
        (map-set damage-assessments { region: region, report-id: report-id } {
            assessor: tx-sender,
            damage-level: damage-level,
            infrastructure-cost: infrastructure-cost,
            casualties: casualties,
            buildings-affected: buildings-affected,
            report-timestamp: current-time,
            verified: false
        })
        
        (print { 
            event: "damage-assessment-submitted", 
            region: region, 
            damage-level: damage-level,
            report-id: report-id
        })
        
        (ok true)
    )
)

;; Register volunteer for emergency response
(define-public (register-volunteer
    (name (string-ascii 100))
    (skills (string-ascii 200))
    (location (string-ascii 100)))
    (begin
        (map-set volunteer-registry tx-sender {
            name: name,
            skills: skills,
            location: location,
            availability: true,
            assignments: u0,
            rating: u5 ;; Default rating out of 10
        })
        
        (print { event: "volunteer-registered", volunteer: tx-sender, name: name })
        (ok true)
    )
)

;; Activate evacuation for a region
(define-public (activate-evacuation (region (string-ascii 50)))
    (let ((current-status (get-region-status region)))
        (asserts! (or 
            (is-eq tx-sender (var-get contract-owner))
            (is-eq tx-sender (var-get emergency-authority))
        ) err-unauthorized-authority)
        
        (unwrap-panic (update-region-status region STATUS-EVACUATE PRIORITY-CRITICAL))
        (var-set total-evacuations (+ (var-get total-evacuations) u1))
        
        (print { event: "evacuation-activated", region: region })
        (ok true)
    )
)

;; Get current region status
(define-read-only (get-region-status (region (string-ascii 50)))
    (map-get? region-status region)
)

;; Get evacuation route information
(define-read-only (get-evacuation-route (region (string-ascii 50)) (route-id uint))
    (map-get? evacuation-routes { region: region, route-id: route-id })
)

;; Get available emergency resources
(define-read-only (get-emergency-resource (resource-id uint) (resource-type (string-ascii 20)))
    (map-get? emergency-resources { resource-id: resource-id, resource-type: resource-type })
)

;; Get damage assessment report
(define-read-only (get-damage-assessment (region (string-ascii 50)) (report-id uint))
    (map-get? damage-assessments { region: region, report-id: report-id })
)

;; Get volunteer information
(define-read-only (get-volunteer-info (volunteer principal))
    (map-get? volunteer-registry volunteer)
)

;; Get resource allocation details
(define-read-only (get-resource-allocation (allocation-id uint))
    (map-get? resource-allocations allocation-id)
)

;; Get emergency alert details
(define-read-only (get-alert-history (alert-id uint))
    (map-get? alert-history alert-id)
)

;; Get emergency statistics
(define-read-only (get-emergency-statistics)
    {
        active-alerts: (var-get active-alerts-count),
        total-evacuations: (var-get total-evacuations),
        resources-deployed: (var-get total-resources-deployed)
    }
)

;; Private function to update region status
(define-private (update-region-status (region (string-ascii 50)) (status (string-ascii 20)) (alert-level uint))
    (let (
        (current-time (unwrap-panic (get-stacks-block-info? time (- stacks-block-height u1))))
        (evacuation-required (is-eq status STATUS-EVACUATE))
    )
        (map-set region-status region {
            current-status: status,
            alert-level: alert-level,
            last-updated: current-time,
            population-affected: u0, ;; Would be updated based on census data
            evacuation-ordered: evacuation-required
        })
        
        (begin
            (print (if evacuation-required
                { event: "evacuation-ordered", region: region, alert-level: alert-level }
                { event: "region-status-updated", region: region, status: status, alert-level: alert-level }
            ))
            true
        )
        
        (ok true)
    )
)
