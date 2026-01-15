class MakeConditionsGeneric < ActiveRecord::Migration[8.0]
  def change
    rename_column :conditions, :icd10_code, :code

    # Add a column to track WHICH system (ICD-10, ICD-11, SNOMED)
    add_column :conditions, :code_system, :string, default: "ICD-10"
  end
end
