class ReviewMailer < ApplicationMailer
  default from: "pact_cm@airworthinesscert.com"
  layout        "mailer"

  def checklist_assigned(review_id, user_id)
    @review   = Review.find(review_id)
    @user     = User.find(user_id)

    if @user.present?
      message = mail(template_path: 'review_mailer',
                     template_name: 'checklist_assigned',
                     to:            @user.email,
                     subject:       'A Checklist has been assigned to you.')

      message.deliver!
    end
  end

  def checklist_unassigned(review_id, user_id)
    @review   = Review.find(review_id)
    @user     = User.find(user_id)

    if @user.present?
      message = mail(template_path: 'review_mailer',
                     template_name: 'checklist_unassigned',
                     to:            @user.email,
                     subject:       'A Checklist assigned to you has been removed.')

      message.deliver!
    end
  end
end
