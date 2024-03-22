class ProblemReportHistoriesController < ApplicationController
  include Common
  before_action :set_problem_report_history, only: [:show, :edit, :update, :destroy]
  before_action :get_project_byparam
  before_action :get_projects, only: [:new, :edit, :update]
  before_action :get_pr
  before_action :get_prs, only: [:new, :edit, :update]

  # GET /problem_report_histories
  # GET /problem_report_histories.json
  def index
    authorize :problem_report_history

    if session[:archives_visible]
      @problem_report_histories = ProblemReportHistory.where(problem_report_id: params[:problem_report_id],
                                                             organization:      current_user.organization).order(:datemodified)
    else
      @problem_report_histories = ProblemReportHistory.where(problem_report_id: params[:problem_report_id],
                                                             organization:      current_user.organization,
                                                             archive_id:        nil).order(:datemodified)
    end

    if params[:filter_field].present? && params[:filter_value]
      session[:prh_filter_field] = params[:filter_field]
      session[:prh_filter_value] = params[:filter_value]
      @problem_report_histories  = @problem_report_histories.to_a.delete_if do |problem_report_history|
        field                    = problem_report_history.attributes[params[:filter_field]].upitem
        value                    = params[:filter_value].upitem

        !field.index(value)
      end
    end
  end

  # GET /problem_report_histories/1
  # GET /problem_report_histories/1.json
  def show
    authorize :problem_report_history

    @undo_path = get_undo_path('problem_report_histories',
                               problem_report_problem_report_histories_path(@problem_report))
    @redo_path = get_redo_path('problem_report_histories',
                               problem_report_problem_report_histories_path(@problem_report))
  end

  # GET /problem_report_histories/new
  def new
    authorize :problem_report_history
    @problem_report_history                   = ProblemReportHistory.new
    @problem_report_history.problem_report_id = @problem_report.id
    @problem_report_history.project_id        = @problem_report.project_id
    @problem_report_history.datemodified      = DateTime.now
    @problem_report_history.modifiedby        = current_user.email
  end

  # GET /problem_report_histories/1/edit
  def edit
    authorize @problem_report_history

    @undo_path = get_undo_path('problem_report_histories',
                               problem_report_problem_report_histories_path(@problem_report))
    @redo_path = get_redo_path('problem_report_histories',
                               problem_report_problem_report_histories_path(@problem_report))
  end

  # POST /problem_report_histories
  # POST /problem_report_histories.json
  def create
    authorize :problem_report_history

    params[:problem_report_history][:problem_report_id]    = @problem_report.id         if !problem_report_history_params[:problem_report_id].present? && @problem_report.present?
    params[:problem_report_history][:project_id]           = @problem_report.project_id if !problem_report_history_params[:project_id].present?        && @problem_report.present?
    @projects                                              = Project.where(organization: current_user.organization)
    @problem_report_history                                = ProblemReportHistory.new(problem_report_history_params)

    respond_to do |format|
        @data_change = DataChange.save_or_destroy_with_undo_session(@problem_report_history,
                                                                    'create',
                                                                    @problem_report_history.id,
                                                                    'problem_report_histories')

      if @data_change.present?
        format.html { redirect_to [@problem_report, @problem_report_history], notice: 'Problem report history was successfully created.' }
        format.json { render :show, status: :created, location: [@problem_report, @problem_report_history] }
      else
        format.html { render :new }
        format.json { render json: @problem_report_history.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /problem_report_histories/1
  # PATCH/PUT /problem_report_histories/1.json
  def update
    authorize @problem_report_history

    params[:problem_report_history][:problem_report_id] = @problem_report.id         if !problem_report_history_params[:problem_report_id].present? && @problem_report.present?
    params[:problem_report_history][:project_id]        = @problem_report.project_id if !problem_report_history_params[:project_id].present?        && @problem_report.present?

    respond_to do |format|
        @data_change                                    = DataChange.save_or_destroy_with_undo_session(problem_report_history_params,
                                                                                                       'update',
                                                                                                       params[:id],
                                                                                                       'problem_report_histories')

      if @data_change.present?
        format.html { redirect_to [@problem_report, @problem_report_history], notice: 'Problem report history was successfully updated.' }
        format.json { render :show, status: :ok, location: [@problem_report, @problem_report_history] }
      else
        format.html { render :edit }
        format.json { render json: @problem_report_history.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /problem_report_histories/1
  # DELETE /problem_report_histories/1.json
  def destroy
    authorize @problem_report_history
      @data_change = DataChange.save_or_destroy_with_undo_session(@problem_report_history,
                                                                  'delete',
                                                                  @problem_report_history.id,
                                                                  'problem_report_histories')

    respond_to do |format|
      format.html { redirect_to problem_report_problem_report_histories_url, notice: 'Problem report history was successfully removed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_problem_report_history
      @problem_report_history = ProblemReportHistory.find(params[:id])
    end

    # Get problem report
    def get_pr
      @problem_report = ProblemReport.find_by(:id => params[:problem_report_id])

      unless @project.present?
        @project = Project.find(@problem_report.project_id) if @problem_report.present?
      end
    end

    # Get all problem reports for project
    def get_prs
      if session[:archives_visible]
        @problem_reports = ProblemReport.where(project_id:   params[:project_id],
                                               organization: current_user.organization)
      else
        @problem_reports = ProblemReport.where(project_id:   params[:project_id],
                                               organization: current_user.organization,
                                               archive_id:  nil)
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def problem_report_history_params
      params.require(:problem_report_history).permit(:action, :modifiedby, :status, :severity_type, :datemodified, :project_id, :problem_report_id)
    end
end
