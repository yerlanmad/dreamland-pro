class CreateWhatsappTemplates < ActiveRecord::Migration[8.1]
  def change
    create_table :whatsapp_templates do |t|
      t.string :name
      t.text :content
      t.text :variables
      t.string :category
      t.boolean :active

      t.timestamps
    end
  end
end
