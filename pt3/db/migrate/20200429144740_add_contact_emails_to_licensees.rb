class AddContactEmailsToLicensees < ActiveRecord::Migration[5.2]
  def change
    add_column :licensees, :contact_emails, :string
  end
end
