module ConfigGenUtils
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
