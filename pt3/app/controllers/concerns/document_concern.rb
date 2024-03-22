module DocumentConcern
  extend ActiveSupport::Concern

  # Get documents
  def get_doc
    @document = Document.find_by(:id => params[:document_id])

    if @document.present?
      unless @project.present?
        @project = Project.find(@document.project_id)
      end
      unless @item.present?
        @item = Item.find(@document.item_id)
      end
    end
  end

  # Get all documents for project
  def get_docs
    if session[:archives_visible]
      @documents = Document.where(item_id: params[:item_id],
                                  organization: current_user.organization)
    else
      @documents = Document.where(item_id: params[:item_id],
                                  organization: current_user.organization,
                                  archive_id: nil)
    end
  end
end
