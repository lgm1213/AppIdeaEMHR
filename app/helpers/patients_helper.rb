module PatientsHelper
  def audit_changes_for(version)
    # Determines the source of the changes based on event type
    changes = if version.event == "create"
                # If 'object_changes' wasn't captured, try to show the current item's attributes
                # If the item was deleted, fallback to an empty hash
                version.changeset.presence || (version.item ? version.item.attributes : {})
    else
                # For updates/destroys, the changeset is reliable
                version.changeset
    end

    # Filters out boring system columns
    ignored_keys = %w[
      created_at updated_at id patient_id
      organization_id uploader_id prescribed_by_id user_id
      type
    ]

    # Returns the cleaned hash without ignored keys
    changes.except(*ignored_keys)
  end
end
