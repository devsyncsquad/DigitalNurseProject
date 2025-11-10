# Digital Nurse Web Portal Requirements

## 1. Mobile App Feature Summary

- **Authentication & Onboarding**
  - Email/password registration with caregiver invite support.
  - Email verification workflow prior to full access.
  - Role selection between patient and caregiver.
  - Multi-step profile setup including demographics, medical history, emergency contacts, subscription selection.
- **Dashboard Experience**
  - Personalized greeting and adherence streak KPI.
  - Medication reminders with adherence tracking.
  - Recent vitals overview with abnormality highlights.
  - Recent documents summary and quick access.
  - Diet and exercise activity snapshot.
  - Caregiver-specific context switcher for assigned elders and notification badge for alerts.
- **Medication Management**
  - Add/edit/delete medicines with dosage, schedule, and reminder times.
  - Intake logging with status (taken, missed, upcoming) and adherence metrics.
  - Calendar views for daily regimen.
- **Vitals Tracking**
  - Record, edit, delete vital measurements (e.g., blood pressure, heart rate).
  - Trend calculations and abnormal reading detection.
  - Calendar views and historical retrieval.
- **Lifestyle Logging**
  - Capture diet and exercise entries with daily and weekly summaries.
  - Support for deletion, summaries, and combined dashboard insights.
- **Document Management**
  - Upload, update, delete documents with type classification and visibility controls.
  - Share documents with caregivers or keep private.
- **Caregiver Coordination**
  - Patients invite caregivers, see invitation status, manage relationships.
  - Caregivers accept invitations, switch between assigned elders, and access shared data.
- **Notifications**
  - Push notification scheduling, unread counts, mark-as-read, and deletion.
  - Topic subscription management and FCM integration.
- **Profile & Settings**
  - Profile editing, subscription updates, language selection (English/Urdu), notification preferences.
  - Logout and debug/testing utilities.

## 2. Web Portal Objectives

- Extend mobile capabilities to a desktop-friendly interface optimized for care coordinators, clinicians, and administrative staff.
- Centralize patient data review (medications, vitals, documents, lifestyle trends) without duplicating mobile-only authoring such as medication creation.
- Provide robust role-based access control, auditability, and compliance-ready workflows (HIPAA/local equivalents).
- Enable scalable management of user accounts, caregiver assignments, subscription tiers, and alerts.
- Support bilingual content with easy localization updates aligned with mobile translations.

## 3. Target Personas

- **Clinical Admin**: Sets up patient accounts, reviews escalations, manages subscriptions and permissions.
- **Healthcare Provider**: Monitors patient progress, reviews vitals/documents, communicates care plans.
- **Care Coordinator**: Manages caregiver assignments, tracks adherence, ensures documentation completeness.
- **Patient (Read-Only)**: Accesses own records, downloads documents, reviews notifications from larger screen.
- **Caregiver (Web)**: Mirrors mobile data access with enhanced visualization, no ability to author medications.

## 4. Role-Based Access Matrix

| Capability | Clinical Admin | Healthcare Provider | Care Coordinator | Patient | Caregiver |
| --- | --- | --- | --- | --- | --- |
| View patient roster | ✓ | ✓ | ✓ | self only | assigned elders |
| Manage user accounts & roles | ✓ | ✗ | ✗ | ✗ | ✗ |
| Assign caregivers to patients | ✓ | ✓ (request) | ✓ | request | ✗ |
| Review medication schedules | ✓ | ✓ | ✓ | ✓ | ✓ |
| Modify medication schedules | ✓ (approve edits) | propose change | escalate | ✗ | ✗ |
| Log medication intake | ✗ | ✓ (enter on behalf) | ✓ | ✓ | ✓ |
| View vitals history & trends | ✓ | ✓ | ✓ | ✓ | ✓ |
| Add/edit vital readings | ✓ | ✓ | ✓ | ✓ | ✓ |
| Review lifestyle logs | ✓ | ✓ | ✓ | ✓ | ✓ |
| Upload/manage documents | ✓ | ✓ | ✓ | ✓ | ✓ (if shared) |
| Update subscription plans | ✓ | request | request | ✓ (self) | ✗ |
| Manage notifications & alerts | ✓ | ✓ | ✓ | limited | limited |
| System configuration | ✓ | ✗ | ✗ | ✗ | ✗ |

*Note: Medication creation/editing remains mobile-first; portal supports viewing, approvals, and logging.*

## 5. Feature Requirements

