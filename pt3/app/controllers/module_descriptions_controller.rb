class ModuleDescriptionsController < ApplicationController
  include Common

  respond_to         :docx

  before_action      :set_module_description, only: [:show, :edit, :update, :destroy, :mark_as_deleted]
  before_action      :get_item
  before_action      :get_items, only: [:new, :edit, :update]
  before_action      :get_project_fromitemid
  before_action      :get_projects, only: [:new, :edit, :update]
  before_action      :set_session
  skip_before_action :verify_authenticity_token, only: [:update]

  # GET /module_descriptions
  # GET /module_descriptions.json
  def index
    authorize :module_description

    if params[:item_id] =~ /^\d+,\d.*$/
      ids                                = params[:item_id].split(',')
      @module_descriptions               = []

      ids.each do |id|
        if session[:archives_visible]
          module_descriptions            = ModuleDescription.where(item_id:      id,
                                                                   organization: current_user.organization)
        else
          module_descriptions            = ModuleDescription.where(item_id:      id,
                                                                   organization: current_user.organization,
                                                                   archive_id:  nil)
        end

        @module_descriptions            += module_descriptions.to_a
      end
    else
      if session[:archives_visible]
        @module_descriptions             = ModuleDescription.where(item_id:      params[:item_id],
                                                                   organization: current_user.organization)
      else
        @module_descriptions             = ModuleDescription.where(item_id:      params[:item_id],
                                                                   organization: current_user.organization,
                                                                   archive_id:  nil)
      end
    end

    @module_descriptions                 = sort_on_full_id(@module_descriptions)

    if params[:filter_field].present? && params[:filter_value]
      session[:md_filter_field] = params[:filter_field]
      session[:md_filter_value] = params[:filter_value]
      @module_descriptions      = @module_descriptions.to_a.delete_if do |module_description|
        field                   = module_description.attributes[params[:filter_field]].to_s.updescription
        value                   = params[:filter_value].updescription

        !field.index(value)
      end
    end

    @undo_path                  = get_undo_path('module_descriptions', item_module_descriptions_path(@item))
    @redo_path                  = get_redo_path('module_descriptions', item_module_descriptions_path(@item))
  end

  # GET /module_descriptions/1
  # GET /module_descriptions/1.json
  def show
    authorize :module_description

    # Get the item.
    @item            = Item.find_by(id: @module_description.item_id)
    @undo_path       = get_undo_path('module_descriptions', item_module_descriptions_path(@item))
    @redo_path       = get_redo_path('module_descriptions', item_module_descriptions_path(@item))

    if session[:archives_visible]
      @module_description_ids = ModuleDescription.where(item_id:      @item.id,
                                                        organization: current_user.organization).order(:full_id).pluck(:id)
    else
      @module_description_ids = ModuleDescription.where(item_id:      @item.id,
                                                        organization: current_user.organization,
                                                        archive_id:  nil).order(:full_id).pluck(:id)
    end
  end

  # GET /module_descriptions/new
  def new
    authorize :module_description
    @module_description                           = ModuleDescription.new
    @module_description.item_id                   = @item.id
    @module_description.project_id                = @project.id
    maximium_description_id                       = ModuleDescription.where(item_id: @item.id).maximum(:module_description_number)
    @module_description.module_description_number = maximium_description_id.present? ? maximium_description_id + 1 : 1
    # Initial version counter value is 1.
    @module_description.version                   = increment_int(@module_description.version)
    @high_level_requirements                      = sort_on_full_id(HighLevelRequirement.where(item_id: @item.id).order(:full_id))
    @low_level_requirements                       = sort_on_full_id(LowLevelRequirement.where(item_id: @item.id).order(:full_id))
    @undo_path                                    = get_undo_path('module_descriptions',
                                                                  item_module_descriptions_path(@item))
    @redo_path                                    = get_redo_path('module_descriptions',
                                                                  item_module_descriptions_path(@item))
    @high_level_requirements                      = @high_level_requirements.delete_if {|hlr| hlr.soft_delete }
    @low_level_requirements                       = @low_level_requirements.delete_if  {|llr| llr.soft_delete }
    @module_description.draft_revision            = Constants::INITIAL_DRAFT_REVISION
  end

  # GET /module_descriptions/1/edit
  def edit
    authorize @module_description

    # Increment the version counter if edited.
    @module_description.version                   = increment_int(@module_description.version)
    @high_level_requirements                      = sort_on_full_id(HighLevelRequirement.where(item_id: @item.id).order(:full_id))
    @low_level_requirements                       = sort_on_full_id(LowLevelRequirement.where(item_id: @item.id).order(:full_id))
    @undo_path                                    = get_undo_path('module_descriptions',
                                                                  item_module_descriptions_path(@item))
    @redo_path                                    = get_redo_path('module_descriptions',
                                                                  item_module_descriptions_path(@item))
    high_level_associations                       = if @module_description.high_level_requirement_associations.present?
                                                      if @module_description.high_level_requirement_associations.kind_of?(String)
                                                        @module_description.high_level_requirement_associations.split(',')
                                                      else
                                                        @module_description.high_level_requirement_associations.reject { |x| x.empty? }
                                                      end
                                                    else
                                                       []
                                                    end
    low_level_associations                        = if @module_description.low_level_requirement_associations.present?
                                                      if @module_description.low_level_requirement_associations.kind_of?(String)
                                                        @module_description.low_level_requirement_associations.split(',')
                                                      else
                                                        @module_description.low_level_requirement_associations.reject { |x| x.empty? }
                                                      end
                                                    else
                                                       []
                                                    end

    @high_level_requirements                     = @high_level_requirements.delete_if {|hlr| hlr.soft_delete }
    @low_level_requirements                      = @low_level_requirements.delete_if  {|llr| llr.soft_delete }

    @high_level_requirements.each { |hlr| hlr.selected = high_level_associations.include?(hlr.id.to_s) } if @high_level_requirements.present?
    @low_level_requirements.each  { |llr| llr.selected = low_level_associations.include?(llr.id.to_s) }  if @low_level_requirements.present?

    if session[:archives_visible]
      @module_description_ids                    = ModuleDescription.where(item_id:      @item.id,
                                                                           organization: current_user.organization).order(:full_id).pluck(:id)
    else
      @module_description_ids                    = ModuleDescription.where(item_id:      @item.id,
                                                                           organization: current_user.organization,
                                                                           archive_id:  nil).order(:full_id).pluck(:id)
    end

    @source_codes = @module_description.source_codes

    if @module_description.draft_revision.present?
      @module_description.draft_revision = increment_draft_revision(@module_description.draft_revision)
    else
      @module_description.draft_revision = Constants::INITIAL_DRAFT_REVISION
    end
  end

  # POST /module_descriptions
  # POST /module_descriptions.json
  def create
    authorize :module_description

    session_id                               = nil
    params[:module_description][:project_id] = @project.id if !module_description_params[:project_id].present? && @project.present?
    params[:module_description][:item_id]    = @item.id    if !module_description_params[:item_id].present?    && @item.present?
    @module_description                      = ModuleDescription.new(module_description_params)

    respond_to do |format|
      # Check to see if the Description ID already Exists.
      if ModuleDescription.find_by(module_description_number: @module_description.module_description_number,
                                  item_id: @module_description.item_id)
        @module_description.errors.add(:module_description_number, :blank, message: "Duplicate ID: #{@module_description.module_description_number}") 

        format.html { render :new }
        format.json { render json: @module_description.errors, status: :unprocessable_entity }
      elsif ModuleDescription.find_by(full_id: @module_description.full_id,
                                     item_id: @module_description.item_id)
        @module_description.errors.add(:full_id, :blank, message: "Duplicate ID: #{@module_description.full_id}") 

        format.html { render :new }
        format.json { render json: @module_description.errors, status: :unprocessable_entity }
      else
        session_id                           = ChangeSession.get_session_id
        @data_change                         = DataChange.save_or_destroy_with_undo_session(@module_description,
                                                                                            'create',
                                                                                            @module_description.id,
                                                                                            'module_descriptions',
                                                                                            session_id)

        if @data_change.present?
          if Associations.build_associations(@module_description) &&
             module_description_params[:upload_file].present?
            @module_description.add_model_document(module_description_params[:upload_file],
                                                   @data_change.session_id)
          end

          filename                           = ''

          @module_description.source_codes.each do |source_code|
            filename                        += ', ' unless filename.present?
            filename                        += source_code.file_name
          end

          @data_change                       = DataChange.save_or_destroy_with_undo_session(@module_description,
                                                                                            'create',
                                                                                            @module_description.id,
                                                                                            'module_descriptions',
                                                                                            session_id)

          format.html { redirect_to [@item, @module_description], notice: 'Module description was successfully created.' }
          format.json { render :show, status: :created, location: [@item, @module_description] }
        else
          format.html { render :new }
          format.json { render json: @module_description.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # PATCH/PUT /module_descriptions/1
  # PATCH/PUT /module_descriptions/1.json
  def update
    authorize @module_description

    session_id                               = nil
    params[:module_description][:project_id]          = @project.id if !module_description_params[:project_id].present? && @project.present?
    params[:module_description][:item_id]             = @item.id    if !module_description_params[:item_id].present?    && @item.present?

    respond_to do |format|
      # Check to see if the Description ID already Exists.
      new_id = module_description_params[:module_description_number].to_i

      if (new_id != @module_description.module_description_number) &&
         ModuleDescription.find_by(module_description_number:   new_id,
                                   item_id: @module_description.item_id)
        @module_description.errors.add(:module_description_number, :blank, message: "Duplicate ID: #{@module_description.module_description_number}") 

        format.html { render :new }
        format.json { render json: @module_description.errors, status: :unprocessable_entity }
      else
        session_id                           = ChangeSession.get_session_id
        @data_change                         = DataChange.save_or_destroy_with_undo_session(params['module_description'],
                                                                                            'update',
                                                                                             params[:id],
                                                                                            'module_descriptions',
                                                                                            session_id)

        if @data_change.present?
          if Associations.build_associations(@module_description) &&
             module_description_params[:upload_file].present?
            @module_description.add_model_document(module_description_params[:upload_file],
                                          @data_change.session_id)
          filename                           = ''

          @module_description.source_codes.each do |source_code|
            filename                        += ', ' unless filename.present?
            filename                        += source_code.file_name
          end

          @data_change                       = DataChange.save_or_destroy_with_undo_session(@module_description,
                                                                                            'create',
                                                                                            @module_description.id,
                                                                                            'module_descriptions',
                                                                                            session_id)

          end

          format.html { redirect_to item_module_description_path(@item.id, @module_description.id, previous_mode: 'editing'), notice: "#{I18n.t('module_description.single_title')} was successfully updated." }
          format.json { render :show, status: :ok, location: [@item, @module_description] }
        else
          format.html { render :edit }
          format.json { render json: @module_description.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /module_descriptions/1
  # DELETE /module_descriptions/1.json
  def destroy
    authorize @module_description

    @data_change = DataChange.save_or_destroy_with_undo_session(@module_description,
                                                                'delete',
                                                                @module_description.id,
                                                                'module_descriptions')

    respond_to do |format|
      format.html { redirect_to item_module_descriptions_url, notice: 'Module description was successfully removed.' }
      format.json { head :no_content }
    end
  end

  def export
    authorize :module_description

    # Get all Module Description requirements
    @module_descriptions = if session[:archives_visible].kind_of?(Integer)
                              ModuleDescription.where(item_id:    params[:item_id],
                                             archive_id: session[:archives_visible]).order(:full_id)
                           else
                              ModuleDescription.where(item_id:    params[:item_id],
                                             archive_id: nil).order(:full_id)
                           end

    @starting_number = (params[:md_export] && params[:md_export][:starting_number].present?) ? params[:md_export][:starting_number].to_i : 1 ;

    respond_to do |format|
      if params[:md_export].try(:has_key?, :export_type) && params[:md_export][:export_type] == 'HTML'
        format.html { render "module_descriptions/export_html", layout: false }
        format.json { render :show, status: :ok, location: @module_description }
      elsif params[:md_export].try(:has_key?, :export_type) && params[:md_export][:export_type] == 'PDF'
        format.html { redirect_to item_module_descriptions_export_path(format: :pdf) }
      elsif params[:md_export].try(:has_key?, :export_type) && params[:md_export][:export_type] == 'CSV'
        # Come back here using the csv format to generate the csv below.
        format.html { redirect_to item_module_descriptions_export_path(format: :csv) }
      elsif params[:md_export].try(:has_key?, :export_type) && params[:md_export][:export_type] == 'XLS'
        # Come back here using the xls format to generate the xls below.
        format.html { redirect_to item_module_descriptions_export_path(format: :xls) }
      elsif params[:md_export].try(:has_key?, :export_type) && params[:md_export][:export_type] == 'DOCX'
        # Come back here using the docx format to generate the docx below.
        if convert_data("Module_Descriptions.docx",
                        'module_descriptions/export_html.html.erb',
                        @item.present? ? @item.id : params[:item_id])
          format.html { redirect_to item_module_descriptions_export_path(filename: @converted_filename, format: :docx, starting_number: params[:md_export].try(:has_key?, :starting_number) ) }
        else
          flash[:error]  = @conversion_error
          params[:level] = 2

          go_back
        end
      else
        format.html { render :export }
        format.json { render json: @module_description.errors, status: :unprocessable_entity }
        # If redirected using format => csv, generate the csv here.
        format.csv  { send_data ModuleDescription.to_csv(@item.id), filename: "#{@item.name}-Module_Descriptions.csv" }
        format.xls  { send_data ModuleDescription.to_xls(@item.id), filename: "#{@item.name}-Module_Descriptions.xls" }
        format.pdf  {
                       @no_links = true

                       render(pdf:      "#{@project.name}-ModuleDescriptions",
                              template: 'module_descriptions/export_html.html.erb',
                              title:    'Module Descriptions: Export PDF | PACT',
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

  def import_module_descriptions
    import                = params[import_path]

    return false unless import.present?

    check_download        = []
    error                 = false
    id                    = import['item_select'].to_i if import['item_select'] =~ /^\d+$/
    file                  = import['file']

    check_download.push(:check_duplicates)   if params[import_path]['duplicates_permitted']          != '1'
    check_download.push(:check_associations) if params[import_path]['association_changes_permitted'] != '1'

    if file.present?
      filename          = if file.path.present?
                            file.path
                          elsif file.tempfile.present?
                            file.tempfile.path
                          end
    end

    if !error
      if id.present?
        @item             = Item.find(id)
      else
        flash[:alert]     = 'No Item Selected'
        error             = true
      end
    end

    if !error
      if filename.present?
        @item             = Item.find(id)
      else
        flash[:alert]     = 'No File Selected'
        error             = true
      end
    end

    if !((filename  =~ /^.+\.csv$/i)   ||
         ((filename =~ /^.+\.xlsx$/i)) ||
         ((filename =~ /^.+\.xls$/i))) && !error
      flash[:alert]   = 'You can only import a CSV, an xlsx or an XLS file'
      error           = true
    end

    if !error && !check_download.empty?
      result = ModuleDescription.from_file(filename, @item, check_download)

      if result == :duplicate_module_description
        if @project.errors.messages.empty?
          flash[:alert] = "File: #{file.original_filename} contains existing Module Descriptions. Choose Duplicates Permitted to import duplicates."
        end

        error           = true
      elsif result == :module_description_associations_changed
        if @project.errors.messages.empty?
          flash[:alert] = "File: #{file.original_filename} changes associations to High or low Level Requirements. Choose Association Changes Permitted to import records with changed associations."
        end

        error           = true
      end
    end

    if !error
      unless ModuleDescription.from_file(filename, @item)
        if @item.errors.messages.empty?
          flash[:alert]    = "Cannot import: #{file.original_filename}"
        else
          @item.errors.messages.each do |key, value|
            flash[:alert] += "\n" + value 
          end
        end

        error              = true
      end
    end

    return !error
  end

  def import
    authorize :module_description

    if params[import_path].present?
      if import_module_descriptions
        respond_to do |format|
          format.html {redirect_to item_module_descriptions_path(@item), notice: 'Module Description requirements were successfully imported.' }
          format.json { head :no_content }
        end
      else
        respond_to do |format|
          format.html { redirect_to item_module_descriptions_import_path(@item) }
          format.json { render json: @item.errors, status: :unprocessable_entity }
        end
      end
    else
      respond_to do |format|
        format.html { render :import }
        format.json { render json: @module_description.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /module_descriptions/renumber
  def renumber
    authorize :module_description

    if params[:md_renumber].try(:has_key?, :start)     &&
       params[:md_renumber][:start]     =~/^\d+$/      &&
       params[:md_renumber].try(:has_key?, :increment) &&
       params[:md_renumber][:increment] =~/^\d+$/      &&
       params[:md_renumber][:leading_zeros] =~/^\d+$/
      ModuleDescription.renumber(@item.id, 
                                 params[:md_renumber][:start].to_i,
                                 params[:md_renumber][:increment].to_i,
                                 @item.module_description_prefix,
                                 params[:md_renumber][:leading_zeros].to_i)
  
      respond_to do |format|
        format.html {redirect_to item_module_descriptions_path(@item), notice: 'Module Descriptions were successfully renumbered.' }
        format.json { head :no_content }
      end
    end
  end

  # GET /module_descriptions/1/mark_as_deleted/
  # GET /module_descriptions/1/mark_as_deleted.json
  def mark_as_deleted
    authorize @module_description

    @module_description.soft_delete = true
    @data_change           = DataChange.save_or_destroy_with_undo_session(@module_description,
                                                                          'update',
                                                                          @module_description.id,
                                                                          'module_descriptions')

    if @data_change.present?
      respond_to do |format|
        format.html { redirect_to item_module_descriptions_url, notice: 'Module description was successfully marked as deleted.' }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html { render :edit, error: 'Could not delete module description'}
        format.json { render json: @module_description.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_module_description
      if params[:id].present? && params[:id] =~ /\d+/
        @module_description = ModuleDescription.find(params[:id])
      elsif params[:module_description_id] && params[:module_description_id] =~ /\d+/
        @module_description = ModuleDescription.find(params[:module_description_id])
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def module_description_params
      params.require(
                       :module_description
                    )
            .permit(
                       :module_description_number,
                       :full_id,
                       :description,
                       :file_name,
                       :version,
                       :revision,
                       :draft_revision,
                       :revision_date,
                       :item_id,
                       :project_id,
                       :archive_id,
                       :high_level_associations,
                       :low_level_associations,
                       :high_level_requirement_associations,
                       :low_level_requirement_associations,
                       :full_id_prefix,
                       :soft_delete,
                       high_level_requirement_associations: [],
                       low_level_requirement__associations: []
                   )
    end
end
