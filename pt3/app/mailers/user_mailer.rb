class UserMailer < ApplicationMailer
  default from: "pact_cm@airworthinesscert.com"
  layout        "mailer"

  def new_email(user_id,
                attachment_type = nil,
                attachment_name = nil,
                attachment_data = nil)
    @user                        = User.find_by(id: user_id)
#    attachments[attachment_name] = {
#                                      mime_type: attachment_type,
#                                      content:   attachment_data
#                                   } if attachment_name.present? && attachment_data.present?

    if @user.present?
      message                    = mail(template_path: 'user_mailer',
                                        template_name: 'new_email',
                                        to:            @user.email,
                                        subject:       'You have been given new login.')

      message.deliver!
    end
  end

  def edit_email(user_id, attachment_type = nil, attachment_data = nil)
    @user                        = User.find_by(id: user_id)
    attachments[attachment_name] = {
                                      mime_type: attachment_type,
                                      content:   attachment_data
                                   } if attachment_data.present?

    if @user.present?
      message                    = mail(template_path: 'user_mailer',
                                        template_name: 'edit_email',
                                        to:            @user.email,
                                        subject:       'Your PACT information has been changed.')

      message.deliver!
    end
  end

  def delete_email(user_id, attachment_type = nil, attachment_data = nil)
    @user                        = User.find_by(id: user_id)
    attachments[attachment_name] = {
                                      mime_type: attachment_type,
                                      content:   attachment_data
                                   } if attachment_data.present?

    if @user.present?
      message                    = mail(template_path: 'user_mailer',
                                        template_name: 'delete_email',
                                        to:            @user.email,
                                        subject:       'Your PACT account has been removed.')

      message.deliver!
    end
  end
end
