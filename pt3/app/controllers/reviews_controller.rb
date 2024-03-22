class ReviewsController < ApplicationController
  include Common
  include ReviewConcern

  respond_to    :docx

  skip_before_action :verify_authenticity_token

  before_action :set_review, only: [:show, :edit, :update, :destroy, :signin, :save_signin, :select_attendees, :sign_off, :assign_checklists, :renumber_checklist, :fill_in_checklist, :submit_checklist, :consolidated_checklist, :export_consolidated_checklist, :checklist_items, :status, :export_checklist, :import_checklist, :checklist, :close]
  before_action :get_item
  before_action :get_items, only: [:new, :edit, :update]
  before_action :get_project_fromitemid, except: [:cl_fill, :cl_removeall, :signin, :save_signin, :select_attendees, :sign_off, :fill_in_checklist, :submit_checklist, :assign_checklists, :consolidated_checklist, :export_consolidated_checklist, :export_checklist, :import_checklist, :checklist]
  before_action :get_project_from_review, only: [:cl_fill, :cl_removeall, :signin, :save_signin, :select_attendees, :sign_off, :fill_in_checklist, :submit_checklist, :assign_checklists, :consolidated_checklist, :export_consolidated_checklist, :export_checklist, :import_checklist, :checklist, :close]
  before_action :get_projects, only: [:new, :edit, :update]
  # Misc actions
  before_action :get_review, only: [:cl_fill, :cl_removeall]
  before_action :get_reviews, only: [:cl_fill, :cl_removeall]
  before_action :get_review_item, only: [:cl_fill, :cl_removeall, :assign_checklists, :fill_in_checklist, :submit_checklist]

  # GET /reviews
  # GET /reviews.json
  def index
    authorize :review

    if session[:archives_visible]
      @reviews = Review.where(item_id:      params[:item_id],
                              organization: current_user.organization)
    else
      @reviews = Review.where(item_id:      params[:item_id],
                              organization: current_user.organization,
                              archive_id:  nil)
    end

    if params[:filter_field].present? && params[:filter_value]
      session[:review_filter_field] = params[:filter_field]
      session[:review_filter_value] = params[:filter_value]
      @reviews                      = @reviews.to_a.delete_if do |review|
        field                       = review.attributes[params[:filter_field]].upitem
        value                       = params[:filter_value].upitem

        !field.index(value)
      end
    end

    @undo_path = get_undo_path('reviews', item_reviews_path(@item))
    @redo_path = get_redo_path('reviews', item_reviews_path(@item))
  end

  # GET /reviews/1
  # GET /reviews/1.json
  def show
    authorize :review

    # Get the item for this review.
    @item               = Item.find_by(id: @review.item_id)
    @undo_path          = get_undo_path('reviews', item_reviews_path(@item))
    @redo_path          = get_redo_path('reviews', item_reviews_path(@item))
    @checklist_items    = @review.checklist_item.order(:clitemid)
    @my_checklist_items = @review.checklist_item.where(user_id: current_user.id).order(:clitemid)
  end

  # GET /reviews/new
  def new
    authorize :review

    @review            = Review.new
    @transition_types  = TemplateChecklist.get_checklists(@item.itemtype,
                                                         'Transition Review')
    @peer_types        = TemplateChecklist.get_checklists(@item.itemtype,
                                                         'Peer Review')
    reviews            = Review.where(project_id: @project.id)
    @review.evaldate   = DateTime.now
    @review.item_id    = @item.id
    @review.project_id = @project.id
    @review.reviewid   = if reviews.present?
                           reviews.maximum(:reviewid).next
                         else
                           1
                         end
    @review.created_by = current_user.email

    # Initial version counter value is 1.
    @review.version          = 1
    @pact_files              = get_pact_files
    @review.unassigned_users = User.where(organization: current_user.organization).or(User.where("role LIKE '%AirWorthinessCert Member%'"))
    @review.evaluators       = [ current_user ]
    @problem_reports         = ProblemReport.where(project_id: @project.id, organization: current_user.organization).order(:prid)
  end

  # GET /reviews/1/edit
  def edit
    authorize @review

    # Increment the version counter if edited.
    evaluators               = []
    @review.version          = increment_int(@review.version)
    @undo_path               = get_undo_path('reviews', item_reviews_path(@item))
    @redo_path               = get_redo_path('reviews', item_reviews_path(@item))
    @checklist_items         = @review.checklist_item.order(:clitemid)
    @my_checklist_items      = @review.checklist_item.where(user_id: current_user.id).order(:clitemid)
    @review.unassigned_users = User.where(organization: current_user.organization).or(User.where("role LIKE '%AirWorthinessCert Member%'")).to_a
    @problem_reports         = ProblemReport.where(project_id: @project.id, organization: current_user.organization).order(:prid)

    @review.evaluators.each do |email|
      next unless email.present?
      evaluator = User.find_by(email: email,
                               organization: User.current.organization)

      evaluators.push(evaluator) if evaluator.present?

      @review.unassigned_users.delete_if { |user| user.email == email }
    end

    @review.evaluators       = evaluators
  end

  # POST /reviews
  # POST /reviews.json
  def create
    authorize :review

    params[:review][:evaluators].delete_if { |evaluator| !evaluator.present? } if params[:review][:evaluators].present?

    error                      = ''
    session_id                 = nil
    okay                       = true
    @review                    = Review.new(review_params)
    @review.project_id         = @project.id        if !@review.project_id.present? && @project.present?
    @review.item_id            = @item.id           if !@review.item_id.present?    && @item.present?
    @review.created_by         = current_user.email if !@review.created_by.present?
    @review.attendees          = ''

    params[:review][:evaluators].each do |attendee|
      if @review.attendees.present?
        @review.attendees     += ",#{attendee}"
      else
        @review.attendees      = attendee
      end
    end if params[:review][:evaluators].present?

    # Check to see if the Review ID already Exists.
    if Review.find_by(reviewid:   @review.reviewid,
                      project_id: @review.project_id,
                      item_id:    @review.item_id)
      okay                     = false
      error                    = "Duplicate ID: #{@review.reviewid}"

      @review.unassigned_users = User.where(organization: current_user.organization).or(User.where("role LIKE '%AirWorthinessCert Member%'"))
      @review.evaluators       = []
    end

    if okay
      data_change              = DataChange.save_or_destroy_with_undo_session(@review,
                                                                              'create',
                                                                              @review.id,
                                                                              'reviews')

      if data_change.present?
        session_id             = data_change.session_id
      else
        okay                   = false
        error                  = "Cannot Save Review: #{@review.reviewid}"
      end
    end

    if okay && review_params[:link_type].present?
        result                 = attach_document(review_params, session_id)
        okay                   = result[:status]
        error                  = result[:error]
        session_id             = result[:session_id]
    end

    if okay && review_params[:attachments].present?
      review_params[:attachments].each do |index, attachment|
        result                 = attach_attachment(attachment, session_id)
        okay                   = result[:status]
        error                  = result[:error]
        session_id             = result[:session_id]

        break unless okay
      end
    end

    if okay
      @item.review_count      += 1
      data_change              = DataChange.save_or_destroy_with_undo_session(@item,
                                                                              'update',
                                                                              @item.id,
                                                                              'items',
                                                                              session_id)

      if data_change.present?
        session_id             = data_change.session_id
      else
        okay                   = false
        error                  = "Cannot Update Item: #{@item.identifier}"
      end
    end

    clexec_fillallclitems(review_params[:reviewtype],
                          session_id)         if okay &&
                                                 review_params[:reviewtype].present?
    copy_checklists_to_evaluators(@review.evaluators,
                                  false,
                                  session_id) if okay &&
                                                 @review.evaluators.present?
    @review.errors.add(:reviewid,
                       :blank,
                       message: error)        unless okay

    respond_to do |format|
      if okay
        format.html { redirect_to [@item, @review],         notice: 'Review was successfully created.' }
        format.json { render      :show,  status: :created, location: [@item, @review] }
      else
        format.html { render :new, alert: error }
        format.json { render json: @review.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /reviews/1
  # PATCH/PUT /reviews/1.json
  def update
    authorize @review

    params[:review][:evaluators].delete_if { |evaluator| !evaluator.present? } if params[:review][:evaluators].present?

    deleted_evaluators       = []
    added_evaluators         = []

    unless review_params[:evaluators].nil?
      evaluators             = review_params[:evaluators]

      @review.evaluators.each do |old_evaluator|
        found                = false

        evaluators.each do |new_evaluator|
          found              = (new_evaluator == old_evaluator)

          break if found
        end if evaluators.present?

        deleted_evaluators.push(old_evaluator) unless found
      end

      evaluators.each do |new_evaluator|
        found                = false

        @review.evaluators.each do |old_evaluator|
          found              = (new_evaluator == old_evaluator)

          break if found
        end if @review.evaluators.present?

        added_evaluators.push(new_evaluator) unless found
      end if evaluators.present?

      evaluators.each do |attendee|
        if @review.attendees.present?
          @review.attendees += ",#{attendee}"
        else
          @review.attendees  = attendee
        end
      end
    end

    @review.assign_attributes(review_params)

    @review.project_id       = @project.id        if !@review.project_id.present? &&
                                                      @project.present?
    @review.item_id          = @item.id           if !@review.item_id.present? &&
                                                      @item.present?
    @review.created_by       = current_user.email if !@review.created_by.present?
    @review.attendees        = ''
    error                    = ''
    session_id               = nil
    okay                     = true

    data_change              = DataChange.save_or_destroy_with_undo_session(@review,
                                                                            'update',
                                                                            @review.id,
                                                                            'reviews',
                                                                            session_id)

    if data_change.present?
      session_id             = data_change.session_id
    else
      okay                   = false
      error                  = "Cannot Update Review: #{review_params.title}"
    end

    delete_evaluators_checklists(deleted_evaluators,
                                 session_id) if okay &&
                                                deleted_evaluators.present?

    copy_checklists_to_evaluators(added_evaluators,
                                  false,
                                  session_id) if okay &&
                                                 added_evaluators.present?

    respond_to do |format|
      if okay
        format.html { redirect_to [@item, @review], notice: 'Review was successfully updated.' }
        format.json { render :show, status: :ok, location: @review }
      else
        format.html { render :edit, alert: error }
        format.json { render json: @review.errors, status: :unprocessable_entity }
      end
    end
  end

  # Fill Checklist
  def cl_fill
    authorize @review

    if request.put?
      if @review.checklist_item.present? && !current_user.fulladmin
        @review.errors.add(:checklist_item, :blank, message: 'You cannot overwrite a checklist you need to remove it first.')
      else
        if @review.checklist_item.present? && current_user.fulladmin
          clexec_removeclitems
        end

        # Fill the checklist.
        clexec_fillallclitems(params[:review][:reviewtype])

        @review.version = increment_int(@review.version)
        @data_change    = DataChange.save_or_destroy_with_undo_session(@review,
                                                                       'update',
                                                                       @review.id,
                                                                       'reviews')
        respond_to do |format|
          format.html { redirect_to [@item, @review], notice: 'All checklist items were successfully deleted.' }
          format.json { render :show, status: :created, location: @review }
        end
      end
    end
  end

  # Remove all checklist items
  def cl_removeall
    authorize @review

    if @review.checklists_assigned && !current_user.fulladmin
      @review.errors.add(:checklist_item, :blank, message: 'You cannot remove a checklist that has been assigned.')
    else
      respond_to do |format|
        if params[:review].try(:has_key?, :removeallclitems) && params[:review][:removeallclitems] == '1'
          # Remove all checklist items.
          clexec_removeclitems
          @review.version             = increment_int(@review.version)
          @review.checklists_assigned = false
          @data_change                = DataChange.save_or_destroy_with_undo_session(@review,
                                                                                     'update',
                                                                                     @review.id,
                                                                                     'reviews')
          format.html { redirect_to [@item, @review], notice: 'All checklist items were successfully deleted.' }
          format.json { render :show, status: :created, location: @review }
        else
          # , notice: 'Checklist items have not been deleted.'
          format.html { render :cl_removeall }
          format.json { render json: @review.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # GET /reviews/1/sign-in
  def signin
    authorize :review
  end

  # GET /reviews/1/save-sign-in
  def save_signin
    authorize :review

    @no_links = true

    render(pdf:      "#{@review.title}-Sign-In_Sheet",
           template: 'reviews/signin.html.erb',
           title:    'Reviews: Export PDF | PACT',
           footer:   {
                       right: '[page] of [topage]'
                     })
  end

  # GET /reviews/1/select-attendees
  def select_attendees
    authorize @review
  end

  # GET /reviews/1/sign-off
  def sign_off
    authorize :review

    if @review.sign_offs.present?
      @review.sign_offs.push(current_user.email) unless @review.sign_offs.include?(current_user.email)
    else
      @review.sign_offs = [ current_user.email ]
    end

    @data_change        = DataChange.save_or_destroy_with_undo_session(@review,
                                                                       'update',
                                                                       @review.id,
                                                                       'reviews')

    respond_to do |format|
      if @data_change.present?
        format.html { redirect_to review_sign_in_path, notice: 'Review was successfully signed.' }
        format.json { render :nothing => true, :status => 200 }
      else
        format.html { redirect_to review_sign_in_path, notice: 'Could not sign review.' }
        format.json { render json: @review.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /reviews/1/assign-checklists
  def assign_checklists
    authorize @review

    copy_checklists_to_evaluators(@review.evaluators, true, nil)

    respond_to do |format|
      format.html { redirect_to [@item, @review], notice: 'Checklists were successfully assigned.' }
      format.json { render :show, status: :created, location: [@item, @review] }
    end
  end

  def renumber_checklist
    authorize @review

    session_id        = nil
    last_user         = nil
    current_list      = nil
    checklists        = []
    @checklist_items  = ChecklistItem.where(review_id: @review.id,
                                            organization: current_user.organization).order(:user_id,
                                                                                           :clitemid)

    @checklist_items.each do |checklist_item|
      if last_user != checklist_item.user_id
        checklists.push(current_list) if current_list.present?

        last_user     = checklist_item.user_id
        current_list  = []
      end

      current_list.push(checklist_item)
    end

    checklists.push(current_list) if current_list.present?

    checklists.each do |checklist|
      clitemid        = 1

      checklist.each do |item|
        item.clitemid = clitemid
        clitemid     += 1
        @data_change  = DataChange.save_or_destroy_with_undo_session(item,
                                                                     'update',
                                                                     item.id,
                                                                     'checklist_items',
                                                                     session_id)
        session_id    = @data_change.session_id if @data_change.present?
      end
    end

    respond_to do |format|
      format.html { redirect_to edit_item_review_path(@item, @review), notice: 'Checklists were successfully renumbered.' }
      format.json { render :show, status: :created, location: [@item, @review] }
    end
  end

  # GET /reviews/1/fill-in-checklist
  def fill_in_checklist
    authorize @review

    @item               = Item.find(@review.item_id) if @review.present?
    @project            = Project.find(@item.project_id) if @item.present?
    documents           = Document.where(organization: current_user.organization, item_id: @item.id, archive_id:  nil)
    @documents          = documents.to_a.delete_if { |document| document.document_type == Constants::FOLDER_TYPE}
    @review_document    = Document.find_by(review_id: @review.id)
    @document_url       = url_for([@item, @review_document])
    @my_checklist_items = ChecklistItem.where(review_id: @review.id,
                                              user_id:   current_user.id)
  end

  # PUT|PATCH|POST /reviews/1/fill-in-checklist
  def submit_checklist
    authorize @review

    session_id                   = nil
    @my_checklist_items          = ChecklistItem.where(review_id: @review.id,
                                                       user_id:   current_user.id)
    checklist_data               = JSON.parse(params[:checklist_data])

    checklist_data.each do |checklist_item|
      my_checklist_item          = @my_checklist_items.find { |item| item.clitemid.to_s == checklist_item['id'] }

      next unless my_checklist_item.present?

      checklist_item['status']   = nil if checklist_item['status'] == ""
      checklist_item['notes']    = nil if checklist_item['notes'] == ""

      if (my_checklist_item.status != checklist_item['status']) ||
         (my_checklist_item.note   != checklist_item['notes'])
        my_checklist_item.status = checklist_item['status']
        my_checklist_item.note   = checklist_item['notes']
        @data_change             = DataChange.save_or_destroy_with_undo_session(my_checklist_item,
                                                                                'update',
                                                                                my_checklist_item.id,
                                                                                'checklist_items',
                                                                                session_id)
        session_id               = @data_change.session_id if @data_change.present?
      end
    end if checklist_data.present?

    if params[:no_exit]
      respond_to do |format|
        format.html { render body: nil }
        format.json { render nothing: true }
      end
    else
      respond_to do |format|
        format.html { redirect_to [@item, @review], notice: 'Checklists were successfully updated.' }
        format.json { render :show, status: :created, location: [@item, @review] }
      end
    end
  end

  # GET /reviews/1/consolidated-checklist
  def consolidated_checklist
    authorize @review

    @consolidated_items = ChecklistItem.consolidate_checklist_items(@review.id,
                                                                    @review.checklists_assigned)

    respond_to do |format|
      format.html { render       :consolidated_checklist }
      format.json { render json: @consolidated_items, status: :ok }
    end
  end


  # GET /reviews/1/checklist
  def checklist
    authorize :review

    @items     = ChecklistItem.where(review_id: @review.id,
                                     evaluator: current_user.email)
    @preheaders = setup_preheaders(current_user.email)

    respond_to do |format|
      format.html { render       :checklist }
      format.json { render json: @items, status: :ok }
    end
  end

  DEFAULT_HEADERS = %w{ clitemid description reference minimumdal supplements status note}
  DISPLAY_HEADERS = [ '#', 'Checklist Item', 'DO-178C or Other Guidance Reference', 'DAL', 'Supplements', 'Compliance', 'Remarks' ]

  # GET /reviews/1/export-checklist
  def export_checklist
    authorize @review

    if request.put? && params[:checklist_export].present?
      @items      = ChecklistItem.where(review_id: @review.id,
                                        evaluator: current_user.email)
      @preheaders = setup_preheaders(current_user.email)

      if params[:checklist_export].try(:has_key?, :export_type)    &&
         params[:checklist_export][:export_type] == 'HTML'
        redirect_to review_checklist_path(@review.id)
      elsif params[:checklist_export].try(:has_key?, :export_type) &&
            params[:checklist_export][:export_type] == 'JSON'
        redirect_to review_checklist_path(@review.id)
      elsif params[:checklist_export].try(:has_key?, :export_type) &&
            params[:checklist_export][:export_type] == 'PDF'
        @no_links = true

        render(pdf:         "#{@review.title}-Checklist",
               template:    'reviews/checklist.html.erb',
               title:       'Reviews: Export PDF | PACT',
               footer:      {
                               right: '[page] of [topage]'
                            },
               orientation: 'Landscape')
      elsif params[:checklist_export].try(:has_key?, :export_type) &&
            params[:checklist_export][:export_type] == 'CSV'
        send_data(ChecklistItem.to_csv(@review.id,
                                       current_user.email,
                                       DEFAULT_HEADERS,
                                       DISPLAY_HEADERS,
                                       @preheaders),
                  filename: "#{@review.title}-Checklist.csv")
      elsif params[:checklist_export].try(:has_key?, :export_type) &&
            params[:checklist_export][:export_type] == 'XLS'
        send_data(ChecklistItem.to_xls(@review.id,
                                       current_user.email,
                                       DEFAULT_HEADERS,
                                       DISPLAY_HEADERS,
                                       @preheaders),
                  filename: "#{@review.title}-Checklist.xls")
      elsif params[:checklist_export].try(:has_key?, :export_type) &&
            params[:checklist_export][:export_type] == 'DOCX'
        if convert_data("Checklist.docx",
                        'reviews/checklist.html.erb',
                         @item.present? ? @item.id : params[:item_id])
          return_file(@converted_filename)
        else
          flash[:error]  = @conversion_error
          params[:level] = 2
  
          go_back
        end
      end

      return
    end
  end

  # GET /reviews/1/import-checklist
  def import_checklist
    authorize @review

    render nothing: true
  end

  # GET /reviews/1/export-consolidated-checklist
  def export_consolidated_checklist
    authorize @review

    if request.put? && params[:consolidated_checklist_export].present?
      @consolidated_items = ChecklistItem.consolidate_checklist_items(@review.id,
                                                                      @review.checklists_assigned)

      if params[:consolidated_checklist_export].try(:has_key?, :export_type)    &&
         params[:consolidated_checklist_export][:export_type] == 'HTML'
        redirect_to review_consolidated_checklist_path(format: :html)
      elsif params[:consolidated_checklist_export].try(:has_key?, :export_type) &&
            params[:consolidated_checklist_export][:export_type] == 'JSON'
        redirect_to review_consolidated_checklist_path(format: :html)
      elsif params[:consolidated_checklist_export].try(:has_key?, :export_type) &&
            params[:consolidated_checklist_export][:export_type] == 'PDF'
        @no_links = true

        render(pdf:      "#{@review.title}-Consolidated-Checklist",
               template: 'reviews/consolidated_checklist.html.erb',
               title:    'Reviews: Export PDF | PACT',
               footer: {
                         right: '[page] of [topage]'
                       })
      elsif params[:consolidated_checklist_export].try(:has_key?, :export_type) &&
            params[:consolidated_checklist_export][:export_type] == 'DOCX'
        if convert_data("Consolidated-Checklist.docx",
                        'reviews/consolidated_checklist.html.erb',
                         @item.present? ? @item.id : params[:item_id])
          return_file(@converted_filename)
        else
          flash[:error]  = @conversion_error
          params[:level] = 2
  
          go_back
        end
      elsif params[:consolidated_checklist_export].try(:has_key?, :export_type) &&
            params[:consolidated_checklist_export][:export_type] == 'CSV'
        send_data ChecklistItem.to_consolidated_csv(@review.id, @review.checklists_assigned), filename: "#{@review.title}-Consolidated-Checklist.csv"
      elsif params[:consolidated_checklist_export].try(:has_key?, :export_type) &&
            params[:consolidated_checklist_export][:export_type] == 'XLS'
        send_data ChecklistItem.to_consolidated_xls(@review.id, @review.checklists_assigned), filename: "#{@review.title}-Consolidated-Checklist.xls"
      end

      return
    end
  end

  # DELETE /reviews/1
  # DELETE /reviews/1.json
  def destroy
    authorize @review

    @data_change = DataChange.save_or_destroy_with_undo_session(@review,
                                                                'delete',
                                                                @review.id,
                                                                'reviews')

    respond_to do |format|
      format.html { redirect_to item_reviews_url, notice: 'Review was successfully removed.' }
      format.json { head :no_content }
    end
  end

  def checklist_items
    @user            = User.find_by(email: params[:email].gsub('_dot_', '.'))
    @checklist_items = if @user.present?
                         ChecklistItem.where(review_id: @review.id, user_id: @user.id).order(:clitemid)
                       else
                         []
                       end

    respond_to do |format|
      format.html { render }
      format.json { render json: @checklist_items }
    end
  end

  def status
    authorize :review

    if request.method == 'GET'
      if @review.present?
        respond_to do |format|
          format.html { render :inline => "<%= @review.review_passing %>" }
          format.json { render json: @review.review_passing }
        end
      else
        respond_to do |format|
          format.html { render :inline => "<%= false %>" }
          format.json { render json: false }
        end
      end
    end
  end

  def close
    authorize @review

    if @review.checklistitems_passing && (@review.actionitems_open == 0)
      @review.status = 'Closed'
      @data_change   = DataChange.save_or_destroy_with_undo_session(@review,
                                                                    'update',
                                                                    @review.id,
                                                                    'reviews')

      if @data_change.present?
        respond_to do |format|
          format.html { redirect_to project_review_status_path(@project), notice: 'Review was successfully closed.' }
        end

        return
      end
    else
        respond_to do |format|
          format.html { redirect_to project_review_status_path(@project), notice: 'Review cannot be closed yet.' }
        end

        return
    end
  end

  private

  def setup_preheaders(email)
    result           = []
    review_document  = Document.find_by(review_id: @review.id)
    review_type      = TemplateChecklist.find_by(title: @review.reviewtype) 

    if review_type.try(:description)
      result.push([ review_type.description ])
    else
      result.push([ @review.reviewtype ])
    end

    result.push([
                   'Project Name:',
                   @project.name
                ])     if @project.try(:name)
    result.push([
                   'Document(s) under review:',
                   review_document.name
                ])     if review_document.try(:name)

    if @review.review_attachment.present?
      columns        = [ 'Supporting Documents:' ]
      documents      = ''

      @review.review_attachment.each do |revattach|
        if revattach.try(:link_description)
          next if review_document.try(:name) &&
                  (revattach.link_description == review_document.name)

          documents += if documents.present?
                        ", #{revattach.link_description}"
                       else
                         revattach.link_description
                       end
        end
      end

      columns.push(documents)
      result.push(columns)
    end

    result.push(['Reviewer Name:', User.fullname_from_email(email), 'Review Date:', @review.evaldate])
    result.push([])

    return result
  end

  def delete_evaluators_checklists(evaluators = @review.evaluators,
                                   session_id = nil)
    evaluators.each do |evaluator|
      user            = User.find_by(email: evaluator,
                                     organization: User.current.organization)

      next unless user.present?

      checklist_items = ChecklistItem.where(review_id: @review.id,
                                            user_id:   user.id) if user.present?

      checklist_items.each do |checklist_item|
        if DataChange.save_or_destroy_with_undo_session(checklist_item,
                                                       'delete',
                                                       checklist_item.id,
                                                       'checklist_items',
                                                       session_id)
        end
      end if checklist_items.present?

      begin
        mailer    = ReviewMailer.new

        mailer.checklist_unassigned(@review.id, user.id)
      rescue => e
        @review.errors.add(:evaluators,
                           :blank,
                           message: "Could not send email to unassigned user: #{user.email}. Error: #{e.message}.")
      end
    end if evaluators.present?
  end

  def copy_checklists_to_evaluators(evaluators            = @review.evaluators,
                                    delete_old_checklists = true,
                                    session_id            = nil)
    checklist_items                  = ChecklistItem.where(review_id: @review.id)

    if evaluators.present? && checklist_items.present?
      unassigned_checklist_items     = []

      checklist_items.each() do |checklist_item|
        if checklist_item.assigned || checklist_item.user_id.present?
          if delete_old_checklists
            DataChange.save_or_destroy_with_undo_session(checklist_item,
                                                         'delete',
                                                         checklist_item.id,
                                                         'checklist_items',
                                                         session_id)
          end
        else
          unassigned_checklist_items.push(checklist_item)
        end
      end

      if unassigned_checklist_items.present?
        evaluators.each() do |evaluator|
          user                       = User.find_by(email: evaluator,
                                                    organization: User.current.organization)

          next if user.nil?

          unassigned_checklist_items.each() do |unassigned_checklist_item|
            checklist_item           = unassigned_checklist_item.dup
            checklist_item.id        = nil
            checklist_item.evaluator = user.email
            checklist_item.user_id   = user.id
            checklist_item.assigned  = true
            @data_change             = DataChange.save_or_destroy_with_undo_session(checklist_item,
                                                                                    'create',
                                                                                    nil,
                                                                                    'checklist_items',
                                                                                    session_id)
          end

          begin
            mailer                 = ReviewMailer.new

            mailer.checklist_assigned(@review.id, user.id)
          rescue => e
            @review.errors.add(:evaluators, :blank, message: "Could not send email to assigned user: #{user.email}. Error: #{e.message}.")
          end
        end

        @review.checklists_assigned  = true
        @data_change                 = DataChange.save_or_destroy_with_undo_session(@review,
                                                                                    'update',
                                                                                    @review.id,
                                                                                    'reviews',
                                                                                    session_id)
      end
    end
  end

  def attach_attachment(attachment, session_id)
    @review_attachment            = ReviewAttachment.new
    @review_attachment.review_id  = @review.id
    @review_attachment.project_id = @review.project_id
    @review_attachment.item_id    = @review.item_id
    @review_attachment.user       = current_user.email

    return(@review_attachment.setup_attachment(attachment['link_link'],
                                               attachment['link_description'],
                                               attachment['link_type'],
                                               Constants::REFERENCE_ATTACHMENT,
                                               attachment['pact_file'],
                                               attachment['link_data'],
                                               session_id))
  end

  def attach_document(review_params, session_id)
    @review_attachment            = ReviewAttachment.new
    @review_attachment.review_id  = @review.id
    @review_attachment.project_id = @review.project_id
    @review_attachment.item_id    = @review.item_id
    @review_attachment.user       = current_user.email

    return(@review_attachment.setup_attachment(review_params['link_link'],
                                               review_params['link_description'],
                                               review_params['link_type'],
                                               Constants::REVIEW_ATTACHMENT,
                                               review_params['pact_file'],
                                               review_params['file'],
                                               session_id))
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_review
    if params[:id].present?
      @review = Review.find(params[:id])
    elsif params[:review_id].present?
      @review = Review.find(params[:review_id])
    end

    unless @item.present?
      @item = Item.find(@review.item_id) if @review.present?
    end
  end

  # Delete all checklist items
  def clexec_removeclitems
    @session_id    = @data_change.session_id if @data_change.present?

    @review.checklist_item.each do |cl|
      @data_change = DataChange.save_or_destroy_with_undo_session(cl,
                                                                  'delete',
                                                                  cl.id,
                                                                  'checklist_items',
                                                                  @session_id)
      @session_id  = @data_change.session_id if @data_change.present?
    end
  end

  # Fill a checklist with the specified id.
  def clexec_fillallclitems(template_checklist_id, session_id = nil)
    template_checklist_items          = []
    template_checklist                = TemplateChecklist.find_by(title:        template_checklist_id,
                                                                  organization: current_user.organization)

    if template_checklist.present?
      template_checklist_items        = TemplateChecklistItem.where(template_checklist_id: template_checklist.id,
                                                                    organization:          current_user.organization)
    end

    checklist_item_number             = 1

    # Add item for every checklist item constant defined.
    template_checklist_items.each do |template_checklist_item|
      skip                            = false
      checklist_item                  = @review.checklist_item.new
      checklist_item.clitemid         = checklist_item_number
      checklist_item.description      = template_checklist_item.description
      checklist_item.reference        = template_checklist_item.reference
      checklist_item.supplements      = template_checklist_item.supplements

      if @item.level.present?
        if template_checklist_item.minimumdal.present?
          if template_checklist_item.minimumdal.include?(@item.level)
            checklist_item.minimumdal = @item.level
          else
            skip                      = true
          end
        end
      end

      next if skip

      @data_change                    = DataChange.save_or_destroy_with_undo_session(checklist_item,
                                                                                     'create',
                                                                                    checklist_item.id,
                                                                                    'checklist_items',
                                                                                    session_id)
      checklist_item_number          += 1
    end
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def review_params
    params.require(
                    :review
                  )
          .permit(
                    :reviewid,
                    :reviewtype,
                    :title,
                    :description,
                    :review_type,
                    :link_type,
                    :link_link,
                    :link_description,
                    :file,
                    :pact_file,
                    :created_by,
                    :evaldate,
                    :item_id,
                    :project_id,
                    :version,
                    :attendees,
                    :sign_offs,
                    unassigned_users:          [],
                    evaluators:                [],
                    problem_reports_addressed: [],
                    attachments: [
                                                  :link_type,
                                                  :link_description,
                                                  :link_data
                    ],
                    checklist_item_attributes: [
                                                  :id,
                                                  :clitemid,
                                                  :description,
                                                  :reference,
                                                  :minimumdal,
                                                  :passing,
                                                  :failing,
                                                   status,
                                                  :note,
                                                  :_destroy,
                                                  supplements: []
                                               ],
                    checklist_item_id:         []
                  )
  end
end
