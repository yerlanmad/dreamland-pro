# Dreamland PRO CRM

**WhatsApp-First Tour Sales CRM System**

A specialized CRM built for tour operators and travel agencies with native WhatsApp integration, multi-language support (Russian/English), and multi-currency capabilities (USD, KZT, EUR, RUB).

## Documentation

📋 **[Product Requirements Document](docs/PRD.md)** - Complete PRD with business requirements, technical specifications, and implementation roadmap

## Tech Stack

- **Framework:** Ruby on Rails 8.1.1
- **Database:** SQLite3 (Phase 1) → PostgreSQL (Phase 2)
- **Frontend:** Hotwire (Turbo + Stimulus), Tailwind CSS 3.3.2
- **Background Jobs:** SolidQueue (database-backed)
- **Caching:** SolidCache (database-backed)
- **WebSockets:** SolidCable (database-backed)
- **Authentication:** Rails 8 built-in authentication (implemented)
- **Testing:** RSpec + FactoryBot + Faker
- **Deployment:** Kamal 2

## Key Features

- 📱 **WhatsApp Integration** via wazzup24 API (primary communication channel)
- 🌍 **Multi-Language** (Russian & English)
- 💰 **Multi-Currency** (USD, KZT, EUR, RUB)
- 👥 **Lead Management** with automatic capture from WhatsApp
- 📅 **Booking Management** with tour capacity tracking
- 💳 **Payment Tracking** with invoicing
- 📊 **Analytics & Reporting** for sales performance

## Getting Started

### Prerequisites

- Ruby 3.3+
- SQLite3
- Node.js (for Tailwind CSS)

### Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/dreamland-pro.git
cd dreamland-pro

# Install dependencies
bundle install

# Setup database and seed demo data
rails db:create db:migrate db:seed

# Start the development server with Tailwind CSS watcher (recommended)
bin/dev

# Or start without Tailwind watcher
rails server
```

The application will be available at `http://localhost:3000`

**Demo Credentials:**
- Admin: `admin@dreamland.pro` / `password123`
- Manager: `manager@dreamland.pro` / `password123`
- Agent: `agent@dreamland.pro` / `password123`

### Configuration

1. Set up environment variables (copy `.env.example` to `.env`)
2. Configure wazzup24 API credentials
3. Configure email delivery (SendGrid or similar)

## Development

### Running the Application

```bash
# Start with Tailwind CSS watcher (recommended)
bin/dev

# Or start Rails server only
rails server
```

### Tailwind CSS

```bash
# Build Tailwind CSS
rails tailwindcss:build

# Watch for changes
rails tailwindcss:watch
```

### Testing

```bash
# Run all tests
bundle exec rspec

# Run specific test file
bundle exec rspec spec/models/user_spec.rb

# Run with coverage
COVERAGE=true bundle exec rspec
```

### Code Quality

```bash
# Run linter
rubocop

# Auto-fix issues
rubocop -a

# Security audit
bundle exec bundler-audit check
bundle exec brakeman
```

## Deployment

This application uses Kamal 2 for deployment.

```bash
# Deploy to production
kamal deploy
```

See [Kamal documentation](https://kamal-deploy.org) for more details.

## Project Structure

```
dreamland-pro/
├── app/               # Application code
│   ├── models/        # ActiveRecord models
│   ├── controllers/   # Controllers
│   ├── views/         # Views (Turbo + Stimulus)
│   └── jobs/          # Background jobs (SolidQueue)
├── config/            # Configuration
│   └── locales/       # I18n translations (en, ru)
├── db/                # Database migrations and schema
├── docs/              # Documentation
│   └── PRD.md         # Product Requirements Document
└── test/              # Tests

```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

[Specify your license here]

## Contact

For questions or support, please contact [your contact information]
