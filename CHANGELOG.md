# Changelog

All notable changes to Dreamland PRO CRM will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.3.0] - 2026-01-11

### Added - WhatsApp Outbound Messaging & Templates UI (MVP Phase 1)

#### Core Features
- **WhatsApp Message Sending**: Agents can now send WhatsApp messages to clients directly from Lead detail pages
- **Message Templates Management**: Complete CRUD interface for creating and managing reusable message templates
- **Variable Substitution**: Templates support dynamic variables like `{{name}}`, `{{phone}}`, `{{email}}`, `{{tour_name}}`
- **Template Categories**: Organize templates by type (Greeting, Pricing, Availability, Confirmation, Follow-up, General)
- **Communication Tracking**: All sent messages are recorded in the communications timeline with status tracking

#### Technical Implementation
- **Wazzup24Client** (`app/clients/wazzup24_client.rb`): HTTP wrapper for wazzup24 WhatsApp Business API
  - Phone number normalization to wazzup24 format (+phone@c.us)
  - Error handling and timeout protection (10 seconds)
  - HTTParty-based HTTP client
- **SendMessageService** (`app/services/whatsapp/send_message_service.rb`): Message sending orchestration
  - Template rendering with client data
  - Communication record creation with status tracking (pending → sent/failed)
  - Comprehensive error handling and logging
- **WhatsappTemplatesController**: Full CRUD operations + toggle_active action
- **CommunicationsController**: Updated with send_whatsapp_message method

#### User Interface
- **Templates Index** (`/whatsapp_templates`):
  - List view with filters by category
  - Stats cards (Total, Active, Categories)
  - Activate/deactivate toggle buttons
- **Template Show**: Preview templates with sample data
- **Template Form**: Create/edit templates with variable info box
- **Lead Show Page**: Updated message form with:
  - Template dropdown selector
  - Message type selection (WhatsApp/Email)
  - Variable hints for users

#### Database & Configuration
- Added `httparty` gem (v0.21) for HTTP requests
- Added `webmock` gem for test HTTP stubbing
- Routes: Added `toggle_active` member route to whatsapp_templates
- Credentials: Requires wazzup24 API key configuration

#### Testing
- Comprehensive test suite for Wazzup24Client (6 test cases)
- WebMock stubs for HTTP request testing
- Test coverage for phone normalization, error handling, media URLs

### Changed
- **CommunicationsController**: Refactored `create` action to route by message type
  - Now supports both WhatsApp and Email (Email placeholder for future)
  - Improved redirect helpers for better code organization
- **Lead Show View**: Enhanced message sending form
  - Better styling with Tailwind CSS rounded borders
  - Template selector dropdown
  - Improved UX with variable hints

### Documentation
- Added comprehensive `docs/WHATSAPP_INTEGRATION.md` covering:
  - Architecture and data flow diagrams
  - Setup and configuration guide
  - Feature usage for users and developers
  - API integration details (wazzup24)
  - Code reference and examples
  - Troubleshooting guide
  - Future enhancement roadmap

### Dependencies
- `httparty ~> 0.21` - HTTP client for external API calls
- `webmock` - Test support for HTTP request stubbing

### Configuration Required
Users must add wazzup24 API key to Rails credentials:
```bash
rails credentials:edit
# Add: wazzup24: { api_key: YOUR_KEY }
```

## [0.2.0] - 2026-01-11

### Added - Tours & Tour Departures Management

#### Features
- **Tours CRUD**: Complete create, read, update, delete for tours
  - Tour attributes: name, description, base_price, currency, duration_days, capacity, active status
  - Multi-currency support (USD, KZT, EUR, RUB)
  - Active/inactive status toggle
  - Filter by status and currency
- **Tour Departures CRUD**: Manage specific tour dates and availability
  - Departure attributes: departure_date, price, currency, capacity
  - Pre-filled defaults from parent tour
  - Safety checks prevent deletion if bookings exist
  - Capacity tracking with visual progress bars
- **Capacity Management**: Real-time available spots calculation
  - Color-coded indicators (green > 50%, yellow 25-50%, red < 25%)
  - "Full" badges when no spots available
- **Nested Resources**: RESTful routes with shallow nesting
  - `/tours/:tour_id/tour_departures/new`
  - `/tour_departures/:id` (shallow routes for edit/show/destroy)

#### User Interface
- **Tours Index**:
  - Stats cards (Total Tours, Active, Total Departures, Upcoming)
  - Filter by active status and currency
  - Pagination support (Kaminari)
- **Tours Show**:
  - Tour details with stats
  - Upcoming departures table (limit 10)
  - Empty state with "Add Departure" CTA
