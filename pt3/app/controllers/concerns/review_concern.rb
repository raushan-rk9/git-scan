module ReviewConcern
  extend ActiveSupport::Concern

  # Get review
  def get_review
    @review = Review.find_by(:id => params[:review_id])

    unless @project.present?
      get_project(@review.project_id) if @review.present? && @review.project_id.present?
    end

    unless @item.present?
      get_review_item if @review.present? && @review.item_id.present?
    end
  end

  # Get all reviews for item
  def get_reviews
    if session[:archives_visible]
      @reviews = Review.where(item_id:      params[:item_id],
                              organization: current_user.organization)
    else
      @reviews = Review.where(item_id:      params[:item_id],
                              organization: current_user.organization,
                              archive_id:  nil)
    end
  end

  # Get item from review
  def get_review_item
    @item = @review.item
  end

  # Get project from review
  def get_project_from_review
    unless @project.present?
      @project = Project.find(@review.project_id) if @review.present?
    end
  end
end
