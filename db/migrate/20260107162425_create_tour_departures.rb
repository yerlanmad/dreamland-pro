class CreateTourDepartures < ActiveRecord::Migration[8.1]
  def change
    create_table :tour_departures do |t|
      t.references :tour, null: false, foreign_key: true
      t.date :departure_date
      t.integer :capacity
      t.decimal :price
      t.string :currency

      t.timestamps
    end
  end
end
