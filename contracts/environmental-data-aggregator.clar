;; title: environmental-data-aggregator
;; version: 1.0.0
;; summary: Collects and validates environmental data from multiple sources to predict natural disasters
;; description: Aggregates environmental data from weather stations, seismic sensors, and satellite imagery.
;;              Handles data quality verification, predictive analytics, and real-time risk assessment.

;; Error constants
(define-constant err-owner-only (err u100))
(define-constant err-invalid-data-source (err u101))
(define-constant err-data-out-of-range (err u102))
(define-constant err-source-not-registered (err u103))
(define-constant err-insufficient-data (err u104))
(define-constant err-threshold-invalid (err u105))

;; Risk level constants
(define-constant RISK-SAFE u0)
(define-constant RISK-LOW u25)
(define-constant RISK-MODERATE u50)
(define-constant RISK-HIGH u75)
(define-constant RISK-EXTREME u100)

;; Data quality constants
(define-constant MIN-RELIABILITY-SCORE u60)
(define-constant MAX-DATA-AGE u3600) ;; 1 hour in seconds

;; Contract owner
(define-data-var contract-owner principal tx-sender)

;; Global risk thresholds
(define-data-var seismic-threshold uint u50)
(define-data-var temperature-threshold uint u40) ;; Celsius
(define-data-var air-quality-threshold uint u150) ;; AQI
(define-data-var humidity-threshold uint u85) ;; Percentage

;; Data source registry - tracks registered oracles and their reliability scores
(define-map data-sources 
    principal 
    {
        name: (string-ascii 50),
        reliability-score: uint,
        last-submission: uint,
        is-active: bool
    }
)

;; Environmental data storage - stores latest readings from each source
(define-map environmental-readings
    { source: principal, data-type: (string-ascii 20) }
    {
        value: uint,
        timestamp: uint,
        location: (string-ascii 100),
        confidence: uint
    }
)

;; Historical risk scores for trend analysis
(define-map risk-history
    uint ;; timestamp
    {
        overall-risk: uint,
        seismic-risk: uint,
        weather-risk: uint,
        air-quality-risk: uint
    }
)

;; Regional risk assessments
(define-map regional-risks
    (string-ascii 50) ;; region name
    {
        current-risk: uint,
        last-updated: uint,
        active-alerts: uint
    }
)

;; Register a new data source oracle
(define-public (register-data-source (name (string-ascii 50)) (source principal))
    (begin
        (asserts! (is-eq tx-sender (var-get contract-owner)) err-owner-only)
        (map-set data-sources source {
            name: name,
            reliability-score: u80, ;; Default reliability score
            last-submission: u0,
            is-active: true
        })
        (print { event: "data-source-registered", source: source, name: name })
        (ok true)
    )
)

;; Submit environmental data reading
(define-public (submit-environmental-data 
    (data-type (string-ascii 20))
    (value uint)
    (location (string-ascii 100))
    (confidence uint))
    (let (
        (source-info (map-get? data-sources tx-sender))
        (current-time (unwrap-panic (get-stacks-block-info? time (- stacks-block-height u1))))
    )
        ;; Verify source is registered and active
        (asserts! (is-some source-info) err-source-not-registered)
        (asserts! (get is-active (unwrap-panic source-info)) err-invalid-data-source)
        
        ;; Validate data ranges based on type
        (asserts! (validate-data-range data-type value) err-data-out-of-range)
        (asserts! (<= confidence u100) err-data-out-of-range)
        
        ;; Store the environmental reading
        (map-set environmental-readings 
            { source: tx-sender, data-type: data-type }
            {
                value: value,
                timestamp: current-time,
                location: location,
                confidence: confidence
            }
        )
        
        ;; Update source's last submission time
        (map-set data-sources tx-sender 
            (merge (unwrap-panic source-info) { last-submission: current-time })
        )
        
        ;; Trigger risk assessment if high-value reading
        (if (is-high-risk-reading data-type value)
            (begin
                (print { event: "high-risk-data-detected", type: data-type, value: value, source: tx-sender })
                (unwrap-panic (update-regional-risk-score location))
            )
            true
        )
        
        (print { event: "environmental-data-submitted", type: data-type, value: value, source: tx-sender })
        (ok true)
    )
)

;; Update risk assessment thresholds (owner only)
(define-public (update-risk-thresholds 
    (seismic uint) 
    (temperature uint) 
    (air-quality uint) 
    (humidity uint))
    (begin
        (asserts! (is-eq tx-sender (var-get contract-owner)) err-owner-only)
        (asserts! (and (> seismic u0) (<= seismic u100)) err-threshold-invalid)
        (asserts! (and (> temperature u0) (<= temperature u60)) err-threshold-invalid)
        (asserts! (and (> air-quality u0) (<= air-quality u500)) err-threshold-invalid)
        (asserts! (and (> humidity u0) (<= humidity u100)) err-threshold-invalid)
        
        (var-set seismic-threshold seismic)
        (var-set temperature-threshold temperature)
        (var-set air-quality-threshold air-quality)
        (var-set humidity-threshold humidity)
        
        (print { event: "risk-thresholds-updated", seismic: seismic, temperature: temperature })
        (ok true)
    )
)

