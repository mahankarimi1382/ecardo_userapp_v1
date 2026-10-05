# ECardo International Travel & Commerce Platform Architecture

## 🏗️ Vision Statement
A production-grade, international-grade Travel & Commerce Super-Platform integrating booking services, financial instruments, marketplace commerce, and enterprise operations into a unified ecosystem.

---

## 1. High-Level System Overview

### 1.1 Core Platforms
```text
┌─────────────────────────────────────────────────────────────────────┐
│                    ECardo Unified Platform Stack                   │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   ┌──────────────────┐    ┌──────────────────┐    ┌──────────────┐ │
│   │ User Mobile App  │    │  Web Admin Panel │    │ Backend APIs │ │
│   │  (Flutter/Dart)  │◄──►│   (Laravel/PHP)  │◄──►│  (Laravel)   │ │
│   └────────┬─────────┘    └────────┬─────────┘    └──────┬───────┘ │
│            │                       │                      │         │
│            ▼                       ▼                      ▼         │
│   ┌──────────────────────────────────────────────────────────────┐ │
│   │           Shared Infrastructure Layer                        │ │
│   │  • Authentication & KYC   • Notification Engine              │ │
│   │  • Payment Gateway        • Document Generation             │ │
│   │  • Wallet Management      • PDF/Voucher Generation          │ │
│   └──────────────────────────────────────────────────────────────┘ │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 2. Domain Decomposition

### 2.1 Travel Services Domain
```text
Travel Services
├── Flights (International + Domestic)
│   ├── Search & Booking
│   ├── Seat Selection
│   ├── Baggage Management
│   └── Check-in & Boarding Pass
├── Hotels & Accommodation
│   ├── Global Hotel Catalog
│   ├── Room Selection
│   ├── Amenities & Preferences
│   └── Cancellation & Refunds
├── Tours & Experiences
│   ├── Guided Tours
│   ├── Local Experiences
│   ├── Activity Bookings
│   └── Group/Corporate Packages
├── Car Rental
│   ├── Vehicle Selection
│   ├── Insurance Options
│   ├── Pickup/Drop-off
│   └── Deposit Management
├── Transfer Services
│   ├── Airport Transfers
│   ├── City Transport
│   └── Multi-stop Journeys
├── Visa Services
│   ├── Visa Application Processing
│   ├── Embassy Coordination
│   ├── Document Management
│   └── Status Tracking
├── Travel Insurance
│   ├── Policy Selection
│   ├── Claim Management
│   └── Emergency Support
└── Specialized Services
    ├── Airport Lounges (CIP)
    ├── eSIM/Data Packages
    ├── Travel Gear Sales
    └── Corporate Travel Mgmt
```

### 2.2 Finance Services Domain
```text
Finance Services
├── Wallet Management
│   ├── Multi-currency Wallets
│   ├── Balance Management
│   ├── Transaction History
│   └── Cross-border Transfers
├── Exchange Services
│   ├── Currency Exchange
│   ├── Crypto-to-Fiat
│   └── Real-time Rates
├── Remittance
│   ├── International Transfers
│   ├── Cash Pickup
│   └── Bank Deposits
├── Bill Payment
│   ├── Utilities
│   ├── Government Fees
│   └── Private Bills
└── Cards & Payments
    ├── Virtual Card Issuing
    ├── Physical Card Orders
    └── Contactless Payments
```

### 2.3 Commerce Domain
```text
Commerce Services
├── Stock Trading
│   ├── International Markets
│   ├── Order Execution
│   ├── Portfolio Management
│   └── Market Analytics
├── License Key Sales
│   ├── Software Licenses
│   ├── Renewal Management
│   └── Dispute Resolution
├── Financial Instruments
│   ├── Guarantees (Bank Guarantee/LC)
│   ├── Escrow Services
│   └── Syndicated Products
├── Marketplace
│   ├── P2P Trading
│   ├── Vendor Listings
│   └── Commission Management
└── Loans & Financing
    ├── Personal Loans
    ├── Business Financing
    └── Collateral Management
