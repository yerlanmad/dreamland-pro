# Dreamland PRO CRM

**WhatsApp-First Tour Sales CRM System**

A specialized CRM built for tour operators and travel agencies with native WhatsApp integration, multi-language support (Russian/English), and multi-currency capabilities (USD, KZT, EUR, RUB).

## Documentation

📋 **[Product Requirements Document](docs/PRD.md)** - Complete PRD with business requirements, technical specifications, and implementation roadmap

## Tech Stack

- **Framework:** Ruby on Rails 8.0+
- **Database:** SQLite3 (Phase 1) → PostgreSQL (Phase 2)
- **Frontend:** Hotwire (Turbo + Stimulus), Tailwind CSS
- **Background Jobs:** SolidQueue (database-backed)
- **Caching:** SolidCache (database-backed)
- **WebSockets:** SolidCable (database-backed)
- **Authentication:** Rails 8 built-in authentication
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

# Setup database
rails db:create db:migrate

# Start the server
rails server
```

### Configuration

1. Set up environment variables (copy `.env.example` to `.env`)
2. Configure wazzup24 API credentials
3. Configure email delivery (SendGrid or similar)

## Development

```bash
# Run tests
rails test

# Run linter
rubocop

# Start development server
rails server
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
