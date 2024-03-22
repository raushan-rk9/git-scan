class TemplatesController < ApplicationController
  include Common

  respond_to    :docx

  before_action :set_template, only: [:show, :edit, :update, :destroy, :import, :export]
  before_action :get_undo

  # GET /templates
  # GET /templates.json
  def index
    authorize :template

    if params[:awc].present?
      @templates = Template.where(organization: current_user.organization,
                                  source:      Constants::AWC).order(:title)
    else
      templates  = Template.where(organization: current_user.organization).order(:title).to_a
      @templates = templates.delete_if { |template| template.source == Constants::AWC }
    end
  end

  # GET /templates/:id
  def show
    authorize @template
  end

  # GET /templates/new(.:format)
  def new
    @template        = Template.new
    @template.source = 'Airworthiness Certification Services'
  end

  def create
    authorize :template
  
    @template = Template.new(template_params)

    respond_to do |format|
      if @template.save
        format.html {
                      redirect_to templates_path,
                      notice: 'Template was successfully created.'
                    }
        format.json { render :show, status: :created }
      else
        format.html { render :new }
        format.json {
                      render json: @template.errors,
                      status:      :unprocessable_entity,
                      location:    @template
                    }
      end
    end
  end

  # GET /templates/:id/edit(.:format) 
  def edit
    authorize @template
  end

  # PATCH | PUT /templates/:id(.:format)
  def update
    authorize @template

    respond_to do |format|
      @data_change = DataChange.save_or_destroy_with_undo_session(template_params,
                                                                  'update',
                                                                  params[:id],
                                                                  'templates')

      if @data_change.present?
        format.html {
                      redirect_to templates_path,
                      notice: 'Template was successfully updated.'
                    }
        format.json {
                      render    :show,
                      status:   :ok,
                      location: @template
                    }
      else
        format.html { render :edit }
        format.json {
                      render json: @template.errors,
                      status:      :unprocessable_entity
                    }
      end
    end
  end

  # DELETE /templates/1
  # DELETE /templates/1.json
  def destroy
    unless @template.present?
      @template = Template.find(params[:id])
    end

    authorize @template

    @data_change = DataChange.save_or_destroy_with_undo_session(@template,
                                                                'delete',
                                                                @template.id,
                                                                'templates')

    respond_to do |format|
      format.html {
                    redirect_to templates_path,
                    notice: 'Template was successfully removed.'
                  }
      format.json { head :no_content }
    end
  end

  # DELETE /templates/1
  # DELETE /templates/1.json
  def delete
    destroy
  end

  def export
    authorize @template

    respond_to do |format|
      if params[:template_export].try(:has_key?, :export_type) && params[:template_export][:export_type] == 'HTML'
        format.html { render "templates/export_html", layout: false }
        format.json { render :show, status: :ok, location: @template }
      elsif params[:template_export].try(:has_key?, :export_type) && params[:template_export][:export_type] == 'PDF'
        format.html { redirect_to template_export_path(@template, format: :pdf) }
      elsif params[:template_export].try(:has_key?, :export_type) && params[:template_export][:export_type] == 'CSV'
        # Come back here using the csv format to generate the csv below.
        format.html { redirect_to template_export_path(@template, format: :csv) }
      elsif params[:template_export].try(:has_key?, :export_type) && params[:template_export][:export_type] == 'XLS'
        # Come back here using the xls format to generate the xls below.
        format.html { redirect_to template_export_path(@template, format: :xls) }
      elsif params[:template_export].try(:has_key?, :export_type) && params[:template_export][:export_type] == 'DOCX'
        # Come back here using the Docx format to generate the Docx below.
        if convert_data("TemplateItems.docx",
                        'templates/export_html.html.erb',
                         @item.present? ? @item.id : params[:item_id])
          format.html { redirect_to  template_export_path(filename: @converted_filename, format: :docx, starting_number: params[:md_export].try(:has_key?, :starting_number) ) }
        else
          flash[:error]  = @conversion_error
          params[:level] = 2

          go_back
        end
        format.html { redirect_to template_export_path(@template, format: :docx) }
      else
        format.html { render :export }
        format.json { render json: @template_template.errors, status: :unprocessable_entity }
        # If redirected using format => csv, generate the csv here.
        format.csv  { send_data @template.to_csv, filename: "#{@template.description}-TemplateItems.csv" }
        format.xls  { send_data @template.to_xls, filename: "#{@template.description}-TemplateItems.xls" }
        format.pdf  {
                       @no_links = true

                       render(pdf:      "#{@template.title}-TemplateItems",
                              template: 'templates/export_html.html.erb',
                              title:    'Templates: Export PDF | PACT',
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

  def import_template
    import                  = params[import_path]

    return false unless import.present?

    error                   = false
    id                      = import['template_select'].to_i if import['template_select'] =~ /^\d+$/
    file                    = import['file']

    if file.present?
      filename              = if file.path.present?
                                file.path
                              elsif file.tempfile.present?
                                file.tempfile.path
                              end
    end

    if !error
      if id.present?
        @template = Template.find(id)
      else
        flash[:alert]       = 'No  Selected'
        error               = true
      end
    end

    if !error
      if filename.present?
        @template = Template.find(id)
      else
        flash[:alert]       = 'No File Selected'
        error               = true
      end
    end

    if !((filename  =~ /^.+\.csv$/i)   ||
         ((filename =~ /^.+\.xlsx$/i)) ||
         ((filename =~ /^.+\.xls$/i))) && !error
      flash[:alert]   = 'You can only import a CSV, an xlsx or an XLS file'
      error           = true
    end

    if !error
      unless @template.from_file(filename)
        if @item.errors.messages.empty?
          flash[:alert]     = "Cannot import: #{file.original_filename}"
        else
          @item.errors.messages.each do |key, value|
            flash[:alert]  += "\n" + value 
          end
        end

        error               = true
      end
    end

    return !error
  end

  def import
    authorize :template

    @templates = Template.all

    if params[import_path].present?
      if import_template
        respond_to do |format|
          format.html {redirect_to templates_path(@template), notice: 'Template checklist items were successfully imported.' }
          format.json { head :no_content }
        end
      else
        respond_to do |format|
          format.html { redirect_to templates_path(@template) }
          format.json { render json: @item.errors, status: :unprocessable_entity }
        end
      end
    else
      respond_to do |format|
        format.html { render :import }
        format.json { render json: @template.errors, status: :unprocessable_entity }
      end
    end
  end

  def duplicate_global_templates
    authorize :template

    Template.duplicate_global_templates

    respond_to do |format|
      format.html { redirect_to templates_path(@template) }
      format.json { render json: @item.errors, status: :unprocessable_entity }
    end
  end

  def populate_global_templates
    authorize :template

    result          = PopulateTemplates.new.populate_templates

    if result
      flash[:info] = 'Templates populated.'

      respond_to do |format|
        format.html { redirect_to templates_path(@template) }
      end
    else
      flash[:alert] = 'Cannot Populate templates!'

      respond_to do |format|
        format.html { redirect_to templates_path(@template) }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def get_undo
      set_template unless @template.present?

      @undo_path = get_undo_path('templates', templates_path)
      @redo_path = get_redo_path('templates', templates_path)
    end

    def set_template
      @template   = Template.find(params[:id]) if params[:id].present?

      unless @template.present?
        @template = Template.find(params[:template_id]) if params[:template_id].present?
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def template_params
      params.require(:template).permit(:tlid,
                                       :title,
                                       :description,
                                       :template_type,
                                       :template_class,
                                       :notes,
                                       :source)
    end
end
