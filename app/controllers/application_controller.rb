class ApplicationController < ActionController::Base
  protect_from_forgery
  include SessionsHelper
    before_filter :authenticate

  def authenticate
    if !signed_in?
       redirect_to '/signin'
    else
      if !current_user.isAlive
        sign_out
        redirect_to '/signin'
      end
    end
  end
end