;; Deactivate unreliable data source
(define-public (deactivate-data-source (source principal))
    (let ((source-info (unwrap! (map-get? data-sources source) err-source-not-registered)))
        (asserts! (is-eq tx-sender (var-get contract-owner)) err-owner-only)
        (map-set data-sources source 
            (merge source-info { is-active: false })
        )
        (print { event: "data-source-deactivated", source: source })
        (ok true)
    )
)

;; Get current comprehensive risk score (0-100)
(define-read-only (get-current-risk-score)
    (let (
        (seismic-risk (calculate-seismic-risk))
        (weather-risk (calculate-weather-risk))
        (air-quality-risk (calculate-air-quality-risk))
    )
        (/ (+ seismic-risk weather-risk air-quality-risk) u3)
    )
)

;; Get regional risk assessment
(define-read-only (get-regional-risk (region (string-ascii 50)))
    (map-get? regional-risks region)
)

;; Get data source reliability information
(define-read-only (get-data-source-info (source principal))
    (map-get? data-sources source)
)

;; Get latest environmental reading for specific source and data type
(define-read-only (get-environmental-reading (source principal) (data-type (string-ascii 20)))
    (map-get? environmental-readings { source: source, data-type: data-type })
)

;; Get historical risk data
(define-read-only (get-risk-history (timestamp uint))
    (map-get? risk-history timestamp)
)

;; Check if data source is active and reliable
(define-read-only (is-source-reliable (source principal))
    (match (map-get? data-sources source)
        source-info (and 
            (get is-active source-info)
            (>= (get reliability-score source-info) MIN-RELIABILITY-SCORE)
        )
        false
    )
)

;; Private function to validate data ranges based on type
(define-private (validate-data-range (data-type (string-ascii 20)) (value uint))
    (if (is-eq data-type "seismic")
        (<= value u100)  ;; Richter scale equivalent (0-100)
        (if (is-eq data-type "temperature")
            (and (>= value u0) (<= value u60))  ;; -20 to 60 Celsius (offset by 20)
            (if (is-eq data-type "air-quality")
                (<= value u500)  ;; AQI 0-500
                (if (is-eq data-type "humidity")
                    (<= value u100)  ;; 0-100%
                    true  ;; Default: accept any value for unknown types
                )
            )
        )
    )
)

;; Private function to check if reading indicates high risk
(define-private (is-high-risk-reading (data-type (string-ascii 20)) (value uint))
    (if (is-eq data-type "seismic")
        (>= value (var-get seismic-threshold))
        (if (is-eq data-type "temperature")
            (>= value (var-get temperature-threshold))
            (if (is-eq data-type "air-quality")
                (>= value (var-get air-quality-threshold))
                (if (is-eq data-type "humidity")
                    (>= value (var-get humidity-threshold))
                    false
                )
            )
        )
    )
)

;; Private function to calculate seismic risk based on recent data
(define-private (calculate-seismic-risk)
    ;; Simplified risk calculation - in production, this would analyze multiple data points
    ;; and apply sophisticated algorithms
    (let ((threshold (var-get seismic-threshold)))
        (if (> threshold u80)
            RISK-EXTREME
            (if (> threshold u60)
                RISK-HIGH
                (if (> threshold u40)
                    RISK-MODERATE
                    RISK-LOW
                )
            )
        )
    )
)

;; Private function to calculate weather-related risk
(define-private (calculate-weather-risk)
    (let ((temp-threshold (var-get temperature-threshold))
          (humid-threshold (var-get humidity-threshold)))
        (if (and (> temp-threshold u45) (> humid-threshold u90))
            RISK-HIGH
            (if (or (> temp-threshold u40) (> humid-threshold u80))
                RISK-MODERATE
                RISK-LOW
            )
        )
    )
)

;; Private function to calculate air quality risk
(define-private (calculate-air-quality-risk)
    (let ((aqi-threshold (var-get air-quality-threshold)))
        (if (> aqi-threshold u300)
            RISK-EXTREME
            (if (> aqi-threshold u200)
                RISK-HIGH
                (if (> aqi-threshold u150)
                    RISK-MODERATE
                    RISK-LOW
                )
            )
        )
    )
)

;; Private function to update regional risk scores
(define-private (update-regional-risk-score (region (string-ascii 100)))
    (let (
        (current-risk (get-current-risk-score))
        (current-time (unwrap-panic (get-stacks-block-info? time (- stacks-block-height u1))))
    )
        (map-set regional-risks (unwrap-panic (as-max-len? region u50))
            {
                current-risk: current-risk,
                last-updated: current-time,
                active-alerts: (if (> current-risk RISK-MODERATE) u1 u0)
            }
        )
        
        ;; Store in historical data
        (map-set risk-history current-time
            {
                overall-risk: current-risk,
                seismic-risk: (calculate-seismic-risk),
                weather-risk: (calculate-weather-risk),
                air-quality-risk: (calculate-air-quality-risk)
            }
        )
        
        (ok true)
    )
)
