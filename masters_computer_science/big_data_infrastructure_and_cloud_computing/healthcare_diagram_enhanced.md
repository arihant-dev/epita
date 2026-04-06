title Cloud-Based Healthcare Management System Architecture - Enhanced Layout

direction right
textSize medium

// ============================================
// LAYER 1: CLIENT LAYER
// ============================================
Clients [icon: users, color: #E8F4F8, textSize: medium] {
  WebPortal [label: "Web Portal", icon: monitor]
  MobileApp [label: "Mobile App", icon: smartphone]
  ProviderDashboard [label: "Provider Dashboard", icon: layout]
}

// ============================================
// LAYER 2: EDGE & CDN LAYER
// ============================================
Edge [icon: globe, color: #E8F5E9, textSize: medium] {
  CloudFront [icon: aws-cloudfront, textSize: medium]
  Route53 [label: "Route 53", icon: aws-route-53, textSize: medium]
  AWSShield [label: "AWS Shield", icon: aws-shield, textSize: medium]
}

// ============================================
// LAYER 3: SECURITY GATEWAY
// ============================================
SecurityGateway [label: "Security Gateway", icon: shield, color: #FFEBEE, textSize: medium] {
  WAF [icon: aws-waf, textSize: medium]
  Auth [icon: aws-cognito]
  APIGateway [label: "API Gateway", icon: aws-api-gateway]
  RateLimiter [label: "Rate Limiter", icon: sliders]
}

// ============================================
// LAYER 4A: CORE MICROSERVICES
// ============================================
CoreServices [label: "Core Services", icon: server, color: #F3E5F5] {
  EHRService [label: "EHR Service", icon: file-text]
  EHRDB [label: "EHR DB", icon: aws-rds]

  PatientService [label: "Patient Service", icon: user]
  PatientDB [label: "Patient DB", icon: aws-rds]

  AppointmentService [label: "Appointment Service", icon: calendar]
  AppointmentDB [label: "Appointment DB", icon: aws-rds]

  BillingService [label: "Billing Service", icon: dollar-sign]
  BillingDB [label: "Billing DB", icon: aws-rds]
}

// ============================================
// LAYER 4B: INTEGRATION
// ============================================
Integration [icon: shuffle, color: #FFFDE7] {
  HL7FHIRAdapter [label: "HL7 FHIR Adapter", icon: git-merge]
  MessageQueue [label: "Message Queue", icon: aws-sqs]
  SchemaRegistry [label: "Schema Registry", icon: aws-glue]
  ETLPipeline [label: "ETL Pipeline", icon: aws-glue]
}

// ============================================
// LAYER 4C: TELEMEDICINE
// ============================================
Telemedicine [icon: video, color: #E0F2F1] {
  WebRTCServer [label: "WebRTC Server", icon: aws-ec2]
  TURN_STUN [label: "TURN / STUN", icon: aws-ec2]
  RecordingService [label: "Recording Service", icon: aws-s3]
  QualityMonitor [label: "Quality Monitor", icon: activity]
}

// ============================================
// LAYER 5: AI/ML ANALYTICS
// ============================================
AIAnalytics [label: "AI Analytics", icon: cpu, color: #FFE0B2] {
  MLTraining [label: "ML Training", icon: aws-sagemaker]
  FeatureEngineering [label: "Feature Engineering", icon: aws-glue]
  ModelInference [label: "Model Inference", icon: aws-sagemaker]
  ABTesting [label: "A/B Testing", icon: git-branch]
  ModelRegistry [label: "Model Registry", icon: aws-ecr]
}

// ============================================
// LAYER 6: DATA STORAGE (3-Tier)
// ============================================
DataStorage [label: "Data Storage", icon: database, color: #E8F5E9] {
  RedisCache [label: "Redis Cache", icon: aws-elasticache]
  PrimaryAurora [label: "Primary Aurora", icon: aws-aurora]
  S3Storage [label: "S3 Storage", icon: aws-s3]
  S3Glacier [label: "S3 Glacier", icon: aws-s3-glacier]
}

// ============================================
// LAYER 7: MONITORING & OBSERVABILITY
// ============================================
Monitoring [icon: activity, color: #F3E5F5] {
  CloudWatch [icon: aws-cloudwatch]
  XRay [label: "X-Ray", icon: aws-xray]
  AuditLogs [label: "Audit Logs", icon: file]
  PagerDuty [icon: alert-circle]
}

// ============================================
// LAYER 8: SECURITY SERVICES
// ============================================
SecurityServices [label: "Security Services", icon: lock, color: #FFEBEE] {
  SecretsManager [label: "Secrets Manager", icon: aws-secrets-manager]
  KMS [icon: aws-kms]
  VPNDirectConnect [label: "VPN Direct Connect", icon: vpn]
}

