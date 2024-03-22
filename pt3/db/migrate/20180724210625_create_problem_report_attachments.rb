class CreateProblemReportAttachments < ActiveRecord::Migration[5.2]
  def change
    create_table   :problem_report_attachments do |t|
      t.references :problem_report,   foreign_key: true
      t.references :item,             foreign_key: true
      t.references :project,          foreign_key: true
      t.string     :link_type
      t.string     :link_description
      t.string     :link_link
      t.string     :user

      t.timestamps
    end
  end
end
