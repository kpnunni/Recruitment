class ApplicationController < ActionController::Base
  protect_from_forgery
  include SessionsHelper
  before_filter :store_location
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
  def call_rake(task, options = {})
    options[:rails_env] ||= Rails.env
    args = options.map { |n, v| "#{n.to_s.upcase}='#{v}'" }
    system "rake #{task} #{args.join(' ')} --trace 2>&1 >> #{Rails.root}/log/rake.log &"
  end


  def store_location
    # store last url - this is needed for post-login redirect to whatever the user last visited.
    return unless request.get? 
    if (request.path != "/signin" &&
        request.path != "/sign_out" &&
        request.path != "/sessions" &&
        request.path != "/homes/index" &&
        request.path != "/users/confirmation" &&
        request.path != "/users/sign_out" &&
        !request.xhr?) # don't store ajax calls
      session[:previous_url] = request.fullpath 
    end
  end

  def after_sign_in_path_for
    session[:previous_url] || root_path
  end

end