// ============================================
// LAYER 9: DISASTER RECOVERY
// ============================================
DRRegion [label: "DR Region", icon: aws-region, color: #F5F5F5] {
  AuroraReplica [label: "Aurora Replica", icon: aws-aurora]
  CacheReplica [label: "Cache Replica", icon: aws-elasticache]
  BackupStorage [label: "Backup Storage", icon: aws-s3]
}

// ============================================
// LAYER 10: EXTERNAL INTEGRATIONS
// ============================================
External [icon: globe, color: #F5F5F5] {
  LegacySystems [label: "Legacy Systems", icon: server]
  PaymentGateway [label: "Payment Gateway", icon: credit-card]
  SMSGateway [label: "SMS Gateway", icon: message-square]
  EmailService [label: "Email Service", icon: mail]
}

// ============================================
// CONNECTIONS
// ============================================
Clients > CloudFront: "HTTPS/TLS 1.3"
CloudFront > Route53: "DNS"
Route53 > AWSShield: "Route"

AWSShield > WAF: "Threat Detection"
WAF > APIGateway: "Clean Traffic"
APIGateway <-> Auth: "OAuth 2.0"
APIGateway > RateLimiter: "Rate Check"

RateLimiter > CoreServices: "Authenticated Requests"
RateLimiter > Telemedicine: "WebSocket"
RateLimiter > Integration: "Events"

EHRService <-> EHRDB: "SQL Pool: 100"
PatientService <-> PatientDB: "SQL Pool: 100"
AppointmentService <-> AppointmentDB: "SQL Pool: 100"
BillingService <-> BillingDB: "SQL Pool: 100"

CoreServices <-> RedisCache: "GET/SET"
CoreServices <-> PrimaryAurora: "Read/Write"

External > LegacySystems: "HL7 v2"
LegacySystems > HL7FHIRAdapter: "HL7 Format"
HL7FHIRAdapter > SchemaRegistry: "Validate"
MessageQueue -> CoreServices: "Async (Retry 3x)"
ETLPipeline > PrimaryAurora: "Transform"

CoreServices > WebRTCServer: "WebSocket"
WebRTCServer <-> TURN_STUN: "NAT"
RecordingService > S3Storage: "H.264/Opus"

PrimaryAurora -> MLTraining: "Patient Data (De-identified)"
FeatureEngineering > ModelInference: "Features"
ModelInference > ABTesting: "Compare Models"
ModelInference > CoreServices: "Predictions"

CoreServices -> CloudWatch: "Metrics"
APIGateway -> XRay: "Traces"
CloudWatch -> PagerDuty: "Alerts"

SecretsManager > CoreServices: "Credentials"
KMS > PrimaryAurora: "Encrypt"
KMS > S3Storage: "Encrypt"

PrimaryAurora -> AuroraReplica: "Sync Replication"
S3Storage -> BackupStorage: "Cross-Region"
Route53 -> DRRegion: "Failover"

BillingService > PaymentGateway: "Charge"
AppointmentService > SMSGateway: "Reminder"

