class AddBaselines < ActiveRecord::Migration[5.2]
  def change
    create_table :archives do |t|
      t.string   :name,        null: false
      t.string   :full_id,     null: false
      t.string   :description, null: false
      t.string   :revision,    null: false
      t.string   :version,     null: false
      t.datetime :archived_at, null: false
      t.string   :organization

      t.timestamps
    end

    add_reference :projects, :archive
    add_reference :system_requirements, :archive
    add_reference :items, :archive
    add_reference :high_level_requirements, :archive
    add_reference :documents, :archive
    add_reference :low_level_requirements, :archive
    add_reference :document_comments, :archive
    add_reference :reviews, :archive
    add_reference :checklist_items, :archive
    add_reference :action_items, :archive
    add_reference :problem_reports, :archive
    add_reference :problem_report_histories, :archive
    add_reference :test_cases, :archive
    add_reference :document_attachments, :archive
    add_reference :review_attachments, :archive
    add_reference :problem_report_attachments, :archive
    add_reference :source_codes, :archive
  end
end
