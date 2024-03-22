class DocumentCommentsController < ApplicationController
  include Common
  include DocumentConcern
  before_action :set_document_comment, only: [:show, :edit, :update, :destroy]
  before_action :get_project_byparam
  before_action :get_projects, only: [:new, :edit, :create, :update]
  before_action :get_item
  before_action :get_items, only: [:new, :edit, :create, :update]
  before_action :get_doc
  before_action :get_docs, only: [:new, :edit, :update]

  # GET /document_comments
  # GET /document_comments.json
  def index
    authorize :document_comment

    if session[:archives_visible] || params[:show_archived]
      @document_comments = DocumentComment.where(document_id: params[:document_id],
                                                 organization: current_user.organization)
    else
      @document_comments = DocumentComment.where(document_id: params[:document_id],
                                                 organization: current_user.organization,
                                                 archive_id: nil)
    end

    if params[:filter_field].present? && params[:filter_value]
      session[:dc_filter_field] = params[:filter_field]
      session[:dc_filter_value] = params[:filter_value]
      @document_comments        = @document_comments.to_a.delete_if do |document_comment|
        field                   = document_comment.attributes[params[:filter_field]].upcomment
        value                   = params[:filter_value].upcomment

        !field.index(value)
      end
    end

    @undo_path           = get_undo_path('document_comments',
                                         document_document_comments_path(@document))
    @redo_path           = get_redo_path('document_comments',
                                         document_document_comments_path(@document))
  end

  # GET /document_comments/1
  # GET /document_comments/1.json
  def show
    authorize :document_comment
    @undo_path         = get_undo_path('document_comments',
                                       document_document_comments_path(@document))
    @redo_path         = get_redo_path('document_comments',
                                       document_document_comments_path(@document))
  end

  # GET /document_comments/new
  def new
    authorize :document_comment
    @document_comment                = DocumentComment.new
    @document_comment.document_id    = @document.id
    @document_comment.project_id     = @document.project_id
    @document_comment.item_id        = @document.item_id
    @document_comment.requestedby    = current_user.email
    @document_comment.commentid      = @document.doccomment_count + 1
    @document_comment.docrevision    = @document.revision
    @document_comment.draft_revision = @document.draft_revision
    @document_comment.status         = 'Open'
    @undo_path                       = get_undo_path('document_comments',
                                                     document_document_comments_path(@document))
    @redo_path                       = get_redo_path('document_comments',
                                                     document_document_comments_path(@document))
  end

  # GET /document_comments/1/edit
  def edit
    authorize @document_comment

    @read_only = (@document_comment.status == 'Closed') && !current_user.fulladmin
    @undo_path = get_undo_path('document_comments',
                               document_document_comments_path(@document))
    @redo_path = get_redo_path('document_comments',
                               document_document_comments_path(@document))
  end

  # POST /document_comments
  # POST /document_comments.json
  def create
    authorize :document_comment

    params[:document_comment][:document_id] = @document.id         if !document_comment_params[:document_id].present? && @document.present?
    params[:document_comment][:project_id]  = @document.project_id if !document_comment_params[:project_id].present?  && @document.present?
    params[:document_comment][:item_id]     = @document.item_id    if !document_comment_params[:item_id].present?     && @document.present?
    params[:document_comment][:docrevision] = @document.revision   if !document_comment_params[:docrevision].present? && @document.present?
    @document_comment                       = DocumentComment.new(document_comment_params)

    # Check to see if the Document Comment ID already Exists.
    if DocumentComment.find_by(commentid:   @document_comment.commentid,
                               project_id:  @document.project_id,
                               item_id:     @document.item_id,
                               document_id: @document.id)
      @document_comment.errors.add(:commentid, :blank, message: "Duplicate ID: #{@document_comment.commentid}")

      respond_to do |format|
        format.html { render :new }
        format.json { render json: @system_requirement.errors, status: :unprocessable_entity }
      end
    else
      respond_to do |format|
          @data_change = DataChange.save_or_destroy_with_undo_session(@document_comment,
                                                                      'create',
                                                                      @document_comment.id,
                                                                      'document_comments')

        if @data_change.present?
          # Increment the global counter, and save the document.
          @document.doccomment_count += 1
          @data_change                = DataChange.save_or_destroy_with_undo_session(@document,
                                                                                    'update',
                                                                                    @document.id,
                                                                                    'documents',
                                                                                    @data_change.session_id)

          format.html { redirect_to [@document, @document_comment], notice: 'Document comment was successfully created.' }
          format.json { render :show, status: :created, location: @document_comment }
        else
          format.html { render :new }
          format.json { render json: @document_comment.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # PATCH/PUT /document_comments/1
  # PATCH/PUT /document_comments/1.json
  def update
    authorize @document_comment

    params[:document_comment][:document_id] = @document.id         if !document_comment_params[:document_id].present? && @document.present?
    params[:document_comment][:project_id]  = @document.project_id if !document_comment_params[:project_id].present?  && @document.present?
    params[:document_comment][:item_id]     = @document.item_id    if !document_comment_params[:item_id].present?     && @document.present?

    respond_to do |format|
      @data_change = DataChange.save_or_destroy_with_undo_session(document_comment_params,
                                                                  'update',
                                                                  params[:id],
                                                                  'document_comments')

      if @data_change.present?
        format.html { redirect_to [@document, @document_comment], notice: 'Document comment was successfully updated.' }
        format.json { render :show, status: :ok, location: @document_comment }
      else
        format.html { render :edit }
        format.json { render json: @document_comment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /document_comments/1
  # DELETE /document_comments/1.json
  def destroy
    authorize @document_comment
    @data_change = DataChange.save_or_destroy_with_undo_session(@document_comment,
                                                                'delete',
                                                                @document_comment.id,
                                                                'document_comments')

    respond_to do |format|
      format.html { redirect_to document_document_comments_url(@document), notice: 'Document comment was successfully removed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_document_comment
      @document_comment = DocumentComment.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def document_comment_params
      params.require(
                       :document_comment
                    )
            .permit(
                       :commentid,
                       :comment,
                       :docrevision,
                       :datemodified,
                       :status,
                       :requestedby,
                       :assignedto,
                       :item_id,
                       :project_id,
                       :document_id,
                       :draft_revision
                   )
    end
end
