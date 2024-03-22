class ExportController < ApplicationController
  include Common
  before_action :get_projects, only: [:new, :edit, :update]

  def index
    authorize :export
    @projects = Project.all
    @item = Item.new
    @export = Export.new
  end

  def edit
    authorize :export
    @projects = Project.all
    @item = Item.new
  end

  def update
    authorize :export
    respond_to do |format|
        @data_change = DataChange.save_or_destroy_with_undo_session(review_params,
                                                                    'update',
                                                                    params[:id],
                                                                    'reviews')
      if @data_change.present?
        format.html { redirect_to [@item, @review], notice: 'Review was successfully updated.' }
        format.json { render :show, status: :ok, location: @review }
      else
        format.html { render :edit }
        format.json { render json: @review.errors, status: :unprocessable_entity }
      end
    end
  end

  def user
    authorize :export
    @users = User.all

    respond_to do |format|
      format.csv { send_data @users.to_csv, filename: "user.csv" }
    end
  end

  def review
    authorize :export
    @review = Review.find(params[:review_id])

    respond_to do |format|
      format.csv { send_data @review.to_csv, filename: @review.title + ".csv" }
    end
  end
end
