class ApplicationController < ActionController::Base
  protect_from_forgery
  include SessionsHelper
    before_filter :authenticate

  def authenticate
    if !signed_in?
       redirect_to '/signin'
    else
      #To forcefully make signout 'remember me' users when isalive==false.
      if !current_user.isAlive&&!my_roles.include?('Candidate')
        sign_out
        redirect_to '/signin'
      end
    end
  end
end
