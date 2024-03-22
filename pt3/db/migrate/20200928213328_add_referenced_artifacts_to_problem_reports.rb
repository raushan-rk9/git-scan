class AddReferencedArtifactsToProblemReports < ActiveRecord::Migration[5.2]
  def change
    add_column :problem_reports, :referenced_artifacts, :text
  end
end
