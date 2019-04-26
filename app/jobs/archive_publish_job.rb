class ArchivePublishJob < ApplicationJob
  include ConfigGenUtils
  queue_as :default

  # Create a new archive on docmanager
  def perform(archive, settings_by_type, last_export_date)
    save_public_archive_service_configs(archive)
    settings_by_type.each do |doc_type, type_values|
      c = Curl.get("#{archive['docmanager_instance']}/export_to_public",
                   {date_changed_since: last_export_date,
                    pub_selector_field: type_values[:publish_selector_field],
                    acceptable_to_publish_values: JSON.pretty_generate(type_values[:facet_vals_to_publish]),
                    fields_to_include_in_export: JSON.pretty_generate(type_values[:fields_to_include]),
                    index_name: archive.index_name,
                    doc_type: doc_type})    
    end
  end
  
  # Generate config files for public archive
  def save_public_archive_service_configs(archive)
    archive_config_dir = ENV["ARCHIVE_CONFIG_PATH"]+"/"+archive.index_name+"_publicconfig"
    FileUtils.mkdir_p(archive_config_dir)
    create_pipeline_configs(archive_config_dir, archive)
  end

  # Generate config file with environment variables for each app in the pipeline
  def create_pipeline_configs(archive_config_dir, archive)
    # Generate Docmanager config
    docmanager = { "DOCMANAGER_URL": archive[:docmanager_instance] }
    gen_service_config(docmanager, archive_config_dir, "docmanager")

    # Generate LG config
    lookingglass = { "DOCMANAGER_URL": archive[:docmanager_instance],
                     "WRITEABLE": "false",
                     "PROJECT_INDEX": archive[:index_name] }
    gen_service_config(lookingglass, archive_config_dir, "lookingglass")

    # Generate IndexServer config
    indexserver = { "OCR_OUT_PATH": archive[:ocr_out_path],
                    "DOCMANAGER_URL": archive[:docmanager_instance] }
    gen_service_config(indexserver, archive_config_dir, "indexserver")
  end
end
