class HighLevelRequirementsController < ApplicationController
  include Common

  respond_to    :docx

  before_action :set_high_level_requirement, only: [:show, :edit, :update, :destroy, :mark_as_deleted]
  before_action :get_item
  before_action :get_items, only: [:new, :edit, :update]
  before_action :get_project_fromitemid
  before_action :get_projects, only: [:new, :edit, :update]
  before_action :set_session
  before_action :set_session
  skip_before_action :verify_authenticity_token, only: [:update]

  # before_action :get_system_requirements, only: [:new, :edit, :update]
  # https://stackoverflow.com/a/39918694
  # before_action only: [:new, :edit, :update] { get_system_requirements(params[:item_id]) }

  # GET /high_level_requirements
  # GET /high_level_requirements.json
  def index
    authorize :high_level_requirement

    if params[:item_id] =~ /^\d+,\d.*$/
      ids                      = params[:item_id].split(',')
      @high_level_requirements = []

      ids.each do |id|
        if session[:archives_visible]
          high_level_requirements = HighLevelRequirement.where(item_id:      id,
                                                               organization: current_user.organization)
        else
          high_level_requirements = HighLevelRequirement.where(item_id:      id,
                                                               organization: current_user.organization,
                                                               archive_id:  nil)
        end

        @high_level_requirements += high_level_requirements.to_a
      end
    else
      if session[:archives_visible]
        @high_level_requirements = HighLevelRequirement.where(item_id:      params[:item_id],
                                                              organization: current_user.organization)
      else
        @high_level_requirements = HighLevelRequirement.where(item_id:      params[:item_id],
                                                              organization: current_user.organization,
                                                              archive_id:  nil)
      end
    end

    @high_level_requirements   = sort_on_full_id(@high_level_requirements);
 
    if params[:filter_field].present? && params[:filter_value]
      session[:hlr_filter_field] = params[:filter_field]
      session[:hlr_filter_value] = params[:filter_value]
      @high_level_requirements   = @high_level_requirements.to_a.delete_if do |high_level_requirement|
        field                    = high_level_requirement.attributes[params[:filter_field]].to_s.upcase
        value                    = params[:filter_value].upcase

        !field.index(value)
      end
    end

    @undo_path                 = get_undo_path('high_level_requirements',
                                               item_high_level_requirements_path(@item))
    @redo_path                 = get_redo_path('high_level_requirements',
                                               item_high_level_requirements_path(@item))
  end

  # GET /high_level_requirements/1
  # GET /high_level_requirements/1.json
  def show
    authorize :high_level_requirement
    # Get the item for this high level requirement.
    @item      = Item.find_by(id: @high_level_requirement.item_id)
    @undo_path = get_undo_path('high_level_requirements',
                                item_high_level_requirements_path(@item))
    @redo_path = get_redo_path('high_level_requirements',
                                item_high_level_requirements_path(@item))

    if session[:archives_visible]
      @high_level_requirement_ids = HighLevelRequirement.where(item_id:      @item.id,
                                                               organization: current_user.organization).order(:full_id).pluck(:id)
    else
      @high_level_requirement_ids = HighLevelRequirement.where(item_id:      @item.id,
                                                               organization: current_user.organization,
                                                               archive_id:  nil).order(:full_id).pluck(:id)
    end
  end

  # GET /high_level_requirements/new
  def new
    authorize :high_level_requirement

    @system_requirements               = sort_on_full_id(SystemRequirement.where(project_id:   @project.id,
                                                                                 organization: current_user.organization).order(:full_id))
    @high_level_requirement            = HighLevelRequirement.new
    @high_level_requirement.item_id    = @item.id
    @high_level_requirement.project_id = @project.id
    maximium_reqid                     = HighLevelRequirement.where(item_id: @item.id).maximum(:reqid)
    @high_level_requirement.reqid      = maximium_reqid.present? ? maximium_reqid + 1 : 1
    @pact_files                        = get_model_file_list(@high_level_requirement.project_id,
                                                             @high_level_requirement.item_id)

    # Initial version counter value is 1.
    @high_level_requirement.version    = increment_int(@high_level_requirement.version)
    @system_requirements               = @system_requirements.delete_if {|sysreq| sysreq.soft_delete }
  end

  # GET /high_level_requirements/1/edit
  def edit
    authorize @high_level_requirement

    @system_requirements            = sort_on_full_id(SystemRequirement.where(project_id:   @project.id,
                                                                              organization: current_user.organization).order(:full_id))
    # Increment the version counter if edited.
    @high_level_requirement.version = increment_int(@high_level_requirement.version)
    @undo_path                      = get_undo_path('high_level_requirements',
                                                     item_high_level_requirements_path(@item))
    @redo_path                      = get_redo_path('high_level_requirements',
                                                     item_high_level_requirements_path(@item))
    @pact_files                     = get_model_file_list(@high_level_requirement.project_id,
                                                          @high_level_requirement.item_id)
    system_requirement_associations = if @high_level_requirement.system_requirement_associations.present?
                                        if @high_level_requirement.system_requirement_associations.kind_of?(String)
                                          @high_level_requirement.system_requirement_associations.split(',')
                                        else
                                          @high_level_requirement.system_requirement_associations.reject { |x| x.empty? }
                                        end
                                      else
                                         []
                                      end
    high_level_associations         = if @high_level_requirement.high_level_requirement_associations.present?
                                        if @high_level_requirement.high_level_requirement_associations.kind_of?(String)
                                          @high_level_requirement.high_level_requirement_associations.split(',')
                                        else
                                          @high_level_requirement.high_level_requirement_associations.reject { |x| x.empty? }
                                        end
                                      else
                                         []
                                      end

    @system_requirements          = @system_requirements.delete_if     {|sysreq| sysreq.soft_delete } if @system_requirements.present?
    @high_level_requirements      = @high_level_requirements.delete_if {|hlr|    hlr.soft_delete } if @high_level_requirements.present?

    @system_requirements.each     { |sysreq| sysreq.selected = system_requirement_associations.include?(sysreq.id.to_s) } if @system_requirements.present?
    @high_level_requirements.each { |hlr|    hlr.selected    = high_level_associations.include?(hlr.id.to_s) }            if @high_level_requirements.present?

    if session[:archives_visible]
      @high_level_requirement_ids = HighLevelRequirement.where(item_id:      @item.id,
                                                               organization: current_user.organization).order(:full_id).pluck(:id)
    else
      @high_level_requirement_ids = HighLevelRequirement.where(item_id:      @item.id,
                                                               organization: current_user.organization,
                                                               archive_id:  nil).order(:full_id).pluck(:id)
    end


  end

  # POST /high_level_requirements
  # POST /high_level_requirements.json
  def create
    authorize :high_level_requirement

    session_id                                   = nil
    params[:high_level_requirement][:project_id] = @project.id if !high_level_requirement_params[:project_id].present? && @project.present?
    params[:high_level_requirement][:item_id]    = @item.id    if !high_level_requirement_params[:item_id].present?    && @item.present?
    @high_level_requirement                      = HighLevelRequirement.new(high_level_requirement_params)
    @high_level_requirement.project_id           = @project.id
    @high_level_requirement.model_file_id        = nil if @high_level_requirement.model_file_id.to_s == "-1"

    respond_to do |format|
      # Check to see if the Requirement ID already Exists.
      if HighLevelRequirement.find_by(reqid:   @high_level_requirement.reqid,
                                      item_id: @high_level_requirement.item_id)
        @high_level_requirement.errors.add(:reqid, :blank, message: "Duplicate ID: #{@high_level_requirement.reqid}") 
        format.html { render :new }
        format.json { render json: @HighLevelRequirement.errors, status: :unprocessable_entity }
      elsif HighLevelRequirement.find_by(full_id: @high_level_requirement.full_id,
                                         item_id: @high_level_requirement.item_id)
        @high_level_requirement.errors.add(:full_id, :blank, message: "Duplicate ID: #{@high_level_requirement.full_id}") 

        format.html { render :new }
        format.json { render json: @high_level_requirement.errors, status: :unprocessable_entity }
      else
        session_id                               = ChangeSession.get_session_id
        @data_change                             = DataChange.save_or_destroy_with_undo_session(@high_level_requirement,
                                                                                                'create',
                                                                                                @high_level_requirement.id,
                                                                                                'high_level_requirements',
                                                                                                session_id)

        if @data_change.present?
          if Associations.build_associations(@high_level_requirement) &&
             high_level_requirement_params[:upload_file].present?
            @high_level_requirement.add_model_document(high_level_requirement_params[:upload_file],
                                                       @data_change.session_id)
          end

          # Increment the global counter, and save the item.
          @item.hlr_count                       += 1

          DataChange.save_or_destroy_with_undo_session(@item,
                                                       'update',
                                                       @item.id,
                                                       'items',
                                                       session_id)
          format.html { redirect_to [@item, @high_level_requirement], notice: 'High level requirement was successfully created.' }
          format.json { render :show, status: :created, location: [@item, @high_level_requirement] }
        else
          format.html { render :new }
          format.json { render json: @high_level_requirement.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # PATCH/PUT /high_level_requirements/1
  # PATCH/PUT /high_level_requirements/1.json
  def update
    authorize @high_level_requirement

    session_id                                            = nil
    params[:high_level_requirement][:project_id]          = @project.id if !high_level_requirement_params[:project_id].present? && @project.present?
    params[:high_level_requirement][:item_id]             = @item.id    if !high_level_requirement_params[:item_id].present?    && @item.present?
    params[:high_level_requirement][:model_file_id]       = nil         if  high_level_requirement_params[:model_file_id].to_s == "-1"

    respond_to do |format|
      new_id = high_level_requirement_params[:reqid].to_i

      if (new_id != @high_level_requirement.reqid) &&
         HighLevelRequirement.find_by(reqid:   new_id,
                                      item_id: @high_level_requirement.item_id)
        @high_level_requirement.errors.add(:reqid, :blank, message: "Duplicate ID: #{@high_level_requirement.reqid}") 

        format.html { render :new }
        format.json { render json: @high_level_requirement.errors, status: :unprocessable_entity }
      else
        session_id                                        = ChangeSession.get_session_id
        @data_change                                      = DataChange.save_or_destroy_with_undo_session(params['high_level_requirement'],
                                                                                                         'update',
                                                                                                         params[:id],
                                                                                                         'high_level_requirements',
                                                                                                         session_id)

        if @data_change.present?
          if Associations.build_associations(@high_level_requirement) &&
             high_level_requirement_params[:upload_file].present?
            @high_level_requirement.add_model_document(high_level_requirement_params[:upload_file],
                                                       @data_change.session_id)
          end

          format.html { redirect_to item_high_level_requirement_path(@item.id, @high_level_requirement.id, previous_mode: 'editing'), notice: "#{Item.item_type_title(@item, :high_level, :singular) } was successfully updated." }
          format.json { render :show, status: :ok, location: [@item, @high_level_requirement] }
        else
          format.html { render :edit }
          format.json { render json: @high_level_requirement.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /high_level_requirements/1
  # DELETE /high_level_requirements/1.json
  def destroy
    authorize @high_level_requirement

    @data_change = DataChange.save_or_destroy_with_undo_session(@high_level_requirement,
                                                                'delete',
                                                                @high_level_requirement.id,
                                                                'high_level_requirements')

    respond_to do |format|
      format.html { redirect_to item_high_level_requirements_url, notice: 'High level requirement was successfully removed.' }
      format.json { head :no_content }
    end
  end

  def export
    authorize :high_level_requirement
    # Get all high level requirements

    if session[:archives_visible].kind_of?(Integer)
      @high_level_requirements = HighLevelRequirement.where(item_id:      params[:item_id],
                                                            organization: current_user.organization,
                                                            archive_id:   session[:archives_visible])
    else
      @high_level_requirements = HighLevelRequirement.where(item_id:      params[:item_id],
                                                            organization: current_user.organization,
                                                            archive_id:   nil)
    end

    @high_level_requirements = sort_on_full_id(@high_level_requirements)

    respond_to do |format|
      if params[:hlr_export].try(:has_key?, :export_type) && params[:hlr_export][:export_type] == 'HTML'
        format.html { render "high_level_requirements/export_html", layout: false }
        format.json { render :show, status: :ok, location: @high_level_requirement }
      elsif params[:hlr_export].try(:has_key?, :export_type) && params[:hlr_export][:export_type] == 'PDF'
        format.html { redirect_to item_high_level_requirements_export_path(format: :pdf) }
      elsif params[:hlr_export].try(:has_key?, :export_type) && params[:hlr_export][:export_type] == 'CSV'
        # Come back here using the csv format to generate the csv below.
        format.html { redirect_to item_high_level_requirements_export_path(format: :csv) }
      elsif params[:hlr_export].try(:has_key?, :export_type) && params[:hlr_export][:export_type] == 'XLS'
        # Come back here using the xls format to generate the XLS below.
        format.html { redirect_to item_high_level_requirements_export_path(format: :xls) }
      elsif params[:hlr_export].try(:has_key?, :export_type) && params[:hlr_export][:export_type] == 'DOCX'
        # Come back here using the docx format to generate the docx below.
        if convert_data("High_Level_Requirements.docx",
                        'high_level_requirements/export_html.html.erb',
                         @item.present? ? @item.id : params[:item_id])
          format.html { redirect_to  item_high_level_requirements_export_path(filename: @converted_filename, format: :docx, starting_number: params[:md_export].try(:has_key?, :starting_number) ) }
        else
          flash[:error]  = @conversion_error
          params[:level] = 2

          go_back
        end
      else
        format.html { render :export }
        format.json { render json: @high_level_requirement.errors, status: :unprocessable_entity }
        # If redirected using format => csv, generate the csv here.
        format.csv  { send_data HighLevelRequirement.to_csv(@item.id), filename: "#{@item.name}-High_Level_Requirements.csv" }
        format.xls  { send_data HighLevelRequirement.to_xls(@item.id), filename: "#{@item.name}-High_Level_Requirements.xls" }
        format.pdf  {
                       @no_links = true

                       render(pdf:      "#{@project.name}-HighLevelRequirements",
                              template: 'high_level_requirements/export_html.html.erb',
                              title:    'High Level Requirements: Export PDF | PACT',
                              footer:   {
                                           right: '[page] of [topage]'
                                        })
                     }
        format.docx  {
                       return_file(params[:filename])
                     }
      end
    end
  end

  def import_high_level_requirements
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
      result = HighLevelRequirement.from_file(filename, @item, check_download)

      if result == :duplicate_high_level_requirement
        if @project.errors.messages.empty?
          flash[:alert] = "File: #{file.original_filename} contains existing High Level Requirements. Choose Duplicates Permitted to import duplicates."
        end

        error           = true
      elsif result == :system_requirement_associations_changed
        if @project.errors.messages.empty?
          flash[:alert] = "File: #{file.original_filename} changes associations to System Requirements. Choose Association Changes Permitted to import records with changed associations."
        end

        error           = true
      elsif result == :high_level_requirement_associations_changed
        if @project.errors.messages.empty?
          flash[:alert] = "File: #{file.original_filename} changes associations to High Level Requirements. Choose Association Changes Permitted to import records with changed associations."
        end

        error           = true
      end
    end

    if !error
      unless HighLevelRequirement.from_file(filename, @item)
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
    authorize :high_level_requirement

    if params[import_path].present?
      if import_high_level_requirements
        respond_to do |format|
          format.html {redirect_to item_high_level_requirements_path(@item), notice: 'High level requirements were successfully imported.' }
          format.json { head :no_content }
        end
      else
        respond_to do |format|
          format.html { redirect_to item_high_level_requirements_import_path(@item) }
          format.json { render json: @item.errors, status: :unprocessable_entity }
        end
      end
    else
      respond_to do |format|
        format.html { render :import }
        format.json { render json: @high_level_requirement.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /high_level_requirements/renumber
  def renumber
    authorize :high_level_requirement

    if params[:hlr_renumber].try(:has_key?, :start)         &&
       params[:hlr_renumber][:start]     =~/^\d+$/          &&
       params[:hlr_renumber].try(:has_key?, :increment)     &&
       params[:hlr_renumber][:increment] =~/^\d+$/          &&
       params[:hlr_renumber].try(:has_key?, :leading_zeros) &&
       params[:hlr_renumber][:leading_zeros] =~/^\d+$/
      HighLevelRequirement.renumber(@item.id,
                                    params[:hlr_renumber][:start].to_i,
                                    params[:hlr_renumber][:increment].to_i,
                                    @item.high_level_requirements_prefix,
                                    params[:hlr_renumber][:leading_zeros].to_i)

      respond_to do |format|
        format.html {redirect_to item_high_level_requirements_path(@item), notice: 'High level requirements were successfully renumbered.' }
        format.json { head :no_content }
      end
    end
  end

  # GET /high_level_requirements/1/mark_as_deleted/
  # GET /high_level_requirements/1/mark_as_deleted.json
  def mark_as_deleted
    authorize @high_level_requirement

    @high_level_requirement.soft_delete = true
    @data_change                        = DataChange.save_or_destroy_with_undo_session(@high_level_requirement,
                                                                                       'update',
                                                                                       @high_level_requirement.id,
                                                                                       'high_level_requirements')

    if @data_change.present?
      respond_to do |format|
        format.html { redirect_to item_high_level_requirements_url, notice: 'High level requirement was successfully marked as deleted.' }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html { render :edit, error: 'Could not delete high level requirement'}
        format.json { render json: @high_level_requirement.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_high_level_requirement
      if params[:id].present?
        @high_level_requirement = HighLevelRequirement.find(params[:id])
      elsif params[:high_level_requirement_id]
        @high_level_requirement = HighLevelRequirement.find(params[:high_level_requirement_id])
      end
    end

    # Delete image
    def delete_image
      @high_level_requirement.image.purge
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def high_level_requirement_params
      params.require(
                       :high_level_requirement)
            .permit(
                       :reqid,
                       :full_id,
                       :description,
                       :category,
                       :safety,
                       :robustness,
                       :derived,
                       :testmethod,
                       :image,
                       :remove_image,
                       :version,
                       :item_id,
                       :project_id,
                       :derived_justification,
                       :system_requirement_associations,
                       :high_level_requirement_associations,
                       :full_id_prefix,
                       :document_id,
                       :model_file_id,
                       :upload_file,
                       :archive_type,
                       system_requirement_associations: [],
                       verification_method: [],
                       low_level_requirement_ids: [])
    end
end
