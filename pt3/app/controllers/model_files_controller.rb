class ModelFilesController < ApplicationController
  include Common

  respond_to         :docx

  before_action      :set_model_file, only: [:show, :edit, :update, :destroy, :mark_as_deleted, :download_file, :display_file]
  before_action      :get_item
  before_action      :get_items, only: [:new, :edit, :update]
  before_action      :get_project_fromitemid
  before_action      :get_projects, only: [:new, :edit, :update]
  before_action      :set_session
  before_action      :setup_parameters, only: [:create, :update]
  before_action      :setup_project

  skip_before_action :verify_authenticity_token, only: [:update, :generate]

  HTML_ESCAPE	=	{ "&" => "&amp;", ">" => "&gt;", "<" => "&lt;", '"' => "&quot;", "'" => "&#39;" }
  HTML_ESCAPE_ONCE_REGEXP	=	/["><']|&(?!([a-zA-Z]+|(#\d+)|(#[xX][\dA-Fa-f]+));)/

  # GET /model_files
  # GET /model_files.json
  def index
    authorize :model_file

    if @item.present?
      if session[:archives_visible]
        @model_files = ModelFile.where(item_id:      params[:item_id],
                                       organization: current_user.organization)
      else
        @model_files = ModelFile.where(item_id:      params[:item_id],
                                       organization: current_user.organization,
                                       archive_id:  nil)
      end
    else
      if session[:archives_visible]
        @model_files = ModelFile.where(project_id:   params[:project_id],
                                       organization: current_user.organization)
      else
        @model_files = ModelFile.where(project_id:   params[:project_id],
                                       organization: current_user.organization,
                                       archive_id:  nil)
      end
    end

    if params[:filter_field].present? && params[:filter_value]
      session[:mf_filter_field] = params[:filter_field]
      session[:mf_filter_value] = params[:filter_value]
      @model_files              = @model_files.to_a.delete_if do |model_file|
        field                   = model_file.attributes[params[:filter_field]].to_s.upcase
        value                   = params[:filter_value].upcase

        !field.index(value)
      end
    end

    @model_files                = sort_on_full_id(@model_files)

    if @item.present?
      @undo_path                  = get_undo_path('model_files',
                                                  item_model_files_path(@item))
      @redo_path                  = get_redo_path('model_files',
                                                  item_model_files_path(@item))
    else
      @undo_path                  = get_undo_path('model_files',
                                                  project_model_files_path(@project))
      @redo_path                  = get_redo_path('model_files',
                                                  project_model_files_path(@project))
    end
  end

  # GET /model_files/1
  # GET /model_files/1.json
  def show
    authorize :model_file

    # Get the item.
    @item             = Item.find_by(id: @model_file.item_id) if @model_file.item_id.present?

    if @item.present?
      @undo_path                  = get_undo_path('model_files',
                                                  item_model_files_path(@item))
      @redo_path                  = get_redo_path('model_files',
                                                  item_model_files_path(@item))
    else
      @undo_path                  = get_undo_path('model_files',
                                                  project_model_files_path(@project))
      @redo_path                  = get_redo_path('model_files',
                                                  project_model_files_path(@project))
    end

    if @item.present?
      if session[:archives_visible]
        @model_file_ids = ModelFile.where(item_id:      @item.id,
                                          organization: current_user.organization).order(:full_id).pluck(:id)
      else
        @model_file_ids = ModelFile.where(item_id:      @item.id,
                                          organization: current_user.organization,
                                          archive_id:  nil).order(:full_id).pluck(:id)
      end
    else
      if session[:archives_visible]
        @model_file_ids = ModelFile.where(project_id:   @project.id,
                                          organization: current_user.organization).order(:full_id).pluck(:id)
      else
        @model_file_ids = ModelFile.where(project_id:   @project.id,
                                          organization: current_user.organization,
                                          archive_id:  nil).order(:full_id).pluck(:id)
      end
    end
  end

  # GET /model_files/new
  def new
    authorize :model_file

    @pact_files               = get_pact_files
    @model_file               = ModelFile.new
    @model_file.item_id       = @item.try(:id)
    @model_file.project_id    = @project.try(:id)
    @model_file.draft_version = Constants::INITIAL_DRAFT_REVISION

    if @item.present?
      maximium_model_id       = ModelFile.where(item_id: @item.id).maximum(:model_id)
    else
      maximium_model_id       = ModelFile.where(project_id: @project.id).maximum(:model_id)
    end

    @model_file.model_id      = maximium_model_id.present? ? maximium_model_id + 1 : 1

    # Initial version counter value is 1.
    @model_file.version       = increment_int(@model_file.version)

    if @item.present?
      @undo_path                  = get_undo_path('model_files',
                                                  item_model_files_path(@item))
      @redo_path                  = get_redo_path('model_files',
                                                  item_model_files_path(@item))
    else
      @undo_path                  = get_undo_path('model_files',
                                                  project_model_files_path(@project))
      @redo_path                  = get_redo_path('model_files',
                                                  project_model_files_path(@project))
    end

    @system_requirements          = sort_on_full_id(SystemRequirement.where(project_id: @project.id).order(:full_id))

    if @item.present?
      @high_level_requirements    = sort_on_full_id(HighLevelRequirement.where(item_id: @item.id).order(:full_id))
      @low_level_requirements     = sort_on_full_id(LowLevelRequirement.where(item_id: @item.id).order(:full_id))
      @test_cases                 = sort_on_full_id(TestCase.where(item_id: @item.id).order(:full_id))
    else
      @high_level_requirements    = sort_on_full_id(HighLevelRequirement.where(project_id: @project.id).order(:full_id))
      @low_level_requirements     = sort_on_full_id(LowLevelRequirement.where(project_id: @project.id).order(:full_id))
      @test_cases                 = sort_on_full_id(TestCase.where(project_id: @project.id).order(:full_id))
    end
  end

  # GET /model_files/1/edit
  def edit
    authorize :model_file

    @pact_files                     = get_pact_files

    # Increment the version counter if edited.
    @model_file.version             = increment_int(@model_file.version)

    if @item.present?
      @undo_path                  = get_undo_path('model_files',
                                                  item_model_files_path(@item))
      @redo_path                  = get_redo_path('model_files',
                                                  item_model_files_path(@item))
    else
      @undo_path                  = get_undo_path('model_files',
                                                  project_model_files_path(@project))
      @redo_path                  = get_redo_path('model_files',
                                                  project_model_files_path(@project))
    end

    @system_requirements            = sort_on_full_id(SystemRequirement.where(project_id: @project.id).order(:full_id))

    if @item.present?
      @high_level_requirements      = sort_on_full_id(HighLevelRequirement.where(item_id: @item.id).order(:full_id))
      @low_level_requirements       = sort_on_full_id(LowLevelRequirement.where(item_id: @item.id).order(:full_id))
      @test_cases                   = sort_on_full_id(TestCase.where(item_id: @item.id).order(:full_id))
    else
      @high_level_requirements      = sort_on_full_id(HighLevelRequirement.where(project_id: @project.id).order(:full_id))
      @low_level_requirements       = sort_on_full_id(LowLevelRequirement.where(project_id: @project.id).order(:full_id))
      @test_cases                   = sort_on_full_id(TestCase.where(project_id: @project.id).order(:full_id))
    end

    system_requirement_associations = if @model_file.system_requirement_associations.present?
                                        if @model_file.system_requirement_associations.kind_of?(String)
                                          @model_file.system_requirement_associations.split(',')
                                        else
                                          @model_file.system_requirement_associations.reject { |x| x.empty? }
                                        end
                                      else
                                         []
                                      end
    high_level_associations         = if @model_file.high_level_requirement_associations.present?
                                        if @model_file.high_level_requirement_associations.kind_of?(String)
                                          @model_file.high_level_requirement_associations.split(',')
                                        else
                                          @model_file.high_level_requirement_associations.reject { |x| x.empty? }
                                        end
                                      else
                                         []
                                      end
    low_level_associations          = if @model_file.low_level_requirement_associations.present?
                                        if @model_file.low_level_requirement_associations.kind_of?(String)
                                          @model_file.low_level_requirement_associations.split(',')
                                        else
                                          @model_file.low_level_requirement_associations.reject { |x| x.empty? }
                                        end
                                      else
                                         []
                                      end
    test_case_associations          = if @model_file.test_case_associations.present?
                                        if @model_file.test_case_associations.kind_of?(String)
                                          @model_file.test_case_associations.split(',')
                                        else
                                          @model_file.test_case_associations.reject { |x| x.empty? }
                                        end
                                      else
                                         []
                                      end

    @system_requirements.each     { |sysreq| sysreq.selected = system_requirement_associations.include?(sysreq.id.to_s) } if @system_requirements.present?
    @high_level_requirements.each { |hlr|    hlr.selected    = high_level_associations.include?(hlr.id.to_s) }            if @high_level_requirements.present?
    @low_level_requirements.each  { |llr|    llr.selected    = low_level_associations.include?(llr.id.to_s) }             if @low_level_requirements.present?
    @test_cases.each              { |tc|     tc.selected     = test_case_associations.include?(tc.id.to_s) }              if @test_cases.present?

    if @item.present?
      if session[:archives_visible]
        @model_file_ids             = ModelFile.where(item_id:      @item.id,
                                                      organization: current_user.organization).order(:full_id).pluck(:id)
      else
        @model_file_ids             = ModelFile.where(item_id:      @item.id,
                                                      organization: current_user.organization,
                                                      archive_id:  nil).order(:full_id).pluck(:id)
      end
    else
      if session[:archives_visible]
        @model_file_ids             = ModelFile.where(project_id:   @project.id,
                                                      organization: current_user.organization).order(:full_id).pluck(:id)
      else
        @model_file_ids             = ModelFile.where(project_id:   @project.id,
                                                      organization: current_user.organization,
                                                      archive_id:  nil).order(:full_id).pluck(:id)
      end
    end
  end

  # POST /model_files
  # POST /model_files.json
  def create
    authorize :model_file

    @model_file                = ModelFile.new(model_file_params)

    respond_to do |format|
      # Check to see if the File ID already Exists.
      if ModelFile.find_by(model_id:  @model_file.model_id,
                           item_id: @model_file.item_id)
        @model_file.errors.add(:model_id, :blank, message: "Duplicate ID: #{@model_file.model_id}") 

        format.html { render :new }
        format.json { render json: @model_file.errors, status: :unprocessable_entity }
      elsif ModelFile.find_by(full_id:  @model_file.full_id,
                              item_id: @model_file.item_id)
        @model_file.errors.add(:full_id, :blank, message: "Duplicate ID: #{@model_file.full_id}") 

        format.html { render :new }
        format.json { render json: @model_file.errors, status: :unprocessable_entity }
      else
        @model_file.project_id = @project.id if !@model_file.project_id.present? && @project.present?
        @data_change           = DataChange.save_or_destroy_with_undo_session(@model_file,
                                                                              'create',
                                                                              @model_file.id,
                                                                              'model_files')

        Associations.build_associations(@model_file) if @data_change.present?

        if @data_change.present? && model_file_params['upload_file'].present?
          @model_file.store_file(model_file_params['upload_file'])

          @data_change         = DataChange.save_or_destroy_with_undo_session(@model_file,
                                                                              'update',
                                                                              @model_file.id,
                                                                              'model_files',
                                                                              @data_change.session_id)
        end

        if @data_change.present?
          if @item.present?
            format.html { redirect_to [@item, @model_file], notice: 'Model file was successfully created.' }
            format.json { render :show, status: :created, location: [@item, @model_file] }
          else
            format.html { redirect_to [@project, @model_file], notice: 'Model file was successfully created.' }
            format.json { render :show, status: :created, location: [@project, @model_file] }
          end
        else
          format.html { render :new }
          format.json { render json: @model_file.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # PATCH/PUT /model_files/1
  # PATCH/PUT /model_files/1.json
  def update
    authorize @model_file

    session_id              = nil

    if @model_file.present?
      unless @model_file.model_id.present?
        pg_results          = ActiveRecord::Base.connection.execute("SELECT nextval('model_files_model_id_seq')")

        pg_results.each { |row| @model_file.model_id = row["nextval"] } if pg_results.present?
      end

      archive               = Archive.new()
      title                 = "Update of #{I18n.t('misc.model_file')} ID: #{@model_file.full_id}, Version #{@model_file.version}."
      archive.name,         = title
      archive.full_id,      = title
      archive.description   = title
      archive.revision      = "1"
      archive.version       = "1"
      archive.archive_type  = Constants::MODEL_ARCHIVE
      archive.archived_at   = DateTime.now()
      archive.organization  = current_user.organization
      @data_change          = DataChange.save_or_destroy_with_undo_session(archive,
                                                                           'create',
                                                                           nil,
                                                                           'archives',
                                                                           session_id)
      session_id            = @data_change.session_id if @data_change.present?

      archive.clone_model_file(@model_file, @project.id, @item.try(:id),
                               session_id)
    end

    respond_to do |format|
      # Check to see if the File ID already Exists.
      new_id = model_file_params[:model_id].to_i

      if (new_id != @model_file.model_id) &&
         ModelFile.find_by(model_id: new_id,
                           item_id:  @model_file.item_id)
        @model_file.errors.add(:model_id, :blank, message: "Duplicate ID: #{@model_file.model_id}") 

        format.html { render :new }
        format.json { render json: @model_file.errors, status: :unprocessable_entity }
      else
        @data_change        = DataChange.save_or_destroy_with_undo_session(params['model_file'],
                                                                           'update',
                                                                           params[:id],
                                                                           'model_files')

        Associations.build_associations(@model_file) if @data_change.present?
      end

      if @data_change.present? && model_file_params['upload_file'].present?
        @model_file.store_file(model_file_params['upload_file'])

        @data_change        = DataChange.save_or_destroy_with_undo_session(@model_file,
                                                                           'update',
                                                                           @model_file.id,
                                                                           'model_files',
                                                                           @data_change.session_id)
      end

      if @data_change.present?
        if @item.present?
          format.html { redirect_to item_model_file_path(@item.id, @model_file.id, previous_mode: 'editing'), notice: "#{I18n.t('misc.model_file')} was successfully updated." }
          format.json { render :show, status: :ok, location: [@item, @model_file] }
        else
          format.html { redirect_to project_model_file_path(@project.id, @model_file.id, previous_mode: 'editing'), notice: "#{I18n.t('misc.model_file')} was successfully updated." }
          format.json { render :show, status: :ok, location: [@project, @model_file] }
        end
      else
        format.html { render :edit }
        format.json { render json: @model_file.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /model_files/1
  # DELETE /model_files/1.json
  def destroy
    authorize @model_file

    @data_change = DataChange.save_or_destroy_with_undo_session(@model_file,
                                                                'delete',
                                                                @model_file.id,
                                                                'model_files')

    respond_to do |format|
      if @item.present?
        format.html { redirect_to item_model_files_url, notice: "#{I18n.t('misc.model_file')}  was successfully removed." }
        format.json { head :no_content }
      else
        format.html { redirect_to project_model_files_url, notice: "#{I18n.t('misc.model_file')}  was successfully removed." }
        format.json { head :no_content }
      end
    end
  end

  def export
    authorize :model_file

    # Get all Model File requirements
    @model_files = if session[:archives_visible].kind_of?(Integer)
                     ModelFile.where(item_id:      params[:item_id],
                                     organization: current_user.organization,
                                     archive_id:   session[:archives_visible])
                   else
                     ModelFile.where(item_id:      params[:item_id],
                                     organization: current_user.organization,
                                     archive_id:   nil)
    end

    @model_files = sort_on_full_id(@model_files)

    respond_to do |format|
      if params[:mf_export].try(:has_key?, :export_type)    &&
        (params[:mf_export][:export_type] == 'HTML')
        format.html { render "model_files/export_html", layout: false }
        format.json { render :show, status: :ok, location: @model_file }
      elsif params[:mf_export].try(:has_key?, :export_type) &&
           (params[:mf_export][:export_type] == 'PDF')
        if @item.present?
          format.html { redirect_to item_model_files_export_path(format: :pdf) }
        else
          format.html { redirect_to project_model_files_export_path(format: :pdf) }
        end
      elsif params[:mf_export].try(:has_key?, :export_type) &&
           (params[:mf_export][:export_type] == 'CSV')
        # Come back here using the csv format to generate the csv below.
        if @item.present?
          format.html { redirect_to item_model_files_export_path(format: :csv) }
        else
          format.html { redirect_to project_model_files_export_path(format: :csv) }
        end
      elsif params[:mf_export].try(:has_key?, :export_type) &&
           (params[:mf_export][:export_type] == 'XLS')
        # Come back here using the xls format to generate the xls below.
        if @item.present?
          format.html { redirect_to item_model_files_export_path(format: :xls) }
        else
          format.html { redirect_to project_model_files_export_path(format: :xls) }
        end
      elsif params[:mf_export].try(:has_key?, :export_type) &&
           (params[:mf_export][:export_type] == 'DOCX')
        # Come back here using the docx format to generate the docx below.
        if @item.present?
          format.html { redirect_to item_model_files_export_path(@item, format: :docx) }
        else
          format.html { redirect_to project_model_files_export_path(@project, format: :docx) }
        end
      else
        if @item.present?
          format.html { render :export }
          format.json { render json: @model_file.errors, status: :unprocessable_entity }
          # If redirected using format => csv, generate the csv here.
          format.csv  { send_data ModelFile.to_csv(@project.id, @item.id), filename: "#{@item.name}-Model_Files.csv" }
          format.xls  { send_data ModelFile.to_xls(@project.id, @item.id), filename: "#{@item.name}-Model_Files.xls" }
          format.pdf  {
                         @no_links = true
  
                         render(pdf:         "#{@project.name}-ModelFiles",
                                template:    'model_files/export_html.html.erb',
                                title:       'Model Files: Export PDF | PACT',
                                footer:      {
                                                right: '[page] of [topage]'
                                             },
                                orientation: 'Landscape')
                      }
        format.docx   {
                        if convert_data("Model_Files.docx",
                                        'model_files/export_html.html.erb',
                                         @item.present? ? @item.id : params[:item_id])
                          return_file(@converted_filename)
                        else
                          flash[:error]  = @conversion_error
                          params[:level] = 2
                
                          go_back
                        end
                      }
        else
          format.html { render :export }
          format.json { render json: @model_file.errors, status: :unprocessable_entity }
          # If redirected using format => csv, generate the csv here.
          format.csv  { send_data ModelFile.to_csv(@project.id, nil), filename: "#{@project.name}-Model_Files.csv" }
          format.xls  { send_data ModelFile.to_xls(@project.id, nil), filename: "#{@project.name}-Model_Files.xls" }
          format.pdf  {
                         @no_links = true
  
                         render(pdf:         "#{@project.name}-ModelFiles",
                                template:    'model_files/export_html.html.erb',
                                title:       'Model Files: Export PDF | PACT',
                                footer:      {
                                                right: '[page] of [topage]'
                                             },
                                orientation: 'Landscape')
                      }
        format.docx   {
                        if convert_data("Model_Files.docx",
                                        'model_files/export_html.html.erb',
                                         @item.present? ? @item.id : params[:item_id])
                          return_file(@converted_filename)
                        else
                          flash[:error]  = @conversion_error
                          params[:level] = 2
                
                          go_back
                        end
                      }
        end
      end
    end
  end

  def import
    authorize :model_file

    if params[import_path].present?
      if import_model_files
        respond_to do |format|
          if @item.present?
            format.html {redirect_to item_model_files_path(@item), notice: "#{I18n.t('misc.model_files')} successfully imported." }
            format.json { head :no_content }
          else
            format.html {redirect_to project_model_files_path(@project), notice: "#{I18n.t('misc.model_files')} successfully imported." }
            format.json { head :no_content }
          end
        end
      else
        respond_to do |format|
          if @item.present?
            format.html { redirect_to item_model_files_import_path(@item) }
            format.json { render json: @item.errors, status: :unprocessable_entity }
          else
            format.html { redirect_to project_model_files_import_path(@project) }
            format.json { render json: @item.errors, status: :unprocessable_entity }
          end
        end
      end
    else
      respond_to do |format|
        format.html { render :import }
        format.json { render json: @model_file.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /model_files/renumber
  def renumber
    authorize :model_file

    if params[:mf_renumber].try(:has_key?, :start)     &&
       params[:mf_renumber][:start]     =~/^\d+$/      &&
       params[:mf_renumber].try(:has_key?, :increment) &&
       params[:mf_renumber][:increment] =~/^\d+$/      &&
       params[:mf_renumber][:leading_zeros] =~/^\d+$/
      if @item.present?
        ModelFile.renumber(:item,
                           @item.id,
                           params[:mf_renumber][:start].to_i,
                           params[:mf_renumber][:increment].to_i,
                           @item.model_file_prefix.present? ? @item.model_file_prefix : 'MF-',
                           params[:mf_renumber][:leading_zeros].to_i)
      else
        ModelFile.renumber(:project,
                           @project.id,
                           params[:mf_renumber][:start].to_i,
                           params[:mf_renumber][:increment].to_i,
                           @project.model_file_prefix.present? ? @project.model_file_prefix : 'MF-')
      end

      respond_to do |format|
        if @item.present?
          format.html {redirect_to item_model_files_path(@item), notice: 'model files were successfully renumbered.' }
          format.json { head :no_content }
        else
          format.html {redirect_to project_model_files_path(@project), notice: 'model files were successfully renumbered.' }
          format.json { head :no_content }
        end
      end
    end
  end

  # GET /model_files/1/mark_as_deleted/
  # GET /model_files/1/mark_as_deleted.json
  def mark_as_deleted
    authorize @model_file

    @model_file.soft_delete = true
    @data_change             = DataChange.save_or_destroy_with_undo_session(@model_file,
                                                                            'update',
                                                                            @model_file.id,
                                                                            'model_files')

    if @data_change.present?
      respond_to do |format|
        if @item.present?
          format.html { redirect_to item_model_files_url, notice: 'Model file was successfully marked as deleted.' }
          format.json { head :no_content }
        else
          format.html { redirect_to project_model_files_url, notice: 'Model file was successfully marked as deleted.' }
          format.json { head :no_content }
        end
      end
    else
      respond_to do |format|
        format.html { render :edit, error: 'Could not delete model file'}
        format.json { render json: @model_file.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /aource_file/1/download_file
  # GET /model_file/1/download_file.json
  def download_file
    authorize @model_file

    if @model_file.present?          &&
       @model_file.url_type.present? &&
       @model_file.url_link.present?
      file = @model_file.get_file_contents

      if file.kind_of?(ActiveStorage::Attached::One)
       send_data(file.download,
                 filename:     file.filename.to_s,
                 contant_type: file.content_type)
      elsif file.kind_of?(String)
        send_data(file,
                  filename: File.basename(@model_file.file_name))
      elsif file.kind_of?(URI::HTTP)
        redirect_to file.to_s, target: "_blank"

        return
      else
        respond_to do |format|
          format.html { redirect_to item_test_procedures_url, error: 'No file to download.'}
          format.json { render json: @action_item.errors,  status: :unprocessable_entity }
        end
      end
    else
      flash[:error]  = 'No file to download'

      respond_to do |format|
        if @item.present?
          format.html { redirect_to item_model_files_url, error: 'No file to download.'}
          format.json { render json: @action_item.errors,  status: :unprocessable_entity }
        else
          format.html { redirect_to project_model_files_url, error: 'No file to download.'}
          format.json { render json: @action_item.errors,  status: :unprocessable_entity }
        end
      end
    end
  end

  # GET /aource_file/1/display_file
  # GET /model_file/1/display_file.json
  def display_file
    authorize @model_file

    unless @model_file.present?       &&
           @model_file.upload_file.attached? &&
           @model_file.file_type =~ /^image\/.+$/i
      flash[:alert] = 'No file to display.'

      respond_to do |format|
        if @item.present?
          format.html { redirect_to item_model_files_url, notice: 'No file to display.'}
        else
          format.html { redirect_to project_model_files_url, notice: 'No file to display.'}
        end
      end
    end
  end

  private
    def setup_parameters
      if  model_file_params['url_type'] == 'PACT'
        params['model_file']['url_link']          = model_file_params['pact_file']
      elsif  model_file_params['url_type'] == 'ATTACHMENT'
        file                                      = model_file_params['upload_file']

        if file.present?
          params['model_file']['url_link']        = file.original_filename
        end
      end

      if  model_file_params['url_type'] != 'PACT'
        if model_file_params['url_link'] =~ /^.*\/(.+)$/
          params['model_file']['url_description'] = Regexp.last_match[1]
        else
          params['model_file']['url_description'] = model_file_params['url_link']
        end
      end

      params[:model_file][:project_id]            = @project.id if !model_file_params[:project_id].present? && @project.present?
      params[:model_file][:item_id]               = @item.id    if !model_file_params[:item_id].present?    && @item.present?
    end

    def set_model_file
      if params[:model_file_id].present?
        @model_file = ModelFile.find(params[:model_file_id])
      elsif params[:id].present?
        @model_file = ModelFile.find(params[:id])
      end

      if @model_file.present?
        @project = Project.find(@model_file.project_id) unless @project.present?
        @item    = Item.find(@model_file.item_id)       if     !@item.present? && @model_file.item_id.present? && (@model_file.item_id > 0)
      end
    end

    def setup_project
      unless @project.present?
        @project = Project.find(params[:project_id]) if params[:project_id].present?
      end
    end

    def import_model_files
      import                 = params[import_path]

      return false unless import.present?

      check_download         = []
      error                  = false
      id                     = import['item_select'].to_i if import['item_select'] =~ /^\d+$/
      file                   = import['file']

      check_download.push(:check_duplicates)   if params[import_path]['duplicates_permitted']          != '1'
      check_download.push(:check_associations) if params[import_path]['association_changes_permitted'] != '1'

      if file.present?
        filename             = if file.path.present?
                                 file.path
                               elsif file.tempfile.present?
                                 file.tempfile.path
                               end
      end

      if !error
        if id.present?
          @item              = Item.find(id)
        else
          flash[:alert]      = 'No Item Selected'
          error              = true
        end
      end

      if !error
        if filename.present?
          @item              = Item.find(id)
        else
          flash[:alert]      = 'No File Selected'
          error              = true
        end
      end

      if !((filename  =~ /^.+\.csv$/i)   ||
           ((filename =~ /^.+\.xlsx$/i)) ||
           ((filename =~ /^.+\.xls$/i))) && !error
        flash[:alert]        = 'You can only import a CSV, an xlsx or an XLS file'
        error                = true
      end

      if !error && !check_download.empty?
        result               = ModelFile.from_file(filename, @item, check_download)

        if result == :duplicate_model_file
          if @project.errors.messages.empty?
            flash[:alert]    = "File: #{file.original_filename} contains existing #{I18n.t('misc.model_files')}. Choose Duplicates Permitted to import duplicates."
          end

          error              = true

          if @project.errors.messages.empty?
            flash[:alert]    = "File: #{file.original_filename} changes associations to High or low Level Requirements. Choose Association Changes Permitted to import records with changed associations."
          end

          error              = true
        end
      end

      if !error
        unless ModelFile.from_file(filename, @item)
          flash[:alert]      = "Cannot import: #{file.original_filename}"
          error              = true
        end
      end

      return !error
    end

    # Only allow a list of trusted parameters through.
    def model_file_params
      params.require(
                       :model_file
                    )
            .permit(
                       :model_id,
                       :full_id,
                       :description,
                       :file_path,
                       :file_type,
                       :url_type,
                       :url_link,
                       :url_description,
                       :soft_delete,
                       :derived,
                       :derived_justification,
                       :system_requirement_associations,
                       :high_level_requirement_associations,
                       :low_level_requirement_associations,
                       :test_case_associations,
                       :version,
                       :revision,
                       :draft_version,
                       :revision_date,
                       :project_id,
                       :item_id,
                       :archive_id,
                       :organization,
                       :upload_file,
                       :pact_file,
                       :selected,
                       :full_id_prefix,
                       :release_model_file,
                       system_requirement_associations:     [],
                       high_level_requirement_associations: [],
                       low_level_requirement_associations:  [],
                       test_case_associations:              []
                   )
    end
end
