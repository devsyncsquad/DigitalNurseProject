# Digital Nurse Web Portal (Frontend Mock)

This Vite + React + TypeScript project implements a desktop web portal that mirrors the Digital Nurse mobile experience. It focuses on a fully interactive frontend mock using [shadcn/ui](https://ui.shadcn.com/), Tailwind CSS v4, and mock data sources—no backend integration is required yet.

## Getting Started

```bash
cd web/portal
npm install
npm run dev
```

The development server runs on [http://localhost:5173](http://localhost:5173). All data is static and lives under `src/mocks/`.

## Tech Stack

- Vite + React 19 + TypeScript
- Tailwind CSS v4 with the `@tailwindcss/vite` plugin
- shadcn/ui component library
- Recharts for lightweight data visualizations
- Date-fns for date manipulation

## Project Structure (selected)

- `src/components/` – shared UI pieces (layout shell, theme toggle, dashboard widgets, shadcn components)
- `src/layouts/app-layout.tsx` – authenticated app shell with responsive sidebar, header, and routing outlet
- `src/pages/` – route-level pages, grouped by functional area (dashboard, patients, caregiver management, etc.)
- `src/mocks/data.ts` – canonical mock datasets feeding the UI
- `src/components/theme-provider.tsx` – light/dark/system theme orchestration

## Routes & Feature Coverage

| Route | Purpose |
| ----- | ------- |
| `/` | Patient overview dashboard with KPIs, vitals trends, reminders, alerts, doc summary |
| `/patients` | Roster with filtering, cohort segmentation, escalation toggle |
| `/patients/:slug` | Detailed patient workspace (meds, vitals, lifestyle, documents, care network, notifications) |
| `/caregivers` | Caregiver directory, status filters, invitation dialog |
| `/notifications` | Alert inbox, severity tabs, unread management |
| `/documents` | Document library with visibility filters and download CTA |
| `/subscriptions` | Subscription roster, plan filters, renewal forecast |
| `/reports` | Scheduled report manager with frequency filters |
| `/settings` | Localization preview, notification template cards, security toggles |
| `/audit` | Compliance audit trail table |
| `/login` | Auth mock with MFA context and support messaging |

## Mock Data Model

The aggregated dataset in `src/mocks/data.ts` mirrors expected backend responses:

- `dashboardMetrics`, `medicationReminders`, `vitalTrend`, `dashboardAlerts`
- `patientRoster` (with slugs used for routing) and `patientWorkspace` (detailed example)
- `caregivers`, `documents`, `notifications`, `subscriptions`, `reportSchedules`, `notificationTemplates`

These mocks are intentionally rich enough to demonstrate filtering, trend charts, and UI edge cases like overdue alerts or pending documents.

## Tailwind & Theming Notes

- Tailwind v4 is configured via `@tailwindcss/vite`; utility layers come from `src/index.css`.
- Design tokens (background, foreground, sidebar, chart colors) live as CSS variables with both light/dark definitions.
- `ThemeProvider` wraps the app to handle system / light / dark preferences with local storage persistence.

## Next Steps / Integration Hooks

- Wire React Query (or equivalent) to real NestJS endpoints once they are ready.
- Replace static mocks with API clients in `src/mocks/` (keep file structure for typing).
- Harden forms and dialogs with `react-hook-form` + zod when moving beyond static mocks.
- Add route-level loaders/guards once authentication APIs are connected.
- Consider code splitting for heavier sections (`patient-workspace`, dashboard) when data fetching arrives.

## Linting & Formatting

```bash
npm run lint
npm run build
```

ESLint is configured with `@eslint/js` and React refresh rules; Tailwind formatting is handled via the CSS layer. The build command compiles TypeScript and bundles assets for static deployment of the mock.
