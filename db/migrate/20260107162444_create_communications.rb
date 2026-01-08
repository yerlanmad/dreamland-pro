class CreateCommunications < ActiveRecord::Migration[8.1]
  def change
    create_table :communications do |t|
      t.references :communicable, polymorphic: true, null: false
      t.string :communication_type, null: false
      t.string :subject
      t.text :body
      t.string :direction, null: false
      t.string :whatsapp_message_id
      t.string :whatsapp_status
      t.string :media_url
      t.string :media_type

      t.timestamps
    end

    add_index :communications, [:communicable_type, :communicable_id]
    add_index :communications, :whatsapp_message_id
    add_index :communications, :communication_type
  end
end
