<div align="center">

# 🚀 EmbedCraft

### Enterprise-Grade In-App Engagement & Campaign Orchestration Platform

[![Backend](https://img.shields.io/badge/Backend-Node.js%20%2F%20Express%205-339933?logo=node.js&logoColor=white)](#backend-api-server)
[![Dashboard](https://img.shields.io/badge/Dashboard-React%20%2B%20TypeScript-61DAFB?logo=react&logoColor=black)](#dashboard-panel)
[![SDK](https://img.shields.io/badge/SDK-Flutter%20%2F%20Dart-02569B?logo=flutter&logoColor=white)](#flutter-sdk-in_app_ninja)
[![Infrastructure](https://img.shields.io/badge/Infra-AWS%20%2B%20Terraform-FF9900?logo=amazonaws&logoColor=white)](#aws-production-infrastructure)
[![CI/CD](https://img.shields.io/badge/CI%2FCD-GitHub%20Actions-2088FF?logo=githubactions&logoColor=white)](#cicd-pipeline)

**EmbedCraft** is a full-stack, multi-tenant SaaS platform that enables product teams to design, deploy, and measure **in-app nudges, campaigns, gamification widgets, and user engagement experiences** inside their mobile applications — all controlled from a powerful no-code dashboard, delivered through a zero-code Flutter SDK, and deployed on a production-grade AWS infrastructure provisioned entirely with Terraform.

</div>

---

## 📑 Table of Contents

1. [Quick Start — Running the Dashboard](#-quick-start--running-the-dashboard)
2. [Repository Map — Full Monorepo Layout](#-repository-map--full-monorepo-layout)
3. [Architecture Overview](#-architecture-overview)
4. [Backend API Server](#-backend-api-server)
   - [Entry Point & Server Bootstrap](#entry-point--server-bootstrap)
   - [API Routes & Controllers](#api-routes--controllers)
   - [Mongoose Data Models](#mongoose-data-models)
   - [Middleware Layer](#middleware-layer)
   - [Services Layer](#services-layer)
   - [Utility Modules](#utility-modules)
   - [Environment Variables](#environment-variables)
   - [Docker Container](#docker-container)
   - [Database Seeding & Debug Scripts](#database-seeding--debug-scripts)
5. [Dashboard Panel](#-dashboard-panel)
   - [Tech Stack & Dependencies](#dashboard-tech-stack--dependencies)
   - [Application Routing](#dashboard-application-routing)
   - [Pages & Features](#dashboard-pages--features)
   - [Component Architecture](#dashboard-component-architecture)
   - [State Management](#dashboard-state-management)
   - [Context Providers](#dashboard-context-providers)
6. [Flutter SDK — `in_app_ninja`](#-flutter-sdk--in_app_ninja)
   - [SDK Capabilities](#sdk-capabilities)
   - [Exported Modules](#exported-modules)
   - [SDK Models](#sdk-models)
   - [Renderers & UI Engines](#renderers--ui-engines)
   - [Integration Guide](#sdk-integration-guide)
7. [Documentation Portal — `EmbedDoc`](#-documentation-portal--embeddoc)
8. [Landing Page — `embedcraft-ui-main`](#-landing-page--embedcraft-ui-main)
9. [Test App](#-test-app)
10. [NudgeCore V2 (Legacy Reference SDK)](#-nudgecore-v2-legacy-reference-sdk)
11. [AWS Production Infrastructure](#-aws-production-infrastructure)
    - [Credentials, Endpoints & Identifiers Directory](#1-credentials-endpoints--identifiers-directory)
    - [Infrastructure Architecture & Network Flow](#2-infrastructure-architecture--network-flow)
    - [DevOps & CI/CD Pipelines](#3-devops--cicd-pipelines)
    - [Multi-Tenant Connections & Queue Processing](#4-multi-tenant-connections--queue-processing)
12. [Terraform — Infrastructure as Code](#-terraform--infrastructure-as-code)
    - [Terraform File Reference](#terraform-file-reference)
    - [VPC & Network Topology](#vpc--network-topology)
    - [ECS Fargate Compute](#ecs-fargate-compute)
    - [Auto-Scaling Policies](#auto-scaling-policies)
    - [SQS Event Queue](#sqs-event-queue)
    - [ElastiCache Redis](#elasticache-redis)
    - [ALB & HTTPS](#alb--https)
    - [IAM Roles & Policies](#iam-roles--policies)
    - [Secrets Manager](#secrets-manager)
    - [MongoDB Atlas VPC Peering](#mongodb-atlas-vpc-peering)
    - [Route 53 DNS](#route-53-dns)
    - [S3 & CloudFront CDN](#s3--cloudfront-cdn)
13. [CI/CD Pipeline](#-cicd-pipeline)
14. [DevOps Scripts](#-devops-scripts)
15. [Event Tracking System](#-event-tracking-system)
16. [Kubernetes Migration Blueprint](#-kubernetes-migration-blueprint)
17. [Running Locally — Development Setup](#-running-locally--development-setup)
18. [License](#-license)

---

## 🏁 Quick Start — Running the Dashboard

To run the dashboard, use the following login details:

| Field    | Value              |
|----------|--------------------|
| **Email**    | `big@mail.com`     |
| **Password** | `Au20052005`       |

> [!NOTE]
> The `big@gmail.com` account is linked with the **Test App**. You can link it with any app by following the documentation at `https://docs.embedcraft.com`.

### Steps

```bash
# 1. Start the backend (API server)
cd backend
npm install
npm run dev          # Starts on http://localhost:4000

# 2. Start the dashboard
cd dashboard
npm install
npm run dev          # Starts on http://localhost:5173

# 3. Login at http://localhost:5173/login with the credentials above
```

---

## 🗂 Repository Map — Full Monorepo Layout

```
EmbedCraft/
├── .github/
│   └── workflows/
│       └── aws-deploy.yml              # GitHub Actions → ECR push pipeline
│
├── backend/                            # 🟢 Node.js API Server (Express 5)
│   ├── index.js                        # Server entry point
│   ├── Dockerfile                      # Production Docker image (node:20-slim)
│   ├── .env.example                    # Environment variable template
│   ├── package.json                    # Dependencies & scripts
│   ├── seed_templates.js               # System template seeder
│   ├── src/
│   │   ├── controllers/                # 19 route controllers
│   │   │   ├── adminController.js      # Super-admin org management
│   │   │   ├── analyticsController.js  # Dashboard analytics & aggregations
│   │   │   ├── assetController.js      # S3 media asset management
│   │   │   ├── authController.js       # Login, register, JWT issuance
│   │   │   ├── campaignController.js   # Campaign CRUD & lifecycle
│   │   │   ├── challengeController.js  # Gamification challenge engine
│   │   │   ├── dataSourceController.js # External data source registry
│   │   │   ├── flowController.js       # Automation flow builder
│   │   │   ├── gameController.js       # Spin wheel, scratch card, quiz games
│   │   │   ├── metadataController.js   # Event & property schema registry
│   │   │   ├── nudgeController.js      # Core nudge engine (93KB — largest)
│   │   │   ├── organizationController.js # Org settings & config
│   │   │   ├── pageController.js       # In-app page builder
│   │   │   ├── rewardController.js     # Reward vault & redemption
│   │   │   ├── segmentController.js    # User segmentation
│   │   │   ├── supportController.js    # Contact form (Nodemailer)
│   │   │   ├── teamController.js       # Team member management
│   │   │   └── templateController.js   # Campaign template library
│   │   ├── middleware/
│   │   │   ├── authMiddleware.js        # Dual-strategy auth (API Key + JWT)
│   │   │   └── templateController.js    # Template middleware helpers
│   │   ├── models/                      # 16 Mongoose schemas
│   │   │   ├── Asset.js                 # Media assets (images, Lottie, Rive)
│   │   │   ├── DataSource.js            # External API data sources
│   │   │   ├── EndUser.js               # SDK end-user profiles
│   │   │   ├── Event.js                 # Custom event definitions
│   │   │   ├── EventLog.js              # Raw event log entries
│   │   │   ├── Flow.js                  # Automation flow definitions
│   │   │   ├── Lead.js                  # Referral leads
│   │   │   ├── Nudge.js                 # Campaign/nudge configurations
│   │   │   ├── Organization.js          # Tenant org (multi-tenant root)
│   │   │   ├── Page.js                  # In-app page schemas
│   │   │   ├── Property.js              # User/event property definitions
│   │   │   ├── Reward.js                # Gamification reward definitions
│   │   │   ├── Segment.js               # User segments
│   │   │   ├── Template.js              # Reusable campaign templates
│   │   │   ├── User.js                  # Dashboard admin users
│   │   │   └── UserLedger.js            # Reward transaction ledger
│   │   ├── routes/                      # 16 Express route files
│   │   ├── services/
│   │   │   ├── cacheService.js          # Redis cache (stampede protection)
│   │   │   ├── sqsService.js            # SQS event enqueue client
│   │   │   ├── sqsWorker.js             # SQS batch consumer worker
│   │   │   ├── tenantConnectionManager.js # Multi-tenant DB context switcher
│   │   │   └── dataMigrationService.js  # Cross-cluster tenant data migration
│   │   └── utils/
│   │       └── crypto.js                # AES-256-CBC encryption utility
│   └── scripts/                         # Operational helper scripts
│
├── dashboard/                           # 🔵 React + TypeScript Dashboard
│   ├── src/
│   │   ├── App.tsx                      # Root router with auth guards
│   │   ├── main.tsx                     # Vite entry point
│   │   ├── pages/                       # 22 page components + admin/
│   │   ├── components/                  # Renderers, editors, UI primitives
│   │   ├── context/                     # AuthContext, EnvironmentContext
│   │   ├── store/                       # Zustand stores (editor, global)
│   │   ├── services/                    # API service layer
│   │   ├── hooks/                       # Custom React hooks
│   │   └── layouts/                     # Admin & App layout shells
│   ├── package.json                     # 65+ dependencies
│   └── vite.config.ts                   # Vite build configuration
│
├── in_app_ninja/                        # 📱 Flutter SDK Package
│   ├── pubspec.yaml                     # SDK metadata & dependencies
│   └── lib/
│       ├── in_app_ninja.dart            # Library barrel exports
│       └── src/
│           ├── app_ninja.dart           # Core SDK class (107KB singleton)
│           ├── controllers/             # SDK business logic controllers
│           ├── data/                    # Local persistence & network
│           ├── engine/                  # Campaign matching engine
│           ├── models/                  # 9 data model classes
│           ├── observers/               # Route & widget tracking observers
│           ├── renderers/               # Campaign rendering engine
│           │   ├── campaign_renderer.dart
│           │   ├── challenge_renderer.dart
│           │   ├── nudge_renderers/     # 7 nudge type renderers
│           │   └── layers/              # Compositing layers
│           ├── utilities/               # Helper utilities
│           ├── utils/                   # Common utils
│           ├── widgets/                 # 9 embeddable widgets
│           └── callbacks/               # Event callback system
│
├── EmbedDoc/                            # 📖 Documentation Portal (React)
│   ├── src/
│   │   ├── App.tsx                      # Auth-gated docs router
│   │   └── pages/docs/                  # Individual documentation pages
│   └── package.json                     # Vite + React + ShadcnUI
│
├── embedcraft-ui-main/                  # 🌐 Marketing Landing Page
│   ├── src/
│   │   ├── router.tsx                   # TanStack Router config
│   │   └── routes/index.tsx             # Landing page (87KB)
│   └── package.json                     # React 19 + TanStack Start
│
├── test_app/                            # 🧪 Flutter Demo App
│   ├── lib/main.dart                    # Test app with SDK integration
│   └── pubspec.yaml                     # References in_app_ninja locally
│
├── nudgecore_v2-8.0.3/                  # 📦 Legacy SDK Reference (NudgeNow)
│   ├── pubspec.yaml                     # Flutter plugin (Android, iOS, Windows)
│   └── lib/                             # Legacy renderer implementation
│
├── terraform/                           # ☁️ AWS Infrastructure as Code
│   ├── main.tf                          # Provider config (ap-south-1 + us-east-1)
│   ├── variables.tf                     # Input variable definitions
│   ├── terraform.tfvars                 # Production variable values
│   ├── vpc.tf                           # VPC, subnets, NAT, IGW
│   ├── security_groups.tf               # ALB, ECS, Redis security groups
│   ├── alb.tf                           # Application Load Balancer + HTTPS
│   ├── ecs.tf                           # ECS Fargate tasks + auto-scaling
│   ├── ecr.tf                           # Docker image repositories
│   ├── elasticache.tf                   # Redis Serverless cache
│   ├── sqs.tf                           # Event queue + DLQ
│   ├── s3_cloudfront.tf                 # Asset storage + CDN
│   ├── dashboard.tf                     # Dashboard S3 + CloudFront
│   ├── landing_and_docs.tf              # Landing & Docs S3 + CloudFront
│   ├── route53.tf                       # DNS records
│   ├── ssl.tf                           # ACM SSL certificates
│   ├── iam.tf                           # IAM roles & policies
│   ├── secrets.tf                       # Secrets Manager
│   ├── mongodb_peering.tf               # VPC Peering with MongoDB Atlas
│   ├── codebuild.tf                     # AWS CodeBuild (optional)
│   ├── eventbridge.tf                   # EventBridge rules
│   └── outputs.tf                       # Terraform outputs
│
├── devops_architecture_and_credentials.md  # Production infrastructure reference
├── detailed_k8s_docker_architecture.md     # Kubernetes migration blueprint
├── integration_guide.md                    # SDK integration documentation
├── aws_setup_guide.md                      # AWS first-time setup guide
├── build_in_cloud.ps1                      # PowerShell ECR build script
├── migrate_aws.ps1                         # AWS account migration script
├── destroy_old_aws.ps1                     # Old infra teardown script
├── run_ec2_builder.ps1                     # EC2 builder provisioning
└── extract_info.py                         # Utility data extraction script
```

---

## 🏛 Architecture Overview

EmbedCraft follows a **decoupled, event-driven, multi-tenant microservices architecture** deployed on AWS:

```mermaid
graph TD
    %% Clients
    User([End User / Flutter SDK]) -->|Track Event / HTTPS| Route53{AWS Route 53}
    DashboardAdmin([Dashboard Admin / React]) -->|Manage / HTTPS| Route53

    %% DNS Routing
    Route53 -->|api.embedcraft.com| ALB[Application Load Balancer]
    Route53 -->|dashboard.embedcraft.com| CloudFrontFront[CloudFront Dashboard CDN]

    %% Frontends & Static Assets
    CloudFrontFront -->|Fetch Assets| S3Dashboard[(S3 Dashboard Bucket)]

    %% ALB Forwarding
    ALB -->|Proxy Route /api/*| ECSApi[ECS Fargate Tasks: API Server]

    %% ECS Tasks Interactions
    ECSApi -->|Async Cache-Aside| RedisServerless[(ElastiCache Serverless Redis)]
    ECSApi -->|Immediate 202 response| SQSQueue[(AWS SQS Event Queue)]
    ECSApi -->|Verify API Key / Auth| MongoDb[(MongoDB Atlas Cluster)]

    %% SQS Workers Ingest Flow
    SQSWorker[ECS Fargate Tasks: SQS Worker] -->|Long Poll 20s| SQSQueue
    SQSWorker -->|Tenant Switch runWithTenantContext| MongoDb
```

### Key Design Principles

| Principle | Implementation |
|-----------|---------------|
| **Multi-Tenancy** | Database-per-tenant isolation via `mongoose.connection.useDb()` with enterprise dedicated cluster support |
| **Event-Driven Ingestion** | SDK events → SQS queue → batch worker → MongoDB (sub-50ms API response) |
| **Cache-Aside with Stampede Protection** | Redis SETNX mutex prevents thundering herd on cache miss |
| **Zero-Downtime Deploys** | ECS rolling updates (min 100%, max 200% healthy) |
| **Infrastructure as Code** | 100% of AWS resources provisioned via Terraform |
| **Dual Auth Strategy** | API Key (SDK clients) + JWT Bearer (dashboard admins) |
| **Graceful Degradation** | Redis offline → bypass cache; SQS offline → direct DB writes |

---

## 🟢 Backend API Server

### Entry Point & Server Bootstrap

**File:** [`index.js`](backend/index.js)

The backend is a **Node.js Express 5** application running on port `4000`. The entry point:

1. **Loads environment** — In development, uses `dotenv`; in production (ECS Fargate), env vars come from AWS Secrets Manager via Task Definition injection.
2. **Configures middleware** — `helmet` (security headers), `cors`, JSON body parser (50MB limit for Lottie JSON), static file serving for `/uploads`.
3. **Disables caching** for admin/dashboard API routes (prevents stale data in dashboard).
4. **Registers health check** at `GET /health` — reports MongoDB, Redis, and SQS status. Used by ALB Target Group health checks every 30 seconds.
5. **Mounts 16 route groups** across `/api/*` and `/v1/*` namespaces.
6. **S3 Proxy SPA layer** — A catch-all middleware that proxies unmatched GET requests to S3 buckets based on the `Host` header (`dashboard.*` → dashboard bucket, `docs.*` → docs bucket, default → landing page bucket). This enables React SPA client-side routing without CloudFront.
7. **MongoDB connection** with production-grade pooling (min 10, max 100 connections, zlib compression, IPv4 only, 1-minute idle timeout).
8. **Graceful shutdown** — SIGTERM/SIGINT handlers close HTTP server, Redis, and MongoDB connections cleanly (required for ECS container lifecycle).

### API Routes & Controllers

The backend exposes **16 route groups** mapped to **19 controllers**:

| Route Prefix | Controller | Purpose |
|---|---|---|
| `POST /api/auth/*` | `authController.js` | User registration, login, JWT token issuance |
| `GET/POST /api/admin/*` | `adminController.js` | Super-admin: list orgs, create orgs, global stats |
| `GET/POST /v1/admin/campaigns/*` | `campaignController.js` | Campaign CRUD, activation, scheduling |
| `GET/POST /v1/admin/metadata/*` | `metadataController.js` | Event & property schema definition registry |
| `GET/POST /v1/admin/datasources/*` | `dataSourceController.js` | External data source configuration |
| `GET/POST /v1/admin/rewards/*` | `rewardController.js` | Reward vault management & redemption tracking |
| `GET /v1/admin/analytics/*` | `analyticsController.js` | Dashboard analytics aggregation pipelines |
| `GET/POST /v1/admin/assets/*` | `assetController.js` | S3 media upload, CDN URL generation |
| `GET/POST /v1/admin/team/*` | `teamController.js` | Team member invite, role management |
| `GET/PUT /v1/admin/organization/*` | `organizationController.js` | Org settings (API keys, branding, contracts) |
| `GET/POST /v1/admin/segments/*` | `segmentController.js` | User segmentation rule builder |
| `GET/POST /v1/admin/flows/*` | `flowController.js` | Automation flow definitions |
| `GET/POST /v1/admin/templates/*` | `templateController.js` | Reusable campaign template library |
| `GET/POST /api/pages/*` | `pageController.js` | In-app page builder (HTML/JSON pages) |
| `POST /api/support/*` | `supportController.js` | Contact form submission (Nodemailer/Gmail SMTP) |
| `GET/POST /*` (root) | `nudgeController.js` | **Core SDK API** — fetch campaigns, track events, user identification, game state |

#### `nudgeController.js` — The Heart of the Platform (93KB)

This is the largest and most critical controller. It handles:

- **`GET /v1/fetch`** — SDK campaign fetch endpoint. Resolves user segments, matches active campaigns by screen/event, applies frequency capping, and returns personalized nudge configurations. Uses Redis cache-aside with stampede protection.
- **`POST /v1/track`** — Event ingestion. In production, enqueues to SQS for async batch processing; in development, writes directly to MongoDB.
- **`POST /v1/identify`** — User identification. Creates/updates `EndUser` profiles with custom properties.
- **`POST /v1/game/*`** — Gamification endpoints: spin wheel probability engine, scratch card reveal, quiz scoring, challenge completion tracking.
- **Campaign targeting engine** — Evaluates event-based trigger rules, user segment membership, scheduling windows, frequency caps, and A/B variant assignment.

### Mongoose Data Models

The backend defines **16 Mongoose schemas** for multi-tenant data:

| Model | File | Purpose |
|---|---|---|
| `Organization` | `Organization.js` | Tenant root document. Contains API keys (`api_key`, `staging_api_key`), billing, contracts, and optional `dedicated_mongo_uri` for enterprise tenants. |
| `User` | `User.js` | Dashboard admin users. Stores hashed passwords, org association, role. |
| `Nudge` | `Nudge.js` | Campaign configuration. UI layout (type, layers, styles), trigger rules, scheduling, targeting, frequency caps. |
| `EndUser` | `EndUser.js` | SDK-identified users. Stores external ID, custom properties, last seen, device info. |
| `EventLog` | `EventLog.js` | Raw event log entries. Written by SQS worker in bulk batches. |
| `Event` | `Event.js` | Custom event definitions (schema registry for dashboard). |
| `Property` | `Property.js` | User/event property definitions with type metadata. |
| `Asset` | `Asset.js` | Media assets stored in S3 (images, Lottie animations, Rive files). |
| `Reward` | `Reward.js` | Gamification rewards (coins, coupons, badges) with inventory tracking. |
| `UserLedger` | `UserLedger.js` | Reward transaction ledger (earn/redeem history per user). |
| `Template` | `Template.js` | Reusable campaign templates (system and custom). |
| `Segment` | `Segment.js` | User segments with rule-based definitions. |
| `Flow` | `Flow.js` | Automation flow configurations. |
| `Page` | `Page.js` | In-app page builder schemas (rich content pages). |
| `Lead` | `Lead.js` | Referral lead captures. |
| `DataSource` | `DataSource.js` | External API data source configurations. |

### Middleware Layer

#### `authMiddleware.js` — Dual-Strategy Authentication

The auth middleware supports two authentication strategies in a single pass:

1. **API Key Strategy** (SDK / Public API):
   - Checks `x-api-key` header.
   - Looks up the organization by matching against both `api_key` (production) and `staging_api_key` (staging).
   - Validates contract expiration dates.
   - Determines environment (`staging` vs `production`) from key prefix (`nk_test_*` = staging).
   - Injects `runWithTenantContext()` to switch downstream database context.

2. **JWT Bearer Strategy** (Dashboard / Admin API):
   - Validates `Authorization: Bearer <token>` header.
   - Decodes JWT with `JWT_SECRET` to extract `orgId` and user identity.
   - Fetches organization and validates `is_active` status.
   - Injects tenant database context for all downstream handlers.

3. **Safety guards**: Checks MongoDB connection state before processing (returns `503` if disconnected). Enforces `JWT_SECRET` presence on startup (`process.exit(1)` if missing).

### Services Layer

#### `cacheService.js` — Production-Grade Redis Caching (439 lines)

A comprehensive Redis caching layer implementing industry-standard patterns:

| Pattern | Description |
|---------|-------------|
| **Cache-Aside with TTL** | Standard read-through caching with configurable TTLs (nudge: 5min, org: 10min, user: 2min, segment: 5min) |
| **Cache Stampede Protection** | SETNX mutex lock pattern prevents thundering herd on popular cache key expiry. First request acquires lock, fetches from DB, populates cache; concurrent requests wait and retry cache. |
| **SCAN-Based Invalidation** | Non-blocking cursor-based key scanning (replaces `KEYS *` which blocks Redis) with pipelined batch deletes. |
| **Circuit Breaker (mockMode)** | Automatic fallback to no-cache mode when Redis is unreachable. Self-heals on reconnection. |
| **Structured Logging** | JSON logs in production (CloudWatch Logs Insights), human-readable in dev. |
| **Multi-Provider Support** | Connects via `REDIS_URL` (Redis Cloud, Upstash) or `REDIS_HOST + REDIS_PORT + REDIS_PASSWORD` (ElastiCache). |

**Cache Key Schema:**
```
nudge:{orgId}:{screenName}   → Cached campaign list for SDK fetch
lock:nudge:{orgId}:{screen}  → Stampede mutex (auto-expires 5s)
```

#### `sqsService.js` — SQS Event Enqueue Client

Decoupled event ingestion service for high-scale tracking:

- Initializes SQS client only if `AWS_SQS_QUEUE_URL` is set AND `NODE_ENV === 'production'`.
- `enqueueEvent(payload)` — Sends event to SQS with message attributes (`organization_id`, `event_type`).
- Returns `null` on failure — caller (`nudgeController.trackEvent`) gracefully falls back to direct `EventLog.create()`.
- **Zero-config local dev**: SQS is automatically disabled locally. No AWS credentials needed.

#### `sqsWorker.js` — Batch Event Consumer (358 lines)

A standalone or embedded SQS message consumer process:

1. **Long-polls SQS** (20s wait) for maximum efficiency.
2. **Receives up to 10 messages** per poll (AWS API limit).
3. **Accumulates in buffer** until `BATCH_FLUSH_SIZE` (default: 100) or `BATCH_FLUSH_INTERVAL` (default: 5s).
4. **Groups events by `organization_id` + `environment`** for multi-tenant context switching.
5. **Bulk-writes to MongoDB** using `EventLog.insertMany()` with `ordered: false` for optimal throughput.
6. **Deletes processed messages** in batches of 10 via `DeleteMessageBatchCommand`.
7. **Handles poison messages** — Parse failures are logged to the global database and deleted from queue.
8. **Graceful shutdown** on SIGTERM — flushes remaining buffer before exit.

```bash
# Run standalone:
node src/services/sqsWorker.js

# Or use npm script:
npm run worker:sqs
```

#### `tenantConnectionManager.js` — Multi-Tenant Database Isolation

Implements two tiers of tenant database separation:

| Tier | Mechanism | Connection Strategy |
|------|-----------|-------------------|
| **Standard / Growth** | Shared MongoDB Atlas Cluster | `mongoose.connection.useDb('tenant_<org_id>', { useCache: true })` — logical database switch on shared cluster |
| **Enterprise** | Dedicated MongoDB Cluster | `mongoose.createConnection(org.dedicated_mongo_uri)` — isolated connection pool (max 50, min 5) per org, cached in memory |

Key components:

- **`runWithTenantContext(org, next, req)`** — Wraps downstream Express handlers in `AsyncLocalStorage` with the resolved tenant connection. Supports staging environments (`_stg` suffix).
- **`createTenantModelProxy(Model)`** — JavaScript `Proxy` that intercepts Mongoose model static methods (`find`, `findOne`, `create`) and transparently redirects them to the tenant-scoped model.
- **`getTenantConnection()`** — Retrieves the current request's tenant connection from `AsyncLocalStorage`.

#### `dataMigrationService.js` — Cross-Cluster Tenant Migration

Securely migrates tenant data between shared and dedicated clusters:

- Migrates 11 collection types: nudges, endusers, eventlogs, challenges, rewards, segments, flows, templates, pages, properties, events.
- Skips documents that already exist in the destination (idempotent).
- Properly manages connection lifecycle (opens, migrates, closes).

### Utility Modules

#### `crypto.js` — AES-256-CBC Encryption

- Derives a stable 32-byte key from `JWT_SECRET` using SHA-256.
- `encrypt(text)` — Produces `iv:ciphertext` format.
- `decrypt(text)` — Safely falls back to returning plaintext if the input is not in encrypted format (handles legacy data).

### Environment Variables

**File:** [`backend/.env.example`](backend/.env.example)

```env
PORT=4000
MONGO_URI=mongodb://localhost:27017/nudge_db

# Redis (Local / AWS ElastiCache / Redis Cloud / Upstash)
# Option 1: Full URL (highest priority)
# REDIS_URL=rediss://default:password@host:port
# Option 2: Host + Port + Password
REDIS_HOST=127.0.0.1
REDIS_PORT=6379
REDIS_PASSWORD=
REDIS_TLS=false

# Cache TTLs (seconds)
# CACHE_TTL_NUDGE=300
# CACHE_TTL_ORG=600
# CACHE_TTL_USER=120
# CACHE_TTL_SEGMENT=300

# AWS S3 (Asset Storage)
AWS_REGION=us-east-1
AWS_S3_BUCKET_NAME=
CLOUDFRONT_URL=

# AWS SQS (Event Queue)
AWS_SQS_QUEUE_URL=

# SQS Worker Tuning
# WORKER_BATCH_SIZE=100
# WORKER_FLUSH_INTERVAL_MS=5000

# Gmail SMTP
GMAIL_USER=contactembedcraft@gmail.com
GMAIL_APP_PASSWORD=
```

### Docker Container

**File:** [`backend/Dockerfile`](backend/Dockerfile)

```dockerfile
FROM node:20-slim
ENV NODE_ENV=production
ENV PORT=4000
WORKDIR /usr/src/app
COPY --chown=node:node package*.json ./
RUN npm install --omit=dev
COPY --chown=node:node . .
RUN mkdir -p uploads/pages && chown -R node:node uploads
USER node
EXPOSE 4000
CMD ["node", "index.js"]
```

Key security decisions:
- **Multi-stage ownership** — All files owned by `node` user.
- **Non-root execution** — Container runs as `node` user (not root).
- **Production-only deps** — `--omit=dev` excludes devDependencies.
- **Minimal base image** — `node:20-slim` reduces attack surface.

### Database Seeding & Debug Scripts

The backend includes numerous operational scripts:

| Script | Purpose |
|--------|---------|
| `seed_templates.js` | Seeds system campaign templates via admin REST API |
| `seed_events.js` | Seeds default event definitions |
| `check_db.js` / `check_mongo.js` | Database connectivity verification |
| `check_sqs.js` | SQS queue connectivity check |
| `check_events.js` | Event log inspection |
| `check_assets.js` | S3 asset integrity audit |
| `check_org.js` | Organization data inspection |
| `deploy_static.js` | S3 static file deployment utility |
| `full_sim.js` | Full SDK simulation (tracks, fetches, games) |
| `clean_userledger_duplicates.js` | Deduplication cleanup script |
| `debug_campaign.js` / `debug_nudge.js` | Campaign debugging tools |

---

## 🔵 Dashboard Panel

**Directory:** `dashboard/`

The dashboard is the **no-code administration interface** where product teams design campaigns, analyze user behavior, manage assets, and configure their application.

### Dashboard Tech Stack & Dependencies

| Category | Technology |
|----------|-----------|
| **Framework** | React 18 + TypeScript |
| **Build** | Vite 5 with SWC |
| **Routing** | React Router DOM 6 |
| **State** | Zustand 5 + Immer |
| **Server State** | TanStack React Query 5 |
| **UI Framework** | Radix UI primitives + ShadCN patterns |
| **Styling** | Tailwind CSS 3 + Tailwind Animate |
| **Typography** | Inter, Poppins, Roboto (via @fontsource) |
| **Charts** | Recharts 3 |
| **Animations** | Framer Motion 12, Lottie React, Rive Canvas |
| **Rich Editing** | Monaco Editor (VS Code), Fabric.js canvas, react-color |
| **Drag & Drop** | @hello-pangea/dnd |
| **Forms** | React Hook Form 7 + Zod validation |
| **QR Codes** | qrcode.react |
| **Markdown** | react-markdown |
| **Toasts** | Sonner |
| **HTTP** | Axios |

### Dashboard Application Routing

**File:** [`dashboard/src/App.tsx`](dashboard/src/App.tsx)

```
/login                          → Login page (public)
/                               → Dashboard home (protected)
/campaigns                      → Campaign list
/campaigns/new                  → Create new campaign
/campaigns/:id/report           → Campaign performance report
/campaign-builder               → Visual campaign builder
/flows                          → Automation flows
/segments                       → User segments
/analytics                      → Analytics dashboard
/events                         → Event definitions & logs
/users                          → User directory
/users/:id                      → Individual user profile
/rewards                        → Reward vault
/pages                          → In-app page builder
/apis                           → API documentation & SDK setup
/settings                       → Organization settings
/assets                         → Media asset library
/templates                      → Campaign template gallery
/support                        → Support contact form
/admin                          → Super admin panel (hidden)
/admin/stats                    → Global platform statistics
```

### Dashboard Pages & Features

| Page | File | Size | Functionality |
|------|------|------|--------------|
| **Login** | `Login.tsx` | 42KB | Multi-step auth flow with animations |
| **Dashboard** | `Dashboard.tsx` | 18KB | Overview metrics, quick actions, recent activity |
| **Campaigns** | `Campaigns.tsx` | 34KB | Campaign list with filters, status badges, bulk actions |
| **Create Campaign** | `CreateCampaign.tsx` | 27KB | Step-by-step campaign wizard (type, trigger, audience, schedule) |
| **Campaign Builder** | `CampaignBuilder.tsx` | 42KB | Visual drag-and-drop nudge designer with live preview |
| **Campaign Report** | `CampaignReport.tsx` | 26KB | Performance analytics: impressions, clicks, conversions, funnel |
| **Analytics** | `Analytics.tsx` | 13KB | Aggregated platform analytics & trend charts |
| **Events** | `Events.tsx` | 18KB | Event schema registry, event log viewer, event analytics |
| **Users** | `Users.tsx` | 25KB | User directory with search, filters, segment indicators |
| **User Details** | `UserDetails.tsx` | 32KB | Individual user profile, event timeline, properties, segments |
| **Assets** | `Assets.tsx` | 63KB | Media library: upload images, Lottie JSON, Rive files to S3 |
| **Templates** | `Templates.tsx` | 44KB | Reusable campaign template gallery with preview |
| **Settings** | `Settings.tsx` | 44KB | Organization settings, API keys, team, branding, billing |
| **Rewards** | `Rewards.tsx` | 24KB | Reward vault: create rewards, track inventory, view redemptions |
| **Segments** | `Segments.tsx` | 8KB | User segmentation rule builder |
| **Flows** | `Flows.tsx` | 9KB | Automation flow builder |
| **Pages** | `Pages.tsx` | 10KB | In-app page builder/editor |
| **API Docs** | `ApiPage.tsx` | 54KB | Interactive API documentation with code samples |
| **Support** | `Support.tsx` | 13KB | Contact form with email delivery |

### Dashboard Component Architecture

The dashboard features several complex UI renderers that preview campaign designs in real-time:

| Component | Size | Description |
|-----------|------|-------------|
| `FloaterRenderer.tsx` | 74KB | PiP/floating widget preview with drag, resize, animations |
| `TooltipRenderer.tsx` | 43KB | Tooltip nudge preview with anchor positioning |
| `BottomSheetRenderer.tsx` | 14KB | Bottom sheet campaign preview |
| `FullScreenRenderer.tsx` | 9KB | Full-screen modal/interstitial preview |
| `ShadowDomWrapper.tsx` | 2KB | Shadow DOM isolation for style encapsulation |

### Dashboard State Management

| Store | File | Size | Purpose |
|-------|------|------|---------|
| **Editor Store** | `useEditorStore.ts` | 200KB | Massive Zustand store powering the visual campaign builder. Manages layers, styles, animations, canvas state, undo/redo, clipboard, and multi-selection. |
| **Global Store** | `useStore.ts` | 16KB | App-wide state: current org, user, navigation, modals. |

### Dashboard Context Providers

| Context | File | Purpose |
|---------|------|---------|
| `AuthContext` | `AuthContext.tsx` | JWT token storage, login/logout, user session management |
| `EnvironmentContext` | `EnvironmentContext.tsx` | Production/staging environment toggle, sends `x-environment` header |

---

## 📱 Flutter SDK — `in_app_ninja`

**Directory:** `in_app_ninja/`  
**Version:** `1.0.0`  
**Dart SDK:** `>=2.17.0 <4.0.0`  
**Flutter:** `>=3.0.0`

### SDK Capabilities

The InAppNinja Flutter SDK enables **zero-code in-app engagement** with these features:

- 🎯 **Nudge Types**: Bottom sheets, modals, tooltips, floating widgets (PiP), fullscreen interstitials, inline banners, story carousels
- 🎮 **Gamification**: Spin wheel, scratch card, quiz challenges
- 📊 **Event Tracking**: Custom events with properties, automatic screen tracking
- 👤 **User Identification**: External ID mapping with custom user properties
- 🔗 **Deep Linking**: App Links/Universal Links integration
- 📸 **Screenshots**: Automatic screenshot capture for user context
- 🎬 **Rich Media**: Lottie animations, Rive animations, video players, YouTube embeds, WebView
- 🎨 **Dynamic Styling**: Google Fonts, custom colors, gradients, shadows, borders, border-radius
- 🔄 **Auto-Rendering**: Zero-code overlay campaign rendering with `NinjaApp` wrapper

### SDK Dependencies

| Package | Purpose |
|---------|---------|
| `http` | Network requests to EmbedCraft API |
| `rxdart` | Reactive streams for campaign state |
| `shared_preferences` | Local persistence (seen campaigns, user identity) |
| `path_provider` | File system paths for cache |
| `visibility_detector` | Widget visibility tracking |
| `video_player` | Native video playback |
| `app_links` | Deep link handling |
| `screenshot` | Widget screenshot capture |
| `google_fonts` | Dynamic font loading |
| `url_launcher` | External URL handling |
| `scratcher` | Scratch card widget |
| `youtube_player_flutter` | YouTube video embedding |
| `lottie` | Lottie animation rendering |
| `rive` | Rive animation rendering |
| `webview_flutter` | In-app WebView |

### Exported Modules

**File:** [`in_app_ninja/lib/in_app_ninja.dart`](in_app_ninja/lib/in_app_ninja.dart)

| Export | Description |
|--------|-------------|
| `AppNinja` | Core SDK singleton — initialization, tracking, user identification |
| `NinjaApp` | Wrapper widget for auto-rendering campaigns (ZERO CODE) |
| `NinjaAutoObserver` | Auto screen tracking navigator observer (ZERO CODE) |
| `NinjaWidget` | Inline widget for embedding campaigns in widget trees |
| `EmbedWidgetWrapper` | Explicit ID wrapper for widget targeting |
| `NinjaAppComponent` | Component-based nudge placement |
| `NinjaStories` | Instagram-style story carousel |
| `NinjaTrackedView` | Widget wrapper for automatic visibility tracking |
| `NinjaWrapper` | Scroll detection wrapper |
| `NinjaRouteObserver` | Auto page tracking for navigation |
| `NinjaView` | Visibility tracking wrapper |
| `NinjaCallbackManager` | Event listener registration system |
| `CampaignRenderer` | Programmatic campaign rendering (PiP, overlays) |

### SDK Models

| Model | Description |
|-------|-------------|
| `Campaign` | Campaign configuration parsed from API response |
| `NudgeConfig` | Individual nudge layout and styling config |
| `NudgeModel` | Full nudge data model with layers, triggers, actions |
| `ChallengeModel` | Gamification challenge definition |
| `NinjaUser` | User identity and properties |
| `NinjaCallbackData` | Callback event data passed to listeners |
| `NinjaReferralLead` | Referral/lead capture data |
| `NinjaRegion` | Screen region definition for widget targeting |
| `NinjaWidgetDetails` | Widget metadata for tracking |

### Renderers & UI Engines

The SDK includes **7 specialized nudge renderers** and **2 campaign-level renderers**:

| Renderer | File | Size | Nudge Type |
|----------|------|------|------------|
| **Floater V2** | `Floater_render_v2.dart` | 123KB | PiP floating widget with drag, snap, animations |
| **Tooltip V2** | `tooltip_renderer_v2.dart` | 75KB | Positioned tooltip with anchor detection |
| **Slide Container** | `slide_container_renderer.dart` | 35KB | Slide-in panel from edges |
| **Bottom Sheet** | `bottom_sheet_nudge_renderer.dart` | 26KB | Bottom sheet with drag-to-dismiss |
| **Fullscreen** | `fullscreen_nudge_renderer.dart` | 13KB | Fullscreen modal/interstitial |
| **Story Wrapper** | `story_wrapper_renderer.dart` | 9KB | Instagram-style story carousel |
| **Inline** | `inline_nudge_renderer.dart` | 2KB | Inline widget renderer |
| **Campaign Renderer** | `campaign_renderer.dart` | 42KB | Top-level campaign orchestration |
| **Challenge Renderer** | `challenge_renderer.dart` | 18KB | Gamification challenge UI |

### SDK Integration Guide

#### Basic Initialization

```dart
import 'package:flutter/material.dart';
import 'package:in_app_ninja/in_app_ninja.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  AppNinja(
    apiKey: 'YOUR_NINJA_API_KEY',  // nk_live_* or nk_test_*
    debugMode: true,
    disableMode: false,
  );

  runApp(const MyApp());
}
```

#### Auto-Rendering Setup (Zero Code)

```dart
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  AppNinja(
    apiKey: 'YOUR_NINJA_API_KEY',
    debugMode: true,
    autoRender: true,
    navigatorKey: navigatorKey,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      builder: (context, child) => NinjaApp(child: child!),
      home: const HomeScreen(),
    );
  }
}
```

#### Core SDK Methods

```dart
final ninja = AppNinja.getInstance();

// Identify user
ninja.userIdentifier(
  externalId: 'user_10284',
  userProperties: { 'name': 'Aaryan', 'plan': 'gold' },
);

// Track events
ninja.track(event: 'product_added_to_cart', properties: { 'price': 320.0 });

// Track page views
ninja.trackPage(name: 'home', context: context);

// Clear campaigns
ninja.clearNudges();

// Sign out
ninja.userSignOut();
```

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `apiKey` | `String` | **Yes** | — | Application API key (`nk_live_*` or `nk_test_*`) |
| `debugMode` | `bool` | No | `false` | Enable console debug logs |
| `disableMode` | `bool` | No | `false` | Halt all SDK operations |
| `autoRender` | `bool` | No | `false` | Enable zero-code campaign rendering |
| `navigatorKey` | `GlobalKey<NavigatorState>` | No | `null` | Required when `autoRender` is true |

---

## 📖 Documentation Portal — `EmbedDoc`

**Directory:** `EmbedDoc/`  
**Live URL:** `https://docs.embedcraft.com`

A **React 18 + TypeScript** documentation portal built with Vite:

- **Auth-gated** — Requires login to access documentation (same credentials as dashboard).
- **ShadCN UI** + Tailwind CSS for styling.
- **Sidebar layout** (`DocsLayout`) with navigation tree.
- **Lazy-loaded pages** — Each doc is a separate `.tsx` file in `src/pages/docs/` loaded via `React.lazy()`.
- **Route registry** — `docRoutes.ts` (26KB) defines all documentation slugs and their component mappings.
- **Testing** — Vitest + Testing Library configured.

---

## 🌐 Landing Page — `embedcraft-ui-main`

**Directory:** `embedcraft-ui-main/`  
**Live URL:** `https://embedcraft.com`

A **React 19** marketing landing page built with:

- **TanStack Router** for file-based routing.
- **TanStack Start** for SSR/SSG capabilities.
- **Tailwind CSS v4** with `@tailwindcss/vite` plugin.
- **Framer Motion** for page animations.
- **Cloudflare Vite Plugin** for edge deployment.
- **Large single-page** — `routes/index.tsx` is 87KB, containing all landing sections.

---

## 🧪 Test App

**Directory:** `test_app/`

A **Flutter demo application** that integrates the `in_app_ninja` SDK locally:

```yaml
dependencies:
  in_app_ninja:
    path: ../in_app_ninja
```

- Demonstrates all SDK features: event tracking, user identification, campaign rendering.
- Integrates Firebase (Auth, Firestore) for user management.
- Contains a rich `main.dart` (30KB) with multiple test screens.

---

## 📦 NudgeCore V2 (Legacy Reference SDK)

**Directory:** `nudgecore_v2-8.0.3/`

The original **NudgeNow** Flutter SDK (v8.0.3) that EmbedCraft's `in_app_ninja` SDK is based on:

- Supports **Android**, **iOS**, and **Windows** platforms.
- Uses SQLite (`sqflite`) for local persistence (vs. `shared_preferences` in `in_app_ninja`).
- Includes platform-specific plugin classes (`NudgecoreV2Plugin`).
- Provides a reference implementation for renderer patterns and campaign matching logic.

---

## ☁️ AWS Production Infrastructure

### 1. Credentials, Endpoints & Identifiers Directory

Below is the directory of all provisioned services, URLs, and Resource Names (ARNs) inside the **ap-south-1 (Mumbai)** region:

#### 1.1 Web Domains & Public DNS Entries

| Service / Target | Custom Domain (DNS Alias) | AWS Base Endpoint |
|---|---|---|
| **API Backend (ALB)** | `https://api.embedcraft.com` | `embedcraft-production-alb-1784126882.ap-south-1.elb.amazonaws.com` |
| **Landing Web Page** | `https://embedcraft.com` / `https://www.embedcraft.com` | `d3d1iu5wvid4g6.cloudfront.net` (Distribution: `E3M8FDMP3HW5BN`) |
| **Dashboard Panel** | `https://dashboard.embedcraft.com` | `dl0180i6tgxdi.cloudfront.net` (Distribution: `E22PCSN8IN2U2A`) |
| **Documentation Portal** | `https://docs.embedcraft.com` | `EKHJQZLLFR06Y.cloudfront.net` (Distribution: `EKHJQZLLFR06Y`) |
| **Asset Storage CDN** | `https://assets.embedcraft.com` | `cloudfront-assets.cloudfront.net` |

#### 1.2 Data Infrastructure & Event Queueing

| Service | Environment / Connection String | Key Identifiers |
|---|---|---|
| **MongoDB Atlas Cluster** | `mongodb+srv://admin:***@embedcraft.z923ska.mongodb.net/?appName=EmbedCraft` | Cluster: `embedcraft.z923ska.mongodb.net` / Primary DB: `nudge_db` |
| **Redis Serverless Cache** | Host: `embedcraft-production-redis-zgnntc.serverless.aps1.cache.amazonaws.com:6379` | ElastiCache Serverless (Mumbai) |
| **AWS SQS Event Queue** | `https://sqs.ap-south-1.amazonaws.com/585949318403/embedcraft-production-event-queue` | Queue ARN: `arn:aws:sqs:ap-south-1:585949318403:embedcraft-production-event-queue` |
| **S3 Media Storage** | `embedcraft-production-assets-bucket` | AWS S3 Bucket (ap-south-1) |

#### 1.3 SSL Certificates & VPC Properties

| Resource | ARN / ID | Description |
|---|---|---|
| **VPC ID** | Managed by Terraform | Mumbai Private VPC (`10.0.0.0/16`) |
| **ACM Certificate (Global)** | `arn:aws:acm:us-east-1:585949318403:certificate/...` | `*.embedcraft.com` (CloudFront) |
| **ACM Certificate (Mumbai)** | `arn:aws:acm:ap-south-1:585949318403:certificate/...` | `*.embedcraft.com` (ALB TLS) |
| **AWS Secrets Manager** | `arn:aws:secretsmanager:ap-south-1:585949318403:secret:embedcraft-production-secrets-...` | `JWT_SECRET`, `MONGO_URI`, `REDIS_PASSWORD` |

### 2. Infrastructure Architecture & Network Flow

#### 2.1 Network Partitioning & Security Groups

| Subnet Tier | CIDR Blocks | Hosts | Connectivity |
|---|---|---|---|
| **Public Subnets** | `10.0.1.0/24`, `10.0.2.0/24` | ALB, NAT Gateway | Direct internet via IGW |
| **Private Subnets** | `10.0.10.0/24`, `10.0.11.0/24` | ECS Fargate Tasks (API + Worker) | Internet via NAT Gateway only; inbound only from ALB on port 4000 |
| **Isolated Subnets** | `10.0.20.0/24`, `10.0.21.0/24` | ElastiCache Redis | No internet; inbound only from ECS on port 6379 |

**VPC Peering:** Connects the Mumbai VPC directly to MongoDB Atlas private cluster, completely bypassing the public internet for database traffic.

### 3. DevOps & CI/CD Pipelines

Deployment is fully automated using GitHub Actions with zero-downtime rolling deployments:

```mermaid
sequenceDiagram
    autonumber
    actor Developer
    participant GitHub as GitHub Actions
    participant ECR as AWS ECR (Mumbai)
    participant ECS as AWS ECS Fargate
    participant S3 as AWS S3 Bucket
    participant CloudFront as CloudFront CDN

    Note over Developer, ECS: Backend Pipeline
    Developer->>GitHub: Git Push to main/master (backend/)
    activate GitHub
    GitHub->>GitHub: Run tests & Docker Multi-Stage build
    GitHub->>ECR: Push Docker Image (embedcraft-api)
    GitHub->>ECS: Register Task Definition & trigger update
    ECS->>ECS: Deploy Tasks (Min 100%, Max 200%)
    deactivate GitHub

    Note over Developer, CloudFront: Dashboard Pipeline
    Developer->>GitHub: Git Push to main/master (dashboard/)
    activate GitHub
    GitHub->>GitHub: Build React App (Vite production build)
    GitHub->>S3: Sync build files (dist/) to S3
    GitHub->>CloudFront: Invalidate CloudFront CDN Cache (/*)
    deactivate GitHub
```

#### 3.1 ECS Rolling Update Configuration (Zero-Downtime)

```json
{
  "minimumHealthyPercent": 100,
  "maximumPercent": 200
}
```

ECS boots new task containers and runs target group health checks. Once healthy, traffic routes to new containers; old containers drain and shut down. **Zero API downtime during updates.**

### 4. Multi-Tenant Connections & Queue Processing

#### 4.1 Tenant DB Context Switching

| Tier | Isolation Level | Mechanism |
|------|----------------|-----------|
| **Standard & Growth** | Logical database | `mongoose.connection.useDb('tenant_<org_id>', { useCache: true })` |
| **Enterprise** | Dedicated cluster | `mongoose.createConnection(org.dedicated_mongo_uri, { maxPoolSize: 50, minPoolSize: 5 })` |

```javascript
// Dynamic Tenant Resolution (tenantConnectionManager.js)
const runWithTenantContext = async (org, next) => {
    let connection;
    if (org.dedicated_mongo_uri) {
        // Enterprise Tier — dedicated cluster
        const cacheKey = org._id.toString();
        if (!dedicatedConnections[cacheKey]) {
            dedicatedConnections[cacheKey] = mongoose.createConnection(org.dedicated_mongo_uri, {
                maxPoolSize: 50, minPoolSize: 5
            });
        }
        connection = dedicatedConnections[cacheKey];
    } else {
        // Standard/Growth — shared cluster, logical database
        connection = mongoose.connection.useDb(`tenant_${org._id}`, { useCache: true });
    }
    return tenantStorage.run({ connection }, next);
};
```

#### 4.2 High-Scale Event Logging (SQS Ingestion Buffer)

To prevent MongoDB write saturation at scale (10M+ users):

1. **SDK `/track` call** → Pushes event to AWS SQS instantly → Returns `202 Accepted` within 30ms.
2. **SQS Worker (standalone process)**:
   - Long-polls SQS (20s) to minimize API calls.
   - Buffers up to 100 messages or waits 5 seconds.
   - Groups messages by `organization_id`.
   - Switches DB context via `runWithTenantContext`.
   - Bulk-writes with `EventLog.insertMany(cleanEvents, { ordered: false })`.
   - Deletes processed batches from SQS.

> [!TIP]
> **Graceful Fallback**: If AWS SQS is down or credentials expire, the API immediately falls back to direct MongoDB writes synchronously. Event data is **never lost**.

---

## 🏗 Terraform — Infrastructure as Code

**Directory:** `terraform/`  
**Provider:** AWS (`~> 5.0`)  
**Terraform:** `>= 1.5.0`  
**Primary Region:** `ap-south-1` (Mumbai)  
**Secondary Region:** `us-east-1` (for CloudFront SSL certificates)

### Terraform File Reference

| File | Lines | Purpose |
|------|-------|---------|
| `main.tf` | 36 | Provider configuration (ap-south-1 + us-east-1 alias) |
| `variables.tf` | 37 | Input variable definitions |
| `terraform.tfvars` | 9 | Production variable values |
| `vpc.tf` | 138 | VPC, 6 subnets (2 public + 2 private + 2 isolated), IGW, NAT, route tables |
| `security_groups.tf` | 89 | 3 security groups (ALB, ECS, Redis) with strict ingress rules |
| `alb.tf` | 76 | Application Load Balancer + HTTP→HTTPS redirect + HTTPS listener |
| `ecs.tf` | 364 | **Largest** — ECS cluster, 2 task definitions (API + Worker), 2 services, 7 auto-scaling policies |
| `ecr.tf` | 27 | 2 ECR repositories (embedcraft-api, embedcraft-worker) |
| `elasticache.tf` | 29 | Redis Serverless (engine 7, 10GB limit) |
| `sqs.tf` | 21 | SQS Standard Queue + DLQ with redrive policy |
| `s3_cloudfront.tf` | ~100 | Asset S3 bucket + CloudFront CDN distribution |
| `dashboard.tf` | ~200 | Dashboard S3 + CloudFront with OAC and SPA routing |
| `landing_and_docs.tf` | ~300 | Landing + Docs S3 buckets + CloudFront distributions |
| `route53.tf` | 35 | Hosted zone + DNS records (api.*, assets.*) |
| `ssl.tf` | ~90 | ACM certificates for Mumbai and us-east-1 with DNS validation |
| `iam.tf` | 115 | ECS execution role + task role + S3/SQS/Secrets policies |
| `secrets.tf` | 22 | Secrets Manager with placeholder values |
| `mongodb_peering.tf` | 40 | VPC peering accepter + private/isolated route rules |
| `codebuild.tf` | ~70 | Optional AWS CodeBuild project |
| `eventbridge.tf` | ~40 | EventBridge rules for scheduled tasks |
| `outputs.tf` | 52 | 10 output values (VPC ID, ALB DNS, CloudFront, S3, SQS, Redis, Secrets, Route53) |

### VPC & Network Topology

```
10.0.0.0/16 (Main VPC)
├── 10.0.1.0/24  — Public Subnet AZ-a (ALB, NAT)
├── 10.0.2.0/24  — Public Subnet AZ-b (ALB)
├── 10.0.10.0/24 — Private Subnet AZ-a (ECS Fargate)
├── 10.0.11.0/24 — Private Subnet AZ-b (ECS Fargate)
├── 10.0.20.0/24 — Isolated Subnet AZ-a (Redis)
└── 10.0.21.0/24 — Isolated Subnet AZ-b (Redis)
```

- **Single NAT Gateway** in public subnet AZ-a for cost-efficiency (~$32/mo savings vs multi-AZ NAT).
- **Route Tables**: Public → IGW, Private → NAT, Isolated → local only.

### ECS Fargate Compute

Two ECS services run on the same cluster:

| Service | vCPU | Memory | Desired Count | Port | Command |
|---------|------|--------|---------------|------|---------|
| **API Server** | 0.5 | 1024 MB | 2 | 4000 | `node index.js` |
| **SQS Worker** | 0.5 | 1024 MB | 2 | — | `node src/services/sqsWorker.js` |

Both services:
- Run in private subnets (`assign_public_ip = false`).
- Use `awsvpc` network mode (dedicated ENI per container).
- Use FireLens (Fluent Bit) sidecar for structured log shipping to CloudWatch.
- Inject secrets from AWS Secrets Manager (`MONGO_URI`, `JWT_SECRET`).

### Auto-Scaling Policies

**7 auto-scaling policies** across 2 services:

| Service | Metric | Target | Cooldown (In/Out) |
|---------|--------|--------|-------------------|
| API | CPU Utilization | 65% | 300s / 60s |
| API | ALB Request Count/Target | 800 req/min | 300s / 60s |
| API | Memory Utilization | 70% | 300s / 60s |
| Worker | CPU Utilization | 65% | 300s / 60s |
| Worker | Memory Utilization | 70% | 300s / 60s |
| Worker | SQS Queue Depth | 100 messages | 300s / 60s |

Scale range: **2–10 tasks** for both services.

### SQS Event Queue

| Property | Value |
|----------|-------|
| **Queue Type** | Standard |
| **Max Message Size** | 256 KB |
| **Retention** | 4 days |
| **Long Polling** | 20 seconds |
| **Visibility Timeout** | 60 seconds |
| **DLQ Max Receive** | 5 retries before DLQ |
| **DLQ Retention** | 14 days (audit trail) |

### ElastiCache Redis

| Property | Value |
|----------|-------|
| **Engine** | Redis 7 (Serverless) |
| **Storage Limit** | 10 GB |
| **Subnets** | Isolated (10.0.20.0/24, 10.0.21.0/24) |
| **Security** | TLS in-transit, ECS-only ingress |

### ALB & HTTPS

- **HTTP Listener (80)** → 301 redirect to HTTPS.
- **HTTPS Listener (443)** → Forward to ECS target group.
- **Health Check**: `GET /health` every 30s, 2 healthy / 3 unhealthy thresholds.
- **SSL Policy**: `ELBSecurityPolicy-2016-08`.

### IAM Roles & Policies

| Role | Type | Permissions |
|------|------|-------------|
| **ECS Execution Role** | Bootstrap | ECR image pull, Secrets Manager decrypt, CloudWatch logs |
| **ECS Task Role** | Runtime | `sqs:Send/Receive/DeleteMessage`, `s3:Put/Get/DeleteObject`, CloudWatch log write |

### Secrets Manager

Stores two critical secrets injected into ECS tasks at container startup:

| Key | Description |
|-----|-------------|
| `MONGO_URI` | MongoDB Atlas connection string |
| `JWT_SECRET` | JWT signing secret for auth tokens |

Lifecycle: `ignore_changes = [secret_string]` prevents Terraform from overwriting manually-updated secrets.

### MongoDB Atlas VPC Peering

Optional VPC peering with MongoDB Atlas:

- Accepts peering connection initiated from MongoDB Atlas console.
- Adds route rules in both Private and Isolated route tables to direct traffic through the peering connection.
- **Result**: Database traffic never traverses the public internet.

### Route 53 DNS

| Record | Type | Target |
|--------|------|--------|
| `api.embedcraft.com` | A (Alias) | ALB DNS |
| `assets.embedcraft.com` | A (Alias) | CloudFront Distribution |

### S3 & CloudFront CDN

The infrastructure provisions multiple S3 buckets and CloudFront distributions:

| Bucket | Purpose | CloudFront |
|--------|---------|------------|
| `embedcraft-production-assets-bucket` | Media assets (images, Lottie, Rive) | Yes — `assets.embedcraft.com` |
| `embedcraft-production-dashboard-*` | Dashboard React build | Yes — `dashboard.embedcraft.com` |
| `embedcraft-production-docs-*` | Docs React build | Yes — `docs.embedcraft.com` |
| `embedcraft-production-landing-*` | Landing page build | Yes — `embedcraft.com` |

CloudFront features:
- **Origin Access Control (OAC)** — SigV4 signing replaces legacy OAI.
- **SPA Routing** — 404/403 errors return `/index.html` with 200 status for React Router.
- **API Proxying** — `/api/*` and `/v1/*` routes forwarded to ALB with full header/cookie passthrough.

---

## 🔄 CI/CD Pipeline

**File:** [`.github/workflows/aws-deploy.yml`](.github/workflows/aws-deploy.yml)

```yaml
name: Deploy Backend to AWS ECR

on:
  push:
    branches: [main, master]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - Checkout Code
      - Configure AWS Credentials (via GitHub Secrets)
      - Login to Amazon ECR
      - Build, tag, and push Docker image:
          cd backend
          docker build -t 585949318403.dkr.ecr.ap-south-1.amazonaws.com/embedcraft-api:latest .
          docker push 585949318403.dkr.ecr.ap-south-1.amazonaws.com/embedcraft-api:latest
```

**Required GitHub Secrets:**

| Secret | Purpose |
|--------|---------|
| `AWS_ACCESS_KEY_ID` | AWS IAM access key for ECR push |
| `AWS_SECRET_ACCESS_KEY` | AWS IAM secret key |

After the image push, ECS detects the new `:latest` tag and performs a rolling deployment.

---

## 🛠 DevOps Scripts

| Script | Purpose |
|--------|---------|
| `build_in_cloud.ps1` | PowerShell script to build and push Docker images to ECR |
| `migrate_aws.ps1` | Migrate infrastructure between AWS accounts |
| `destroy_old_aws.ps1` | Teardown old AWS infrastructure safely |
| `run_ec2_builder.ps1` | Provision an EC2 instance for Docker builds |
| `extract_info.py` | Python utility for data extraction |

---

## 📊 Event Tracking System

EmbedCraft follows **industry-standard event tracking conventions** used by Segment, Amplitude, Mixpanel, and Firebase Analytics.

### Event Naming Convention

**Use `snake_case`** for all event names:

```dart
// ✅ Correct:
'app_opened', 'screen_viewed', 'button_clicked',
'product_added', 'checkout_started', 'order_completed'

// ❌ Avoid:
'AppOpened', 'screenViewed', 'HomeScreen_Viewed', 'Page View'
```

### Event Categories

| Category | Examples | Description |
|----------|---------|-------------|
| **Lifecycle** | `app_opened`, `session_started` | Auto-tracked by SDK |
| **Navigation** | `screen_viewed`, `tab_switched` | Page/screen tracking |
| **E-commerce** | `product_viewed`, `product_added`, `checkout_started`, `order_completed` | Shopping funnel |
| **Engagement** | `button_clicked`, `search_performed`, `form_submitted`, `content_shared` | User interactions |
| **Campaign** | `nudge_viewed`, `nudge_clicked`, `nudge_dismissed` | Auto-tracked by SDK |

### Campaign Trigger Rules

```json
{
  "name": "Free Shipping Offer",
  "trigger": "cart_viewed",
  "rules": [
    {
      "type": "event",
      "field": "cart_total",
      "operator": ">=",
      "value": "50"
    },
    {
      "type": "attribute",
      "field": "plan",
      "operator": "==",
      "value": "premium"
    }
  ]
}
```

---

## 🚀 Kubernetes Migration Blueprint

**File:** [`detailed_k8s_docker_architecture.md`](detailed_k8s_docker_architecture.md)

A comprehensive migration plan from ECS Fargate to Kubernetes (EKS):

| Component | Current (ECS) | Target (K8s) |
|-----------|--------------|-------------|
| **Container Orchestration** | ECS Task Definitions | Kubernetes Pods + Helm Charts |
| **Service Mesh** | None | Istio/Linkerd with mTLS sidecars |
| **Auto-Scaling** | ECS AppAutoScaling (CPU/Memory/SQS) | HPA + VPA + KEDA (event-driven) + Karpenter (node) |
| **Logging** | CloudWatch awslogs driver | Promtail DaemonSet → Grafana Loki |
| **RBAC** | IAM Task Roles | IAM Roles for Service Accounts (IRSA) + K8s RBAC |
| **Deployment** | Rolling updates (min 100%, max 200%) | Helm releases with rollback |

---

## 💻 Running Locally — Development Setup

### Prerequisites

| Tool | Version | Purpose |
|------|---------|---------|
| **Node.js** | 20+ | Backend + Dashboard |
| **npm** | 10+ | Package management |
| **Flutter** | 3.0+ | SDK development & test app |
| **MongoDB** | 7.0+ (or Atlas free tier) | Database |
| **Redis** | 7.0+ (optional) | Caching (falls back to no-cache) |
| **Terraform** | 1.5+ (optional) | Infrastructure provisioning |

### Backend

```bash
cd backend
cp .env.example .env      # Configure your MongoDB URI
npm install
npm run dev                # Starts on http://localhost:4000 with --watch
```

### SQS Worker (Optional — only needed for SQS event processing)

```bash
cd backend
npm run worker:sqs         # Standalone SQS consumer
```

### Dashboard

```bash
cd dashboard
npm install
npm run dev                # Starts on http://localhost:5173
```

### Documentation Portal

```bash
cd EmbedDoc
npm install
npm run dev                # Starts on http://localhost:5174
```

### Landing Page

```bash
cd embedcraft-ui-main
npm install
npm run dev                # Starts on http://localhost:5175
```

### Flutter Test App

```bash
cd test_app
flutter pub get
flutter run                # Runs on connected device/emulator
```

### Terraform (Infrastructure)

```bash
cd terraform
terraform init
terraform plan             # Preview changes
terraform apply            # Provision infrastructure
```

---

## 📄 License

Proprietary — EmbedCraft © 2024–2026. All rights reserved.
