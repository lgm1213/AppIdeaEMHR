class CcdaGenerator
  def initialize(patient)
    @patient = patient
  end

  def call
    Nokogiri::XML::Builder.new(encoding: "UTF-8") do |xml|
      xml.ClinicalDocument("xmlns" => "urn:hl7-org:v3") do
        # --- HEADER ---
        xml.realmCode(code: "US")
        xml.typeId(root: "2.16.840.1.113883.1.3", extension: "POCD_HD000040")
        xml.title "Continuity of Care Document (CCD)"
        xml.effectiveTime(value: Time.now.strftime("%Y%m%d%H%M%S"))
        xml.confidentialityCode(code: "N", codeSystem: "2.16.840.1.113883.5.25")

        # PATIENT INFO
        xml.recordTarget do
          xml.patientRole do
            xml.id(root: "2.16.840.1.113883.4.1", extension: @patient.id)
            xml.patient do
              xml.name do
                xml.given @patient.first_name
                xml.family @patient.last_name
              end
              xml.administrativeGenderCode(code: gender_code, codeSystem: "2.16.840.1.113883.5.1")
              xml.birthTime(value: @patient.date_of_birth.strftime("%Y%m%d"))
              xml.telecom(value: "tel:#{@patient.phone}")
            end
          end
        end

        # --- BODY ---
        xml.component do
          xml.structuredBody do
            # 1. ALLERGIES
            if @patient.allergies.any?
              xml.component do
                xml.section do
                  xml.title "Allergies"
                  # Use tag!("text")
                  xml.tag!("text") do
                    xml.table do
                      xml.thead { xml.tr { xml.th "Substance"; xml.th "Reaction"; xml.th "Severity" } }
                      xml.tbody do
                        @patient.allergies.each do |alg|
                          xml.tr { xml.td alg.name; xml.td alg.reaction; xml.td alg.severity }
                        end
                      end
                    end
                  end
                end
              end
            end

            # 2. MEDICATIONS
            if @patient.medications.respond_to?(:active) && @patient.medications.active.any?
              xml.component do
                xml.section do
                  xml.title "Active Medications"
                  # Use tag!("text")
                  xml.tag!("text") do
                    xml.table do
                      xml.thead { xml.tr { xml.th "Medication"; xml.th "Dosage"; xml.th "Frequency" } }
                      xml.tbody do
                        @patient.medications.active.each do |med|
                          xml.tr { xml.td med.name; xml.td med.dosage; xml.td med.frequency }
                        end
                      end
                    end
                  end
                end
              end
            end

            # 3. PROBLEM LIST
            if @patient.conditions.respond_to?(:active) && @patient.conditions.active.any?
              xml.component do
                xml.section do
                  xml.title "Problem List"
                  # Use tag!("text")
                  xml.tag!("text") do
                    xml.table do
                      xml.thead { xml.tr { xml.th "Condition"; xml.th "Code"; xml.th "Onset" } }
                      xml.tbody do
                        @patient.conditions.active.each do |cond|
                          xml.tr { xml.td cond.name; xml.td "#{cond.code_system}: #{cond.code}"; xml.td cond.onset_date }
                        end
                      end
                    end
                  end
                end
              end
            end

            # 4. LAB RESULTS
            if @patient.labs.any?
              xml.component do
                xml.section do
                  xml.title "Lab Results"
                  # Use tag!("text")
                  xml.tag!("text") do
                    xml.table do
                      xml.thead { xml.tr { xml.th "Test"; xml.th "Result"; xml.th "Date" } }
                      xml.tbody do
                        @patient.labs.each do |lab|
                          xml.tr { xml.td lab.test_type; xml.td lab.result; xml.td lab.date }
                        end
                      end
                    end
                  end
                end
              end
            end

            # 5. ENCOUNTERS
            if @patient.encounters.any?
              xml.component do
                xml.section do
                  xml.title "Recent Encounters"
                  # Use tag!("text")
                  xml.tag!("text") do
                    @patient.encounters.order(visit_date: :desc).limit(5).each do |enc|
                      xml.paragraph do
                        xml.content "Date: #{enc.visit_date} | Provider: #{enc.provider&.full_name}"
                        xml.br
                        xml.content "Assessment: #{enc.assessment}"
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end.to_xml
  end

  private

  def gender_code
    case @patient.gender&.downcase
    when "male" then "M"
    when "female" then "F"
    else "UN"
    end
  end
end
