class FunctionItemsController < ApplicationController
  include Common
  before_action :get_item

  # GET /action_items
  # GET /action_items.json
  def index
    authorize :function_item

    @item = Item.find(params[:item_id]) if params[:item_id].present?

    if @item.present?
      if params[:entry_point].present?
        @function_items = FunctionItem.where(item_id:          params[:item_id],
                                             calling_function: params[:entry_point],
                                             organization: current_user.organization).to_a

        unless @function_items.present?
          @function_items = FunctionItem.where('item_id = ? AND organization = ? AND calling_function LIKE ?',
                                               params[:item_id],
                                               current_user.organization,
                                               "%#{params[:entry_point]}%").to_a
        end

        @function_items.delete_if { |function_item| !function_item.function.present? }
      else
        @function_items = FunctionItem.where(item_id:      params[:item_id],
                                             organization: current_user.organization)
      end
    end
  end
end
