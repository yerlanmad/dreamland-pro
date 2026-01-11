# Product Requirements Document: Dreamland PRO CRM

**Version:** 1.5
**Date:** January 10, 2026
**Status:** Draft
**Product:** Dreamland PRO - Tour Sales CRM System (WhatsApp-First, Russian/English, Multi-Currency)

---

## Executive Summary

### Problem Statement
Tour operators and travel agencies currently lack a unified CRM system specifically designed for the unique challenges of tour sales management, especially one that integrates with WhatsApp - the primary communication channel for customer inquiries. Existing solutions are either generic CRMs that don't understand the tour industry workflow or expensive enterprise systems that are overkill for small-to-medium tour operators. This results in:
- Fragmented customer data across multiple spreadsheets and tools
- WhatsApp conversations scattered across multiple devices with no centralized tracking
- Manual tracking of tour bookings, payments, and customer communications
- Inability to forecast revenue and manage tour capacity effectively
- Poor customer experience due to lack of centralized communication history
- Lost leads when team members miss WhatsApp messages or lack context
- Difficulty in managing seasonal demand and dynamic pricing

### Solution Overview
Dreamland PRO is a specialized CRM system built specifically for tour operators and travel agencies, with native WhatsApp integration as the primary communication channel. It combines customer relationship management with tour inventory management, booking workflows, payment tracking, and analytics - all tailored to the tour sales lifecycle. By integrating with wazzup24 (WhatsApp Business API gateway), all customer conversations are automatically captured, organized, and tracked within the CRM.

**Phase 1 (Internal Service):** Deploy as an internal tool for our tour operation business to validate product-market fit, refine workflows, and gather real-world usage data.

**Phase 2 (SaaS Platform):** Transform into a multi-tenant SaaS platform for the broader travel market, enabling other tour operators to benefit from our proven system.

### Success Metrics
**Phase 1 (Internal) - 6 months:**
- 100% user adoption by sales team (target: 15 users)
- 40% reduction in booking processing time
- 95% of customer communications tracked in system
- 25% increase in upsell/cross-sell conversions
- Zero data loss or critical system failures

**Phase 2 (SaaS) - 12 months post-launch:**
- 50 paying customers in first year
- $500K ARR (Annual Recurring Revenue)
- 90%+ customer retention rate
- NPS (Net Promoter Score) > 50
- 99.9% uptime SLA

### Timeline
**Phase 1: Internal Service (Months 1-8)**
- Month 1-2: MVP Development (Core CRM + Booking)
- Month 3-4: Payment & Communication Features
- Month 5-6: Reporting & Analytics
- Month 7-8: Refinement & Team Training

**Phase 2: SaaS Platform (Months 9-16)**
- Month 9-10: Multi-tenancy & Self-service Onboarding
- Month 11-12: Advanced Features & Integrations
- Month 13-14: Marketing & Beta Program
- Month 15-16: General Availability Launch

---

## Implementation Status (Phase 1)

**Last Updated:** January 10, 2026

### ✅ Completed Features

#### Core Architecture
- **Client-Centric Architecture** - Fully implemented with Client → Leads, Bookings, Communications relationships
- **Database Schema** - All 8 core models with migrations and validations
- **Authentication** - Rails 8 built-in auth with role-based access (admin/manager/agent)
- **Multi-Currency** - Full support for USD, KZT, EUR, RUB in tours, bookings, payments
- **Styling** - Tailwind CSS 3.3.2 with professional SaaS-style design

#### Client Management
- **Client Views** - Show page with gradient avatar, metrics cards, lifetime history
- **Client Model** - Find-or-create by phone, duplicate prevention
- **UI/UX** - Modern design with breadcrumbs, hover effects, responsive layout

#### Lead Management
- **Lead Index** - Advanced filters (status, source, agent, unassigned, unread)
- **Lead Show** - Client context, communication history, status management
- **Lead Forms** - Create/edit with client selection
- **WhatsApp Integration** - Webhook handler, automatic lead creation from messages
- **Bug Fixes** - All client attribute access errors resolved

#### Booking Management
- **Bookings Index** - Filters, search, statistics cards
- **Bookings Show** - Full context (client, tour, payments, communications)
- **Bookings Forms** - Auto-calculation (participants × price), tour selection
- **Status Workflow** - Confirmed → Paid → Completed → Cancelled
- **Helper Methods** - `booking_status_badge` for UI

#### Payment Tracking
- **Payments Index** - Filters by status, method, date range
- **Payments Show** - Booking context, payment progress
- **Payments Forms** - "Apply full balance" helper, currency support
- **Outstanding Balance** - Automatic calculation per booking
- **Helper Methods** - `payment_status_indicator` for bookings

#### Dashboard & Analytics
- **Statistics Cards** - Total/New/Unassigned leads, Unread messages
- **Recent Leads** - List with status badges and quick actions
- **Lead Status Breakdown** - Visual distribution by status
- **Quick Actions** - New lead, manage tours, view bookings

#### Testing Infrastructure
- **RSpec + FactoryBot** - Fully configured
- **Example Specs** - Lead model with comprehensive tests
- **Factories** - All models (users, leads, tours, bookings, payments)

### 🚧 In Progress

- **Tours Management** - Models complete, controllers/views pending
- **WhatsApp Templates** - Model complete, UI pending
- **Test Coverage** - Framework ready, need 80%+ coverage
- **I18n Translations** - Structure ready, translation files pending

### ⏳ Pending (Phase 1)

- **WhatsApp Outbound** - Send messages from CRM to customers
- **Real-time Updates** - Turbo Streams for live dashboard/notifications
- **Email Communication** - Secondary channel with templates
- **Reporting Enhancement** - Sales pipeline, revenue reports, exports
- **Multi-Tenancy** - Phase 2 (SaaS platform)

### Estimated Completion Timeline

**Core MVP Remaining:** 5-10 days
- Tours/Departures UI: 2 days
- WhatsApp Templates UI: 1 day
- Outbound messaging: 2 days
- Real-time features: 2 days
- Test coverage: 2-3 days

---

## 1. Background & Context

### Industry Overview
The global tour operator market is worth $180B+ annually, with thousands of small-to-medium operators struggling with operational efficiency. The industry faces unique challenges:
- **Seasonal demand fluctuations** requiring dynamic capacity management
- **Complex pricing models** (per person, group discounts, early bird rates, peak season premiums)
- **Multi-step booking process** (inquiry → quote → deposit → full payment → tour delivery)
- **High customer service requirements** (pre-tour questions, itinerary customization, post-tour follow-up)
- **Integration needs** (payment processors, email marketing, accounting software)

### Current Workflow Pain Points
Our internal team currently uses:
- **WhatsApp (wazzup24)** for customer inquiries and communications - but conversations are not centralized
  - Multiple agents use their personal phones or shared devices
  - No way to see conversation history when another agent takes over
  - Messages get lost, context is missing
  - Can't track response times or conversation status
- Google Sheets for lead tracking (manual data entry from WhatsApp conversations)
- QuickBooks for invoicing (separate system, double entry)
- Manual Excel reports for performance tracking (time-consuming)

