title Cloud-Based Healthcare Management System Architecture

direction right

// ============================================
// LAYER 1: CLIENT LAYER (Top-Left)
// ============================================
Clients [icon: users, color: #E8F4F8] {
  Web Portal [icon: monitor, label: "Web Portal\n(React)"]
  Mobile App [icon: smartphone, label: "Mobile App\n(iOS/Android)"]
  Provider Dashboard [icon: layout, label: "Provider Dashboard\n(EHR Access)"]
}

// ============================================
// LAYER 2: EDGE & CDN LAYER (Top-Center)
// ============================================
Edge [icon: globe, color: #E8F5E9] {
  CloudFront [icon: aws-cloudfront, label: "CloudFront\nCDN (TLS 1.3)\nCache Hit >85%"]
  Route 53 [icon: aws-route-53, label: "Route 53\nGlobal DNS\nHealth Checks"]
  AWS Shield [icon: aws-shield, label: "AWS Shield\nDDoS Protection\nStandard + Advanced"]
}

// ============================================
// LAYER 3: SECURITY LAYER (Top-Right)
// ============================================
Security Gateway [icon: shield, color: #FFEBEE] {
  WAF [icon: aws-waf, label: "WAF\nOWASP Top 10\nSQL/XSS Prevention"]
  Auth Service [icon: aws-cognito, label: "Cognito\nOAuth 2.0/SAML\nMFA (TOTP/SMS)"]
  API Gateway [icon: aws-api-gateway, label: "API Gateway\nREST/gRPC\nWebSocket"]
  Rate Limiter [icon: sliders, label: "Rate Limiter\n1000 req/min per user\nThrottling"]
}

// ============================================
// LAYER 4A: CORE MICROSERVICES (Left Column)
// ============================================
Core Services [icon: server, color: #F3E5F5] {
  EHR Service [icon: file-text, label: "EHR Service\nASG: Min 3, Max 20\nP99: <200ms"]
  EHR DB [icon: aws-rds, label: "EHR Database\nPostgreSQL\nMulti-AZ"]

  Patient Service [icon: user, label: "Patient Service\nASG: Min 3, Max 20\nP99: <200ms"]
  Patient DB [icon: aws-rds, label: "Patient DB\nPostgreSQL\nMulti-AZ"]

  Appointment Service [icon: calendar, label: "Appointment Service\nASG: Min 3, Max 20\nP99: <150ms"]
  Appointment DB [icon: aws-rds, label: "Appointment DB\nPostgreSQL\nMulti-AZ"]

  Billing Service [icon: dollar-sign, label: "Billing Service\nASG: Min 3, Max 20\nP99: <200ms"]
  Billing DB [icon: aws-rds, label: "Billing DB\nPostgreSQL\nMulti-AZ"]
}

// ============================================
// LAYER 4B: INTEGRATION LAYER (Center Column)
// ============================================
Integration [icon: shuffle, color: #FFFDE7] {
  HL7 FHIR Adapter [icon: git-merge, label: "HL7/FHIR Adapter\nHL7 v2 → FHIR\nMessage Transform"]

  Message Queue [icon: aws-sqs, label: "Message Queue\nSQS/Kafka\nAsync Processing\nRetry: 3x"]

  Schema Registry [icon: aws-glue, label: "Schema Registry\nFHIR Validation\nData Quality"]

  ETL Pipeline [icon: aws-glue, label: "ETL Pipeline\nData Transformation\nNormalization\nDaily @ 02:00 UTC"]
}

// ============================================
// LAYER 4C: TELEMEDICINE (Right Column)
// ============================================
Telemedicine [icon: video, color: #E0F2F1] {
  WebRTC Server [icon: aws-ec2, label: "WebRTC Media Server\nH.264/Opus\nLatency: <100ms"]

  TURN STUN [icon: aws-ec2, label: "TURN/STUN Servers\nNAT Traversal\nMulti-region"]

  Recording Service [icon: aws-s3, label: "Recording Service\nS3 Storage\nAuto Transcription"]

  Quality Monitor [icon: activity, label: "Quality Monitor\nAdaptive Bitrate\nJitter Handling"]
}

// ============================================
// LAYER 5: AI/ML ANALYTICS (Far Right)
// ============================================
AI Analytics [icon: cpu, color: #FFE0B2] {
  ML Training [icon: aws-sagemaker, label: "ML Training Pipeline\nMonthly Retraining\nDe-identified Data"]

  Feature Engineering [icon: aws-glue, label: "Feature Engineering\nData Preparation\nNormalization"]

  Model Inference [icon: aws-sagemaker, label: "Model Inference Service\nAccuracy: >95%\nLatency: <100ms"]

  AB Testing [icon: git-branch, label: "A/B Testing Framework\n10% Canary Start\nDrift Detection"]

  Model Registry [icon: aws-ecr, label: "Model Registry\nVersion Control\nAutomated Rollback"]
}

