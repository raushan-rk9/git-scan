class ActionItemsController < ApplicationController
  include Common
  include ReviewConcern
  before_action :set_action_item, only: [:show, :edit, :update, :destroy]
  before_action :get_item
  before_action :get_items, only: [:new, :edit, :update]
  before_action :get_project_byparam
  before_action :get_projects, only: [:new, :edit, :update]
  before_action :get_review
  before_action :get_reviews, only: [:new, :edit, :update]
  before_action :get_users, only: [:new, :edit, :update]

  # GET /action_items
  # GET /action_items.json
  def index
    authorize :action_item

    if session[:archives_visible]
      @action_items = ActionItem.where(review_id:    params[:review_id],
                                       organization: current_user.organization)
    else
      @action_items = ActionItem.where(review_id:    params[:review_id],
                                       organization: current_user.organization,
                                       archive_id:  nil)
    end

    if params[:filter_field].present? && params[:filter_value]
      session[:ai_filter_field] = params[:filter_field]
      session[:ai_filter_value] = params[:filter_value]
      @action_items             = @action_items.to_a.delete_if do |action_item|
        field                   = action_item.attributes[params[:filter_field]].upitem
        value                   = params[:filter_value].upitem

        !field.index(value)
      end
    end

    @undo_path      = get_undo_path('action_items',
                                    review_action_items_path(@review))
    @redo_path      = get_redo_path('action_items',
                                    review_action_items_path(@review))
  end

  # GET /action_items/1
  # GET /action_items/1.json
  def show
    authorize :action_item

    @undo_path = get_undo_path('action_items',
                               review_action_items_path(@review))
    @redo_path = get_redo_path('action_items',
                               review_action_items_path(@review))
  end

  # GET /action_items/new
  def new
    authorize :action_item
    @action_item = ActionItem.new
    @action_item.project_id   = @review.project_id
    @action_item.item_id      = @review.item_id
    @action_item.openedby     = current_user.email
    @action_item.actionitemid = @review.ai_count + 1
    @action_item.review_id    = @review.id
  end

  # GET /action_items/1/edit
  def edit
    authorize @action_item

    @undo_path = get_undo_path('action_items',
                               review_action_items_path(@review))
    @redo_path = get_redo_path('action_items',
                               review_action_items_path(@review))
  end

  # POST /action_items
  # POST /action_items.json
  def create
    authorize :action_item

    params[:action_item][:project_id] = @review.project_id if !action_item_params[:project_id].present? && @review.present?
    params[:action_item][:item_id]    = @review.item_id    if !action_item_params[:item_id].present?    && @review.present?
    params[:action_item][:review_id]  = @review.id         if !action_item_params[:review_id].present?  && @review.present?
    @action_item                      = ActionItem.new(action_item_params)

    # Check to see if the Action ID already Exists.
    if ActionItem.find_by(actionitemid: @action_item.actionitemid,
                          project_id:   @review.project_id,
                          item_id:      @review.item_id,
                          review_id:    @review.id)
      @action_item.errors.add(:actionitemid, :blank, message: "Duplicate ID: #{@action_item.actionitemid}")

      respond_to do |format|
        format.html { render :new }
        format.json { render json: @system_requirement.errors, status: :unprocessable_entity }
      end
    else
      @action_item.review_id = @review.id
      @data_change           = DataChange.save_or_destroy_with_undo_session(@action_item,
                                                                            'create')

      if @data_change.present?
        # Increment the global counter, and save the review.
        @review.ai_count    += 1
        @data_change         = DataChange.save_or_destroy_with_undo_session(@review,
                                                                            'update',
                                                                            @review.id,
                                                                            'reviews',
                                                                            @data_change.session_id)

        if @data_change.present? && @action_item.assignedto.present?
          user               = User.find_by(email: @action_item.assignedto,
                                            organization: User.current.organization);

          if user.present? && user.notify_on_changes
            begin
              mailer         = ActionItemMailer.new

              mailer.new_email(@action_item.id)
            rescue => e
              flash[:error]  = "Could not send email to assigned user: #{user.email}. Error: #{e.message}."
            end
          end
        end

        respond_to do |format|
          format.html { redirect_to [@review, @action_item], notice: 'Action item was successfully created.' }
          format.json { render :show, status: :created, location: @action_item }
        end
      else
        respond_to do |format|
          format.html { render :new }
          format.json { render json: @action_item.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # PATCH/PUT /action_items/1
  # PATCH/PUT /action_items/1.json
  def update
    authorize @action_item

    params[:action_item][:project_id] = @review.project_id if !action_item_params[:project_id].present? && @review.present?
    params[:action_item][:item_id]    = @review.item_id    if !action_item_params[:item_id].present?    && @review.present?
    params[:action_item][:review_id]  = @review.id         if !action_item_params[:review_id].present?  && @review.present?

    @data_change          = DataChange.save_or_destroy_with_undo_session(action_item_params,
                                                                         'update',
                                                                         params[:id],
                                                                         'action_items')

    if @data_change.present?
      if action_item_params[:assignedto].present?
        user              = User.find_by(email: action_item_params[:assignedto],
                                         organization: User.current.organization);
  
        if user.present? && user.notify_on_changes
          begin
            mailer        = ActionItemMailer.new
  
            mailer.edit_email(params[:id])
          rescue => e
            flash[:error] = "Could not send email to assigned user: #{user.email}. Error: #{e.message}."
          end
        end
      end

      respond_to do |format|
        format.html { redirect_to [@review, @action_item], notice: 'Action item was successfully updated.' }
        format.json { render :show, status: :ok, location: @action_item }
      end
    else
      respond_to do |format|
        format.html { render :edit }
        format.json { render json: @action_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /action_items/1
  # DELETE /action_items/1.json
  def destroy
    authorize @action_item

    @data_change = DataChange.save_or_destroy_with_undo_session(@action_item,
                                                                'delete')

    if @data_change.present?
      if @action_item.assignedto.present?
        user = User.find_by(email: @action_item.assignedto,
                            organization: User.current.organization);

        if user.present? && user.notify_on_changes
          begin
            mailer = ActionItemMailer.new

            mailer.delete_email(@action_item)
          rescue => e
            flash[:error] = "Could not send email to assigned user: #{user.email}. Error: #{e.message}."
          end
        end
      end

      respond_to do |format|
        format.html { redirect_to review_action_items_url(@review), notice: 'Action item was successfully removed.' }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html { render :index, error: 'Could not delete action item.'}
        format.json { render json: @action_item.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_action_item
      @action_item = ActionItem.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def action_item_params
      params.require(:action_item).permit(:actionitemid, :description, :openedby, :assignedto, :status, :note, :item_id, :project_id, :review_id)
    end
end
