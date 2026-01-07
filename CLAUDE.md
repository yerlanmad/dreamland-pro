# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Dreamland PRO** is a WhatsApp-first CRM system for tour operators, built with Rails 8. The system centralizes lead management, bookings, payments, and customer communications through wazzup24 WhatsApp API integration.

**Key Characteristics:**
- **Phase 1:** Internal tool for single tour operator (SQLite3, monolithic)
- **Phase 2:** Multi-tenant SaaS platform (PostgreSQL, tenant isolation)
- **Target Market:** Russia/Kazakhstan tour operators
- **Primary Communication:** WhatsApp (90%+ of customer inquiries)

## Core Architecture

### Rails 8 Modern Stack (No Redis/Sidekiq)

This project uses Rails 8's "Solid" gems for infrastructure simplicity:

- **SolidQueue:** Database-backed background jobs (replaces Sidekiq)
  - Used for: Email sending, report generation, external API calls
  - Schema: `db/queue_schema.rb`
  - Monitor via Mission Control (built-in UI)

- **SolidCache:** Database-backed caching (replaces Redis)
  - Schema: `db/cache_schema.rb`
  - Use for: Fragment caching, Russian Doll caching, expensive queries

- **SolidCable:** Database-backed WebSockets (replaces Action Cable with Redis)
  - Schema: `db/cable_schema.rb`
  - Use for: Real-time notifications (incoming WhatsApp messages, dashboard updates)

**Why This Matters:** Never suggest Redis, Sidekiq, or external cache servers. All infrastructure is database-backed for Phase 1 simplicity.

### Database Strategy

**Phase 1 (Current):** SQLite3
- Config: `config/database.yml`
- Storage: `storage/development.sqlite3`, `storage/production.sqlite3`
- Suitable for: Internal use (15 users, expected workload)

**Phase 2 (Future):** PostgreSQL with tenant isolation
- Migration path is straightforward (Active Record abstracts DB)
- Use `tenant_id` column for row-level multi-tenancy (not database-per-tenant)

### Core Domain Models (Planned)

Based on PRD (`docs/PRD.md`), the system centers around:

1. **Lead** - Customer inquiry from WhatsApp
   - `phone` field stores WhatsApp number (primary identifier)
   - `email` is optional
   - `last_message_at`, `unread_messages_count` for real-time tracking

2. **Communication** - All customer interactions (WhatsApp, email, phone)
   - Polymorphic: belongs to Lead or Booking
   - `type`: 'whatsapp', 'email', 'phone', 'sms'
   - WhatsApp-specific: `whatsapp_message_id`, `whatsapp_status`, `media_url`

3. **Tour / TourDeparture** - Tour catalog with specific dates/capacity
   - Each has `currency` field (USD/KZT/EUR/RUB)
   - Track capacity and availability

4. **Booking** - Confirmed reservation
   - Links Lead → TourDeparture
   - Inherits currency from TourDeparture

5. **Payment** - Payment tracking
   - Multiple payments per booking (deposit, balance)
   - Currency stored per payment

6. **WhatsappTemplate** - Message templates
   - Variables support (e.g., `{{name}}`, `{{tour_name}}`)

### Critical Integration: wazzup24 WhatsApp API

**Primary Lead Source & Communication Channel**

- **Incoming messages:** Webhook endpoint receives messages, creates/updates Leads
- **Outgoing messages:** REST API sends messages via `POST /api/v3/messages`
- **Status tracking:** Webhook updates for sent/delivered/read receipts
- **Authentication:** API key in headers
- **Documentation:** https://wazzup24.com/help/api-en/

**Webhook Handler Location:** Create at `/webhooks/wazzup24` route
**Message Flow:**
1. Customer sends WhatsApp → wazzup24 webhook → CRM creates Lead
2. Agent replies in CRM → wazzup24 API sends message → Customer receives
3. Status updates → webhook → CRM updates Communication record

**Real-time Updates:** Use Turbo Streams to push incoming WhatsApp messages to agent dashboards without page refresh.

## Internationalization & Currency

