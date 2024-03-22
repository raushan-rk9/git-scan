class SystemRequirementsController < ApplicationController
  include Common

  respond_to    :docx

  before_action :set_system_requirement, only: [:show, :edit, :update, :destroy, :mark_as_deleted]
  before_action :get_project
  before_action :get_projects, only: [:new, :edit, :update]
  before_action :set_session

  # GET /system_requirements
  # GET /system_requirements.json
  def index
    authorize :system_requirement
    # Get all system requirements
    if session[:archives_visible]
      @system_requirements = SystemRequirement.where(project_id:   params[:project_id],
                                                     organization: current_user.organization)
    else
      @system_requirements = SystemRequirement.where(project_id:   params[:project_id],
                                                     organization: current_user.organization,
                                                     archive_id:  nil)
    end

    if params[:filter_field].present? && params[:filter_value]
      session[:sr_filter_field] = params[:filter_field]
      session[:sr_filter_value] = params[:filter_value]
      @system_requirements      = @system_requirements.to_a.delete_if do |system_requirement|
        field                   = system_requirement.attributes[params[:filter_field]].to_s.upcase
        value                   = params[:filter_value].upcase

        !field.index(value)
      end
    end

    @system_requirements   = sort_on_full_id(@system_requirements)
    @undo_path             = get_undo_path('system_requirements',
                                           project_system_requirements_path(@project))
    @redo_path             = get_redo_path('system_requirements',
                                           project_system_requirements_path(@project))
  end

  # GET /system_requirements/1
  # GET /system_requirements/1.json
  def show
    authorize :system_requirement
    # Get the project for this system requirement.
    @project             = Project.find_by(id: @system_requirement.project_id)
    @undo_path           = get_undo_path('system_requirements',
                                         project_system_requirements_path(@project))
    @redo_path           = get_redo_path('system_requirements',
                                         project_system_requirements_path(@project))

    if session[:archives_visible]
      @system_requirement_ids = SystemRequirement.where(project_id:   @project.id,
                                                        organization: current_user.organization).order(:full_id).pluck(:id)
    else
      @system_requirement_ids = SystemRequirement.where(project_id:   @project.id,
                                                        organization: current_user.organization,
                                                        archive_id:  nil).order(:full_id).pluck(:id)
    end
  end

  # GET /projects/:project_id/system_requirements/new
  def new
    authorize :system_requirement

    @system_requirement            = SystemRequirement.new
    @system_requirement.project_id = params[:project_id]
    maximium_reqid                 = SystemRequirement.where(project_id: @system_requirement.project_id).maximum(:reqid)
    @system_requirement.reqid      = maximium_reqid.present? ? maximium_reqid + 1 : 1
    @pact_files                    = get_model_file_list(@system_requirement.project_id)

    # Initial version counter value is 1.
    @system_requirement.version = increment_int(@system_requirement.version)
  end

  # GET /system_requirements/1/edit
  def edit
    authorize @system_requirement
    # Increment the version counter if edited.
    @system_requirement.version = increment_int(@system_requirement.version)
    @undo_path                  = get_undo_path('system_requirements',
                                                project_system_requirements_path(@project))
    @redo_path                  = get_redo_path('system_requirements',
                                                project_system_requirements_path(@project))
    @pact_files                 = get_model_file_list(@system_requirement.project_id)

    if session[:archives_visible]
      @system_requirement_ids = SystemRequirement.where(project_id:   @project.id,
                                                        organization: current_user.organization).order(:full_id).pluck(:id)
    else
      @system_requirement_ids = SystemRequirement.where(project_id:   @project.id,
                                                        organization: current_user.organization,
                                                        archive_id:  nil).order(:full_id).pluck(:id)
    end
  end

  # POST /system_requirements

  # POST /system_requirements.json
  def create
    authorize :system_requirement

    session_id                               = nil
    params[:system_requirement][:project_id] = @project.id if !system_requirement_params[:project_id].present? && @project.present?
    @projects                                = Project.where(organization: current_user.organization)
    @system_requirement                      = SystemRequirement.new(system_requirement_params)
    @system_requirement.model_file_id        = nil if @system_requirement.model_file_id.to_s == "-1"

    respond_to do |format|
      # Check to see if the Requirement ID already Exists.
      if SystemRequirement.find_by(reqid: @system_requirement.reqid,
                                   project_id: @system_requirement.project_id)
        @system_requirement.errors.add(:reqid, :blank, message: "Duplicate ID: #{@system_requirement.reqid}") 
        format.html { render :new }
        format.json { render json: @system_requirement.errors, status: :unprocessable_entity }
      elsif SystemRequirement.find_by(full_id: @system_requirement.full_id,
                                      project_id: @system_requirement.project_id)
        @system_requirement.errors.add(:full_id, :blank, message: "Duplicate ID: #{@system_requirement.full_id}") 

        format.html { render :new }
        format.json { render json: @system_requirement.errors, status: :unprocessable_entity }
      else
        @data_change                         = DataChange.save_or_destroy_with_undo_session(@system_requirement,
                                                                                            'create',
                                                                                            nil,
                                                                                            'system_requirements',
                                                                                            session_id)

        @system_requirement.add_model_document(system_requirement_params[:upload_file],
                                               system_requirement_params[:item_id],
                                               @data_change.session_id) if system_requirement_params[:upload_file].present? && @data_change.present?

        if @data_change.present?
          format.html { redirect_to [@project, @system_requirement], notice: 'System requirement was successfully created.' }
          format.json { render :show, status: :created, location: [@project, @system_requirement] }
        else
          format.html { render :new }
          format.json { render json: @system_requirement.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # PATCH/PUT /system_requirements/1
  # PATCH/PUT /system_requirements/1.json
  def update
    authorize @system_requirement

    session_id                                  = nil
    params[:system_requirement][:project_id]    = @project.id if !system_requirement_params[:project_id].present? && @project.present?
    params[:system_requirement][:model_file_id] = nil         if  system_requirement_params[:model_file_id].to_s == "-1"

    respond_to do |format|
      new_id                                 = params[:system_requirement][:reqid].to_i

      if (new_id != @system_requirement.reqid) &&
         SystemRequirement.find_by(reqid: new_id,
                                   project_id: @system_requirement.project_id)
        @system_requirement.errors.add(:reqid, :blank, message: "Duplicate ID: #{@system_requirement.reqid}") 

        format.html { render :new }
        format.json { render json: @system_requirement.errors, status: :unprocessable_entity }
      else
        @data_change                         = DataChange.save_or_destroy_with_undo_session(system_requirement_params,
                                                                                            'update',
                                                                                            params[:id],
                                                                                            'system_requirements',
                                                                                            session_id)

        if @data_change.present?
          @system_requirement.add_model_document(system_requirement_params[:upload_file],
                                                 system_requirement_params[:item_id],
                                                 @data_change.session_id) if system_requirement_params[:upload_file].present?

          format.html { redirect_to project_system_requirement_path(@project.id, @system_requirement.id, previous_mode: 'editing'), notice: 'System requirement was successfully updated.' }
          format.json { render :show, status: :ok, location: @system_requirement }
        else
          format.html { render :edit }
          format.json { render json: @system_requirement.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /system_requirements/1
  # DELETE /system_requirements/1.json
  def destroy
    authorize @system_requirement
    @data_change = DataChange.save_or_destroy_with_undo_session(@system_requirement, 'delete')

    if @data_change.present?
      respond_to do |format|
        format.html { redirect_to project_system_requirements_url, notice: 'System requirement was successfully removed.' }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html { render :edit, error: 'Could not delete System Requirement'}
        format.json { render json: @system_requirement.errors, status: :unprocessable_entity }
      end
    end
  end

  def export
    authorize :system_requirement

    # Get all system requirements
    if session[:archives_visible].kind_of?(Integer)
      @system_requirements = SystemRequirement.where(project_id:   params[:project_id],
                                                     organization: current_user.organization,
                                                     archive_id:   session[:archives_visible])
    else
      @system_requirements = SystemRequirement.where(project_id:   params[:project_id],
                                                     organization: current_user.organization,
                                                     archive_id:  nil)
    end

    @system_requirements = sort_on_full_id(@system_requirements)

    respond_to do |format|
      if params[:sysreq_export].try(:has_key?, :export_type) && params[:sysreq_export][:export_type] == 'HTML'
        format.html { render "system_requirements/export_html", layout: false }
        format.json { render :show, status: :ok, location: @system_requirement }
      elsif params[:sysreq_export].try(:has_key?, :export_type) && params[:sysreq_export][:export_type] == 'PDF'
        format.html { redirect_to project_system_requirements_export_path(format: :pdf) }
      elsif params[:sysreq_export].try(:has_key?, :export_type) && params[:sysreq_export][:export_type] == 'CSV'
        # Come back here using the csv format to generate the csv below.
        format.html { redirect_to project_system_requirements_export_path(format: :csv) }
      elsif params[:sysreq_export].try(:has_key?, :export_type) && params[:sysreq_export][:export_type] == 'XLS'
        # Come back here using the xls format to generate the xls below.
        format.html { redirect_to project_system_requirements_export_path(format: :xls) }
      elsif params[:sysreq_export].try(:has_key?, :export_type) && params[:sysreq_export][:export_type] == 'DOCX'
        # Come back here using the docx format to generate the docx below.
        if convert_data("System_Requirements.docx",
                        'system_requirements/export_html.html.erb',
                         @item.present? ? @item.id : params[:item_id])
          format.html { redirect_to  project_system_requirements_export_path(@project.id, filename: @converted_filename, format: :docx, starting_number: params[:md_export].try(:has_key?, :starting_number) ) }
        else
          flash[:error]  = @conversion_error
          params[:level] = 2

          go_back
        end
      else
        format.html { render :export }
        format.json { render json: @system_requirement.errors, status: :unprocessable_entity }
        # If redirected using format => csv, generate the csv here.
        format.csv  { send_data SystemRequirement.to_csv(@project.id), filename: "#{@project.name}-System_Requirements.csv" }
        format.xls  { send_data SystemRequirement.to_xls(@project.id), filename: "#{@project.name}-System_Requirements.xls" }
        format.pdf  {
                       @no_links = true

                       render(pdf:      "#{@project.name}-System_Requirements",
                              template: 'system_requirements/export_html.html.erb',
                              title:    'System Requirements: Export PDF | PACT',
                              footer:   {
                                          right: '[page] of [topage]'
                                        })
                    }
        format.docx {
                       return_file(params[:filename])
                    }
      end
    end
  end

  def import_system_requirements
    import              = params[import_path]

    return false unless import.present?

    check_download      = []
    filename            = nil
    error               = false
    id                  = import['project_select'].to_i if import['project_select'] =~ /^\d+$/
    file                = import['file']

    check_download.push(:check_duplicates)               if params[import_path]['duplicates_permitted'] != '1'

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

    if !error && !check_download.empty?
      result = SystemRequirement.from_file(filename, @project, check_download)

      if result == :duplicate_system_requirement
        if @project.errors.messages.empty?
          flash[:alert] = "File: #{file.original_filename} contains existing System Requirements. Choose Duplicates Permitted to import duplicates."
        end

        error           = true
      end
    end

    if !error
      unless SystemRequirement.from_file(filename, @project)
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
    authorize :system_requirement

    if params[import_path].present?
      if import_system_requirements
        respond_to do |format|
          format.html {redirect_to project_system_requirements_path(@project), notice: 'System requirements were successfully imported.' }
          format.json { head :no_content }
        end
      else
        respond_to do |format|
          format.html { redirect_to project_system_requirements_import_path(@project) }
          format.json { render json: @project.errors, status: :unprocessable_entity }
        end
      end
    else
      respond_to do |format|
        format.html { render :import }
        format.json { render json: @system_requirement.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /system_requirements/renumber
  def renumber
    authorize :system_requirement

    if params[:sysreq_renumber].try(:has_key?, :start)     &&
       params[:sysreq_renumber][:start]     =~/^\d+$/      &&
       params[:sysreq_renumber].try(:has_key?, :increment) &&
       params[:sysreq_renumber][:increment] =~/^\d+$/      &&
       params[:sysreq_renumber][:leading_zeros] =~/^\d+$/
      SystemRequirement.renumber(@project.id,
                                 params[:sysreq_renumber][:start].to_i,
                                 params[:sysreq_renumber][:increment].to_i,
                                 @project.system_requirements_prefix,
                                 params[:sysreq_renumber][:leading_zeros].to_i)

      respond_to do |format|
        format.html {redirect_to project_system_requirements_path(@project), notice: 'System requirements were successfully renumbered.' }
        format.json { head :no_content }
      end
    end
  end

  # GET /system_requirements/1/mark_as_deleted/
  # GET /system_requirements/1/mark_as_deleted.json
  def mark_as_deleted
    authorize @system_requirement

    @system_requirement.soft_delete = true
    @data_change                    = DataChange.save_or_destroy_with_undo_session(@system_requirement,
                                                                                   'update',
                                                                                   @system_requirement.id,
                                                                                   'system_requirements')

    if @data_change.present?
      respond_to do |format|
        format.html { redirect_to project_system_requirements_url, notice: 'System requirement was successfully marked as deleted.' }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html { render :edit, error: 'Could not delete System Requirement'}
        format.json { render json: @system_requirement.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_system_requirement
      if params[:id].present?
        @system_requirement = SystemRequirement.find(params[:id])
      elsif params[:system_requirement_id]
        @system_requirement = SystemRequirement.find(params[:system_requirement_id])
      end
    end

    # Get the project for the parameter provided id.
    def get_project
      @project = Project.find_by(id: params[:project_id])

      set_current_project(@project)
    end

    # Delete image
    def delete_image
      @system_requirement.image.purge
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def system_requirement_params
      params.require(
                       :system_requirement)
            .permit(
                       :reqid,
                       :full_id,
                       :description,
                       :category,
                       :source,
                       :safety,
                       :implementation,
                       :image,
                       :remove_image,
                       :version,
                       :project_id,
                       :derived,
                       :derived_justification,
                       :item_id,
                       :document_id,
                       :model_file_id,
                       :upload_file,
                       verification_method: [])
    end
end
