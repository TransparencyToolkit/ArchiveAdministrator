# Set where the config files should be stored
ENV['ARCHIVE_CONFIG_PATH'] = "/home/user/tt_archive_config" if ENV['ARCHIVE_CONFIG_PATH'] == nil
ENV['ARCHIVEADMIN_URL'] = "http://localhost:3002" if ENV['ARCHIVEADMIN_URL'] == nil

ENV['HOURS_TO_ARCHIVEVM_TIMEOUT'] = "12"
