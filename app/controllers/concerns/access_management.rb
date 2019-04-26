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

  # Keep the last access date up to date so archive doesn't shut down
  def update_last_access_date(archive)
    archive.last_access_date = Time.now
    archive.save
  end
end
