class ArchiveCreatorJob < ApplicationJob
  include ConfigGenUtils
  queue_as :default

  # Create a new archive on docmanager
  def perform(archive_config_json, index_name, archive)
    # Create the config files needed to generate archive VM
    save_archive_service_configs(archive)

    # Create a new archive on docmanager
    send_archive_config_to_dm(archive_config_json, archive)
  end

  # Create a new archive on DocManager
  def send_archive_config_to_dm(archive_config_json, archive)
    begin
      sleep(1)
      c = Curl::Easy.new("#{set_dm_path(archive)}/create_archive")
      c.http_post(Curl::PostField.content("archive_config_json", archive_config_json))
    rescue
      send_archive_config_to_dm(archive_config_json, archive)
    end
  end

  # Generate config file for archive
  def save_archive_service_configs(archive)
    archive_config_dir = ENV["ARCHIVE_CONFIG_PATH"]+"/"+archive.index_name
    FileUtils.mkdir_p(archive_config_dir)
    create_pipeline_configs(archive_config_dir, archive)
  end

  # Generate config file for IP addresses
  def gen_ip_config_file(archive_config_dir, archive)
    ip_config = {"ARCHIVE_GATEWAY_IP": archive[:archive_gateway_ip],
                 "ARCHIVE_VM_IP": archive[:archive_vm_ip],
                 "SUBDOMAIN": archive[:public_archive_subdomain]}
    config_path = "#{archive_config_dir}/ip_config.json"
    File.write(config_path, JSON.pretty_generate(ip_config))
  end

  # Generate config files with environment variables for each app in the pipeline
  def create_pipeline_configs(archive_config_dir, archive)
    gen_ip_config_file(archive_config_dir, archive)
    
    # Generate Docmanager config
    docmanager = { "DOCMANAGER_URL": archive[:docmanager_instance],
                   "CATALYST_URL": archive[:catalyst_instance],
                   "SAVE_EXPORT_PATH": archive[:save_export_path],
                   "SYNC_JSONDATA_PATH": archive[:sync_jsondata_path],
                   "SYNC_RAWDOC_PATH": archive[:sync_rawdoc_path],
                   "SYNC_CONFIG_PATH": archive[:sync_config_path]
                   }
    gen_service_config(docmanager, archive_config_dir, "docmanager")

    # Generate LG config
    lookingglass = { "DOCMANAGER_URL": archive[:docmanager_instance],
                     "CATALYST_URL": archive[:catalyst_instance],
                     "DOCUPLOAD_URL": archive[:uploadform_instance],
                     "ARCHIVEADMIN_URL": ENV['ARCHIVEADMIN_URL'],
                     "WRITEABLE": "true",
                     "PROJECT_INDEX": archive[:index_name],
                     "RAILS_RELATIVE_ROOT_URL": "/#{archive[:public_archive_subdomain]}/lookingglass/",
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
end
