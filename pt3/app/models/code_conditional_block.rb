class CodeConditionalBlock < OrganizationRecord
  belongs_to :source_code

  validates  :source_code,       presence: true
  validates  :filename,          presence: true
  validates  :start_line_number, presence: true
  validates  :end_line_number,   presence: true
end