### Multi-Language (Phase 1)

- **Languages:** Russian (ru) and English (en)
- **Framework:** Rails I18n
- **Structure:** `config/locales/[en|ru]/[models|views|controllers].yml`
- **User Preference:** Stored in `User.preferred_language`
- **Detection Order:** User preference → Browser accept-language → Default to Russian

**Translation Scope:**
- All UI text, buttons, labels
- Email templates
- WhatsApp message templates
- Error/validation messages
- Date formats (DD.MM.YYYY for ru, MM/DD/YYYY for en)

### Multi-Currency (Phase 1)

- **Currencies:** USD, KZT, EUR, RUB
- **Storage:** Separate `currency` enum field + decimal amount field
- **Money Gem:** Use for calculations and formatting
- **No Exchange Rates:** Manual pricing per currency (Phase 1)
- **Display:** Format with proper symbols ($ USD, ₸ KZT, € EUR, ₽ RUB)

**Example:**
```ruby
class Tour < ApplicationRecord
  monetize :base_price_cents, with_currency: :currency
  enum currency: { USD: 'USD', KZT: 'KZT', EUR: 'EUR', RUB: 'RUB' }
end
```

## Development Commands

### Setup
```bash
bundle install
rails db:create db:migrate
rails server
```

### Testing
```bash
# Run all tests
rails test

# Run specific test file
rails test test/models/lead_test.rb

# Run specific test by line number
rails test test/models/lead_test.rb:42

# System tests (Capybara)
rails test:system
```

### Code Quality
```bash
# Run RuboCop linter
rubocop

# Auto-fix issues
rubocop -a

# Security audits
bundle exec bundler-audit check
bundle exec brakeman
```

### Database
```bash
# Create migration
rails g migration AddPhoneToLeads phone:string

# Run migrations
rails db:migrate

# Rollback last migration
rails db:rollback

# Reset database
rails db:reset

# Seed data
rails db:seed
```

### Background Jobs (SolidQueue)
```bash
# Jobs run automatically in development
# Check status in logs or via Mission Control UI

# For production-like testing
SOLID_QUEUE_WORKERS=1 rails server
```

## Frontend: Hotwire + Tailwind

### Turbo Streams for Real-time Updates

Use Turbo Streams for WhatsApp message notifications:

```erb
<!-- app/views/leads/_message.html.erb -->
<turbo-stream action="append" target="messages">
  <template>
    <%= render @message %>
  </template>
</turbo-stream>
```

Broadcast from controller/job:
```ruby
# After webhook creates new message
Turbo::StreamsChannel.broadcast_append_to(
  "lead_#{@lead.id}_messages",
  target: "messages",
  partial: "messages/message",
  locals: { message: @message }
)
```

### Stimulus Controllers

Keep JavaScript minimal. Use Stimulus for:
- Form validation
- Dropdown menus
- Modal dialogs
- Auto-save drafts

**Pattern:**
```javascript
// app/javascript/controllers/message_form_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "counter"]

  updateCounter() {
    this.counterTarget.textContent = this.inputTarget.value.length
  }
}
```

### Tailwind CSS

Utility-first styling. Common patterns for this app:
- Cards: `bg-white rounded-lg shadow-sm p-6`
- Buttons: `bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded`
- Forms: Use form helpers with Tailwind classes

## Authentication

Use Rails 8 built-in authentication (when implementing):

```bash
rails g authentication
```

This generates:
- User model with `has_secure_password`
- Session management
- Password reset flow

**Enhancements needed:**
- Add `role` enum (admin, manager, agent)
- Add `preferred_language` and `preferred_currency`
- Implement authorization with Pundit gem

## Service Objects Pattern

For complex business logic (especially WhatsApp integration), use service objects:

