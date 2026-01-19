class EncounterProcedure < ApplicationRecord
  belongs_to :encounter
  belongs_to :procedure

  before_create :set_price

  private
  def set_price
    self.charge_amount ||= procedure.price
  end
end
