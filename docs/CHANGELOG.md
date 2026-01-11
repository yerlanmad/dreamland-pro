# Changelog - Dreamland PRO CRM

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### To Do
- Tours and Tour Departures management UI
- WhatsApp Templates management UI
- WhatsApp outbound messaging service
- Real-time features with Turbo Streams
- I18n translations (Russian/English)
- Test coverage expansion to 80%+

## [0.2.0] - 2026-01-10

### Added
- **Bookings Management**
  - Complete CRUD views (index, show, form, new, edit)
  - Advanced filters (search, status, upcoming tours)
  - Statistics cards (total, confirmed, upcoming, revenue)
  - JavaScript auto-calculation (total = participants × price)
  - Payment progress visualization
  - Booking status workflow (confirmed/paid/completed/cancelled)
  - Helper method: `booking_status_badge`

- **Payments Tracking**
  - Complete CRUD views (index, show, form, new, edit)
  - Filters by status, payment method, date range
  - "Apply full balance" helper button
  - Outstanding balance calculation
  - Payment progress bars per booking
  - Helper method: `payment_status_indicator`

- **Client Management Enhancement**
  - Redesigned client show page with modern UI
  - Gradient avatar background (indigo → purple)
  - Metrics cards with colored icon backgrounds
  - Breadcrumb navigation
  - Responsive layout improvements
  - Hover effects and transitions

- **Helper Methods**
  - `app/helpers/bookings_helper.rb` with status badges and payment indicators

### Fixed
- **Client-Centric Architecture Bug Fixes**
  - Fixed `undefined method 'name' for Lead` in `leads/show.html.erb` (line 164)
  - Changed `@lead.name` to `@lead.client.name` in communications section
  - Verified all other views properly use `lead.client.name` pattern
  - Dashboard, leads index, leads show - all client attribute access corrected

### Changed
- Updated documentation structure (PRD, MVP_IMPLEMENTATION_SUMMARY, database ERD)
- Enhanced UI/UX across all pages with SaaS-style design patterns

## [0.1.0] - 2026-01-08

### Added
- **Core MVC Structure**
  - 8 core models (User, Client, Lead, Tour, TourDeparture, Booking, Communication, Payment)
  - All migrations with proper indexes and foreign keys
  - Model validations, associations, enums, scopes
  - RESTful controllers (Leads, Bookings, Dashboard, Webhooks)
  - Complete routes configuration

- **Client-Centric Architecture (Version 1.4)**
  - Client model with unique phone constraint
  - Leads linked to Clients (many-to-one)
  - Bookings linked to Clients (many-to-one)
  - Communications belong to Clients with optional Lead/Booking references
  - Enables repeat customers and lifetime value tracking

- **Authentication & Authorization**
  - Rails 8 built-in authentication
  - Role-based access (admin, manager, agent)
  - Session management with secure cookies
  - Seed data with 3 demo users

- **WhatsApp Integration (wazzup24)**
  - Webhook endpoint for incoming messages
  - `Whatsapp::MessageHandler` service
  - Automatic Client find-or-create by phone
  - Lead creation from WhatsApp messages
  - Communication logging (inbound messages)

- **Leads Management Views**
  - Lead index with advanced filters (status, source, agent, unassigned, unread)
  - Lead show page with client context and communication history
  - Lead forms (new, edit) with client selection
  - Search functionality
  - Status badges with color coding

- **Dashboard**
  - Statistics cards (Total Leads, New, Unassigned, Unread Messages)
  - Recent leads list with status badges
  - Quick actions sidebar
  - Lead status breakdown
  - Responsive grid layout

- **Styling & UI/UX**
  - Tailwind CSS 3.3.2 fully integrated
  - Professional color scheme (indigo primary)
  - Navigation bar with logo and user dropdown
  - Flash messages with auto-dismiss
  - Status badges (New, Contacted, Qualified, Quoted, Won, Lost)
  - User avatars with initials
  - Responsive design (mobile-first)

- **Testing Infrastructure**
  - RSpec + FactoryBot + Faker setup
  - Example model spec (lead_spec.rb)
  - Factories for all models
  - Test coverage foundation

- **Multi-Currency Support**
  - USD, KZT, EUR, RUB support in tours, bookings, payments
  - Money gem integration
  - Currency symbols and formatting
  - No automatic exchange rates (manual pricing)

- **Documentation**
  - Comprehensive PRD (docs/PRD.md) with Version 1.4
  - Database ERD with Mermaid diagrams (docs/database-erd.md)
  - MVP Implementation Summary (docs/MVP_IMPLEMENTATION_SUMMARY.md)
  - CLAUDE.md with development guidelines

### Known Limitations
- Tours/Departures UI not yet created (models exist)
- WhatsApp Templates UI not yet created (model exists)
- No outbound WhatsApp messaging yet (only inbound)
- Real-time features (Turbo Streams) not yet implemented
- I18n translation files not yet created (structure ready)
- Test coverage < 80% (framework in place)

---

## Version Numbering

- **0.1.x** - Initial MVP development (Phase 1)
- **0.2.x** - Feature additions and bug fixes (Phase 1)
- **1.0.0** - Production-ready internal service (Phase 1 complete)
- **2.0.0** - Multi-tenant SaaS platform (Phase 2)
