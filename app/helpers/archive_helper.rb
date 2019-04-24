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

  # Return a list of the human readable names of category fields for a datasource
  def list_category_fields(datasource)
    return datasource["source_fields"].to_a.select{|f| f[1]["display_type"] == "Category"}.map{|i| [i[1]["human_readable"], i[0]]}.to_h
  end

  # Return a list of the key names of category fields for a datasource
  def list_category_fields_machine_readable(datasource)
    return datasource["source_fields"].to_a.select{|f| f[1]["display_type"] == "Category"}.map{|i| i[0]}
  end

  # Remap field info to work with collection checkboxes
  def remap_field_info(datasource)
    return datasource["source_fields"].to_a.map{|i| [i[0], i[1]["human_readable"]]}.to_h
  end
end
