class TestProceduresController < ApplicationController
  include Common

  respond_to    :docx

  before_action :set_test_procedure, only: [:show, :edit, :update, :destroy, :mark_as_deleted, :download_file, :display_file]
  before_action :get_item
  before_action :get_items, only: [:new, :edit, :update]
  before_action :get_project_fromitemid
  before_action :get_projects, only: [:new, :edit, :update]
  before_action :set_session
  skip_before_action :verify_authenticity_token, only: [:update]

  HTML_ESCAPE	=	{ "&" => "&amp;", ">" => "&gt;", "<" => "&lt;", '"' => "&quot;", "'" => "&#39;" }
  HTML_ESCAPE_ONCE_REGEXP	=	/["><']|&(?!([a-zA-Z]+|(#\d+)|(#[xX][\dA-Fa-f]+));)/

  # GET /test_procedures
  # GET /test_procedures.json
  def index
    authorize :test_procedure

    if session[:archives_visible]
      @test_procedures = TestProcedure.where(item_id:      params[:item_id],
                                             organization: current_user.organization)
    else
      @test_procedures = TestProcedure.where(item_id:      params[:item_id],
                                             organization: current_user.organization,
                                             archive_id:  nil)
    end

    if params[:filter_field].present? && params[:filter_value]
      session[:tp_filter_field] = params[:filter_field]
      session[:tp_filter_value] = params[:filter_value]
      @test_procedures          = @test_procedures.to_a.delete_if do |test_procedure|
        field                   = test_procedure.attributes[params[:filter_field]].to_s.upcase
        value                   = params[:filter_value].upcase

        !field.index(value)
      end
    end

    @test_procedures   = sort_on_full_id(@test_procedures)
    @undo_path         = get_undo_path('test_procedures', item_test_procedures_path(@item))
    @redo_path         = get_redo_path('test_procedures', item_test_procedures_path(@item))

    respond_to do |format|
        format.html { render :index }
        format.json { render json: @test_procedures }
    end
  end

  # GET /test_procedures/1
  # GET /test_procedures/1.json
  def show
    authorize :test_procedure

    # Get the item.
    @item                 = Item.find_by(id: @test_procedure.item_id)
    @undo_path            = get_undo_path('test_procedures', item_test_procedures_path(@item))
    @redo_path            = get_redo_path('test_procedures', item_test_procedures_path(@item))

    if session[:archives_visible]
      @test_procedure_ids = TestProcedure.where(item_id:      @item.id,
                                                organization: current_user.organization).order(:full_id).pluck(:id)
    else
      @test_procedure_ids = TestProcedure.where(item_id:      @item.id,
                                                organization: current_user.organization,
                                                archive_id:  nil).order(:full_id).pluck(:id)
    end
  end

  # GET /test_procedures/new
  def new
    authorize :test_procedure

    @pact_files                  = get_pact_files
    @test_procedure              = TestProcedure.new
    @test_procedure.item_id      = @item.id
    @test_procedure.project_id   = @project.id
    maximium_procedure_id        = TestProcedure.where(item_id: @item.id).maximum(:procedure_id)
    @test_procedure.procedure_id = maximium_procedure_id.present? ? maximium_procedure_id + 1 : 1
    # Initial version counter value is 1.
    @test_procedure.version      = increment_int(@test_procedure.version)
    @test_cases                  = sort_on_full_id(TestCase.where(item_id: @item.id).order(:full_id))
    @undo_path                   = get_undo_path('test_procedures',
                                                 item_test_procedures_path(@item))
    @redo_path                   = get_redo_path('test_procedures',
                                                 item_test_procedures_path(@item))
    @test_cases                  = @test_cases.delete_if {|tc| tc.soft_delete }
  end

  # GET /test_procedures/1/edit
  def edit
    authorize :test_procedure
    @test_cases              = sort_on_full_id(TestCase.where(item_id: @item.id).order(:full_id))
    @undo_path               = get_undo_path('@test_procedures',
                                             item_test_procedures_path(@item))
    @redo_path               = get_redo_path('@test_procedures',
                                             item_test_procedures_path(@item))
    @pact_files              = get_pact_files
    test_case_associations   = if @test_procedure.test_case_associations.present?
                                 if @test_procedure.test_case_associations.kind_of?(String)
                                   @test_procedure.test_case_associations.split(',')
                                 else
                                   @test_procedure.test_case_associations.reject { |x| x.empty? }
                                 end
                               else
                                  []
                               end

    @test_cases              = @test_cases.delete_if {|tc| tc.soft_delete }

    @test_cases.each { |tc| tc.selected = test_case_associations.include?(tc.id.to_s) } if @test_cases.present?

    if session[:archives_visible]
      @test_procedure_ids    = TestProcedure.where(item_id:      @item.id,
                                                   organization: current_user.organization).order(:full_id).pluck(:id)
    else
      @test_procedure_ids    = TestProcedure.where(item_id:      @item.id,
                                                   organization: current_user.organization,
                                                   archive_id:  nil).order(:full_id).pluck(:id)
    end
  end

  # POST /test_procedures
  # POST /test_procedures.json
  def create
    authorize :test_procedure

    params[:test_procedure][:project_id]            = @project.id if !test_procedure_params[:project_id].present? && @project.present?
    params[:test_procedure][:item_id]               = @item.id    if !test_procedure_params[:item_id].present?    && @item.present?

    if  test_procedure_params['url_type'] == 'PACT'
      params['test_procedure']['url_link']          = test_procedure_params['pact_file']
    elsif  test_procedure_params['url_type'] == 'ATTACHMENT'
      file                                          = test_procedure_params['upload_file']

      if file.present?
        params['test_procedure']['url_link']        = file.original_filename
      end
    end

    if  test_procedure_params['url_type'] != 'PACT'
      if test_procedure_params['url_link'] =~ /^.*\/(.+)$/
        params['test_procedure']['url_description'] = $1
      else
        params['test_procedure']['url_description'] = test_procedure_params['url_link']
      end
    end

    @test_procedure                                 = TestProcedure.new(test_procedure_params)

    respond_to do |format|
      # Check to see if the Procedure ID already Exists.
      if TestProcedure.find_by(procedure_id: @test_procedure.procedure_id,
                               item_id:      @test_procedure.item_id)
        @test_procedure.errors.add(:procedure_id, :blank, message: "Duplicate ID: #{@test_procedure.procedure_id}") 
        format.html { render :new }
        format.json { render json: @test_procedure.errors, status: :unprocessable_entity }
      elsif TestProcedure.find_by(full_id: @test_procedure.full_id,
                                  item_id: @test_procedure.item_id)
        @test_procedure.errors.add(:full_id, :blank, message: "Duplicate ID: #{@test_procedure.full_id}") 
        format.html { render :new }
        format.json { render json: @test_procedure.errors, status: :unprocessable_entity }
      else
        @data_change                                = DataChange.save_or_destroy_with_undo_session(@test_procedure,
                                                                                                   'create',
                                                                                                   @test_procedure.id,
                                                                                                   'test_procedures')

        Associations.build_associations(@test_procedure) if @data_change.present?

        if @data_change.present?
          # Increment the global counter, and save the item.
          @item.tp_count                            = if @item.tp_count.present?
                                                        @item.tp_count + 1
                                                      else
                                                        1
                                                      end

          DataChange.save_or_destroy_with_undo_session(@item,
                                                       'update',
                                                       @item.id,
                                                       'items',
                                                       @data_change.session_id)
          format.html { redirect_to [@item, @test_procedure], notice: 'Test procedure was successfully created.' }
          format.json { render :show, status: :created, location: [@item, @test_procedure] }
        else
          format.html { render :new }
          format.json { render json: @test_procedure.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # PATCH/PUT /test_procedures/1
  # PATCH/PUT /test_procedures/1.json
  def update
    authorize @test_procedure

    params[:test_procedure][:project_id]                = @project.id if !test_procedure_params[:project_id].present? && @project.present?
    params[:test_procedure][:item_id]                   = @item.id    if !test_procedure_params[:item_id].present?    && @item.present?

    respond_to do |format|
      # Check to see if the Procedure ID already Exists.
      new_id                                            = test_procedure_params[:procedure_id].to_i

      if (new_id != @test_procedure.procedure_id) &&
         TestProcedure.find_by(procedure_id:   new_id,
                                   item_id: @test_procedure.item_id)
        @test_procedure.errors.add(:procedure_id, :blank, message: "Duplicate ID: #{@test_procedure.procedure_id}") 

        format.html { render :new }
        format.json { render json: @test_procedure.errors, status: :unprocessable_entity }
      else
        if  test_procedure_params['url_type'] == 'PACT'
          params['test_procedure']['url_link']          = test_procedure_params['pact_file']
        elsif  test_procedure_params['url_type'] == 'ATTACHMENT'
          file                                          = test_procedure_params['upload_file']

          if file.present?
            params['test_procedure']['url_link']        = file.original_filename
            params['test_procedure']['url_link']        = file.original_filename
          end
        end

        @data_change                                    = DataChange.save_or_destroy_with_undo_session(params['test_procedure'],
                                                                                                      'update',
                                                                                                       params[:id],
                                                                                                       'test_procedures')

        if @data_change.present?
          if Associations.build_associations(@test_procedure) &&
             test_procedure_params['upload_file'].present?
            @test_procedure.replace_file(test_procedure_params['upload_file'],
                                         @test_procedure.project_id,
                                         @test_procedure.item_id)

            @test_procedure.version                  = increment_int(@test_procedure.version)
            @data_change                             = DataChange.save_or_destroy_with_undo_session(@test_procedure,
                                                                                                    'update',
                                                                                                    @test_procedure.id,
                                                                                                    'test_procedures',
                                                                                                    @data_change.session_id)
          end
        end

        if @data_change.present?
          format.html { redirect_to item_test_procedure_path(@item.id, @test_procedure.id, previous_mode: 'editing'), notice: "#{I18n.t('misc.test_procedure')} was successfully updated." }
          format.json { render :show, status: :ok, location: [@item, @test_procedure] }
        else
          format.html { render :edit }
          format.json { render json: @test_procedure.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /test_procedures/1
  # DELETE /test_procedures/1.json
  def destroy
    authorize @test_procedure

    @data_change = DataChange.save_or_destroy_with_undo_session(@test_procedure,
                                                                'delete',
                                                                @test_procedure.id,
                                                                'test_procedures')

    respond_to do |format|
      format.html { redirect_to item_test_procedures_url, notice: 'Test procedure was successfully removed.' }
      format.json { head :no_content }
    end
  end

  def export
    authorize :test_procedure

    # Get all Test Procedure requirements
    if session[:archives_visible].kind_of?(Integer)
      @test_procedures = TestProcedure.where(item_id:      params[:item_id],
                                             organization: current_user.organization,
                                             archive_id:   session[:archives_visible])
    else
      @test_procedures = TestProcedure.where(item_id:      params[:item_id],
                                             organization: current_user.organization,
                                             archive_id:   nil)
    end

    @test_procedures = sort_on_full_id(@test_procedures)

    respond_to do |format|
      if params[:tp_export].try(:has_key?, :export_type) && params[:tp_export][:export_type] == 'HTML'
        format.html { render "test_procedures/export_html", layout: false }
        format.json { render :show, status: :ok, location: @test_procedure }
      elsif params[:tp_export].try(:has_key?, :export_type) && params[:tp_export][:export_type] == 'PDF'
        format.html { redirect_to item_test_procedures_export_path(format: :pdf) }
      elsif params[:tp_export].try(:has_key?, :export_type) && params[:tp_export][:export_type] == 'CSV'
        # Come back here using the csv format to generate the csv below.
        format.html { redirect_to item_test_procedures_export_path(format: :csv) }
      elsif params[:tp_export].try(:has_key?, :export_type) && params[:tp_export][:export_type] == 'XLS'
        # Come back here using the xls format to generate the xls below.
        format.html { redirect_to item_test_procedures_export_path(format: :xls) }
      elsif params[:tp_export].try(:has_key?, :export_type) && params[:tp_export][:export_type] == 'DOCX'
        # Come back here using the docx format to generate the docx below.
        if convert_data("Test_Procedures.docx",
                        'test_procedures/export_html.html.erb',
                         @item.present? ? @item.id : params[:item_id])
          format.html { redirect_to  item_test_procedures_export_path(filename: @converted_filename, format: :docx, starting_number: params[:md_export].try(:has_key?, :starting_number) ) }
        else
          if @conversion_error.present?
            error                        = @conversion_error.clone
            flash[:error]                = error
            session[:application_errors] = [ error ]
          end

          format.html { render :export }
          format.json { render json: @test_procedure.errors, status: :unprocessable_entity }
        end
      else
        format.html { render :export }
        format.json { render json: @test_procedure.errors, status: :unprocessable_entity }
        # If redirected using format => csv, generate the csv here.
        format.csv  { send_data TestProcedure.to_csv(@item.id), filename: "#{@item.name}-Test_Procedures.csv" }
        format.xls  { send_data TestProcedure.to_xls(@item.id), filename: "#{@item.name}-Test_Procedures.xls" }
        format.pdf  {
                       @no_links = true

                       render(pdf:      "#{@project.name}-TestProcedures",
                              template: 'test_procedures/export_html.html.erb',
                              title:    'Test Procedures: Export PDF | PACT',
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

  def import_test_procedures
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
      result = TestProcedure.from_file(filename, @item, check_download)

      if result == :duplicate_test_procedure
        if @project.errors.messages.empty?
          flash[:alert] = "File: #{file.original_filename} contains existing Test Procedures. Choose Duplicates Permitted to import duplicates."
        end

        error           = true
        elsif result == :test_procedure_associations_changed
        if @project.errors.messages.empty?
          flash[:alert] = "File: #{file.original_filename} changes associations to High or low Level Requirements. Choose Association Changes Permitted to import records with changed associations."
        end

        error           = true
      end
    end

    if !error
      unless TestProcedure.from_file(filename, @item)
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
    authorize :test_procedure

    if params[import_path].present?
      if import_test_procedures
        respond_to do |format|
          format.html {redirect_to item_test_procedures_path(@item), notice: 'Test Procedure requirements were successfully imported.' }
          format.json { head :no_content }
        end
      else
        respond_to do |format|
          format.html { redirect_to item_test_procedures_import_path(@item) }
          format.json { render json: @item.errors, status: :unprocessable_entity }
        end
      end
    else
      respond_to do |format|
        format.html { render :import }
        format.json { render json: @test_procedure.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /test_procedures/renumber
  def renumber
    authorize :test_procedure

    if params[:tp_renumber].try(:has_key?, :start)     &&
       params[:tp_renumber][:start]     =~/^\d+$/      &&
       params[:tp_renumber].try(:has_key?, :increment) &&
       params[:tp_renumber][:increment] =~/^\d+$/      &&
       params[:tp_renumber][:leading_zeros] =~/^\d+$/
      TestProcedure.renumber(@item.id, 
                        params[:tp_renumber][:start].to_i,
                        params[:tp_renumber][:increment].to_i,
                        @item.test_procedure_prefix,
                        params[:tp_renumber][:leading_zeros].to_i)
  
      respond_to do |format|
        format.html {redirect_to item_test_procedures_path(@item), notice: 'Test Procedures were successfully renumbered.' }
        format.json { head :no_content }
      end
    end
  end

  # GET /test_procedures/1/mark_as_deleted/
  # GET /test_procedures/1/mark_as_deleted.json
  def mark_as_deleted
    authorize @test_procedure

    @test_procedure.soft_delete = true
    @data_change                = DataChange.save_or_destroy_with_undo_session(@test_procedure,
                                                                               'update',
                                                                               @test_procedure.id,
                                                                               'test_procedures')

    if @data_change.present?
      respond_to do |format|
        format.html { redirect_to item_test_procedures_url, notice: 'Test procedure was successfully marked as deleted.' }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html { render :edit, error: 'Could not delete test procedure'}
        format.json { render json: @test_procedure.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /aource_procedure/1/download_file
  # GET /test_procedure/1/download_file.json
  def download_file
    authorize @test_procedure

    if @test_procedure.present?          &&
       @test_procedure.url_type.present? &&
       @test_procedure.url_link.present?
      file = @test_procedure.get_file_contents

      if file.kind_of?(ActiveStorage::Attached::One)
       send_data(file.download,
                 filename:     file.filename.to_s,
                 contant_type: file.content_type)
      elsif file.kind_of?(String)
        send_data(file,
                  filename: File.basename(@test_procedure.file_name))
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
        format.html { redirect_to item_test_procedures_url, error: 'No file to download.'}
        format.json { render json: @action_item.errors,  status: :unprocessable_entity }
      end
    end
  end

  # GET /aource_procedure/1/display_file
  # GET /test_procedure/1/display_file.json
  def display_file
    authorize @test_procedure

    if @test_procedure.present?          &&
       @test_procedure.url_type.present? &&
       @test_procedure.url_link.present?
      file = @test_procedure.get_file_contents

      if file.kind_of?(ActiveStorage::Attached::One)
        @file_contents = file.download
      elsif file.kind_of?(String)
        @file_contents = file
      elsif file.kind_of?(URI::HTTP)
        redirect_to file.to_s

        return
      end

      if @file_contents.present?
        lines            = []

        @file_contents   = @file_contents.split("\n")
        max              = (@file_contents.length).to_s.length + 1
        line_number      = 1

        @file_contents.each do |line|
          line.gsub!(HTML_ESCAPE_ONCE_REGEXP, HTML_ESCAPE)

          formatted_line = sprintf("%0*d %s", max, line_number, line).gsub(' ', '&nbsp;')
          lines.push(formatted_line)

          line_number   += 1
        end

        @file_contents   = lines.join('<br>')
      end
    else
      flash[:error]      = 'No file to display'

      respond_to do |format|
        format.html { redirect_to item_test_procedures_url, error: 'No file to display.'}
        format.json { render json: @action_item.errors,  status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_test_procedure
      if params[:id].present? && params[:id] =~ /\d+/
        @test_procedure = TestProcedure.find(params[:id])
      elsif params[:test_procedure_id] && params[:test_procedure_id] =~ /\d+/
        @test_procedure = TestProcedure.find(params[:test_procedure_id])
      end
    end

    # Delete image
    def delete_image
      @test_procedure.image.purge
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def test_procedure_params
      params.require(
                       :test_procedure)
            .permit(
                       :procedure_id,
                       :full_id,
                       :description,
                       :file_name,
                       :image,
                       :remove_image,
                       :selected,
                       :selected_files,
                       :test_case_associations,
                       :version,
                       :item_id,
                       :project_id,
                       :url_type,
                       :url_description,
                       :url_link,
                       :upload_file,
                       :pact_file,
                       :full_id_prefix,
                       test_case_associations:  [],
                   )
    end
end
