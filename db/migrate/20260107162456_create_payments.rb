class CreatePayments < ActiveRecord::Migration[8.1]
  def change
    create_table :payments do |t|
      t.references :booking, null: false, foreign_key: true
      t.decimal :amount
      t.string :currency
      t.date :payment_date
      t.string :payment_method
      t.string :status

      t.timestamps
    end
  end
end
