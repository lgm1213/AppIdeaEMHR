class CptCode < ApplicationRecord
  # Search by code OR description (e.g., "99213" or "Office Visit")
  scope :search_by_term, ->(term) {
    where("code ILIKE :term OR description ILIKE :term", term: "%#{term}%")
  }
end
