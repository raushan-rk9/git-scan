class ProblemReportsController < ApplicationController
  include Common

  respond_to    :docx

  skip_before_action :verify_authenticity_token

  before_action :set_problem_report, only: [:show, :edit, :update, :destroy, :mark_as_deleted, :send_email, :email_problem_report]
  before_action :get_project_byparam
  before_action :set_item
  before_action :get_projects, only: [:new, :edit, :update]
  before_action :get_users, only: [:new, :edit, :update]

  # GET /problem_reports
  # GET /problem_reports.json
  def index
    authorize :problem_report

    if params['clear_filter']
      session[:pr_filter_field] = nil
      session[:pr_filter_value] = nil
    end

    if session[:archives_visible]
      if params['problem_reports_assigned_to_me'] ||
         session[:problem_reports_assigned_to_me]
        if @item.present?
          @problem_reports = ProblemReport.where(project_id:   params[:project_id],
                                                 item_id:      @item.id,
                                                 organization: current_user.organization,
                                                 assignedto:   current_user.email)
        else
          @problem_reports = ProblemReport.where(project_id:   params[:project_id],
                                                 organization: current_user.organization,
                                                 assignedto:   current_user.email)
        end
      elsif params['my_problem_reports'] ||
            session[:my_problem_reports]
        if @item.present?
          @problem_reports = ProblemReport.where(project_id:   params[:project_id],
                                                 item_id:      @item.id,
                                                 organization: current_user.organization,
                                                 openedby:     current_user.email)
        else
          @problem_reports = ProblemReport.where(project_id:   params[:project_id],
                                                 organization: current_user.organization,
                                                 openedby:     current_user.email)
        end
      else
        if @item.present?
          @problem_reports = ProblemReport.where(project_id:   params[:project_id],
                                                 item_id:      @item.id,
                                                 organization: current_user.organization)
        else
          @problem_reports = ProblemReport.where(project_id:   params[:project_id],
                                                 organization: current_user.organization)
        end
      end
    else
      if params['problem_reports_assigned_to_me'] ||
         session[:problem_reports_assigned_to_me]
        @problem_reports = ProblemReport.where(project_id:   params[:project_id],
                                               organization: current_user.organization,
                                               assignedto:   current_user.email,
                                               archive_id:   nil)
      elsif params['my_problem_reports'] ||
            session[:my_problem_reports]
        @problem_reports = ProblemReport.where(project_id:   params[:project_id],
                                               organization: current_user.organization,
                                               openedby:     current_user.email,
                                               archive_id:   nil)
      elsif @item.try(:id)
        if @project.try(:id)
          @problem_reports = ProblemReport.where(project_id:   @project.id,
                                                 item_id:      @item.id,
                                                 organization: current_user.organization,
                                                 archive_id:   nil)
        else
          @problem_reports = ProblemReport.where(item_id:      @item.id,
                                                 organization: current_user.organization,
                                                 archive_id:   nil)
        end
      else
        @problem_reports = ProblemReport.where(project_id:   params[:project_id],
                                               organization: current_user.organization,
                                               archive_id:   nil)
      end
    end

    if params['only_open_problem_reports'] ||
       session[:only_open_problem_reports]
      @problem_reports   = @problem_reports.to_a.delete_if do |problem_report|
        problem_report.status == 'Closed'   ||
        problem_report.status == 'Deferred' ||
        problem_report.status == 'Rejected'
      end
    end

    if params[:filter_field].present? && params[:filter_value]
      session[:pr_filter_field] = params[:filter_field]
      session[:pr_filter_value] = params[:filter_value]
    end

    if session[:pr_filter_field].present? && session[:pr_filter_value]
      @problem_reports          = @problem_reports.to_a.delete_if do |problem_report|
        field                   = problem_report.attributes[session[:pr_filter_field]].to_s.upcase
        value                   = session[:pr_filter_value].upcase

        !field.index(value)
      end
    end

    @undo_path           = get_undo_path('problem_reports',
                                         project_problem_reports_path(@project))
    @redo_path           = get_redo_path('problem_reports',
                                         project_problem_reports_path(@project))
  end

  # GET /problem_reports
  # GET /problem_reports.json
  def filtered_index
    authorize :problem_report
  end

  # GET /problem_reports/1
  # GET /problem_reports/1.json
  def show
    authorize :problem_report

    @undo_path = get_undo_path('problem_reports',
                               project_problem_reports_path(@project))
    @redo_path = get_redo_path('problem_reports',
                               project_problem_reports_path(@project))
  end

  # GET /problem_reports/new
  def new
    authorize :problem_report
    @problem_report              = ProblemReport.new
    @problem_report.project_id   = @project.id
    @problem_report.prid         = @project.pr_count + 1
    # Fill in a problem report history action.
    @problem_report.prh_action   = "Create PR"
    @problem_report.openedby     = current_user.email
    @problem_report.dateopened   = DateTime.now
    @problem_report.datemodified = DateTime.now
    @problem_report.status       = 'Open'
    @undo_path                   = get_undo_path('problem_reports',
                                                 project_problem_reports_path(@project))
    @redo_path                   = get_redo_path('problem_reports',
                                                 project_problem_reports_path(@project))
  end

  # GET /problem_reports/1/edit
  def edit
    authorize @problem_report
    # Update the date modified.
    @problem_report.datemodified = DateTime.now
    @undo_path                   = get_undo_path('problem_reports',
                                                 project_problem_reports_path(@project))
    @redo_path                   = get_redo_path('problem_reports',
                                                 project_problem_reports_path(@project))
  end

  # POST /problem_reports
  # POST /problem_reports.json
  def create
    authorize :problem_report
    fix_sequence('problem_reports_id_seq')

    referenced_artifacts                           = problem_report_params[:referenced_artifacts]
    params[:problem_report][:referenced_artifacts] = nil
    params[:problem_report][:project_id]           = @project.id if !problem_report_params[:project_id].present? && @project.present?
    @problem_report                                = ProblemReport.new(problem_report_params)
    @problem_report.referenced_artifacts           = JSON.parse(referenced_artifacts) if referenced_artifacts.present?
    @data_change                                   = DataChange.save_or_destroy_with_undo_session(@problem_report,
                                                                                                  'create',
                                                                                                  @problem_report.id,
                                                                                                  'problem_reports')

    attach_file(problem_report_params[:attachment_file],
                "Attachment for #{@problem_report.fullpr_with_title}.",
                @data_change.session_id) if @data_change.present? &&
                                            problem_report_params[:attachment_file].present?

    if @data_change.present?
      # Increment the global counter, and save the project.
      @project.pr_count                           += 1
      @data_change                                 = DataChange.save_or_destroy_with_undo_session(@project,
                                                                                                  'update',
                                                                                                  @project.id,
                                                                                                  'projects',
                                                                                                  @data_change.session_id)

      # Create and fill in problem report history.
      prhistory_build('Create Problem Report')

      @data_change                                 = DataChange.save_or_destroy_with_undo_session(@prhistory,
                                                                                                  'create',
                                                                                                  @prhistory.id,
                                                                                                  'problem_report_histories',
                                                                                                  @data_change.session_id)

      if @data_change.present?
        begin
          mailer                                   = ProblemReportMailer.new

          mailer.new_email(@problem_report.id)
        rescue => e
          flash[:error]                = "Could not send email. Error: #{e.message}."
        end
      end

      respond_to do |format|
        format.html { redirect_to [@project, @problem_report], notice: 'Problem report was successfully created.' }
        format.json { render :show, status: :created, location: [@project, @problem_report] }
      end
    else
      respond_to do |format|
        format.html { render :new }
        format.json { render json: @problem_report.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /problem_reports/1
  # PATCH/PUT /problem_reports/1.json
  def update
    authorize @problem_report

    params[:problem_report][:project_id]           = @project.id if !problem_report_params[:project_id].present? && @project.present?
    params[:problem_report][:referenced_artifacts] = JSON.parse(problem_report_params[:referenced_artifacts]) if problem_report_params[:referenced_artifacts].present?
    changes                                        = prhistory_diff(@problem_report,
                                                                    problem_report_params)
    params[:problem_report][:prh_action]           = changes

    @problem_report.update_attributes(problem_report_params)

    @data_change                                   = DataChange.save_or_destroy_with_undo_session(@problem_report,
                                                                                                  'update',
                                                                                                   @problem_report.id,
                                                                                                   'problem_reports')

    if @data_change.present?
      @problem_report = ProblemReport.find_by(id:  @problem_report.id)

      # Create and fill in problem report history. Must be done after passing the params.

      prhistory_build(changes, @problem_report.status, @problem_report.criticality)

      @data_change                                 = DataChange.save_or_destroy_with_undo_session(@prhistory,
                                                                                                  'create',
                                                                                                  @prhistory.id,
                                                                                                  'problem_report_histories',
                                                                                                  @data_change.session_id)

      if @data_change.present?
        begin
          mailer                                   = ProblemReportMailer.new

          mailer.edit_email(@problem_report.id)
        rescue => e
          flash[:error]                            = "Could not send email. Error: #{e.message}."
        end
      end

      respond_to do |format|
        format.html { redirect_to [@project, @problem_report], notice: 'Problem report was successfully updated.' }
        format.json { render :show, status: :ok, location: [@project, @problem_report] }
      end
    else
      respond_to do |format|
        format.html { render :edit }
        format.json { render json: @problem_report.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /problem_reports/1/send_email
  def email_problem_report
    authorize @problem_report
  end

  # GET /problem_reports/1/send_email
  def send_email
    authorize @problem_report

    params[:problem_report][:project_id] = @project.id if !problem_report_params[:project_id].present? && @project.present?
    @problem_reports                     = [ @problem_report ]
    pdf                                  = render_to_string(pdf:      "problem_report_#{@problem_report.id}",
                                                            template: 'problem_reports/export_html.html.erb',
                                                            encoding: "UTF-8")

    begin
      mailer                             = ProblemReportMailer.new

      mailer.send_email(@problem_report.id,
                        params[:problem_report][:recipients],
                        params[:problem_report][:cc_list],
                        params[:problem_report][:comment],
                        "problem_report-#{@problem_report.id}.pdf",
                        'application/pdf',
                        pdf)

      @notice                            = 'Problem report was successfully sent.'
      flash[:info]                       = notice
    rescue => e
      @notice                            = "Could not send email. Error: #{e.message}."
      flash[:error]                      = notice
    end

    respond_to do |format|
      format.html { redirect_to [@project, @problem_report], notice: @notice }
    end
  end

  def export
    authorize :problem_report

    # Get all problem reports
    if session[:archives_visible]
      @problem_reports = ProblemReport.where(project_id: params[:project_id],
                                             organization: current_user.organization).order(:prid)
    else
      @problem_reports = ProblemReport.where(project_id:   params[:project_id],
                                             organization: current_user.organization,
                                             archive_id:   nil).order(:prid)
    end

    respond_to do |format|
      if params[:pr_export].try(:has_key?, :export_type) && params[:pr_export][:export_type] == 'HTML'
        format.html { render "problem_reports/export_html", layout: false }
        format.json { render :show, status: :ok, location: @problem_report }
      elsif params[:pr_export].try(:has_key?, :export_type) && params[:pr_export][:export_type] == 'PDF'
        format.html { redirect_to project_problem_reports_export_path(format: :pdf) }
      elsif params[:pr_export].try(:has_key?, :export_type) && params[:pr_export][:export_type] == 'CSV'
        # Come back here using the csv format to generate the csv below.
        format.html { redirect_to project_problem_reports_export_path(format: :csv) }
      elsif params[:pr_export].try(:has_key?, :export_type) && params[:pr_export][:export_type] == 'XLS'
        # Come back here using the xls format to generate the xls below.
        format.html { redirect_to project_problem_reports_export_path(format: :xls) }
      elsif params[:pr_export].try(:has_key?, :export_type) && params[:pr_export][:export_type] == 'DOCX'
        # Come back here using the docx format to generate the docx below.
        if convert_data("ProblemReports.docx",
                        'problem_reports/export_html.html.erb',
                         @item.present? ? @item.id : params[:item_id])
          format.html { redirect_to  project_problem_reports_export_path(filename: @converted_filename, format: :docx, starting_number: params[:md_export].try(:has_key?, :starting_number) ) }
        else
          flash[:error]  = @conversion_error
          params[:level] = 2

          go_back
        end
      else
        format.html { render :export }
        format.json { render json: @problem_report.errors, status: :unprocessable_entity }
        # If redirected using format => csv, generate the csv here.
        format.csv  { send_data ProblemReport.to_csv(@project.id), filename: "#{@project.name}-Problem_Reports.csv" }
        format.xls  { send_data ProblemReport.to_xls(@project.id), filename: "#{@project.name}-Problem_Reports.xls" }
        format.pdf  {
                       @no_links = true

                       render(pdf:         "#{@project.name}-Problem_Reports",
                              template:    'problem_reports/export_html.html.erb',
                              title:       'Problem Reports: Export PDF | PACT',
                              footer:      {
                                              right: '[page] of [topage]'
                                           },
                              orientation: 'Landscape')
                    }
        format.docx {
                       return_file(params[:filename])
                    }
      end
    end
  end

  def import_problem_reports
    import              = params[import_path]

    return false unless import.present?

    check_download      = []
    filename            = nil
    error               = false
    id                  = import['project_select'].to_i if import['project_select'] =~ /^\d+$/
    file                = import['file']

    if file.present?
      filename          = if file.path.present?
                            file.path
                          elsif file.tempfile.present?
                            file.tempfile.path
                          end
    end

    if !error
      if id.present?
        @project        = Project.find(id)
      else
        flash[:alert]   = 'No Project Selected'
        error           = true
      end
    end

    if !error
      if filename.present?
        @project        = Project.find(id)
      else
        flash[:alert]   = 'No File Selected'
        error           = true
      end
    end

    if !((filename  =~ /^.+\.csv$/i)   ||
         ((filename =~ /^.+\.xlsx$/i)) ||
         ((filename =~ /^.+\.xls$/i))) && !error
      flash[:alert]   = 'You can only import a CSV, an xlsx or an XLS file'
      error           = true
    end

    check_download.push(:check_duplicates) if params[import_path]['duplicates_permitted']          != '1'

    if !error
      if ProblemReport.from_file(filename, @project, check_download) == :duplicate_problem_report
        if @project.errors.messages.empty?
          flash[:alert] = "File: #{file.original_filename} contains existing Problem Reports. Choose Duplicates Permitted to import duplicates."
        end

        error           = true
      end
    end

    if !error
      unless ProblemReport.from_file(filename, @project)
        if @project.errors.messages.empty?
          flash[:alert]   = "Cannot import: #{file.original_filename}"
        else
          @project.errors.messages.each do |key, value|
            flash[:alert] += "\n" + value
          end
        end

        error              = true
      end
    end

    return !error
  end

  def import
    authorize :problem_report

    if params[import_path].present?
      if import_problem_reports
        respond_to do |format|
          format.html {redirect_to project_problem_reports_path(@project), notice: 'Problem reports were successfully imported.' }
          format.json { head :no_content }
        end
      else
        respond_to do |format|
          format.html { redirect_to project_problem_reports_import_path(@project) }
          format.json { render json: @project.errors, status: :unprocessable_entity }
        end
      end
    else
      respond_to do |format|
        format.html { render :import }
        format.json { render json: @problem_report.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /problem_reports/1
  # DELETE /problem_reports/1.json
  def destroy
    authorize @problem_report

    @problem_report.prh_action = "Delete PR"

    prhistory_build('Problem Report Deleted', 'Closed')

    @data_change      = DataChange.save_or_destroy_with_undo_session(@problem_report,
                                                                     'delete',
                                                                     @problem_report.id,
                                                                     'problem_reports')

    if @data_change.present?
      begin
        mailer        = ProblemReportMailer.new

        mailer.delete_email(@problem_report)
      rescue => e
        flash[:error] = "Could not send emailopenedby. Error: #{e.message}."
      end

      respond_to do |format|
        format.html { redirect_to project_problem_reports_url, notice: 'Problem report was successfully removed.' }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html { render :index, error: 'Could not delete problem report item.'}
        format.json { render json: @problem_report.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /problem_reports/open
  def open_problem_reports_report
    authorize :problem_report

    if session[:archives_visible]
      if params['problem_reports_assigned_to_me'] ||
         session[:problem_reports_assigned_to_me]
        @problem_reports = ProblemReport.where(project_id:   params[:project_id],
                                               organization: current_user.organization,
                                               assignedto:   current_user.email).to_a
      elsif params['my_problem_reports'] ||
            session[:my_problem_reports]
        @problem_reports = ProblemReport.where(project_id:   params[:project_id],
                                               organization: current_user.organization,
                                               openedby:     current_user.email).to_a
      else
        @problem_reports = ProblemReport.where(project_id:   params[:project_id],
                                               organization: current_user.organization).to_a
      end
    else
      if params['problem_reports_assigned_to_me'] ||
         session[:problem_reports_assigned_to_me]
        @problem_reports = ProblemReport.where(project_id:   params[:project_id],
                                               organization: current_user.organization,
                                               assignedto:   current_user.email,
                                               archive_id:  nil).to_a
      elsif params['my_problem_reports'] ||
            session[:my_problem_reports]
        @problem_reports = ProblemReport.where(project_id:   params[:project_id],
                                               organization: current_user.organization,
                                               openedby:     current_user.email,
                                               archive_id:  nil).to_a
      else
        @problem_reports = ProblemReport.where(project_id:   params[:project_id],
                                               organization: current_user.organization,
                                               archive_id:  nil).to_a
      end
    end

    @problem_reports = @problem_reports.delete_if do |problem_report|
      problem_report.status == 'Closed'   ||
      problem_report.status == 'Deferred' ||
      problem_report.status == 'Rejected'
    end

    respond_to do |format|
      format.html { render :open_problem_reports }
    end
  end

  # GET /problem_reports/1/mark_as_deleted/
  # GET /problem_reports/1/mark_as_deleted.json
  def mark_as_deleted
    authorize @problem_report

    @problem_report.title         = I18n.t('misc.deleted')
    @problem_report.status        = nil
    @problem_report.description   = nil
    @problem_report.openedby      = nil
    @problem_report.assignedto    = nil
    @problem_report.safetyrelated = nil
    @problem_report.criticality   = nil
    @data_change                  = DataChange.save_or_destroy_with_undo_session(@problem_report,
                                                                                'update',
                                                                                 @problem_report.id,
                                                                                'problem_reports')

    if @data_change.present?
      respond_to do |format|
        format.html { redirect_to project_problem_reports_url, notice: 'Problem report was successfully marked as deleted.' }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html { render :edit, error: 'Could not delete Problem Report'}
        format.json { render json: @problem_report.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_problem_report
      if params[:id].present?
        @problem_report = ProblemReport.find(params[:id])
      elsif params[:problem_report_id].present?
        @problem_report = ProblemReport.find(params[:problem_report_id])
      end
    end

    def set_item
      if params[:item_id].present?
        @item = Item.find(params[:item_id])

        if @item.present? && @item.project_id.present? && !@project.present?
          @project = Project.find(@item.project_id)
        end
      end
    end

    def prhistory_diff(problem_report, updated_params)
      result      = ""
      changes     = []

      return result unless problem_report.present? && updated_params.present?

      problem_report.attributes.each do |attribute, value|
        if value.kind_of?(Time)
          old_value = value.to_date.to_s
        elsif value.kind_of?(FalseClass)
          old_value = '0'
        elsif value.kind_of?(TrueClass)
          old_value = '1'
        else
          old_value = value.to_s
        end

        new_value = updated_params[attribute]

        next unless old_value.present? &&
                    new_value.present? &&
                    (old_value != new_value)
        change    = "#{attribute} changed from '#{old_value}' to '#{new_value}'."

        changes.push(change)
      end

      result      = changes.join("\n") if changes.present?

      return result
    end

    # Build and populate a problem report history.
    def prhistory_build(action, status = 'New', severity_type = nil)
      # Build the problem report history.
      @prhistory               = @problem_report.problem_report_history.build
      # Add details from problem report into this history automatically.
      @prhistory.modifiedby    = current_user.email
      @prhistory.project_id    = @project.id
      @prhistory.action        = action
      @prhistory.status        = status
      @prhistory.severity_type = severity_type
      @prhistory.datemodified  = DateTime.now
    end

    # Add an attachment.
    def attach_file(file, description, session_id)
      @problem_report_attachment                   = ProblemReportAttachment.new
      @problem_report_attachment.problem_report_id = @problem_report.id
      @problem_report_attachment.project_id        = @problem_report.project_id
      @problem_report_attachment.item_id           = @problem_report.item_id
      @problem_report_attachment.user              = current_user.email
      @problem_report_attachment.link_type         = Constants::UPLOAD_ATTACHMENT
      @problem_report_attachment.link_link         = file.original_filename
      @problem_report_attachment.link_description  = if description.present?
                                                       description
                                                     else
                                                       file.original_filename
                                                     end

      DataChange.save_or_destroy_with_undo_session(@problem_report_attachment,
                                                   'create',
                                                   @problem_report_attachment.id,
                                                   'problem_report_attachments',
                                                   session_id)
      @problem_report_attachment.store_file(file, session_id)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def problem_report_params
      params.require(
                       :problem_report
                     ).
             permit(
                       :prid,
                       :dateopened,
                       :status,
                       :openedby,
                       :title,
                       :product,
                       :criticality,
                       :source,
                       :discipline_assigned,
                       :assignedto,
                       :target_date,
                       :close_date,
                       :description,
                       :problemfoundin,
                       :correctiveaction,
                       :fixed_in,
                       :verification,
                       :feedback,
                       :notes,
                       :meeting_id,
                       :safetyrelated,
                       :datemodified,
                       :prh_action,
                       :project_id,
                       :item_id,
                       :referenced_artifacts,
                       :attachment_file,
                       :recipients,
                       :cc_list,
                       :comment,
                       problem_report_history_attributes: [
                                                             :action,
                                                             :modifiedby,
                                                             :status,
                                                             :datemodified,
                                                             :project_id,
                                                             :problem_report_id,
                                                             :_destroy
                                                          ],
                       problem_report_history_id: [],
                       referenced_artifacts: {}
                       )
    end
end
