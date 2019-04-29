class ArchivesController < ApplicationController
  include AccessManagement
  include ArchiveControlTouchFile
  include ConfigGenUtils

  def index
    # Get archives for the current user
    if current_user
      user = User.find(current_user.id)
      @archives = user.archives.all
    else # Show splash page if logged in
      render "unauthenticated"
    end
  end

  # Publish the archive
  def publish_archive_settings
    # Get the archive details and dataspec
    @archive = Archive.find(params["archive_id"])
    http_dataspec = Curl.get("#{set_dm_path(@archive)}/get_project_spec", {index_name: @archive.index_name})
    @dataspec = JSON.parse(http_dataspec.body_str)

    # Get the facets and values in array
    http_facets = Curl.get("#{set_dm_path(@archive)}/get_docs_on_index_page", {start: 0, index_name: @archive.index_name})
    @facets = JSON.parse(http_facets.body_str)["aggregations"].map{|f| [f[0], f[1]["buckets"].map{|v| v["key"]}]}.to_h

    render "publish_archive_settings"
  end

  # Receive post request when archive published
  def publish_archive
    # Get the parameters to pass
    settings_by_type = publish_filter_settings
    @archive = Archive.find(params["archive_id"])
    last_export_date = get_last_export_date

    # Set archive values based on input options and ensure started
    @archive.last_export_date = Time.now
    @archive.save
    update_last_access_date(@archive)
    touch_start(@archive)
    
    # Call the publish archive create job
    ArchivePublishJob.perform_now(@archive, settings_by_type, last_export_date)
    flash[:success] = "Your archive is being published. It may take some time for the data to transfer to the public instance."
    redirect_to @archive
  end

  # Get the last export date for archive
  def get_last_export_date
    @archive.last_export_date ? (return @archive.last_export_date) : (return Time.at(0))
  end

  # Get list of document types to publish and params for each
  def publish_filter_settings
    doc_types_to_publish = get_doc_types_to_publish
    return doc_types_to_publish.inject({}) do |settings, doc_type|
      params_for_type = params.to_unsafe_h.to_a.select{|p| p[0].include?(doc_type)}.to_h
      field_to_select_published = params_for_type["filterfield_#{doc_type}"]
      facet_values_that_mean_publish = params_for_type["#{doc_type}_filtervals"].reject!(&:blank?)
      fields_to_include = params_for_type["#{doc_type}_include"].reject!(&:blank?)

      # Set the settings to filter for with this doc type
      settings[doc_type] = { publish_selector_field: field_to_select_published,
                             facet_vals_to_publish: facet_values_that_mean_publish,
                             fields_to_include: fields_to_include }
      settings
    end
  end

  # Get an array of the document types that should be published
  def get_doc_types_to_publish
    return params.to_unsafe_h.to_a.select{|i| i[0].include?("publish_") && i[1] == "1"}.map{|d| d[0].split("publish_").last}
  end

  def update
    @archive = Archive.find(params["id"])
    
    # Update the archive settings
    if params["archive"] && is_archive_admin?
      update_last_access_date(@archive)
      touch_start(@archive)
      @archive.update(params["archive"].permit(:human_readable_name,
                                               :public_archive_subdomain,
                                               :description,
                                               :theme,
                                               :language,
                                               topbar_links: [:link_title, :link],
                                               info_dropdown_links: [:link_title, :link]).to_hash)
      ArchiveUpdateJob.perform_now(gen_archive_config_json(@archive), @archive.index_name, @archive)
      
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
      redirect_to archive_path(@archive) + "/give_user_access_form"
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
      redirect_to archive_path(@archive) + "/give_user_access_form"
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
    subdomain = params[:archive][:public_archive_subdomain]
    @archive = Archive.new({human_readable_name: params[:archive][:human_readable_name],
                            public_archive_subdomain: params[:archive][:public_archive_subdomain],
                            description: params[:archive][:description],
                            theme: params[:archive][:theme],
                            language: params[:archive][:language],
                            topbar_links: format_hash_param(params[:archive][:topbar_links]),
                            info_dropdown_links: format_hash_param(params[:archive][:info_dropdown_links]),
                            index_name: index_name,
                            data_sources: get_default_data_sources}.merge(set_default_pipeline_urls(subdomain)))
    
    # Associate archive with the appropriate user
    @archive.users << User.find(current_user.id)
    @archive.admin_users = [current_user.id]
    
    # Create the archive on DocManager
    ArchiveCreatorJob.perform_now(gen_archive_config_json(@archive), index_name, @archive)
    
    if @archive.save
      update_last_access_date(@archive)
      touch_start(@archive)
      redirect_to @archive
    else
      flash[:error] = "Subdomain chosen already in use. Please choose another."
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

  # Destroy the archive and archive VM
  def destroy
    @archive = Archive.find(params["id"].to_i)
    touch_delete(@archive)
    @archive.destroy
    redirect_to root_path
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
  def set_default_pipeline_urls(subdomain)
    ips = set_archive_ip
    return {
      archive_gateway_ip: ips[:archive_gateway_ip],
      archive_vm_ip: ips[:archive_vm_ip],
      public_gateway_ip: ips[:public_gateway_ip],
      public_vm_ip: ips[:public_vm_ip],
      uploadform_instance: set_archive_url(subdomain, "upload"),
      docmanager_instance: "http://0.0.0.0:3000",
      lookingglass_instance: set_archive_url(subdomain, "lookingglass"),
      catalyst_instance: "http://localhost:9004",
      ocr_in_path: "/home/tt/ocr_in",
      ocr_out_path: "/home/tt/ocr_out",
      save_export_path: "/home/tt/export_out",
      sync_jsondata_path: "#{ips[:public_vm_ip]}:/home/tt/ocr_out/ocred_docs",
      sync_rawdoc_path: "#{ips[:public_vm_ip]}:/home/tt/ocr_out/raw_docs",
      sync_config_path: "#{ips[:public_vm_ip]}:/tt-ansible/DocManager/dataspec_files",
      archive_key: SecureRandom.base64(100)
    }
  end

  # Generate IP address for new archive
  def set_archive_ip
    # Generate the archive IP
    subnet_arr = [*2..255]-[13]
    s1 = subnet_arr.sample
    s2 = subnet_arr.sample
    ip_base = "10.#{s1}.#{s2}."

    # Check if one exists with IP, if so run again. Otherwise return.
    if Archive.find_by(archive_gateway_ip: ip_base+"1")
      set_archive_ip
    else
      return { archive_gateway_ip: ip_base+"1",
               archive_vm_ip: ip_base+"2",
               public_gateway_ip: ip_base+"3",
               public_vm_ip: ip_base+"4"
      }
    end
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
