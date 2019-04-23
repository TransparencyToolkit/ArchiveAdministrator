class ArchiveCreatorJob < ApplicationJob
  queue_as :default

  # Create a new archive on docmanager
  def perform(archive_config_json, docmanager_url, index_name, archive)
    # Create the config files needed to generate archive VM
    save_archive_service_configs(archive)

    # Create a new archive on docmanager
    c = Curl::Easy.new("#{docmanager_url}/create_archive")
    c.http_post(Curl::PostField.content("archive_config_json", archive_config_json))
  end

  # Generate config file for archive
  def save_archive_service_configs(archive)
    archive_config_dir = ENV["ARCHIVE_CONFIG_PATH"]+"/"+archive.index_name
    FileUtils.mkdir_p(archive_config_dir)
    create_pipeline_configs(archive_config_dir, archive)
  end

  # Generate config files with environment variables for each app in the pipeline
  def create_pipeline_configs(archive_config_dir, archive)
    # Generate Docmanager config
    docmanager = { "DOCMANAGER_URL": archive[:docmanager_instance],
                   "CATALYST_URL": archive[:catalyst_instance]}
    gen_service_config(docmanager, archive_config_dir, "docmanager")

    # Generate LG config
    lookingglass = { "DOCMANAGER_URL": archive[:docmanager_instance],
                     "CATALYST_URL": archive[:catalyst_instance],
                     "DOCUPLOAD_URL": archive[:uploadform_instance],
                     "ARCHIVEADMIN_URL": ENV['ARCHIVEADMIN_URL'],
                     "WRITEABLE": "true",
                     "PROJECT_INDEX": archive[:index_name],
                     "ARCHIVE_SECRET_KEY": archive[:archive_key] }
    gen_service_config(lookingglass, archive_config_dir, "lookingglass")

    # Generate DocUpload config
    docupload = { "LOOKINGGLASS_URL": archive[:lookingglass_instance],
                  "ARCHIVEADMIN_URL": ENV['ARCHIVEADMIN_URL'],
                  "OCR_IN_PATH": archive[:ocr_in_path],
                  "OCR_OUT_PATH": archive[:ocr_out_path],
                  "PROJECT_INDEX": archive[:index_name],
                  "ARCHIVE_SECRET_KEY": archive[:archive_key] }
    gen_service_config(docupload, archive_config_dir, "docupload")

    # Generate OCR server config
    ocrserver = { "OCR_IN_PATH": archive[:ocr_in_path],
                  "OCR_OUT_PATH": archive[:ocr_out_path],
                  "PROJECT_INDEX": archive[:index_name] }
    gen_service_config(ocrserver, archive_config_dir, "ocrserver")

    # Generate IndexServer config
    indexserver = { "OCR_OUT_PATH": archive[:ocr_out_path],
                    "DOCMANAGER_URL": archive[:docmanager_instance] }
    gen_service_config(indexserver, archive_config_dir, "indexserver")

    # Generate Catalyst config
    catalyst = { "DOCMANAGER_URL": archive[:docmanager_instance] }
    gen_service_config(catalyst, archive_config_dir, "catalyst")
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
