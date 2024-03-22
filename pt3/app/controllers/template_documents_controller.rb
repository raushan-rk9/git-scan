class TemplateDocumentsController < ApplicationController
  include Common

  before_action :set_template, only: [:index, :show, :edit, :update, :destroy, :duplicate, :download]
  skip_before_action :verify_authenticity_token, only: [:duplicate]
  before_action :get_undo

  # GET /templates/:template_id/template_documents(.:format)
  def index
    authorize :template_document

    if params[:awc].present?
      @template_documents = if (@template.present?)
                              TemplateDocument.where(template_id: @template.id,
                                                     organization: current_user.organization,
                                                     source:      Constants::AWC).order(:document_id)
                            else
                              TemplateDocument.where(organization: current_user.organization,
                                                     source:      Constants::AWC).order(:document_id)
                            end
    else
      template_documents  = if (@template.present?)
                              TemplateDocument.where(template_id: @template.id,
                                                     organization: current_user.organization).order(:document_id).to_a
                            else
                              TemplateDocument.where(organization: current_user.organization).order(:document_id).to_a
                            end

      @template_documents   = template_documents.delete_if { |doc| doc.source == Constants::AWC }
    end
  end

  # GET /templates/:template_id/template_documents/:id(.:format)
  def show
    authorize @template_document
  end

  # GET /templates/:template_id/template_documents/new(.:format)
  def new
    query                             = if params[:awc].present?
                                          'template_id = ? AND organization = ? AND source = ?'
                                        else
                                          'template_id = ? AND organization = ? AND source != ?'
                                        end
    max_id                            = TemplateDocument.where(query,
                                                               @template.id,
                                                               current_user.organization,
                                                               Constants::AWC).maximum(:document_id)
    @template_document                = TemplateDocument.new
    @template_document.document_id    = max_id.present? ? max_id.next : 1
    @template_document.document_type  = 'Template'
    @template_document.template_id    = @template.id   if @template.present?
    @template_document.source         = Constants::AWC if params[:awc].present?
    @template_document.draft_revision = '0.0'
  end

  def create
    authorize :template_document
  
    unless @template_document.present?
      @template_document = TemplateDocument.new(template_document_params)
    end

    @template_document.template_id = @template.id if @template.present?
    @template_document.upload_date = DateTime.now()

    respond_to do |format|
      if @template_document.save
        format.html {
                      redirect_to template_template_documents_path(@template),
                      notice: 'Template Document was successfully created.'
                    }
        format.json { render :show, status: :created }
      else
        format.html { render :new }
        format.json {
                      render json: @template_document.errors,
                      status:      :unprocessable_entity,
                      location:    @template_document
                    }
      end
    end
  end

  # /templates/:template_id/template_documents/:id/edit(.:format)
  def edit
    authorize @template_document
  end

  # PATCH, PUT /templates/:template_id/template_documents/:id(.:format)
  def update
    authorize @template_document

    @original_template_document = TemplateDocument.find(params[:id])
    new_attachment              = false

    if template_document_params[:file].present? &&
       template_document_params[:file].content_type.present?
      params[:template_document][:content_type] = template_document_params[:file].content_type
    end

    if !@original_template_document.file.attached? &&
       template_document_params[:file].present?
       new_attachment           = true
    end

    respond_to do |format|
      if template_document_params[:new_document_name].present?
        query                                    = if params[:awc].present?
                                                        'template_id = ? AND organization = ? AND source = ?'
                                                      else
                                                        'template_id = ? AND organization = ? AND source != ?'
                                                      end
        max_id                                   = TemplateDocument.where(query,
                                                                          @template.id,
                                                                          current_user.organization,
                                                                          Constants::AWC).maximum(:document_id)
        params[:awc]                             = nil
        @template                                = find_or_create_template()
        params[:template_document][:document_id] = max_id.present? ? max_id.next : 1
        params[:template_document][:template_id] = @template.id
        params[:template_document][:source]      = current_user.organization
        params[:template_document][:title]       = template_document_params[:new_document_name]
        @template_document                       = TemplateDocument.new(template_document_params)
        @template_document.upload_date           = DateTime.now()
        @data_change                             = DataChange.save_or_destroy_with_undo_session(@template_document,
                                                                                                'create',
                                                                                                nil,
                                                                                                'template_documents')
      else
        @data_change                             = DataChange.save_or_destroy_with_undo_session(template_document_params,
                                                                                                'update',
                                                                                                params[:id],
                                                                                                'template_documents')
      end

      if @data_change.present?
        if new_attachment
          file                   = template_document_params[:file]
          @new_template_document = TemplateDocument.find(params[:id])

          file.tempfile.rewind

          begin
            @new_template_document.file.attach(io:           file.tempfile,
                                               filename:     file.original_filename,
                                               content_type: file.content_type)
          rescue Errno::EACCES
            @new_template_document.file.attach(io:           file.tempfile,
                                               filename:     file.original_filename,
                                               content_type: file.content_type)
          end
        elsif template_document_params[:new_document_name].present? && @original_template_document.file.attached?
          begin
            @template_document.file.attach(io:           StringIO.new(@original_template_document.file.download),
                                           filename:     @original_template_document.file.filename,
                                           content_type: @original_template_document.file.content_type)
          rescue Errno::EACCES
            @template_document.file.attach(io:           StringIO.new(@original_template_document.file.download),
                                           filename:     @original_template_document.file.filename,
                                           content_type: @original_template_document.file.content_type)
          end
        end

        format.html {
                      redirect_to template_template_documents_path(@template),
                      notice: 'Template Document was successfully updated.'
                    }
        format.json {
                      render    :show,
                      status:   :ok,
                      location: @template_document
                    }
      else
        format.html { render :edit }
        format.json {
                      render json: @template_document.errors,
                      status:      :unprocessable_entity
                    }
      end
    end
  end

  # DELETE /template_documents/1
  # DELETE /template_documents/1.json
  def destroy
    authorize @template_document

    unless @template_document.present?
      @template_document = TemplateDocument.find(params[:id])
    end

    @data_change = DataChange.save_or_destroy_with_undo_session(@template_document,
                                                                'delete',
                                                                @template_document.id,
                                                                'template_documents')

    respond_to do |format|
      format.html {
                    redirect_to template_template_documents_path(@template),
                    notice: 'Template Document was successfully removed.'
                  }
      format.json { head :no_content }
    end
  end

  # DELETE /template_documents/1
  # DELETE /template_documents/1.json
  def delete
    destroy
  end

  def duplicate
    authorize @template_document

    if request.method == 'POST'

      new_title = params[:new_title]
      new_dal   = params[:new_dal]

      @template_document.duplicate_document(new_title, new_dal)

      respond_to do |format|
        format.html {
                      redirect_to template_template_documents_path(@template),
                      notice: 'Template Document was successfully Duplicated..'
                    }
        format.json { head :no_content }
      end
    end
  end

  def download
    authorize @template_document

    if (@template_document.present?          &&
        @template_document.filename.present? &&
        File.readable?(@template_document.filename))
      send_file(@template_document.filename,
                filename: File.basename(@template_document.filename),
                type: @template_document.file_type)
    else
      respond_to do |format|
        format.html { redirect_to template_template_documents_url(@template), error: 'No File found: #{@template_document.filename}.'}
        format.json { render json: @action_item.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def get_undo
      set_template          unless  @template.present?
      set_template_document unless @template_document.present?

      @undo_path = get_undo_path('template_documents',
                                 template_template_documents_path(@template)) if @template.present?
      @redo_path = get_redo_path('template_documents',
                                 template_template_documents_path(@template)) if @template.present?
    end

    def find_or_create_template(force = false)
      result            = nil

      if params[:awc].present?
        templates       = Template.where(organization: current_user.organization,
                                         source:       Constants::AWC)

        return nil unless templates.present? || force
      else
        templates       = Template.where(organization: current_user.organization).to_a
                                  .delete_if { |template| template.source == Constants::AWC }
      end

      if templates.present?
        result          = templates.first

        if templates.length > 1
          templates.each do |template|
            if template.template_document.length > 0
              result    = template
  
              break;
            end
          end
        end
      else
        template        = Template.new()
        template.tlid   = Template.maximum(:tlid).next
        template.title  = if params[:awc].present?
                            "#{Constants::AWC} Template"
                          else
                            'Organization Template'
                          end
        template.source = if params[:awc].present?
                            Constants::AWC
                          else
                            current_user.organization
                          end

        template.save

        result = template
      end

      return result
    end

    def set_template(force = false)
      @template = if params[:template_id].present?
                    Template.find(params[:template_id])
                  elsif params[:template_id].present?
                    Template.find(params[:template_id])
                  end
      @template = find_or_create_template(force) unless @template || params[:awc]
    end

    def set_template_document
      if params[:id].present?
        @template_document = TemplateDocument.find(params[:id])
      elsif params[:template_document_id].present?
        @template_document = TemplateDocument.find(params[:template_document_id])
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def template_document_params
      params.require(
                       :template_document
                    )
            .permit(
                       :document_id,
                       :title,
                       :description,
                       :docid,
                       :name,
                       :dal,
                       :category,
                       :document_type,
                       :document_class,
                       :file_type,
                       :notes,
                       :template_id,
                       :file,
                       :new_title,
                       :new_dal,
                       :source,
                       :new_document_name,
                       :revision,
                       :draft_revision,
                       :upload_date
                   )
    end
end
