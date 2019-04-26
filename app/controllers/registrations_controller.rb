class RegistrationsController < Devise::RegistrationsController
  include AccessManagement
  include ArchiveControlTouchFile

  # Sets the authentication key also for newly created
  def create
    super
    set_user_auth_key(@user)
  end

  # Delete the user and the archives with it
  def destroy
    delete_archives_with_user
    super
  end
  
  private

  # Delete archives where the user is admin when they close account
  def delete_archives_with_user
    archives_to_delete = get_archives_where_user_admin
    archives_to_delete.each do |archive|
      touch_delete(archive)
      archive.destroy
    end
  end

  # Get the archives where the user is admin
  def get_archives_where_user_admin
    @user.archives.select{|archive| archive.admin_users = [@user.id.to_s]}
  end

  def sign_up_params
    params.require(:user).permit(:username, :email, :password, :password_confirmation)
  end

  def account_update_params
    params.require(:user).permit(:username, :email, :password, :password_confirmation, :current_password)
  end
end
