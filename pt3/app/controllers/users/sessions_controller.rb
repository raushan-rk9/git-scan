# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  # before_action :configure_sign_in_params, only: [:create]

  skip_before_action :verify_authenticity_token

  # GET /resource/sign_in
  def new
    super
  end

  # POST /resource/sign_in
  def create
    if @organization_set
      DataChange.clear_undo_history

      super
    else
      redirect_to new_user_session_path, error: 'No organization specified.'
    end
  end

  # DELETE /resource/sign_out
  def destroy
  end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end
end
