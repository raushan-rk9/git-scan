class AddRevisionToSourceCodes < ActiveRecord::Migration[5.2]
  def change
    add_column :source_codes,    :file_path,     :string
    add_column :source_codes,    :content_type,  :string
    add_column :source_codes,    :file_type,     :string
    add_column :source_codes,    :revision,      :string
    add_column :source_codes,    :draft_version, :string
    add_column :source_codes,    :revision_date, :date
    add_column :test_procedures, :file_path,     :string
    add_column :test_procedures, :content_type,  :string
    add_column :test_procedures, :file_type,     :string
    add_column :test_procedures, :revision,      :string
    add_column :test_procedures, :draft_version, :string
    add_column :test_procedures, :revision_date, :date
  end
end