// ============================================
// LAYER 6: DATA STORAGE TIER (Bottom)
// ============================================
Data Storage [icon: database, color: #E8F5E9] {
  Redis Cache [icon: aws-elasticache, label: "Redis Cache (HOT)\nSession Storage\nTTL: 24h\nHit Ratio: >85%\nCluster Mode"]

  Primary Aurora [icon: aws-aurora, label: "Aurora Primary (WARM)\nMulti-AZ Deployment\nDaily Snapshot\nConnection Pool: 100\nBackup: 30 days"]

  S3 Storage [icon: aws-s3, label: "S3 (COLD)\nDocuments & Images\nVersioning Enabled\nServer-side Encryption"]

  S3 Glacier [icon: aws-s3-glacier, label: "Glacier Archive\nLifecycle: 90 days\n90% Cost Reduction\n6+ Year Retention"]
}

// ============================================
// LAYER 7: MONITORING & OBSERVABILITY (Bottom)
// ============================================
Monitoring [icon: activity, color: #F3E5F5] {
  CloudWatch [icon: aws-cloudwatch, label: "CloudWatch\nMetrics: 1000s/min\nDashboards\nAlarms"]

  XRay [icon: aws-xray, label: "X-Ray\nDistributed Tracing\nLatency Analysis\nError Detection"]

  Audit Logs [icon: file, label: "Audit Logs\nAll User Actions\nTimestamp & ID\n6+ Year Retention"]

  PagerDuty [icon: alert-circle, label: "Alerting\nPagerDuty Integration\nSMS + Email\nOn-call Support"]
}

// ============================================
// LAYER 8: SECURITY SERVICES (Bottom-Left)
// ============================================
Security Services [icon: lock, color: #FFEBEE] {
  Secrets Manager [icon: aws-secrets-manager, label: "Secrets Manager\nCredential Rotation\nAutomated Updates"]

  KMS [icon: aws-kms, label: "AWS KMS\nAES-256 Encryption\nKey Rotation\nData at Rest"]

  VPN Direct Connect [icon: vpn, label: "VPN/Direct Connect\nProvider Access\nSecure Channel"]
}

// ============================================
// LAYER 9: DISASTER RECOVERY (Far Right, Secondary Region)
// ============================================
DR Region [icon: aws-region, color: #F5F5F5] {
  Aurora Replica [icon: aws-aurora, label: "Aurora Replica\n(Standby us-west-2)\nSynchronous Replication\nRTO: 5 min\nRPO: <1 min"]

  Cache Replica [icon: aws-elasticache, label: "Redis Replica\nMulti-AZ Cluster\nAuto Failover"]

  Backup Storage [icon: aws-s3, label: "Backup Storage\nCross-Region Replication\nS3 Versioning"]
}

// ============================================
// LAYER 10: EXTERNAL SYSTEMS
// ============================================
External [icon: globe, color: #F5F5F5] {
  Legacy Systems [icon: server, label: "Legacy Systems\nHL7 v2 Format\nEDI/X12\nLIS/PACS"]

  Payment Gateway [icon: credit-card, label: "Payment Gateway\nPCI Compliant\nTokenization"]

  SMS Gateway [icon: message-square, label: "SMS Gateway\nAppointment Reminders\nNotifications"]

  Email Service [icon: mail, label: "Email Service (SES)\nNotifications\nReporting"]
}

// ============================================
// PERFORMANCE & COMPLIANCE LABELS
// ============================================
Performance [icon: zap, color: #FFF9C4] {
  SLAs [label: "System Availability: 99.99%\nError Rate: <0.1%\nThroughput: 50k req/sec\nConcurrent Users: 10,000"]
}

// ============================================
// CONNECTIONS - CLIENT LAYER
// ============================================

// Client to Edge
Clients > CloudFront: "HTTPS\nTLS 1.3"
CloudFront > Route 53: "DNS Query"
Route 53 > AWS Shield: "Route Through"

// ============================================
// CONNECTIONS - EDGE TO SECURITY
// ============================================

AWS Shield > WAF: "Threat Detection"
WAF > API Gateway: "Clean Traffic"
API Gateway <> Auth Service: "OAuth 2.0\nToken Validation"
API Gateway > Rate Limiter: "Rate Check\n1000 req/min"

// ============================================
// CONNECTIONS - SECURITY TO SERVICES
// ============================================

Rate Limiter > Core Services: "Authenticated\nRequests"
Rate Limiter > Telemedicine: "WebSocket\nConnections"
Rate Limiter > Integration: "Event & Queue"

// ============================================
// CORE SERVICES INTERNAL CONNECTIONS
// ============================================

