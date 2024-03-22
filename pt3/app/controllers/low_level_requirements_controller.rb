class LowLevelRequirementsController < ApplicationController
  include Common

  respond_to    :docx

  before_action :set_low_level_requirement, only: [:show, :edit, :update, :destroy, :mark_as_deleted]
  before_action :get_item
  before_action :get_items, only: [:new, :edit, :update]
  before_action :get_project_fromitemid
  before_action :get_projects, only: [:new, :edit, :update]
  before_action :set_session
  skip_before_action :verify_authenticity_token, only: [:update]

  # GET /low_level_requirements
  # GET /low_level_requirements.json
  def index
    authorize :low_level_requirement

    if params[:item_id] =~ /^\d+,\d.*$/
      ids                     = params[:item_id].split(',')
      @low_level_requirements = []

      ids.each do |id|
        if session[:archives_visible]
          low_level_requirements = LowLevelRequirement.where(item_id:      id,
                                                             organization: current_user.organization)
        else
          low_level_requirements = LowLevelRequirement.where(item_id:      id,
                                                             organization: current_user.organization,
                                                             archive_id:  nil)
        end

        @low_level_requirements += low_level_requirements.to_a
      end
    else
      if session[:archives_visible]
        @low_level_requirements = LowLevelRequirement.where(item_id:      params[:item_id],
                                                            organization: current_user.organization)
      else
        @low_level_requirements = LowLevelRequirement.where(item_id:      params[:item_id],
                                                            organization: current_user.organization,
                                                            archive_id:  nil)
      end
    end

    if params[:filter_field].present? && params[:filter_value]
      session[:llr_filter_field] = params[:filter_field]
      session[:llr_filter_value] = params[:filter_value]
      @low_level_requirements    = @low_level_requirements.to_a.delete_if do |low_level_requirement|
        field                    = low_level_requirement.attributes[params[:filter_field]].to_s.upcase
        value                    = params[:filter_value].upcase

        !field.index(value)
      end
    end

    @low_level_requirements   = sort_on_full_id(@low_level_requirements)
    @undo_path                = get_undo_path('low_level_requirements',
                                              item_low_level_requirements_path(@item))
    @redo_path                = get_redo_path('low_level_requirements',
                                              item_low_level_requirements_path(@item))
  end

  # GET /low_level_requirements/1
  # GET /low_level_requirements/1.json
  def show
    authorize :low_level_requirement
    # Get the item for this low level requirement.
    @item = Item.find_by(id: @low_level_requirement.item_id)
    @undo_path = get_undo_path('low_level_requirements',
                                item_low_level_requirements_path(@item))
    @redo_path = get_redo_path('low_level_requirements',
                                item_low_level_requirements_path(@item))

    if session[:archives_visible]
      @low_level_requirement_ids = LowLevelRequirement.where(item_id:      @item.id,
                                                             organization: current_user.organization).order(:full_id).pluck(:id)
    else
      @low_level_requirement_ids = LowLevelRequirement.where(item_id:      @item.id,
                                                             organization: current_user.organization,
                                                             archive_id:  nil).order(:full_id).pluck(:id)
    end
  end

  # GET /low_level_requirements/new
  def new
    authorize :low_level_requirement
    @low_level_requirement            = LowLevelRequirement.new
    @low_level_requirement.item_id    = @item.id
    @low_level_requirement.project_id = @project.id
    maximium_reqid                    = LowLevelRequirement.where(item_id: @item.id).maximum(:reqid)
    @low_level_requirement.reqid      = maximium_reqid.present? ? maximium_reqid + 1 : 1
    @pact_files                       = get_model_file_list(@low_level_requirement.project_id,
                                                            @low_level_requirement.item_id)

    # Initial version counter value is 1.
    @low_level_requirement.version    = increment_int(@low_level_requirement.version)
    @high_level_requirements          = sort_on_full_id(HighLevelRequirement.where(item_id: @item.id).order(:full_id))
    @high_level_requirements          = @high_level_requirements.delete_if {|hlr|    hlr.soft_delete }
  end

  # GET /low_level_requirements/1/edit
  def edit
    authorize @low_level_requirement

    @low_level_requirement.version = increment_int(@low_level_requirement.version)
    @undo_path                     = get_undo_path('low_level_requirements',
                                                   item_low_level_requirements_path(@item))
    @redo_path                     = get_redo_path('low_level_requirements',
                                                   item_low_level_requirements_path(@item))
    @high_level_requirements       = sort_on_full_id(HighLevelRequirement.where(item_id: @item.id).order(:full_id))
    @pact_files                    = get_model_file_list(@low_level_requirement.project_id,
                                                         @low_level_requirement.item_id)
    high_level_associations        = if @low_level_requirement.high_level_requirement_associations.present?
                                       if @low_level_requirement.high_level_requirement_associations.kind_of?(String)
                                         @low_level_requirement.high_level_requirement_associations.split(',')
                                       else
                                         @low_level_requirement.high_level_requirement_associations.reject { |x| x.empty? }
                                       end
                                     else
                                        []
                                     end

    @high_level_requirements     = @high_level_requirements.delete_if {|hlr|    hlr.soft_delete }

    @high_level_requirements.each { |hlr| hlr.selected = high_level_associations.include?(hlr.id.to_s) } if @high_level_requirements.present?

    if session[:archives_visible]
      @low_level_requirement_ids = LowLevelRequirement.where(item_id:      @item.id,
                                                             organization: current_user.organization).order(:full_id).pluck(:id)
    else
      @low_level_requirement_ids = LowLevelRequirement.where(item_id:      @item.id,
                                                             organization: current_user.organization,
                                                             archive_id:  nil).order(:full_id).pluck(:id)
    end
  end

  # POST /low_level_requirements
  # POST /low_level_requirements.json
  def create
    authorize :low_level_requirement

    session_id                                                   = nil
    params[:low_level_requirement][:project_id]                  = @project.id if !low_level_requirement_params[:project_id].present? && @project.present?
    params[:low_level_requirement][:item_id]                     = @item.id    if !low_level_requirement_params[:item_id].present?    && @item.present?
    @low_level_requirement                                       = LowLevelRequirement.new(low_level_requirement_params)
    @low_level_requirement.project_id                            = @project.id
    @low_level_requirement.model_file_id                         = nil if @low_level_requirement.model_file_id.to_s == "-1"

    respond_to do |format|
      # Check to see if the Requirement ID already Exists.
      if LowLevelRequirement.find_by(reqid:   @low_level_requirement.reqid,
                                      item_id: @low_level_requirement.item_id)
        @high_level_requirements                                 = sort_on_full_id(HighLevelRequirement.where(item_id: @item.id).order(:full_id))

        @low_level_requirement.errors.add(:reqid, :blank, message: "Duplicate ID: #{@low_level_requirement.reqid}") 
        format.html { render :new }
        format.json { render json: @LowLevelRequirement.errors, status: :unprocessable_entity }
      elsif LowLevelRequirement.find_by(full_id: @low_level_requirement.full_id,
                                        item_id: @low_level_requirement.item_id)
        @low_level_requirement.errors.add(:full_id, :blank, message: "Duplicate ID: #{@low_level_requirement.full_id}") 

        format.html { render :new }
        format.json { render json: @low_level_requirement.errors, status: :unprocessable_entity }
      else
        session_id                                               = ChangeSession.get_session_id
        @data_change                                             = DataChange.save_or_destroy_with_undo_session(@low_level_requirement,
                                                                                                                'create',
                                                                                                                @low_level_requirement.id,
                                                                                                                'low_level_requirements',
                                                                                                                session_id)

        if @data_change.present?
          if Associations.build_associations(@low_level_requirement) &&
             low_level_requirement_params[:upload_file].present?
            @low_level_requirement.add_model_document(low_level_requirement_params[:upload_file],
                                                       @data_change.session_id)
          end

          # Increment the global counter, and save the item.
          @item.llr_count += 1
          DataChange.save_or_destroy_with_undo_session(@item,
                                                       'update',
                                                       @item.id,
                                                       'items',
                                                       session_id)
          format.html { redirect_to [@item, @low_level_requirement], notice: 'Low level requirement was successfully created.' }
          format.json { render :show, status: :created, location: [@item, @low_level_requirement] }
        else
          format.html { render :new }
          format.json { render json: @low_level_requirement.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # PATCH/PUT /low_level_requirements/1
  # PATCH/PUT /low_level_requirements/1.json
  def update
    authorize @low_level_requirement

    session_id                                                                = nil
    params[:low_level_requirement][:project_id]                               = @project.id if !low_level_requirement_params[:project_id].present? && @project.present?
    params[:low_level_requirement][:item_id]                                  = @item.id    if !low_level_requirement_params[:item_id].present?    && @item.present?
    params[:low_level_requirement][:model_file_id]                            = nil         if  low_level_requirement_params[:model_file_id].to_s == "-1"

    respond_to do |format|
      new_id = low_level_requirement_params[:reqid].to_i

      if (new_id != @low_level_requirement.reqid) &&
         LowLevelRequirement.find_by(reqid:   new_id,
                                   item_id: @low_level_requirement.item_id)
        @low_level_requirement.errors.add(:reqid, :blank, message: "Duplicate ID: #{@low_level_requirement.reqid}") 
        format.html { render :new }
        format.json { render json: @low_level_requirement.errors, status: :unprocessable_entity }
      else
        session_id                                                            = ChangeSession.get_session_id
        @data_change                                                           = DataChange.save_or_destroy_with_undo_session(params['low_level_requirement'],
                                                                                                                              'update',
                                                                                                                              params[:id],
                                                                                                                              'low_level_requirements',
                                                                                                                              session_id)

        if @data_change.present?
          if Associations.build_associations(@low_level_requirement) &&
             low_level_requirement_params[:upload_file].present?
            @low_level_requirement.add_model_document(low_level_requirement_params[:upload_file],
                                                       @data_change.session_id)
          end
        end

        if @data_change.present?
          if @low_level_requirement.remove_image == "1" then
            delete_image
            @low_level_requirement.remove_image = "0"
          end
          format.html { redirect_to item_low_level_requirement_path(@item.id, @low_level_requirement.id, previous_mode: 'editing'), notice: "#{Item.item_type_title(@item, :low_level, :singular) } was successfully updated." }
          format.json { render :show, status: :ok, location: [@item, @low_level_requirement] }
        else
          format.html { render :edit }
          format.json { render json: @low_level_requirement.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /low_level_requirements/1
  # DELETE /low_level_requirements/1.json
  def destroy
    authorize @low_level_requirement

    @data_change = DataChange.save_or_destroy_with_undo_session(@low_level_requirement,
                                                                'delete',
                                                                @low_level_requirement.id,
                                                                'low_level_requirements')

    respond_to do |format|
      format.html { redirect_to item_low_level_requirements_url, notice: 'Low level requirement was successfully removed.' }
      format.json { head :no_content }
    end
  end

  def export
    authorize :low_level_requirement

    # Get all low level requirements
    if session[:archives_visible].kind_of?(Integer)
      @low_level_requirements = LowLevelRequirement.where(item_id:      params[:item_id],
                                                          organization: current_user.organization,
                                                          archive_id:   session[:archives_visible])
    else
      @low_level_requirements = LowLevelRequirement.where(item_id:      params[:item_id],
                                                          organization: current_user.organization,
                                                          archive_id:   nil)
    end
    
    @low_level_requirements = sort_on_full_id(@low_level_requirements)
    respond_to do |format|
      if params[:llr_export].try(:has_key?, :export_type) && params[:llr_export][:export_type] == 'HTML'
        format.html { render "low_level_requirements/export_html", layout: false }
        format.json { render :show, status: :ok, location: @low_level_requirement }
      elsif params[:llr_export].try(:has_key?, :export_type) && params[:llr_export][:export_type] == 'PDF'
        format.html { redirect_to item_low_level_requirements_export_path(format: :pdf) }
      elsif params[:llr_export].try(:has_key?, :export_type) && params[:llr_export][:export_type] == 'CSV'
        # Come back here using the csv format to generate the csv below.
        format.html { redirect_to item_low_level_requirements_export_path(format: :csv) }
      elsif params[:llr_export].try(:has_key?, :export_type) && params[:llr_export][:export_type] == 'XLS'
        # Come back here using the xls format to generate the xls below.
        format.html { redirect_to item_low_level_requirements_export_path(format: :xls) }
      elsif params[:llr_export].try(:has_key?, :export_type) && params[:llr_export][:export_type] == 'DOCX'
        # Come back here using the xls format to generate the xls below.
        if convert_data("Low_Level_Requirements.docx",
                        'low_level_requirements/export_html.html.erb',
                         @item.present? ? @item.id : params[:item_id])
          format.html { redirect_to  item_low_level_requirements_export_path(filename: @converted_filename, format: :docx, starting_number: params[:md_export].try(:has_key?, :starting_number) ) }
        else
          flash[:error]  = @conversion_error
          params[:level] = 2

          go_back
        end
      else
        format.html { render :export }
        format.json { render json: @low_level_requirement.errors, status: :unprocessable_entity }
        # If redirected using format => csv, generate the csv here.
        format.csv  { send_data LowLevelRequirement.to_csv(@item.id), filename: "#{@item.name}-Low_Level_Requirements.csv" }
        format.xls  { send_data LowLevelRequirement.to_xls(@item.id), filename: "#{@item.name}-Low_Level_Requirements.xls" }
        format.pdf  {
                       @no_links = true

                       render(pdf:      "#{@project.name}-LowLevelRequirements",
                              template: 'low_level_requirements/export_html.html.erb',
                              title:    'Low Level Requirements: Export PDF | PACT',
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

  def import_low_level_requirements
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
      result = LowLevelRequirement.from_file(filename, @item, check_download)

      if result == :duplicate_low_level_requirement
        if @project.errors.messages.empty?
          flash[:alert] = "File: #{file.original_filename} contains existing Low Level Requirements. Choose Duplicates Permitted to import duplicates."
        end

        error           = true
        elsif result == :low_level_requirement_associations_changed
        if @project.errors.messages.empty?
          flash[:alert] = "File: #{file.original_filename} changes associations to High Level Requirements. Choose Association Changes Permitted to import records with changed associations."
        end

        error           = true
      end
    end

    if !error
      unless LowLevelRequirement.from_file(filename, @item)
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
    authorize :low_level_requirement

    if params[import_path].present?
      if import_low_level_requirements
        respond_to do |format|
          format.html {redirect_to item_low_level_requirements_path(@item), notice: 'Low level requirements were successfully imported.' }
          format.json { head :no_content }
        end
      else
        respond_to do |format|
          format.html { redirect_to item_low_level_requirements_import_path(@item) }
          format.json { render json: @item.errors, status: :unprocessable_entity }
        end
      end
    else
      respond_to do |format|
        format.html { render :import }
        format.json { render json: @low_level_requirement.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /low_level_requirements/renumber
  def renumber
    authorize :low_level_requirement

    if params[:llr_renumber].try(:has_key?, :start)     &&
       params[:llr_renumber][:start]     =~/^\d+$/      &&
       params[:llr_renumber].try(:has_key?, :increment) &&
       params[:llr_renumber][:increment] =~/^\d+$/      &&
       params[:llr_renumber][:leading_zeros] =~/^\d+$/
      LowLevelRequirement.renumber(@item.id,
                                    params[:llr_renumber][:start].to_i,
                                    params[:llr_renumber][:increment].to_i,
                                    @item.low_level_requirements_prefix,
                                    params[:llr_renumber][:leading_zeros].to_i)
  
      respond_to do |format|
        format.html {redirect_to item_low_level_requirements_path(@item), notice: 'Low level requirements were successfully renumbered.' }
        format.json { head :no_content }
      end
    end
  end

  # GET /low_level_requirements/1/mark_as_deleted/
  # GET /low_level_requirements/1/mark_as_deleted.json
  def mark_as_deleted
    authorize @low_level_requirement

    @low_level_requirement.soft_delete = true
    @data_change                       = DataChange.save_or_destroy_with_undo_session(@low_level_requirement,
                                                                                      'update',
                                                                                      @low_level_requirement.id,
                                                                                      'low_level_requirements')

    if @data_change.present?
      respond_to do |format|
        format.html { redirect_to item_low_level_requirements_url, notice: 'Low level requirement was successfully marked as deleted.' }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html { render :edit, error: 'Could not delete low level requirement'}
        format.json { render json: @low_level_requirement.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_low_level_requirement
      if params[:id].present?
        @low_level_requirement = LowLevelRequirement.find(params[:id])
      elsif params[:low_level_requirement_id]
        @low_level_requirement = LowLevelRequirement.find(params[:low_level_requirement_id])
      end
    end

    # Delete image
    def delete_image
      @low_level_requirement.image.purge
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def low_level_requirement_params
      params.require(
                       :low_level_requirement
                    )
            .permit(
                       :reqid,
                       :full_id,
                       :category,
                       :module_description,
                       :description,
                       :derived,
                       :image,
                       :remove_image,
                       :version,
                       :item_id,
                       :project_id,
                       :derived_justification,
                       :high_level_requirement_associations,
                       :safety,
                       :full_id_prefix,
                       :selected,
                       :document_id,
                       :model_file_id,
                       :upload_file,
                       verification_method: [],
                       high_level_requirement_associations: []
                   )
    end
end
