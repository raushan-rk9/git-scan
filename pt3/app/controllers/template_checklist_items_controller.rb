class TemplateChecklistItemsController < ApplicationController
  include Common

  before_action :set_template_checklist_item, only: [:show, :edit, :update, :destroy]
  before_action :set_template_checklist,      only: [:show, :edit, :update, :destroy]
  before_action :set_template,                only: [:show, :edit, :update, :destroy]
  before_action :get_undo

  # /templates/:template_id/template_checklists/:template_checklist_id/template_checklist_items(.:format)
  def index
    authorize :template_checklist_item

    @template_checklist_items = TemplateChecklistItem.where(template_checklist_id: @template_checklist.id, organization: current_user.organization).order(:clitemid) if @template_checklist.present?
  end

  # GET /templates/:template_id/template_checklists/:template_checklist_id/template_checklist_items/:id(.:format)
  def show
    authorize @template_checklist_item
  end

  # GET /templates/:template_id/template_checklists/:template_checklist_id/template_checklist_items/new(.:format)
  def new
    @template_checklist_item                       = TemplateChecklistItem.new
    @template_checklist_item.clitemid              = TemplateChecklistItem.maximum(:clitemid).next
    @template_checklist_item.template_checklist_id = @template_checklist.id if @template_checklist.present?
    @template_checklist_item.source                = Constants::AWC         if params[:awc].present?
  end

  def create
    authorize :template_checklist_item
  
    unless @template_checklist_item.present?
      @template_checklist_item                  = TemplateChecklistItem.new(template_checklist_item_params)
    end

    if @template_checklist.present?
      @template_checklist_item.template_checklist_id = @template_checklist.id
    end

    respond_to do |format|
      if @template_checklist_item.save
        format.html {
                      redirect_to template_template_checklist_template_checklist_item_path(@template, @template_checklist, @template_checklist_item),
                      notice: 'Template Checklist Item was successfully created.'
                    }
        format.json { render :show, status: :created }
      else
        format.html { render :new }
        format.json {
                      render json: @template_checklist_item.errors,
                      status:      :unprocessable_entity,
                      location:    @template_checklist
                    }
      end
    end
  end

  # /templates/:template_id/template_checklists/:template_checklist_id/template_checklist_items/:id/edit(.:format)
  def edit
    authorize @template_checklist_item
  end

  # PATCH, PUT /templates/:template_id/template_checklists/:template_checklist_id/template_checklist_items/:id(.:format)
  def update
    authorize @template_checklist_item

    respond_to do |format|
      @data_change = DataChange.save_or_destroy_with_undo_session(template_checklist_item_params,
                                                                  'update',
                                                                  params[:id],
                                                                  'template_checklist_items')

      if @data_change.present?
        format.html {
                      redirect_to template_template_checklist_template_checklist_items_path(@template, @template_checklist),
                      notice: 'Template Checklist item was successfully updated.'
                    }
        format.json {
                      render :show,
                      status: :ok,
                      location: @template_checklist_item
                    }
      else
        format.html { render :edit }
        format.json {
                      render json: @template_checklist_item.errors,
                      status:      :unprocessable_entity
                    }
      end
    end
  end

  # DELETE /template_checklist_items/1
  # DELETE /template_checklist_items/1.json
  def destroy
    unless @template_checklist_item.present?
      @template_checklist_item = TemplateChecklistItem.find(params[:id])
    end

    authorize @template_checklist_item

    @data_change = DataChange.save_or_destroy_with_undo_session(@template_checklist_item,
                                                                'delete',
                                                                @template_checklist_item.id,
                                                                'template_checklist_items')

    respond_to do |format|
      format.html {
                    redirect_to template_template_checklist_template_checklist_items_path(@template, @template_checklist),
                    notice: 'Template Checklist item was successfully removed.'
                  }
      format.json { head :no_content }
    end
  end

  # DELETE /template_checklist_items/1
  # DELETE /template_checklist_items/1.json
  def delete
    destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def get_undo
      set_template                unless @template.present?
      set_template_checklist      unless @template_checklist.present?
      set_template_checklist_item unless @template_checklist_item.present?

      @undo_path = get_undo_path('template_checklist_items',
                                 template_template_checklist_template_checklist_items_path(@template,
                                                                                           @template_checklist)) if @template.present? && @template_checklist.present?
      @redo_path = get_redo_path('template_checklist_items',
                                 template_template_checklist_template_checklist_items_path(@template,
                                                                                           @template_checklist)) if @template.present? && @template_checklist.present?
    end

    def set_template
      @template = if params[:template_id].present?
                    Template.find(params[:template_id])
                  elsif params[:template_id].present?
                    Template.find(params[:template_id])
                  end
    end

    def set_template_checklist
      @template_checklist = if params[:template_checklist_id].present?
                              TemplateChecklist.find(params[:template_checklist_id])
                            elsif params[:template_checklist_id].present?
                              TemplateChecklistItem.find(params[:template_checklist_id])
                            end
    end

    def set_template_checklist_item
      @template_checklist_item = if params[:id].present?
                                   TemplateChecklistItem.find(params[:id])
                                 elsif params[:template_checklist_item_id].present?
                                   @template_checklist_item = TemplateChecklistItem.find(params[:template_checklist_item_id])
                                 end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def template_checklist_item_params
      params.require(:template_checklist_item).permit(:clitemid,
                                                      :title,
                                                      :description,
                                                      :reference,
                                                      :passing,
                                                      :failing,
                                                      :status,
                                                      :note,
                                                      :template_checklist_id,
                                                      :source,
                                                      :minimumdal  => [],
                                                      :supplements => [])
    end
end
