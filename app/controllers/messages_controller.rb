class MessagesController < ApplicationController
  def index
    # Inbox logic
    @messages = Current.user.received_messages.chronological
  end

  def sent
    # Outbox Logic
    @messages = Current.user.sent_messages.chronological
    render :index
  end

  def show
    @message = Message.where(id: params[:id])
                      .where("sender_id = ? OR recipient_id = ?", Current.user.id, Current.user.id)
                      .first!

    # Logic: Only mark as read if I am the RECIPIENT (and it's unread)
    if @message.recipient_id == Current.user.id && @message.read_at.nil?
      @message.update(read_at: Time.current)
    end
  end

  def new
    @message = Message.new
    @recipients = @current_organization.users.where.not(id: Current.user.id)

    # Handle "Reply"
    if params[:reply_to_id]
      original_msg = Message.find(params[:reply_to_id])
      @message.recipient = original_msg.sender
      @message.subject = "Re: #{original_msg.subject}"
      @message.patient = original_msg.patient
    end

    # Handle "Patient Context"
    if params[:patient_id]
      @patient = @current_organization.patients.find(params[:patient_id])
      @message.patient = @patient
      @message.subject ||= "Regarding: #{@patient.full_name}"
    end

    # If we have a patient, load their existing documents for the selection list
    if @message.patient
      @patient_documents = @message.patient.documents.includes(file_attachment: :blob)
    end
  end

  def create
    @message = Current.user.sent_messages.build(message_params.except(:patient_document_ids))
    @message.organization = @current_organization

    # Attachs the existing patient docs (Copies the Blob)
    if message_params[:patient_document_ids].present?
      docs = Document.find(message_params[:patient_document_ids].reject(&:blank?))
      docs.each do |doc|
        if doc.file.attached?
          # This creates a new attachment pointing to the SAME file (no duplication of storage)
          @message.attachments.attach(doc.file.blob)
        end
      end
    end

    if @message.save
      redirect_to messages_path(slug: @current_organization.slug), notice: "Message sent."
    else
      @recipients = @current_organization.users.where.not(id: Current.user.id)
      @patient = @message.patient
      # Reload documents if needed
      @patient_documents = @patient.documents.includes(file_attachment: :blob) if @patient
      render :new, status: :unprocessable_entity
    end
  end

  private

  def message_params
    # Whitelist attachments (array) and patient_document_ids (array)
    params.require(:message).permit(:recipient_id, :patient_id, :category, :subject, :body, attachments: [], patient_document_ids: [])
  end
end
