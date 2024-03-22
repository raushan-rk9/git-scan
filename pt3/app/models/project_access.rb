class ProjectAccess < OrganizationRecord
  belongs_to :user
  belongs_to :project

  serialize  :access,          Array

  validates  :user_id,         presence: true
  validates  :project_id,      presence: true
  validate   :access_is_valid

  ACCESS_TYPES = [
                   'OWNER',
                   'FULL',
                   'CHANGE',
                   'READ ONLY'
                 ]

  def access_is_valid
    if access.present?
      access.each do |access_type|
        unless ACCESS_TYPES.include?(access_type.upcase)
          errors.add(:access, "Invalid access type: #{access_type}.")
        end
      end
    end
  end
end
