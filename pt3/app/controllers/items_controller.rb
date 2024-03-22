class ItemsController < ApplicationController
  include Common

  respond_to    :docx

  before_action :set_item, only: [:show, :edit, :update, :destroy, :export, :get_checklists]
  before_action :get_project_byparam
  before_action :get_projects, only: [:new, :edit, :update]

  # GET /items
  # GET /items.json
  def index
    authorize :item

    if session[:archives_visible]
      @items   = Item.where(project_id:   params[:project_id],
                            organization: current_user.organization)
    else
      @items   = Item.where(project_id:   params[:project_id],
                            organization: current_user.organization,
                            archive_id:  nil)
    end

    if params[:filter_field].present? && params[:filter_value]
      session[:item_filter_field] = params[:filter_field]
      session[:item_filter_value] = params[:filter_value]
      @items                      = @items.to_a.delete_if do |item|
        field                     = item.attributes[params[:filter_field]].upitem
        value                     = params[:filter_value].upitem

        !field.index(value)
      end
    end

    @project   = Project.find_by(id: params[:project_id])
    @undo_path = get_undo_path('items', project_items_path(@project))
    @redo_path = get_redo_path('items', project_items_path(@project))
  end

  # GET /items/1
  # GET /items/1.json
  def show
    authorize :item
    # Get the project for this item.
    @project   = Project.find_by(id: @item.project_id)
    @undo_path = get_undo_path('items', project_items_path(@project))
    @redo_path = get_redo_path('items', project_items_path(@project))
  end

  # GET /items/new
  def new
    authorize :item

    @baselined                           = false
    @item                                = Item.new
    @item.project_id                     = @project.id
    @item.high_level_requirements_prefix = @project.high_level_requirements_prefix
    @item.low_level_requirements_prefix  = @project.low_level_requirements_prefix
    @item.source_code_prefix             = @project.source_code_prefix
    @item.model_file_prefix              = @project.model_file_prefix
    @item.test_case_prefix               = @project.test_case_prefix
    @item.test_procedure_prefix          = @project.test_procedure_prefix
  end

  # GET /items/1/edit
  def edit
    authorize @item

    @baselined = Archive.archived(object:        @item,
                                  project_id:    @project.id,
                                  archive_types: [
                                                    Constants::HIGH_LEVEL_REQUIREMENTS_ARCHIVE,
                                                    Constants::LOW_LEVEL_REQUIREMENTS_ARCHIVE,
                                                    Constants::SOURCE_CODE_ARCHIVE,
                                                    Constants::TEST_CASE_ARCHIVE,
                                                    Constants::TEST_PROCEDURE_ARCHIVE
                                                 ])
    @undo_path = get_undo_path('items', project_items_path(@project))
    @redo_path = get_redo_path('items', project_items_path(@project))
  end

  # POST /items
  # POST /items.json
  def create
    authorize :item
    @projects = Project.all

    params[:item][:project_id] = @project.id if !item_params[:project_id].present? && @project.present?
    @item                      = Item.new(item_params)

    respond_to do |format|
      @data_change             = DataChange.save_or_destroy_with_undo_session(@item, 'create')

      if @data_change.present?
        @item.duplicate_documents(@data_change.session_id)

        format.html { redirect_to [@project, @item], notice: 'Item was successfully created.' }
        format.json { render :show, status: :created, location: [@project, @item] }
      else
        format.html { render :new }
        format.json { render json: @item.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /items/1
  # PATCH/PUT /items/1.json
  def update
    authorize @item

    old_high_level_requirements_prefix = @item.high_level_requirements_prefix
    old_low_level_requirements_prefix  = @item.low_level_requirements_prefix
    old_model_files_prefix             = @item.model_file_prefix
    old_source_codes_prefix            = @item.source_code_prefix
    old_test_cases_prefix              = @item.test_case_prefix
    old_test_procedures_prefix         = @item.test_procedure_prefix
    params[:item][:project_id]         = @project.id      if !item_params[:project_id].present? &&
                                                              @project.present?
    params[:item][:identifier]         = @item.identifier if !item_params[:identifier].present? &&
                                                              @item.identifier.present?
    new_high_level_requirements_prefix = if item_params[:high_level_requirements_prefix].present?
                                           item_params[:high_level_requirements_prefix]
                                         else
                                           @item.high_level_requirements_prefix
                                         end
    new_low_level_requirements_prefix  = if item_params[:low_level_requirements_prefix].present?
                                           item_params[:low_level_requirements_prefix]
                                         else
                                           @item.low_level_requirements_prefix
                                         end
    new_model_files_prefix             = if item_params[:model_file_prefix].present?
                                           item_params[:model_file_prefix]
                                         else
                                           @item.model_file_prefix
                                         end
    new_source_codes_prefix            = if item_params[:source_code_prefix].present?
                                           item_params[:source_code_prefix]
                                         else
                                           @item.source_code_prefix
                                         end
    new_test_cases_prefix              = if item_params[:test_case_prefix].present?
                                           item_params[:test_case_prefix]
                                         else
                                           @item.test_case_prefix
                                         end
    new_test_procedures_prefix         = if item_params[:test_procedure_prefix].present?
                                           item_params[:test_procedure_prefix]
                                         else
                                           @item.test_procedure_prefix
                                         end

    respond_to do |format|
      @data_change                     = DataChange.save_or_destroy_with_undo_session(item_params,
                                                                                      'update',
                                                                                      params[:id],
                                                                                      'items')

      if @data_change.present?
        session_id = @data_change.session_id

        if old_high_level_requirements_prefix != new_high_level_requirements_prefix
          HighLevelRequirement.rename_prefix(@project.id,
                                             @item.id,
                                             old_high_level_requirements_prefix,
                                             new_high_level_requirements_prefix,
                                             session_id)
        end

        if old_low_level_requirements_prefix != new_low_level_requirements_prefix
          LowLevelRequirement.rename_prefix(@project.id,
                                             @item.id,
                                             old_low_level_requirements_prefix,
                                             new_low_level_requirements_prefix,
                                             session_id)
        end

        if old_model_files_prefix != new_model_files_prefix
          ModelFile.rename_prefix(@project.id,
                                  @item.id,
                                  old_model_files_prefix,
                                  new_model_files_prefix,
                                  session_id)
        end

        if old_source_codes_prefix != new_source_codes_prefix
          SourceCode.rename_prefix(@project.id,
                                   @item.id,
                                   old_source_codes_prefix,
                                   new_source_codes_prefix,
                                   session_id)
        end

        if old_test_cases_prefix != new_test_cases_prefix
          TestCase.rename_prefix(@project.id,
                                 @item.id,
                                 old_test_cases_prefix,
                                 new_test_cases_prefix,
                                 session_id)
        end

        if old_test_procedures_prefix != new_test_procedures_prefix
          TestProcedure.rename_prefix(@project.id,
                                      @item.id,
                                      old_test_procedures_prefix,
                                      new_test_procedures_prefix,
                                      session_id)
        end

        format.html { redirect_to [@project, @item], notice: 'Item was successfully updated.' }
        format.json { render :show, status: :ok, location: [@project, @item] }
      else
        format.html { render :edit }
        format.json { render json: @item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /items/1
  # DELETE /items/1.json
  def destroy
    authorize @item

    @data_change = DataChange.save_or_destroy_with_undo_session(@item, 'delete')

    respond_to do |format|
      format.html { redirect_to project_items_url, notice: 'Item was successfully removed.' }
      format.json { head :no_content }
    end
  end

  def export
    authorize :item

    # Get all system requirements
    if session[:archives_visible]
      @sysreqs_all = SystemRequirement.where(project_id:   @project.id,
                                             organization: current_user.organization)
    else
      @sysreqs_all = SystemRequirement.where(project_id:   @project.id,
                                             organization: current_user.organization,
                                             archive_id:  nil)
    end

    @sysreqs_all = sort_on_full_id(@sysreqs_all)

    # Get all HLRs for this item.
    if session[:archives_visible]
      @hlrs_all = HighLevelRequirement.where(item_id:      @item.id,
                                             organization: current_user.organization)
    else
      @hlrs_all = HighLevelRequirement.where(item_id:      @item.id,
                                             organization: current_user.organization,
                                             archive_id:  nil)
    end

    @hlrs_all = sort_on_full_id(@hlrs_all)

    # Get all LLRs for this item.
    if session[:archives_visible]
      @llrs_all = LowLevelRequirement.where(item_id: @item.id,
                                            organization: current_user.organization)
    else
      @llrs_all = LowLevelRequirement.where(item_id: @item.id,
                                            organization: current_user.organization,
                                            archive_id: nil)
    end

    @llrs_all = sort_on_full_id(@llrs_all)

    # Get all Test Cases for this item.
    if session[:archives_visible]
      @tcs_all = TestCase.where(item_id:      @item.id,
                                organization: current_user.organization)
    else
      @tcs_all = TestCase.where(item_id:      @item.id,
                                organization: current_user.organization,
                                archive_id:  nil)
    end

    @tcs_all = sort_on_full_id(@tcs_all)

    # Get all Source Codes for this item.
    if session[:archives_visible]
      @scs_all = SourceCode.where(item_id: @item.id,
                                  organization: current_user.organization)
    else
      @scs_all = SourceCode.where(item_id: @item.id,
                                  organization: current_user.organization,
                                  archive_id: nil)
    end

    @scs_all = sort_on_full_id(@scs_all)

    # Get all code LLR tags. TODO
    respond_to do |format|
      if params[:item_export].try(:has_key?, :export_type) && params[:item_export][:export_type] == 'HTML'
        format.html { render "items/export_html", layout: false }
        format.json { render :show, status: :ok, location: @item }
      elsif params[:item_export].try(:has_key?, :export_type) && params[:item_export][:export_type] == 'PDF'
        format.html { redirect_to project_item_export_path(@project.id, @item.id, format: :pdf) }
      elsif params[:item_export].try(:has_key?, :export_type) && params[:item_export][:export_type] == 'CSV'
        # Come back here using the csv format to generate the csv below.
        format.html { redirect_to project_item_export_path(@project.id, @item.id, format: :csv) }
      elsif params[:item_export].try(:has_key?, :export_type) && params[:item_export][:export_type] == 'XLS'
        # Come back here using the xls format to generate the xls below.
        format.html { redirect_to project_item_export_path(@project.id, @item.id, format: :xls) }
      elsif params[:item_export].try(:has_key?, :export_type) && params[:item_export][:export_type] == 'DOCX'
        # Come back here using the docx format to generate the docx below.
        if convert_data("Items.docx",
                        'items/export_html.html.erb',
                         @item.present? ? @item.id : params[:item_id])
          format.html { redirect_to  items_level_requirements_export_path(filename: @converted_filename, format: :docx, starting_number: params[:md_export].try(:has_key?, :starting_number) ) }
        else
          flash[:error]  = @conversion_error
          params[:level] = 2

          go_back
        end
    else
        format.html { render :export }
        format.json { render json: @item.errors, status: :unprocessable_entity }
        # If redirected using format => csv, generate the csv here.
        format.csv  { send_data Item.to_csv(@project.id), filename: "#{@project.name}-Items.csv" }
        format.xls  { send_data Item.to_xls(@project.id), filename: "#{@project.name}-Items.xls" }
        format.pdf  { render pdf: "#{@project.name}-System_Requirements", template: 'items/export_html.html.erb', footer: { right: '[page] of [topage]' } }
        format.docx {
                       return_file(params[:filename])
                    }
      end
    end
  end


  # GET /templates/get_checklists/:item_type(.:format)
  def get_checklists
    authorize @item

    @template_checklists = TemplateChecklist.get_checklists(@item.itemtype,
                                                            params[:review_type],
                                                            true)

    respond_to do |format|
      format.html {
        if @error.present?
          render :nothing => true, :status => 500, :content_type => 'text/html'
        else
          render plain: @template_checklists, :status => 200, :content_type => 'text/html'
        end
      }

      format.json {
        if @error.present?
          render :json => { error: @error }, :status => 500
        else
          render :json => { template_checklists: @template_checklists.to_json }, :status => 200
        end
      }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_item
      @item = if params[:id].present?
                Item.find(params[:id])
              elsif params[:item_id].present?
                Item.find(params[:item_id])
              end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def item_params
      params.require(
                       :item
                    ).
             permit(
                       :name,
                       :itemtype,
                       :identifier,
                       :level,
                       :high_level_requirements_prefix,
                       :low_level_requirements_prefix,
                       :model_file_prefix,
                       :source_code_prefix,
                       :test_case_prefix,
                       :test_procedure_prefix,
                       :project_id
                   )
    end
end
