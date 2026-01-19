require "prawn"
require "prawn/table"

class SuperbillGenerator
  def initialize(encounter)
    @encounter = encounter
    @patient = encounter.patient
    @provider = encounter.provider
    @organization = encounter.organization
  end

  def call
    Prawn::Document.new do |pdf|
      # --- Header ---
      pdf.font_size 16
      pdf.text "SUPERBILL / SERVICE RECEIPT", style: :bold, align: :right
      pdf.font_size 10
      pdf.text "Date of Service: #{@encounter.visit_date.strftime('%m/%d/%Y')}", align: :right
      pdf.move_down 20

      # --- Practice Data  ---
      pdf.text @organization.name.upcase, style: :bold, size: 14
      # Safe navigation in case provider/license is missing
      pdf.text "NPI: #{@provider&.npi || 'Pending'}"
      pdf.text "Tax ID: 12-3456789"
      pdf.move_down 20
      pdf.stroke_horizontal_rule
      pdf.move_down 20

      # --- Doctor & Patient ---
      data = [
        [
          "<b>PATIENT:</b>\n#{@patient.full_name}\nDOB: #{@patient.date_of_birth}\n#{@patient.street_address}\n#{@patient.city}, #{@patient.state}",
          "<b>PROVIDER:</b>\n#{@provider.full_name}\n#{@provider&.specialty}\nLic: #{@provider&.license_number}"
        ]
      ]
      pdf.table(data, width: 540, cell_style: { inline_format: true, border_width: 0 })
      pdf.move_down 30

      # --- Diagnosis Codes (Supports ICD-10 & ICD-11) ---
      pdf.text "DIAGNOSIS CODES", style: :bold
      pdf.move_down 5

      if @patient.conditions.any?
        # Headers: System | Code | Description
        icd_data = [ [ "System", "Code", "Description" ] ]
        @patient.conditions.each do |c|
          # Explicitly show if it is ICD-10 or ICD-11
          icd_data << [ c.code_system, c.code, c.name ]
        end

        pdf.table(icd_data, header: true, width: 540) do
          row(0).style(font_style: :bold, background_color: "EEEEEE")
          column(0).style(width: 80, font_style: :bold) # Highlight the System column
        end
      else
        pdf.text "No diagnosis recorded.", style: :italic
      end
      pdf.move_down 30

      # --- Procedures (CPT) ---
      pdf.text "PROCEDURES (CPT)", style: :bold
      pdf.move_down 5

      bill_data = [ [ "Code", "Description", "Fee" ] ]
      @encounter.encounter_procedures.each do |line|
        bill_data << [
          line.procedure.code,
          line.procedure.name,
          ActionController::Base.helpers.number_to_currency(line.charge_amount)
        ]
      end

      # Total Row
      bill_data << [ "", "<b>TOTAL</b>", "<b>#{ActionController::Base.helpers.number_to_currency(@encounter.total_charges)}</b>" ]

      pdf.table(bill_data, header: true, width: 540, cell_style: { inline_format: true }) do
        row(0).style(background_color: "EEEEEE", font_style: :bold)
        row(-1).style(border_top_width: 2)
      end

      # --- Footer ---
      pdf.move_down 50
      pdf.text "This document serves as a receipt for services rendered. Please retain for your records.", size: 8, align: :center
    end.render
  end
end
