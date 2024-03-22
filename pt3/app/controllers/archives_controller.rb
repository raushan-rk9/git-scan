class ArchivesController < ApplicationController
  include Common

  before_action :set_archive_type
  before_action :set_archive, only: [:show, :edit, :update, :destroy, :view, :unarchive]
  before_action :get_project_byparam

  # GET /projects
  # GET /projects.json
  def index
    authorize :archive

    @archives  = if @project.present?
                   if @archive_type.present?
                     Archive.where(organization: current_user.organization,
                                   archive_type: @archive_type,
                                   project_id:   @project.id)
                   else
                     Archive.where(organization: current_user.organization,
                                   project_id:   @project.id)
                   end
                 else
                   if @archive_type.present?
                     Archive.where(archive_type: @archive_type,
                                   organization: current_user.organization)
                   else
                     Archive.where(organization: current_user.organization)
                   end
                 end

    if params[:filter_field].present? && params[:filter_value]
      session[:archive_filter_field] = params[:filter_field]
      session[:archive_filter_value] = params[:filter_value]
      @archives                      = @archives.delete_if do |archive|
        field                        = archive.attributes[params[:filter_field]].upitem
        value                        = params[:filter_value].upitem

        !field.index(value)
      end
    end

    @undo_path   = get_undo_path('archives', project_archives_path(@project))
    @redo_path   = get_redo_path('archives', project_archives_path(@project))
  end

  # GET /archives/1
  # GET /archives/1.json
  def show
    authorize @archive

    @undo_path = get_undo_path('archives', project_archives_path(@project))
    @redo_path = get_redo_path('archives', project_archives_path(@project))
  end

  # GET /archives/new
  def new
    authorize :archive

    @archive              = Archive.new
    @archive.project_id   = @project.id if @project.present?
    @archive.pact_version = Tool::Application::VERSION
    @archive.archived_at  = DateTime.now()
    @archive.archive_type = Constants::PROJECT_ARCHIVE
    maximium_version      = if @project.present?
                              Archive.where(organization: current_user.organization,
                                            project_id:   @project.id).maximum(:version)
                            else
                              Archive.where(organization: current_user.organization).maximum(:version)
                            end

    if maximium_version =~ /^\d+$/
      @archive.version    = (maximium_version.to_i + 1).to_s
    elsif maximium_version =~ /^\d+\.\d+$/
      @archive.version    = (maximium_version.to_f.truncate(3) + 0.1).to_s
    else
      @archive.version    = Constants::INITIAL_DRAFT_REVISION
    end
  end

  # GET /archives/1/edit
  def edit
    authorize @archive

    @undo_path = get_undo_path('archives', project_archives_path(@project))
    @redo_path = get_redo_path('archives', project_archives_path(@project))
  end

  # POST /archives
  # POST /archives.json
  def create
    authorize :archive

    @undo_path            = get_undo_path('archives',
                                          project_archives_path(@project))
    @redo_path            = get_redo_path('archives',
                                          project_archives_path(@project))
    @archive              = Archive.new(archive_params)
    @archive.project_id   = @project.id                if     @project.present?
    @archive.pact_version = Tool::Application::VERSION unless @archive.pact_version.present?
    @archive.archive_type = Constants::PROJECT_ARCHIVE unless @archive.archive_type.present?
    @archive.archived_at  = DateTime.now()             unless @archive.archived_at.present?

    respond_to do |format|
      @data_change = DataChange.save_or_destroy_with_undo_session(@archive,
                                                                  'create')

      if @data_change.present?
        @archive.create_archive(@project.id)

        format.html { redirect_to [@project, @archive], notice: 'Archive was successfully created.' }
        format.json { render :show, status: :created, location: @project }
      else
        format.html { render :new }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /archives/1
  # PATCH/PUT /archives/1.json
  def update
    authorize @archive

    @undo_path                      = get_undo_path('archives', project_archives_path(@project))
    @redo_path                      = get_redo_path('archives', project_archives_path(@project))
    params[:archive][:archive_type] = Constants::PROJECT_ARCHIVE unless params[:archive][:archive_type].present?

    respond_to do |format|
      @data_change = DataChange.save_or_destroy_with_undo_session(archive_params,
                                                                  'update',
                                                                  params[:id],
                                                                  'archives')

      if @data_change.present?
        format.html { redirect_to @project, notice: 'Archive was successfully updated.' }
        format.json { render :show, status: :ok, location: @project }
      else
        format.html { render :edit }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /archives/1
  # DELETE /archives/1.json
  def destroy
    authorize @archive

    @undo_path   = get_undo_path('archives', project_archives_path(@project))
    @data_change = DataChange.save_or_destroy_with_undo_session(@archive,
                                                                'delete',
                                                                @archive.id,
                                                                'archives')

    respond_to do |format|
      format.html { redirect_to projects_url, notice: 'Archive was successfully removed.' }
      format.json { head :no_content }
    end
  end

  # GET /unarchive/1
  # GET /unarchive/1.json
  def unarchive
    authorize @archive

    result = @archive.unarchive(@archive.id)

    if result
      @archive.destroy

      respond_to do |format|
        format.html { redirect_to projects_url, notice: 'Archive was successfully unarchived.' }
        format.json { head :no_content }
      end
    else
      @archive.errors.add(:id, :blank, message: 'Cannot unarchive Archive.')

      respond_to do |format|
        format.html { render :index, error: 'Cannot unarchive Archive.' }
        format.json { render json: @archive.errors, status: :unprocessable_entity }
      end
    end
  end

  def make_archives_visible
    authorize :archive

    if session[:archives_visible]
      session[:archives_visible] = false
    else
      session[:archives_visible] = true
    end

    respond_to do |format|
      format.html do
        if params['redirect_url'].present?
          redirect_to params['redirect_url']
        else
          redirect_to projects_url
        end
      end
      format.json { head :no_content }
    end
  end

  def view
    authorize @archive

    case @archive.archive_type
      when Constants::DOCUMENT_ARCHIVE,
           Constants::HIGH_LEVEL_REQUIREMENTS_ARCHIVE,
           Constants::LOW_LEVEL_REQUIREMENTS_ARCHIVE,
           Constants::SOURCE_CODE_ARCHIVE,
           Constants::TEST_CASE_ARCHIVE,
           Constants::TEST_PROCEDURE_ARCHIVE,
           Constants::REVIEW_ARCHIVE
          @item  = Item.find_by(id:           @archive.archive_item_id,
                                organization: current_user.organization,
                                archive_id:   @archive.id) if @archive.archive_item_id.present?

          @item  = Item.find_by(id:           @archive.archive_item_id,
                                organization: current_user.organization) if @item.nil? && @archive.archive_item_id.present?

          if @item.present?
            session[:archives_visible] = @archive.id
            session[:archived_project] = @project.id
            session[:archive_type]     = @archive.archive_type

            case @archive.archive_type
              when Constants::HIGH_LEVEL_REQUIREMENTS_ARCHIVE
                redirect_to item_high_level_requirements_path(@item)
              when Constants::LOW_LEVEL_REQUIREMENTS_ARCHIVE
                redirect_to item_low_level_requirements_path(@item)
              when Constants::SOURCE_CODE_ARCHIVE
                redirect_to item_source_codes_path(@item)
              when Constants::TEST_CASE_ARCHIVE
                redirect_to item_test_cases_path(@item)
              when Constants::TEST_PROCEDURE_ARCHIVE
                redirect_to item_test_procedures_path(@item)
              when Constants::REVIEW_ARCHIVE
                if @archive.element_id.present?
                  redirect_to item_review_path(@item, @archive.element_id)
                else
                  redirect_to item_reviews_path(@item)
                end
              when Constants::DOCUMENT_ARCHIVE
                if @archive.element_id.present?
                  redirect_to item_document_path(@item, @archive.element_id)
                else
                  redirect_to item_documents_path(@item)
                end
            end

            return
          end
      else
        @project = Project.find_by(id:           @archive.archive_project_id,
                                   organization: current_user.organization,
                                   archive_id:   @archive.id) if @archive.archive_project_id.present?

        if @project.present?
          session[:archives_visible] = @archive.id
          session[:archived_project] = @project.id
          session[:archive_type]     = @archive.archive_type

          if @archive.archive_type == Constants::SYSTEM_REQUIREMENTS_ARCHIVE
            redirect_to project_system_requirements_path(@project)
          else
            redirect_to projects_path
          end

          return
        end
    end

    redirect_to :index
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_archive_type
      @archive_type = if params[:archive_type].present?
                         params[:archive_type]
                       else
                         Constants::PROJECT_ARCHIVE
                       end
      @element_id   = params[:element_id] if params[:element_id].present?
    end

    def set_archive
      if params[:id].present?
        @archive    = Archive.find(params[:id])
      elsif params[:archive_id].present?
        @archive    = Archive.find(params[:archive_id])
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def archive_params
      params.require(
                       :archive
                    )
            .permit(
                       :name,
                       :full_id,
                       :description,
                       :revision,
                       :version,
                       :project_id,
                       :pact_version,
                       :archived_at,
                       :archive_type,
                       :element_id,
                       :item_id,
                       :archive_project_id,
                       :archive_item_id,
                       archive_item_ids: []
                   )
    end
end