EHR Service <> EHR DB: "SQL (Pool: 100)"
Patient Service <> Patient DB: "SQL (Pool: 100)"
Appointment Service <> Appointment DB: "SQL (Pool: 100)"
Billing Service <> Billing DB: "SQL (Pool: 100)"

// ============================================
// CORE SERVICES TO CACHING
// ============================================

Core Services <> Redis Cache: "Session/Cache\nGET/SET"
Core Services <> Primary Aurora: "Primary Write\nRead Replica"

// ============================================
// INTEGRATION LAYER CONNECTIONS
// ============================================

External > Legacy Systems: "HL7 v2 Messages"
Legacy Systems > HL7 FHIR Adapter: "HL7 Format"
HL7 FHIR Adapter > Schema Registry: "Validate Schema"
Schema Registry --> HL7 FHIR Adapter: "Validation Result"
HL7 FHIR Adapter > Message Queue: "FHIR Compliant\nAsync Messages"
Message Queue --> Core Services: "Retry: 3x\nDead Letter Queue"
Message Queue > ETL Pipeline: "Transform Data"
ETL Pipeline > Primary Aurora: "Store Normalized\nData"

// ============================================
// TELEMEDICINE CONNECTIONS
// ============================================

Core Services > WebRTC Server: "WebSocket\nVideo Invite"
WebRTC Server <> TURN STUN: "NAT Traversal\nSTUN/TURN"
WebRTC Server > Recording Service: "H.264/Opus\nRTP Stream"
Recording Service > S3 Storage: "Store Recording\nWith Metadata"
Quality Monitor > WebRTC Server: "Monitor Stream\nQuality Metrics"

// ============================================
// ANALYTICS & ML CONNECTIONS
// ============================================

ETL Pipeline > ML Training: "De-identified\nPatient Data"
Primary Aurora --> ML Training: "Training Data"
Feature Engineering > Model Inference: "Features"
Model Inference > Model Registry: "Publish v1.2.3"
Model Registry > AB Testing: "Model Versions"
AB Testing --> Model Inference: "Metrics & Feedback"
Model Inference > Core Services: "Clinical Decision\nSupport"

// ============================================
// MONITORING CONNECTIONS (Dotted for observability)
// ============================================

Core Services --> CloudWatch: "Metrics"
WebRTC Server --> CloudWatch: "Stream Quality"
Message Queue --> CloudWatch: "Queue Depth"
API Gateway --> XRay: "Trace Requests"
Primary Aurora --> XRay: "Query Tracing"
CloudWatch --> Audit Logs: "Log Aggregation"
CloudWatch --> PagerDuty: "Critical Alerts"

// ============================================
// SECURITY CONNECTIONS
// ============================================

Secrets Manager > Core Services: "Database\nCredentials"
Secrets Manager > Integration: "API Keys"
KMS > Primary Aurora: "Encrypt at Rest\n(AES-256)"
KMS > S3 Storage: "Encrypt at Rest\n(AES-256)"
KMS > Redis Cache: "Encrypt Sessions"
VPN Direct Connect > Core Services: "Secure\nProvider Access"

// ============================================
// DATA STORAGE CONNECTIONS
// ============================================

Primary Aurora <> Redis Cache: "Cache Invalidation"
S3 Storage --> S3 Glacier: "Lifecycle Policy\n90 days"
EHR Service > S3 Storage: "Document Upload\nEncrypted"
Telemedicine > S3 Storage: "Recordings\nCompressed"

// ============================================
// DISASTER RECOVERY CONNECTIONS
// ============================================

Primary Aurora --> Aurora Replica: "Synchronous\nReplication\nMulti-region"
Redis Cache --> Cache Replica: "Async Replication\nCluster Failover"
S3 Storage --> Backup Storage: "Cross-Region\nReplication"
Route 53 --> Aurora Replica: "Health Check\nFailover\n<1 min"
Route 53 --> DR Region: "Traffic Redirect\nRTO: 5 min"

// ============================================
// EXTERNAL SERVICES CONNECTIONS
// ============================================

Billing Service > Payment Gateway: "Charge Patient\nPCI Compliant"
Appointment Service > SMS Gateway: "24h Reminder\nNotification"
Core Services > Email Service: "Report Distribution\nNotifications"

// ============================================
// COST OPTIMIZATION ANNOTATIONS
// ============================================

Cost Optimization [icon: dollar-sign, color: #FFF9C4] {
  Pricing [label: "Reserved Instances: 40% discount\nSpot Instances: 70% savings\nData Tiering: Hot/Warm/Cold\nMonthly Cost: $11,600 (36% optimized)"]
}

// ============================================
// COMPLIANCE & STANDARDS ANNOTATIONS
// ============================================

Compliance [icon: check-circle, color: #C8E6C9] {
  Standards [label: "HIPAA Compliant\nFHIR Standard\nHL7 v2/v3\nOAUTH 2.0/SAML\nTLS 1.3 Encryption"]
}
