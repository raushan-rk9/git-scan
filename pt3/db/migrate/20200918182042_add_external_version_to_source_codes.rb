class AddExternalVersionToSourceCodes < ActiveRecord::Migration[5.2]
  def change
    add_column :source_codes, :external_version, :string
  end
end
