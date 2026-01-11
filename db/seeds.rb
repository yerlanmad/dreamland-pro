# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "🌱 Seeding database..."

# Clean up existing data in development
if Rails.env.development?
  puts "\n🧹 Cleaning existing data..."
  [Payment, Booking, Communication, Lead, TourDeparture, Tour, Client, WhatsappTemplate, User].each do |model|
    model.destroy_all
  end
end

# ============================================================================
# USERS
# ============================================================================
puts "\n👥 Creating users..."

users_data = [
  {
    name: "Admin User",
    email: "admin@dreamland.pro",
    password: "password123",
    password_confirmation: "password123",
    role: :admin,
    preferred_language: :en,
    preferred_currency: :USD
  },
  {
    name: "Алексей Петров",
    email: "manager@dreamland.pro",
    password: "password123",
    password_confirmation: "password123",
    role: :manager,
    preferred_language: :ru,
    preferred_currency: :KZT
  },
  {
    name: "Анна Смирнова",
    email: "anna@dreamland.pro",
    password: "password123",
    password_confirmation: "password123",
    role: :agent,
    preferred_language: :ru,
    preferred_currency: :KZT
  },
  {
    name: "Марат Жусупов",
    email: "marat@dreamland.pro",
    password: "password123",
    password_confirmation: "password123",
    role: :agent,
    preferred_language: :ru,
    preferred_currency: :KZT
  },
  {
    name: "Elena Rodriguez",
    email: "elena@dreamland.pro",
    password: "password123",
    password_confirmation: "password123",
    role: :agent,
    preferred_language: :en,
    preferred_currency: :USD
  }
]

users = {}
users_data.each do |user_attrs|
  user = User.create!(user_attrs)
  users[user.email] = user
  puts "  ✓ Created #{user.role}: #{user.name} (#{user.email})"
end

# ============================================================================
# TOURS
# ============================================================================
puts "\n🏔️  Creating tours..."

tours_data = [
  {
    name: "Altai Mountains Adventure",
    description: "Explore the pristine beauty of Altai Mountains with hiking, horseback riding, and camping under the stars. Visit sacred mountains and crystal-clear lakes.",
    base_price: 850.00,
    currency: :USD,
    duration_days: 7,
    capacity: 12,
    active: true
  },
  {
    name: "Charyn Canyon Explorer",
    description: "Day trip to the spectacular Charyn Canyon, known as Kazakhstan's Grand Canyon. Marvel at the Valley of Castles rock formations.",
    base_price: 85000.00,
    currency: :KZT,
    duration_days: 1,
    capacity: 20,
    active: true
  },
  {
    name: "Silk Road Heritage Tour",
    description: "Journey through ancient Silk Road cities: Turkestan, Otrar, and Sayram. Discover UNESCO World Heritage sites and immerse in local culture.",
    base_price: 1200.00,
    currency: :USD,
    duration_days: 5,
    capacity: 15,
    active: true
  },
  {
    name: "Big Almaty Lake & Mountain Pass",
    description: "Visit the turquoise Big Almaty Lake and cross mountain passes with panoramic views. Perfect for photography enthusiasts.",
    base_price: 45000.00,
    currency: :KZT,
    duration_days: 1,
    capacity: 8,
    active: true
  },
  {
    name: "Kolsai & Kaindy Lakes Trek",
    description: "Multi-day trek through the stunning Kolsai Lakes and the famous sunken forest at Kaindy Lake. Moderate difficulty.",
    base_price: 650.00,
    currency: :EUR,
    duration_days: 3,
    capacity: 10,
    active: true
  },
  {
    name: "Winter Shymbulak Ski Resort",
    description: "Ski and snowboard at Shymbulak resort with modern lifts and pristine slopes. Includes equipment rental and instructor.",
    base_price: 75000.00,
    currency: :RUB,
    duration_days: 2,
    capacity: 15,
    active: true
  }
]

tours = {}
tours_data.each do |tour_attrs|
  tour = Tour.create!(tour_attrs)
  tours[tour.name] = tour
  puts "  ✓ Created tour: #{tour.name} (#{tour.currency} #{tour.base_price})"
end

