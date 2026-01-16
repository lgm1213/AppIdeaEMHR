class CareTeamMember < ApplicationRecord
  belongs_to :patient
  belongs_to :user

  validates :role, presence: true
end