```

### 2.4 Operations & Support Domain
```text
Operations & Support
├── Customer Support
│   │   Ticket Management
│   ├── Live Chat Integration
│   ├── Call Center Integration
│   └── Escalation Workflows
├── CRM & Analytics
│   ├── Customer 360 View
│   ├── Behavioral Analytics
│   └── Marketing Automation
├── Content Management
│   ├── Landing Pages
│   ├── Blog CMS
│   ├── SEO Management
│   └── A/B Testing
└── ERP & Compliance
    ├── Booking Management
    ├── Supplier/Provider Relations
    ├── Tax & Accounting
    ├── Audit Logging
    └── Regulatory Compliance
```

---

## 3. Technology Stack

### 3.1 Frontend Stack
| Component | Technology | Version | Purpose |
|-----------|------------|---------|---------|
| Mobile App | Flutter/Dart | 3.44.6 | iOS/Android cross-platform |
| Web Admin | Laravel Blade + Vue.js | 11.x | Responsive admin panel |
| Design System | Custom + Material 3 | N/A | Unified visual language |

### 3.2 Backend Stack
| Component | Technology | Version | Purpose |
|-----------|------------|---------|---------|
| Main API | Laravel PHP | 11.x | RESTful API layer |
| Travel Engine | Laravel + MySQL | 10.6 | Travel service orchestration |
| Cache | Redis | 7.x | Session/cache layer |
| Queue | Database + Supervisor | N/A | Async job processing |

### 3.3 Infrastructure
| Component | Technology | Purpose |
|-----------|------------|---------|
| Hosting | AlmaLinux VPS | Primary infrastructure |
| Web Server | Nginx | Reverse proxy |
| Database | MariaDB | Primary data storage |
| File Storage | Local + CDN | Media assets |
| Monitoring | Built-in logging | Application monitoring |

---

## 4. Data Architecture

### 4.1 Primary Databases
```text
Database Division:
├── ecardoq192.db      // Main operational database
│   ├── User accounts, KYC, wallets
│   ├── Transactions, payments, orders
│   ├── CRM & support tickets
│   └── ERP & administrative data
│
├── travel-origin.db   // Travel service database
│   ├── Flight/hotel/tour catalogs
│   ├── Provider integrations
│   ├── Travel bookings & vouchers
│   └── Travel-specific analytics
│
└── trip.ecardo.ir     // Secondary travel instance
    └── Redundant/travel domain hosting
```

### 4.2 Entity Relationship Highlights
```text
Core Entities:
User ──┬── Wallet ──┬── Transaction
       │            └── Payment
       │
       ├── KYC Record
       │
       ├── Support Tickets
       │
       └── Bookings ──┬── Flight Booking
                      ├── Hotel Booking
                      ├── Tour Booking
                      └── Service Booking (Car/Rental/etc.)
```

---

## 5. Security Architecture

### 5.1 Authentication & Authorization
```text
Auth Flow:
User ──► Login/KYC ──► JWT Token ──► Rate-Limited API Access

Authorization Layers:
├── Role-Based Access Control (RBAC)
│   ├── User Roles: Standard, Verified, Premium
│   ├── Agent Roles: Basic, Advanced, Manager
│   └── Admin Roles: User, Super Admin
│
├── Feature Permissions
│   ├── Trading permissions (Stock licenses)
│   ├── High-value transaction limits
│   └── Geographic restrictions
│
└── Data Segregation
    ├── Customer data isolation
    ├── Supplier data segregation
    └── Audit trail enforcement
```

### 5.2 Payment Security
- PCI-DSS compliant payment gateway integration
- End-to-end encryption for sensitive transactions
- Dual-authentication for high-value transfers
- Fraud detection algorithms
- Transaction velocity checks

---

## 6. Scalability Strategy

### 6.1 Horizontal Scaling Plan
```text
Phase 1 (Current): Single server stack
├── Shared resources
└── Vertical scaling focus

