class EmailChallengeMailer < ApplicationMailer
  default from: "pact_cm@airworthinesscert.com"
  layout        "mailer"

  def send_code(user_id)
    @user    = User.find(user_id)

    if @user.present?
      message    = mail(template_path: 'email_challenge_mailer',
                        template_name: 'send_code',
                        to:            @user.email,
                        subject:       'Here is your challence code for PACT.')

      message.deliver!
    end
  end
end
