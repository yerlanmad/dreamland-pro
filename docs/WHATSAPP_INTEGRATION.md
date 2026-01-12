# WhatsApp Integration Documentation

**Feature**: WhatsApp Outbound Messaging & Templates UI
**Status**: ✅ Complete (MVP Phase 1)
**Date**: January 2026
**Version**: 1.0

---

## Table of Contents

1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Setup & Configuration](#setup--configuration)
4. [Features](#features)
5. [Usage Guide](#usage-guide)
6. [API Integration](#api-integration)
7. [Code Reference](#code-reference)
8. [Testing](#testing)
9. [Troubleshooting](#troubleshooting)
10. [Future Enhancements](#future-enhancements)

---

## Overview

The WhatsApp integration enables two-way communication between the CRM and customers via the wazzup24 WhatsApp Business API. This completes the primary communication loop:

- **Inbound**: Customers send WhatsApp messages → wazzup24 webhook → CRM creates Leads and Communications ✅ (Already implemented)
- **Outbound**: Agents reply from CRM → wazzup24 API sends WhatsApp message → Customer receives ✅ (Newly implemented)

### Key Capabilities

- Send WhatsApp messages to clients from Lead detail pages
- Create reusable message templates with variable substitution
- Track all communications with status (pending/sent/failed)
- Variable replacement: `{{name}}`, `{{phone}}`, `{{email}}`, `{{tour_name}}`
- Template categories: Greeting, Pricing, Availability, Confirmation, Follow-up, General
- Activate/deactivate templates
- Communication history timeline

---

## Architecture

### System Components

```
┌─────────────────────────────────────────────────────────────┐
│                      Dreamland PRO CRM                       │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌──────────────┐      ┌────────────────────────────┐       │
│  │   Lead       │      │  WhatsappTemplate          │       │
│  │   Show Page  │      │  Management                │       │
│  └──────┬───────┘      └────────────────────────────┘       │
│         │                                                     │
│         ▼                                                     │
│  ┌──────────────────────────────────────────────────┐       │
│  │   CommunicationsController                       │       │
│  │   • send_whatsapp_message()                      │       │
│  └──────────────────┬───────────────────────────────┘       │
│                     │                                         │
│                     ▼                                         │
│  ┌──────────────────────────────────────────────────┐       │
│  │   Whatsapp::SendMessageService                   │       │
│  │   • Render template (if provided)                │       │
│  │   • Create Communication record                  │       │
│  │   • Call Wazzup24Client                          │       │
│  │   • Update communication status                  │       │
│  └──────────────────┬───────────────────────────────┘       │
│                     │                                         │
│                     ▼                                         │
│  ┌──────────────────────────────────────────────────┐       │
│  │   Wazzup24Client (HTTParty)                      │       │
│  │   • POST /api/v3/messages                        │       │
│  │   • Phone normalization                          │       │
│  │   • Error handling & timeouts                    │       │
│  └──────────────────┬───────────────────────────────┘       │
│                     │                                         │
└─────────────────────┼─────────────────────────────────────┘
                      │
                      ▼
         ┌────────────────────────┐
         │   wazzup24 API         │
         │   (WhatsApp Business)  │
         └────────────┬───────────┘
                      │
                      ▼
              Customer's WhatsApp
```

### Data Flow

1. **Agent Action**: Selects template or types custom message on Lead page
2. **Controller**: `CommunicationsController#send_whatsapp_message` receives form data
3. **Service Layer**: `Whatsapp::SendMessageService` orchestrates the workflow:
   - Renders template with client variables (if template selected)
   - Creates `Communication` record with status: `pending`
   - Calls `Wazzup24Client.send_message()`
   - Updates communication status: `sent` or `failed`
4. **HTTP Client**: `Wazzup24Client` sends POST request to wazzup24 API
5. **External API**: wazzup24 delivers message via WhatsApp Business API
6. **Customer**: Receives WhatsApp message on their phone

---

## Setup & Configuration

### 1. Dependencies Installation

The following gems have been added:

```ruby
# Gemfile
gem 'httparty', '~> 0.21'  # HTTP client for wazzup24 API

group :test do
  gem 'webmock'  # Stub HTTP requests in tests
end
```

Install with:
```bash
bundle install
```

### 2. wazzup24 API Key Configuration

**Critical**: You must add your wazzup24 API key to Rails encrypted credentials.

```bash
# Edit credentials (opens in $EDITOR)
rails credentials:edit
```

Add this structure:
```yaml
wazzup24:
  api_key: YOUR_WAZZUP24_API_KEY_HERE
```

Save and close the editor. The credentials file will be encrypted automatically.

**Access in code**:
```ruby
Rails.application.credentials.dig(:wazzup24, :api_key)
```

### 3. Routes Configuration

Routes are already configured in `config/routes.rb`:

```ruby
# WhatsApp Templates CRUD + toggle_active
resources :whatsapp_templates do
  member do
    patch :toggle_active
  end
end

# Communications (nested under leads/bookings)
resources :leads do
  resources :communications, only: [:create]
end
```

### 4. Database Schema

No new migrations required. Uses existing tables:
- `whatsapp_templates` (already exists)
- `communications` (already exists with `whatsapp_status` and `whatsapp_message_id` columns)

### 5. Verify Installation

Check that all files are in place:

```bash
# Controllers
ls app/controllers/whatsapp_templates_controller.rb
ls app/controllers/communications_controller.rb

# Services
ls app/services/whatsapp/send_message_service.rb

# Clients
ls app/clients/wazzup24_client.rb

# Views
ls app/views/whatsapp_templates/
# Should show: index.html.erb, show.html.erb, new.html.erb, edit.html.erb, _form.html.erb

# Tests
ls test/clients/wazzup24_client_test.rb
```

---

## Features

### 1. WhatsApp Message Sending

**Location**: Lead detail page (`/leads/:id`)

**Capabilities**:
- Send WhatsApp messages directly to leads
- Choose between custom message or template
- Real-time message type selection (WhatsApp/Email)
- Variable hints displayed to user
- Success/failure feedback with error messages

**Form Fields**:
- **Message Type**: WhatsApp or Email (dropdown)
- **Template**: Optional dropdown of active templates
- **Message Body**: Text area for custom message or template content

### 2. WhatsApp Templates Management

**Location**: `/whatsapp_templates`

**CRUD Operations**:
- **Create**: Add new message templates with variables
- **Read**: View all templates with filters and search
- **Update**: Edit template content, category, or status
- **Delete**: Remove unused templates
- **Toggle Active**: Enable/disable templates for use

**Template Features**:
- **Variable Substitution**: Use `{{variable_name}}` syntax
- **Categories**: Organize by type (Greeting, Pricing, etc.)
- **Preview**: See rendered template with sample data
- **Active Status**: Only active templates appear in dropdowns

**Available Variables**:
- `{{name}}` - Client name
- `{{phone}}` - Client phone number
- `{{email}}` - Client email address
- `{{tour_name}}` - Tour name (context-dependent)

### 3. Communication Timeline

**Location**: Lead detail page (`/leads/:id`)

**Features**:
- Chronological list of all communications
- Direction indicators (Inbound/Outbound)
- Status tracking (Pending, Sent, Failed)
- Timestamp with relative time
- Message body preview
- WhatsApp message ID storage

---

## Usage Guide

### For CRM Users

#### Sending a WhatsApp Message

1. **Navigate to Lead**: Go to `/leads` and click on a lead
2. **Scroll to Communications**: Find "Send Message" section at bottom
3. **Select Message Type**: Choose "WhatsApp" from dropdown
4. **Optional - Use Template**:
   - Select template from "Use Template" dropdown
   - Template content will populate (future: auto-populate feature)
5. **Enter Message**: Type or paste message in text area
   - Use variable syntax: `Hello {{name}}, your tour on {{tour_name}} is confirmed!`
6. **Send**: Click "Send Message" button
7. **Confirmation**: Success message appears, or error with details

#### Creating a Message Template

1. **Navigate to Templates**: Go to `/whatsapp_templates`
2. **Click "New Template"**
3. **Fill Form**:
   - **Template Name**: Descriptive name (e.g., "Greeting for new leads")
   - **Category**: Select appropriate category
   - **Message Content**: Enter template with variables
     ```
     Hello {{name}}, thank you for your inquiry about our tours!

     We received your message and will get back to you within 24 hours.

     Feel free to reach out if you have any questions.
     ```
   - **Active**: Check to make available for use
4. **Create Template**: Click button to save
5. **View Preview**: See template with sample data rendered

#### Managing Templates

- **View All**: Visit `/whatsapp_templates`
- **Filter by Category**: Use category dropdown and click "Filter"
- **Activate/Deactivate**: Click "Toggle" button in table
- **Edit**: Click "Edit" link to modify content
- **Delete**: Not recommended if in use; deactivate instead

### For Developers

#### Sending Messages Programmatically

```ruby
# Basic usage
result = Whatsapp::SendMessageService.new(
  client: @client,
  body: "Hello! Your booking is confirmed."
).call

if result[:success]
  puts "Message sent! ID: #{result[:communication].whatsapp_message_id}"
else
  puts "Error: #{result[:error]}"
end

# With template
template = WhatsappTemplate.find_by(name: "Booking Confirmation")
result = Whatsapp::SendMessageService.new(
  client: @client,
  body: nil,  # Not used when template provided
  template: template
).call
```

#### Creating Templates Programmatically

```ruby
template = WhatsappTemplate.create!(
  name: "Tour Availability Update",
  category: :availability,
  content: "Hi {{name}}, good news! {{tour_name}} has spots available for next month.",
  active: true
)

# Template automatically extracts variables from content
template.variables  # => ["name", "tour_name"]
```

#### Direct API Client Usage

```ruby
# For advanced use cases
client = Wazzup24Client.new
result = client.send_message(
  phone: "+77001234567",
  message: "Test message",
  media_url: "https://example.com/image.jpg"  # Optional
)

if result[:success]
  message_id = result[:data]['messageId']
end
```

---

## API Integration

### wazzup24 API Documentation

**Official Docs**: https://wazzup24.com/help/api-en/

**Base URL**: `https://api.wazzup24.com`

### Authentication

**Method**: Bearer token in `Authorization` header

```
Authorization: Bearer YOUR_API_KEY
Content-Type: application/json
```

### Send Message Endpoint

**Endpoint**: `POST /api/v3/messages`

**Request Body**:
```json
{
  "phone": "+77001234567@c.us",
  "message": "Hello from Dreamland PRO!",
  "media_url": "https://example.com/photo.jpg"  // Optional
}
```

**Success Response** (200 OK):
```json
{
  "messageId": "msg_abc123xyz"
}
```

**Error Response** (400 Bad Request):
```json
{
  "message": "Invalid phone number format"
}
```

### Phone Number Format

**IMPORTANT: Updated for wazzup24 API v3**

wazzup24 API expects phone numbers **without** the `@c.us` suffix:

**API Format** (for sending): `[country_code][number]` (no + prefix, no @c.us)
- Russia: `79001234567`
- Kazakhstan: `77001234567`
- USA: `11234567890`

**Webhook Format** (receiving): `[country_code][number]@c.us`
- wazzup24 **sends** `@c.us` in webhook payloads
- We **strip** it before storing in database

**Our Database Format**: `+[country_code][number]` (standard E.164)
- Russia: `+79001234567`
- Kazakhstan: `+77001234567`
- USA: `+11234567890`

**Normalization Flow**:
1. **Incoming** (from webhook): `77001234567@c.us` → strip @c.us → add + → `+77001234567` (DB)
2. **Outgoing** (to API): `+77001234567` (DB) → strip + → `77001234567` (API)

The `Wazzup24Client` automatically:
- **For incoming**: Removes `@c.us` suffix, adds `+` prefix
- **For outgoing**: Removes `+` prefix (API requirement)
- Removes spaces, dashes, parentheses: `+7 (900) 123-45-67` → `+79001234567`

### Rate Limits

**wazzup24 limits**:
- Check with your wazzup24 account manager
- Typical: 1000 messages/day for basic plans
- Enterprise plans: Higher limits available

**Implementation**: Currently no rate limiting in CRM. Consider adding if needed:
```ruby
# Future: Use Rails cache for rate limiting
cache_key = "whatsapp_rate_limit:#{Date.today}"
count = Rails.cache.increment(cache_key)
Rails.cache.write(cache_key, count, expires_in: 24.hours) if count == 1
```

### Webhook Callbacks (Inbound - Already Implemented)

**Endpoint**: `POST /webhooks/wazzup24`

**Handler**: `Whatsapp::MessageHandler` service

**Status Updates**: The wazzup24 API can send webhooks for:
- Message delivered
- Message read
- Message failed

**Note**: Status webhook handling is not yet implemented. Currently only tracks:
- `pending` - Created in CRM, not yet sent
- `sent` - Successfully sent to wazzup24 API
- `failed` - API returned error

---

## Code Reference

### File Structure

```
app/
├── clients/
│   └── wazzup24_client.rb              # HTTP API wrapper
├── controllers/
│   ├── communications_controller.rb     # Message sending controller
│   └── whatsapp_templates_controller.rb # Template CRUD
├── services/
│   └── whatsapp/
│       └── send_message_service.rb      # Message sending orchestration
├── models/
│   ├── whatsapp_template.rb            # Template model (pre-existing)
│   └── communication.rb                 # Communication model (pre-existing)
└── views/
    ├── leads/
    │   └── show.html.erb                # Updated with message form
    └── whatsapp_templates/
        ├── index.html.erb               # Template list
        ├── show.html.erb                # Template details
        ├── new.html.erb                 # Create template
        ├── edit.html.erb                # Edit template
        └── _form.html.erb               # Form partial

test/
└── clients/
    └── wazzup24_client_test.rb          # API client tests
```

### Key Classes

#### Wazzup24Client

**Location**: `app/clients/wazzup24_client.rb`

**Purpose**: HTTP wrapper for wazzup24 REST API

**Methods**:
- `initialize(api_key = nil)` - Set up client with API key from credentials
- `send_message(phone:, message:, media_url: nil)` - Send WhatsApp message
- `normalize_phone(phone)` - Convert phone to wazzup24 format (private)
- `handle_response(response)` - Parse API response (private)

**Returns**: Hash with `:success` boolean and `:data` or `:error`

**Example**:
```ruby
client = Wazzup24Client.new
result = client.send_message(
  phone: '+7 900 123 45 67',
  message: 'Hello!'
)
# => { success: true, data: { 'messageId' => 'msg_123' } }
```

#### Whatsapp::SendMessageService

**Location**: `app/services/whatsapp/send_message_service.rb`

**Purpose**: Orchestrate complete message sending workflow

**Responsibilities**:
1. Render template (if provided) using `WhatsappTemplate#render_for`
2. Create `Communication` record with status: `pending`
3. Call `Wazzup24Client` to send message
4. Update communication status based on API response
5. Handle errors and log failures

**Methods**:
- `initialize(client:, body:, template: nil)` - Set up service
- `call` - Execute workflow
- `render_message` - Render template or return body (private)
- `create_communication(message_body)` - Create DB record (private)

**Example**:
```ruby
service = Whatsapp::SendMessageService.new(
  client: Client.find(1),
  body: "Custom message",
  template: nil
)

result = service.call
# => { success: true, communication: #<Communication id: 123> }
```

#### WhatsappTemplatesController

**Location**: `app/controllers/whatsapp_templates_controller.rb`

**Actions**:
- `index` - List templates with filters and stats
- `show` - View template details with preview
- `new` - Template creation form
- `create` - Save new template
- `edit` - Template edit form
- `update` - Save template changes
- `destroy` - Delete template
- `toggle_active` - Enable/disable template

**Before Actions**:
- `require_authentication` - Ensure user is logged in
- `set_template` - Load template for show/edit/update/destroy/toggle_active

#### CommunicationsController (Updated)

**Location**: `app/controllers/communications_controller.rb`

**Updated Methods**:
- `create` - Routes to `send_whatsapp_message` or `send_email_message`
- `send_whatsapp_message` - Handles WhatsApp message sending (NEW)
- `send_email_message` - Placeholder for future email feature (NEW)
- `redirect_back_with_notice(message)` - Helper for success redirects (NEW)
- `redirect_back_with_alert(message)` - Helper for error redirects (NEW)

### Database Models

#### WhatsappTemplate

**Table**: `whatsapp_templates`

**Columns**:
- `name` (string) - Template name
- `category` (enum) - greeting, pricing, availability, confirmation, follow_up, general
- `content` (text) - Template body with variables
- `variables` (json) - Array of variable names (auto-extracted)
- `active` (boolean) - Is template available for use
- `created_at`, `updated_at` (timestamps)

**Scopes**:
- `active` - Only active templates
- `inactive` - Only inactive templates
- `by_category(category)` - Filter by category

**Methods**:
- `render_for(client)` - Replace variables with client data

#### Communication

**Table**: `communications`

**Relevant Columns**:
- `client_id` (foreign key) - Associated client
- `lead_id` (foreign key, optional) - Associated lead
- `booking_id` (foreign key, optional) - Associated booking
- `communication_type` (enum) - whatsapp, email, phone, sms
- `direction` (enum) - inbound, outbound
- `body` (text) - Message content
- `whatsapp_message_id` (string) - wazzup24 message ID
- `whatsapp_status` (enum) - pending, sent, delivered, read, failed
- `created_at`, `updated_at` (timestamps)

**Associations**:
- `belongs_to :client`
- `belongs_to :lead, optional: true`
- `belongs_to :booking, optional: true`

---

## Testing

### Running Tests

```bash
# All client tests
rails test test/clients/

# Specific test file
rails test test/clients/wazzup24_client_test.rb

# With verbose output
rails test test/clients/wazzup24_client_test.rb -v
```

### Test Coverage

**Current Coverage**:
- ✅ Wazzup24Client - HTTP request/response handling
- ✅ Phone normalization
- ✅ Error handling (timeouts, API errors)
- ✅ Media URL inclusion
- ⏳ SendMessageService - Pending implementation
- ⏳ WhatsappTemplatesController - Pending implementation

**Test Files**:
```
test/
└── clients/
    └── wazzup24_client_test.rb  # 6 test cases
```

### Manual Testing Checklist

#### Message Sending Flow

- [ ] Navigate to lead detail page
- [ ] Verify message form displays correctly
- [ ] Select "WhatsApp" as message type
- [ ] Type custom message
- [ ] Click "Send Message"
- [ ] Verify success notice appears
- [ ] Check communication appears in timeline
- [ ] Verify communication status is "sent" or "failed"

#### Template Selection Flow

- [ ] Navigate to lead detail page
- [ ] Select template from dropdown
- [ ] Verify message body updates (if JS implemented)
- [ ] Send message with template
- [ ] Check communication body has variables replaced
- [ ] Verify `{{name}}` replaced with actual client name

#### Template Management

- [ ] Navigate to `/whatsapp_templates`
- [ ] Verify stats cards display correctly
- [ ] Create new template
- [ ] Verify preview shows rendered content
- [ ] Edit template
- [ ] Toggle template active status
- [ ] Filter by category
- [ ] Delete unused template

### WebMock Test Examples

```ruby
# test/clients/wazzup24_client_test.rb

test 'sends message successfully' do
  stub_request(:post, 'https://api.wazzup24.com/api/v3/messages')
    .with(
      headers: {
        'Authorization' => 'Bearer test_api_key',
        'Content-Type' => 'application/json'
      },
      body: {
        phone: '+1234567890@c.us',
        message: 'Test message'
      }.to_json
    )
    .to_return(status: 200, body: { messageId: 'msg_123' }.to_json)

  result = @client.send_message(phone: '+1234567890', message: 'Test message')

  assert result[:success]
  assert_equal 'msg_123', result[:data]['messageId']
end
```

---

## Troubleshooting

### Common Issues

#### 1. "undefined method `dig' for nil:NilClass" when sending messages

**Cause**: wazzup24 API key not configured in credentials

**Solution**:
```bash
rails credentials:edit
# Add wazzup24 API key as shown in Setup section
```

#### 2. Messages showing status "failed"

**Possible Causes**:
- Invalid phone number format
- wazzup24 API key incorrect/expired
- Network timeout
- wazzup24 service down

**Debug Steps**:
1. Check Rails logs for error details:
   ```bash
   tail -f log/development.log | grep wazzup24
   ```

2. Verify API key is set:
   ```ruby
   rails console
   > Rails.application.credentials.dig(:wazzup24, :api_key)
   # Should return your API key, not nil
   ```

3. Test API directly with curl:
   ```bash
   curl -X POST https://api.wazzup24.com/api/v3/messages \
     -H "Authorization: Bearer YOUR_API_KEY" \
     -H "Content-Type: application/json" \
     -d '{"phone":"+77001234567@c.us","message":"Test"}'
   ```

#### 3. Phone number not recognized

**Cause**: Phone stored in database doesn't match wazzup24 format

**Solution**: Check phone normalization:
```ruby
rails console
> client = Wazzup24Client.new
> client.send(:normalize_phone, "+7 900 123 45 67")
# Should return: "+79001234567@c.us"
```

**Verify client phone format**:
```ruby
> Client.find(1).phone
# Should have + prefix and country code
```

#### 4. Template variables not replacing

**Cause**: Variable names in template don't match client attributes

**Solution**:
1. Check template content in database:
   ```ruby
   WhatsappTemplate.find(1).content
   # Should show: "Hello {{name}}, ..."
   ```

2. Verify `render_for` method:
   ```ruby
   template = WhatsappTemplate.find(1)
   client = Client.first
   template.render_for(client)
   # Should show: "Hello John Doe, ..." (with actual name)
   ```

3. Check available variables:
   ```ruby
   template.variables  # => ["name", "phone", "email"]
   ```

#### 5. Templates not appearing in dropdown

**Cause**: Templates are inactive

**Solution**:
```ruby
# Check active templates
WhatsappTemplate.active.count

# Activate a template
template = WhatsappTemplate.find(1)
template.update(active: true)
```

#### 6. HTTP timeout errors

**Cause**: wazzup24 API slow to respond (>10 seconds)

**Solution**: Increase timeout in `Wazzup24Client`:
```ruby
# app/clients/wazzup24_client.rb
response = self.class.post('/api/v3/messages',
  headers: @headers,
  body: body.to_json,
  timeout: 30  # Increase from 10 to 30 seconds
)
```

### Error Logging

All errors are logged to Rails logger:

```ruby
# Check logs for WhatsApp errors
tail -f log/development.log | grep -i "whatsapp\|wazzup24"

# Check communication records for failures
Communication.where(whatsapp_status: 'failed').last(10)
```

### Debug Mode

Enable debug mode for HTTP requests:

```ruby
# In rails console
HTTParty.logger(Logger.new($stdout), :debug)

# Then try sending a message
client = Wazzup24Client.new
client.send_message(phone: '+77001234567', message: 'Debug test')
```

---

## Future Enhancements

### Phase 2: Real-time Updates (Turbo Streams)

**Estimated Effort**: 2-3 days

**Features**:
- Broadcast incoming WhatsApp messages to agents in real-time
- Live notification badges for unread messages
- Auto-refresh lead list when new messages arrive
- No page refresh needed

**Technical**:
- Configure SolidCable for WebSockets
- Add Turbo Stream channels
- Broadcast from `Whatsapp::MessageHandler`

### Phase 3: Status Webhooks

**Estimated Effort**: 1 day

**Features**:
- Track message delivery status from wazzup24
- Update communication records: pending → sent → delivered → read
- Display delivery receipts in timeline

**Implementation**:
```ruby
# app/controllers/webhooks/wazzup24_controller.rb
def status_update
  # Parse webhook payload
  message_id = params[:messageId]
  status = params[:status]  # 'delivered', 'read', 'failed'

  # Update communication
  communication = Communication.find_by(whatsapp_message_id: message_id)
  communication&.update(whatsapp_status: status)

  head :ok
end
```

### Phase 4: Rich Media Support

**Estimated Effort**: 1-2 days

**Features**:
- Send images, videos, PDFs via WhatsApp
- Preview media in communication timeline
- Upload from CRM interface

**Technical**:
- Add file upload to message form
- Store media in Active Storage
- Pass `media_url` to wazzup24 API

### Phase 5: Message Scheduling

**Estimated Effort**: 2 days

**Features**:
- Schedule messages for future delivery
- Recurring messages (follow-ups)
- Timezone-aware scheduling

**Technical**:
- Use SolidQueue for background jobs
- Add `scheduled_at` column to communications
- Create `ScheduledMessageJob`

### Phase 6: Analytics Dashboard

**Estimated Effort**: 2-3 days

**Features**:
- Messages sent per day/week/month
- Response time metrics
- Template usage statistics
- Agent performance reports

### Phase 7: Bulk Messaging

**Estimated Effort**: 2-3 days

**Features**:
- Send same message to multiple leads
- CSV import for bulk campaigns
- Rate limiting to avoid wazzup24 limits
- Queue management

**Note**: Ensure compliance with WhatsApp Business policies before implementing.

### Phase 8: Quick Replies & Buttons

**Estimated Effort**: 3 days

**Features**:
- Interactive buttons in WhatsApp messages
- Quick reply options
- List messages

**Technical**:
- Requires wazzup24 Business API support
- Update `Wazzup24Client` for new message types
- Handle button click webhooks

---

## Appendix A: Configuration Reference

### Environment Variables

No environment variables needed. All configuration via Rails credentials.

### Rails Credentials Structure

```yaml
# config/credentials.yml.enc (encrypted)
wazzup24:
  api_key: your_api_key_here_from_wazzup24_dashboard

# Access in code:
Rails.application.credentials.dig(:wazzup24, :api_key)
```

### Database Indexes

Ensure these indexes exist for performance:

```ruby
# communications table
add_index :communications, :whatsapp_message_id
add_index :communications, :whatsapp_status
add_index :communications, [:client_id, :created_at]

# whatsapp_templates table
add_index :whatsapp_templates, :active
add_index :whatsapp_templates, :category
```

---

## Appendix B: Glossary

**wazzup24**: WhatsApp Business API provider integrated with this CRM

**Communication**: Database record storing all client interactions (WhatsApp, email, phone, SMS)

**Template**: Reusable message with variable placeholders

**Variable**: Placeholder in template that gets replaced with client data (e.g., `{{name}}`)

**Outbound**: Messages sent from CRM to customers

**Inbound**: Messages received from customers via webhook

**Status**: Message delivery state (pending, sent, delivered, read, failed)

**Message ID**: Unique identifier returned by wazzup24 API for tracking

---

## Support

**Internal Documentation**: This file (`docs/WHATSAPP_INTEGRATION.md`)

**External API Docs**: https://wazzup24.com/help/api-en/

**wazzup24 Support**: Contact your wazzup24 account manager

**CRM Issues**: Report to development team

---

**Document Version**: 1.0
**Last Updated**: January 2026
**Author**: Claude Code Assistant
**Status**: Production Ready
