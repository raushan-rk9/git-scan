class AddOrganizations < ActiveRecord::Migration[5.2]
  def change
    add_column :projects, :organization, :string unless Project.column_names.include?('organization')
    add_index  :projects, :organization
    add_column :system_requirements, :organization, :string unless SystemRequirement.column_names.include?('organization')
    add_index  :system_requirements, :organization
    add_column :items, :organization, :string unless Item.column_names.include?('organization')
    add_index  :items, :organization
    add_column :high_level_requirements, :organization, :string unless HighLevelRequirement.column_names.include?('organization')
    add_index  :high_level_requirements, :organization
    add_column :documents, :organization, :string unless Document.column_names.include?('organization')
    add_index  :documents, :organization
    add_column :low_level_requirements, :organization, :string unless LowLevelRequirement.column_names.include?('organization')
    add_index  :low_level_requirements, :organization
    add_column :document_comments, :organization, :string unless DocumentComment.column_names.include?('organization')
    add_index  :document_comments, :organization
    add_column :reviews, :organization, :string unless Review.column_names.include?('organization')
    add_index  :reviews, :organization
    add_column :checklist_items, :organization, :string unless ChecklistItem.column_names.include?('organization')
    add_index  :checklist_items, :organization
    add_column :action_items, :organization, :string unless ActionItem.column_names.include?('organization')
    add_index  :action_items, :organization
    add_column :problem_reports, :organization, :string unless ProblemReport.column_names.include?('organization')
    add_index  :problem_reports, :organization
    add_column :problem_report_histories, :organization, :string unless ProblemReportHistory.column_names.include?('organization')
    add_index  :problem_report_histories, :organization
    add_column :test_cases, :organization, :string unless TestCase.column_names.include?('organization')
    add_index  :test_cases, :organization
    add_column :document_attachments, :organization, :string unless DocumentAttachment.column_names.include?('organization')
    add_index  :document_attachments, :organization
    add_column :review_attachments, :organization, :string unless ReviewAttachment.column_names.include?('organization')
    add_index  :review_attachments, :organization
    add_column :problem_report_attachments, :organization, :string unless ProblemReportAttachment.column_names.include?('organization')
    add_index  :problem_report_attachments, :organization
    add_column :data_changes, :organization, :string unless DataChange.column_names.include?('organization')
    add_index  :data_changes, :organization
    add_column :change_sessions, :organization, :string unless ChangeSession.column_names.include?('organization')
    add_index  :change_sessions, :organization
    add_column :source_codes, :organization, :string unless SourceCode.column_names.include?('organization')
    add_index  :source_codes, :organization
    add_column :github_accesses, :organization, :string unless GithubAccess.column_names.include?('organization')
    add_index  :github_accesses, :organization
    add_column :templates, :organization, :string unless Template.column_names.include?('organization')
    add_index  :templates, :organization
    add_column :template_checklists, :organization, :string unless TemplateChecklist.column_names.include?('organization')
    add_index  :template_checklists, :organization
    add_column :template_checklist_items, :organization, :string unless TemplateChecklistItem.column_names.include?('organization')
    add_index  :template_checklist_items, :organization
    add_column :project_accesses, :organization, :string unless ProjectAccess.column_names.include?('organization')
    add_index  :project_accesses, :organization
  end
end
