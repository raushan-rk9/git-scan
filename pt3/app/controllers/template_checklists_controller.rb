class TemplateChecklistsController < ApplicationController
  include Common

  respond_to    :docx

  before_action :set_template,           only: [:index, :show, :edit, :update, :destroy, :export, :import]
  before_action :set_template_checklist, only: [:show, :edit, :update, :destroy, :export, :import]
  before_action :get_undo

  # GET /templates/:template_id/template_checklists(.:format)
  def index
    authorize :template_checklist

    if params[:awc].present?
      @template_checklists = if (@template.present?)
                               TemplateChecklist.where(template_id: @template.id,
                                                       source:      Constants::AWC,
                                                       organization: current_user.organization).order(:clid)
                             else
                               TemplateChecklist.where(source:      Constants::AWC,
                                                       organization: current_user.organization).order(:clid)
                             end
    else
      template_checklists  = if (@template.present?)
                               TemplateChecklist.where(template_id: @template.id,
                                                       organization: current_user.organization).order(:clid).to_a
                             else
                               TemplateChecklist.where(organization: current_user.organization).order(:clid).to_a
                             end

      @template_checklists   = template_checklists.delete_if { |list| list.source == Constants::AWC }
    end
  end

  # GET /templates/:template_id/template_checklists/:id(.:format)
  def show
    authorize @template_checklist
  end

  # GET /templates/:template_id/template_checklists/new(.:format)
  def new
    @template_checklist                = TemplateChecklist.new
    @template_checklist.clid           = TemplateChecklist.maximum(:clid).next
    @template_checklist.template_id    = @template.id   if @template.present?
    @template_checklist.source         = Constants::AWC if params[:awc].present?
    @template_checklist.draft_revision = Constants::INITIAL_VERSION
  end

  def create
    authorize :template_checklist
  
    unless @template_checklist.present?
      @template_checklist = TemplateChecklist.new(template_checklist_params)
    end

    @template_checklist.template_id = @template.id if @template.present?

    respond_to do |format|
      if @template_checklist.save
        format.html {
                      redirect_to template_template_checklists_path(@template),
                      notice: 'Template Checklist was successfully created.'
                    }
        format.json { render :show, status: :created }
      else
        format.html { render :new }
        format.json {
                      render json: @template_checklist.errors,
                      status:      :unprocessable_entity,
                      location:    @template_checklist
                    }
      end
    end
  end

  # /templates/:template_id/template_checklists/:id/edit(.:format)
  def edit
    authorize @template_checklist
  end

  # PATCH, PUT /templates/:template_id/template_checklists/:id(.:format)
  def update
    authorize @template_checklist

    respond_to do |format|
      if template_checklist_params[:new_checklist_name].present?
        @original_template_checklist_id           = params[:id]
        params[:awc]                              = nil
        @template                                 = find_or_create_template()
        params[:template_checklist][:clid]        = TemplateChecklist.maximum(:clid).next
        params[:template_checklist][:template_id] = @template.id
        params[:template_checklist][:source]      = current_user.organization
        params[:title]                            = template_checklist_params[:new_checklist_name]
        @template_checklist                       = TemplateChecklist.new(template_checklist_params)
        @data_change                              = DataChange.save_or_destroy_with_undo_session(@template_checklist,
                                                                                                 'create',
                                                                                                 nil,
                                                                                                 'template_checklists')

        if @data_change.present?
          clone_checklist(@original_template_checklist_id,
                          @template_checklist.id,
                          @data_change.session_id)
        end
      else
        @data_change                              = DataChange.save_or_destroy_with_undo_session(template_checklist_params,
                                                                                                 'update',
                                                                                                 params[:id],
                                                                                                 'template_checklists')
      end

      if @data_change.present?
        format.html {
                      redirect_to template_template_checklists_path(@template),
                      notice: 'Template Checklist was successfully updated.'
                    }
        format.json {
                      render    :show,
                      status:   :ok,
                      location: @template_checklist
                    }
      else
        format.html { render :edit }
        format.json {
                      render json: @template_checklist.errors,
                      status:      :unprocessable_entity
                    }
      end
    end
  end

  # DELETE /template_checklists/1
  # DELETE /template_checklists/1.json
  def destroy
    authorize @template_checklist

    unless @template_checklist.present?
      @template_checklist = TemplateChecklist.find(params[:id])
    end

    @data_change = DataChange.save_or_destroy_with_undo_session(@template_checklist,
                                                                'delete',
                                                                @template_checklist.id,
                                                                'template_checklists')

    respond_to do |format|
      format.html {
                    redirect_to template_template_checklists_path(@template),
                    notice: 'Template Checklist was successfully removed.'
                  }
      format.json { head :no_content }
    end
  end

  # DELETE /template_checklists/1
  # DELETE /template_checklists/1.json
  def delete
    destroy
  end

  def export
    authorize @template_checklist

    respond_to do |format|
      if params[:template_checklist_export].try(:has_key?, :export_type) && params[:template_checklist_export][:export_type] == 'HTML'
        format.html { render "template_checklists/export_html", layout: false }
        format.json { render :show, status: :ok, location: @template_checklist }
      elsif params[:template_checklist_export].try(:has_key?, :export_type) && params[:template_checklist_export][:export_type] == 'PDF'
        format.html { redirect_to template_template_checklist_export_path(@template.id, @template_checklist, format: :pdf) }
      elsif params[:template_checklist_export].try(:has_key?, :export_type) && params[:template_checklist_export][:export_type] == 'CSV'
        # Come back here using the csv format to generate the csv below.
        format.html { redirect_to template_template_checklist_export_path(@template.id, @template_checklist, format: :csv) }
      elsif params[:template_checklist_export].try(:has_key?, :export_type) && params[:template_checklist_export][:export_type] == 'XLS'
        # Come back here using the xls format to generate the xls below.
        format.html { redirect_to template_template_checklist_export_path(@template.id, @template_checklist, format: :xls) }
      elsif params[:template_checklist_export].try(:has_key?, :export_type) && params[:template_checklist_export][:export_type] == 'DOCX'
        # Come back here using the Docx format to generate the Docx below.
        if convert_data("TemplateChecklistItems.docx",
                        'template_checklists/export_html.erb',
                         @item.present? ? @item.id : params[:item_id])
          format.html { redirect_to  template_template_checklist_export_path(filename: @converted_filename, format: :docx, starting_number: params[:md_export].try(:has_key?, :starting_number) ) }
        else
          flash[:error]  = @conversion_error
          params[:level] = 2

          go_back
        end
      else
        format.html { render :export }
        format.json { render json: @template_template_checklist.errors, status: :unprocessable_entity }
        # If redirected using format => csv, generate the csv here.
        format.csv  { send_data @template_checklist.to_csv, filename: "#{@template_checklist.description}-TemplateChecklistItems.csv" }
        format.xls  { send_data @template_checklist.to_xls, filename: "#{@template_checklist.description}-TemplateChecklistItems.xls" }
        format.pdf  {
                       @no_links = true

                       render(pdf:      "#{@template_checklist.description}-TemplateChecklistItems",
                              template: 'template_checklists/export_html.html.erb',
                              title:    'Template Checklists: Export PDF | PACT',
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

  def import_template_checklist
    import                  = params[import_path]

    return false unless import.present?

    error                   = false
    id                      = import['template_checklist_select'].to_i if import['template_checklist_select'] =~ /^\d+$/
    file                    = import['file']
    awc_template            = import['awc_template']

    if file.present?
      filename              = if file.path.present?
                                file.path
                              elsif file.tempfile.present?
                                file.tempfile.path
                              end
    end

    if !error
      if id.present?
        @template_checklist = TemplateChecklist.find(id)
      else
        flash[:alert]       = 'No Checklist Selected'
        error               = true
      end
    end

    if !error
      if filename.present?
        @template_checklist = TemplateChecklist.find(id)
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
      result = if awc_template == '1'
                 @template_checklist.from_patmos_template(filename)
               else
                 @template_checklist.from_file(filename)
               end

      unless result
        flash[:alert]       = "Cannot import: #{file.original_filename}"
        error               = true
      end
    end

    return !error
  end

  def import
    authorize :template_checklist

    if params[import_path].present?
      if import_template_checklist
        respond_to do |format|
          format.html {redirect_to template_template_checklists_path(@template), notice: 'Template checklist items were successfully imported.' }
          format.json { head :no_content }
        end
      else
        respond_to do |format|
          format.html { redirect_to template_template_checklists_path(@template) }
          format.json { render json: {}, status: :unprocessable_entity }
        end
      end
    else
      respond_to do |format|
        format.html { render :import }
        format.json { render json: @template_checklist.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def get_undo
      set_template          unless  @template.present?
      set_template_checklist unless @template_checklist.present?

      @undo_path = get_undo_path('template_checklists',
                                 template_template_checklists_path(@template)) if @template.present?
      @redo_path = get_redo_path('template_checklists',
                                 template_template_checklists_path(@template)) if @template.present?
    end

    def find_or_create_template(force = false)
      result            = nil

      if params[:awc].present?
        templates       = Template.where(organization: current_user.organization,
                                        source:      Constants::AWC)

        return nil unless templates.present? || force
      else
        templates       = Template.where(organization: current_user.organization).to_a
                                  .delete_if { |template| template.source == Constants::AWC }
      end

      if templates.present?
        result          = templates.first

        if templates.length > 1
          templates.each do |template|
            if template.template_checklist.length > 0
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

    def clone_checklist(original_template_checklist_id,
                        new_template_checklist_id,
                        session_id)
      checklist_items = TemplateChecklistItem.where(template_checklist_id: original_template_checklist_id)

      checklist_items.each do |checklist_item|
        checklist_item                       = checklist_item.dup
        checklist_item.id                    = nil
        checklist_item.template_checklist_id = new_template_checklist_id

        DataChange.save_or_destroy_with_undo_session(checklist_item,
                                                     'create',
                                                     nil,
                                                     'checklist_items',
                                                     session_id)
      end
    end

    def set_template(force = false)
      @template = if params[:template_id].present?
                    Template.find(params[:template_id])
                  elsif params[:template_id].present?
  
                  Template.find(params[:template_id])
                  end

      @template = find_or_create_template(force) unless @template || params[:awc]
    end

    def set_template_checklist
      if params[:id].present?
        @template_checklist = TemplateChecklist.find(params[:id])
      elsif params[:template_checklist_id].present?
        @template_checklist = TemplateChecklist.find(params[:template_checklist_id])
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def template_checklist_params
      params.require(:template_checklist).permit(:clid,
                                                 :title,
                                                 :description,
                                                 :checklist_type,
                                                 :checklist_class,
                                                 :notes,
                                                 :template_id,
                                                 :source,
                                                 :new_checklist_name,
                                                 :filename,
                                                 :revision,
                                                 :draft_revision
                                                )
    end
end
