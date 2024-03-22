class Licensee < ApplicationRecord
  # Validations
  validates :identifier,     presence: true, allow_blank: false
  validates :name,           presence: true, allow_blank: false
  validates :setup_date,     presence: true, allow_blank: false
  validates :license_date,   presence: true, allow_blank: false
  validates :renewal_date,   presence: true, allow_blank: false
  validates :administrator,  presence: true, allow_blank: false
  validates :contact_emails, presence: true, allow_blank: false

  # Serializations
  serialize :contact_emails, Array
end
