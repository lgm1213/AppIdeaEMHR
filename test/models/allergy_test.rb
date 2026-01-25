require "test_helper"

class AllergyTest < ActiveSupport::TestCase
  test "has_allergies?" do
    patient = patients(:one)
    patient.allergies.create!(name: "Dust", severity: "Mild", status: "Active")
    assert patient.has_allergies?
  end

  test "has_allergies? returns true when allergies exist" do
    patient = patients(:one)
    patient.allergies.create!(name: "Dust", severity: "Mild", status: "Active")
    assert patient.has_allergies?
  end
end
