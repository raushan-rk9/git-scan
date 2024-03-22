class Review < OrganizationRecord
  belongs_to :item
  belongs_to :project
  # Use has_many to in order to put foreign key in checklist item table.
  # https://stackoverflow.com/a/861899
  has_many :checklist_item, inverse_of: :review, dependent: :destroy
  accepts_nested_attributes_for :checklist_item, allow_destroy: true
  # Access action items from reviews
  has_many :action_item, inverse_of: :review, dependent: :destroy
  accepts_nested_attributes_for :action_item, allow_destroy: true
  # Access file attachments from reviews
  has_many :review_attachment, inverse_of: :review, dependent: :destroy
  accepts_nested_attributes_for :review_attachment, allow_destroy: true

  serialize :problem_reports_addressed, Array
  serialize :evaluators,                Array
  serialize :sign_offs,                 Array

  # Validations
  validates :reviewid,   presence: true, allow_blank: false
  validates :project_id, presence: true, allow_blank: false
  validates :item_id,    presence: true, allow_blank: false
  validates :title,      presence: true, allow_blank: false

  # Instantiate variables not in database
  attr_accessor :review_type
  attr_accessor :removeallclitems
  attr_accessor :link_type
  attr_accessor :link_link
  attr_accessor :link_description
  attr_accessor :file
  attr_accessor :pact_file
  attr_accessor :unassigned_users
  attr_accessor :attachments

  # Files
  has_one_attached :file, dependent: false
  # Validate only size. Do not validate if file is not attached.
  validates :file, file_size: { less_than_or_equal_to: 200.megabytes }, if: proc { file.attached? }

  # Generate Item identifier + id
  def fullreviewid
    "#{item.identifier}-REVIEW-#{reviewid.to_s}"
  end

  # Count all of the non-closed action items.
  def actionitems_open
    count = 0
    action_item.each do |ai|
      if ai.isclosed == false
        count += 1
      end
    end
    return count
  end

  # Total number of evaluators@review.evaluators
  def evaluators_assigned
    @review.evaluators.present? ? @review.evaluators.length: 0
  end

  # Total number of checklist items.
  def checklistitems_unassigned
    checklist_items = ChecklistItem.where(review_id: id,
                                          assigned:  false)

    return checklist_items.count
  end

  # Total number of checklist items.
  def checklistitems_assigned
    checklist_items = ChecklistItem.where(review_id: id,
                                          assigned:  true)

    return checklist_items.present? ? checklist_items.count : 0
  end

  # Total number of checklist items.
  def checklistitems_totalnumber
    checklist_items = ChecklistItem.where(review_id: id)

    return checklist_items.present? ? checklist_items.count : 0
  end

  # Passing number of checklist items.
  def checklistitems_passingnumber
    checklist_items = ChecklistItem.where(review_id: id,
                                          status:    'Pass')

    return checklist_items.present? ? checklist_items.count : 0
  end

  # Failing number of checklist items.
  def checklistitems_failingnumber
    checklist_items = ChecklistItem.where(review_id: id,
                                          status:    'Fail')

    return checklist_items.present? ? checklist_items.count : 0
  end

  def checklistitems_na_number
    checklist_items = ChecklistItem.where(review_id: id,
                                          status:    'N/A')

    return checklist_items.present? ? checklist_items.count : 0
  end

  # Unticked checklist items (neither passing nor failing).
  def checklistitems_neithernumber
    checklist_items = ChecklistItem.where(review_id: id,
                                          assigned:  true,
                                          status:    nil)

    return checklist_items.present? ? checklist_items.count : 0
  end

  def checklistitems_percentage_completed
    assigned   = checklistitems_assigned.to_f
    incomplete = checklistitems_neithernumber.to_f

    if incomplete == 0
      100.00
    elsif (assigned > 0) && (assigned > incomplete)
      ((assigned - incomplete) / assigned) * 100.0
    else
      0.0
    end
  end

  # Unticked checklist items (neither passing nor failing).
  def checklistitems_percentage_incomplete
    100.0 - checklistitems_percentage_completed
  end

  # Is the checklist passing based on the number of passing, failing, and neither checklist items?
  def checklistitems_passing
    passing_status = false

    if  (checklistitems_assigned      >  0) &&
        (checklistitems_failingnumber == 0) &&
       ((checklistitems_passingnumber + checklistitems_na_number) >= checklistitems_assigned)
      passing_status = true
    end

    return passing_status
  end

  # Check if the review is passing, based on the checklist items and the open action items.
  def review_passing
    checklistitems_passing
  end

  # Create csv
  def self.to_csv
    attributes = %w{id reviewid reviewtype title description version item project}

    CSV.generate(headers: true) do |csv|
      csv << attributes

      columns = []

      all.each do |review|
        columns = []

        attributes.each do |attribute|
          if attribute == "evaluators"
            value = review[attribute].join("\n")
          else
            value = Sanitize.fragment(review[attribute]).gsub('&nbsp;', ' ').strip
          end

          columns.push(value)
        end
      end

      csv << columns
    end
  end
end
