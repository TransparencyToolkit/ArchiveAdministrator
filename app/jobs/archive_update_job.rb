class ArchiveUpdateJob < ApplicationJob
  queue_as :default

  # Create a new archive on docmanager
  def perform(archive_config_json, docmanager_url, index_name)
    c = Curl::Easy.new("#{docmanager_url}/update_archive")
    c.http_post(Curl::PostField.content("archive_config_json", archive_config_json),
                Curl::PostField.content("index_name", index_name))
  end
end
