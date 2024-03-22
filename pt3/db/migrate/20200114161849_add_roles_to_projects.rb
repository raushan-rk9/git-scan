class AddRolesToProjects < ActiveRecord::Migration[5.2]
  def up
    add_column :projects, :project_managers,       :string unless Project.column_names.include?('project_managers')
    add_column :projects, :configuration_managers, :string unless Project.column_names.include?('configuration_managers')
    add_column :projects, :quality_assurance,      :string unless Project.column_names.include?('quality_assurance')
    add_column :projects, :team_members,           :string unless Project.column_names.include?('team_members')
    add_column :projects, :airworthiness_reps,     :string unless Project.column_names.include?('airworthiness_reps')
  end

  def down
    remove_column :projects, :project_managers             if Project.column_names.include?('project_managers')
    remove_column :projects, :configuration_managers       if Project.column_names.include?('configuration_managers')
    remove_column :projects, :quality_assurance            if Project.column_names.include?('quality_assurance')
    remove_column :projects, :team_members                 if Project.column_names.include?('team_members')
    remove_column :projects, :airworthiness_reps           if Project.column_names.include?('airworthiness_reps')
  end
end
