module ConfigGenUtils
  # Set path to DM (with test mode)
  def set_dm_path(archive)
    if ENV['TESTMODE'] != "true"
      return archive.archive_vm_ip+":3000"
    else
      return "http://0.0.0.0:3000"
    end
  end

  # Set the path to LG/docupload (with testmode)
  def set_archive_url(index_name, service)
    if ENV['TESTMODE'] != "true"
      return "#{ENV['PREPUB_ARCHIVE_DOMAIN']}/#{index_name}/#{service}"
    else # Use localhost when testing
      if service == "lookingglass"
        return "http://localhost:3001"
      elsif service == "upload"
        return "http://localhost:9292"
      end
    end
  end
  
  # Generate a config file for a service with env vars
  def gen_service_config(env_hash, archive_config_dir, service_name)
    # Generate the config file
    str = "[Service]\n"
    env_hash.each do |env_var_name, value|
      str += 'Environment="'+env_var_name.to_s+'='+value.to_s+'"'+"\n"
    end

    # Write env variables to a file
    service_config_path = "#{archive_config_dir}/#{service_name}.service.d"
    FileUtils.mkdir_p(service_config_path)
    File.write("#{service_config_path}/#{service_name}.conf", str)
  end
end
