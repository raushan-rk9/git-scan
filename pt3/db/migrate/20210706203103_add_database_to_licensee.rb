class AddDatabaseToLicensee < ActiveRecord::Migration[5.2]
  def change
    add_column :licensees, :database, :string
    add_column :licensees, :encrypted_password, :string
  end
end
