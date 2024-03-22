class CreateDocuments < ActiveRecord::Migration[5.1]
  def change
    create_table :documents do |t|
      t.integer    :document_id
      t.string     :docid
      t.text       :name
      t.string     :category
      # Revision is the customer maintained version of the document
      t.string     :revision
      t.string     :draft_revision
      t.string     :document_type
      t.string     :review_status
      t.date       :revdate
      # Version is the internally maintained number of times the document has been changed.
      t.integer    :version
      t.references :item,             foreign_key: true
      t.references :project,          foreign_key: true
      t.references :review,           foreign_key: true

      # Optional Reference to parent folder
      t.references :parent,           foreign_key: false, belongs_to: :documents
      t.string     :file_path
      t.string     :file_type

      # Use to keep counters for ID based models.
      t.integer    :doccomment_count, default: 0

      t.timestamps
    end

    add_index  :documents, :document_id
  end
end
