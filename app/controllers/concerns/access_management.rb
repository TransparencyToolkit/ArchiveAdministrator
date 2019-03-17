module AccessManagement
  # Sets the authentication key for single sign on
  def set_user_auth_key(user)
    new_auth_key = SecureRandom.base64(100)
    cookies[:archive_auth_key] = new_auth_key
    user.archive_auth_key = new_auth_key
    user.save
  end

  # Destroy cookie saved for session
  def destroy_user_auth_key(user)
    user.archive_auth_key= ""
    user.save
    cookies[:archive_auth_key] = "none"
  end
end
