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
  def call_rake(task, options = {})
    options[:rails_env] ||= Rails.env
    args = options.map { |n, v| "#{n.to_s.upcase}='#{v}'" }
    system "rake #{task} #{args.join(' ')} --trace 2>&1 >> #{Rails.root}/log/rake.log &"
  end
end
