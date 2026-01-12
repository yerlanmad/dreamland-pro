# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_01_11_122741) do
  create_table "bookings", force: :cascade do |t|
    t.integer "client_id", null: false
    t.datetime "created_at", null: false
    t.string "currency"
    t.integer "lead_id"
    t.integer "num_participants"
    t.string "status"
    t.decimal "total_amount"
    t.integer "tour_departure_id", null: false
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_bookings_on_client_id"
    t.index ["lead_id"], name: "index_bookings_on_lead_id"
    t.index ["tour_departure_id"], name: "index_bookings_on_tour_departure_id"
  end

  create_table "clients", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email"
    t.string "name", null: false
    t.text "notes"
    t.string "phone", null: false
    t.string "preferred_language"
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_clients_on_created_at"
    t.index ["phone"], name: "index_clients_on_phone", unique: true
  end

  create_table "communications", force: :cascade do |t|
    t.text "body"
    t.integer "booking_id"
    t.integer "client_id", null: false
    t.string "communication_type", null: false
    t.datetime "created_at", null: false
    t.datetime "deleted_at"
    t.string "direction", null: false
    t.text "error_message"
    t.integer "lead_id"
    t.string "media_type"
    t.string "media_url"
    t.datetime "sent_at"
    t.string "subject"
    t.datetime "updated_at", null: false
    t.string "whatsapp_message_id"
    t.string "whatsapp_status"
    t.index ["booking_id"], name: "index_communications_on_booking_id"
    t.index ["client_id"], name: "index_communications_on_client_id"
    t.index ["communication_type"], name: "index_communications_on_communication_type"
    t.index ["created_at"], name: "index_communications_on_created_at"
    t.index ["deleted_at"], name: "index_communications_on_deleted_at"
    t.index ["lead_id"], name: "index_communications_on_lead_id"
    t.index ["sent_at"], name: "index_communications_on_sent_at"
    t.index ["whatsapp_message_id"], name: "index_communications_on_whatsapp_message_id"
  end

  create_table "leads", force: :cascade do |t|
    t.integer "assigned_agent_id"
    t.integer "client_id", null: false
    t.datetime "created_at", null: false
    t.datetime "last_message_at"
    t.string "source", default: "whatsapp", null: false
    t.string "status", default: "new", null: false
    t.integer "tour_interest_id"
    t.integer "unread_messages_count", default: 0
    t.datetime "updated_at", null: false
    t.index ["assigned_agent_id"], name: "index_leads_on_assigned_agent_id"
    t.index ["client_id"], name: "index_leads_on_client_id"
    t.index ["source"], name: "index_leads_on_source"
    t.index ["status"], name: "index_leads_on_status"
  end

  create_table "payments", force: :cascade do |t|
    t.decimal "amount"
    t.integer "booking_id", null: false
    t.datetime "created_at", null: false
    t.string "currency"
    t.date "payment_date"
    t.string "payment_method"
    t.string "status"
    t.datetime "updated_at", null: false
    t.index ["booking_id"], name: "index_payments_on_booking_id"
  end

  create_table "tour_departures", force: :cascade do |t|
    t.integer "capacity"
    t.datetime "created_at", null: false
    t.string "currency"
    t.date "departure_date"
    t.decimal "price"
    t.integer "tour_id", null: false
    t.datetime "updated_at", null: false
    t.index ["tour_id"], name: "index_tour_departures_on_tour_id"
  end

  create_table "tours", force: :cascade do |t|
    t.boolean "active"
    t.decimal "base_price"
    t.integer "capacity"
    t.datetime "created_at", null: false
    t.string "currency"
    t.text "description"
    t.integer "duration_days"
    t.string "name"
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "name", null: false
    t.string "password_digest", null: false
    t.string "preferred_currency", default: "KZT"
    t.string "preferred_language", default: "ru"
    t.string "role", default: "agent", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  create_table "whatsapp_templates", force: :cascade do |t|
    t.boolean "active"
    t.string "category"
    t.text "content"
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
    t.text "variables"
  end

  add_foreign_key "bookings", "clients"
  add_foreign_key "bookings", "leads"
  add_foreign_key "bookings", "tour_departures"
  add_foreign_key "communications", "bookings"
  add_foreign_key "communications", "clients"
  add_foreign_key "communications", "leads"
  add_foreign_key "leads", "clients"
  add_foreign_key "payments", "bookings"
  add_foreign_key "tour_departures", "tours"
end
