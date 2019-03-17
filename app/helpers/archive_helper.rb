module ArchiveHelper 
  # Only allow edits if archive is administrator
  # REDUNDANT WITH CONTROLLER
  def is_archive_admin?
    return current_user && @archive.admin_users.include?(current_user.id.to_s)
  end

  # Return only users that aren't admins
  def not_an_admin?(user)
    return !@archive.admin_users.include?(user.id.to_s)
  end
end
