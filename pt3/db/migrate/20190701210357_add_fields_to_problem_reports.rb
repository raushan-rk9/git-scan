class AddFieldsToProblemReports < ActiveRecord::Migration[5.2]
  def change
     add_column :problem_reports, :title,               :string   unless ProblemReport.column_names.include?('title')
     add_column :problem_reports, :product,             :string   unless ProblemReport.column_names.include?('product')
     add_column :problem_reports, :source,              :string   unless ProblemReport.column_names.include?('title')
     add_column :problem_reports, :discipline_assigned, :string   unless ProblemReport.column_names.include?('discipline_assigned')
     add_column :problem_reports, :target_date,         :datetime unless ProblemReport.column_names.include?('target_date')
     add_column :problem_reports, :close_date,          :datetime unless ProblemReport.column_names.include?('close_date')
     add_column :problem_reports, :fixed_in,            :string   unless ProblemReport.column_names.include?('fixed_in')
     add_column :problem_reports, :feedback,            :string   unless ProblemReport.column_names.include?('feedback')
     add_column :problem_reports, :meeting_id,          :string   unless ProblemReport.column_names.include?('meeting_id')
  end
end
