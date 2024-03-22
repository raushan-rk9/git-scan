# frozen_string_literal: true

class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  # You should configure your model like this:
  # devise :omniauthable, omniauth_providers: [:twitter]

  # You should also create an action method in this controller like this:
  # def twitter
  # end

  # More info at:
  # https://github.com/plataformatec/devise#omniauth

  # GET|POST /resource/auth/twitter
  # def passthru
  #   super
  # end

  # GET|POST /users/auth/github/callback
  # def passthru
  #   super
  # end

  # GET|POST /users/auth/twitter/callback
  # def failure
  #   super
  # end

  # protected

  # The path used when OmniAuth fails
  # def after_omniauth_failure_path_for(scope)
  #   super(scope)
  # end
  
  def github
    # You need to implement the method below in your model (e.g. app/models/user.rb)
    @user = User.from_omniauth(request.env["omniauth.auth"])

    if @user.persisted?
#      sign_in_and_redirect @user, event: :authentication #this will throw if @user is not activated
      set_flash_message(:notice, :success, kind: "GitHub") if is_navigational_format?

      if request.env['omniauth.params']['return_path'].present?
        redirect_to request.env['omniauth.params']['return_path']
      else
        sign_in @user
        redirect_to root_path
      end
    else
      session["devise.fgithub_data"] = request.env["omniauth.auth"]

      if request.env['omniauth.params']['return_path'].present?
        redirect_to request.env['omniauth.params']['return_path']
      else
        redirect_to root_path
      end
    end
  end

  def failure
    redirect_to root_path
  end
end
