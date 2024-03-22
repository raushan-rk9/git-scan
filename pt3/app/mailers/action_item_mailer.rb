class ActionItemMailer < ApplicationMailer
  default from: "pact_cm@airworthinesscert.com"
  layout        "mailer"

  def new_email(action_item_id)
    @action_item = ActionItem.find(action_item_id)
    @project     = Project.find(@action_item.project_id)
    @item        = Item.find(@action_item.item_id)
    @review      = Review.find(@action_item.review_id)
    @user        = User.find_by(email: @action_item.assignedto)

    if @user.present?
      message    = mail(template_path: 'action_item_mailer',
                        template_name: 'new_email',
                        to:            @user.email,
                        subject:       'A new Action Item has been assigned to you.')

      message.deliver!
    end
  end

  def edit_email(action_item_id)
    @action_item = ActionItem.find(action_item_id)
    @project     = Project.find(@action_item.project_id)
    @item        = Item.find(@action_item.item_id)
    @review      = Review.find(@action_item.review_id)
    @user        = User.find_by(email: @action_item.assignedto)

    if @user.present?
      message    = mail(template_path: 'action_item_mailer',
                        template_name: 'edit_email',
                        to:            @user.email,
                        subject:       'An Action Item assigned to you has changed.')

      message.deliver!
    end
  end

  def delete_email(action_item)
    @action_item = action_item
    @project     = Project.find(@action_item.project_id)
    @item        = Item.find(@action_item.item_id)
    @review      = Review.find(@action_item.review_id)
    @user        = User.find_by(email: @action_item.assignedto)

    if @user.present?
      message    = mail(template_path: 'action_item_mailer',
                        template_name: 'delete_email',
                        to:            @user.email,
                        subject:       'An Action Item assigned to you has been deleted.')

      message.deliver!
    end
  end
end
