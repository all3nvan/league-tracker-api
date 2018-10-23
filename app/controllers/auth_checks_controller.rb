class AuthChecksController < ApplicationController
  # Used to verify if JWT is still valid
  def index
    authenticate_admin
  end
end
