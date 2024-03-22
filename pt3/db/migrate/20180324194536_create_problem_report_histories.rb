class CreateProblemReportHistories < ActiveRecord::Migration[5.1]
  def change
    create_table :problem_report_histories do |t|
      t.text :action
      t.string :modifiedby
      t.string :status
      t.string :severity_type
      t.datetime :datemodified
      t.references :project, foreign_key: true
      t.references :problem_report, foreign_key: true

      t.timestamps
    end
  end
end
