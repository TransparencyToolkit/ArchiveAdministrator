# Touches files to control when archives should start, stop, and be deleted
module ArchiveControlTouchFile
  # Check if the archive is timed out
  def archive_timed_out?(archive)
    return (archive.last_access_date <= (Time.now-ENV['HOURS_TO_ARCHIVEVM_TIMEOUT'].to_i.hours))
  end
  
  # Touch a file to indicate when archive should start
  def touch_start(archive)
    create_control_dir
    command_path = "#{ENV['ARCHIVE_CONFIG_PATH']}/control/start_#{archive.index_name}"
    
    # Only start if it doesn't exist and should be shutdown
    FileUtils.touch(command_path) if (!File.exist?(command_path) && archive_timed_out?(archive))
  end

  # Stop a running archive
  def touch_stop(archive)
    command_path = "#{ENV['ARCHIVE_CONFIG_PATH']}/control/stop_#{archive.index_name}"

    # Only stop if it doesn't exist (command not sent already)
    FileUtils.touch(command_path) if !File.exist?(command_path)
  end

  # Delete an archive VM
  def touch_delete(archive)
    command_path = "#{ENV['ARCHIVE_CONFIG_PATH']}/control/delete_#{archive.index_name}"

    # Only delete if it doesn't exist (command not sent already)
    FileUtils.touch(command_path) if !File.exist?(command_path)
  end

  # Create control directory for commands
  def create_control_dir
    FileUtils.mkdir_p("#{ENV['ARCHIVE_CONFIG_PATH']}/control")
  end
end
