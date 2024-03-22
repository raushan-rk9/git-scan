class ChecklistItemsController < ApplicationController
  include Common
  before_action :set_checklist_item, only: [:show, :edit, :update, :destroy]
  before_action :get_items, only: [:new, :edit, :update]
  before_action :get_project_byparam
  before_action :get_projects, only: [:new, :edit, :update]
  before_action :get_review
  before_action :get_reviews, only: [:new, :edit, :update]
  before_action :get_review_item

  # GET /checklist_items
  # GET /checklist_items.json
  def index
    authorize :checklist_item

    if @review.present?
      @checklist_items = ChecklistItem.where(review_id:    @review.id,
                                             organization: current_user.organization)
    else
      @checklist_items = []
    end

    if params[:filter_field].present? && params[:filter_value]
      session[:cli_filter_field] = params[:filter_field]
      session[:cli_filter_value] = params[:filter_value]
      @checklist_items           = @checklist_items.to_a.delete_if do |checklist_item|
        field                    = checklist_item.attributes[params[:filter_field]].upitem
        value                    = params[:filter_value].upitem

        !field.index(value)
      end
    end

    if @review.present?
      @undo_path       = get_undo_path('checklist_items',
                                       item_review_path(@review.item, @review))
      @redo_path       = get_redo_path('checklist_items',
                                       item_review_path(@review.item, @review))
    end
  end

  # GET /checklist_items/1
  def show

    unless @review.present?
      @review = Review.find(params["review_id"])
    end

    authorize @checklist_item
  end

  # GET /reviews/:review_id/checklist_items/new
  def new
    @checklist_item            = ChecklistItem.new
    @checklist_item.review_id  = @review.id if @review.present?
  end

  def create
    authorize :checklist_item

    params[:checklist_item][:review_id] = @review.id if !checklist_item_params[:review_id].present? && @review.present?

    @checklist_item = ChecklistItem.new(checklist_item_params)

    unless @review.present?
      @review = Review.find(params["review_id"])
    end

    unless @checklist_item.review_id.present?
      @checklist_item.review_id = @review.id
    end

    respond_to do |format|
      if @checklist_item.save
        format.html { redirect_to item_review_path(@item, @review), notice: 'Checklist item was successfully created.' }
        format.json { render :show, status: :created, location: @project }
      else
        format.html { render :new }
        format.json { render json: @checklist_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /checklist_items/1/edit
  def edit
    authorize @checklist_item

    if @review.present?
      @undo_path       = get_undo_path('checklist_items',
                                       item_review_path(@review.item, @review))
      @redo_path       = get_redo_path('checklist_items',
                                       item_review_path(@review.item, @review))
    end
  end

  # PATCH/PUT /checklist_items/1
  # PATCH/PUT /checklist_items/1.json
  def update
    authorize @checklist_item

    params[:checklist_item][:review_id] = @review.id if !checklist_item_params[:review_id].present? && @review.present?

    respond_to do |format|
      @data_change = DataChange.save_or_destroy_with_undo_session(checklist_item_params,
                                                                  'update',
                                                                  params[:id],
                                                                  'checklist_items')

      if @data_change.present? && @review.present?
        @review.version = increment_int(@review.version)
        @data_change    = DataChange.save_or_destroy_with_undo_session(@review,
                                                                       'update',
                                                                       @review.id,
                                                                         'reviews')

          format.html { redirect_to item_review_path(@review.item, @review), notice: 'Checklist item was successfully updated.' }
          format.json { render :show, status: :ok, location: @checklist_item }
      else
        format.html { render :edit }
        format.json { render json: @checklist_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /checklist_items/1
  # DELETE /checklist_items/1.json
  def destroy
    unless @checklist_item.present?
      @checklist_item = ChecklistItem.find(params["checklist_item_id"])
    end

    authorize @checklist_item
    @data_change = DataChange.save_or_destroy_with_undo_session(@checklist_item,
                                                                'delete',
                                                                @checklist_item.id,
                                                                'checklist_items')


    if @review.present?
      @review.version = increment_int(@review.version)
      @data_change    = DataChange.save_or_destroy_with_undo_session(@review,
                                                                     'update',
                                                                     @review.id,
                                                                     'reviews',
                                                                     @data_change.session_id)
      respond_to do |format|
        format.html { redirect_to item_review_path(@review.item_id, @review), notice: 'Checklist item was successfully removed.' }
        format.json { head :no_content }
      end
    end
  end

  # DELETE /checklist_items/1
  # DELETE /checklist_items/1.json
  def delete
    destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_checklist_item
      @checklist_item = if params[:id].present?
                          ChecklistItem.find(params[:id])
                        elsif params["checklist_item_id"].present?
                          @checklist_item = ChecklistItem.find(params[:checklist_item_id])
                        end
    end

    # Get review
    def get_review
      set_checklist_item unless @checklist_item.present?

      if params["review_id"].present?
        @review = Review.find(params["review_id"])
      elsif @checklist_item.present? && @checklist_item.review_id.present?
        @review = Review.find_by(:id => @checklist_item.review_id)
      end

      unless @project.present?
        @project = Project.find(@review.project_id) if @review.present?
      end
    end

    # Get item from review
    def get_review_item
      get_review unless @review.present?
      
      @item = @review.item if @review.present?
    end

    # Get all reviews for item
    def get_reviews
      get_review_item unless @item.present?

      if @item.present?
        if session[:archives_visible]
          @reviews = Review.where(item_id:      @item.id,
                                  organization: current_user.organization)
        else
          @reviews = Review.where(item_id:      @item.id,
                                  organization: current_user.organization,
                                  archive_id:  nil)
        end
      end
    end
  
    # Never trust parameters from the scary internet, only allow the white list through.
    def checklist_item_params
      params.require(:checklist_item).permit(:clitemid, :description, :reference, :minimumdal, :passing, :failing, :status, :note, :document_id, :evaluator, :evaluation_date, :supplements => [])
    end
end