# ============================================================================
# TOUR DEPARTURES
# ============================================================================
puts "\n📅 Creating tour departures..."

tour_departures = []

# Altai Mountains - 3 departures
[15, 45, 75].each do |days_ahead|
  departure = TourDeparture.create!(
    tour: tours["Altai Mountains Adventure"],
    departure_date: Date.today + days_ahead.days,
    price: 850.00,
    currency: :USD,
    capacity: 12
  )
  tour_departures << departure
  puts "  ✓ Altai Mountains: #{departure.departure_date.strftime('%d %b %Y')}"
end

# Charyn Canyon - 5 departures (frequent day trips)
[3, 10, 17, 24, 31].each do |days_ahead|
  departure = TourDeparture.create!(
    tour: tours["Charyn Canyon Explorer"],
    departure_date: Date.today + days_ahead.days,
    price: 85000.00,
    currency: :KZT,
    capacity: 20
  )
  tour_departures << departure
  puts "  ✓ Charyn Canyon: #{departure.departure_date.strftime('%d %b %Y')}"
end

# Silk Road - 2 departures
[20, 50].each do |days_ahead|
  departure = TourDeparture.create!(
    tour: tours["Silk Road Heritage Tour"],
    departure_date: Date.today + days_ahead.days,
    price: 1200.00,
    currency: :USD,
    capacity: 15
  )
  tour_departures << departure
  puts "  ✓ Silk Road: #{departure.departure_date.strftime('%d %b %Y')}"
end

# Big Almaty Lake - 4 departures
[5, 12, 19, 26].each do |days_ahead|
  departure = TourDeparture.create!(
    tour: tours["Big Almaty Lake & Mountain Pass"],
    departure_date: Date.today + days_ahead.days,
    price: 45000.00,
    currency: :KZT,
    capacity: 8
  )
  tour_departures << departure
  puts "  ✓ Big Almaty Lake: #{departure.departure_date.strftime('%d %b %Y')}"
end

# Kolsai Lakes - 2 departures
[25, 55].each do |days_ahead|
  departure = TourDeparture.create!(
    tour: tours["Kolsai & Kaindy Lakes Trek"],
    departure_date: Date.today + days_ahead.days,
    price: 650.00,
    currency: :EUR,
    capacity: 10
  )
  tour_departures << departure
  puts "  ✓ Kolsai Lakes: #{departure.departure_date.strftime('%d %b %Y')}"
end

# Winter Ski Resort - 3 departures
[7, 14, 21].each do |days_ahead|
  departure = TourDeparture.create!(
    tour: tours["Winter Shymbulak Ski Resort"],
    departure_date: Date.today + days_ahead.days,
    price: 75000.00,
    currency: :RUB,
    capacity: 15
  )
  tour_departures << departure
  puts "  ✓ Shymbulak Ski: #{departure.departure_date.strftime('%d %b %Y')}"
end

# ============================================================================
# CLIENTS
# ============================================================================
puts "\n👤 Creating clients..."

clients_data = [
  { name: "Мария Иванова", phone: "+77011234567", email: "maria.ivanova@mail.ru", preferred_language: :ru },
  { name: "John Smith", phone: "+12125551234", email: "john.smith@gmail.com", preferred_language: :en },
  { name: "Асель Нурбекова", phone: "+77021234567", email: "asel.n@mail.kz", preferred_language: :ru },
  { name: "David Chen", phone: "+14155551234", email: "david.chen@yahoo.com", preferred_language: :en },
  { name: "Ольга Петрова", phone: "+77051234567", email: "olga.petrova@yandex.ru", preferred_language: :ru },
  { name: "Sarah Johnson", phone: "+447700123456", email: "sarah.j@outlook.com", preferred_language: :en },
  { name: "Нурлан Абдуллаев", phone: "+77761234567", email: "nurlan.a@gmail.com", preferred_language: :ru },
  { name: "Emma Wilson", phone: "+61412345678", email: "emma.wilson@gmail.com", preferred_language: :en },
  { name: "Дмитрий Козлов", phone: "+77011234568", email: "dmitry.k@mail.ru", preferred_language: :ru },
  { name: "Michael Brown", phone: "+13105551234", email: "michael.brown@gmail.com", preferred_language: :en }
]

