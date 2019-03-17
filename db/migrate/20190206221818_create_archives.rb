class CreateArchives < ActiveRecord::Migration[5.2]
  def change
    enable_extension 'hstore' unless extension_enabled?('hstore')
    
    create_table :archives do |t|
      # Index settings
      t.string :index_name
      t.string :language
      t.text :data_sources, array: true

      # UI/theme settings
      t.string :human_readable_name
      t.text :description
      t.hstore :topbar_links
      t.hstore :info_dropdown_links
      t.string :logo
      t.string :favicon
      t.string :theme

      # Applications in pipeline
      t.string :lookingglass_instance
      t.string :uploadform_instance
      t.string :docmanager_instance
      t.string :catalyst_instance
      t.string :ocr_in_path
      t.string :ocr_out_path
      t.string :archive_key

      # Access settings
      t.text :admin_users, array: true

      t.timestamps
    end
  end
end
