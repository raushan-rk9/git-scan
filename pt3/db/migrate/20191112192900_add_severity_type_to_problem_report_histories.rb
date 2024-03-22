class AddSeverityTypeToProblemReportHistories < ActiveRecord::Migration[5.1]
  def up
    add_column    :problem_report_histories, :severity_type, :string unless ProblemReportHistory.column_names.include?('severity_type')
  end

  def down
    remove_column :problem_report_histories, :severity_type          if ProblemReportHistory.column_names.include?('severity_type')
  end
end