clients = {}
clients_data.each do |client_attrs|
  client = Client.create!(client_attrs)
  clients[client.phone] = client
  puts "  ✓ Created client: #{client.name} (#{client.phone})"
end

# ============================================================================
# LEADS
# ============================================================================
puts "\n📋 Creating leads..."

# Helper to get random agent
def random_agent(users)
  agent_emails = users.select { |_, u| u.role == 'agent' }.keys
  users[agent_emails.sample]
end

leads_data = [
  # New lead - Maria (first inquiry)
  {
    client: clients["+77011234567"],
    status: :new,
    source: :whatsapp,
    assigned_agent: random_agent(users),
    tour_interest: tours["Charyn Canyon Explorer"],
    unread_messages_count: 2,
    last_message_at: 1.hour.ago
  },
  # Contacted lead - John
  {
    client: clients["+12125551234"],
    status: :contacted,
    source: :whatsapp,
    assigned_agent: users["elena@dreamland.pro"],
    tour_interest: tours["Altai Mountains Adventure"],
    unread_messages_count: 0,
    last_message_at: 2.days.ago
  },
  # Qualified lead - Assel
  {
    client: clients["+77021234567"],
    status: :qualified,
    source: :website,
    assigned_agent: users["anna@dreamland.pro"],
    tour_interest: tours["Silk Road Heritage Tour"],
    unread_messages_count: 0,
    last_message_at: 3.days.ago
  },
  # Quoted lead - David
  {
    client: clients["+14155551234"],
    status: :quoted,
    source: :whatsapp,
    assigned_agent: users["elena@dreamland.pro"],
    tour_interest: tours["Kolsai & Kaindy Lakes Trek"],
    unread_messages_count: 1,
    last_message_at: 1.day.ago
  },
  # Won lead - Olga (converted to booking)
  {
    client: clients["+77051234567"],
    status: :won,
    source: :whatsapp,
    assigned_agent: users["marat@dreamland.pro"],
    tour_interest: tours["Big Almaty Lake & Mountain Pass"],
    unread_messages_count: 0,
    last_message_at: 5.days.ago
  },
  # Lost lead - Sarah
  {
    client: clients["+447700123456"],
    status: :lost,
    source: :manual,
    assigned_agent: users["elena@dreamland.pro"],
    tour_interest: tours["Altai Mountains Adventure"],
    unread_messages_count: 0,
    last_message_at: 10.days.ago
  },
  # Second lead from Maria (returning customer - new inquiry!)
  {
    client: clients["+77011234567"],
    status: :contacted,
    source: :whatsapp,
    assigned_agent: users["anna@dreamland.pro"],
    tour_interest: tours["Altai Mountains Adventure"],
    unread_messages_count: 0,
    last_message_at: 12.hours.ago
  },
  # New lead - Nurlan
  {
    client: clients["+77761234567"],
    status: :new,
    source: :whatsapp,
    assigned_agent: users["marat@dreamland.pro"],
    tour_interest: tours["Winter Shymbulak Ski Resort"],
    unread_messages_count: 3,
    last_message_at: 30.minutes.ago
  }
]

leads = []
leads_data.each_with_index do |lead_attrs, index|
  lead = Lead.create!(lead_attrs)
  leads << lead
  returning = lead.client.leads.count > 1 ? "🔄 RETURNING" : ""
  puts "  ✓ Lead ##{lead.id}: #{lead.client.name} - #{lead.status} #{returning}"
end

# ============================================================================
# BOOKINGS
# ============================================================================
puts "\n🎫 Creating bookings..."

