class AddUploadDateToArtifacts < ActiveRecord::Migration[5.2]
  def change
    add_column :documents,                  :upload_date, :datetime
    add_column :document_attachments,       :upload_date, :datetime
    add_column :model_files,                :upload_date, :datetime
    add_column :problem_report_attachments, :upload_date, :datetime
    add_column :reviews,                    :upload_date, :datetime
    add_column :review_attachments,         :upload_date, :datetime
    add_column :source_codes,               :upload_date, :datetime
    add_column :template_documents,         :upload_date, :datetime
    add_column :test_procedures,            :upload_date, :datetime
  end
end
