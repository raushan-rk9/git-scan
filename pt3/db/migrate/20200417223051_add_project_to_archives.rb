class AddProjectToArchives < ActiveRecord::Migration[5.2]
  def change
    add_reference :archives, :project,      index: true
    add_column    :archives, :pact_version, :string
  end
end
