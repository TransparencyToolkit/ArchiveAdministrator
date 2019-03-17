class RegistrationsController < Devise::RegistrationsController
  include AccessManagement

  # Sets the authentication key also for newly created
  def create
    super
    set_user_auth_key(@user)
  end
  
  private

  def sign_up_params
    params.require(:user).permit(:username, :email, :password, :password_confirmation)
  end

  def account_update_params
    params.require(:user).permit(:username, :email, :password, :password_confirmation, :current_password)
  end
end
