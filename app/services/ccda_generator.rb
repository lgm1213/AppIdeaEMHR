class CcdaGenerator
  def initialize(patient)
    @patient = patient
  end

  def call
    builder = Nokogiri::XML::Builder.new(encoding: "UTF-8") do |xml|
      xml.ClinicalDocument("xmlns" => "urn:hl7-org:v3") do
        # CCDA Header Info
        xml.realmCode(code: "US")
        xml.typeId(root: "2.16.840.1.113883.1.3", extension: "POCD_HD000040")
        xml.title "Continuity of Care Document (CCD)"
        xml.effectiveTime(value: Time.now.strftime("%Y%m%d%H%M%S"))

        # Patient Info
        xml.recordTarget do
          xml.patientRole do
            xml.id(root: "2.16.840.1.113883.4.1", extension: @patient.id)
            xml.patient do
              xml.name do
                xml.given @patient.first_name
                xml.family @patient.last_name
              end
              xml.administrativeGenderCode(code: gender_code(@patient.gender), codeSystem: "2.16.840.1.113883.5.1")
              xml.birthTime(value: @patient.date_of_birth.strftime("%Y%m%d"))
            end
          end
        end

        # CCDA Body Info
        xml.component do
          xml.structuredBody do
            # Section: Allergies
            if @patient.allergies.any?
              xml.component do
                xml.section do
                  xml.title "Allergies, Adverse Reactions, Alerts"
                  xml.text do
                    xml.table do
                      xml.thead do
                        xml.tr { xml.th "Substance"; xml.th "Reaction"; xml.th "Status" }
                      end
                      xml.tbody do
                        @patient.allergies.each do |alg|
                          xml.tr do
                            xml.td alg.name
                            xml.td alg.reaction
                            xml.td alg.status
                          end
                        end
                      end
                    end
                  end
                end
              end
            end

            # Future sections: Medications, Problems, etc.
          end
        end
      end
    end

    builder.to_xml
  end

  private

  def gender_code(gender)
    case gender.downcase
    when "male" then "M"
    when "female" then "F"
    else "UN"
    end
  end
end
