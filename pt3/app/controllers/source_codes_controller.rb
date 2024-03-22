require 'open3'
require 'tempfile'

class SourceCodesController < ApplicationController
  include Common

  respond_to    :docx

  before_action :set_source_code, only: [:show, :edit, :update, :destroy, :mark_as_deleted, :download_file, :display_file, :file_history]
  before_action :get_item
  before_action :get_items, only: [:new, :edit, :update]
  before_action :get_project_fromitemid
  before_action :get_projects, only: [:new, :edit, :update]
  skip_before_action :verify_authenticity_token, only: [:update, :generate, :analysis]

  HTML_ESCAPE	=	{ "&" => "&amp;", ">" => "&gt;", "<" => "&lt;", '"' => "&quot;", "'" => "&#39;" }
  HTML_ESCAPE_ONCE_REGEXP	=	/["><']|&(?!([a-zA-Z]+|(#\d+)|(#[xX][\dA-Fa-f]+));)/

  # GET /source_codes
  # GET /source_codes.json
  def index
    authorize :source_code

    if session[:archives_visible]
      @source_codes = SourceCode.where(item_id:      params[:item_id],
                                       organization: current_user.organization)
    else
      @source_codes = SourceCode.where(item_id:      params[:item_id],
                                       organization: current_user.organization,
                                       archive_id:  nil)
    end

    if params[:filter_field].present? && params[:filter_value]
      session[:sc_filter_field] = params[:filter_field]
      session[:sc_filter_value] = params[:filter_value]
      @source_codes             = @source_codes.to_a.delete_if do |source_code|
        field                   = source_code.attributes[params[:filter_field]].to_s.upcase
        value                   = params[:filter_value].upcase

        !field.index(value)
      end
    end

    @source_codes = sort_on_full_id(@source_codes)
    @undo_path    = get_undo_path('source_codes', item_source_codes_path(@item))
    @redo_path    = get_redo_path('source_codes', item_source_codes_path(@item))
  end

  # GET /source_codes/1
  # GET /source_codes/1.json
  def show
    authorize :source_code
    # Get the item.
    @item              = Item.find_by(id: @source_code.item_id)
    @undo_path         = get_undo_path('source_codes', item_source_codes_path(@item))
    @redo_path         = get_redo_path('source_codes', item_source_codes_path(@item))

    if session[:archives_visible]
      @source_code_ids = SourceCode.where(item_id:    @item.id,
                                        organization: current_user.organization).order(:full_id).pluck(:id)
    else
      @source_code_ids = SourceCode.where(item_id:    @item.id,
                                        organization: current_user.organization,
                                        archive_id:  nil).order(:full_id).pluck(:id)
    end
  end

  # GET /source_codes/new
  def new
    authorize :source_code

    @pact_files              = get_pact_files
    @source_code             = SourceCode.new
    @source_code.item_id     = @item.id
    @source_code.project_id  = @project.id
    maximium_codeid          = SourceCode.where(item_id: @item.id).maximum(:codeid)
    @source_code.codeid      = maximium_codeid.present? ? maximium_codeid + 1 : 1
    # Initial version counter value is 1.
    @source_code.version     = increment_int(@source_code.version)
    @undo_path               = get_undo_path('source_codes',
                                             item_source_codes_path(@item))
    @redo_path               = get_redo_path('source_codes',
                                             item_source_codes_path(@item))
    @high_level_requirements = sort_on_full_id(HighLevelRequirement.where(item_id: @item.id).order(:full_id))
    @low_level_requirements  = sort_on_full_id(LowLevelRequirement.where(item_id: @item.id).order(:full_id))
    @module_descriptions     = sort_on_full_id(ModuleDescription.where(item_id: @item.id).order(:full_id))
    @high_level_requirements = @high_level_requirements.delete_if {|hlr| hlr.soft_delete }
    @low_level_requirements  = @low_level_requirements.delete_if  {|llr| llr.soft_delete }
    @module_descriptions     = @module_descriptions.delete_if  {|md| md.soft_delete }
  end

  # GET /source_codes/1/edit
  def edit
    authorize :source_code

    @undo_path               = get_undo_path('@source_codes',
                                             item_source_codes_path(@item))
    @redo_path               = get_redo_path('@source_codes',
                                             item_source_codes_path(@item))
    @high_level_requirements = sort_on_full_id(HighLevelRequirement.where(item_id: @item.id).order(:full_id))
    @low_level_requirements  = sort_on_full_id(LowLevelRequirement.where(item_id: @item.id).order(:full_id))
    @module_descriptions      = sort_on_full_id(ModuleDescription.where(item_id: @item.id).order(:full_id))
    @pact_files              = get_pact_files
    high_level_associations  = if @source_code.high_level_requirement_associations.present?
                                 if @source_code.high_level_requirement_associations.kind_of?(String)
                                   @source_code.high_level_requirement_associations.split(',')
                                 else
                                   @source_code.high_level_requirement_associations.reject { |x| x.empty? }
                                 end
                               else
                                  []
                               end
    low_level_associations   = if @source_code.low_level_requirement_associations.present?
                                 if @source_code.low_level_requirement_associations.kind_of?(String)
                                   @source_code.low_level_requirement_associations.split(',')
                                 else
                                   @source_code.low_level_requirement_associations.reject { |x| x.empty? }
                                 end
                               else
                                  []
                               end
    module_description_associations = if @source_code.module_description_associations.present?
                                       if @source_code.module_description_associations.kind_of?(String)
                                         @source_code.module_description_associations.split(',')
                                       else
                                         @source_code.module_description_associations.reject { |x| x.empty? }
                                       end
                                     else
                                       []
                                     end

    @high_level_requirements = @high_level_requirements.delete_if {|hlr| hlr.soft_delete }
    @low_level_requirements  = @low_level_requirements.delete_if  {|llr| llr.soft_delete }
    @module_descriptions      = @module_descriptions.delete_if  {|md| md.soft_delete }

    @high_level_requirements.each { |hlr| hlr.selected = high_level_associations.include?(hlr.id.to_s) }  if @high_level_requirements.present?
    @low_level_requirements.each  { |llr| llr.selected = low_level_associations.include?(llr.id.to_s) }   if @low_level_requirements.present?
    @module_descriptions.each  { |md| md.selected = module_description_associations.include?(md.id.to_s) }  if @module_descriptions.present?

    if session[:archives_visible]
      @source_code_ids       = SourceCode.where(item_id:    @item.id,
                                                organization: current_user.organization).order(:full_id).pluck(:id)
    else
      @source_code_ids       = SourceCode.where(item_id:    @item.id,
                                                organization: current_user.organization,
                                                archive_id:  nil).order(:full_id).pluck(:id)
    end
  end

  # POST /source_codes
  # POST /source_codes.json
  def create
    authorize :source_code

    params[:source_code][:project_id]            = @project.id if !source_code_params[:project_id].present? && @project.present?
    params[:source_code][:item_id]               = @item.id    if !source_code_params[:item_id].present?    && @item.present?

    if source_code_params[:file_name].present?
      filename                                   = ActionView::Base.full_sanitizer.sanitize(source_code_params[:file_name])

      filename.gsub!("\r", '')

      if filename.index("\n")
        filenames                                = filename.split("\n")
        filename                                 = filenames[0]
      end

      params[:source_code][:file_name]           = filename
    end

    if  source_code_params['url_type'] == 'PACT'
      params['source_code']['url_link']          = source_code_params['pact_file']
    elsif  source_code_params['url_type'] == 'ATTACHMENT'
      file                                       = source_code_params['upload_file']

      if file.present?
        params['source_code']['url_description'] = file.original_filename
        params['source_code']['url_link']        = file.original_filename
      end
    end

    @source_code                                 = SourceCode.new(source_code_params)

    respond_to do |format|
      # Check to see if the Code ID already Exists.
      if SourceCode.find_by(codeid:  @source_code.codeid,
                            item_id: @source_code.item_id)
        @source_code.errors.add(:codeid, :blank, message: "Duplicate ID: #{@source_code.codeid}") 
        format.html { render :new }
        format.json { render json: @source_code.errors, status: :unprocessable_entity }
      elsif SourceCode.find_by(full_id:  @source_code.full_id,
                               item_id: @source_code.item_id)
        @source_code.errors.add(:full_id, :blank, message: "Duplicate ID: #{@source_code.full_id}") 
        format.html { render :new }
        format.json { render json: @source_code.errors, status: :unprocessable_entity }
      else
        @data_change                             = DataChange.save_or_destroy_with_undo_session(@source_code,
                                                                                                'create',
                                                                                                @source_code.id,
                                                                                                'source_codes')

        if @data_change.present?
          if Associations.build_associations(@source_code) &&
             source_code_params['upload_file'].present?
            @source_code.store_file(source_code_params['upload_file'])

            @data_change                         = DataChange.save_or_destroy_with_undo_session(@source_code,
                                                                                                'update',
                                                                                                @source_code.id,
                                                                                                'source_codes',
                                                                                                @data_change.session_id)
          end

          @source_code.module                    = ''

          @source_code.module_descriptions.each do |module_description|
            @source_code.module                 += ', ' unless @source_code.module.present?
            @source_code.module                 += module_description.full_id
          end

          @data_change                           = DataChange.save_or_destroy_with_undo_session(@source_code,
                                                                                                'update',
                                                                                                @source_code.id,
                                                                                                'source_codes',
                                                                                                @data_change.session_id)
        end

        if @data_change.present?
          # Increment the global counter, and save the item.
          @item.sc_count                        += 1

          DataChange.save_or_destroy_with_undo_session(@item,
                                                       'update',
                                                       @item.id,
                                                       'items',
                                                       @data_change.session_id)

          format.html { redirect_to [@item, @source_code], notice: 'Source code was successfully created.' }
          format.json { render :show, status: :created, location: [@item, @source_code] }
        else
          format.html { render :new }
          format.json { render json: @source_code.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # PATCH/PUT /source_codes/1
  # PATCH/PUT /source_codes/1.json
  def update
    authorize @source_code

    params[:source_code][:project_id]                  = @project.id if !source_code_params[:project_id].present? && @project.present?
    params[:source_code][:item_id]                     = @item.id    if !source_code_params[:item_id].present?    && @item.present?

    if source_code_params[:file_name].present?
      filename                                         = ActionView::Base.full_sanitizer.sanitize(source_code_params[:file_name])

      filename.gsub!("\r", '')

      if filename.index("\n")
        filenames                                      = filename.split("\n")
        filename                                       = filenames[0]
      end


      params[:source_code][:file_name]                 = filename
    end

    respond_to do |format|
      # Check to see if the Code ID already Exists.
      new_id = source_code_params[:codeid].to_i

      if (new_id != @source_code.codeid) &&
         SourceCode.find_by(codeid:   new_id,
                            item_id: @source_code.item_id)
        @source_code.errors.add(:codeid, :blank, message: "Duplicate ID: #{@source_code.codeid}") 
        format.html { render :new }
        format.json { render json: @source_code.errors, status: :unprocessable_entity }
      else
        if    source_code_params['url_type'] == 'PACT'
          params['source_code']['url_link']          = source_code_params['pact_file']
        elsif source_code_params['url_type'] == 'ATTACHMENT'
          file                                       = source_code_params['upload_file']

          if file.present?
            params['source_code']['url_description'] = file.original_filename
            params['source_code']['url_link']        = file.original_filename
          end
        end

        old_filename = @source_code.file_name
        old_version  = @source_code.version
        old_url_link = @source_code.url_link

        unless source_code_params['upload_file']                  ||
               (source_code_params['file_name'].present?          &&
                old_filename.present?                             &&
                old_filename != params[:source_code][:file_name]) ||
               (params[:source_code][:url_link] .present?         &&
                (old_url_link != params['source_code']['url_link']))
          params['source_code']['version'] = old_version
        end

        @data_change                                 = DataChange.save_or_destroy_with_undo_session(params['source_code'],
                                                                                                    'update',
                                                                                                    params[:id],
                                                                                                    'source_codes')

        if @data_change.present?
          if Associations.build_associations(@source_code) &&
             source_code_params['upload_file'].present?
            @source_code.replace_file(source_code_params['upload_file'],
                                      @source_code.project_id,
                                      @source_code.item_id)
          end
        end

        if @data_change.present?
            @source_code.module                      = ''

            @source_code.module_descriptions.each do |module_description|
              @source_code.module                   += ', ' unless @source_code.module.present?
              @source_code.module                   += module_description.full_id
            end

            @data_change                             = DataChange.save_or_destroy_with_undo_session(@source_code,
                                                                                                    'update',
                                                                                                    @source_code.id,
                                                                                                    'source_codes',
                                                                                                    @data_change.session_id)
        end

        if @data_change.present?
          format.html { redirect_to item_source_code_path(@item.id, @source_code.id, previous_mode: 'editing'), notice: "#{I18n.t('misc.source_code')} was successfully updated." }
          format.json { render :show, status: :ok, location: [@item, @source_code] }
        else
          format.html { render :edit }
          format.json { render json: @source_code.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /source_codes/1
  # DELETE /source_codes/1.json
  def destroy
    authorize @source_code

    @data_change = DataChange.save_or_destroy_with_undo_session(@source_code,
                                                                'delete',
                                                                @source_code.id,
                                                                'source_codes')

    respond_to do |format|
      format.html { redirect_to item_source_codes_url, notice: 'Source code was successfully removed.' }
      format.json { head :no_content }
    end
  end

  def export
    authorize :source_code

    # Get all Source Code requirements
    if session[:archives_visible]
      @source_codes = SourceCode.where(item_id:      params[:item_id],
                                       organization: current_user.organization)
    else
      @source_codes = SourceCode.where(item_id:      params[:item_id],
                                       organization: current_user.organization,
                                       archive_id:  nil)
    end

    @source_codes = sort_on_full_id(@source_codes)

    respond_to do |format|
      if params[:sc_export].try(:has_key?, :export_type) && params[:sc_export][:export_type] == 'HTML'
        format.html { render "source_codes/export_html", layout: false }
        format.json { render :show, status: :ok, location: @source_code }
      elsif params[:sc_export].try(:has_key?, :export_type) && params[:sc_export][:export_type] == 'PDF'
        format.html { redirect_to item_source_codes_export_path(format: :pdf) }
      elsif params[:sc_export].try(:has_key?, :export_type) && params[:sc_export][:export_type] == 'CSV'
        # Come back here using the csv format to generate the csv below.
        format.html { redirect_to item_source_codes_export_path(format: :csv) }
      elsif params[:sc_export].try(:has_key?, :export_type) && params[:sc_export][:export_type] == 'XLS'
        # Come back here using the xls format to generate the xls below.
        format.html { redirect_to item_source_codes_export_path(format: :xls) }
      elsif params[:sc_export].try(:has_key?, :export_type) && params[:sc_export][:export_type] == 'DOCX'
        # Come back here using the Docx format to generate the Docx below.
        if convert_data("Source_Codes.docx",
                        'source_codes/export_html.html.erb',
                         @item.present? ? @item.id : params[:item_id])
          format.html { redirect_to  item_source_codes_export_path(filename: @converted_filename, format: :docx, starting_number: params[:md_export].try(:has_key?, :starting_number) ) }
        else
          flash[:error]  = @conversion_error
          params[:level] = 2

          go_back
        end
      else
        format.html { render :export }
        format.json { render json: @source_code.errors, status: :unprocessable_entity }
        # If redirected using format => csv, generate the csv here.
        format.csv  { send_data SourceCode.to_csv(@item.id), filename: "#{@item.name}-Source_Codes.csv" }
        format.xls  { send_data SourceCode.to_xls(@item.id), filename: "#{@item.name}-Source_Codes.xls" }
        format.pdf  {
                       @no_links = true

                       render(pdf:      "#{@project.name}-SourceCodes",
                              template: 'source_codes/export_html.html.erb',
                              title:    'Source Code: Export PDF | PACT',
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

  def import_source_codes
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
      result = SourceCode.from_file(filename, @item, check_download)

      if result == :duplicate_source_code
        if @project.errors.messages.empty?
          flash[:alert] = "File: #{file.original_filename} contains existing Source Codes. Choose Duplicates Permitted to import duplicates."
        end

        error           = true
        elsif result == :source_code_requirement_associations_changed
        if @project.errors.messages.empty?
          flash[:alert] = "File: #{file.original_filename} changes associations to High or low Level Requirements. Choose Association Changes Permitted to import records with changed associations."
        end

        error           = true
      end
    end

    if !error
      unless SourceCode.from_file(filename, @item)
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
    authorize :source_code

    if params[import_path].present?
      if import_source_codes
        respond_to do |format|
          format.html {redirect_to item_source_codes_path(@item), notice: 'Source Code requirements were successfully imported.' }
          format.json { head :no_content }
        end
      else
        respond_to do |format|
          format.html { redirect_to item_source_codes_import_path(@item) }
          format.json { render json: @item.errors, status: :unprocessable_entity }
        end
      end
    else
      respond_to do |format|
        format.html { render :import }
        format.json { render json: @source_code.errors, status: :unprocessable_entity }
      end
    end
  end

  def scan_github
    authorize :source_code

    @error          = ''
    @github_access  = GithubAccess.find_by(user_id: current_user.id) if current_user.present?
    @github_user    = @github_access.get_github_user                if @github_access.present?

    if @github_access.nil?
      @error        = "Cannot locate your GitHub credentials "              \
                      "Have you entered them?\nIf not you can do so under " \
                      "Info > Setup Github Credentials."
    elsif @github_user.nil?
        if @github_access.token.present?
          @error    = "Cannot login to github with your personal token."
        else
          @error    = "Cannot login to github as #{@github_access.username}."
        end
    end

    unless @error.present?
      @repositories = @github_access.get_my_repositories
      @branches     = @github_access.get_branches
      @folders      = @github_access.get_folders
      @files        = @github_access.get_files_for_folders(@github_access.last_accessed_folder)
    end
  end

  def select_github_files
    authorize :source_code

    # Get source_code requirements
    @selected_url     = item_source_codes_generate_path(@item,
                                                        github_access_id: params[:github_access_id])
    @not_selected_url = item_source_codes_path
    @error            = ''
    @github_access    = if params[:github_access_id].present?
                          GithubAccess.find_by(id: params[:github_access_id])
                        else
                          GithubAccess.find_by(user_id: current_user.id) if current_user.present?
                        end

    if @github_access.nil?
      @error          = "Cannot locate your GitHub credentials "              \
                        "Have you entered them?\nIf not you can do so under " \
                        "Info > Setup Github Credentials."
    elsif @github_user.nil?
        if @github_access.token.present?
          @error      = "Cannot login to github with your personal token."
        else
          @error      = "Cannot login to github as #{@github_access.username}."
        end
    end

    @files          =  @github_access.last_accessed_file.split("\n")
    @selected_files = []

    @files.each_with_index do |file, i|
      filename      = ''
      url           = ''

      file.gsub!(/\r/, '')
      file.gsub!(/\n/, '')

      if file.index('|') > 0
        filename,
        url         = file.split('|')
      else
        filename    = file
      end

      @selected_files.push({ index: i, filename: filename, url: url, selected: false })
    end
  end

  def scan_gitlab
    authorize :source_code

    @error          = ''
    @gitlab_access  = GitlabAccess.find_by(user_id: current_user.id) if current_user.present?

    if @gitlab_access.nil?
      @error        = "Cannot locate your GitHub credentials "              \
                      "Have you entered them?\nIf not you can do so under " \
                      "Info > Setup Github Credentials."
    end

    unless @error.present?
      @repositories = @gitlab_access.get_my_repositories
      @branches     = @gitlab_access.get_branches
      @folders      = @gitlab_access.get_folders
      @files        = @gitlab_access.get_files_for_folders(@gitlab_access.last_accessed_folder)
    end
  end

  def select_gitlab_files
    authorize :source_code

    # Get source_code requirements
    @selected_url     = item_source_codes_generate_path(@item,
                                                        gitlab_access_id: params[:gitlab_access_id])
    @not_selected_url = item_source_codes_path
    @error            = ''
    @gitlab_access    = if params[:gitlab_access_id].present?
                          GitlabAccess.find_by(id: params[:gitlab_access_id])
                        else
                          GitlabAccess.find_by(user_id: current_user.id) if current_user.present?
                        end

    if @gitlab_access.nil?
      @error          = "Cannot locate your GitHub credentials "              \
                        "Have you entered them?\nIf not you can do so under " \
                        "Info > Setup Github Credentials."
    elsif @gitlab_user.nil?
        if @gitlab_access.token.present?
          @error      = "Cannot login to gitlab with your personal token."
        else
          @error      = "Cannot login to gitlab as #{@gitlab_access.username}."
        end
    end

    @files          =  @gitlab_access.last_accessed_file.split("\n")
    @selected_files = []

    @files.each_with_index do |file, i|
      filename      = ''
      url           = ''

      file.gsub!(/\r/, '')
      file.gsub!(/\n/, '')

      if file.index('|') > 0
        filename,
        url         = file.split('|')
      else
        filename    = file
      end

      @selected_files.push({ index: i, filename: filename, url: url, selected: false })
    end
  end

  def generate
    authorize :source_code

    if request.referrer.index('select_github_files')
      @github_access    = if params[:github_access_id].present?
                            GithubAccess.find_by(id: params[:github_access_id])
                          else
                            GithubAccess.find_by(user_id: current_user.id) if current_user.present?
                          end
    end

    if request.referrer.index('select_gitlab_files')
      @gitlab_access    = if params[:gitlab_access_id].present?
                            GitlabAccess.find_by(id: params[:gitlab_access_id])
                          else
                            GitlabAccess.find_by(user_id: current_user.id) if current_user.present?
                          end
    end

    filenames    = source_code_params[:selected_files].split(',') if source_code_params[:selected_files].present?

    if filenames.present? && params[:attach_files] && request.referrer.index('select_github_files')
      SourceCode.generate_source_codes(filenames, @item, @github_access)
    elsif filenames.present? && params[:attach_files] && request.referrer.index('select_gitlab_files')
      SourceCode.generate_source_codes(filenames, @item, @gitlab_access)
    else
      SourceCode.generate_source_codes(filenames, @item)
    end

    redirect_to item_source_codes_path(@item), notice: 'Source Code files were successfully generated.' 
  end

  # GET /source_codes/renumber
  def renumber
    authorize :source_code

    if params[:sc_renumber].try(:has_key?, :start)     &&
       params[:sc_renumber][:start]     =~/^\d+$/      &&
       params[:sc_renumber].try(:has_key?, :increment) &&
       params[:sc_renumber][:increment] =~/^\d+$/      &&
       params[:sc_renumber][:leading_zeros] =~/^\d+$/
      SourceCode.renumber(@item.id,
                          params[:sc_renumber][:start].to_i,
                          params[:sc_renumber][:increment].to_i,
                          @item.source_code_prefix,
                          params[:sc_renumber][:leading_zeros].to_i)

      respond_to do |format|
        format.html {redirect_to item_source_codes_path(@item), notice: 'Source Codes were successfully renumbered.' }
        format.json { head :no_content }
      end
    end
  end

  # GET /source_codes/instrument
  def instrument
    authorize :source_code

    if request.put? && params[:select_source_codes].present?
      autoinstrument  = false
      resetnumbering  = false
      deleteexisting  = false
      cmark           = 'CMARK'
      source_code_ids = JSON.parse(params[:select_source_codes])
      autoinstrument  = (params[:autoinstrument].downcase == "yes") if params[:autoinstrument].present?
      resetnumbering  = (params[:resetnumbering].downcase == "yes") if params[:resetnumbering].present?
      deleteexisting  = (params[:deleteexisting].downcase == "yes") if params[:deleteexisting].present?
      cmark           = params[:cmark]                              if params[:cmark].present?

      logger.info("Source Code Files: #{params[:select_source_codes]}")

      if deleteexisting
        folder        = Document.find_by(document_type: Constants::FOLDER_TYPE,
                                         name:          Constants::INSTRUMENTED_CODE,
                                         item_id:       @item.id,
                                         project_id:    @project.id)
        documents     = Document.where(parent_id: folder.id, organization: current_user.organization)

        documents.each { |document| document.delete }
      end

      starting_number = 0

      if !resetnumbering
        maximum_id    = starting_number

        source_code_ids.each do |source_code_id|
          @source_code    = SourceCode.find(source_code_id.to_i)
          maximum_id      = CodeCheckmark.where(organization: User.current.organization,
                                                source_code_id: source_code_id).maximum("checkmark_id")
        end

        if maximum_id > starting_number
          starting_number = maximum_id
        end
      end

      source_code_ids.each do |source_code_id|
        @source_code      = SourceCode.find(source_code_id.to_i)

        logger.info("Processing Source File: #{@source_code.file_name}")
        number            = @source_code.instrument(nil, autoinstrument, cmark, resetnumbering, starting_number)
        starting_number   = number if number.present?
      end

      respond_to do |format|
        format.html { redirect_to item_source_codes_path(@item), notice: 'Source Codes were successfully instrumented.' }
        format.json { render :index, status: :ok }
      end
    else
      if session[:archives_visible]
        @source_codes = SourceCode.where(item_id:      params[:item_id],
                                        organization: current_user.organization)
      else
        @source_codes = SourceCode.where(item_id:      params[:item_id],
                                         organization: current_user.organization,
                                         archive_id:  nil)
      end
    end
  end

  # GET /source_codes/profile
  def profile
    authorize :source_code

    @source_codes          = SourceCode.where(item_id: @item.id, organization: current_user.organization).order(:code_checkmark_id)
    @checkmarks            = CodeCheckmark.where(organization: current_user.organization).order(:source_code_id)
    @checkmark_hits        = CodeCheckmarkHit.where(organization: current_user.organization).order(:code_checkmark_id)
    @profiled_source_codes = []
    profiled_source_codes  = {}

    @checkmarks.each do |checkmark|
      unless profiled_source_codes[checkmark.source_code_id].present?
        profiled_source_code                            = {}
        profiled_source_code[:source_code]              = SourceCode.find(checkmark.source_code_id)
        profiled_source_code[:code_checkmarks]          = []
        profiled_source_code[:code_checkmark_hits]      = []
        profiled_source_code[:code_checkmark_misses]    = []
        profiled_source_code[:checkmark_hits]           = 0
        profiled_source_code[:checkmark_misses]         = 0
        profiled_source_code[:coverage]                 = 0.0
        profiled_source_codes[checkmark.source_code_id] = profiled_source_code
      end
    end

    profiled_source_codes.each do |id, profiled_source_code|
      @checkmarks.each do |code_checkmark|
        if code_checkmark.source_code_id == profiled_source_code[:source_code].id
          profiled_source_code[:code_checkmarks].push(code_checkmark)

          checkmark_hit = false

          @checkmark_hits.each do |code_checkmark_hit|
            if code_checkmark_hit.code_checkmark_id == code_checkmark.id
              profiled_source_code[:code_checkmark_hits].push(code_checkmark_hit)

              checkmark_hit = true
            end
          end

          if checkmark_hit
            profiled_source_code[:checkmark_hits] += 1
          else
            profiled_source_code[:checkmark_misses] += 1

            profiled_source_code[:code_checkmark_misses].push(code_checkmark)
          end
        end
      end

      profiled_source_code[:coverage] = (profiled_source_code[:checkmark_hits].to_f /
                                         profiled_source_code[:code_checkmarks].length.to_f) * 100.0

      @profiled_source_codes.push(profiled_source_code)
    end
  end

  def zip
    authorize :source_code

    if session[:archives_visible]
      @source_codes            = SourceCode.where(item_id:      params[:item_id],
                                                  organization: current_user.organization)
    else
      @source_codes            = SourceCode.where(item_id:      params[:item_id],
                                                  organization: current_user.organization,
                                                  archive_id:  nil)
    end
  end

  def package_source_codes
    authorize :source_code

    selected_source_codes    = []
    selected_source_code_ids = params['selected_source_codes']['selections'].split(',') if params['selected_source_codes']['selections'].present?
    zip_name                 = params['selected_source_codes']['filename']

    zip_name.gsub!(/\//, '_')

    selected_source_code_ids.each do |id|
      source_code_id         = if id =~ /^(\d+)$/
                                 Regexp.last_match(1).to_i
                               else
                                 nil
                               end

      selected_source_codes.push(SourceCode.find(source_code_id)) if source_code_id.present?
    end

    Dir.mktmpdir do |dir|
      zip_filename           = File.join(dir, ActionView::Base.full_sanitizer.sanitize(zip_name))
      data                   = nil

      Zip::File.open(zip_filename,
                     Zip::File::CREATE) do |zip_file|
        selected_source_codes.each do |source_code|
          filename           = File.basename(ActionView::Base.full_sanitizer.sanitize(source_code.file_name))

          File.open(filename, 'wb') { |f| f.write(source_code.get_file_contents) }

          zip_file.add(ActionView::Base.full_sanitizer.sanitize(source_code.file_name),
                       filename)
        end
      end

      File.open(zip_filename, 'rb') { |f| data = f.read }
      send_data data, type: 'application/zip', filename: zip_name
    end
  end

  # GET /source_codes/process_results
  def process_results
    authorize :source_code

        # Get all Source Code requirements
    if session[:archives_visible]
      @source_codes = SourceCode.where(item_id:      params[:item_id],
                                       organization: current_user.organization)
    else
      @source_codes = SourceCode.where(item_id:      params[:item_id],
                                       organization: current_user.organization,
                                       archive_id:  nil)
    end

    @source_codes = sort_on_full_id(@source_codes)

    if request.put?                               &&
       source_code_params[:selected].present?     &&
       source_code_params['upload_file'].present?
      selected = source_code_params[:selected].split(',');
      file     = source_code_params['upload_file']
      filename = if file.path.present?
                   file.path
                 elsif file.tempfile.present?
                   file.tempfile.path
                 end

      if CodeCheckmarkHit.record_hits(filename, selected)
        respond_to do |format|
          format.html { redirect_to item_source_codes_profile_path(@item), notice: 'Run results successfully processed.' }
          format.json { render :index, status: :ok }
        end
      else
        respond_to do |format|
          format.html { redirect_to item_source_codes_path(@item), notice: 'Cannot Import Run Results.' }
          format.json { render :index, status: :unprocessable_entity }
        end
      end

      return
    end
  end

  # GET /source_codes/1/mark_as_deleted/
  # GET /source_codes/1/mark_as_deleted.json
  def mark_as_deleted
    authorize @source_code

    @source_code.soft_delete = true
    @data_change             = DataChange.save_or_destroy_with_undo_session(@source_code,
                                                                            'update',
                                                                            @source_code.id,
                                                                            'source_codes')

    if @data_change.present?
      respond_to do |format|
        format.html { redirect_to item_source_codes_url, notice: 'Source code was successfully marked as deleted.' }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html { render :edit, error: 'Could not delete source code'}
        format.json { render json: @source_code.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /aource_code/1/download_file
  # GET /source_code/1/download_file.json
  def download_file
    authorize @source_code

    if @source_code.present?          &&
       @source_code.url_type.present? &&
       @source_code.url_link.present?
      file = @source_code.get_file_contents

      if file.kind_of?(ActiveStorage::Attached::One)
       send_data(file.download,
                 filename:     ActionView::Base.full_sanitizer.sanitize(file.filename.to_s),
                 contant_type: file.content_type)
      elsif file.kind_of?(String)
        send_data(file,
                  filename: File.basename(ActionView::Base.full_sanitizer.sanitize(file)))
      elsif file.kind_of?(URI::HTTP)
        redirect_to file.to_s, target: "_blank"

        return
      else
        respond_to do |format|
          format.html { redirect_to item_source_codes_url, error: 'No file to download.'}
          format.json { render json: @action_item.errors,  status: :unprocessable_entity }
        end
      end
    else
      flash[:error]  = 'No file to download'

      respond_to do |format|
        format.html { redirect_to item_source_codes_url, error: 'No file to download.'}
        format.json { render json: @action_item.errors,  status: :unprocessable_entity }
      end
    end
  end

  # GET /source_code/1/display_file
  # GET /source_code/1/display_file.json
  def display_file
    authorize @source_code

    if @source_code.present?          &&
       @source_code.url_type.present? &&
       @source_code.url_link.present?
      file                 = @source_code.get_file_contents

      if file.kind_of?(ActiveStorage::Attached::One)
        @file_contents     = file.download
      elsif file.kind_of?(String)
        @file_contents     = file
      elsif file.kind_of?(URI::HTTP)
        redirect_to file.to_s

        return
      end

      if @file_contents.present?
        encoding           = nil

        begin
          encoding         = @file_contents.encoding.to_s

          unless @file_contents.valid_encoding?
            encoding       = 'BAD'
            @file_contents = ''
          else
            test           = @file_contents.dup

            test.encode("UTF-8")
          end
        rescue
          begin
            @file_contents = @file_contents.encode('UTF-8',
                                                   :invalid => :replace,
                                                   :undef   => :replace,
                                                   replace: '')

          rescue
            encoding       = 'BAD'
            @file_contents = ''
          end
        end

        unless encoding == 'BAD'
          lines            = []

          @file_contents.gsub!(/\r/, '')

          @file_contents   = @file_contents.split("\n")
          max              = (@file_contents.length).to_s.length + 1
          line_number      = 1

          @file_contents.each do |line|
            line.gsub!(HTML_ESCAPE_ONCE_REGEXP, HTML_ESCAPE)

            formatted_line = sprintf("%0*d %s", max, line_number, line).gsub(/\t/, '&nbsp;&nbsp;&nbsp;&nbsp;').gsub(' ', '&nbsp;')
            lines.push(formatted_line)

            line_number   += 1
          end

          @file_contents   = lines.join('<br>')
        else
          @file_contents     = ''
          flash[:error]      = "Can't display binary file."
        end
      end
    else
      flash[:error]        = 'No file to display'

      respond_to do |format|
        format.html { redirect_to item_source_codes_url, error: 'No file to display.'}
        format.json { render json: @action_item.errors,  status: :unprocessable_entity }
      end
    end
  end

  # GET /source_code/1/file_history
  # GET /source_code/1/file_history.json
  def file_history
    @source_codes = SourceCode.where(codeid:       @source_code.codeid,
                                     item_id:      params[:item_id],
                                     organization: current_user.organization)
                              .order(:created_at)
  end


  # GET /source_code/1/file_history
  # GET /source_code/1/file_history.json
  def diff
    options = params[:options]
    ids     = if params[:ids].present?
                params[:ids].split(',')
              else
                []
              end

    if ids.length == 2
      source_code_1      = SourceCode.find_by(id: ids[0])
      source_code_2      = SourceCode.find_by(id: ids[1])
      source_code_1      = source_code_1.get_file_contents.download
      source_code_2      = source_code_2.get_file_contents.download
      source_code_file_1 = Tempfile.new
      source_code_file_2 = Tempfile.new
      status             = nil

      source_code_file_1 << source_code_1
      source_code_file_2 << source_code_2

      source_code_file_1.flush
      source_code_file_2.flush

      @stdout, @stderr, status = Open3.capture3("diff #{options} #{source_code_file_1.path} #{source_code_file_2.path}")
      @lines                   = @stdout.split("\n")
    end
  end

  # GET /source_codes/analyze
  def analyze
    authorize :source_code

    if request.put? && params[:select_source_codes].present?
      source_code_ids = JSON.parse(params[:select_source_codes])

      source_code_ids.each do |source_code_id|
        @source_code  = SourceCode.find(source_code_id.to_i)
        code          = @source_code.get_file_contents.download

        FunctionItem.analyze_code(code, @source_code)
      end

      respond_to do |format|
        format.html { redirect_to item_source_codes_path(@item), notice: 'Source Codes were successfully analyzed.' }
        format.json { render :index, status: :ok }
      end
    else
      if session[:archives_visible]
        @source_codes = SourceCode.where(item_id:      params[:item_id],
                                        organization: current_user.organization)
      else
        @source_codes = SourceCode.where(item_id:      params[:item_id],
                                         organization: current_user.organization,
                                         archive_id:  nil)
      end

      @source_codes = @source_codes.to_a.delete_if do |source_code|
        !((source_code.file_name =~ /\.cpp$/i) ||
          (source_code.file_name =~ /\.c$/i))
      end
    end
  end

  # GET /source_codes/analysis
  def analysis
    authorize :source_code

    @item = Item.find(params[:item_id]) if Item.find(params[:item_id]).present?

    if request.post? && params[:item_id].present?
      respond_to do |format|
        format.html { redirect_to item_function_items_path(@item, entry_point: params[:entry_point]) }
        format.json { render :index, status: :ok }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_source_code
      if params[:id].present? && params[:id] =~ /\d+/
        @source_code = SourceCode.find(params[:id])
      elsif params[:source_code_id] && params[:source_code_id] =~ /\d+/
        @source_code = SourceCode.find(params[:source_code_id])
      end
    end

    # Delete image
    def delete_image
      @source_code.image.purge
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def source_code_params
      params.require(
                       :source_code
                    )
            .permit(
                       :codeid,
                       :full_id,
                       :full_id_prefix,
                       :description,
                       :file_name,
                       :module,
                       :function,
                       :image,
                       :remove_image,
                       :selected,
                       :selected_files,
                       :high_level_requirement_associations,
                       :low_level_requirement_associations,
                       :module_description_associations,
                       :version,
                       :item_id,
                       :project_id,
                       :derived,
                       :derived_justification,
                       :url_type,
                       :url_description,
                       :url_link,
                       :upload_file,
                       :pact_file,
                       :external_version,
                       high_level_requirement_associations: [],
                       low_level_requirement_associations: []
                   )
    end
end