### 5.1 Authentication & Access Control
- SSO-ready login with MFA support (email OTP or authenticator app).
- Role-aware landing pages; enforce JWT/refresh flows consistent with backend.
- Session timeout with re-authentication prompts.
- Audit trail capturing login attempts and role changes.

### 5.2 User & Role Management
- User directory with filters (role, subscription, status).
- CRUD for users (admins only); invitation workflows for caregivers and providers.
- Role assignment UI aligned with backend enums (`patient`, `caregiver`, future `provider`, `admin`).
- Caregiver invitation approval queue with status tracking.

### 5.3 Patient Overview Dashboard
- Multi-select filters (risk level, adherence, unread alerts).
- Widgets: adherence streak, upcoming reminders (read-only), recent vitals, outstanding documents, lifestyle summary.
- Alert panel for abnormal vitals, missed medication streaks, expiring subscriptions.

### 5.4 Patient Detail Workspace
- **Header**: demographics, emergency contacts, subscription tier, assigned care team.
- **Tabs**:
  - `Medications`: schedule timeline, adherence charts, intake logging, approval flow for changes submitted via mobile.
  - `Vitals`: graphing (daily/weekly), abnormal flag list, manual entry/edit.
  - `Lifestyle`: diet/exercise logs table with filters, export to CSV.
  - `Documents`: document library with type filter, download/preview, share visibility toggles.
  - `Care Network`: caregivers list, invite/ remove actions, relationship metadata.
  - `Notifications`: audit of automated and manual alerts sent to patient/caregivers.

### 5.5 Caregiver Management
- Global caregiver list with assignment counts and status (pending, active, declined).
- Workflow to match caregivers to patients, including multi-patient assignments.
- Communication log (notes, escalation history).

### 5.6 Notifications & Alerts
- Central inbox for system alerts with filters (type, severity, recipient).
- Compose manual alerts (email/SMS/push) based on templates.
- Bulk mark-as-read, escalation tagging, export.
- Integration with FCM topics for automated routing.

### 5.7 Subscription & Billing Oversight
- Subscription roster with plan tier, renewal date, payment status.
- Trigger plan upgrades/downgrades, issue refunds/credits (Stripe integration hooks).
- Reporting on subscription metrics (active, churn, revenue).

### 5.8 Reports & Analytics
- Downloadable reports for adherence, vitals trends, caregiver activity.
- Configurable scheduled exports delivered via email.
- Role-based access to sensitive metrics.

### 5.9 Settings & Configuration
- Localization management (sync with mobile translations, preview language toggle).
- Notification templates (email/push) editor with versioning.
- Security settings (password policy, session duration).

## 6. Data & Integration Considerations

- Reuse existing NestJS APIs; extend endpoints for web-specific views (pagination, filters, bulk operations) as needed.
- Ensure consistent data models (e.g., `UserRole`, `SubscriptionTier`, `DocumentType`, `VitalType`).
- Introduce GraphQL or aggregated REST endpoints for dashboard KPIs to minimize round-trips.
- Implement event logging ( audit service ) for compliance and debugging.
- Leverage shared notification infrastructure (FCM) with topic-based subscriptions per role.
- Support file preview/download through secure signed URLs from document service.

## 7. Non-Functional Requirements

- **Security & Compliance**: Enforce TLS, encrypt data at rest, role-based access, audit logging, HIPAA/GDPR alignment, consent tracking for caregivers.
- **Performance**: Sub-2s load for dashboards under typical load; scalable to thousands of users with caching (Redis) for dashboards.
- **Reliability**: 99.5% uptime target; graceful degradation when backend offline; retry logic for critical actions.
- **Accessibility**: WCAG 2.1 AA compliance (keyboard navigation, screen-reader labels, high-contrast mode).
- **Internationalization**: English and Urdu parity; right-to-left layout support if Urdu requires it.
- **Usability**: Responsive layout for tablet use; printable summaries for patient visits.

## 8. Implementation Roadmap (High-Level)

1. **Foundation**: Authentication, RBAC, shared UI components, layout framework.
2. **Core Data Views**: Patient roster, detail workspace with read-only data.
3. **Interactions**: Intake logging, caregiver assignment workflows, document management.
4. **Advanced Features**: Notifications composer, subscription management, reporting.
5. **Hardening**: Accessibility polishing, localization QA, security audits, performance tuning.

## 9. Open Questions & Assumptions

- Need confirmation on whether providers beyond patients/caregivers already exist in backend or require schema updates.
- Clarify compliance requirements for target markets (HIPAA vs. local standards).
- Determine preferred reporting stack (in-app vs. external BI).
- Assumed medication creation remains mobile-only; web approvals may require new backend endpoints.


