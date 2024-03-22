class DocumentAttachmentsController < ApplicationController
  include Common
  include DocumentConcern
  before_action :set_document_attachment, only: [:show, :edit, :update, :destroy]
  before_action :get_project_byparam
  before_action :get_projects, only: [:new, :edit, :update]
  before_action :get_item
  before_action :get_items, only: [:new, :edit, :update]
  before_action :get_doc
  before_action :get_docs, only: [:new, :edit, :update]
  before_action :get_users, only: [:new, :edit, :update]

  # GET /document_attachments
  # GET /document_attachments.json
  def index
    authorize :document_attachment
    @item                   = Item.find(@document.item_id)

    if session[:archives_visible]
      @document_attachments = DocumentAttachment.where(document_id:  params[:document_id],
                                                       organization: current_user.organization)
    else
      @document_attachments = DocumentAttachment.where(document_id:  params[:document_id],
                                                       organization: current_user.organization,
                                                       archive_id:  nil)
    end

    if params[:filter_field].present? && params[:filter_value]
      session[:da_filter_field] = params[:filter_field]
      session[:da_filter_value] = params[:filter_value]
      @document_attachments     = @document_attachments.to_a.delete_if do |document_attachment|
        field                   = document_attachment.attributes[params[:filter_field]].upattachment
        value                   = params[:filter_value].upattachment

        !field.index(value)
      end
    end

    @undo_path              = get_undo_path('document_attachments',
                                            document_document_attachments_path(@document))
    @redo_path              = get_redo_path('document_attachments',
                                            document_document_attachments_path(@document))
  end

  # GET /document_attachments/1
  # GET /document_attachments/1.json
  def show
    authorize :document_attachment

    @undo_path = get_undo_path('document_attachments',
                                document_document_attachments_path(@document))
    @redo_path = get_redo_path('document_attachments',
                                document_document_attachments_path(@document))
  end

  # GET /document_attachments/new
  def new
    authorize :document_attachment
    @document_attachment             = DocumentAttachment.new
    @document_attachment.document_id = @document.id
    @document_attachment.project_id  = @document.project_id
    @document_attachment.item_id     = @document.item_id
    @document_attachment.user        = current_user.email
    @undo_path                       = get_undo_path('document_attachments',
                                                     document_document_attachments_path(@document))
    @redo_path                       = get_redo_path('document_attachments',
                                                     document_document_attachments_path(@document))
  end

  # GET /document_attachments/1/edit
  def edit
    authorize @document_attachment

    @undo_path = get_undo_path('document_attachments',
                                document_document_attachments_path(@document))
    @redo_path = get_redo_path('document_attachments',
                                document_document_attachments_path(@document))
  end

  # POST /document_attachments
  # POST /document_attachments.json
  def create
    authorize :document_attachment
    @document_attachment             = DocumentAttachment.new(document_attachment_params)
    @document_attachment.project_id  = @document.project_id
    @document_attachment.item_id     = @document.item_id
    @document_attachment.upload_date = DateTime.now

    respond_to do |format|
        @data_change = DataChange.save_or_destroy_with_undo_session(@document_attachment,
                                                                    'create',
                                                                    @document_attachment.id,
                                                                    'document_attachments')

      if @data_change.present?
        format.html { redirect_to document_document_attachments_path(@document), notice: 'Document attachment was successfully created.' }
        format.json { render :show, status: :created, location: @document_attachment }
      else
        format.html { render :new }
        format.json { render json: @document_attachment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /document_attachments/1
  # PATCH/PUT /document_attachments/1.json
  def update
    authorize @document_attachment

    @original_document_attachment              = DocumentAttachment.find(params[:id])
    params[:document_attachment][:upload_date] = DateTime.now()
    new_attachment                             = false

    if !@original_document_attachment.file.attached? &&
       document_attachment_params[:file].present?
       new_attachment                          = true
    end

    respond_to do |format|
      @data_change = DataChange.save_or_destroy_with_undo_session(document_attachment_params,
                                                                  'update',
                                                                  params[:id],
                                                                  'document_attachments')

      if @data_change.present?
        if new_attachment
          file                                 = document_attachment_params[:file]
          @new_document_attachment             = DocumentAttachment.find(params[:id])

          file.tempfile.rewind

          begin
            @new_document_attachment.file.attach(io:           file.tempfile,
                                                 filename:     file.original_filename,
                                                 content_type: file.content_type)
          rescue Errno::EACCES
            @new_document_attachment.file.attach(io:           file.tempfile,
                                                 filename:     file.original_filename,
                                                 content_type: file.content_type)
          end
        end

        format.html { redirect_to [@document, @document_attachment], notice: 'Document attachment was successfully updated.' }
        format.json { render :show, status: :ok, location: @document_attachment }
      else
        format.html { render :edit }
        format.json { render json: @document_attachment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /document_attachments/1
  # DELETE /document_attachments/1.json
  def destroy
    authorize @document_attachment
    @data_change = DataChange.save_or_destroy_with_undo_session(@document_attachment,
                                                                'delete',
                                                                @document_attachment.id,
                                                                'document_attachments')

    respond_to do |format|
      format.html { redirect_to document_document_attachments_path(@document), notice: 'Document attachment was successfully removed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_document_attachment
      @document_attachment = DocumentAttachment.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def document_attachment_params
      params.require(:document_attachment).permit(:file, :document_id, :item_id, :project_id, :user, :upload_date)
    end
end
