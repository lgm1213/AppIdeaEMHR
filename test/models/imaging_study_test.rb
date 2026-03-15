require "test_helper"

class ImagingStudyTest < ActiveSupport::TestCase
  def setup
    @study = imaging_studies(:one)
  end

  # ── Associations ────────────────────────────────────────────────────────

  test "belongs to patient" do
    assert_respond_to @study, :patient
    assert_instance_of Patient, @study.patient
  end

  test "belongs to organization" do
    assert_respond_to @study, :organization
    assert_instance_of Organization, @study.organization
  end

  test "optionally belongs to encounter" do
    assert_respond_to @study, :encounter
    assert_instance_of Encounter, @study.encounter

    no_encounter = imaging_studies(:two)
    assert_nil no_encounter.encounter
  end

  # ── Validations ─────────────────────────────────────────────────────────

  test "valid with required attributes" do
    assert @study.valid?
  end

  test "invalid without modality" do
    @study.modality = nil
    assert_not @study.valid?
    assert_includes @study.errors[:modality], "can't be blank"
  end

  test "invalid with unknown modality" do
    @study.modality = "XX"
    assert_not @study.valid?
    assert_includes @study.errors[:modality], "is not included in the list"
  end

  test "invalid without description" do
    @study.description = nil
    assert_not @study.valid?
    assert_includes @study.errors[:description], "can't be blank"
  end

  test "invalid with unknown status" do
    @study.status = "lost"
    assert_not @study.valid?
    assert_includes @study.errors[:status], "is not included in the list"
  end

  test "valid with all supported modalities" do
    ImagingStudy::MODALITIES.each do |mod|
      @study.modality = mod
      assert @study.valid?, "Expected modality #{mod} to be valid, got: #{@study.errors.full_messages}"
    end
  end

  # ── Instance Methods ─────────────────────────────────────────────────────

  test "modality_display returns human label" do
    @study.modality = "CT"
    assert_equal "CT Scan", @study.modality_display
  end

  test "modality_display falls back to raw code for unknown" do
    # Bypass validation for this edge case
    @study.instance_variable_set(:@modality, "ZZ")
    assert_equal "ZZ", @study.modality_display
  end

  test "completed? returns true when status is completed" do
    @study.status = "completed"
    assert @study.completed?
  end

  test "ordered? returns true when status is ordered" do
    @study.status = "ordered"
    assert @study.ordered?
  end

  test "has_images? returns false when no files attached" do
    assert_not imaging_studies(:two).has_images?
  end

  test "status_badge_classes returns non-blank string" do
    ImagingStudy::STATUSES.each do |s|
      @study.status = s
      assert @study.status_badge_classes.present?
    end
  end

  # ── Scopes ───────────────────────────────────────────────────────────────

  test "recent scope orders by created_at descending" do
    scope = ImagingStudy.recent
    assert_equal "created_at", scope.order_values.first.expr.name
    assert_equal "desc",       scope.order_values.first.direction.to_s
  end

  test "completed scope returns only completed studies" do
    ImagingStudy.completed.each do |s|
      assert_equal "completed", s.status
    end
  end

  test "ordered scope returns only ordered studies" do
    ImagingStudy.ordered.each do |s|
      assert_equal "ordered", s.status
    end
  end
end
