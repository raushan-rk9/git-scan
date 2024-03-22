class AddAttachmentTypeToReviewAttachments < ActiveRecord::Migration[5.2]
  def change
    add_column :review_attachments, :attachment_type, :string
  end
end
