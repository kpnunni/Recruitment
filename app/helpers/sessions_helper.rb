module SessionsHelper
  def sign_in(user)
    self.current_user = user
    cookies[:remember_token] = user.remember_token if cookies[:remember_token].nil?
  end

  def current_user=(user)
    @current_user = user
  end

  def current_user
    @current_user ||= User.find_by_remember_token(cookies[:remember_token])
  end
  def signed_in?
    !current_user.nil?
  end
  def admin?
    my_roles.count == 16
  end
  def sign_out
    self.current_user = nil
    session[:remember_token]=nil
    cookies.delete(:remember_token)
  end
  def my_roles
    if current_user
      @my_roles ||=  current_user.roles.map(&:role_name)
    else
     @my_roles ||=[]
    end
  end

  def negative
    @negative ||= Setting.find_by_name('negative_mark')
  end
  def auto_result
     @auto_result ||= Setting.find_by_name('auto_result')
  end


end
