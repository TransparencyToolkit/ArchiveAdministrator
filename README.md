# ArchiveAdministrator

This is software for managing the users and archives in the hosted archive
service. It authenticates users and manages the other applications used to run
the archives, including creating new instances, starting the instances, and
stopping the instances as needed. It also allows customization of archive
titles, logos, and themes.

This is a work in progress!! Do not use it yet unless you are helping develop
the hosted archive service.


## Install

Make sure you have nodejs installed

1. Pull this repository
2. Install the `redis-server` debian package
3. Run `bundle install`
4. Set the following env variables in `config/initializers/tt_instance_config.rb`
   * ARCHIVE_CONFIG_PATH: The path where archive config files should be saved
   * ARCHIVEADMIN_URL: The url where this application is accessible
   * HOURS_TO_ARCHIVEVM_TIMEOUT: # of hours where unused archive vms should shutdown
   * TESTMODE: Set to true if testing locally not with VM. Not needed in production.
   * PREPUB_ARCHIVE_DOMAIN: Domain used for private archives

## Run App

Note: `DocManager` must be running

1. Run Redis: `QUEUE=* rake environment resque:work`
2. Start the app: `rails server -p 3002` 
3. Run `bundle exec crono RAILS_ENV=development` in a session (only needed for `production`)
4. Start the app: rails server -p 3002 (Note: DocManager must be running)


## Limitations

With the current version of this software, you still need to do the following:

1. Manually install all pipeline components
2. Start all pipeline components manually or with a script
3. Manually set all environment variables. To work, the `PROJECT_INDEX` and
`ARCHIVE_SECRET_KEY` variables need to be set to those for the corresponding
archive. The index name for an archive is viewable on the interface. The
secret key needs to be gotten with rails console.

4. Run the OCR server manually

It does, however, create the DM project/data sources and elastic index
automatically as well as config files with env variables.
