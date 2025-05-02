# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  # before_action :configure_sign_in_params, only: [:create]
  layout 'application'

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  def create
    user = User.find_by(email: params[:user][:email])
    if user && !user.student? && !user.approved?
      flash[:alert] = "Your account is pending approval from an administrator."
      redirect_to new_user_session_path
    else
      super
    end
  end

  # DELETE /resource/sign_out
  def destroy
    super
    # Add any additional cleanup if needed
  end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end
end