// ============================================
// ARCHITECTURE GUIDE (BOTTOM GRID)
// ============================================
ArchitectureGuide [label: "Architecture Reference Guide", color: #F8F9FA] {
  
  Group1 [label: "Access & Security", color: transparent] {
    ClientsDescription [shape: note, color: #E8F4F8, label: "Multi-platform access enables healthcare professionals and patients to access the system from any device, improving accessibility and adoption rates.\n\nSLA: Under 2s page load, Under 200ms response", textSize: medium]
    EdgeDescription [shape: note, color: #E8F5E9, label: "EDGE & PERFORMANCE:\n- CloudFront reduces latency via geographic caching\n- Route 53 provides DNS with health checks & failover\n- AWS Shield protects against DDoS attacks\n\nTarget: Over 85% cache hit, 99.99% availability", textSize: medium]
    SecurityDescription [shape: note, color: #FFEBEE, label: "MULTI-LAYER SECURITY:\n- WAF: Blocks OWASP Top 10 attacks (SQL injection, XSS)\n- Cognito: OAuth 2.0/SAML with MFA support\n- API Gateway: Request validation & routing\n- Rate Limiter: 1000 req/min per user\n\nStandard: HIPAA compliant with audit trails", textSize: medium]
    SecuritySvcDescription [shape: note, color: #FFEBEE, label: "CREDENTIAL & KEY MANAGEMENT:\n- Secrets Manager: Auto-rotated credentials (24h cycle)\n- KMS: AES-256 encryption, key audit trail\n- VPN/Direct Connect: Secure provider access\n\nEncryption: AES-256 at rest, TLS 1.3 in transit", textSize: medium]
  }

  Group2 [label: "Core & Integration", color: transparent] {
    CoreDescription [shape: note, color: #F3E5F5, label: "SCALABLE MICROSERVICES:\n- Independent services with ASG (Min 3, Max 20 instances)\n- Multi-AZ deployment for high availability\n- Each service optimized for its domain\n- Connection pooling (100 max per service)\n\nPerformance: P99 Under 200ms, handles 10,000+ concurrent users", textSize: medium]
    IntegrationDescription [shape: note, color: #FFFDE7, label: "SEAMLESS INTEROPERABILITY:\n- HL7/FHIR Adapter: Transforms legacy HL7 v2 to modern FHIR\n- Message Queue: Async processing with 3x retry mechanism\n- Schema Registry: Validates data quality before ingestion\n- ETL Pipeline: Normalizes data from multiple hospital systems\n\nStandard: HL7 v2/v3, FHIR, EDI/X12 compatible", textSize: medium]
    AIDescription [shape: note, color: #FFE0B2, label: "CLINICAL INTELLIGENCE:\n- Monthly retraining on de-identified patient data\n- Real-time inference for clinical decision support\n- A/B testing: 10% canary deployment before full rollout\n- Auto rollback if accuracy drops Over 2%\n\nAccuracy: Over 95%, Inference latency: Under 100ms", textSize: medium]
  }

  Group3 [label: "Data & Features", color: transparent] {
    StorageDescription [shape: note, color: #E8F5E9, label: "3-TIER CACHING STRATEGY:\n- Redis (HOT): Session data, TTL 24h, Over 85% hit ratio\n- Aurora (WARM): Active patient records, Multi-AZ, daily snapshots\n- S3 (COLD): Documents/images with versioning & encryption\n- Glacier (ARCHIVE): 90-day lifecycle, 6+ year retention (HIPAA)\n\nOptimization: 90% cost reduction via tiering", textSize: medium]
    TelemedicineDescription [shape: note, color: #E0F2F1, label: "ROBUST TELEMEDICINE:\n- WebRTC: Real-time video with sub-100ms latency\n- TURN/STUN: NAT traversal for corporate networks\n- Recording: Auto-transcription for accessibility & compliance\n- Quality Monitor: Adaptive bitrate for poor connections\n\nCodecs: H.264/Opus, supports 1000+ concurrent sessions", textSize: medium]
    ExternalDescription [shape: note, color: #F5F5F5, label: "SYSTEM INTEGRATIONS:\n- Legacy Systems: HL7 v2 for LIS/PACS connectivity\n- Payment Gateway: PCI-DSS compliant, tokenized payments\n- SMS Gateway: 24h appointment reminders (99.9% delivery)\n- Email Service: Report distribution, notifications\n\nStandard: EDI/X12, PCI compliance, HIPAA audit", textSize: medium]
  }

  Group4 [label: "Operations & Rules", color: transparent] {
    MonitoringDescription [shape: note, color: #F3E5F5, label: "COMPREHENSIVE VISIBILITY:\n- CloudWatch: 1000s metrics/min, real-time dashboards\n- X-Ray: Distributed tracing for performance analysis\n- Audit Logs: All user actions (6+ year retention)\n- PagerDuty: Critical alerts with on-call support\n\nMTTR (Mean Time To Recovery): Under 30 minutes", textSize: medium]
    DRDescription [shape: note, color: #F5F5F5, label: "CROSS-REGION DISASTER RECOVERY:\n- Aurora Replica: Synchronous replication to us-west-2\n- Cache Replica: Multi-AZ failover capability\n- Backup Storage: Cross-region S3 versioning\n- Route 53: Health check-based automatic failover\n\nRTO: 5 min | RPO: Under 1 min", textSize: medium]
    PerformancePanel [shape: note, color: #FFF9C4, label: "SLA TARGETS:\n- Availability: 99.99%\n- P99 Latency: Under 200ms\n- Error Rate: Under 0.1%\n- Throughput: 50k req/sec\n- Cache Hit: Over 85%\n- Concurrent Users: 10,000+\n\nCOST: $11,600/month (36% optimized with Reserved Instances)", textSize: medium]
    CompliancePanel [shape: note, color: #C8E6C9, label: "COMPLIANCE FRAMEWORK:\n- HIPAA compliant architecture\n- FHIR & HL7 standards\n- OAuth 2.0 / SAML 2.0 auth\n- AES-256 encryption\n- 6+ year audit retention\n- BAA with AWS\n- Automated threat detection", textSize: medium]
  }
}
