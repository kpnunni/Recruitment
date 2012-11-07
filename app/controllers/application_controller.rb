class ApplicationController < ActionController::Base
  protect_from_forgery
  include SessionsHelper
    before_filter :authenticate

  def authenticate
    if !signed_in?
       redirect_to '/signin'
    else
      #To forcefully make signout 'remember me' users when isalive==false.
      if !current_user.isAlive&&!current_user.has_role?('Candidate')
        sign_out
        redirect_to '/signin'
      end
    end
  end
end
