class ChangeBaselinesToArchives < ActiveRecord::Migration[5.2]
  def change
    if ActiveRecord::Base.connection.table_exists? 'baselines'
      rename_column    :baselines, :baselined_at, :archived_at
      rename_table     :baselines, :archives
      remove_reference :projects, :baseline
      remove_reference :system_requirements, :baseline
      remove_reference :items, :baseline
      remove_reference :high_level_requirements, :baseline
      remove_reference :documents, :baseline
      remove_reference :low_level_requirements, :baseline
      remove_reference :document_comments, :baseline
      remove_reference :reviews, :baseline
      remove_reference :checklist_items, :baseline
      remove_reference :action_items, :baseline
      remove_reference :problem_reports, :baseline
      remove_reference :problem_report_histories, :baseline
      remove_reference :test_cases, :baseline
      remove_reference :document_attachments, :baseline
      remove_reference :review_attachments, :baseline
      remove_reference :problem_report_attachments, :baseline
      remove_reference :source_codes, :baseline
      add_reference    :projects, :archive
      add_reference    :system_requirements, :archive
      add_reference    :items, :archive
      add_reference    :high_level_requirements, :archive
      add_reference    :documents, :archive
      add_reference    :low_level_requirements, :archive
      add_reference    :document_comments, :archive
      add_reference    :reviews, :archive
      add_reference    :checklist_items, :archive
      add_reference    :action_items, :archive
      add_reference    :problem_reports, :archive
      add_reference    :problem_report_histories, :archive
      add_reference    :test_cases, :archive
      add_reference    :document_attachments, :archive
      add_reference    :review_attachments, :archive
      add_reference    :problem_report_attachments, :archive
      add_reference    :source_codes, :archive
    end
  end
end