bookings_data = [
  # Booking from won lead (Olga)
  {
    client: clients["+77051234567"],
    lead: leads.find { |l| l.client == clients["+77051234567"] && l.status == 'won' },
    tour_departure: tour_departures.find { |td| td.tour == tours["Big Almaty Lake & Mountain Pass"] },
    num_participants: 2,
    total_amount: 90000.00,
    currency: :KZT,
    status: :paid
  },
  # Direct booking without lead (Emma - repeat customer)
  {
    client: clients["+61412345678"],
    lead: nil,
    tour_departure: tour_departures.find { |td| td.tour == tours["Charyn Canyon Explorer"] },
    num_participants: 1,
    total_amount: 85000.00,
    currency: :KZT,
    status: :confirmed
  },
  # Booking from Dmitry
  {
    client: clients["+77011234568"],
    lead: nil,
    tour_departure: tour_departures.find { |td| td.tour == tours["Silk Road Heritage Tour"] },
    num_participants: 2,
    total_amount: 2400.00,
    currency: :USD,
    status: :paid
  },
  # Booking from Michael
  {
    client: clients["+13105551234"],
    lead: nil,
    tour_departure: tour_departures[0], # Altai Mountains
    num_participants: 1,
    total_amount: 850.00,
    currency: :USD,
    status: :confirmed
  }
]

bookings = []
bookings_data.each do |booking_attrs|
  booking = Booking.create!(booking_attrs)
  bookings << booking
  lead_info = booking.lead_id ? "from Lead ##{booking.lead_id}" : "direct booking"
  puts "  ✓ #{booking.reference_number}: #{booking.client_name} - #{booking.tour_name} (#{lead_info})"
end

# ============================================================================
# PAYMENTS
# ============================================================================
puts "\n💰 Creating payments..."

# Payment for Olga's booking (fully paid)
Payment.create!(
  booking: bookings[0],
  amount: 45000.00,
  currency: :KZT,
  payment_date: 4.days.ago,
  payment_method: :bank_transfer,
  status: :completed
)
Payment.create!(
  booking: bookings[0],
  amount: 45000.00,
  currency: :KZT,
  payment_date: 2.days.ago,
  payment_method: :bank_transfer,
  status: :completed
)
puts "  ✓ 2 payments for #{bookings[0].reference_number} (fully paid)"

# Payment for Emma's booking (deposit only)
Payment.create!(
  booking: bookings[1],
  amount: 25000.00,
  currency: :KZT,
  payment_date: 1.day.ago,
  payment_method: :cash,
  status: :completed
)
puts "  ✓ 1 payment for #{bookings[1].reference_number} (deposit)"

# Payments for Dmitry's booking (fully paid)
Payment.create!(
  booking: bookings[2],
  amount: 1200.00,
  currency: :USD,
  payment_date: 6.days.ago,
  payment_method: :credit_card,
  status: :completed
)
Payment.create!(
  booking: bookings[2],
  amount: 1200.00,
  currency: :USD,
  payment_date: 3.days.ago,
  payment_method: :credit_card,
  status: :completed
)
puts "  ✓ 2 payments for #{bookings[2].reference_number} (fully paid)"

# Payment for Michael's booking (pending)
Payment.create!(
  booking: bookings[3],
  amount: 425.00,
  currency: :USD,
  payment_date: Date.today,
  payment_method: :online,
  status: :pending
)
puts "  ✓ 1 payment for #{bookings[3].reference_number} (pending)"

# ============================================================================
# COMMUNICATIONS
# ============================================================================
puts "\n💬 Creating communications..."

# Maria's communications (on her first lead)
maria_lead = leads.find { |l| l.client == clients["+77011234567"] && l.status == 'new' }
Communication.create!(
  client: clients["+77011234567"],
  lead: maria_lead,
  communication_type: :whatsapp,
  direction: :inbound,
  body: "Здравствуйте! Интересует тур в Чарынский каньон. Когда ближайшая дата?",
  whatsapp_message_id: "wamid.#{SecureRandom.hex(16)}",
  whatsapp_status: :delivered,
  created_at: 2.hours.ago
)
Communication.create!(
  client: clients["+77011234567"],
  lead: maria_lead,
  communication_type: :whatsapp,
  direction: :inbound,
  body: "Также хочу узнать стоимость для двоих человек",
  whatsapp_message_id: "wamid.#{SecureRandom.hex(16)}",
  whatsapp_status: :delivered,
  created_at: 1.hour.ago
)
puts "  ✓ 2 WhatsApp messages from Мария Иванова (Lead ##{maria_lead.id})"

