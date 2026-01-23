class Vital < ApplicationRecord
  belongs_to :encounter

  # Optional: Auto-calculate BMI before saving
  before_save :calculate_bmi

  private

  def calculate_bmi
    return unless height_inches.present? && weight_lbs.present? && height_inches > 0

    # Formula: (Weight in lbs * 703) / (Height in inches)^2
    self.bmi = ((weight_lbs * 703) / (height_inches ** 2)).round(1)
  end
end
