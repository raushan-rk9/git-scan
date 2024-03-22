class AddLinkageToProblemReportsAndReviews < ActiveRecord::Migration[5.2]
  def up
    add_column :problem_report_attachments,    :link_type,        :string unless ProblemReportAttachment.column_names.include?('link_type')
    add_column :problem_report_attachments,    :link_description, :string unless ProblemReportAttachment.column_names.include?('link_description')
    add_column :problem_report_attachments,    :link_link,        :string unless ProblemReportAttachment.column_names.include?('link_link')
    add_column :review_attachments,            :link_type,        :string unless ReviewAttachment.column_names.include?('link_type')
    add_column :review_attachments,            :link_description, :string unless ReviewAttachment.column_names.include?('link_description')
    add_column :review_attachments,            :link_link,        :string unless ReviewAttachment.column_names.include?('link_link')
  end

  def down
    remove_column :problem_report_attachments, :link_type                 if ProblemReportAttachment.column_names.include?('link_type')
    remove_column :problem_report_attachments, :link_description          if ProblemReportAttachment.column_names.include?('link_description')
    remove_column :problem_report_attachments, :link_link                 if ProblemReportAttachment.column_names.include?('link_link')
    remove_column :review_attachments,         :link_type                 if ReviewAttachment.column_names.include?('link_type')
    remove_column :review_attachments,         :link_description          if ReviewAttachment.column_names.include?('link_description')
    remove_column :review_attachments,         :link_link                 if ReviewAttachment.column_names.include?('link_link')
  end
end
