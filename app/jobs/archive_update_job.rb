class ArchiveUpdateJob < ApplicationJob
  include ConfigGenUtils
  queue_as :default

  # Create a new archive on docmanager
  def perform(archive_config_json, index_name, archive)
    c = Curl::Easy.new("#{set_dm_path(archive)}/update_archive")
    c.http_post(Curl::PostField.content("archive_config_json", archive_config_json),
                Curl::PostField.content("index_name", index_name))
  end
end
