class RequirementsBaselinesController < ApplicationController
  include Common

  before_action :get_item
  before_action :get_project_byparam
  before_action :setup_requirements_baseline

  # GET /requirements_baselines
  # GET /requirements_baselines.json
  def index
    authorize :requirements_baseline

    @requirements_baselines          = if @project.try(:id) && @item.try(:id)
                                         Archive.where(project_id:   @project.id,
                                                       item_id:      @item.id,
                                                       archive_type: @archive_type,
                                                       organization: current_user.organization)
                                       elsif @project.try(:id)
                                         Archive.where(project_id:   @project.id,
                                                       archive_type: @archive_type,
                                                       organization: current_user.organization)
                                       elsif @item.try(:id)
                                         Archive.where(item_id:      @item.id,
                                                       archive_type: @archive_type,
                                                       organization: current_user.organization)
                                       else
                                         Archive.where(archive_type: @archive_type,
                                                       organization: current_user.organization)
                                       end
    if params[:filter_field].present? && params[:filter_value]
      session[:archive_filter_field] = params[:filter_field]
      session[:archive_filter_value] = params[:filter_value]
      @requirements_baselines        = @requirements_baselines.delete_if do |requirements_baseline|
        field                        = requirements_baseline.attributes[params[:filter_field]].upitem
        value                        = params[:filter_value].upitem

        !field.index(value)
      end
    end
  end

  # GET /requirements_baselines/1
  # GET /requirements_baselines/1.json
  def show
    authorize :requirements_baseline
  end

  # GET /requirements_baselines/new
  def new
    authorize :requirements_baseline

    @requirements_baseline                  = Archive.new()
    @requirements_baseline.full_id          = ''
    @requirements_baseline.revision         = ''
    element_name                            = ''
    title                                   = ''
    project_name                            = @project.present? ? @project.name : ''
    item_name                               = @item.present?    ? @item.name    : ''
    maximium_version                        = if @item.present?
                                                Archive.where(organization: current_user.organization,
                                                              archive_type: @archive_type,
                                                              item_id:      @item.id).maximum(:version)
                                              elsif @project.present?
                                                Archive.where(organization: current_user.organization,
                                                              archive_type: @archive_type,
                                                              project_id:   @project.id).maximum(:version)
                                              else
                                                Archive.where(archive_type: @archive_type,
                                                              organization: current_user.organization).maximum(:version)
                                              end

    if maximium_version =~ /^\d+$/
      @requirements_baseline.version        = (maximium_version.to_i + 1).to_s
    elsif maximium_version =~ /^\d+\.\d+$/
      @requirements_baseline.version        = (maximium_version.to_f + 0.1).to_s
    else
      @requirements_baseline.version        = Constants::INITIAL_DRAFT_REVISION
    end

    if (@archive_type == Constants::DOCUMENT_ARCHIVE) && @element_id.present?
      document                              = Document.find_by(id: @element_id)

      if document.present?
        @requirements_baseline.revision     = document.revision
        @requirements_baseline.version      = document.draft_revision
        element_name                        = document.docid
      end
    elsif (@archive_type == Constants::REVIEW_ARCHIVE) && @element_id.present?
      review                                = Review.find_by(id: @element_id)

      if review.present?
        @requirements_baseline.version      = review.version
        element_name                        = review.title
      end
    end

    @requirements_baseline.version.sub!(/(\.\d*[1-9])0+([1-9]+)$/, Regexp.last_match[1]) if @requirements_baseline.version =~ /(\.\d*[1-9])0+([1-9]+)$/

    @requirements_baseline.full_id         += project_name + "_" if project_name.present?
    @requirements_baseline.full_id         += item_name    + "_" if item_name.present?
    @requirements_baseline.full_id         += element_name + "_" if element_name.present?
    @requirements_baseline.full_id         += "#{@requirements_baseline.revision}_#{@requirements_baseline.version}"

    if element_name.present?
      title                                 = if @requirements_baseline.revision.present?
                                                "Baseline of #{element_name}, Revision #{@requirements_baseline.revision}, Version #{@requirements_baseline.version}"
                                              else
                                                "Baseline of #{element_name}, Version #{@requirements_baseline.version}"
                                              end
    elsif @archive_type.present?
      title                                 = if @requirements_baseline.revision.present?
                                                "#{@archive_type.titleize} Baseline, Revision #{@requirements_baseline.revision}, Version #{@requirements_baseline.version}"
                                              else
                                                "#{@archive_type.titleize} Baseline, Version #{@requirements_baseline.version}"
                                              end
    else
      title                                 = if @requirements_baseline.revision.present?
                                                "Baseline, Revision #{@requirements_baseline.revision}, Version #{@requirements_baseline.version}"
                                              else
                                                "Baseline, Version #{@requirements_baseline.version}"
                                              end
    end

    title                                  += " in Project: #{project_name}" if project_name.present?
    title                                  += " and Item: #{item_name}"      if item_name.present?
    @requirements_baseline.name,            = title
    @requirements_baseline.description      = title
    @requirements_baseline.archive_type     = @archive_type
    @requirements_baseline.element_id       = @element_id
    @requirements_baseline.archived_at      = DateTime.now()
    @requirements_baseline.pact_version     = Tool::Application::VERSION
    @requirements_baseline.organization     = User.current.organization
    @requirements_baseline.project_id       = @project.id                                                                             if @project.present?
    @requirements_baseline.item_id          = @item.id                                                                                if @item.present?
  end

  # GET /requirements_baselines/1/edit
  def edit
    authorize :requirements_baseline
  end

  # POST /requirements_baselines
  # POST /requirements_baselines.json
  def create
    authorize :requirements_baseline

    session_id                                     = nil
    @requirements_baseline                         = Archive.new(requirements_baseline_params)
    @requirements_baseline.project_id              = @project.id                            if     @project.present?
    @requirements_baseline.item_id                 = @item.id                               if     @item.present?
    @requirements_baseline.pact_version            = Tool::Application::VERSION             unless @requirements_baseline.pact_version.present?
    @requirements_baseline.archive_type            = Constants::SYSTEM_REQUIREMENTS_ARCHIVE unless @requirements_baseline.archive_type.present?
    @requirements_baseline.archived_at             = DateTime.now()                         unless @requirements_baseline.archived_at.present?
    @data_change                                   = DataChange.save_or_destroy_with_undo_session(@requirements_baseline,
                                                                                                'create')

    if @data_change.present?
      session_id                                   = @data_change.session_id
      id_prefix                                    = "#{@requirements_baseline.full_id}_"
      project                                      = @project.dup
      project.id                                   = nil
      project.identifier                           = id_prefix + project.identifier
      project.archive_id                           = @requirements_baseline.id
      data_change                                  = DataChange.save_or_destroy_with_undo_session(project,
                                                                                                 'create',
                                                                                                 nil,
                                                                                                 'projects',
                                                                                                 session_id)

      if data_change.present? && project.id.present?
        @requirements_baseline.archive_project_id  = project.id

        DataChange.save_or_destroy_with_undo_session(@requirements_baseline,
                                                     'update',
                                                     @requirements_baseline.id,
                                                     'archives',
                                                     session_id)
      end

      if (@requirements_baseline.archive_type == Constants::REVIEW_ARCHIVE)
        new_item                                   = @item.dup
        new_item.id                                = nil
        new_item.project_id                        = project.id
        new_item.archive_id                        = @requirements_baseline.id
        data_change                                = DataChange.save_or_destroy_with_undo_session(new_item,
                                                                                                  'create',
                                                                                                  nil,
                                                                                                  'items',
                                                                                                  session_id)

        if data_change.present? && @item.present? && new_item.id.present?
          @requirements_baseline.archive_item_ids  = [ new_item.id ]
          @requirements_baseline.archive_item_id   = new_item.id

          @requirements_baseline.clone_reviews(project.id,
                                               @item.id,
                                               new_item.id,
                                               session_id)
          DataChange.save_or_destroy_with_undo_session(@requirements_baseline,
                                                       'update',
                                                       @requirements_baseline.id,
                                                       'archives',
                                                       session_id)
        end
      elsif (@requirements_baseline.archive_type == Constants::DOCUMENT_ARCHIVE) &&
             @element_id.present?
        new_item                                   = @item.dup
        new_item.id                                = nil
        new_item.project_id                        = project.id
        new_item.archive_id                        = @requirements_baseline.id
        data_change                                = DataChange.save_or_destroy_with_undo_session(new_item,
                                                                                                  'create',
                                                                                                  nil,
                                                                                                  'items',
                                                                                                  session_id)

        if data_change.present? && @item.present? && new_item.id.present?
          document                                 = Document.find(@element_id)
          @requirements_baseline.archive_item_ids  = [ new_item.id ]
          @requirements_baseline.archive_item_id   = new_item.id

          @requirements_baseline.clone_document(document,
                                                project.id,
                                                new_item.id,
                                                session_id)
          DataChange.save_or_destroy_with_undo_session(@requirements_baseline,
                                                       'update',
                                                       @requirements_baseline.id,
                                                       'archives',
                                                       session_id)
        end
      else
        @requirements_baseline.clone_system_requirements(@project.id,
                                                         project.id,
                                                         session_id)

        items                                      = Item.where(project_id: @project.id)
        archive_items                              = []

        items.each do |item|
          new_item                                 = item.dup
          new_item.id                              = nil
          new_item.project_id                      = project.id
          new_item.archive_id                      = @requirements_baseline.id
          data_change                              = DataChange.save_or_destroy_with_undo_session(new_item,
                                                                                                  'create',
                                                                                                  nil,
                                                                                                  'items',
                                                                                                  session_id)

          archive_items.push(new_item.id) if new_item.id.present?

          if data_change.present? && @item.present? && (item.id == @item.id) && new_item.id.present?
            @requirements_baseline.archive_item_id = new_item.id

            DataChange.save_or_destroy_with_undo_session(@requirements_baseline,
                                                         'update',
                                                         @requirements_baseline.id,
                                                         'archives',
                                                         session_id)
          end

          @requirements_baseline.clone_high_level_requirements(project.id,
                                                               item.id,
                                                               new_item.id,
                                                               session_id)
          @requirements_baseline.clone_low_level_requirements(project.id,
                                                              item.id,
                                                              new_item.id,
                                                              session_id)
          @requirements_baseline.clone_model_files(project.id,
                                                   item.id,
                                                   new_item.id,
                                                   session_id)
          @requirements_baseline.clone_module_descriptions(project.id,
                                                           item.id,
                                                           new_item.id,
                                                           session_id)
          @requirements_baseline.clone_source_codes(project.id,
                                                    item.id,
                                                    new_item.id,
                                                    session_id)
          @requirements_baseline.clone_test_cases(project.id,
                                                  item.id,
                                                  new_item.id,
                                                  session_id)
          @requirements_baseline.clone_test_procedures(project.id,
                                                       item.id,
                                                       new_item.id,
                                                       session_id)
        end if items.present?

        if archive_items.present?
          @requirements_baseline.archive_item_ids  = archive_items
  
          DataChange.save_or_destroy_with_undo_session(@requirements_baseline,
                                                       'update',
                                                       @requirements_baseline.id,
                                                       'archives',
                                                       session_id)
        end
      end

      respond_to do |format|
        format.html { redirect_to @return_path, notice: "#{@archive_type.titleize} baseline was successfully created." }
        format.json { render :show, status: :created, location: @requirements_baseline }
      end
    else
      respond_to do |format|
        format.html { render :new }
        format.json { render json: @requirements_baseline.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /requirements_baselines/1
  # PATCH/PUT /requirements_baselines/1.json
  def update
    authorize :requirements_baseline

    params[:archive][:archive_type] = @requirements_baseline.archive_type unless params[:archive][:archive_type].present?
    @data_change                    = DataChange.save_or_destroy_with_undo_session(requirements_baseline_params,
                                                                                   'update',
                                                                                   params[:id],
                                                                                   'archives')

    if @data_change.present?
      respond_to do |format|
        format.html { redirect_to @return_path, notice: "#{@archive_type.titleize} baseline was successfully updated." }
        format.json { render :show, status: :created, location: @requirements_baseline }
      end
    else
      respond_to do |format|
        format.html { render :edit }
        format.json { render json: @requirements_baseline.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /requirements_baselines/1
  # DELETE /requirements_baselines/1.json
  def destroy
    authorize :requirements_baseline

    @data_change = DataChange.save_or_destroy_with_undo_session(@requirements_baseline,
                                                                'delete',
                                                                @requirements_baseline.id,
                                                                'archives')

    if @data_change.present?
      respond_to do |format|
        format.html { redirect_to @return_path, notice: "#{@archive_type.titleize} baseline was successfully deleted." }
        format.json { render :show, status: :created, location: @requirements_baseline }
      end
    else
      respond_to do |format|
        format.html { redirect_to @return_path, alert: "#{@archive_type.titleize} baseline could not be deleted." }
        format.json { render json: @requirements_baseline.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    def get_return_path_for_type
      @return_path = case @archive_type
                       when Constants::SYSTEM_REQUIREMENTS_ARCHIVE
                         project_system_requirements_url(@project) if @project.present?
                       when Constants::HIGH_LEVEL_REQUIREMENTS_ARCHIVE
                         item_high_level_requirements_url(@item)   if @item.present?
                       when Constants::LOW_LEVEL_REQUIREMENTS_ARCHIVE
                         item_low_level_requirements_url(@item)    if @item.present?
                       when Constants::SOURCE_CODE_ARCHIVE
                         item_source_codes_url(@item)              if @item.present?
                       when Constants::TEST_CASE_ARCHIVE
                         item_test_cases_url(@item)                if @item.present?
                       when Constants::TEST_PROCEDURE_ARCHIVE
                         item_test_procedures_url(@item)           if @item.present?
                       else
                         project_items_url(@project)
                     end

      return @return_path
    end
    # Use callbacks to share common setup or constraints between actions.

    def setup_requirements_baseline
      if params[:id].present?
        @requirements_baseline = Archive.find(params[:id])
      elsif params[:requirements_baseline_id].present?
        @requirements_baseline = Archive.find(params[:requirements_baseline_id])
      end

      if @requirements_baseline.present?
        @archive_type          = @requirements_baseline.archive_type
        @element_id            = @requirements_baseline.element_id
        @project               = Project.find(@requirements_baseline.project_id) if !@project.present? &&
                                                                                     @requirements_baseline.project_id =~ /^\d+$/
        @item                  = Item.find(@requirements_baseline.item_id)       if !@item.present? &&
                                                                                     @requirements_baseline.item_id =~ /^\d+$/
      elsif params[:archive].present?
        @archive_type          = params[:archive][:archive_type]
        @element_id            = params[:archive][:element_id]
        @item                  = Item.find(params[:archive][:item_id])           if !@item.present? &&
                                                                                     params[:archive][:item_id] =~ /^\d+$/
      end

      unless @archive_type.present?
        @archive_type          = if params[:archive_type].present?
                                   params[:archive_type]
                                 elsif params[:requirements_baseline_params].present? && requirements_baseline_params[:archive_type].present? 
                                   requirements_baseline_params[:archive_type]
                                 elsif params[:archive].present? && params[:archive][:archive_type].present? 
                                   params[:archive][:archive_type]
                                 else
                                   Constants::SYSTEM_REQUIREMENTS_ARCHIVE
                                 end
      end

      unless @element_id.present?
        @element_id          = if params[:element_id].present?
                                   params[:element_id]
                                 elsif params[:requirements_baseline_params].present? && requirements_baseline_params[:element_id].present? 
                                   requirements_baseline_params[:element_id]
                                 elsif params[:archive].present? && params[:archive][:element_id].present? 
                                   params[:archive][:element_id]
                                 end
      end

      @item                    = Item.find(requirements_baseline_params[:item_id]) if !@item.present? && params[:requirements_baseline_params].present? && requirements_baseline_params[:item_id].present?
      @item                    = Item.find(@requirements_baseline.item_id)         if !@item.present? && @requirements_baseline.try(:item_id)

      get_return_path_for_type

      if @return_path.present?
        @undo_path    = get_undo_path('archives', @return_path)
        @redo_path    = get_redo_path('archives', @return_path)
      end
    end

    # Only allow a list of trusted parameters through.
    def requirements_baseline_params
      params.require(
                       :archive)
            .permit(
                       :name,
                       :full_id,
                       :description,
                       :revision,
                       :version,
                       :archived_at,
                       :pact_version,
                       :archive_type,
                       :element_id,
                       :organization,
                       :project_id,
                       :item_id,
                       :archive_project_id,
                       :archive_item_id,
                       archive_item_ids: []
                   )
    end
end
