class DocumentsController < ApplicationController
  before_action :set_patient
  before_action :set_document, only: [ :show, :destroy ]

  def show
    # Track when the file was viewed
    @document.touch(:last_accessed_at)
  end

  def create
    files = params[:documents] || (params[:patient] && params[:patient][:documents])

    if files.present?
      saved_count = 0
      error_messages = []

      # Ensure files is an array (in case of single file upload)
      files = [ files ] unless files.is_a?(Array)

      files.each do |file|
        next if file.is_a?(String)

        doc = @patient.documents.new(
          file: file,
          uploader: Current.user
        )

        if doc.save
          saved_count += 1
        else
          error_messages << "#{file.original_filename}: #{doc.errors.full_messages.join(', ')}"
        end
      end

      if saved_count > 0
        redirect_to patient_path(slug: @current_organization.slug, id: @patient.id), notice: "#{saved_count} file(s) uploaded successfully.", status: :see_other
      else
        redirect_to patient_path(slug: @current_organization.slug, id: @patient.id), alert: "Upload failed: #{error_messages.join(' | ')}", status: :see_other
      end

    else
      redirect_to patient_path(slug: @current_organization.slug, id: @patient.id), alert: "No files selected.", status: :see_other
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
