class ReviewAttachmentsController < ApplicationController
  include Common
  include ReviewConcern

  skip_before_action :verify_authenticity_token

  before_action :set_review_attachment, only: [:show, :edit, :update, :destroy, :download_file, :display_file]
  before_action :get_item
  before_action :get_items, only: [:new, :edit, :update]
  before_action :get_project_byparam
  before_action :get_projects, only: [:new, :edit, :update]
  before_action :get_review
  before_action :get_reviews, only: [:new, :edit, :update]
  before_action :get_users, only: [:new, :edit, :update]
  before_action :set_item_from_review_attachment

  # GET /review_attachments
  # GET /review_attachments.json
  def index
    authorize :review_attachment

    if session[:archives_visible]
      @review_attachments = ReviewAttachment.where(review_id:    params[:review_id],
                                                   organization: current_user.organization)
    else
      @review_attachments = ReviewAttachment.where(review_id:    params[:review_id],
                                                   organization: current_user.organization,
                                                   archive_id:  nil)
    end

    if params[:filter_field].present? && params[:filter_value]
      session[:ra_filter_field] = params[:filter_field]
      session[:ra_filter_value] = params[:filter_value]
      @review_attachments       = @review_attachments.to_a.delete_if do |review_attachment|
        field                   = review_attachment.attributes[params[:filter_field]].upitem
        value                   = params[:filter_value].upitem

        !field.index(value)
      end
    end

    @undo_path            = get_undo_path('review_attachments',
                                          review_review_attachments_path(@review))
    @redo_path            = get_redo_path('review_attachments',
                                          review_review_attachments_path(@review))
  end

  # GET /review_attachments/1
  # GET /review_attachments/1.json
  def show
    authorize :review_attachment

    @undo_path = get_undo_path('review_attachments',
                               review_review_attachment_path(@review,
                                                             @review_attachment))
    @redo_path = get_redo_path('review_attachments',
                               review_review_attachment_path(@review,
                                                             @review_attachment))

  end

  # GET /review_attachments/new
  def new
    authorize :review_attachment

    @pact_files                        = get_pact_files(@review.item_id)
    @review_attachment                 = ReviewAttachment.new
    @review_attachment.review_id       = @review.id
    @review_attachment.project_id      = @review.project_id
    @review_attachment.item_id         = @review.item_id
    @review_attachment.user            = current_user.email
    @review_attachment.attachment_type = Constants::REFERENCE_ATTACHMENT
    @undo_path                         = get_undo_path('review_attachments',
                                                       new_review_review_attachment_path(@review))
    @redo_path                         = get_redo_path('review_attachments',
                                                       new_review_review_attachment_path(@review))
  end

  # GET /review_attachments/1/edit
  def edit
    authorize @review_attachment

    @pact_files = get_pact_files(@review.item_id)
    @undo_path  = get_undo_path('review_attachments',
                                edit_review_review_attachment_path(@review,
                                                                   @review_attachment))
    @redo_path  = get_redo_path('review_attachments',
                                edit_review_review_attachment_path(@review,
                                                                   @review_attachment))
  end

  # POST /review_attachments
  # POST /review_attachments.json
  def create
    authorize :review_attachment

    session_id                                          = nil
    params[:review_attachment][:project_id]             = @review.project_id if !review_attachment_params[:project_id].present? && @review.present?
    params[:review_attachment][:item_id]                = @review.item_id    if !review_attachment_params[:item_id].present?    && @review.present?
    params[:review_attachment][:review_id]              = @review.id         if !review_attachment_params[:review_id].present?  && @review.present?
    params[:review_attachment][:user]                   = current_user.email unless params[:review_attachment][:user].present?

    if review_attachment_params['link_type'] == 'PACT'
      params['review_attachment']['link_link']          = review_attachment_params['pact_file']

      if review_attachment_params['attachment_type'] == Constants::ReviewAttachmentType_hash['REVIEW']
        document_id                                       = nil
        document                                          = nil

        if review_attachment_params['pact_file'] =~ /^.*\/(\d+)$/
          document_id = $1
        end

        if document_id.present?
          document = Document.find_by(id: document_id)
        end

        if document.present?
          document.review_id                            = @review.id
          @data_change                                  = DataChange.save_or_destroy_with_undo_session(document,
                                                                                                       'update',
                                                                                                       document.id,
                                                                                                       'documents',
                                                                                                       session_id)
          session_id                                    = @data_change.session_id if @data_change.present?
        end
      end
    elsif  review_attachment_params['link_type'] == 'ATTACHMENT'
      file                                              = review_attachment_params['file']

      if file.present?
        params['review_attachment']['link_link']        = file.original_filename
      end
    end

    if review_attachment_params['link_type'] != 'PACT'
      if review_attachment_params['link_link'] =~ /^.*\/(.+)$/
        params['review_attachment']['link_description'] = $1
      else
        params['review_attachment']['link_description'] = review_attachment_params['link_link']
      end
    end

    @review_attachment             = ReviewAttachment.new(review_attachment_params)
    @review_attachment.upload_date = DateTime.now()

    respond_to do |format|
        @data_change                                    = DataChange.save_or_destroy_with_undo_session(@review_attachment,
                                                                                                       'create',
                                                                                                       @review_attachment.id,
                                                                                                       'review_attachments',
                                                                                                       session_id)
        session_id                                      = @data_change.session_id if @data_change.present?

      if @data_change.present?
        format.html { redirect_to review_review_attachments_path(@review), notice: 'Review attachment was successfully created.' }
        format.json { render :show, status: :created, location: @review_attachment }
      else
        format.html { render :new }
        format.json { render json: @review_attachment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /review_attachments/1
  # PATCH/PUT /review_attachments/1.json
  def update
    authorize @review_attachment

    @review_attachment.assign_attributes(review_attachment_params)

    @review_attachment.upload_date            = DateTime.now()
    session_id                                = nil
    okay                                      = @review.present?
    error                                     = "Review not found." unless okay
    file                                      = review_attachment_params['file']

    if okay
      if @review_attachment.link_type == Constants::PACT_ATTACHMENT
        @review_attachment.link_link          = review_attachment_params['pact_file']
        id                                    = if @review_attachment.link_link =~ /^.*\/(.+)$/
                                                  Regexp.last_match[1]
                                                else
                                                  @review_attachment.link_link
                                                end
        document                              = Document.find_by(id: id) if (Constants::ReviewAttachmentType_hash.key(@review_attachment.attachment_type) == 'REVIEW') &&
                                                                             (review_attachment_params['pact_file'] =~ /^.*\/(\d+)$/)

        if document.present?
          @review_attachment.link_description = document.name
          document.review_id                  = @review.id
          data_change                         = DataChange.save_or_destroy_with_undo_session(document,
                                                                                             'update',
                                                                                             document.id,
                                                                                             'documents',
                                                                                             session_id)

          if data_change.present?
            session_id                        = data_change.session_id 
          else
            okay                              = false
            error                             = "Can't update document: #{document.name}."
          end
        end
      elsif @review_attachment.link_type == Constants::UPLOAD_ATTACHMENT && file.present?
        @review_attachment.link_link          = file.original_filename
      elsif @review_attachment.link_type == Constants::EXTERNAL_ATTACHMENT
        @review_attachment.link_description   = if @review_attachment.link_link =~ /^.*\/(.+)$/
                                                  Regexp.last_match[1]
                                                else
                                                  @review_attachment.link_link
                                                end
      end
    end

    if okay
      data_change                             = DataChange.save_or_destroy_with_undo_session(@review_attachment,
                                                                                             'update',
                                                                                             @review_attachment.id,
                                                                                             'review_attachments',
                                                                                             session_id)

      if data_change.present?
        session_id                            = data_change.session_id 
      else
        okay                                  = false
        error                                 = "Can't update review attachment: #{@review_attachment.id}."
      end
    end

    if okay && file.present?
      okay                                    = @review_attachment.replace_file(file,
                                                                                session_id)
      error                                   = "Can't attach #{file.original_filename}." if !okay
    end

    respond_to do |format|
      if okay
        format.html { redirect_to [@review, @review_attachment], notice: 'Review attachment was successfully updated.' }
        format.json { render :show, status: :ok, location: @review_attachment }
      else
        format.html { render :edit, alert: "An Error occured while saving review attachment: #{error}." }
        format.json { render json: @review_attachment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /review_attachments/1
  # DELETE /review_attachments/1.json
  def destroy
    authorize @review_attachment

    @data_change = DataChange.save_or_destroy_with_undo_session(@review_attachment,
                                                                'delete',
                                                                @review_attachment.id,
                                                                'review_attachments')

    respond_to do |format|
      format.html { redirect_to review_review_attachments_path(@review), notice: 'Review attachment was successfully removed.' }
      format.json { head :no_content }
    end
  end

  # GET /aource_code/1/download_file
  # GET /review_attachment/1/download_file.json
  def download_file
    authorize @review_attachment

    if @review_attachment.present?          &&
       @review_attachment.link_type.present? &&
       @review_attachment.link_link.present?
      file = @review_attachment.get_file_contents

      if file.kind_of?(ActiveStorage::Attached::One)
       send_data(file.download,
                 filename:     file.filename.to_s,
                 contant_type: file.content_type)
      elsif file.kind_of?(String)
        send_data(file,
                  filename: File.basename(@review_attachment.file_name))
      elsif file.kind_of?(URI::HTTP)
        redirect_to file.to_s, target: "_blank"

        return
      else
        respond_to do |format|
          format.html { redirect_to item_review_attachments_url, error: 'No file to download.'}
          format.json { render json: @action_item.errors,  status: :unprocessable_entity }
        end
      end
    else
      flash[:error]  = 'No file to download'

      respond_to do |format|
        format.html { redirect_to item_review_attachments_url, error: 'No file to download.'}
        format.json { render json: @action_item.errors,  status: :unprocessable_entity }
      end
    end
  end

  # GET /review_attachment/1/display_file
  # GET /review_attachment/1/display_file.json
  def display_file
    authorize @review_attachment

    if @review_attachment.present?          &&
       @review_attachment.link_type.present? &&
       @review_attachment.link_link.present?
      file                 = @review_attachment.get_file_contents

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
        format.html { redirect_to item_review_attachments_url, error: 'No file to display.'}
        format.json { render json: @action_item.errors,  status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_review_attachment
      if params[:id].present?
        @review_attachment = ReviewAttachment.find(params[:id])
      elsif params[:review_attachment_id].present?
        @review_attachment = ReviewAttachment.find(params[:review_attachment_id])
      end
    end

    def set_item_from_review_attachment
      return if @item.present?

      if @review.present?
        @item = Item.find_by(id: @review.item_id)
      elsif @review_attachment.present?
        @review = Review.find_by(id: @review_attachment.review_id)
        @item   = Item.find_by(id: @review.item_id) if @review.present?
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def review_attachment_params
      params.require(
                       :review_attachment
                    )
            .permit(
                       :link_type,
                       :link_description,
                       :link_link,
                       :file,
                       :pact_file,
                       :review_id,
                       :user,
                       :item_id,
                       :project_id,
                       :attachment_type,
                       :upload_date
                    )
    end
end
