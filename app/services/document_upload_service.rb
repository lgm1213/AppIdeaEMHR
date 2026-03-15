class DocumentUploadService
  attr_reader :saved_count, :errors

  def initialize(patient:, uploader:, files:)
    @patient = patient
    @uploader = uploader
    @files = Array(files).reject { |f| f.is_a?(String) }
    @saved_count = 0
    @errors = []
  end

  def call
    @files.each do |file|
      doc = @patient.documents.new(file: file, uploader: @uploader)

      if doc.save
        @saved_count += 1
      else
        @errors << "#{file.original_filename}: #{doc.errors.full_messages.join(', ')}"
      end
    end

    self
  end

  def success?
    @saved_count > 0
  end
end
