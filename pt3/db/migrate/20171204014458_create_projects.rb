class CreateProjects < ActiveRecord::Migration[5.1]
  def change
    create_table :projects do |t|
      t.string :identifier
      t.string :name
      t.string :description
      t.string :access
      t.string :project_managers
      t.string :configuration_managers
      t.string :quality_assurance
      t.string :team_members
      t.string :airworthiness_reps

      # Use to keep counters for ID based models.
      t.integer :sysreq_count, default: 0
      t.integer :pr_count, default: 0

      t.timestamps
    end
  end
end
