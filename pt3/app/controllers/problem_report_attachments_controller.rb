class ProblemReportAttachmentsController < ApplicationController
  include Common
  include ProblemReportConcern

  skip_before_action :verify_authenticity_token

  before_action :set_problem_report_attachment, only: [:show, :edit, :update, :destroy, :get_attachment ]
  before_action :get_items, only: [:new, :edit, :update]
  before_action :get_project_byparam
  before_action :get_projects, only: [:new, :edit, :update]
  before_action :get_pr
  before_action :get_prs, only: [:new, :edit, :update]
  before_action :get_users, only: [:new, :edit, :update]

  # GET /problem_report_attachments
  # GET /problem_report_attachments.json
  def index
    authorize :problem_report_attachment

    if session[:archives_visible]
      @problem_report_attachments = ProblemReportAttachment.where(problem_report_id: params[:problem_report_id],
                                                                  organization:      current_user.organization)
    else
      @problem_report_attachments = ProblemReportAttachment.where(problem_report_id: params[:problem_report_id],
                                                                  organization:      current_user.organization,
                                                                  archive_id:       nil)
    end

    if params[:filter_field].present? && params[:filter_value]
      session[:pra_filter_field]  = params[:filter_field]
      session[:pra_filter_value]  = params[:filter_value]
      @problem_report_attachments = @problem_report_attachments.to_a.delete_if do |problem_report_attachment|
        field                     = problem_report_attachment.attributes[params[:filter_field]].upitem
        value                     = params[:filter_value].upitem

        !field.index(value)
      end
    end

    @undo_path                    = get_undo_path('problem_report_attachments',
                                                  problem_report_problem_report_attachments_path(@problem_report))
    @redo_path                    = get_redo_path('problem_report_attachments',
                                                  problem_report_problem_report_attachments_path(@problem_report))
  end

  # GET /problem_report_attachments/1
  # GET /problem_report_attachments/1.json
  def show
    authorize :problem_report_attachment

    @undo_path = get_undo_path('problem_report_attachments',
                               problem_report_problem_report_attachments_path(@problem_report))
    @redo_path = get_redo_path('problem_report_attachments',
                               problem_report_problem_report_attachments_path(@problem_report))
  end

  # GET /problem_report_attachments/new
  def new
    authorize :problem_report_attachment

    @pact_files                                  = get_pact_files
    @problem_report_attachment                   = ProblemReportAttachment.new
    @problem_report_attachment.problem_report_id = @problem_report.id
    @problem_report_attachment.project_id        = @problem_report.project_id
    @problem_report_attachment.item_id           = @problem_report.item_id
    @problem_report_attachment.user              = current_user.email
    @undo_path                                   = get_undo_path('problem_report_attachments',
                                                                 problem_report_problem_report_attachments_path(@problem_report))
    @redo_path                                   = get_redo_path('problem_report_attachments',
                                                                 problem_report_problem_report_attachments_path(@problem_report))
  end

  # GET /problem_report_attachments/1/edit
  def edit
    authorize @problem_report_attachment

    @pact_files = get_pact_files
    @undo_path  = get_undo_path('problem_report_attachments',
                                problem_report_problem_report_attachments_path(@problem_report))
    @redo_path  = get_redo_path('problem_report_attachments',
                                problem_report_problem_report_attachments_path(@problem_report))
  end

  # POST /problem_report_attachments
  # POST /problem_report_attachments.json
  def create
    authorize :problem_report_attachment

    params[:problem_report_attachment][:problem_report_id] = @problem_report.id         if !problem_report_attachment_params[:problem_report_id].present? && @problem_report.present?
    params[:problem_report_attachment][:project_id]        = @problem_report.project_id if !problem_report_attachment_params[:project_id].present?        && @problem_report.present?

    if problem_report_attachment_params['link_type'] == 'PACT'
      params['problem_report_attachment']['link_link']     = problem_report_attachment_params['pact_file']
    elsif  problem_report_attachment_params['link_type'] == 'ATTACHMENT'
      file                                                 = problem_report_attachment_params['file']

      if file.present?
        params['problem_report_attachment']['link_link']   = file.original_filename
      end
    end

    if problem_report_attachment_params['link_type'] != 'PACT'
      if problem_report_attachment_params['link_link'] =~ /^.*\/(.+)$/
        params['problem_report_attachment']['link_description'] = $1
      else
        params['problem_report_attachment']['link_description'] = problem_report_attachment_params['link_link']
      end
    end

    @problem_report_attachment                             = ProblemReportAttachment.new(problem_report_attachment_params)
    @problem_report_attachment.upload_date                 = DateTime.now()

    respond_to do |format|
        @data_change                                       = DataChange.save_or_destroy_with_undo_session(@problem_report_attachment,
                                                                                                          'create',
                                                                                                          @problem_report_attachment.id,
                                                                                                          'problem_report_attachments')

      if @data_change.present?
        return_link                                        = problem_report_problem_report_attachments_path(@problem_report)
        problem_report                                     = get_session_link('problem_reports',
                                                                              'edit')
        if problem_report.present?
          return_link = edit_problem_report_path(problem_report[:link]['id'],
                                                 project_id: problem_report[:link]['project_id'])
        end

        format.html { redirect_to return_link, notice: 'Problem Report attachment was successfully created.' }
        format.json { render :show, status: :created, location: @problem_report_attachment }
      else
        format.html { render :new }
        format.json { render json: @problem_report_attachment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /problem_report_attachments/1
  # PATCH/PUT /problem_report_attachments/1.json
  def update
    authorize @problem_report_attachment

    params[:problem_report_attachment][:problem_report_id] = @problem_report.id         if !problem_report_attachment_params[:problem_report_id].present? && @problem_report.present?
    params[:problem_report_attachment][:project_id]        = @problem_report.project_id if !problem_report_attachment_params[:project_id].present?        && @problem_report.present?
    params[:problem_report_attachment][:upload_date]       = DateTime.now()
    @original_problem_report_attachment                    = ProblemReportAttachment.find(params[:id])
    new_attachment                                         = false

    if  problem_report_attachment_params['link_type'] == 'PACT'
      params['problem_report_attachment']['link_link']          = problem_report_attachment_params['pact_file']
    elsif  problem_report_attachment_params['link_type'] == 'ATTACHMENT'
      file                                              = problem_report_attachment_params['file']

      if !@original_problem_report_attachment.file.attached? &&
         problem_report_attachment_params[:file].present?
         new_attachment                                 = true
      end

      if file.present?
        params['problem_report_attachment']['link_link']        = file.original_filename
      end
    end

    if problem_report_attachment_params['link_type'] != 'PACT'
      if problem_report_attachment_params['link_link'] =~ /^.*\/(.+)$/
        params['problem_report_attachment']['link_description'] = $1
      else
        params['problem_report_attachment']['link_description'] = problem_report_attachment_params['link_link']
      end
    end

    respond_to do |format|
        @data_change                                       = DataChange.save_or_destroy_with_undo_session(problem_report_attachment_params,
                                                                                                          'update',
                                                                                                          params[:id],
                                                                                                          'problem_report_attachments')

      if @data_change.present?
        if new_attachment
          file                                             = problem_report_attachment_params[:file]
          @new_problem_report_attachment                   = ProblemReportAttachment.find(params[:id])

          file.tempfile.rewind

          begin
            @new_problem_report_attachment.file.attach(io:           file.tempfile,
                                                       filename:     file.original_filename,
                                                       content_type: file.content_type)
          rescue Errno::EACCES
            @new_problem_report_attachment.file.attach(io:           file.tempfile,
                                                       filename:     file.original_filename,
                                                       content_type: file.content_type)
          end
        end

        format.html { redirect_to [@problem_report, @problem_report_attachment], notice: 'Problem Report attachment was successfully updated.' }
        format.json { render :show, status: :ok, location: @problem_report_attachment }
      else
        format.html { render :edit }
        format.json { render json: @problem_report_attachment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /problem_report_attachments/1
  # DELETE /problem_report_attachments/1.json
  def destroy
    authorize @problem_report_attachment
      @data_change = DataChange.save_or_destroy_with_undo_session(@problem_report_attachment,
                                                                  'delete',
                                                                  @problem_report_attachment.id,
                                                                  'problem_report_attachments')

    respond_to do |format|
      format.html { redirect_to problem_report_problem_report_attachments_path(@problem_report), notice: 'Problem Report attachment was successfully removed.' }
      format.json { head :no_content }
    end
  end

  def get_attachment
    authorize @problem_report_attachment

    if @problem_report_attachment.link_type.present? &&
       @problem_report_attachment.link_link.present?
      file = @problem_report_attachment.get_file_contents

      if file.kind_of?(ActiveStorage::Attached::One)
       send_data(file.download,
                 filename:     file.filename.to_s,
                 contant_type: file.content_type)
      elsif file.kind_of?(String)
        send_data(file,
                  filename: File.basename(@problem_report_attachment.file_name))
      elsif file.kind_of?(URI::HTTP)
        redirect_to file.to_s, target: "_blank"

        return
      else
        respond_to do |format|
          format.html { redirect_to item_problem_report_attachments_url, error: 'No file to download.'}
          format.json { render json: @problem_report.errors,  status: :unprocessable_entity }
        end
      end
    else
      flash[:error]  = 'No file to download'

      respond_to do |format|
        format.html { redirect_to item_problem_report_attachments_url, error: 'No file to download.'}
        format.json { render json: @problem_report.errors,  status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_problem_report_attachment
      if params[:problem_report_attachment_id].present?
        @problem_report_attachment = ProblemReportAttachment.find(params[:problem_report_attachment_id])
      elsif params[:id].present?
        @problem_report_attachment = ProblemReportAttachment.find(params[:id])
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def problem_report_attachment_params
      params.require(:problem_report_attachment).permit(:link_type, :link_description, :link_link, :file, :pact_file, :problem_report_id, :user, :item_id, :project_id, :upload_date)
    end
end
