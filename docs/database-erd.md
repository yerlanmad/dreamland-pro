# Database ERD - Dreamland PRO

## Entity Relationship Diagram

```mermaid
erDiagram
    users ||--o{ leads : "assigned_agent"
    leads ||--o| bookings : "has_one"
    tours ||--o{ tour_departures : "has_many"
    tour_departures ||--o{ bookings : "has_many"
    leads ||--o{ communications : "polymorphic"
    bookings ||--o{ communications : "polymorphic"
    bookings ||--o{ payments : "has_many"
    tours ||--o{ leads : "tour_interest"

    users {
        integer id PK
        string email UK "NOT NULL"
        string name "NOT NULL"
        string password_digest "NOT NULL"
        string role "DEFAULT agent, NOT NULL"
        string preferred_language "DEFAULT ru"
        string preferred_currency "DEFAULT KZT"
        datetime created_at
        datetime updated_at
    }

    leads {
        integer id PK
        string name "NOT NULL"
        string phone UK "NOT NULL"
        string email
        string status "DEFAULT new, NOT NULL"
        string source "DEFAULT whatsapp, NOT NULL"
        integer assigned_agent_id FK
        integer tour_interest_id FK
        integer unread_messages_count "DEFAULT 0"
        datetime last_message_at
        datetime created_at
        datetime updated_at
    }

    tours {
        integer id PK
        string name
        text description
        decimal base_price
        string currency
        integer capacity
        integer duration_days
        boolean active
        datetime created_at
        datetime updated_at
    }

    tour_departures {
        integer id PK
        integer tour_id FK "NOT NULL"
        date departure_date
        decimal price
        string currency
        integer capacity
        datetime created_at
        datetime updated_at
    }

    bookings {
        integer id PK
        integer lead_id FK "NOT NULL"
        integer tour_departure_id FK "NOT NULL"
        integer num_participants
        decimal total_amount
        string currency
        string status
        datetime created_at
        datetime updated_at
    }

    communications {
        integer id PK
        string communicable_type "NOT NULL"
        integer communicable_id "NOT NULL"
        string communication_type "NOT NULL"
        string direction "NOT NULL"
        text body
        string subject
        string whatsapp_message_id
        string whatsapp_status
        string media_url
        string media_type
        datetime created_at
        datetime updated_at
    }

    payments {
        integer id PK
        integer booking_id FK "NOT NULL"
        decimal amount
        string currency
        date payment_date
        string payment_method
        string status
        datetime created_at
        datetime updated_at
    }

    whatsapp_templates {
        integer id PK
        string name
        text content
        string category
        text variables
        boolean active
        datetime created_at
        datetime updated_at
    }
```

## Relationship Details

### Users → Leads
- **Type:** One-to-Many (optional)
- **Foreign Key:** `leads.assigned_agent_id` → `users.id`
- **Description:** Users (agents) can be assigned multiple leads

### Leads → Tour (tour_interest)
- **Type:** Many-to-One (optional)
- **Foreign Key:** `leads.tour_interest_id` → `tours.id`
- **Description:** Leads can express interest in a specific tour

### Leads → Bookings
- **Type:** One-to-One
- **Foreign Key:** `bookings.lead_id` → `leads.id`
- **Description:** A lead can be converted to one booking

### Tours → Tour Departures
- **Type:** One-to-Many
- **Foreign Key:** `tour_departures.tour_id` → `tours.id`
- **Description:** Tours have multiple departure dates

### Tour Departures → Bookings
- **Type:** One-to-Many
- **Foreign Key:** `bookings.tour_departure_id` → `tour_departures.id`
- **Description:** Each departure can have multiple bookings

### Bookings → Payments
- **Type:** One-to-Many
- **Foreign Key:** `payments.booking_id` → `bookings.id`
- **Description:** Bookings can have multiple payment installments

### Communications (Polymorphic)
- **Type:** Polymorphic Many-to-One
- **Foreign Keys:** `communicable_type` + `communicable_id`
- **Targets:** Leads, Bookings
- **Description:** Communications can belong to either leads or bookings

### WhatsApp Templates
- **Type:** Standalone table (no foreign keys)
- **Description:** Message templates for WhatsApp communications

## Enum Values

### users.role
- `agent` (default)
- `manager`
- `admin`

### users.preferred_language
- `en`
- `ru` (default)

### users.preferred_currency / bookings.currency / payments.currency
- `USD`
- `KZT` (default for users)
- `EUR`
- `RUB`

### leads.status
- `new` (default)
- `contacted`
- `qualified`
- `quoted`
- `won`
- `lost`

### leads.source
- `whatsapp` (default)
- `website`
- `manual`
- `import`

### bookings.status
- `confirmed`
- `paid`
- `completed`
- `cancelled`

### communications.communication_type
- `whatsapp`
- `email`
- `phone`
- `sms`

### communications.direction
- `inbound`
- `outbound`

## Indexes

### Unique Indexes
- `users.email`
- `leads.phone`

### Foreign Key Indexes
- `leads.assigned_agent_id`
- `bookings.lead_id`
- `bookings.tour_departure_id`
- `payments.booking_id`
- `tour_departures.tour_id`
- `communications.communicable_type + communicable_id`

### Query Optimization Indexes
- `leads.status`
- `leads.source`
- `communications.communication_type`
- `communications.whatsapp_message_id`
