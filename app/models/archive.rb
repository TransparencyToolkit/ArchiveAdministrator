class Archive < ApplicationRecord
  has_and_belongs_to_many :users
  
  #  validates_presence_of :index_name, :human_readable_name, :admin_users
  validates :index_name, uniqueness: true
  store_accessor :topbar_links
  store_accessor :info_dropdown_links
end