**Current Pain Points:**
- **90%+ of customer inquiries** come through WhatsApp but aren't tracked in any system
- Agents manually copy-paste customer details from WhatsApp to spreadsheets
- No visibility into which leads are hot, which need follow-up
- Team coordination is chaotic (who's talking to which customer?)
- Customer context is lost when switching agents

**Average time per booking:** 45 minutes (target: reduce to 25 minutes)
**Revenue leakage:** ~8% from missed follow-ups and payment reminders

### Strategic Goals
1. **Operational Efficiency:** Automate repetitive tasks, reduce manual data entry
2. **Customer Experience:** Provide faster responses, personalized service, seamless booking
3. **Revenue Growth:** Improve conversion rates, enable upselling, reduce payment delays
4. **Data-Driven Decisions:** Real-time insights into sales pipeline, tour performance, customer behavior
5. **Market Expansion:** Build a scalable platform that can serve other tour operators

---

## 2. Goals & Objectives

### Business Goals
- **Increase conversion rate** from inquiry to booking by 30%
- **Reduce booking processing time** by 40%
- **Improve customer satisfaction** (target CSAT: 4.5/5)
- **Enable data-driven pricing** decisions
- **Scale to SaaS** with minimal technical debt

### User Goals
**For Sales Agents:**
- Spend less time on administrative tasks
- Have complete customer context at fingertips
- Easily track and follow up on leads
- Quickly generate quotes and invoices

**For Sales Managers:**
- Monitor team performance in real-time
- Identify bottlenecks in sales pipeline
- Forecast revenue accurately
- Optimize tour capacity and pricing

**For Customers:**
- Receive prompt, personalized responses
- Easily view tour options and availability
- Track booking status and payments
- Communicate through preferred channels

### Technical Goals
- **Reliability:** 99.9% uptime
- **Performance:** < 2s page load, < 500ms API response
- **Security:** SOC 2 compliance-ready architecture
- **Scalability:** Support 10,000+ bookings/month
- **Maintainability:** Clean codebase, comprehensive tests

---

## 3. User Personas

### Primary Personas

#### 1. Sarah - Sales Agent
**Background:** 28 years old, 2 years in travel industry, handles 20-30 customer inquiries per week
**Tech Savvy:** Moderate (comfortable with web apps, prefers mobile-friendly interfaces)
**Pain Points:**
- Loses track of follow-ups when juggling multiple leads
- Spends too much time searching for customer conversation history
- Manually copies data between systems
- Struggles to remember tour details when talking to customers

**Goals:**
- Respond to customer inquiries within 2 hours
- Convert 35% of qualified leads to bookings
- Provide accurate information without constantly checking notes
- Meet monthly sales quota

#### 2. Michael - Sales Manager
**Background:** 35 years old, 8 years managing tour sales teams, oversees 5 agents
**Tech Savvy:** High (data-driven, loves dashboards and analytics)
**Pain Points:**
- Lacks visibility into team activities and pipeline health
- Can't easily identify which agents need coaching
- Spends hours compiling weekly reports from spreadsheets
- Difficult to spot trends and optimize tour offerings

**Goals:**
- Achieve team sales targets (15-20 bookings/week)
- Identify and resolve pipeline bottlenecks quickly
- Coach team based on performance data
- Optimize tour pricing and capacity utilization

#### 3. Lisa - Customer (Tour Buyer)
**Background:** 42 years old, planning family vacation, researching 3-4 tour operators
**Tech Savvy:** Moderate (expects consumer-grade digital experience)
**Pain Points:**
- Frustrated by slow responses from tour operators
- Difficult to compare options and track conversations
- Unclear about booking status and payment schedule
- Worried about making wrong choice

**Goals:**
- Get detailed information about tours quickly
- Feel confident in booking decision
- Have transparent view of booking status
- Communicate easily with tour operator

#### 4. David - System Administrator
**Background:** 30 years old, IT manager, responsible for business systems
**Tech Savvy:** Expert (wants control, security, reliability)
**Pain Points:**
- Managing multiple disconnected tools
- Data export/import challenges
- No single source of truth for customer data
- Security and compliance concerns

**Goals:**
- Maintain 99.9% system uptime
- Ensure data security and GDPR compliance
- Integrate with existing business tools
- Minimize support burden on IT team

### Secondary Personas (Phase 2 - SaaS)

#### 5. Amanda - Tour Operator Owner (SaaS Customer)
**Background:** 45 years old, owns boutique tour company with 3-10 employees
**Tech Savvy:** Moderate (wants simple, works-out-of-box solutions)
**Pain Points:**
- Can't afford expensive enterprise CRM systems
- Current tools don't fit tour operator workflow
- Needs quick setup without IT department
- Worried about vendor lock-in

**Goals:**
- Get up and running in < 1 week
- Pay reasonable monthly fee based on usage
- Access from anywhere (office, home, while traveling)
- Scale system as business grows

---

## 4. User Stories & Acceptance Criteria

### Epic 1: Lead Management

#### Story 1.1: Capture Lead from WhatsApp Message (Primary Flow)
```
As a Sales Agent,
I want leads to automatically enter the CRM when a customer messages our WhatsApp Business number,
So that I never miss a potential customer and have all conversation context.

Acceptance Criteria:
- Given a customer sends a WhatsApp message to our business number via wazzup24
- When the message is received via webhook
- Then a Client record is found or created by phone number
- And a new Lead is created linked to that Client with status "New"
- And the message is logged in the Client's communication history
- And the assigned agent receives a notification (in-app)
- And the lead source is tracked as "WhatsApp"
- And if this is a returning customer, their existing Client info is used
- And agent can see client's previous leads and bookings in sidebar

Definition of Done:
- [ ] Webhook endpoint created to receive wazzup24 messages
- [ ] Client find-or-create logic by phone number
- [ ] Lead record created with client_id reference
- [ ] Message content stored in Communication model (linked to Client)
- [ ] Lead assignment logic implemented (round-robin or manual)
- [ ] Notification system implemented
- [ ] Unit tests for client/lead creation from WhatsApp
- [ ] Integration test for wazzup24 webhook workflow
- [ ] Error handling for webhook failures
- [ ] Admin documentation for wazzup24 setup
```

#### Story 1.2: View Lead Details and Client History
```
As a Sales Agent,
I want to see all information about a lead and the client's full history in one place,
So that I can provide personalized service and leverage past interactions.

Acceptance Criteria:
- Given I am viewing a lead record
- When the lead detail page loads
- Then I see client contact information, tour interests, and communication history
- And I see this lead's current stage in the sales pipeline
- And I see client's previous leads (if returning customer)
- And I see client's previous bookings (if repeat customer)
- And all client communications are displayed chronologically
- And I can quickly identify if this is a repeat customer

Definition of Done:
- [ ] Lead detail page UI implemented with client context
- [ ] Client sidebar showing previous leads and bookings
- [ ] Data aggregation from Client, Lead, Booking, Communication tables
- [ ] Performance optimized (< 1s load time)
- [ ] Responsive design for mobile/tablet
- [ ] Unit tests for data aggregation logic
- [ ] Accessibility standards met (WCAG 2.1 AA)
```

#### Story 1.3: Assign Lead to Agent
```
As a Sales Manager,
I want to assign leads to specific agents based on workload and expertise,
So that leads are distributed fairly and handled by the best person.

Acceptance Criteria:
- Given I am viewing the leads list
- When I select one or more leads and assign to an agent
- Then the leads' assigned agent is updated
- And the agent receives a notification
- And the assignment is logged in the activity timeline
- And I can see lead distribution across team in dashboard

Definition of Done:
- [ ] Bulk assignment functionality implemented
- [ ] Notification system for assignments
- [ ] Activity logging for audit trail
- [ ] Dashboard widget showing distribution
- [ ] Unit tests for assignment logic
- [ ] Integration tests for notification delivery
```

### Epic 2: Booking Management

#### Story 2.1: Create Booking from Lead
```
As a Sales Agent,
I want to convert a lead into a booking with selected tour and customer details,
So that I can formalize the customer's commitment and begin the fulfillment process.

Acceptance Criteria:
- Given a lead has agreed to book a tour
- When I create a booking from the lead record
- Then a booking record is created with tour details, dates, and participants
- And the lead status changes to "Converted"
- And a booking confirmation email is sent to the customer
- And an invoice is generated for the deposit amount

Definition of Done:
- [ ] Booking creation form implemented
- [ ] Lead-to-booking conversion logic
- [ ] Status transition workflow
- [ ] Email template for confirmation
- [ ] Invoice generation integration
- [ ] Unit tests for booking creation
- [ ] Integration tests for email sending
```

#### Story 2.2: Track Booking Payments
```
As a Sales Agent,
I want to track deposit and final payment status for each booking,
So that I can follow up on overdue payments and confirm tour participation.

Acceptance Criteria:
- Given a booking exists with payment schedule
- When I view the booking details
- Then I see payment timeline (deposit due, deposit paid, balance due, balance paid)
- And overdue payments are highlighted
- And I can record a payment with date, amount, and method
- And payment reminders are automatically sent based on due dates

Definition of Done:
- [ ] Payment tracking data model implemented
- [ ] Payment schedule calculation logic
- [ ] Payment recording interface
- [ ] Automated reminder system
- [ ] Unit tests for payment calculations
- [ ] Integration tests for reminders
```

#### Story 2.3: Manage Tour Capacity
```
As a Sales Manager,
I want to see how many spots are booked vs available for each tour departure,
So that I can avoid overbooking and optimize tour profitability.

Acceptance Criteria:
- Given multiple bookings exist for a tour departure
- When I view the tour capacity dashboard
- Then I see total capacity, booked spots, and available spots
- And tours at >80% capacity are highlighted
- And I receive alerts when tours are nearing capacity
- And I can adjust capacity limits as needed

Definition of Done:
- [ ] Capacity calculation logic implemented
- [ ] Dashboard UI with capacity visualization
- [ ] Alert system for near-capacity tours
- [ ] Capacity adjustment interface
- [ ] Unit tests for capacity calculations
- [ ] Performance tests for large datasets
```

### Epic 3: Customer Communication

#### Story 3.1: Send WhatsApp Message to Customer from CRM (Primary)
```
As a Sales Agent,
I want to send WhatsApp messages to customers directly from the CRM,
So that all communications are tracked and I can respond in the customer's preferred channel.

Acceptance Criteria:
- Given I am viewing a lead or booking with phone number
- When I compose and send a WhatsApp message
- Then the message is sent via wazzup24 API
- And a copy is saved in the communication history
- And I can use WhatsApp message templates for common scenarios
- And customer replies are automatically captured via webhook
- And message status is tracked (sent, delivered, read)

Definition of Done:
- [ ] WhatsApp message composition interface (in lead/booking view)
- [ ] wazzup24 API integration for sending messages
- [ ] Communication history storage with message status
- [ ] WhatsApp message templates system (common responses)
- [ ] Message status webhooks (delivery receipts, read receipts)
- [ ] Unit tests for message sending
- [ ] Integration tests for wazzup24 API
- [ ] Error handling for API failures
```

#### Story 3.2: Reply to WhatsApp Message from CRM
```
As a Sales Agent,
I want to view incoming WhatsApp messages and reply directly in the CRM,
So that I never miss a message and have full conversation context.

Acceptance Criteria:
- Given a customer sends a WhatsApp message to our business number
- When the webhook delivers the message to the CRM
- Then I see a notification in the CRM
- And I can view the message in the lead's timeline
- And I can reply directly from the CRM interface
- And the reply is sent via wazzup24 and logged in timeline
- And I can see the full conversation history

Definition of Done:
- [ ] Real-time notification system for incoming messages (Turbo Streams)
- [ ] Conversation view UI with message threading
- [ ] Quick reply interface
- [ ] Conversation history display (chronological)
- [ ] Message read status tracking
- [ ] Unit tests for message handling
- [ ] Integration tests for end-to-end message flow
```

#### Story 3.3: Use WhatsApp Templates for Quick Responses
```
As a Sales Agent,
I want to use pre-written message templates for common responses,
So that I can respond quickly and consistently to customer inquiries.

Acceptance Criteria:
- Given I am replying to a customer on WhatsApp
- When I click "Use Template"
- Then I see a list of common response templates (greetings, pricing, availability, etc.)
- And I can select a template and it populates the message field
- And I can customize the template before sending
- And admins can create/edit templates

Definition of Done:
- [ ] Template library UI
- [ ] Template variables support (customer name, tour name, etc.)
- [ ] Template selection interface
- [ ] Admin interface for template management
- [ ] Unit tests for template rendering
```

#### Story 3.4: Email Customer from CRM (Secondary Channel)
```
As a Sales Agent,
I want to send emails to customers directly from the CRM for formal communications,
So that I can send booking confirmations, invoices, and detailed itineraries.

Acceptance Criteria:
- Given I am viewing a lead or booking with email address
- When I compose and send an email
- Then the email is sent to the customer's email address
- And a copy is saved in the communication history
- And I can use email templates for common scenarios (confirmation, invoice, etc.)

Definition of Done:
- [ ] Email composition interface
- [ ] Email sending integration (Action Mailer + SendGrid)
- [ ] Communication history storage
- [ ] Email templates system
- [ ] Unit tests for email sending
- [ ] Integration tests for email delivery
```

#### Story 3.5: Log Phone Call Notes
```
As a Sales Agent,
I want to quickly log notes after a phone call with a customer,
So that my colleagues and I remember the conversation details.

Acceptance Criteria:
- Given I just finished a phone call with a customer
- When I create a phone call log
- Then I can record date/time, duration, summary, and next steps
- And the log appears in the customer's timeline
- And if I set a follow-up task, it appears in my task list
- And call logs are searchable

Definition of Done:
- [ ] Phone call logging interface
- [ ] Timeline integration
- [ ] Task creation from logs
- [ ] Search functionality
- [ ] Unit tests for logging logic
- [ ] Mobile-responsive design
```

### Epic 4: Reporting & Analytics

#### Story 4.1: View Sales Pipeline Dashboard
```
As a Sales Manager,
I want a visual dashboard showing leads by stage and conversion rates,
So that I can identify bottlenecks and coach my team effectively.

Acceptance Criteria:
- Given leads exist in various stages
- When I view the sales pipeline dashboard
- Then I see a funnel visualization of leads by stage
- And conversion rates between stages
- And average time in each stage
- And I can filter by date range, agent, and tour type

Definition of Done:
- [ ] Pipeline visualization component
- [ ] Conversion rate calculation logic
- [ ] Stage duration analytics
- [ ] Filter functionality
- [ ] Unit tests for analytics calculations
- [ ] Performance optimization (< 2s load)
```

#### Story 4.2: Generate Revenue Report
```
As a Sales Manager,
I want to see revenue reports by tour, date range, and agent,
So that I can forecast revenue and identify top-performing offerings.

Acceptance Criteria:
- Given bookings exist with payment data
- When I generate a revenue report
- Then I see total revenue, revenue by tour, revenue by agent
- And revenue trends over time (daily, weekly, monthly)
- And I can export the report to CSV/Excel
- And I can schedule reports to be emailed automatically

Definition of Done:
- [ ] Revenue aggregation queries
- [ ] Report generation interface
- [ ] Data visualization (charts/graphs)
- [ ] Export functionality
- [ ] Scheduled reporting system
- [ ] Unit tests for revenue calculations
```

### Epic 5: Tour Catalog Management

#### Story 5.1: Create and Edit Tours
```
As a Tour Manager,
I want to create tour listings with details, pricing, and schedules,
So that sales agents have accurate information when speaking with customers.

Acceptance Criteria:
- Given I have tour details to add to the system
- When I create a tour
- Then I can specify name, description, duration, inclusions, pricing tiers
- And I can add multiple departure dates with specific capacity
- And I can upload photos and documents
- And changes are immediately available to sales agents

Definition of Done:
- [ ] Tour creation/editing form
- [ ] File upload functionality
- [ ] Pricing tiers support
- [ ] Departure schedule management
- [ ] Unit tests for tour CRUD operations
- [ ] Image optimization and storage
```

---

## 5. Functional Requirements

### Must Have (MVP - Phase 1)

#### 5.1 Client Management
- **FR-1.1:** Create Client record automatically from WhatsApp messages (find-or-create by phone)
- **FR-1.2:** Store client contact information (phone, name, email, preferred language)
- **FR-1.3:** View client lifetime history (all leads, bookings, communications)
- **FR-1.4:** Detect duplicate clients by phone number (unique constraint)
- **FR-1.5:** Support manual client creation and CSV import
- **FR-1.6:** Track client notes and internal comments

#### 5.2 Lead Management
- **FR-2.1:** Create Lead linked to Client when customer inquires via WhatsApp webhook (primary source)
- **FR-2.2:** Create Lead manually for phone/email inquiries (secondary sources)
- **FR-2.3:** Assign leads to sales agents (manual or automatic round-robin)
- **FR-2.4:** Track lead status through pipeline stages (New → Contacted → Qualified → Quoted → Won/Lost)
- **FR-2.5:** Search and filter leads by status, source, date, assigned agent, client info
- **FR-2.6:** View lead details with client context (past leads, bookings, communications)
- **FR-2.7:** Support returning customers creating new leads for new inquiries
- **FR-2.8:** Track which tour the lead is interested in

#### 5.3 Booking Management
- **FR-3.1:** Convert lead to booking linked to Client and Lead
- **FR-3.2:** Support direct booking creation for repeat customers (optional lead reference)
- **FR-3.3:** Record booking details (tour, dates, number of participants, special requests)
- **FR-3.4:** Generate booking confirmation with unique reference number
- **FR-3.5:** Track booking status (Confirmed → Paid → Completed → Cancelled)
- **FR-3.6:** Support group bookings with multiple participants
- **FR-3.7:** View client's booking history (all past and future bookings)

#### 5.4 Payment Tracking
- **FR-4.1:** Define payment schedules (deposit %, balance %, due dates)
- **FR-4.2:** Record payments manually (date, amount, method)
- **FR-4.3:** Calculate outstanding balances automatically
- **FR-4.4:** Flag overdue payments for follow-up
- **FR-4.5:** Generate invoices and receipts (PDF)

#### 5.5 Customer Communication (WhatsApp-First)
- **FR-5.1:** Send WhatsApp messages from CRM via wazzup24 API to Client
- **FR-5.2:** Receive WhatsApp messages via webhook and link to Client
- **FR-5.3:** View complete WhatsApp conversation history per Client (across all leads/bookings)
- **FR-5.4:** Use WhatsApp message templates for common scenarios (greeting, pricing, availability, confirmation)
- **FR-5.5:** Track WhatsApp message status (sent, delivered, read)
- **FR-5.6:** Real-time notifications for incoming WhatsApp messages (Turbo Streams)
- **FR-5.7:** Send emails from CRM for formal communications (secondary channel)
- **FR-5.8:** Use email templates for confirmations, invoices, itineraries
- **FR-5.9:** Log phone calls with notes and follow-up tasks
- **FR-5.10:** View all client communications (WhatsApp, email, phone) in unified timeline
- **FR-5.11:** Set reminders for follow-ups
- **FR-5.12:** Link communications to Lead and/or Booking for context

#### 5.6 Tour Catalog
- **FR-6.1:** Create tour listings (name, description, itinerary, inclusions, exclusions)
- **FR-6.2:** Define pricing (base price, seasonal pricing, group discounts) in multiple currencies (USD, KZT, EUR, RUB)
- **FR-6.3:** Set departure dates with capacity limits
- **FR-6.4:** Upload tour images and documents
- **FR-6.5:** Mark tours as active/inactive

#### 5.7 Reporting
- **FR-7.1:** Sales pipeline report (leads by stage, conversion rates)
- **FR-7.2:** Revenue report (by tour, by agent, by date range)
- **FR-7.3:** Booking report (upcoming departures, capacity utilization)
- **FR-7.4:** Agent performance report (conversions, revenue, response time)
- **FR-7.5:** Export reports to CSV/Excel
- **FR-7.6:** Client lifetime value report (total bookings and revenue per client)

#### 5.8 User Management
- **FR-8.1:** User authentication (email/password login)
- **FR-8.2:** Role-based access control (Admin, Manager, Agent)
- **FR-8.3:** User profiles with contact information
- **FR-8.4:** Activity logging (who did what, when)
- **FR-8.5:** User language preference (Russian/English)
- **FR-8.6:** User currency preference (USD/KZT/EUR/RUB)

#### 5.9 Localization & Multi-Currency (Phase 1)
- **FR-9.1:** Full UI in Russian and English (switchable)
- **FR-9.2:** All user-facing content translated (emails, WhatsApp templates, reports)
- **FR-9.3:** Multi-currency support for tours and bookings (USD, KZT, EUR, RUB)
- **FR-9.4:** Currency symbols and formatting ($ USD, ₸ KZT, € EUR, ₽ RUB)
- **FR-9.5:** Date format localization (DD.MM.YYYY for Russian, MM/DD/YYYY for English)
- **FR-9.6:** Timezone support with UTC storage
- **FR-9.7:** Store client's preferred language for personalized communications

### Should Have (Phase 1 Enhancement)

#### 5.9 Advanced Communication
- **FR-9.1:** WhatsApp broadcast messages (send to multiple customers at once)
- **FR-9.2:** Automated WhatsApp message sequences (nurture campaigns, follow-up reminders)
- **FR-9.3:** WhatsApp chatbot for basic inquiries (FAQ responses)
- **FR-9.4:** Email reply capture (inbound emails linked to customer records)
- **FR-9.5:** SMS notifications for customers without WhatsApp (booking confirmations, reminders)
- **FR-9.6:** Rich media support in WhatsApp (images, videos, PDFs for tour brochures)
- **FR-9.7:** WhatsApp quick replies (predefined response buttons)

#### 5.10 Advanced Booking
- **FR-10.1:** Waitlist management for fully-booked tours
- **FR-10.2:** Booking modifications (date changes, participant changes)
- **FR-10.3:** Cancellation handling with refund policies
- **FR-10.4:** Upsell opportunities (additional services, upgrades)

#### 5.11 Advanced Analytics
- **FR-11.1:** Revenue forecasting based on pipeline
- **FR-11.2:** Customer lifetime value calculation
- **FR-11.3:** Lead source ROI analysis
- **FR-11.4:** Tour profitability analysis

### Could Have (Phase 2 - SaaS)

#### 5.12 Multi-Tenancy
- **FR-12.1:** Support multiple tour operator accounts (tenants)
- **FR-12.2:** Data isolation between tenants
- **FR-12.3:** Tenant-specific branding (logo, colors)
- **FR-12.4:** Tenant usage analytics

#### 5.13 Self-Service Onboarding
- **FR-13.1:** Self-service account creation
- **FR-13.2:** Guided onboarding wizard
- **FR-13.3:** Sample data for trial accounts
- **FR-13.4:** In-app tutorials and help docs

#### 5.14 Integration Marketplace
- **FR-14.1:** Payment gateway integrations (Stripe, PayPal)
- **FR-14.2:** Accounting software integrations (QuickBooks, Xero)
- **FR-14.3:** Marketing tool integrations (Mailchimp, HubSpot)
- **FR-14.4:** Calendar integrations (Google Calendar, Outlook)

#### 5.15 Advanced Features
- **FR-15.1:** Customer portal (self-service booking status, document download)
- **FR-15.2:** Dynamic pricing engine (demand-based pricing)
- **FR-15.3:** ~~Multi-language support~~ **Implemented in Phase 1** (Russian & English)
- **FR-15.4:** ~~Multi-currency support~~ **Implemented in Phase 1** (USD, KZT, EUR, RUB)
- **FR-15.5:** Additional languages beyond Russian/English (Spanish, French, Arabic)
- **FR-15.6:** Exchange rate API integration for automatic currency conversion

### Won't Have (Out of Scope)

- **FR-16.1:** Supplier management (managing relationships with hotels, transport providers)
- **FR-16.2:** Operations management (tour guide scheduling, vehicle tracking)
- **FR-16.3:** Detailed accounting/bookkeeping (beyond invoice generation)
- **FR-16.4:** Website builder for tour operators
- **FR-16.5:** Social media management tools

---

## 6. Non-Functional Requirements

### 6.1 Performance

**NFR-1.1: Page Load Time**
- Target: < 2 seconds for all pages on standard broadband
- Maximum: < 4 seconds for complex reports/dashboards
- Measurement: P95 load time tracked via RUM (Real User Monitoring)

**NFR-1.2: API Response Time**
- Target: < 500ms for 95% of API requests
- Maximum: < 2 seconds for complex queries
- Measurement: Server-side timing logs, APM monitoring

**NFR-1.3: Database Query Performance**
- Target: < 100ms for single record queries
- Maximum: < 1s for complex aggregation queries
- Measurement: Active Record query logging, database profiling

**NFR-1.4: Concurrent Users**
- Phase 1: Support 50 concurrent users (internal team)
- Phase 2: Support 1,000 concurrent users (SaaS)
- Test: Load testing with realistic user scenarios

**NFR-1.5: Data Volume**
- Phase 1: Support 10,000 leads, 5,000 bookings
- Phase 2: Support 1M+ leads, 500K+ bookings per tenant
- Strategy: Database indexing, query optimization, archival strategy

### 6.2 Security

**NFR-2.1: Authentication**
- Email/password authentication with bcrypt hashing (min cost factor 12)
- Session management with secure, HTTP-only cookies
- Password requirements: min 12 characters, complexity rules
- Account lockout after 5 failed login attempts
- Password reset via secure email token (expires in 1 hour)

**NFR-2.2: Authorization**
- Role-based access control (RBAC) with 3 levels: Admin, Manager, Agent
- Fine-grained permissions for sensitive operations
- All actions logged for audit trail
- Admin-only access to system settings and user management

**NFR-2.3: Data Encryption**
- All data encrypted in transit (TLS 1.3)
- Sensitive data encrypted at rest (AES-256)
- PCI DSS compliance for payment data (if storing cards)
- Encryption key rotation every 90 days

**NFR-2.4: Privacy & Compliance**
- GDPR compliance (data portability, right to deletion, consent management)
- Data retention policies (automatic deletion after specified period)
- Privacy policy and terms of service
- Cookie consent management

**NFR-2.5: Security Headers**
- Content Security Policy (CSP) to prevent XSS
- CSRF protection on all state-changing requests
- Secure headers (X-Frame-Options, X-Content-Type-Options, etc.)
- Rate limiting to prevent abuse (100 req/min per IP)

### 6.3 Reliability & Availability

**NFR-3.1: Uptime**
- Phase 1: 99.5% uptime (< 3.6 hours downtime/month)
- Phase 2: 99.9% uptime (< 43 minutes downtime/month)
- Scheduled maintenance windows: Sunday 2-4am (with 7 days notice)

**NFR-3.2: Backup & Recovery**
- Automated daily database backups (retained for 30 days)
- Point-in-time recovery capability (up to 7 days)
- Disaster recovery plan with RTO (Recovery Time Objective) < 4 hours
- RPO (Recovery Point Objective) < 1 hour (max data loss)

**NFR-3.3: Error Handling**
- Graceful degradation for non-critical features
- User-friendly error messages (no stack traces exposed)
- Automatic error logging and alerting
- Error rate threshold: < 0.5% of requests

**NFR-3.4: Monitoring & Alerting**
- Application performance monitoring (APM)
- Server health monitoring (CPU, memory, disk)
- Alert notifications via email/Slack for critical issues
- On-call rotation for 24/7 incident response (Phase 2)

### 6.4 Scalability

**NFR-4.1: Horizontal Scaling**
- Stateless application servers (can add/remove servers dynamically)
- Database read replicas for read-heavy workloads
- Background job processing with queue system (Sidekiq)
- Auto-scaling based on CPU/memory thresholds (Phase 2)

**NFR-4.2: Caching Strategy**
- Page caching for static content (CDN)
- Fragment caching for expensive views
- Query result caching (Redis) for common queries
- Cache invalidation strategy to prevent stale data

**NFR-4.3: Database Scaling**
- Database connection pooling
- Efficient indexing strategy for common queries
- Partitioning strategy for large tables (Phase 2)
- Archive old data to separate tables/database

### 6.5 Usability & Accessibility

**NFR-5.1: Browser Support**
- Chrome (last 2 versions)
- Firefox (last 2 versions)
- Safari (last 2 versions)
- Edge (last 2 versions)
- Mobile browsers (iOS Safari, Chrome Android)

**NFR-5.2: Responsive Design**
- Mobile-first design approach
- Optimized for phone (320px+), tablet (768px+), desktop (1024px+)
- Touch-friendly interface elements (min 44px tap targets)

**NFR-5.3: Accessibility**
- WCAG 2.1 Level AA compliance
- Keyboard navigation support
- Screen reader compatibility
- Color contrast ratios meeting accessibility standards
- Alt text for all images

**NFR-5.4: User Experience**
- Consistent UI patterns throughout application
- Clear visual hierarchy and information architecture
- Minimal clicks to complete common tasks (< 3 clicks)
- Loading indicators for operations > 1 second
- Undo functionality for destructive actions

### 6.6 Maintainability

**NFR-6.1: Code Quality**
- Rubocop for Ruby style enforcement
- Code coverage > 80% for critical paths
- Pull request reviews required before merge
- Automated CI/CD pipeline

**NFR-6.2: Documentation**
- API documentation (OpenAPI/Swagger)
- Admin documentation for system configuration
- Developer documentation for setup and contribution
- User help documentation and FAQs

**NFR-6.3: Logging**
- Structured logging (JSON format)
- Log levels: DEBUG, INFO, WARN, ERROR
- Personally Identifiable Information (PII) redacted from logs
- Log retention: 90 days

### 6.7 Localization

**NFR-7.1: Language Support**
- Phase 1: Russian and English (default languages)
  - Full UI translation for both languages
  - User can switch language in settings
  - System defaults to Russian for Kazakhstan/Russia region, English otherwise
  - Externalized strings using Rails I18n framework
  - All user-facing text, emails, and WhatsApp templates in both languages
- Phase 2: Additional languages (Spanish, French) for international expansion
- Right-to-left (RTL) layout support (future, for Arabic markets)

**NFR-7.2: Date/Time**
- All dates/times stored in UTC
- Display in user's timezone
- Configurable date format preferences
- Support for multiple date formats (DD.MM.YYYY for Russian, MM/DD/YYYY for English)

**NFR-7.3: Currency Support**
- Phase 1: Multi-currency support (USD, KZT, EUR, RUB)
  - Tours can be priced in any of the 4 currencies
  - Payments tracked in original currency
  - Currency symbol display ($ USD, ₸ KZT, € EUR, ₽ RUB)
  - No automatic exchange rate conversion in Phase 1 (manual pricing per currency)
  - User can set preferred display currency
  - Invoices and booking confirmations show prices in booking currency
- Phase 2: Exchange rate API integration for automatic conversion
- Configurable per tenant (SaaS phase)

---

## 7. Technical Considerations

### Key Technical Decisions Summary

**Rails 8 Modern Stack Philosophy:**
This project embraces Rails 8's "no infrastructure" approach, using the Solid gems (SolidQueue, SolidCache, SolidCable) to eliminate external dependencies like Redis and Sidekiq. We start with SQLite3 for simplicity and migrate to PostgreSQL only when multi-tenant scaling requires it.

**Core Stack:**
- **Framework:** Rails 8.0+ with Hotwire (Turbo + Stimulus)
- **Database:** SQLite3 → PostgreSQL (Phase 1 → Phase 2)
- **Jobs/Cache/Cables:** Solid gems (database-backed, zero infrastructure)
- **Authentication:** Rails 8 built-in (`rails g authentication`)
- **Deployment:** Kamal 2 (zero-downtime Docker deployments)

**Benefits:**
- ✅ Dramatically simpler deployment (no Redis, no Sidekiq, no PostgreSQL initially)
- ✅ Lower costs (~$50-150/month vs $200-500/month)
- ✅ Faster development (fewer moving parts, Rails conventions)
- ✅ Easy scaling path (migrate to PostgreSQL when needed)

---

### 7.1 Technology Stack

**Backend:**
- **Framework:** Ruby on Rails 8.0+ (modern, productive, convention-over-configuration)
- **Language:** Ruby 3.3+
- **Database:**
  - **Phase 1 (Internal):** SQLite3 (Rails 8 default, simple, zero-config, perfect for internal use)
  - **Phase 2 (SaaS):** PostgreSQL 16+ or MySQL 8.4+ (when scaling to multi-tenant requires advanced features)
  - **Rationale:** Start simple with SQLite3, migrate to PostgreSQL/MySQL only when truly needed for scale
- **Caching:** SolidCache (Rails 8 solid gem, database-backed, no Redis needed)
- **Background Jobs:** SolidQueue (Rails 8 solid gem, database-backed job queue)
  - Use for: Email sending, report generation, external API calls (Stripe, etc.)
  - Benefits: No additional infrastructure (Redis/Sidekiq), simpler deployment
- **WebSockets:** SolidCable (Rails 8 solid gem for real-time features)
- **Search:** Database full-text search (SQLite FTS5 or PostgreSQL), Elasticsearch only if truly needed

**Frontend:**
- **Framework:** Hotwire (Turbo + Stimulus) - Rails 8 default, minimal JavaScript
  - Turbo Streams for real-time updates (e.g., live dashboard updates)
  - Stimulus for targeted JavaScript behavior
  - Turbo Frames for lazy-loaded sections
- **CSS:** Tailwind CSS 3+ (utility-first, rapid UI development)
- **Charts:** Chartkick + Chart.js (for dashboards and reports)
- **Icons:** Heroicons (clean, consistent icon set)

**Infrastructure:**
- **Hosting:** Cloud provider (AWS, DigitalOcean, Hetzner, or Fly.io)
- **Deployment:** Kamal 2 (Rails 8 default deployment tool, zero-downtime deploys)
- **Containers:** Docker (for consistent environments)
- **CDN:** CloudFlare (static assets, DDoS protection)
- **Email:** Action Mailer with SendGrid or Postmark (transactional email delivery)
- **File Storage:**
  - ActiveStorage with local disk (Phase 1, simple)
  - ActiveStorage with S3/R2 (Phase 2, when scaling)
- **Monitoring:** Sentry (error tracking), Honeybadger, or AppSignal (APM)

**Stack Philosophy:**
- **Start Simple:** Use Rails 8's "Solid" gems (SolidQueue, SolidCache, SolidCable) to eliminate Redis dependency
- **Scale Gradually:** Migrate to PostgreSQL + Redis only when SQLite3 becomes a bottleneck
- **Avoid Premature Optimization:** Don't add complexity (microservices, separate cache servers) until proven necessary
- **Embrace Rails Conventions:** Leverage Rails 8 defaults for maximum productivity

### 7.2 Architecture Patterns

**Monolithic Architecture (Phase 1):**
- Single Rails application with modular structure
- Clear domain boundaries (Leads, Bookings, Payments, Tours)
- Service objects for complex business logic
- Use Rails engines if needed for modularity

**Multi-Tenant Architecture (Phase 2):**
- Migration from SQLite3 to PostgreSQL when scaling to multi-tenant
- Shared database with tenant_id isolation (row-level security)
- Use acts_as_tenant or custom Current.tenant pattern
- Database-per-tenant considered only for enterprise tier (if needed)
- Decision factors: Scale requirements, data isolation needs, cost
- Recommended approach:
  1. Start with SQLite3 (Phase 1, single tenant)
  2. Migrate to PostgreSQL with tenant_id column (Phase 2, 10-100 tenants)
  3. Consider database-per-tenant only if needed (100+ tenants or compliance requirements)

**API Design:**
- RESTful API conventions
- JSON:API or standard Rails JSON serialization
- API versioning (/api/v1/...) from day one
- Rate limiting with rack-attack

### 7.3 Data Model (Core Entities)

**Client-Centric Architecture:**

This data model separates the lifetime customer relationship (Client) from sales opportunities (Lead):
- **Client** = The person (permanent, identified by phone)
- **Lead** = A sales inquiry (temporary, moves through pipeline)
- **Booking** = A confirmed purchase (linked to Client, optionally to Lead)

**Key Models:**
```
User
- id, email, password_digest, role, name, preferred_language (en/ru), preferred_currency (USD/KZT/EUR/RUB)
- created_at, updated_at
- Note: Language and currency preferences for UI display

Client
- id, name, phone, email, preferred_language, notes
- created_at, updated_at
- Index: phone (unique, for WhatsApp identification and duplicate prevention)
- Note: Represents the actual customer (lifetime relationship)
- Business Logic: Find-or-create by phone when WhatsApp message arrives

Lead
- id, client_id, status, source, assigned_agent_id, tour_interest_id
- last_message_at, unread_messages_count
- created_at, updated_at
- Note: Represents a sales opportunity/inquiry
- Business Logic: Client can have many Leads over time (repeat inquiries)
- Index: client_id, status, assigned_agent_id

Booking
- id, client_id, lead_id, tour_departure_id, status, num_participants, total_amount, currency (USD/KZT/EUR/RUB)
- created_at, updated_at
- Note: Currency inherited from tour_departure, locked at booking creation
- Business Logic: Client can have many Bookings (repeat purchases)
- Business Logic: lead_id is optional (bookings can exist without leads for walk-ins)
- Index: client_id, lead_id

Payment
- id, booking_id, amount, currency (USD/KZT/EUR/RUB), payment_date, payment_method, status
- created_at, updated_at
- Note: Payments recorded in the currency used for the booking

Tour
- id, name, description, base_price, currency (USD/KZT/EUR/RUB), duration_days, capacity, active
- created_at, updated_at
- Note: Each tour has a default currency, but departures can override pricing

TourDeparture
- id, tour_id, departure_date, capacity, price, currency (USD/KZT/EUR/RUB)
- created_at, updated_at
- Note: Currency can differ from tour's base currency for flexible pricing

Communication
- id, client_id, lead_id, booking_id
- type (whatsapp, email, phone, sms), subject, body, direction (inbound/outbound)
- whatsapp_message_id, whatsapp_status (sent, delivered, read, failed)
- media_url, media_type (for WhatsApp images, documents, etc.)
- created_at, updated_at
- Index: client_id, whatsapp_message_id
- Note: All communications belong to Client (lifetime history)
- Note: lead_id and booking_id are optional context references

WhatsappTemplate
- id, name, content, variables (JSON array), category, active, created_at, updated_at
- Example: "Hello {{name}}, thank you for your inquiry about {{tour_name}}..."

Activity
- id, actor_id (User), subject_type, subject_id (polymorphic), action, metadata, created_at
```

**Relationships:**
- Client has_many Leads (repeat inquiries)
- Client has_many Bookings (repeat purchases)
- Client has_many Communications (lifetime history)
- Lead belongs_to Client
- Lead belongs_to Agent (User)
- Booking belongs_to Client
- Booking belongs_to Lead (optional - for conversion tracking)
- Booking belongs_to TourDeparture
- Payment belongs_to Booking
- TourDeparture belongs_to Tour
- Communication belongs_to Client (required)
- Communication belongs_to Lead (optional - inquiry context)
- Communication belongs_to Booking (optional - booking context)
- Activity tracks all changes (audit log)

### 7.4 Integration Points

**Phase 1 (Must Have):**
- **wazzup24 WhatsApp API** (PRIMARY - core functionality)
  - Webhook for receiving incoming messages
  - REST API for sending outgoing messages
  - Message status webhooks (sent, delivered, read)
  - Authentication: API key in headers
  - Rate limits: Monitor and handle gracefully
  - Endpoints:
    - `POST /api/v3/messages` - Send message
    - Webhook: `POST /webhooks/wazzup24` - Receive messages
  - Message types: Text, media (images, documents), templates
  - Documentation: https://wazzup24.com/help/api-en/
- **Email:** Action Mailer with SendGrid API (sending transactional emails - secondary channel)
- **PDF Generation:** Prawn gem (invoices, receipts, booking confirmations)
- **File Upload:** ActiveStorage with local disk (Phase 1) or S3/R2 (Phase 2)

**Phase 2 (Scale & Enhance):**
- **Payment Gateways:** Stripe API (credit card processing)
- **Accounting:** QuickBooks API or Xero API (invoice sync)
- **SMS:** Twilio API (SMS notifications for customers without WhatsApp)
- **Calendar:** Google Calendar API (tour schedule sync)

### 7.5 Localization & Currency Implementation

**Internationalization (I18n):**
- Use Rails I18n framework for all text translations
- Directory structure: `config/locales/[en|ru]/[model|views|controllers].yml`
- Locale files for: UI text, email templates, WhatsApp message templates, error messages, validation messages
- User locale detection: Check user preference → Browser accept-language header → Default to Russian
- Locale switching: User settings preference stored in database
- Translation keys organized by namespace (e.g., `leads.new.title`, `bookings.confirmation.message`)

**Multi-Currency Support:**
- Store currency as enum/string field: 'USD', 'KZT', 'EUR', 'RUB'
- Use Money gem for currency calculations and formatting
- Database storage: Store amounts as decimal(10,2) with separate currency field
- No automatic exchange rate conversion in Phase 1 (manual pricing per currency)
- Currency helper methods for display:
  - `format_currency(amount, currency)` → "₸ 150,000" or "$ 1,000"
  - Handle different decimal separators (. for USD/EUR, , for some locales)
- Reports and analytics: Filter/group by currency (no mixing currencies without conversion)

**Technical Implementation:**
```ruby
# Example currency storage
class Tour < ApplicationRecord
  monetize :base_price_cents, with_currency: :currency
  enum currency: { USD: 'USD', KZT: 'KZT', EUR: 'EUR', RUB: 'RUB' }
end

# Example I18n usage
I18n.t('leads.status.new') # => "Новый" (ru) or "New" (en)
```

### 7.6 Security Considerations

**Authentication:**
- Rails 8 built-in authentication (`rails g authentication`)
  - Modern, lightweight, fully integrated with Rails
  - Session-based auth with secure cookies
  - Password reset flow included
  - No external gem dependencies (Devise, Clearance, etc.)
- Session-based auth (Phase 1), JWT option (Phase 2 API)
- 2FA support (future enhancement using ROTP gem)

**Authorization:**
- Pundit gem for authorization policies (clean, policy-based approach)
- Role-based permissions (Admin, Manager, Agent)
- Object-level permissions (agents can only see their leads)
- Policy-based access control for all actions

**Input Validation:**
- Strong parameters for all controller inputs
- Model validations for data integrity
- Sanitize all user-generated content (prevent XSS)

**SQL Injection Prevention:**
- Use ActiveRecord parameterized queries (built-in protection)
- Avoid raw SQL unless necessary
- Use Brakeman for static security analysis

### 7.7 Testing Strategy

**Test Coverage:**
- Unit tests (RSpec): Models, services, helpers (> 90% coverage)
- Integration tests (RSpec + Capybara): User flows (> 80% coverage)
- System tests: Critical user journeys (booking flow, payment flow)
- Performance tests: Load testing critical endpoints

**CI/CD Pipeline:**
- GitHub Actions or GitLab CI
- Run tests on every pull request
- Automated deployment to staging on merge to main
- Manual deployment to production with approval

### 7.8 Performance Optimization

**Database Optimization:**
- Eager loading (includes, preload) to prevent N+1 queries
- Database indexes on foreign keys and frequently queried columns
- Materialized views for complex reports (if needed)
- Database query monitoring (rack-mini-profiler in dev)

**Caching Strategy:**
- SolidCache for application-level caching (database-backed, no Redis needed)
- Fragment caching for tour listings and frequently accessed views
- Russian Doll caching for nested partials (customers, bookings)
- HTTP caching headers for static content (max-age, etags)
- Page caching with Turbo for static-ish pages
- Use `Rails.cache` methods backed by SolidCache

**Background Processing:**
- SolidQueue for all background jobs (email sending, report generation, API syncs)
  - Database-backed job queue (no Redis/Sidekiq infrastructure)
  - Built-in retry with exponential backoff
  - Job priorities for urgent vs normal tasks
  - Web UI for monitoring jobs (via Mission Control)
- Move slow operations to background jobs:
  - Email sending (transactional, bulk)
  - Report generation (CSV exports, analytics)
  - External API calls (Stripe sync, payment webhooks)
  - Data imports (bulk lead uploads)

---

## 8. Dependencies & Assumptions

### 8.1 Dependencies

**Technical Dependencies:**

**Phase 1 (Minimal Infrastructure):**
- Ruby 3.3+ runtime environment
- SQLite3 (comes with Rails, zero additional setup)
- SMTP service for email delivery (SendGrid or equivalent)
- SSL certificate for HTTPS
- Docker for deployment (Kamal 2)

**Phase 2 (Scale-Ready Infrastructure):**
- PostgreSQL 16+ or MySQL 8.4+ (when multi-tenant scaling required)
- Cloud storage service (S3 or CloudFlare R2) for user uploads
- Redis (optional, only if SolidCache becomes bottleneck)

**Note:** Rails 8's Solid gems (SolidQueue, SolidCache, SolidCable) eliminate need for Redis, Sidekiq, and other external services in Phase 1, dramatically simplifying deployment and reducing operational costs.

**Team Dependencies:**
- Ruby on Rails developers (2-3 developers for MVP)
- UI/UX designer (part-time for Phase 1)
- Sales team availability for user testing and feedback
- Product owner for requirements clarification and prioritization

**Business Dependencies:**
- Internal sales team willing to adopt new system
- Budget for cloud hosting and third-party services (~$50-150/month Phase 1)
  - Significantly reduced due to no Redis/Sidekiq infrastructure
  - Single server deployment possible with SQLite3
- Domain name and email sending infrastructure
- Legal review for privacy policy and terms of service

**Third-Party Service Dependencies:**
- Email delivery service uptime and deliverability
- Cloud hosting provider reliability
- Payment gateway availability (Phase 2)

### 8.2 Assumptions

**User Assumptions:**
- Users have reliable internet connection (broadband or 4G)
- Users have modern web browsers (Chrome, Firefox, Safari, Edge)
- Sales agents are willing to enter data into system daily
- Sales managers will use reports for decision-making
- Customers are comfortable with email communication

**Business Assumptions:**
- Current tour sales process is representative of industry norms
- Tour sales volume will grow 20-30% year-over-year
- Market demand exists for tour operator CRM (validated in Phase 1)
- Pricing model ($50-200/user/month) is acceptable to target market
- Customers prefer all-in-one solution over best-of-breed integrations

**Technical Assumptions:**
- Rails 8 and Hotwire are suitable for building interactive CRM
- SQLite3 is sufficient for Phase 1 internal use (15 users, expected load)
- Single-tenant architecture is sufficient for Phase 1
- Migration path from SQLite3 to PostgreSQL is straightforward when needed
- SolidQueue/SolidCache/SolidCable perform adequately for internal workload
- Shared database multi-tenancy with PostgreSQL is viable for SaaS (Phase 2)
- Cloud hosting costs remain stable and predictable
- Single-server deployment handles Phase 1 load (can scale horizontally later)

**Regulatory Assumptions:**
- GDPR compliance strategy is sufficient for EU customers
- No special industry regulations for tour operators (verify per region)
- Standard business insurance covers SaaS operations
- Terms of service protect company from liability for customer disputes

---

## 9. Risk Assessment

### High Impact, High Probability Risks

**Risk 9.1: User Adoption Resistance**
- **Description:** Sales team resists using new system, continues with spreadsheets
- **Impact:** Product failure, wasted development effort
- **Probability:** 40%
- **Mitigation:**
  - Involve sales team in design process from day one
  - Prioritize features that reduce their pain points first
  - Provide hands-on training and ongoing support
  - Assign champions within sales team to advocate
  - Make system easier to use than current workflow
- **Contingency:** Gather feedback, iterate rapidly, consider incentives for adoption

**Risk 9.2: Data Migration Challenges**
- **Description:** Difficulty migrating existing customer data from spreadsheets to CRM
- **Impact:** Incomplete data, duplicate records, lost information
- **Probability:** 50%
- **Mitigation:**
  - Build robust import tools with validation and duplicate detection
  - Perform data cleanup before migration
  - Parallel run old and new systems during transition
  - Assign data quality champion
- **Contingency:** Manual data entry support, gradual migration approach

### High Impact, Low Probability Risks

**Risk 9.3: Data Breach / Security Incident**
- **Description:** Customer data compromised due to security vulnerability
- **Impact:** Reputation damage, legal liability, customer loss
- **Probability:** 10%
- **Mitigation:**
  - Security best practices from day one
  - Regular security audits and penetration testing
  - Incident response plan documented and practiced
  - Cyber insurance policy
  - Minimize data retention (delete old data)
- **Contingency:** Incident response team, legal counsel, customer notification plan

**Risk 9.4: Key Developer Departure**
- **Description:** Lead developer leaves project mid-development
- **Impact:** Project delay, knowledge loss, quality degradation
- **Probability:** 15%
- **Mitigation:**
  - Code reviews ensure knowledge sharing
  - Comprehensive documentation
  - Pair programming for critical features
  - Cross-training team members
- **Contingency:** Hire replacement quickly, prioritize knowledge transfer

### Medium Impact, High Probability Risks

**Risk 9.5: Scope Creep**
- **Description:** Stakeholders request additional features beyond MVP scope
- **Impact:** Timeline delay, budget overrun, team burnout
- **Probability:** 60%
- **Mitigation:**
  - Clearly defined MVP scope in writing
  - Product owner enforces prioritization
  - Feature request process with evaluation criteria
  - Regular scope reviews with stakeholders
- **Contingency:** Re-prioritize features, extend timeline if necessary, say "no" to non-critical requests

**Risk 9.6: Performance Issues at Scale**
- **Description:** System slows down as data volume grows beyond expectations
- **Impact:** Poor user experience, customer churn (Phase 2)
- **Probability:** 40%
- **Mitigation:**
  - Performance testing throughout development
  - Database query optimization and indexing
  - Caching strategy from day one
  - Scalability planning in architecture
- **Contingency:** Performance audit, database optimization, scaling infrastructure

**Risk 9.7: Integration Complexity**
- **Description:** Third-party integrations (email, payment, accounting) more complex than anticipated
- **Impact:** Timeline delay, reduced functionality
- **Probability:** 50%
- **Mitigation:**
  - Research APIs thoroughly before committing
  - Build integration layer with abstraction (easy to swap)
  - Use well-maintained gems/libraries
  - Budget extra time for integration testing
- **Contingency:** Simplify integration scope, use webhooks instead of real-time sync

### Low Impact, Variable Probability Risks

**Risk 9.8: Cloud Provider Outage**
- **Description:** Hosting provider experiences extended downtime
- **Impact:** System unavailable for hours
- **Probability:** 20%
- **Mitigation:**
  - Choose reliable provider with good SLA
  - Multi-region deployment (Phase 2)
  - Status page to communicate outages
- **Contingency:** Failover to backup provider (Phase 2), communicate transparently with users

**Risk 9.9: Market Competition**
- **Description:** Competitor launches similar product before Phase 2
- **Impact:** Reduced market opportunity, pricing pressure
- **Probability:** 30%
- **Mitigation:**
  - Focus on tour operator-specific features competitors lack
  - Build strong relationship with customers
  - Rapid iteration and feature development
  - Competitive pricing
- **Contingency:** Differentiate through customer service, niche down to specific tour segments

---

## 10. Success Metrics & KPIs

### 10.1 Phase 1: Internal Service (6 Months Post-Launch)

#### Product Adoption Metrics
- **User Adoption Rate:** 100% of sales team actively using system weekly
  - Measurement: Active user logins per week
  - Target: 15/15 users (100%)

- **Feature Utilization:** Core features used regularly
  - Lead management: 95% of leads entered in CRM (not spreadsheets)
  - Booking management: 100% of bookings tracked in CRM
  - Communication logging: 80% of customer interactions logged
  - Reporting: Managers view dashboard 3+ times per week

- **Data Quality:** Accurate, complete records
  - Lead completeness: 90% of leads have all required fields
  - Booking accuracy: <1% error rate in booking details
  - Payment tracking: 100% of payments recorded within 24 hours

#### Business Impact Metrics
- **Efficiency Gains:**
  - Booking processing time: 45 min → 25 min (44% reduction) ✓
  - Quote generation time: 30 min → 10 min (67% reduction)
  - Report generation time: 2 hours → 5 min (96% reduction)

- **Sales Performance:**
  - Lead-to-booking conversion rate: Baseline 15% → 20% (33% increase)
  - Average deal size: Baseline $2,000 → $2,400 (20% increase from upsells)
  - Sales cycle length: 14 days → 10 days (29% reduction)

- **Revenue Impact:**
  - Revenue per sales agent: $50K/quarter → $65K/quarter (30% increase)
  - Reduced revenue leakage: 8% → 2% (from better follow-up)
  - Payment collection time: 30 days → 20 days (33% improvement)

#### User Satisfaction Metrics
- **Internal User Satisfaction (Sales Team):**
  - NPS (Net Promoter Score): Target > 40
  - User satisfaction survey: 4+ out of 5 average rating
  - System usability: SUS (System Usability Scale) score > 70

- **Customer Satisfaction:**
  - Customer response time: < 2 hours during business hours
  - Booking confirmation accuracy: 99%+
  - Customer complaints: < 5 per month

#### Technical Performance Metrics
- **Reliability:**
  - Uptime: 99.5%+ (< 3.6 hours downtime per month)
  - Error rate: < 0.5% of requests
  - Bug reports: < 10 per month

- **Performance:**
  - Page load time: < 2 seconds (P95)
  - API response time: < 500ms (P95)
  - Background job processing: < 5 min for reports

### 10.2 Phase 2: SaaS Platform (12 Months Post-Launch)

#### Customer Acquisition Metrics
- **Customer Growth:**
  - Total customers: 50 paying companies in Year 1
  - Monthly new customers: 5+ per month by Month 12
  - Customer acquisition cost (CAC): < $2,000 per customer

- **Activation:**
  - Trial-to-paid conversion: 25%+
  - Time to first booking: < 7 days
  - Onboarding completion rate: 80%+

#### Revenue Metrics
- **Revenue Growth:**
  - Annual Recurring Revenue (ARR): $500K by end of Year 1
  - Monthly Recurring Revenue (MRR): $42K by Month 12
  - Average Revenue Per Account (ARPA): $833/month

- **Revenue Health:**
  - Gross churn: < 5% per month
  - Net churn: < 2% (after expansions)
  - Expansion revenue: 20% of existing customers upgrade in Year 1

#### Customer Success Metrics
- **Retention:**
  - Customer retention rate: 90%+ after 12 months
  - Logo retention: 85%+ (customers still subscribed)
  - Net Dollar Retention: 105%+ (including expansions)

- **Satisfaction:**
  - NPS: > 50 (industry benchmark for SaaS: 30-40)
  - Customer satisfaction (CSAT): 4.5+ out of 5
  - Support ticket resolution: < 24 hours first response

- **Engagement:**
  - Daily active users / Monthly active users (DAU/MAU): > 40%
  - Feature adoption: 70%+ of customers use core features
  - Customer health score: 80%+ of customers "green" status

#### Market Metrics
- **Market Penetration:**
  - Market share in target segment: 2-3% (of 2,000 target tour operators)
  - Brand awareness: 20% unaided awareness in target market
  - Inbound leads: 100+ qualified leads per month by Month 12

- **Product Market Fit:**
  - "Very disappointed" response: 40%+ (Sean Ellis test)
  - Organic growth: 30% of customers from referrals/word-of-mouth
  - Case studies: 10 customer success stories published

#### Technical Scalability Metrics
- **Performance at Scale:**
  - Uptime: 99.9%+ (< 43 minutes downtime per month)
  - Page load time: < 2 seconds for 95% of customers
  - Support concurrent users: 1,000+ simultaneous

- **Infrastructure Efficiency:**
  - Cost per customer: < $50/month (hosting + services)
  - Database size: Optimized for 1M+ records per tenant
  - Background job processing: 99% processed within SLA

### 10.3 Leading Indicators (Monitor Weekly/Monthly)

**User Engagement Indicators:**
- Weekly active users trend (should increase consistently)
- Feature adoption rate (track each feature separately)
- Support ticket volume and trends (increasing = issues, decreasing = stability)
- User session duration (higher = more engaged)

**Sales Pipeline Health (Phase 1 Internal):**
- Number of new leads per week
- Lead velocity (movement through pipeline stages)
- Average time in each pipeline stage
- Win rate by agent, by tour, by lead source

**SaaS Health Indicators (Phase 2):**
- Trial signup rate and trend
- Activation rate (first booking created in trial)
- Customer health score distribution
- Feature request frequency and themes
- Churn early warning indicators (decreased usage, support escalations)

### 10.4 Monitoring & Reporting

**Real-Time Dashboards:**
- System health dashboard (uptime, error rate, performance)
- Sales pipeline dashboard (for internal Phase 1)
- SaaS metrics dashboard (MRR, churn, customer health for Phase 2)

**Regular Reports:**
- Weekly: User activity report, support ticket summary
- Monthly: Product metrics review, revenue report, customer success review
- Quarterly: OKR review, roadmap planning, customer feedback analysis

**Data Tools:**
- Analytics: Mixpanel or Amplitude (user behavior tracking)
- BI Tool: Metabase or Redash (custom reports and dashboards)
- APM: Sentry + AppSignal (error tracking, performance monitoring)
- Customer Success: Intercom or Zendesk (support + in-app messaging)

---

## 11. Phasing & Roadmap

### Phase 1: Internal Service (Months 1-8)

#### Month 1-2: MVP Development - Core CRM
**Goals:** Basic lead and booking management working

**Features:**
- User authentication and role-based access
- Lead capture (manual entry + basic web form integration)
- Lead management (view, edit, assign, status tracking)
- Basic booking creation from leads
- Simple tour catalog (CRUD operations)
- Basic reporting (leads by status, bookings by tour)

**Deliverables:**
- Working application deployed to staging
- 5 users (pilot team) testing daily
- Core user flows documented

**Success Criteria:**
- Pilot team can manage 20 leads and 5 bookings per week
- < 10 critical bugs reported
- System uptime > 95%

#### Month 3-4: Payment & Communication
**Goals:** Complete booking lifecycle management

**Features:**
- Payment tracking and invoice generation
- Email integration (send from CRM, template library)
- Communication logging (phone calls, notes)
- Booking status workflow (confirmed → paid → completed)
- Payment reminders (automated emails)
- Customer timeline view (all interactions)

**Deliverables:**
- Full sales team onboarded (15 users)
- Training materials created
- Legacy data migration completed

**Success Criteria:**
- 100% of bookings tracked with payments in CRM
- 80% of customer emails sent from CRM
- User satisfaction > 4/5

#### Month 5-6: Reporting & Analytics
**Goals:** Data-driven decision making enabled

**Features:**
- Sales pipeline dashboard with funnel visualization
- Revenue reports (by tour, by agent, by period)
- Agent performance metrics
- Tour capacity utilization reports
- Export to CSV/Excel
- Scheduled email reports

**Deliverables:**
- Manager dashboards used in weekly meetings
- Monthly business review reports automated
- Performance improvement identified from data

**Success Criteria:**
- Managers view dashboard 3+ times per week
- Report generation time: 2 hours → 5 minutes
- 3+ actionable insights discovered from data

#### Month 7-8: Refinement & Optimization
**Goals:** Polish and prepare for scale

**Features:**
- Advanced search and filtering
- Bulk operations (assign leads, send emails)
- Mobile-responsive improvements
- Performance optimization
- Security audit and hardening
- Documentation completion

**Deliverables:**
- Bug backlog cleared (< 5 open bugs)
- Performance benchmarks met (< 2s page load)
- Security audit report (no critical issues)
- Admin and user documentation complete

**Success Criteria:**
- User satisfaction > 4.3/5
- System performance meets all NFRs
- Ready for external customer use (technical foundation)

### Phase 2: SaaS Platform (Months 9-16)

#### Month 9-10: Multi-Tenancy & Onboarding
**Goals:** Transform to multi-tenant SaaS architecture

**Features:**
- Multi-tenant data isolation
- Self-service account creation
- Guided onboarding wizard with sample data
- Tenant branding (logo, color scheme)
- Subscription management (Stripe integration)
- Billing and invoicing automation

**Deliverables:**
- Beta program launched (5 external customers)
- Pricing model validated
- Onboarding time < 1 week

**Success Criteria:**
- Beta customers successfully onboarded
- Zero data leakage between tenants
- Beta NPS > 40

#### Month 11-12: Advanced Features & Integrations
**Goals:** Competitive differentiation and ecosystem

**Features:**
- Payment gateway integration (Stripe for credit cards)
- Accounting software integration (QuickBooks or Xero)
- SMS notifications via Twilio
- WhatsApp integration for customer chat
- Customer portal (self-service booking status)
- API for third-party integrations

**Deliverables:**
- Integration marketplace launched
- API documentation published
- 2-3 marquee integrations live

**Success Criteria:**
- 50% of beta customers use at least 1 integration
- API adoption by 3rd party developers (stretch goal)

#### Month 13-14: Marketing & Growth
**Goals:** Build awareness and sales pipeline

**Features:**
- Public website with product tour
- Free trial (14-day, no credit card required)
- In-app tutorials and help docs
- Customer referral program
- Usage analytics and product telemetry

**Marketing Activities:**
- Content marketing (blog posts, case studies)
- SEO optimization for "tour operator CRM"
- Paid advertising (Google Ads, Facebook)
- Partnerships with tour operator associations
- Webinars and demos

**Deliverables:**
- 20 trial signups per month
- 3 case studies published
- 100+ qualified leads in pipeline

**Success Criteria:**
- 25% trial-to-paid conversion
- CAC < $2,000
- 10 paying customers acquired

#### Month 15-16: General Availability & Scale
**Goals:** Production-ready SaaS at scale

**Features:**
- Enterprise features (SSO, advanced permissions)
- Advanced analytics (customer LTV, cohort analysis)
- Proactive customer success tools (health scores, automated outreach)
- 24/7 monitoring and on-call rotation
- Disaster recovery tested and documented

**Deliverables:**
- General Availability (GA) launch announcement
- 50 paying customers
- $500K ARR achieved
- Customer success playbook

**Success Criteria:**
- 99.9% uptime SLA met
- NPS > 50
- Net churn < 2%
- Profitability path clear (unit economics positive)

---

## 12. Go-to-Market Strategy (Phase 2)

### 12.1 Target Market

**Primary Market (Year 1):**
- Small-to-medium tour operators (3-20 employees)
- Focus: Boutique tour companies, adventure travel, eco-tourism
- Geography: English-speaking markets (USA, Canada, UK, Australia, New Zealand)
- Annual revenue: $500K - $5M
- Pain point: Outgrown spreadsheets, can't afford Salesforce

**Market Size:**
- Total addressable market (TAM): 50,000 tour operators globally
- Serviceable addressable market (SAM): 10,000 in English-speaking markets
- Serviceable obtainable market (SOM): 2,000 in target segments (Year 1-3)
- Target: 50 customers Year 1 (2.5% of SOM)

### 12.2 Pricing Strategy

**Tiered Pricing Model:**

**Starter Plan: $79/month**
- Up to 3 users
- 500 leads, 100 bookings/month
- Core features (CRM, booking, payment tracking)
- Email support
- Target: Solo operators, very small teams

**Professional Plan: $149/month** (Recommended)
- Up to 10 users
- 2,000 leads, 500 bookings/month
- All Starter features plus:
  - Advanced reporting and analytics
  - Email templates and automation
  - Payment gateway integration
- Priority email support
- Target: Growing tour operators (5-10 employees)

**Business Plan: $299/month**
- Up to 25 users
- Unlimited leads and bookings
- All Professional features plus:
  - Accounting software integration
  - API access
  - Custom branding
  - Phone + email support
  - Dedicated account manager
- Target: Established tour operators (10-20 employees)

**Add-ons:**
- Additional users: $15/user/month
- SMS notifications: $0.05/message (pay-as-you-go)
- Priority support: $99/month (24/7 support, 1-hour response SLA)

**Freemium Option (Considered):**
- Free tier for solo operators (1 user, 50 leads, 20 bookings/month)
- Goal: Generate qualified leads, word-of-mouth growth
- Risk: Support burden, low conversion rate
- Decision: Evaluate after beta program

### 12.3 Customer Acquisition Channels

**Organic Channels (Primary Focus):**
1. **Content Marketing:**
   - Blog posts: "How to manage tour bookings efficiently", "CRM for tour operators guide"
   - SEO optimization for keywords: "tour operator CRM", "tour booking software"
   - Case studies and customer success stories
   - Free resources: booking template, sales playbook

2. **Partnerships:**
   - Tour operator associations (partner for webinars, sponsor events)
   - Travel technology companies (integration partnerships)
   - Travel bloggers and influencers (affiliate program)

3. **Referrals:**
   - Customer referral program (1 month free for each referral)
   - Built-in "invite colleague" functionality

**Paid Channels (Secondary):**
1. **Google Ads:**
   - Target keywords: "tour operator software", "CRM for travel agents"
   - Budget: $2,000/month initially, optimize based on CAC

2. **Facebook/LinkedIn Ads:**
   - Target tour operator owners and managers
   - Retargeting website visitors

3. **Industry Publications:**
   - Sponsored content in tour operator magazines
   - Display ads on travel industry websites

### 12.4 Sales Process

**Self-Service (Primary):**
- 14-day free trial (no credit card required)
- In-app onboarding with guided setup
- Self-service knowledge base and tutorials
- Automated email nurture sequence during trial
- Upgrade prompts at key usage milestones

**Sales-Assisted (for Business Plan):**
- Demo requests routed to founder/sales rep
- Live product demo (30 minutes)
- Custom onboarding and training included
- Negotiated annual contracts for larger teams

### 12.5 Customer Success Strategy

**Onboarding (Days 1-7):**
- Welcome email with getting started checklist
- In-app tutorial videos for core features
- Sample data pre-loaded to explore
- Check-in email on Day 3 (offer help)

**Activation (Days 8-14):**
- Monitor usage (goal: first booking created)
- Automated tips based on usage patterns
- Offer live onboarding call if not activated by Day 10
- Upgrade prompt if trial limits reached

**Retention (Ongoing):**
- Monthly product update emails (new features)
- Proactive outreach to low-usage accounts
- Customer health scores (usage, support tickets, payment status)
- Quarterly business review for high-value customers

**Expansion (Upsell):**
- Prompt to upgrade when limits approached
- Feature announcements with clear value proposition
- Success stories from similar customers
- Discount for annual prepayment (2 months free)

---

## 13. Open Questions & Future Considerations

### 13.1 Open Questions (Require Research/Decisions)

**Product Questions:**
1. Should we support offline mode for areas with poor internet connectivity?
   - User need: Tour guides may be in remote locations
   - Technical complexity: Significant (data sync challenges)
   - Decision needed: Phase 2 or later?

2. How should we handle customer cancellations and refund policies?
   - Flexibility needed: Different operators have different policies
   - Options: Configurable policies, manual override, policy templates
   - Decision needed: Month 2

3. ~~Should bookings support multiple currencies for international tours?~~ **RESOLVED - Implemented in Phase 1**
   - **Decision:** Support USD, KZT, EUR, RUB in Phase 1
   - Tours/departures priced in any currency
   - No automatic exchange rates in Phase 1 (manual pricing)
   - Phase 2: Add exchange rate API for automatic conversion

4. What level of tour customization should we support?
   - User need: Many tours are customized per customer
   - Options: Standard tours only, custom itineraries, modular tours
   - Decision needed: Month 3 (after user research)

**Business Questions:**
5. What should our data retention policy be?
   - Legal requirement: Varies by jurisdiction (GDPR, etc.)
   - User need: Historical data for repeat customers
   - Decision needed: Month 4 (consult legal)

6. Should we offer annual contracts with discounts?
   - Pro: Predictable revenue, lower churn, cash flow
   - Con: Harder to sell, commitment friction
   - Decision needed: Before SaaS launch

7. What level of customer support should we commit to?
   - Phase 1: Email support, 24-hour response
   - Phase 2: Consider phone support, live chat, 24/7 coverage?
   - Decision needed: Based on customer feedback and budget

**Technical Questions:**
8. Should we build a mobile app or mobile-responsive web?
   - User need: Access on the go, notifications
   - Options: PWA (progressive web app), native iOS/Android, both
   - Decision needed: Month 6 (after web version validated)

9. Database-per-tenant vs shared database for multi-tenancy?
   - Trade-offs: Isolation vs simplicity, scale vs cost
   - Recommendation: Shared database with row-level security (Apartment gem)
   - Decision needed: Month 8 (before Phase 2 work begins)

10. What's our international expansion strategy beyond Russia/Kazakhstan region?
    - **Phase 1:** Russian & English languages, USD/KZT/EUR/RUB currencies (covers CIS region)
    - **Phase 2+:** Additional languages (Spanish, French, Arabic) for global expansion?
    - Legal: GDPR compliance, regional data requirements
    - Decision needed: After 50 customers (Month 16+)

### 13.2 Future Features (Post-Launch)

**Potential Features for Phase 3+ (Prioritize based on customer feedback):**

1. **Advanced Tour Management:**
   - Multi-day itineraries with day-by-day activities
   - Supplier management (hotels, transport, guides)
   - Automated supplier booking confirmations
   - Tour guide scheduling and assignment

2. **Customer Portal:**
   - Self-service booking status check
   - Document downloads (invoices, vouchers, itineraries)
   - Pre-trip questionnaires (dietary restrictions, etc.)
   - Post-trip review and feedback collection

3. **Marketing Automation:**
   - Drip email campaigns for nurturing leads
   - Personalized tour recommendations
   - Birthday/anniversary emails for repeat customers
   - Win-back campaigns for past customers

4. **Advanced Analytics:**
   - Predictive analytics (which leads likely to convert?)
   - Customer lifetime value (LTV) predictions
   - Cohort analysis (customer behavior over time)
   - A/B testing for email campaigns

5. **Mobile Applications:**
   - Native iOS app for on-the-go access
   - Native Android app
   - Offline mode for tour guides in field
   - Push notifications for important events

6. **Integrations:**
   - More payment gateways (PayPal, Square, regional options)
   - More accounting software (FreshBooks, Wave)
   - Email marketing tools (Mailchimp, ConvertKit)
   - Video conferencing (Zoom, Google Meet for virtual consultations)

7. **Enterprise Features:**
   - Single Sign-On (SSO) via SAML or OAuth
   - Advanced permissions and role customization
   - Audit logs and compliance reports
   - Data export and portability tools

8. **AI-Powered Features:**
   - Smart lead scoring (predict conversion likelihood)
   - Automated response suggestions (for common customer questions)
   - Optimal pricing recommendations (based on demand, seasonality)
   - Chatbot for customer inquiries

### 13.3 Risks to Monitor

**Ongoing Risk Monitoring:**
- User adoption and engagement trends (weekly)
- System performance and scalability (daily)
- Customer satisfaction and NPS (monthly)
- Competitive landscape changes (quarterly)
- Regulatory changes affecting travel industry (ongoing)
- Technology stack updates and security advisories (ongoing)

---

## 14. Appendices

### Appendix A: Glossary

**Key Terms:**
- **Lead:** A potential customer who has expressed interest in a tour
- **Booking:** A confirmed tour reservation with payment commitment
- **Tour Departure:** A specific instance of a tour with a fixed date and capacity
- **Pipeline Stage:** Status of a lead in the sales process (New, Contacted, Qualified, Quoted, Won/Lost)
- **Conversion Rate:** Percentage of leads that become bookings
- **Payment Schedule:** Timeline for deposit and final payment
- **Tour Capacity:** Maximum number of participants for a tour departure
- **Capacity Utilization:** Percentage of tour capacity that is booked
- **Customer Timeline:** Chronological view of all interactions with a customer
- **Multi-Tenancy:** Architecture allowing multiple customers (tenants) to use the same application instance

**Acronyms:**
- **CRM:** Customer Relationship Management
- **SaaS:** Software as a Service
- **MVP:** Minimum Viable Product
- **API:** Application Programming Interface
- **UI/UX:** User Interface / User Experience
- **NFR:** Non-Functional Requirement
- **ARR:** Annual Recurring Revenue
- **MRR:** Monthly Recurring Revenue
- **CAC:** Customer Acquisition Cost
- **LTV:** Lifetime Value
- **NPS:** Net Promoter Score
- **CSAT:** Customer Satisfaction Score
- **GDPR:** General Data Protection Regulation
- **SOC 2:** Service Organization Control 2 (security compliance)

### Appendix B: Competitive Analysis

**Direct Competitors:**
- **TourPlan:** Enterprise tour operator software (expensive, complex)
- **TourCMS:** Booking system + website builder (lacks CRM depth)
- **Rezdy:** Booking platform (focused on distribution, not CRM)

**Indirect Competitors:**
- **Salesforce:** General-purpose CRM (not tour-specific, expensive)
- **HubSpot:** CRM + marketing automation (not tour-specific)
- **Zoho CRM:** Affordable CRM (not tour-specific)

**Differentiation:**
- Tour operator-specific workflow (not generic CRM)
- Affordable for small-medium operators ($79-299/month vs $1000+/month)
- Quick setup and onboarding (< 1 week vs months)
- Built by tour operators, for tour operators (domain expertise)

### Appendix C: User Research Summary

**Research Conducted:**
- Internal sales team interviews (5 agents, 2 managers)
- Current workflow observation (shadowing sales agents)
- Pain point analysis (spreadsheet review)
- Competitive product evaluation (demos of 3 competitors)

**Key Findings:**
1. Biggest pain point: Lost information in email threads
2. Second biggest: Time spent manually creating quotes/invoices
3. Managers lack visibility into team activities
4. Current tools: 6 different systems (too fragmented)
5. Mobile access needed 40% of the time

**Validated Assumptions:**
- Sales agents willing to adopt new system (if easier than current)
- Tour-specific features are must-have (generic CRM won't work)
- Integration with email is critical for adoption

**Invalidated Assumptions:**
- Agents don't need complex reporting (they just need pipeline visibility)
- Mobile app not critical for Phase 1 (responsive web is sufficient)

### Appendix D: Technical Spike Results

**Database Strategy:**
- **Phase 1:** Start with SQLite3 (Rails 8 default)
  - Zero configuration, simple deployment
  - Sufficient for internal use (15 users, expected workload)
  - Tested with 100K leads, 50K bookings - performance excellent
- **Phase 2:** Migrate to PostgreSQL when scaling to multi-tenant
  - Migration path is straightforward (Active Record abstracts database)
  - Shared database with tenant_id column for row-level isolation
  - Can scale to millions of records with proper indexing
- **Recommendation:** Start simple (SQLite3), scale when needed (PostgreSQL)

**Rails 8 Solid Gems Evaluation:**
- Tested SolidQueue for background jobs (email sending, report generation)
  - Database-backed queue eliminates Redis/Sidekiq infrastructure
  - Performance adequate for expected workload (100s of jobs/hour)
  - Built-in UI via Mission Control for job monitoring
- Tested SolidCache for application caching
  - Database-backed cache, simple setup
  - Eliminates Redis dependency
  - Performance acceptable for Phase 1 scale
- Tested SolidCable for WebSockets (real-time dashboard updates)
  - Works well for internal team collaboration features
- **Recommendation:** Use Solid gems for Phase 1, evaluate Redis only if bottleneck emerges

**Multi-Tenancy Approach:**
- Evaluated database-per-tenant vs shared database with tenant_id
- Shared database with tenant_id isolation is simplest for Phase 2
- Use acts_as_tenant gem or custom Current.tenant pattern
- Can migrate to database-per-tenant later if compliance requires
- **Recommendation:** Tenant_id approach (simple, cost-effective, scales to 100s of tenants)

**Email Integration:**
- Tested SendGrid, Postmark, AWS SES
- All have good deliverability and Rails integration (Action Mailer)
- **Recommendation:** SendGrid (good deliverability, generous free tier, excellent docs)

**Rails 8 Hotwire Evaluation:**
- Built prototype of lead management with Turbo + Stimulus
- Turbo Streams for real-time updates (dashboard, notifications)
- Turbo Frames for lazy-loaded sections (customer timeline)
- Stimulus for targeted interactions (form validation, dropdown menus)
- Developer velocity excellent, minimal JavaScript needed (< 100 lines for entire prototype)
- **Recommendation:** Proceed with Rails 8 + Hotwire (Turbo + Stimulus)

**Authentication Approach:**
- Evaluated Devise vs Rails 8 built-in authentication
- Rails 8's `rails g authentication` provides clean, simple starting point
- Fully customizable, no gem dependencies, well-documented
- **Recommendation:** Use Rails 8 built-in authentication (simple, maintainable)

### Appendix E: References

**Product Management:**
- "Inspired" by Marty Cagan (product discovery, validation)
- "The Lean Startup" by Eric Ries (MVP, iteration)
- "Crossing the Chasm" by Geoffrey Moore (market adoption)

**SaaS Metrics:**
- "SaaS Metrics 2.0" by David Skok (ARR, churn, CAC, LTV)
- Christoph Janz's "Five Ways to Build a $100M SaaS Business"

**Rails Development:**
- Rails 8 official documentation (guides.rubyonrails.org)
- "The Rails 8 Way" (best practices)
- Hotwire documentation (Turbo + Stimulus) - hotwired.dev
- Rails 8 Solid gems documentation:
  - SolidQueue (github.com/rails/solid_queue)
  - SolidCache (github.com/rails/solid_cache)
  - SolidCable (github.com/rails/solid_cable)
- Rails 8 Authentication guide (built-in `rails g authentication`)
- Kamal 2 deployment documentation (kamal-deploy.org)

**Internationalization & Localization:**
- Rails I18n (Internationalization) guide (guides.rubyonrails.org/i18n.html)
- Money gem for currency handling (github.com/RubyMoney/money)
- Rails localization best practices
- ISO 4217 currency codes standard

**Multi-Tenancy:**
- acts_as_tenant gem documentation (row-level multi-tenancy)
- "Multitenancy with Rails" resources
- Rails Current attributes pattern for tenant context

---

## Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2026-01-07 | Product Team | Initial PRD creation |
| 1.1 | 2026-01-07 | Technical Team | Updated tech stack to Rails 8 modern defaults (SQLite3, Solid gems, built-in auth) |
| 1.2 | 2026-01-07 | Product Team | Major update: WhatsApp via wazzup24 as primary communication channel. Added WhatsApp integration for lead capture and customer communication. |
| 1.3 | 2026-01-07 | Product Team | Added Russian & English localization (Phase 1) and multi-currency support (USD, KZT, EUR, RUB) in Phase 1. Updated data models and requirements. |
| 1.4 | 2026-01-10 | Product Team | **CRITICAL ARCHITECTURE CHANGE:** Introduced Client model to separate customer identity from sales opportunities. Client-centric architecture enables repeat customers, multiple leads per client, and lifetime value tracking. Updated data model, user stories, and functional requirements. |
| 1.5 | 2026-01-10 | Development Team | **Implementation Status Update:** Completed Bookings and Payments views with comprehensive CRUD, payment tracking, and modern UI/UX. Resolved all Client-Centric Architecture migration bugs. Enhanced Client show page with SaaS-style design. |

---

## Approval Sign-Off

**Product Owner:** _________________ Date: _______

**Engineering Lead:** _________________ Date: _______

**Sales Manager:** _________________ Date: _______

**Executive Sponsor:** _________________ Date: _______
