class CreateImagingStudies < ActiveRecord::Migration[8.1]
  def change
    create_table :imaging_studies, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.references :patient,      null: false, foreign_key: true,                          type: :uuid
      t.references :organization, null: false, foreign_key: true,                          type: :uuid
      t.references :encounter,    null: true,  foreign_key: true,                          type: :uuid
      t.references :ordered_by,   null: true,  foreign_key: { to_table: :providers },      type: :uuid

      # DICOM Metadata
      t.string :modality,           null: false
      t.string :study_instance_uid
      t.string :accession_number
      t.string :description,        null: false
      t.string :body_site

      # Workflow
      t.string :status, null: false, default: "ordered"
      t.date   :study_date

      # Radiologist Report
      t.text :findings
      t.text :impression

      t.timestamps
    end

    add_index :imaging_studies, :modality
    add_index :imaging_studies, :status
    add_index :imaging_studies, :study_instance_uid, unique: true, where: "study_instance_uid IS NOT NULL"
    add_index :imaging_studies, :accession_number,   unique: true, where: "accession_number IS NOT NULL"
  end
end
