class DocumentsController < ApplicationController
  before_action :set_patient
  before_action :set_document, only: [ :show, :destroy ]

  def show
    # Track when the file was viewed
    @document.touch(:last_accessed_at)
  end

  def create
    files = params[:documents] || (params[:patient] && params[:patient][:documents])

    if files.blank?
      return redirect_to patient_path(slug: @current_organization.slug, id: @patient.id),
                         alert: "No files selected.", status: :see_other
    end

    result = DocumentUploadService.new(patient: @patient, uploader: Current.user, files: files).call

    if result.success?
      redirect_to patient_path(slug: @current_organization.slug, id: @patient.id),
                  notice: "#{result.saved_count} file(s) uploaded successfully.", status: :see_other
    else
      redirect_to patient_path(slug: @current_organization.slug, id: @patient.id),
                  alert: "Upload failed: #{result.errors.join(' | ')}", status: :see_other
    end
  end

  def destroy
    @document.destroy
    redirect_to patient_path(slug: @current_organization.slug, id: @patient.id), notice: "Document deleted."
  end

  private

  def set_patient
    @patient = Patient.find(params[:patient_id])
  end

  def set_document
    @document = @patient.documents.find(params[:id])
  end
end
