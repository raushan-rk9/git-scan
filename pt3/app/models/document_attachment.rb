class DocumentAttachment < OrganizationRecord
  belongs_to :item, optional: true
  belongs_to :project, optional: true
  belongs_to :document, optional: true
  # Validations
  validates :document_id, presence: true
  validates :project_id, presence: true
  validates :item_id, presence: true
  validates :user, presence: true
  # Files
  has_one_attached :file, dependent: false
  # Validate only size. Do not validate if file is not attached.
  validates :file, file_size: { less_than_or_equal_to: 200.megabytes }, if: proc { file.attached? }
end
