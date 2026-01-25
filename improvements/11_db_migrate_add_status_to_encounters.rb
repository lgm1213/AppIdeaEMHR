# frozen_string_literal: true

# ==============================================================================
# BONUS IMPROVEMENT: Add Status Workflow to Encounters
# ==============================================================================
# File: db/migrate/YYYYMMDDHHMMSS_add_status_to_encounters.rb
#
# Run: bin/rails generate migration AddStatusToEncounters
# Then replace the contents with this file.
#
# This migration adds:
# - status enum for encounter workflow (draft -> completed -> signed)
# - signed_at timestamp
# - signed_by_id for tracking who signed the encounter
# ==============================================================================

class AddStatusToEncounters < ActiveRecord::Migration[8.1]
  def change
    # Status enum: 0=draft, 1=in_progress, 2=completed, 3=signed, 4=amended
    add_column :encounters, :status, :integer, default: 0, null: false

    # Signing information
    add_column :encounters, :signed_at, :datetime
    add_reference :encounters, :signed_by, type: :uuid, foreign_key: { to_table: :users }

    # Index for filtering by status
    add_index :encounters, :status
    add_index :encounters, [ :organization_id, :status ]

    # Backfill existing encounters as completed (they were created before workflow)
    reversible do |dir|
      dir.up do
        # Mark all existing encounters as completed
        execute <<-SQL.squish
          UPDATE encounters#{' '}
          SET status = 2#{' '}
          WHERE status = 0
        SQL
      end
    end
  end
end
