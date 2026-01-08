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

ActiveRecord::Schema[8.1].define(version: 2026_01_07_162456) do
  create_table "bookings", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "currency"
    t.integer "lead_id", null: false
    t.integer "num_participants"
    t.string "status"
    t.decimal "total_amount"
    t.integer "tour_departure_id", null: false
    t.datetime "updated_at", null: false
    t.index ["lead_id"], name: "index_bookings_on_lead_id"
    t.index ["tour_departure_id"], name: "index_bookings_on_tour_departure_id"
  end

  create_table "communications", force: :cascade do |t|
    t.text "body"
    t.integer "communicable_id", null: false
    t.string "communicable_type", null: false
    t.string "communication_type", null: false
    t.datetime "created_at", null: false
    t.string "direction", null: false
    t.string "media_type"
    t.string "media_url"
    t.string "subject"
    t.datetime "updated_at", null: false
    t.string "whatsapp_message_id"
    t.string "whatsapp_status"
    t.index ["communicable_type", "communicable_id"], name: "index_communications_on_communicable"
    t.index ["communicable_type", "communicable_id"], name: "index_communications_on_communicable_type_and_communicable_id"
    t.index ["communication_type"], name: "index_communications_on_communication_type"
    t.index ["whatsapp_message_id"], name: "index_communications_on_whatsapp_message_id"
  end

  create_table "leads", force: :cascade do |t|
    t.integer "assigned_agent_id"
    t.datetime "created_at", null: false
    t.string "email"
    t.datetime "last_message_at"
    t.string "name", null: false
    t.string "phone", null: false
    t.string "source", default: "whatsapp", null: false
    t.string "status", default: "new", null: false
    t.integer "tour_interest_id"
    t.integer "unread_messages_count", default: 0
    t.datetime "updated_at", null: false
    t.index ["assigned_agent_id"], name: "index_leads_on_assigned_agent_id"
    t.index ["phone"], name: "index_leads_on_phone", unique: true
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

  add_foreign_key "bookings", "leads"
  add_foreign_key "bookings", "tour_departures"
  add_foreign_key "payments", "bookings"
  add_foreign_key "tour_departures", "tours"
end