# John's communication
john_lead = leads.find { |l| l.client == clients["+12125551234"] }
Communication.create!(
  client: clients["+12125551234"],
  lead: john_lead,
  communication_type: :whatsapp,
  direction: :inbound,
  body: "Hi! I'm interested in the Altai Mountains tour. Can you send me more details?",
  whatsapp_message_id: "wamid.#{SecureRandom.hex(16)}",
  whatsapp_status: :read,
  created_at: 2.days.ago
)
Communication.create!(
  client: clients["+12125551234"],
  lead: john_lead,
  communication_type: :whatsapp,
  direction: :outbound,
  body: "Hello John! Thank you for your interest. The Altai Mountains Adventure is our 7-day premium tour...",
  whatsapp_message_id: "wamid.#{SecureRandom.hex(16)}",
  whatsapp_status: :read,
  created_at: 2.days.ago
)
Communication.create!(
  client: clients["+12125551234"],
  lead: john_lead,
  communication_type: :email,
  direction: :outbound,
  subject: "Altai Mountains Tour - Detailed Itinerary",
  body: "Dear John, Please find attached the detailed itinerary for our Altai Mountains Adventure tour...",
  created_at: 1.day.ago
)
puts "  ✓ 3 communications with John Smith (WhatsApp + Email)"

# Olga's communication (on her booking)
olga_booking = bookings[0]
Communication.create!(
  client: clients["+77051234567"],
  booking: olga_booking,
  communication_type: :whatsapp,
  direction: :outbound,
  body: "Здравствуйте, Ольга! Подтверждаем Вашу бронь #{olga_booking.reference_number}. Встреча в 08:00 у офиса.",
  whatsapp_message_id: "wamid.#{SecureRandom.hex(16)}",
  whatsapp_status: :read,
  created_at: 3.days.ago
)
puts "  ✓ 1 booking confirmation to Ольга Петрова"

# David's communications
david_lead = leads.find { |l| l.client == clients["+14155551234"] }
Communication.create!(
  client: clients["+14155551234"],
  lead: david_lead,
  communication_type: :whatsapp,
  direction: :inbound,
  body: "Hello! I received your quote for Kolsai Lakes. Looks great! One question - is camping equipment included?",
  whatsapp_message_id: "wamid.#{SecureRandom.hex(16)}",
  whatsapp_status: :delivered,
  created_at: 1.day.ago
)
puts "  ✓ 1 WhatsApp message from David Chen"

# Nurlan's communications (very recent)
nurlan_lead = leads.find { |l| l.client == clients["+77761234567"] }
Communication.create!(
  client: clients["+77761234567"],
  lead: nurlan_lead,
  communication_type: :whatsapp,
  direction: :inbound,
  body: "Саламатсызба! Шымбұлақта шаңғы тұратын тур бар ма?",
  whatsapp_message_id: "wamid.#{SecureRandom.hex(16)}",
  whatsapp_status: :delivered,
  created_at: 30.minutes.ago
)
Communication.create!(
  client: clients["+77761234567"],
  lead: nurlan_lead,
  communication_type: :whatsapp,
  direction: :inbound,
  body: "Киім мен шаңғы жабдықтарын жалдауға бола ма?",
  whatsapp_message_id: "wamid.#{SecureRandom.hex(16)}",
  whatsapp_status: :delivered,
  created_at: 25.minutes.ago
)
Communication.create!(
  client: clients["+77761234567"],
  lead: nurlan_lead,
  communication_type: :whatsapp,
  direction: :inbound,
  body: "Бағасы қанша?",
  whatsapp_message_id: "wamid.#{SecureRandom.hex(16)}",
  whatsapp_status: :delivered,
  created_at: 20.minutes.ago
)
puts "  ✓ 3 recent WhatsApp messages from Нурлан Абдуллаев (NEEDS RESPONSE)"

# ============================================================================
# WHATSAPP TEMPLATES
# ============================================================================
puts "\n📱 Creating WhatsApp templates..."

