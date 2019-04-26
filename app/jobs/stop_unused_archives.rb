class StopUnusedArchives < ActiveJob::Base
  include ArchiveControlTouchFile
  
  # Shutdown archives not used in last day
  def perform
    # Get a list of archives not used within certain period
    unused_archives = get_unused_archives

    # Shutdown unused archives
    unused_archives.each do |archive|
      touch_stop(archive)
    end
  end

  # Get a list of archives not used in the last day
  def get_unused_archives
    archives = Archive.all
    return archives.select do |archive|
      last_accessed = archive.last_access_date
      true if last_accessed && last_accessed < (Time.now-ENV['HOURS_TO_ARCHIVEVM_TIMEOUT'].to_i.hours)
    end
  end
end
