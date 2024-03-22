class ProjectsController < ApplicationController
  include Common
  before_action :set_project, only: [:show, :edit, :update, :destroy]

  # GET /projects
  # GET /projects.json
  def index
    authorize :project

    if params[:clear_archives]
      session[:archives_visible] = false
      session[:archived_project] = nil
      session[:archive_type]     = nil
    end

    if session[:archives_visible]
      if session[:archives_visible].class.name == 'TrueClass'
        @projects = Project.where(organization: current_user.organization).where.not(archive_id: nil)
      else
        @projects = Project.where(organization: current_user.organization,
                                  archive_id:   session[:archives_visible])
      end
    else
      @projects   = Project.where(organization: current_user.organization,
                                  archive_id: nil)
    end

    if params[:filter_field].present? && params[:filter_value]
      session[:project_filter_field] = params[:filter_field]
      session[:project_filter_value] = params[:filter_value]
      @projects                      = @projects.to_a.delete_if do |project|
        field                        = project.attributes[params[:filter_field]].to_s.upcase
        value                        = params[:filter_value].upcase

        !field.index(value)
      end
    end

    @projects = @projects.to_a.delete_if do |project|
      if project.access.nil? || project.access == 'PUBLIC'
        false
      else
        !project.user_access?
      end
    end

    @undo_path = get_undo_path('projects', projects_path)
    @redo_path = get_redo_path('projects', projects_path)
  end

  # GET /projects/1
  # GET /projects/1.json
  def show
    authorize :project

    @undo_path = get_undo_path('projects', projects_path)
    @redo_path = get_redo_path('projects', projects_path)
  end

  # GET /projects/new
  def new
    authorize :project

    @project                                = Project.new
    @project.system_requirements_prefix     = 'SYS'
    @project.high_level_requirements_prefix = 'HLR'
    @project.low_level_requirements_prefix  = 'LLR'
    @project.model_file_prefix              = 'MF'
    @project.module_description_prefix      = 'MD'
    @project.source_code_prefix             = 'SC'
    @project.test_case_prefix               = 'TC'
    @project.test_procedure_prefix          = 'TP'
  end

  # GET /projects/1/edit
  def edit
    authorize @project

    permitted_users = @project.permitted_users
    @selected_users = []

    permitted_users.each do |id, permissions|
      @selected_users.push(permissions[:user].email)
    end if permitted_users.present?

    @undo_path = get_undo_path('projects', projects_path)
    @redo_path = get_redo_path('projects', projects_path)
  end

  # POST /projects
  # POST /projects.json
  def create
    authorize :project

    @project                                = Project.new(project_params)
    @project.system_requirements_prefix     = 'SYS' unless @project.system_requirements_prefix.present?
    @project.high_level_requirements_prefix = 'HLR' unless @project.high_level_requirements_prefix.present?
    @project.low_level_requirements_prefix  = 'LLR' unless @project.low_level_requirements_prefix.present?
    @project.model_file_prefix              = 'MF'  unless @project.model_file_prefix.present?
    @project.source_code_prefix             = 'SC'  unless @project.source_code_prefix.present?
    @project.test_case_prefix               = 'TC'  unless @project.test_case_prefix.present?
    @project.test_procedure_prefix          = 'TP'  unless @project.test_procedure_prefix.present?

    respond_to do |format|
      @data_change = DataChange.save_or_destroy_with_undo_session(@project, 'create')

      if @data_change.present?
        if @project.access == 'PROTECTED'
          @project.add_permitted_users(project_params[:users],
                                       @data_change.session_id)
        elsif @project.access == 'PRIVATE'
          @project.add_permitted_users([ User.current.id ],
                                       @data_change.session_id)
        end

        format.html { redirect_to @project, notice: 'Project was successfully created.' }
        format.json { render :show, status: :created, location: @project }
      else
        format.html { render :new }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /projects/1
  # PATCH/PUT /projects/1.json
  def update
    authorize @project

    old_system_requirements_prefix = @project.system_requirements_prefix
    new_system_requirements_prefix = project_params[:system_requirements_prefix]

    respond_to do |format|
      @data_change = DataChange.save_or_destroy_with_undo_session(project_params,
                                                                  'update',
                                                                  params[:id],
                                                                  'projects')

      if @data_change.present?
        session_id = @data_change.session_id

        if old_system_requirements_prefix != new_system_requirements_prefix
          SystemRequirement.rename_prefix(@project.id,
                                          old_system_requirements_prefix,
                                          new_system_requirements_prefix,
                                          session_id)
        end

        if project_params[:access] == 'PROTECTED'
          @project.update_permitted_users(project_params[:users],
                                          @data_change.session_id)
        elsif project_params[:access] == 'PRIVATE'
          @project.remove_permitted_users(@data_change.session_id)
          @project.add_permitted_users([ User.current.id ],
                                       @data_change.session_id)
        else
          @project.remove_permitted_users(@data_change.session_id)
        end

        format.html { redirect_to @project, notice: 'Project was successfully updated.' }
        format.json { render :show, status: :ok, location: @project }
      else
        format.html { render :edit }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /projects/1
  # DELETE /projects/1.json
  def destroy
    authorize @project

    @data_change = DataChange.save_or_destroy_with_undo_session(@project,
                                                                'delete',
                                                                @project.id,
                                                                'projects')

    respond_to do |format|
      format.html { redirect_to projects_url, notice: 'Project was successfully removed.' }
      format.json { head :no_content }
    end
  end

  def review_status
    authorize :project
    @project = Project.find(params[:project_id])
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_project
      @project = Project.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def project_params
      params.require(
                       :project
                    ).
             permit(
                       :identifier,
                       :name,
                       :access,
                       :system_requirements_prefix,
                       :high_level_requirements_prefix,
                       :low_level_requirements_prefix,
                       :model_file_prefix,
                       :source_code_prefix,
                       :test_case_prefix,
                       :test_procedure_prefix,
                       users:                  [],
                       project_managers:       [],
                       configuration_managers: [],
                       quality_assurance:      [],
                       team_members:           [],
                       airworthiness_reps:     []
                   )
    end
end
