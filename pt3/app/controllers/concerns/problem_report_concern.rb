module ProblemReportConcern
  extend ActiveSupport::Concern

  # Get review
  def get_pr
    @problem_report = ProblemReport.find_by(:id => params[:problem_report_id])

    unless @project.present?
      @project = Project.find(@problem_report.project_id) if @problem_report.present?
    end
  end

  # Get all reviews for item
  def get_prs
    if session[:archives_visible]
      @problem_reports = ProblemReport.where(project_id: params[:project_id],
                                             organization: current_user.organization)
    else
      @problem_reports = ProblemReport.where(project_id: params[:project_id],
                                             organization: current_user.organization,
                                             archive_id: nil)
    end
  end
end