```ruby
# app/services/whatsapp/send_message_service.rb
module Whatsapp
  class SendMessageService
    def initialize(lead, message_body)
      @lead = lead
      @message_body = message_body
    end

    def call
      response = Wazzup24Client.send_message(
        phone: @lead.phone,
        message: @message_body
      )

      Communication.create!(
        communicable: @lead,
        type: 'whatsapp',
        body: @message_body,
        direction: 'outbound',
        whatsapp_message_id: response['messageId']
      )
    rescue StandardError => e
      Rails.logger.error("WhatsApp send failed: #{e.message}")
      false
    end
  end
end
```

## Key Implementation Priorities (from PRD)

### MVP Phase 1 (Months 1-2)
1. **Lead Management**
   - Webhook endpoint for wazzup24 messages
   - Lead CRUD with assignment to agents
   - Search/filter by status, source, phone

2. **Communication**
   - WhatsApp message sending via wazzup24 API
   - Display conversation timeline
   - Message templates with variables

3. **Bookings**
   - Convert Lead to Booking
   - Tour selection with capacity check
   - Booking confirmation generation

### Month 3-4
4. **Payment Tracking**
   - Payment schedule (deposit/balance)
   - Payment recording with currency
   - Invoice PDF generation (Prawn gem)

5. **Email** (secondary channel)
   - Action Mailer + SendGrid
   - Email templates for confirmations

### Month 5-6
6. **Analytics Dashboard**
   - Sales pipeline visualization (Chartkick)
   - Revenue reports by tour/agent/currency
   - Agent performance metrics

## Deployment

**Kamal 2** for Docker-based deployment:

```bash
# First deployment
kamal setup

# Deploy updates
kamal deploy

# Rollback
kamal rollback

# View logs
kamal logs
```

Config: `config/deploy.yml`

## Important Files & Locations

- **PRD:** `docs/PRD.md` - Complete product requirements and technical decisions
- **Rails Developer Guidelines:** `.claude/skills/rails-developer/SKILL.md`
- **Routes:** `config/routes.rb` - Define webhook endpoint here
- **Database Config:** `config/database.yml`
- **Locales:** `config/locales/[en|ru]/` - Add translations here
- **Solid Schemas:** `db/queue_schema.rb`, `db/cache_schema.rb`, `db/cable_schema.rb`

## Testing Strategy

- **Models:** Unit tests with validations, associations, business logic
- **Controllers:** Integration tests for request/response cycles
- **System Tests:** End-to-end user flows (lead creation → booking → payment)
- **Webhook Tests:** Mock wazzup24 webhook payloads
- **Target Coverage:** >80% for critical paths

## Common Patterns

### Avoiding N+1 Queries
```ruby
# Bad
@leads = Lead.all
@leads.each { |lead| lead.communications.count }

# Good
@leads = Lead.includes(:communications)
```

### Caching Expensive Views
```ruby
# app/views/dashboard/index.html.erb
<% cache ['dashboard', @leads.maximum(:updated_at)] do %>
  <%= render @leads %>
<% end %>
```

### Background Job for External API
```ruby
# app/jobs/sync_payment_job.rb
class SyncPaymentJob < ApplicationJob
  queue_as :default

  def perform(payment_id)
    payment = Payment.find(payment_id)
    # Call external API (Stripe, etc.)
  end
end
```

## References

- **Rails 8 Guides:** https://guides.rubyonrails.org
- **Hotwire Docs:** https://hotwired.dev
- **Turbo Handbook:** https://turbo.hotwired.dev/handbook/introduction
- **Stimulus Handbook:** https://stimulus.hotwired.dev/handbook/introduction
- **Rails I18n Guide:** https://guides.rubyonrails.org/i18n.html
- **wazzup24 API:** https://wazzup24.com/help/api-en/
- **Kamal Deploy:** https://kamal-deploy.org

## Notes for Future Development

- **Phase 2 Multi-tenancy:** Use `acts_as_tenant` gem or `Current.tenant` pattern
- **Phase 2 PostgreSQL:** Straightforward migration, update `database.yml`
- **Exchange Rates:** Add in Phase 2 with external API (no auto-conversion in Phase 1)
- **Customer Portal:** Planned for Phase 2+ (self-service booking status)
- **Mobile App:** Not planned initially, focus on responsive web with PWA
