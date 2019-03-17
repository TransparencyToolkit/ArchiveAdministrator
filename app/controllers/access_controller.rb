class AccessController < ApplicationController
  skip_before_action :verify_authenticity_token
  
  def can_access_archive
    # Get the user by key in cookie and archive by secret key from app
    user = User.find_by(archive_auth_key: params["archive_auth_key"])
    archive = Archive.find_by(archive_key: params["archive_secret_key"])

    # Check that it found user for key and correct archive
    if user && archive && archive.index_name == params["index_name"]
      # User has access
      if user.archives.map{|a| a.index_name}.include?(params["index_name"])
        render json: {has_access: "yes"}
      # User exists but does not have access
      elsif !user.archives.map{|a| a.index_name}.include?(params["index_name"])
        render json: {has_access: "no"}
      end
    else # Doesn't have access, redirect to login
      render json: {has_access: "unauthenticated"}
    end
  end
end
