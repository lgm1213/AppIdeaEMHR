class Encounter < ApplicationRecord
  belongs_to :patient
  belongs_to :provider
  belongs_to :organization
  belongs_to :appointment, optional: true
end
