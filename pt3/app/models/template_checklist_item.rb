class TemplateChecklistItem < OrganizationRecord
  belongs_to :template_checklist

  # Define minimumdal, supplements as an array type.
  serialize :minimumdal,  Array
  serialize :supplements, Array

  validates  :template_checklist_id, presence: true
end