templates_data = [
  {
    name: "Greeting - Russian",
    content: "Здравствуйте, {{name}}! Спасибо за интерес к нашим турам. Чем могу помочь?",
    category: :greeting,
    variables: ["name"],
    active: true
  },
  {
    name: "Greeting - English",
    content: "Hello {{name}}! Thank you for your interest in Dreamland PRO tours. How can I help you today?",
    category: :greeting,
    variables: ["name"],
    active: true
  },
  {
    name: "Tour Info - Russian",
    content: "{{name}}, информация о туре \"{{tour_name}}\": длительность {{tour_duration}}, стоимость {{tour_price}}. Хотите узнать больше?",
    category: :pricing,
    variables: ["name", "tour_name", "tour_duration", "tour_price"],
    active: true
  },
  {
    name: "Tour Info - English",
    content: "Hi {{name}}! Here's info about \"{{tour_name}}\": duration {{tour_duration}}, price {{tour_price}}. Would you like more details?",
    category: :pricing,
    variables: ["name", "tour_name", "tour_duration", "tour_price"],
    active: true
  },
  {
    name: "Booking Confirmation - Russian",
    content: "{{name}}, Ваша бронь {{booking_reference}} подтверждена! Дата: {{departure_date}}, сумма: {{booking_total}}. До встречи!",
    category: :confirmation,
    variables: ["name", "booking_reference", "departure_date", "booking_total"],
    active: true
  },
  {
    name: "Booking Confirmation - English",
    content: "{{name}}, your booking {{booking_reference}} is confirmed! Date: {{departure_date}}, total: {{booking_total}}. See you soon!",
    category: :confirmation,
    variables: ["name", "booking_reference", "departure_date", "booking_total"],
    active: true
  },
  {
    name: "Payment Reminder - Russian",
    content: "Здравствуйте, {{name}}! Напоминаем об оплате бронирования {{booking_reference}}. Ждем оплату до {{departure_date}}.",
    category: :follow_up,
    variables: ["name", "booking_reference", "departure_date"],
    active: true
  },
  {
    name: "Availability Check - Russian",
    content: "{{name}}, тур \"{{tour_name}}\" доступен на {{departure_date}}. Осталось мест: {{available_spots}}. Забронировать?",
    category: :availability,
    variables: ["name", "tour_name", "departure_date", "available_spots"],
    active: true
  }
]

templates_data.each do |template_attrs|
  template = WhatsappTemplate.create!(template_attrs)
  puts "  ✓ Template: #{template.name} (#{template.category})"
end

# ============================================================================
# SUMMARY
# ============================================================================
puts "\n" + "="*70
puts "✅ Seeding complete!"
puts "="*70
puts "\n📊 Database Summary:"
puts "  • Users: #{User.count} (#{User.admins.count} admin, #{User.managers.count} manager, #{User.agents.count} agents)"
puts "  • Clients: #{Client.count}"
puts "  • Leads: #{Lead.count} (#{Lead.where.not(status: ['won', 'lost']).count} active)"
puts "  • Tours: #{Tour.count}"
puts "  • Tour Departures: #{TourDeparture.count}"
puts "  • Bookings: #{Booking.count}"
puts "  • Payments: #{Payment.count}"
puts "  • Communications: #{Communication.count} (#{Communication.whatsapp_messages.count} WhatsApp, #{Communication.where(communication_type: 'email').count} email)"
puts "  • WhatsApp Templates: #{WhatsappTemplate.count}"
puts "\n🔑 Test Credentials:"
puts "  Admin:   admin@dreamland.pro / password123"
puts "  Manager: manager@dreamland.pro / password123"
puts "  Agents:  anna@dreamland.pro / password123"
puts "           marat@dreamland.pro / password123"
puts "           elena@dreamland.pro / password123"
puts "\n💡 Key Features Demonstrated:"
puts "  ✓ Client-centric architecture (Мария has 2 leads - returning customer!)"
puts "  ✓ Multi-currency support (USD, KZT, EUR, RUB)"
puts "  ✓ Multi-language (Russian & English)"
puts "  ✓ WhatsApp-first communication (most communications via WhatsApp)"
puts "  ✓ Direct bookings without leads (Emma's booking)"
puts "  ✓ Complete booking lifecycle (from lead to payment)"
puts "  ✓ Unread messages requiring attention (Maria & Nurlan)"
puts "="*70
