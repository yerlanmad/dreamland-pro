# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "Seeding database..."

# Create test users for each role
users = [
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
    name: "Manager User",
    email: "manager@dreamland.pro",
    password: "password123",
    password_confirmation: "password123",
    role: :manager,
    preferred_language: :ru,
    preferred_currency: :KZT
  },
  {
    name: "Agent User",
    email: "agent@dreamland.pro",
    password: "password123",
    password_confirmation: "password123",
    role: :agent,
    preferred_language: :ru,
    preferred_currency: :KZT
  }
]

users.each do |user_attrs|
  user = User.find_or_initialize_by(email: user_attrs[:email])
  if user.new_record?
    user.assign_attributes(user_attrs)
    user.save!
    puts "✓ Created #{user.role} user: #{user.email}"
  else
    puts "- User already exists: #{user.email}"
  end
end

puts "\nSeeding complete!"
puts "\nTest Credentials:"
puts "  Admin:   admin@dreamland.pro / password123"
puts "  Manager: manager@dreamland.pro / password123"
puts "  Agent:   agent@dreamland.pro / password123"
