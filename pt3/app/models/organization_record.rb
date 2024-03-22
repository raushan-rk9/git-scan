class OrganizationRecord < ApplicationRecord
  self.abstract_class = true

  before_validation :set_organization

  def set_organization
    unless self.organization == 'global'
      if User.current.present? && self.organization.present? && self.organization != User.current.organization
        logger.info("Current User Organization: #{User.current.organization}")
        logger.info("Record Organization: #{self.organization}")
        raise 'Current Organization does not match Record Orgranization'
      end
    end

    self.organization = User.current.organization if User.current.present?
  end

  def self.json_create(o)
    new(*o['data'])
  end

  def to_json(*a)
    data          = self.attributes
    attached_file = if self.respond_to?(:upload_file) && self.upload_file.attached?
                      file = self.upload_file
                    elsif self.respond_to?(:file) && self.file.attached?
                      file = self.upload_file
                    end

    if attached_file.present?
      {
        'json_class' => self.class.name,
        'data'       => data,
        'file'       => {
                          filename:     attached_file.filename,
                          content_type: attached_file.content_type,
                          contents:     Base64.encode64(file.download)
                        }
      }.to_json()
    else
      {
        'json_class' => self.class.name,
        'data'       => data
      }.to_json()
    end
  end
end
