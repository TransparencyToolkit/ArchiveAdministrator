class CreateJoinTableUserArchive < ActiveRecord::Migration[5.2]
  def change
    create_join_table :users, :archives do |t|
      t.index [:user_id, :archive_id]
      t.index [:archive_id, :user_id]
    end
  end
end
