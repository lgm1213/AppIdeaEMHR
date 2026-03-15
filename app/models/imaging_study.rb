# frozen_string_literal: true

class ImagingStudy < ApplicationRecord
  # ===========================================================================
  # Constants
  # ===========================================================================
  MODALITIES = %w[CR CT MR US NM PT DX MG RF].freeze
  MODALITY_LABELS = {
    "CR" => "Computed Radiography",
    "CT" => "CT Scan",
    "MR" => "MRI",
    "US" => "Ultrasound",
    "NM" => "Nuclear Medicine",
    "PT" => "PET Scan",
    "DX" => "Digital X-Ray",
    "MG" => "Mammography",
    "RF" => "Fluoroscopy"
  }.freeze
  STATUSES = %w[ordered scheduled in_progress completed cancelled].freeze

  # ===========================================================================
  # Associations
  # ===========================================================================
  belongs_to :patient,       inverse_of: :imaging_studies
  belongs_to :organization
  belongs_to :encounter,     optional: true, inverse_of: :imaging_studies
  belongs_to :ordered_by,    class_name: "Provider", optional: true

  has_many_attached :dicom_files

  # ===========================================================================
  # Audit Trail
  # ===========================================================================
  has_paper_trail meta: { patient_id: :patient_id }

  # ===========================================================================
  # Callbacks
  # ===========================================================================
  # When an imaging study is built through an encounter (nested attributes),
  # inherit patient, organization, and ordering provider automatically so the
  # caller doesn't have to set them manually.
  before_validation :inherit_from_encounter, if: -> { encounter.present? }

  # ===========================================================================
  # Validations
  # ===========================================================================
  validates :modality,    presence: true, inclusion: { in: MODALITIES }
  validates :description, presence: true, length: { maximum: 255 }
  validates :status,      presence: true, inclusion: { in: STATUSES }
  validates :body_site,   length: { maximum: 100 }, allow_blank: true

  # ===========================================================================
  # Scopes
  # ===========================================================================
  scope :recent,    -> { order(created_at: :desc) }
  scope :completed, -> { where(status: "completed") }
  scope :ordered,   -> { where(status: "ordered") }
  scope :with_images, -> { joins(:dicom_files_attachments) }

  # ===========================================================================
  # Instance Methods
  # ===========================================================================
  def modality_display
    MODALITY_LABELS[modality] || modality
  end

  def has_images?
    dicom_files.attached?
  end

  def ordered?
    status == "ordered"
  end

  def completed?
    status == "completed"
  end

  def status_badge_classes
    case status
    when "ordered"      then "bg-yellow-100 text-yellow-800 ring-yellow-600/20"
    when "scheduled"    then "bg-blue-100 text-blue-800 ring-blue-600/20"
    when "in_progress"  then "bg-indigo-100 text-indigo-800 ring-indigo-600/20"
    when "completed"    then "bg-green-100 text-green-800 ring-green-600/20"
    when "cancelled"    then "bg-red-100 text-red-800 ring-red-600/20"
    else                     "bg-gray-100 text-gray-800 ring-gray-600/20"
    end
  end

  private

  def inherit_from_encounter
    self.patient      ||= encounter.patient
    self.organization ||= encounter.organization
    self.ordered_by   ||= encounter.provider
  end
end
