class ProblemReportHistory < OrganizationRecord
  belongs_to :project, optional: true
  belongs_to :problem_report, optional: true
  # Validations
  # Don't validate the presense of the problem report ID here.
  # validates :problem_report_id, presence: true
  validates :project_id, presence: true
end
