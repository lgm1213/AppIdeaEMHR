class AddStatusToEncounters < ActiveRecord::Migration[8.1]
  def change
    # 1. Status Column (Check first to prevent "DuplicateColumn" error)
    unless column_exists?(:encounters, :status)
      # Status enum: 0=draft, 1=in_progress, 2=completed, 3=signed, 4=amended
      add_column :encounters, :status, :integer, default: 0, null: false
    end

    # 2. Signing Information
    unless column_exists?(:encounters, :signed_at)
      add_column :encounters, :signed_at, :datetime
    end

    unless column_exists?(:encounters, :signed_by_id)
      add_reference :encounters, :signed_by, type: :uuid, foreign_key: { to_table: :users }
    end

    # 3. Indexes (Check if index exists before adding)
    unless index_exists?(:encounters, :status)
      add_index :encounters, :status
    end

    unless index_exists?(:encounters, [ :organization_id, :status ])
      add_index :encounters, [ :organization_id, :status ]
    end

    # 4. Backfill (Safe to run multiple times because it targets specific criteria)
    reversible do |dir|
      dir.up do
        # Mark all existing encounters (that are currently 0/Draft) as completed (2)
        # This assumes that any OLD data created before this migration was "finished" work.
        # We check simply to avoid re-running if not needed, though SQL update is safe regardless.
        execute <<-SQL.squish
          UPDATE encounters#{' '}
          SET status = 2#{' '}
          WHERE status = 0
        SQL
      end
    end
  end
end
