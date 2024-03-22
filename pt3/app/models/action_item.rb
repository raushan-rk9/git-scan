class ActionItem < OrganizationRecord
  belongs_to :review,      optional: true
  belongs_to :item,        optional: true
  belongs_to :project,     optional: true

  # Validations
  validates :review_id,    presence: true, allow_blank: false
  validates :project_id,   presence: true, allow_blank: false
  validates :item_id,      presence: true, allow_blank: false
  validates :actionitemid, presence: true, allow_blank: false
  validates :description,  presence: true, allow_blank: false

  # Determine if Action Item is Closed or Open
  def isclosed
    closed_status = false
    if status == "Closed" || status == "Deferred"
      closed_status = true
    else
      closed_status = false
    end
    return closed_status
  end
end