Phase 2 (Growth): Service separation
├── API layer → Dedicated servers
├── Database → Read replicas
└── Cache cluster expansion

Phase 3 (Scale): Microservices transition
├── Travel services → Independent cluster
├── Finance services → Isolated security zone
└── User-facing API → Load-balanced pool
```

### 6.2 Performance Targets
| Metric | Target | Current | Status |
|--------|--------|---------|--------|
| Page Load Time | <2s | ~3.5s | ⚠️ Needs optimization |
| API Response Time | <500ms | ~800ms | ⚠️ Needs optimization |
| Concurrent Users | 10k+ | TBD | 🔲 To measure |
| Uptime | 99.9% | TBD | 🔲 To establish baseline |

---

## 7. API Contract Standards

### 7.1 REST API Conventions
```yaml
Versioning: /api/v1/{resource}
Naming: Snake case for endpoints (e.g., /api/v1/bookings)
Response Format:
  {
    "status": "success" | "error",
    "data": { ... },
    "meta": { pagination, timestamps }
  }
Error Format:
  {
    "status": "error",
    "message": "Human readable error",
    "code": "ERROR_CODE",
    "details": { ... }
  }
```

### 7.2 Rate Limiting & Throttling
- Public endpoints: 100 req/min
- Authenticated users: 500 req/min
- Premium tier: 2000 req/min
- API keys: Configurable per client

---

## 8. Deployment Pipeline

```text
Development Workflow:
Developer ──► Feature Branch ──► PR Review ──► CI Build ──► Merge to Main

CI Pipeline Steps:
├── Static Analysis (flutter analyze)
├── Unit Tests (>90% coverage)
├── Integration Tests
├── E2E Critical Paths
├── Security Scan
├── Docker Build (backend)
└── Artifact Upload

Deployment Strategy:
├── Staging Environment (feature validation)
├── Production Deploy (blue-green strategy)
├── Rollback Procedure (automatic on health check failure)
└── Post-deployment Verification Suite
```

---

## 9. Documentation Structure

```text/docs
├── MASTER_ARCHITECTURE.md        // This document
├── DOMAIN_INVENTORY.md           // Full domain/module inventory
├── SERVICE_SPECS/                // Per-service specifications
│   ├── FLIGHTS_SERVICE.md
│   ├── HOTELS_SERVICE.md
│   ├── TOURS_SERVICE.md
│   ├── STOCK_TRADING.md
│   ├── LICENSE_SALES.md
│   └── ...
├── IMPLEMENTATION_ROADMAP.md     // Phased implementation plan
├── TESTING_STRATEGY.md           // Test coverage requirements
└── DEPLOYMENT_GUIDE.md           // Production deployment procedures
```

---

## 10. Success Metrics & KPIs

### 10.1 Platform Health Metrics
- **Service Availability**: >99.9% uptime
- **API Error Rate**: <1% of requests
- **Customer Satisfaction**: NPS >50
- **Booking Conversion**: >3% from search to confirmation
- **Support Ticket Resolution**: <24h median resolution time

### 10.2 Business Metrics
- **Monthly Active Users**: Growth trajectory targets
- **Transaction Volume**: Monthly growth targets
- **Average Order Value**: Track by service category
- **Repeat Booking Rate**: >40% target retention
- **Cross-sell Rate**: >25% across service categories

---

## 11. Next Steps

1. ✅ **Phase 1 Complete**: CI pipeline fixes applied
2. 🔲 **Phase 2**: Domain inventory creation in progress
3. 🔲 **Phase 3**: First service rebuild (Local Experiences recommended)
4. 🔲 **Phase 4**: Integration testing between rebuilt services
5. 🔲 **Phase 5**: Production deployment with monitoring

---

**Document Version**: 1.0.0  
**Last Updated**: October 2026  
**Owner**: Platform Architecture Team  
**Status**: Approved for Implementation Phase
