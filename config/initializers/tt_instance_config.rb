# Set where the config files should be stored
ENV['ARCHIVE_CONFIG_PATH'] = "/home/user/tt_archive_config" if ENV['ARCHIVE_CONFIG_PATH'] == nil
ENV['ARCHIVEADMIN_URL'] = "http://localhost:3002" if ENV['ARCHIVEADMIN_URL'] == nil

# Set time after which unused private archives should be shutdown
ENV['HOURS_TO_ARCHIVEVM_TIMEOUT'] = "12" if ENV['HOURS_TO_ARCHIVEVM_TIMEOUT'] == nil

# Set domain to use for private archives
ENV['PREPUB_ARCHIVE_DOMAIN'] = "https://transparency.tools" if ENV['PREPUB_ARCHIVE_DOMAIN'] == nil
