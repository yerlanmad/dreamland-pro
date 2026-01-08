class CreateTours < ActiveRecord::Migration[8.1]
  def change
    create_table :tours do |t|
      t.string :name
      t.text :description
      t.decimal :base_price
      t.string :currency
      t.integer :duration_days
      t.integer :capacity
      t.boolean :active

      t.timestamps
    end
  end
end
