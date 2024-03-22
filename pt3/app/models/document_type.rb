class DocumentType < OrganizationRecord
  # Validations
  validates :document_code, presence: true
  validates :description,   presence: true

  serialize :item_types,    Array
  serialize :dal_levels,    Array
end
