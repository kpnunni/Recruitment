class ApplicationController < ActionController::Base
  protect_from_forgery
  include SessionsHelper
    before_filter :authenticate

  def authenticate
    if !signed_in?
       redirect_to root_path
    end
  end
end
