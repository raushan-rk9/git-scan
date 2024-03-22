class DocumentsController < ApplicationController
  include Common
  before_action :set_document, only: [:show, :edit, :update, :destroy, :upload_document, :download_document, :document_history, :display_file]
  before_action :get_parent_document
  before_action :get_items, only: [:new, :edit, :update]
  before_action :get_project_fromitemid
  before_action :get_projects, only: [:new, :edit, :update]
  skip_before_action :verify_authenticity_token, only: [:package_documents]

  # GET /documents
  # GET /documents.json
  def index
    authorize :document

    if session[:archives_visible]
      @documents = Document.where(item_id:      params[:item_id],
                                  organization: current_user.organization).order(:docid)
    else
      @documents = Document.where(item_id:      params[:item_id],
                                  organization: current_user.organization,
                                  archive_id: nil).order(:docid)
    end

    if params[:filter_field].present? && params[:filter_value]
      session[:doc_filter_field] = params[:filter_field]
      session[:doc_filter_value] = params[:filter_value]
      @documents                 = @documents.to_a.delete_if do |document|
        field                    = document.attributes[params[:filter_field]].upitem
        value                    = params[:filter_value].upitem

        !field.index(value)
      end
    end

    @undo_path   = get_undo_path('documents',
                                  item_documents_path(@item))
    @redo_path   = get_redo_path('documents',
                                  item_documents_path(@item))
  end

  # GET /documents/1
  # GET /documents/1.json
  def show
    authorize :document
    @item      = Item.find_by(id: @document.item_id)
    @undo_path = get_undo_path('documents',
                                item_documents_path(@item))
    @redo_path = get_redo_path('documents',
                                item_documents_path(@item))
  end

  # GET /documents/new
  def new
    authorize :document

    @document                  = Document.new
    @document.item_id          = @item.id
    @document.project_id       = @project.id
    @document.parent_id        = @parent_document.id if @parent_document.present?
    @document.version          = 1
    @document.release_document = false
    @document.draft_revision   = Constants::INITIAL_DRAFT_REVISION
    @document_types            = DocumentType.where(item_types: [ @item.itemtype ],
                                                    dal_levels: [ @item.level])
    pg_results                 = ActiveRecord::Base.connection.execute("SELECT nextval('documents_document_id_seq')")

    pg_results.each { |row| @document.document_id = row["nextval"] } if pg_results.present?
  end

  # GET /documents/1/edit
  def edit
    authorize @document
    # Increment the version counter if edited.

    if @document.version.present?
      @document.version       += 1
    else
      @document.version        = 1
    end

    if @document.draft_revision.present?
      @document.draft_revision = increment_draft_revision(@document.draft_revision)
    else
      @document.draft_revision = Constants::INITIAL_DRAFT_REVISION
    end

    @document.release_document = false
    @undo_path                 = get_undo_path('documents',
                                               item_documents_path(@item))
    @redo_path                 = get_redo_path('documents',
                                               item_documents_path(@item))
  end

  # POST /documents
  # POST /documents.json
  def create
    authorize :document

    params[:document][:project_id] = @project.id if !document_params[:project_id].present? && @project.present?
    params[:document][:item_id]    = @item.id    if !document_params[:item_id].present?    && @item.present?
    @document                      = Document.new(document_params)
    pg_results                     = ActiveRecord::Base.connection.execute("SELECT nextval('documents_document_id_seq')")

    pg_results.each { |row| @document.document_id = row["nextval"] } if pg_results.present?

    unless @document.draft_revision.present?
      @document.draft_revision     = Constants::INITIAL_DRAFT_REVISION
    end

    unless document_params[:file].present? || (document_params[:document_type] == Constants::FOLDER_TYPE)
      @document.errors.add(:file, :blank, message: 'You must attach a file.')

      unless document_params[:file].present? || (document_params[:document_type] == Constants::FOLDER_TYPE)
        render partial: 'form',  layout: 'layouts/application', document: @document, notice: 'You must chosse a file to upload.'
  
        return
      end
    end

    @document.upload_date          = DateTime.now

    # Check to see if the Document ID already Exists.
    if Document.find_by(docid:   @document.docid,
                        item_id: @document.item_id)
      @document.errors.add(:docid,
                           :blank,
                           message: "Duplicate ID: #{@document.docid}")
    else
      @data_change                 = DataChange.save_or_destroy_with_undo_session(@document,
                                                                                  'create',
                                                                                  @document.id,
                                                                                  'documents')

      if @data_change.present? && document_params['file'].present?
        @document.store_file(document_params['file'])

        @data_change               = DataChange.save_or_destroy_with_undo_session(@document,
                                                                                  'update',
                                                                                  @document.id,
                                                                                  'documents',
                                                                                  @data_change.session_id)
      end
    end

    respond_to do |format|
      if @data_change.present?
        format.html { redirect_to [@item, @document], notice: 'Document was successfully created.' }
        format.json { render :show, status: :created, location: [@item, @document] }
      else
        format.html { render 'new' }
        format.json { render json: @document.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /documents/1
  # PATCH/PUT /documents/1.json
  def update
    authorize @document

    session_id                       = nil

    if @document.present?
      unless @document.document_id.present?
        pg_results                 = ActiveRecord::Base.connection.execute("SELECT nextval('documents_document_id_seq')")

        pg_results.each { |row| @document.document_id = row["nextval"] } if pg_results.present?
      end

      archive                        = Archive.new()
      title                          = "Update of Document ID: #{@document.docid}, Version #{@document.version}."
      archive.name                   = title
      archive.full_id                = title
      archive.description            = title
      archive.revision               = "1"
      archive.version                = "1"
      archive.archive_type           = Constants::DOCUMENT_ARCHIVE
      archive.archived_at            = DateTime.now()
      archive.organization           = current_user.organization
      @data_change                   = DataChange.save_or_destroy_with_undo_session(archive,
                                                                                    'create',
                                                                                    nil,
                                                                                    'archives',
                                                                                    session_id)
      session_id                     = @data_change.session_id if @data_change.present?

      archive.clone_document(@document, @project.id, @item.id, session_id)
    end

    params[:document][:project_id]   = @project.id if !document_params[:project_id].present? && @project.present?
    params[:document][:item_id]      = @item.id    if !document_params[:item_id].present?    && @item.present?
    params[:document][:upload_date]  = DateTime.now()

    respond_to do |format|
      @data_change                   = DataChange.save_or_destroy_with_undo_session(document_params,
                                                                                    'update',
                                                                                    params[:id],
                                                                                    'documents',
                                                                                    session_id)

      if @data_change.present? && document_params['file'].present?
        @document.store_file(document_params['file'])

        @data_change                 = DataChange.save_or_destroy_with_undo_session(@document,
                                                                                    'update',
                                                                                    @document.id,
                                                                                    'documents',
                                                                                    @data_change.session_id)
      end

      if @data_change.present?
        if document_params[:release_document]
          document_change            = @document.release_revision(@data_change.session_id)
        else
          document_change            = @document.update_version(@data_change.session_id)
        end
      end

      if @data_change.present?
        format.html { redirect_to [@item, @document], notice: 'Document was successfully updated.' }
        format.json { render :show, status: :ok, location: [@item, @document] }
      else
        format.html { render :edit }
        format.json { render json: @document.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /documents/1
  # DELETE /documents/1.json
  def destroy
    authorize @document
    @data_change = DataChange.save_or_destroy_with_undo_session(@document,
                                                                'delete',
                                                                @document.id,
                                                                'documents')

    respond_to do |format|
      format.html { redirect_to item_documents_url, notice: 'Document was successfully removed.' }
      format.json { head :no_content }
    end
  end

  # GET /documents/1/upload_document
  # GET /documents/1/upload_document.json
  def upload_document
    authorize @document

    if @document.draft_revision.present?
      @document.draft_revision = increment_draft_revision(@document.draft_revision)
    else
      @document.draft_revision = Constants::INITIAL_DRAFT_REVISION
    end
  end

  # GET /documents/1/download_document
  # GET /documents/1/download_document.json
  def download_document
    authorize @document

    if @document.present? && @document.file_path.present?
      if @document.file_type.present?
        send_data @document.get_file_contents,
                  type:     @document.file_type,
                  filename: File.basename(@document.file_path)
      else
        send_data @document.get_file_contents,
                  filename: File.basename(@document.file_path)
      end
    else
      flash[:error]  = 'No Document to download'

      respond_to do |format|
        format.html { redirect_to item_documents_url, error: 'No Document to download.'}
        format.json { render json: @action_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /documents/1/document_history
  # GET /documents/1/document_history.json
  def document_history
    authorize @document

    if @document.present?
      @documents    = Document.where(item_id:      params[:item_id],
                                     organization: current_user.organization,
                                     document_id:  @document.document_id).order(:version)
    else
      @document.errors.add(:docid, :blank, message: 'Cannot find document.')
    end
  end

  # GET /documents/select_documents
  # GET /documents/select_documents.json
  def select_documents
    authorize :document

    documents = if session[:archives_visible]
                  Document.where(item_id:      params[:item_id],
                                 organization: current_user.organization).order(:docid).to_a
                else
                  Document.where(item_id:      params[:item_id],
                                 organization: current_user.organization,
                                 archive_id:   nil).order(:docid).to_a
                end

    @documents = documents.delete_if { |document| document.document_type == Constants::FOLDER_TYPE }
  end

  # GET /documents/package_documents
  # GET /documents/package_documents.json
  def package_documents
    authorize :document

    if params[:selected_documents][:selections].present?
      selected_documents    = []
      selected_document_ids = params[:selected_documents][:selections].split(',')
      zip_name              = params[:selected_documents][:filename]

      zip_name.gsub!(/\//, '_')

      selected_document_ids.each { |id| selected_documents.push(Document.find(id)) }

      Dir.mktmpdir do |dir|
        zip_filename        = File.join(dir, zip_name)
        data                = nil

        Zip::File.open(zip_filename,
                       Zip::File::CREATE) do |zip_file|
          selected_documents.each do |document|
            next if document.document_type == Constants::FOLDER_TYPE

            name            = 'document'
            name            = File.basename(document.file_path) if document.file_path.present?
            filename        = File.join(dir, name)

            File.open(filename, 'wb') { |f| f.write(document.get_file_contents) }

            zip_file.add(name, filename)
          end
        end

        File.open(zip_filename, 'rb') { |f| data = f.read }
        send_data data, type: 'application/zip', filename: zip_name
      end
    else
      respond_to do |format|
        format.html { redirect_to item_documents_url, notice: 'No documents were selected.' }
        format.json { head :no_content }
      end
    end
  end

  # GET /document/1/display_file
  # GET /document/1/display_file.json
  def display_file
    authorize @document

    unless @document.present?       &&
           @document.file.attached? &&
           @document.file_type =~ /^image\/.+$/i
      flash[:alert] = 'No file to display.'

      respond_to do |format|
        format.html { redirect_to item_documents_url, notice: 'No file to display.'}
      end
    end
  end

  def get_pact_documents
    @pact_files = get_pact_files

    respond_to do |format|
      format.json { render json: @pact_files }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_document
      if params[:document_id].present?
        @document = Document.find(params[:document_id])
      elsif params[:id].present?
        @document = Document.find(params[:id])
      end
      
      unless @project.present?
        @project = Project.find(@document.project_id) if @document.present?
      end
      
      unless @item.present?
        @item = Item.find(@document.item_id) if @document.present?
      end
    end

    def get_parent_document
      if params[:parent_id].present? && (params[:parent_id] =~ /^\d+$/)
        @parent_document = Document.find(params[:parent_id].to_i)
      else
        document         = if @document.present?
                            @document
                          elsif params[:document_id].present?
                            Document.find(params[:document_id])
                          elsif params[:id].present?
                            Document.find(params[:id])
                          end
        @parent_document = Document.find(document.parent_id) if document.present? &&
                                                              document.parent_id.present?
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def document_params
      params.require(
                       :document
                    )
            .permit(
                       :docid,
                       :name,
                       :category,
                       :revision,
                       :draft_revision,
                       :document_type,
                       :review_status,
                       :revdate,
                       :version,
                       :item_id,
                       :project_id,
                       :review_id,
                       :parent_id,
                       :file_path,
                       :file_type,
                       :file,
                       :release_document,
                       :upload_date
                   )
    end
end
