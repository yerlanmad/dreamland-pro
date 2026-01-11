class TransformToClientCentricArchitecture < ActiveRecord::Migration[8.1]
  def up
    # Step 1: Create clients table
    create_table :clients do |t|
      t.string :name, null: false
      t.string :phone, null: false
      t.string :email
      t.string :preferred_language
      t.text :notes

      t.timestamps
    end

    add_index :clients, :phone, unique: true
    add_index :clients, :created_at

    # Step 2: Add client_id to leads (nullable for now)
    add_reference :leads, :client, null: true, foreign_key: true

    # Step 3: Migrate leads data to clients
    # Skip if there are no leads (fresh database)
    unless connection.select_value("SELECT COUNT(*) FROM leads") == 0
      connection.execute(<<-SQL.squish)
        INSERT INTO clients (name, phone, email, preferred_language, notes, created_at, updated_at)
        SELECT
          COALESCE(name, 'Unknown'),
          phone,
          email,
          NULL,
          'Migrated from Lead',
          datetime('now'),
          datetime('now')
        FROM leads
        WHERE phone IS NOT NULL
      SQL

      # Link leads to clients
      connection.execute(<<-SQL.squish)
        UPDATE leads
        SET client_id = (
          SELECT id FROM clients
          WHERE clients.phone = leads.phone
          LIMIT 1
        )
        WHERE phone IS NOT NULL
      SQL
    end

    # Step 4: Make leads.client_id NOT NULL and remove redundant columns
    change_column_null :leads, :client_id, false
    remove_column :leads, :name, :string
    remove_column :leads, :phone, :string
    remove_column :leads, :email, :string

    # Step 5: Add client_id to bookings
    add_reference :bookings, :client, null: true, foreign_key: true

    # Step 6: Migrate booking data
    unless connection.select_value("SELECT COUNT(*) FROM bookings") == 0
      connection.execute(<<-SQL.squish)
        UPDATE bookings
        SET client_id = (
          SELECT client_id FROM leads
          WHERE leads.id = bookings.lead_id
          LIMIT 1
        )
        WHERE lead_id IS NOT NULL
      SQL
    end

    # Step 7: Make bookings.client_id NOT NULL and lead_id optional
    change_column_null :bookings, :client_id, false
    change_column_null :bookings, :lead_id, true

    # Step 8: Transform communications table
    add_reference :communications, :client, null: true, foreign_key: true
    add_reference :communications, :lead, null: true, foreign_key: true
    add_reference :communications, :booking, null: true, foreign_key: true

    # Step 9: Migrate communications data
    unless connection.select_value("SELECT COUNT(*) FROM communications") == 0
      # For Communications associated with Leads
      connection.execute(<<-SQL.squish)
        UPDATE communications
        SET
          client_id = (
            SELECT client_id FROM leads
            WHERE leads.id = communications.communicable_id
            LIMIT 1
          ),
          lead_id = communications.communicable_id
        WHERE communicable_type = 'Lead'
          AND communicable_id IS NOT NULL
      SQL

      # For Communications associated with Bookings
      connection.execute(<<-SQL.squish)
        UPDATE communications
        SET
          client_id = (
            SELECT client_id FROM bookings
            WHERE bookings.id = communications.communicable_id
            LIMIT 1
          ),
          booking_id = communications.communicable_id
        WHERE communicable_type = 'Booking'
          AND communicable_id IS NOT NULL
      SQL
    end

    # Step 10: Clean up communications table
    change_column_null :communications, :client_id, false
    remove_column :communications, :communicable_type, :string
    remove_column :communications, :communicable_id, :bigint

    # Step 11: Add missing indexes
    add_index :communications, :created_at unless index_exists?(:communications, :created_at)
  end

  def down
    # Restore communications structure
    change_column_null :communications, :client_id, true
    add_column :communications, :communicable_type, :string
    add_column :communications, :communicable_id, :bigint

    # Restore polymorphic associations for communications
    connection.execute(<<-SQL.squish)
      UPDATE communications
      SET communicable_type = 'Lead',
          communicable_id = lead_id
      WHERE lead_id IS NOT NULL
    SQL

    connection.execute(<<-SQL.squish)
      UPDATE communications
      SET communicable_type = 'Booking',
          communicable_id = booking_id
      WHERE booking_id IS NOT NULL
    SQL

    remove_reference :communications, :booking, foreign_key: true
    remove_reference :communications, :lead, foreign_key: true
    remove_reference :communications, :client, foreign_key: true

    # Restore bookings structure
    change_column_null :bookings, :lead_id, false
    change_column_null :bookings, :client_id, true
    remove_reference :bookings, :client, foreign_key: true

    # Restore leads structure
    add_column :leads, :name, :string
    add_column :leads, :phone, :string
    add_column :leads, :email, :string

    # Copy client data back to leads
    connection.execute(<<-SQL.squish)
      UPDATE leads
      SET
        name = (SELECT name FROM clients WHERE clients.id = leads.client_id),
        phone = (SELECT phone FROM clients WHERE clients.id = leads.client_id),
        email = (SELECT email FROM clients WHERE clients.id = leads.client_id)
      WHERE client_id IS NOT NULL
    SQL

    change_column_null :leads, :client_id, true
    remove_reference :leads, :client, foreign_key: true

    # Remove clients table
    drop_table :clients
  end
end
