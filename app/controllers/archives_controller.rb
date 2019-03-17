class ArchivesController < ApplicationController
  def index
    # Get archives for the current user
    if current_user
      user = User.find(current_user.id)
      @archives = user.archives.all
    else # Show splash page if logged in
      render "unauthenticated"
    end
  end

  def update
    @archive = Archive.find(params["id"])
    
    # Update the archive settings
    if params["archive"] && is_archive_admin?
      @archive.update(params["archive"].permit(:human_readable_name,
                                               :description,
                                               :theme,
                                               :language,
                                               topbar_links: [:link_title, :link],
                                               info_dropdown_links: [:link_title, :link]).to_hash)
      redirect_to @archive
    else
      render "edit"
    end
  end

  # Add user to archive (if not already added)
  def add_user_to_archive
    @archive = Archive.find(params["archive_id"].to_i)

    # Add users to list with access if allowed
    if is_archive_admin?
      user_to_add = User.find_by(username: params["user_to_add"])
      @archive.users << user_to_add if !@archive.users.include?(user_to_add)
      redirect_to archive_path(@archive)
    else
      render "not_allowed"
    end
  end

  # Remove user access to the archive
  def remove_user_access
    @archive = Archive.find(params["archive_id"].to_i)
    if is_archive_admin?
      user_to_remove = User.find_by(username: params["user"])
      @archive.users.delete(user_to_remove)
      redirect_to @archive
    else
      render "not_allowed"
    end
  end

  # Show the form to give users access to the archive
  def give_user_access_form
    @archive = Archive.find(params["archive_id"].to_i)
    if is_archive_admin?
      render "give_user_access_form"
    else
      render "not_allowed"
    end
  end

  def edit
    # Only allow edits if admin user
    @archive = Archive.find(params["id"])
    if is_archive_admin?
      render "edit"
    else # Don't allow unauthorized edits
      render "not_allowed"
    end
  end
  
  def create
    # Save the archive settings
    index_name = gen_index_name(params[:archive][:human_readable_name])
    @archive = Archive.new({human_readable_name: params[:archive][:human_readable_name],
                           description: params[:archive][:description],
                           theme: params[:archive][:theme],
                           language: params[:archive][:language],
                           topbar_links: format_hash_param(params[:archive][:topbar_links]),
                           info_dropdown_links: format_hash_param(params[:archive][:info_dropdown_links]),
                           index_name: index_name,
                           data_sources: get_default_data_sources}.merge(set_default_pipeline_urls))

    # Associate archive with the appropriate user
    @archive.users << User.find(current_user.id)
    @archive.admin_users = [current_user.id]
    
    # Create the archive on DocManager
    ArchiveCreatorJob.perform_now(gen_archive_config_json(@archive), @archive.docmanager_instance, index_name)
    
    if @archive.save
      redirect_to @archive
    else
      render "new"
    end
  end

  def new
    @archive = Archive.new
  end

  def show
    @archive = Archive.where(id: params[:id]).first

    respond_to do |format|
      format.html
    end
  end

  private

  # Only allow edits if archive is administrator
  def is_archive_admin?
    return current_user && @archive.admin_users.include?(current_user.id.to_s)
  end

  # Generate JSON config file for archive
  def gen_archive_config_json(archive)
    # Clear empty link values for custom links
    archive.topbar_links.delete_if{|k,v| k.empty?}
    archive.info_dropdown_links.delete_if{|k,v| k.empty?}

    # Generate hash of config details
    return JSON.pretty_generate({
      index_name: archive.index_name,
      display_details: {
        title: archive.human_readable_name.to_s,
        theme: archive.theme.to_s,
        favicon: archive.favicon.to_s,
        logo: archive.logo.to_s,
        info_links: archive.info_dropdown_links,
        other_topbar_links: archive.topbar_links
      },
      data_source_details: archive.data_sources
    })
  end

  # Set the default data sources for hosted archives
  def get_default_data_sources
    return [
      "dataspec_files/data_sources/archive_documents.json",
      "dataspec_files/data_sources/email.json",
      "dataspec_files/data_sources/entity_company.json",
      "dataspec_files/data_sources/entity_person.json",
      "dataspec_files/data_sources/entity_location.json",
      "dataspec_files/data_sources/entity_event.json",
      "dataspec_files/data_sources/entity_note.json"
    ]
  end

  # Set the URLS for the other parts of the pipeline
  def set_default_pipeline_urls
    return {
      uploadform_instance: "http://localhost:9292",
      docmanager_instance: "http://0.0.0.0:3000",
      lookingglass_instance: "http://localhost:3001",
      catalyst_instance: "http://localhost:9004",
      ocr_in_path: "/home/user/ocr_in",
      ocr_out_path: "/home/user/ocr_out",
      archive_key: SecureRandom.base64(100)
    }
  end

  # Generate the index name
  def gen_index_name(human_readable)
    index_valid = human_readable.downcase.gsub(" ", "_").gsub("'", "")
    return index_valid+"_"+SecureRandom.urlsafe_base64(4).downcase.gsub("-", "")
  end

  # Changes the format of a hash param from that passed in the form
  def format_hash_param(hash_param)
    return { hash_param[:link_title] => hash_param[:link] }
  end
end
