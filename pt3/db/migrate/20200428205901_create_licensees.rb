class CreateLicensees < ActiveRecord::Migration[5.2]
  def change
    create_table :licensees do |t|
      t.string :identifier
      t.string :name
      t.text :description
      t.date :setup_date
      t.date :license_date
      t.string :license_type
      t.date :renewal_date
      t.string :administrator
      t.text :contact_information

      t.timestamps
    end
  end
end