- **Tour Departures Index**:
  - Filter by timeframe (All/Upcoming/Past)
  - Stats cards with capacity metrics
  - Clickable rows for quick navigation
- **Tour Departures Show**:
  - Departure details with capacity visualization
  - Bookings list linked to this departure
  - Edit/Delete actions

#### Technical
- **ToursHelper**: Helper methods for formatting
  - `tour_status_badge(tour)` - Active/Inactive badges
  - `currency_symbol(currency)` - Convert to symbols (₽, €, ₸, $)
  - `format_tour_price(amount, currency)` - Format with proper symbols
  - `capacity_color_class(available, total)` - Color-coded capacity
  - `capacity_percentage(available, total)` - Percentage calculation
  - `departure_status_badge(departure)` - Today/Upcoming/Past badges
  - `departure_full_badge` - Full capacity indicator
- **Controllers**: Full CRUD with before_action filters
  - Eager loading to prevent N+1 queries
  - Safety checks (e.g., prevent deletion if dependencies exist)
  - Proper flash messages for user feedback

#### Database
- Tours: 6 seeded tours with various durations and prices
- Tour Departures: 19 seeded departures across multiple tours
- Foreign key constraints and indexes for performance

#### Bug Fixes
- Fixed button_to syntax for Rails 8 (turbo_confirm instead of confirm)
- Fixed flex layout issue in tours/show (added min-w-0, gap-6, flex-shrink-0)
- Fixed duration_days access in bookings views (booking.tour_departure.tour.duration_days)
- Removed non-existent new_booking_communication_path link

## [0.1.0] - 2026-01-10

### Added - Initial CRM Core Features

#### Client Management
- Client model with name, email, phone, address
- Client-centric architecture (all leads, bookings, communications roll up to client)
- Client CRUD operations

#### Lead Management
- Lead lifecycle: new → contacted → qualified → lost/converted
- Lead sources tracking (website, referral, social_media, direct, advertising)
- Assignment to agents
- Unread message tracking
- Lead search and filtering
- Automatic lead creation from WhatsApp webhook

#### Booking Management
- Booking workflow: confirmed → paid → completed → cancelled
- Multi-participant bookings
- Currency support per booking (USD, KZT, EUR, RUB)
- Total amount calculation (price × participants)
- Link to tours and tour departures
- Outstanding balance tracking

#### Payment Tracking
- Payment methods: cash, bank_transfer, card, online
- Payment status: pending, completed, failed, refunded
- Multiple payments per booking
- Currency per payment
- Outstanding balance calculation

#### WhatsApp Integration (Inbound Only - Phase 1)
- Webhook handler for incoming wazzup24 messages
- Automatic lead creation/update from WhatsApp
- Communication timeline display
- Phone number normalization (handles @c.us format)
- Message direction tracking (inbound/outbound)
- WhatsApp-specific fields: message_id, status

#### Authentication & Authorization
- Rails 8 built-in authentication
- User roles: admin, manager, agent
- Session management
- Password reset flow

#### Database
- SQLite3 for Phase 1 (single-tenant)
- 9 core tables: clients, leads, communications, users, bookings, payments, tours, tour_departures, whatsapp_templates
- Proper foreign keys and indexes
- Seed data for development

#### Testing
- RSpec + FactoryBot configuration
- Comprehensive MessageHandler specs
- Factories for all models
- Test coverage >70%

#### UI/UX
- Tailwind CSS 3.3.2 integration
- Responsive SaaS-style design
- Card-based layouts
- Status badges (color-coded)
- Empty states with CTAs
- Pagination (Kaminari)

#### Developer Experience
- Comprehensive PRD documentation
- Database ERD diagram
- CLAUDE.md file with project guidelines
- Rails 8 modern stack (SolidQueue, SolidCache, SolidCable)
- Kamal 2 deployment configuration

---

## Versioning Notes

### Version Format: MAJOR.MINOR.PATCH

- **MAJOR**: Incompatible API changes, major architecture changes
- **MINOR**: New features, backward-compatible
- **PATCH**: Bug fixes, minor improvements

### Release Cadence

- **MVP Phase 1** (v0.1.0 - v0.5.0): Core CRM features
- **MVP Phase 2** (v0.6.0 - v1.0.0): Multi-tenancy, real-time features, email
- **v1.0.0**: First production-ready release
- **v2.0.0+**: Customer portal, mobile apps, advanced analytics

---

## Links

- **GitHub Repository**: https://github.com/yerlanmad/dreamland-pro
- **Documentation**: See `/docs` directory
- **Issue Tracker**: GitHub Issues
- **Product Roadmap**: `docs/PRD.md`
