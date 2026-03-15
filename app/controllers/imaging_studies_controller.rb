# frozen_string_literal: true

class ImagingStudiesController < ApplicationController
  before_action :set_patient,        only: [ :index, :new, :create ]
  before_action :set_imaging_study,  only: [ :show, :edit, :update, :destroy ]

  def index
    @imaging_studies = @patient.imaging_studies
                               .includes(:encounter, :ordered_by)
                               .recent
  end

  def show
    @patient = @imaging_study.patient
    # Build signed URLs for all attached DICOM files so the
    # Cornerstone.js viewer can load them directly from Active Storage.
    @dicom_urls = @imaging_study.dicom_files.map { |f| url_for(f) }
  end

  def new
    @imaging_study = @patient.imaging_studies.build(
      status:     "ordered",
      study_date: Date.current
    )
    load_form_collections
  end

  def create
    @imaging_study = @patient.imaging_studies.build(imaging_study_params)
    @imaging_study.organization = @current_organization

    if @imaging_study.save
      redirect_to patient_imaging_studies_path(
        slug: @current_organization.slug, patient_id: @patient.id
      ), notice: "Imaging study ordered."
    else
      load_form_collections
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @patient = @imaging_study.patient
    load_form_collections
  end

  def update
    if @imaging_study.update(imaging_study_params)
      redirect_to imaging_study_path(
        slug: @current_organization.slug, id: @imaging_study.id
      ), notice: "Study updated."
    else
      @patient = @imaging_study.patient
      load_form_collections
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    patient = @imaging_study.patient
    @imaging_study.destroy
    redirect_to patient_path(
      slug: @current_organization.slug, id: patient.id
    ), notice: "Imaging study deleted."
  end

  private

  # ── Finders ──────────────────────────────────────────────────────────────

  def set_patient
    @patient = @current_organization.patients.find(params[:patient_id])
  end

  # Tenant-scoped lookup: ensures the study belongs to this org's patient.
  def set_imaging_study
    @imaging_study = ImagingStudy
                       .joins(:patient)
                       .where(patients: { organization_id: @current_organization.id })
                       .find(params[:id])
  end

  # ── Form Helpers ──────────────────────────────────────────────────────────

  def load_form_collections
    @providers  = @current_organization.providers
    @encounters = @patient.encounters.order(visit_date: :desc).limit(20)
  end

  # ── Strong Parameters ─────────────────────────────────────────────────────

  def imaging_study_params
    permitted = params.require(:imaging_study).permit(
      :encounter_id,
      :ordered_by_id,
      :modality,
      :study_instance_uid,
      :accession_number,
      :description,
      :body_site,
      :status,
      :study_date,
      :findings,
      :impression,
      dicom_files: []
    )

    # Active Storage: an empty file input submits a blank string, which Active
    # Storage treats as "replace all attachments with nothing", silently purging
    # existing DICOM files. Only keep the key when real uploads are present.
    files = permitted[:dicom_files]
    unless files&.any? { |f| f.is_a?(ActionDispatch::Http::UploadedFile) }
      permitted.delete(:dicom_files)
    end

    permitted
  end
end
