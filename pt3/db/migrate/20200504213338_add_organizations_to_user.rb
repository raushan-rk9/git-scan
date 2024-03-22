class AddOrganizationsToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :organizations, :string
  end
end
