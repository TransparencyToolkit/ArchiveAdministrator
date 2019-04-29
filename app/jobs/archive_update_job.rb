class ArchiveUpdateJob < ApplicationJob
  include ConfigGenUtils
  queue_as :default

  # Create a new archive on docmanager
  def perform(archive_config_json, index_name, archive)
    send_archive_config_to_dm(archive_config_json, index_name, archive)
  end

  # Send the archive config to DocManager
  def send_archive_config_to_dm(archive_config_json, index_name, archive)
    begin
      c = Curl::Easy.new("#{set_dm_path(archive)}/update_archive")
      c.http_post(Curl::PostField.content("archive_config_json", archive_config_json),
                  Curl::PostField.content("index_name", index_name))
    rescue # Retry if update fails
      sleep(5)
      send_archive_config_to_dm(archive_config_json, index_name, archive)
    end
  end
end
