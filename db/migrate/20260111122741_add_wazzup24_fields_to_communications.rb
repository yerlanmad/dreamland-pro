class AddWazzup24FieldsToCommunications < ActiveRecord::Migration[8.1]
  def change
    add_column :communications, :sent_at, :datetime
    add_column :communications, :error_message, :text
    add_column :communications, :deleted_at, :datetime

    add_index :communications, :sent_at
    add_index :communications, :deleted_at
  end
end
