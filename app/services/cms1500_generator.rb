require "prawn"

class Cms1500Generator
  # Global offsets for printer calibration
  X_OFFSET = 0
  Y_OFFSET = 0

  # Added 'mode: :print' to the arguments so it has a default
  def initialize(encounter, mode: :print)
    @encounter = encounter
    @patient = encounter.patient
    @provider = encounter.provider
    @organization = encounter.organization
    @mode = mode
  end

  def call
    Prawn::Document.new(page_size: "LETTER", margin: 0) do |pdf|
      # Background Image Logic
      if @mode == :digital
        bg_path = Rails.root.join("app/assets/images/cms1500.jpg")
        # Only try to load if file exists to prevent crashing
        if File.exist?(bg_path)
          pdf.image bg_path, width: 612, height: 792, at: [ 0, 792 ]
        end
      end

      pdf.font "Courier", size: 10

      # Drawing Form Data, We pass 'pdf' into our helper methods
      draw_form_data(pdf)
    end.render
  end

  private

  def draw_field(pdf, text, x, y)
    return if text.blank?
    # Apply offsets
    pdf.draw_text text.to_s.upcase, at: [ x + X_OFFSET, y + Y_OFFSET ]
  end

  def draw_form_data(pdf)
    # --- BOX 1: Insurance Type ---
    draw_field(pdf, "X", 50, 700)

    # --- BOX 2: Patient Name ---
    draw_field(pdf, @patient.last_name, 50, 680)
    draw_field(pdf, @patient.first_name, 150, 680)
    # Use safe navigation (&.) in case middle_initial is missing
    draw_field(pdf, @patient.respond_to?(:middle_initial) ? @patient.middle_initial : "", 250, 680)

    # --- BOX 3: Date of Birth ---
    if dob = @patient.date_of_birth
      draw_field(pdf, dob.strftime("%m"), 300, 680)
      draw_field(pdf, dob.strftime("%d"), 330, 680)
      draw_field(pdf, dob.strftime("%y"), 360, 680)
    end

    # --- BOX 5: Patient Address ---
    draw_field(pdf, @patient.street_address, 50, 650)
    draw_field(pdf, @patient.city, 50, 630)
    draw_field(pdf, @patient.state, 200, 630)
    draw_field(pdf, @patient.zip_code, 250, 630)

    # --- BOX 21: Diagnosis Codes ---
    y_pos = 450
    @patient.conditions.limit(4).each_with_index do |condition, index|
      x_pos = 50 + (index * 150)
      draw_field(pdf, condition.code, x_pos, y_pos)
    end

    # --- BOX 24: Service Lines ---
    start_y = 380
    row_height = 24

    @encounter.encounter_procedures.each_with_index do |line, index|
      cursor_y = start_y - (index * row_height)

      draw_field(pdf, @encounter.visit_date.strftime("%m %d %y"), 50, cursor_y) # 24a
      draw_field(pdf, "11", 150, cursor_y)                                      # 24b
      draw_field(pdf, line.procedure.code, 200, cursor_y)                       # 24d
      draw_field(pdf, "A", 300, cursor_y)                                       # 24e
      draw_field(pdf, sprintf("%.2f", line.charge_amount), 350, cursor_y)       # 24f
      draw_field(pdf, "1", 450, cursor_y)                                       # 24g
      draw_field(pdf, @provider.npi, 500, cursor_y)                             # 24j
    end

    # --- BOX 25: Federal Tax ID ---
    draw_field(pdf, "12-3456789", 50, 100)

    # --- BOX 31: Signature ---
    draw_field(pdf, "SIGNATURE ON FILE", 50, 50)
    draw_field(pdf, Date.today.strftime("%m/%d/%Y"), 150, 50)

    # --- BOX 33: Billing Provider Info ---
    draw_field(pdf, @organization.name.upcase, 400, 100)
    draw_field(pdf, "555 Main St", 400, 90)     # Ideally, add address to Organization model
    draw_field(pdf, "Miami, FL 33185", 400, 80)
    draw_field(pdf, @provider.npi, 400, 60)
  end
end
