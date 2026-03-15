class Vital < ApplicationRecord
  BMI_IMPERIAL_CONVERSION = 703

  belongs_to :encounter

  # Optional: Auto-calculate BMI before saving
  before_save :calculate_bmi

  private

  def calculate_bmi
    return unless height_inches.present? && weight_lbs.present? && height_inches > 0

    self.bmi = ((weight_lbs * BMI_IMPERIAL_CONVERSION) / (height_inches ** 2)).round(1)
  end
end
