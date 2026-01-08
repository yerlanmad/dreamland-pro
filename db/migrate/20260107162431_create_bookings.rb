class CreateBookings < ActiveRecord::Migration[8.1]
  def change
    create_table :bookings do |t|
      t.references :lead, null: false, foreign_key: true
      t.references :tour_departure, null: false, foreign_key: true
      t.string :status
      t.integer :num_participants
      t.decimal :total_amount
      t.string :currency

      t.timestamps
    end
  end
end
