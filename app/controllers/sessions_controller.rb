class SessionsController < Devise::SessionsController
  include AccessManagement
  
  def create
    # Set auth key for the user
    user = User.find_by(username: params["user"]["username"])
    if user
      set_user_auth_key(user)
    end
    super
  end

  def destroy
    user = User.find_by(archive_auth_key: cookies[:archive_auth_key])
    if user
      destroy_user_auth_key(user)
    end
    super
  end
end

