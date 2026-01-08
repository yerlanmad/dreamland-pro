class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :email, null: false
      t.string :password_digest, null: false
      t.string :role, null: false, default: 'agent'
      t.string :name, null: false
      t.string :preferred_language, default: 'ru'
      t.string :preferred_currency, default: 'KZT'

      t.timestamps
    end

    add_index :users, :email, unique: true
  end
end
