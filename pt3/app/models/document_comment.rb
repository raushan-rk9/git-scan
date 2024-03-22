class DocumentComment < OrganizationRecord
  belongs_to :item, optional: true
  belongs_to :project, optional: true
  belongs_to :document, optional: true
  # Validations
  validates :commentid, presence: true
  validates :project_id, presence: true
  validates :item_id, presence: true
end
