class CreateLeads < ActiveRecord::Migration[8.1]
  def change
    create_table :leads do |t|
      t.string :name, null: false
      t.string :email
      t.string :phone, null: false
      t.string :source, null: false, default: 'whatsapp'
      t.string :status, null: false, default: 'new'
      t.integer :assigned_agent_id
      t.integer :tour_interest_id
      t.datetime :last_message_at
      t.integer :unread_messages_count, default: 0

      t.timestamps
    end

    add_index :leads, :phone, unique: true
    add_index :leads, :assigned_agent_id
    add_index :leads, :status
    add_index :leads, :source
  end
end
