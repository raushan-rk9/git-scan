class TestCasesController < ApplicationController
  include Common

  respond_to    :docx

  before_action :set_test_case, only: [:show, :edit, :update, :destroy, :mark_as_deleted]
  before_action :get_item
  before_action :get_items, only: [:new, :edit, :update]
  before_action :get_project_fromitemid
  before_action :get_projects, only: [:new, :edit, :update]
  before_action :set_session
  skip_before_action :verify_authenticity_token, only: [:update]

  # GET /test_cases
  # GET /test_cases.json
  def index
    authorize :test_case

    if params[:item_id] =~ /^\d+,\d.*$/
      ids                       = params[:item_id].split(',')
      @test_cases               = []

      ids.each do |id|
        if session[:archives_visible]
          test_cases            = TestCase.where(item_id:      id,
                                                 organization: current_user.organization)
        else
          test_cases            = TestCase.where(item_id:      id,
                                                 organization: current_user.organization,
                                                 archive_id:  nil)
        end

        @test_cases            += test_cases.to_a
      end
    else
      if session[:archives_visible]
        @test_cases             = TestCase.where(item_id:      params[:item_id],
                                                 organization: current_user.organization)
      else
        @test_cases             = TestCase.where(item_id:      params[:item_id],
                                                 organization: current_user.organization,
                                                 archive_id:  nil)
      end
    end

    @test_cases                 = sort_on_full_id(@test_cases)

    if params[:filter_field].present? && params[:filter_value]
      session[:tc_filter_field] = params[:filter_field]
      session[:tc_filter_value] = params[:filter_value]
      @test_cases               = @test_cases.to_a.delete_if do |test_case|
        field                   = test_case.attributes[params[:filter_field]].to_s.upcase
        value                   = params[:filter_value].upcase

        !field.index(value)
      end
    end

    @undo_path                  = get_undo_path('test_cases', item_test_cases_path(@item))
    @redo_path                  = get_redo_path('test_cases', item_test_cases_path(@item))
  end

  # GET /test_cases/1
  # GET /test_cases/1.json
  def show
    authorize :test_case

    # Get the item.
    @item            = Item.find_by(id: @test_case.item_id)
    @undo_path       = get_undo_path('test_cases', item_test_cases_path(@item))
    @redo_path       = get_redo_path('test_cases', item_test_cases_path(@item))

    if session[:archives_visible]
      @test_case_ids = TestCase.where(item_id:      @item.id,
                                      organization: current_user.organization).order(:full_id).pluck(:id)
    else
      @test_case_ids = TestCase.where(item_id:      @item.id,
                                      organization: current_user.organization,
                                      archive_id:  nil).order(:full_id).pluck(:id)
    end
  end

  # GET /test_cases/new
  def new
    authorize :test_case
    @test_case               = TestCase.new
    @test_case.item_id       = @item.id
    @test_case.project_id    = @project.id
    maximium_caseid          = TestCase.where(item_id: @item.id).maximum(:caseid)
    @test_case.caseid        = maximium_caseid.present? ? maximium_caseid + 1 : 1
    # Initial version counter value is 1.
    @test_case.version       = increment_int(@test_case.version)
    @high_level_requirements = sort_on_full_id(HighLevelRequirement.where(item_id: @item.id).order(:full_id))
    @low_level_requirements  = sort_on_full_id(LowLevelRequirement.where(item_id: @item.id).order(:full_id))
    @undo_path               = get_undo_path('test_cases',
                                             item_test_cases_path(@item))
    @redo_path               = get_redo_path('test_cases',
                                             item_test_cases_path(@item))
    @pact_files              = get_model_file_list(@test_case.project_id,
                                                   @test_case.item_id)
    @high_level_requirements = @high_level_requirements.delete_if {|hlr| hlr.soft_delete }
    @low_level_requirements  = @low_level_requirements.delete_if  {|llr| llr.soft_delete }
  end

  # GET /test_cases/1/edit
  def edit
    authorize @test_case
    # Increment the version counter if edited.
    @test_case.version       = increment_int(@test_case.version)
    @high_level_requirements = sort_on_full_id(HighLevelRequirement.where(item_id: @item.id).order(:full_id))
    @low_level_requirements  = sort_on_full_id(LowLevelRequirement.where(item_id: @item.id).order(:full_id))
    @undo_path               = get_undo_path('test_cases',
                                             item_test_cases_path(@item))
    @redo_path               = get_redo_path('test_cases',
                                             item_test_cases_path(@item))
    @pact_files              = get_model_file_list(@test_case.project_id,
                                                   @test_case.item_id)
    high_level_associations  = if @test_case.high_level_requirement_associations.present?
                                 if @test_case.high_level_requirement_associations.kind_of?(String)
                                   @test_case.high_level_requirement_associations.split(',')
                                 else
                                   @test_case.high_level_requirement_associations.reject { |x| x.empty? }
                                 end
                               else
                                  []
                               end
    low_level_associations   = if @test_case.low_level_requirement_associations.present?
                                 if @test_case.low_level_requirement_associations.kind_of?(String)
                                   @test_case.low_level_requirement_associations.split(',')
                                 else
                                   @test_case.low_level_requirement_associations.reject { |x| x.empty? }
                                 end
                               else
                                  []
                               end

    @high_level_requirements = @high_level_requirements.delete_if {|hlr| hlr.soft_delete }
    @low_level_requirements  = @low_level_requirements.delete_if  {|llr| llr.soft_delete }

    @high_level_requirements.each { |hlr| hlr.selected = high_level_associations.include?(hlr.id.to_s) } if @high_level_requirements.present?
    @low_level_requirements.each  { |llr| llr.selected = low_level_associations.include?(llr.id.to_s) }  if @low_level_requirements.present?

    if session[:archives_visible]
      @test_case_ids         = TestCase.where(item_id:      @item.id,
                                              organization: current_user.organization).order(:full_id).pluck(:id)
    else
      @test_case_ids         = TestCase.where(item_id:      @item.id,
                                              organization: current_user.organization,
                                              archive_id:  nil).order(:full_id).pluck(:id)
    end
  end

  # POST /test_cases
  # POST /test_cases.json
  def create
    authorize :test_case

    session_id                      = nil
    params[:test_case][:project_id] = @project.id if !test_case_params[:project_id].present? && @project.present?
    params[:test_case][:item_id]    = @item.id    if !test_case_params[:item_id].present?    && @item.present?
    @test_case                      = TestCase.new(test_case_params)
    @test_case.model_file_id        = nil if @test_case.model_file_id.to_s == "-1"

    respond_to do |format|
      # Check to see if the Case ID already Exists.
      if TestCase.find_by(caseid: @test_case.caseid,
                          item_id: @test_case.item_id)
        @test_case.errors.add(:caseid, :blank, message: "Duplicate ID: #{@test_case.caseid}") 

        format.html { render :new }
        format.json { render json: @test_case.errors, status: :unprocessable_entity }
      elsif TestCase.find_by(full_id: @test_case.full_id,
                             item_id: @test_case.item_id)
        @test_case.errors.add(:full_id, :blank, message: "Duplicate ID: #{@test_case.full_id}") 

        format.html { render :new }
        format.json { render json: @test_case.errors, status: :unprocessable_entity }
      else
        session_id                  = ChangeSession.get_session_id
        @data_change                = DataChange.save_or_destroy_with_undo_session(@test_case,
                                                                                   'create',
                                                                                   @test_case.id,
                                                                                   'test_cases',
                                                                                   session_id)

        if @data_change.present?
          if Associations.build_associations(@test_case) &&
             test_case_params[:upload_file].present?
            @test_case.add_model_document(test_case_params[:upload_file],
                                          @data_change.session_id)
          end

          # Increment the global counter, and save the item.
          @item.tc_count           += 1

          DataChange.save_or_destroy_with_undo_session(@item,
                                                       'update',
                                                       @item.id,
                                                       'items',
                                                       session_id)

          format.html { redirect_to [@item, @test_case], notice: 'Test case was successfully created.' }
          format.json { render :show, status: :created, location: [@item, @test_case] }
        else
          format.html { render :new }
          format.json { render json: @test_case.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # PATCH/PUT /test_cases/1
  # PATCH/PUT /test_cases/1.json
  def update
    authorize @test_case

    session_id                               = nil
    params[:test_case][:project_id]          = @project.id if !test_case_params[:project_id].present? && @project.present?
    params[:test_case][:item_id]             = @item.id    if !test_case_params[:item_id].present?    && @item.present?

    respond_to do |format|
      # Check to see if the Case ID already Exists.
      new_id = test_case_params[:caseid].to_i

      if (new_id != @test_case.caseid) &&
         TestCase.find_by(caseid:   new_id,
                                   item_id: @test_case.item_id)
        @test_case.errors.add(:caseid, :blank, message: "Duplicate ID: #{@test_case.caseid}") 

        format.html { render :new }
        format.json { render json: @test_case.errors, status: :unprocessable_entity }
      else
        session_id                           = ChangeSession.get_session_id
        @data_change                         = DataChange.save_or_destroy_with_undo_session(params['test_case'],
                                                                                            'update',
                                                                                             params[:id],
                                                                                            'test_cases',
                                                                                            session_id)

        if @data_change.present?
          if Associations.build_associations(@test_case) &&
             test_case_params[:upload_file].present?
            @test_case.add_model_document(test_case_params[:upload_file],
                                          @data_change.session_id)
          end

          format.html { redirect_to item_test_case_path(@item.id, @test_case.id, previous_mode: 'editing'), notice: "#{I18n.t('misc.test_case')} was successfully updated." }
          format.json { render :show, status: :ok, location: [@item, @test_case] }
        else
          format.html { render :edit }
          format.json { render json: @test_case.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /test_cases/1
  # DELETE /test_cases/1.json
  def destroy
    authorize @test_case

    @data_change = DataChange.save_or_destroy_with_undo_session(@test_case,
                                                                'delete',
                                                                @test_case.id,
                                                                'test_cases')

    respond_to do |format|
      format.html { redirect_to item_test_cases_url, notice: 'Test case was successfully removed.' }
      format.json { head :no_content }
    end
  end

  def export
    authorize :test_case

    # Get all Test Case requirements
    @test_cases = if session[:archives_visible].kind_of?(Integer)
                    TestCase.where(item_id:    params[:item_id],
                                   archive_id: session[:archives_visible]).order(:full_id)
                  else
                    TestCase.where(item_id:    params[:item_id],
                                   archive_id: nil).order(:full_id)
                  end

    respond_to do |format|
      if params[:tc_export].try(:has_key?, :export_type) && params[:tc_export][:export_type] == 'HTML'
        format.html { render "test_cases/export_html", layout: false }
        format.json { render :show, status: :ok, location: @test_case }
      elsif params[:tc_export].try(:has_key?, :export_type) && params[:tc_export][:export_type] == 'PDF'
        format.html { redirect_to item_test_cases_export_path(format: :pdf) }
      elsif params[:tc_export].try(:has_key?, :export_type) && params[:tc_export][:export_type] == 'CSV'
        # Come back here using the csv format to generate the csv below.
        format.html { redirect_to item_test_cases_export_path(format: :csv) }
      elsif params[:tc_export].try(:has_key?, :export_type) && params[:tc_export][:export_type] == 'XLS'
        # Come back here using the xls format to generate the xls below.
        format.html { redirect_to item_test_cases_export_path(format: :xls) }
      elsif params[:tc_export].try(:has_key?, :export_type) && params[:tc_export][:export_type] == 'DOCX'
        # Come back here using the docx format to generate the docx below.
        if convert_data("Test_Cases.docx",
                        'test_cases/export_html.html.erb',
                         @item.present? ? @item.id : params[:item_id])
          format.html { redirect_to  item_test_cases_export_path(filename: @converted_filename, format: :docx, starting_number: params[:md_export].try(:has_key?, :starting_number) ) }
        else
          if @conversion_error.present?
            error                        = @conversion_error.clone
            flash[:error]                = error
            session[:application_errors] = [ error ]
          end

          format.html { render :export }
          format.json { render json: @test_case.errors, status: :unprocessable_entity }
        end
      else
        format.html { render :export }
        format.json { render json: @test_case.errors, status: :unprocessable_entity }
        # If redirected using format => csv, generate the csv here.
        format.csv  { send_data TestCase.to_csv(@item.id), filename: "#{@item.name}-Test_Cases.csv" }
        format.xls  { send_data TestCase.to_xls(@item.id), filename: "#{@item.name}-Test_Cases.xls" }
        format.pdf  {
                       @no_links = true

                       render(pdf:      "#{@project.name}-TestCases",
                              template: 'test_cases/export_html.html.erb',
                              title:    'Test Cases: Export PDF | PACT',
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

  def import_test_cases
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
      result = TestCase.from_file(filename, @item, check_download)

      if result == :duplicate_test_case
        if @project.errors.messages.empty?
          flash[:alert] = "File: #{file.original_filename} contains existing Test Cases. Choose Duplicates Permitted to import duplicates."
        end

        error           = true
      elsif result == :test_case_associations_changed
        if @project.errors.messages.empty?
          flash[:alert] = "File: #{file.original_filename} changes associations to High or low Level Requirements. Choose Association Changes Permitted to import records with changed associations."
        end

        error           = true
      end
    end

    if !error
      unless TestCase.from_file(filename, @item)
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
    authorize :test_case

    if params[import_path].present?
      if import_test_cases
        respond_to do |format|
          format.html {redirect_to item_test_cases_path(@item), notice: 'Test Case requirements were successfully imported.' }
          format.json { head :no_content }
        end
      else
        respond_to do |format|
          format.html { redirect_to item_test_cases_import_path(@item) }
          format.json { render json: @item.errors, status: :unprocessable_entity }
        end
      end
    else
      respond_to do |format|
        format.html { render :import }
        format.json { render json: @test_case.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /test_cases/renumber
  def renumber
    authorize :test_case

    if params[:tc_renumber].try(:has_key?, :start)     &&
       params[:tc_renumber][:start]     =~/^\d+$/      &&
       params[:tc_renumber].try(:has_key?, :increment) &&
       params[:tc_renumber][:increment] =~/^\d+$/      &&
       params[:tc_renumber][:leading_zeros] =~/^\d+$/
      TestCase.renumber(@item.id, 
                        params[:tc_renumber][:start].to_i,
                        params[:tc_renumber][:increment].to_i,
                        @item.test_case_prefix,
                        params[:tc_renumber][:leading_zeros].to_i)
  
      respond_to do |format|
        format.html {redirect_to item_test_cases_path(@item), notice: 'Test Cases were successfully renumbered.' }
        format.json { head :no_content }
      end
    end
  end

  # GET /test_cases/1/mark_as_deleted/
  # GET /test_cases/1/mark_as_deleted.json
  def mark_as_deleted
    authorize @test_case

    @test_case.soft_delete = true
    @data_change           = DataChange.save_or_destroy_with_undo_session(@test_case,
                                                                          'update',
                                                                          @test_case.id,
                                                                          'test_cases')

    if @data_change.present?
      respond_to do |format|
        format.html { redirect_to item_test_cases_url, notice: 'Test case was successfully marked as deleted.' }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html { render :edit, error: 'Could not delete test case'}
        format.json { render json: @test_case.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_test_case
      if params[:id].present? && params[:id] =~ /\d+/
        @test_case = TestCase.find(params[:id])
      elsif params[:test_case_id] && params[:test_case_id] =~ /\d+/
        @test_case = TestCase.find(params[:test_case_id])
      end
    end

    # Delete image
    def delete_image
      @test_case.image.purge
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def test_case_params
      params.require(
                       :test_case
                    )
            .permit(
                       :caseid,
                       :full_id,
                       :description,
                       :procedure,
                       :image,
                       :remove_image,
                       :category,
                       :robustness,
                       :derived,
                       :testmethod,
                       :version,
                       :item_id,
                       :project_id,
                       :derived_justification,
                       :document_id,
                       :model_file_id,
                       :upload_file,
                       :high_level_requirement_associations,
                       :low_level_requirement_associations,
                       high_level_requirement_associations: [],
                       low_level_requirement__associations: []
                   )
    end
end
