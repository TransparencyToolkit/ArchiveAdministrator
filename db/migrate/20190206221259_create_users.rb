class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    enable_extension 'hstore' unless extension_enabled?('hstore')
    
    create_table :users do |t|
      t.string :username
      t.string :email
      t.string :archive_auth_key

      t.timestamps
    end
  end
end
