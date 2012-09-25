class SessionsController < ApplicationController
  skip_before_filter :authenticate

  def new
    if signed_in?
      redirect_to '/homes/index'
    end
  end

  def create

    if params[:session][:email]==""
        flash[:notice ] = 'Enter your Email id'
        render "new"
        return
    end
    if params[:session][:password]==""
        flash[:notice ] = 'Enter the password'
        render "new"
        return
    end
    if (params[:session][:email]=~/\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i).nil?
        flash[:notice ] = 'Invalid email id'
        render "new"
        return
    end
    user = User.find_by_user_email(params[:session][:email])
    login_password=params[:session][:password]

    if user!=nil
      login_password=Digest::SHA2.hexdigest("#{user.salt}--#{login_password}")

  #  render :text => User.find(session[:remember_token]).userEmail

      if ( user.password==login_password && user.isAlive== true && user.isDelete== false  )

        if params[:session][:remember]
          session[:remember_token] = user.id
        end
        if user.has_role?('candidate')&&!user.candidate.schedule.nil?
               sign_in user
               redirect_to candidate_detail_answers_path
        elsif user.has_role?('admin')||user.has_role?('super_user')
          sign_in user
          redirect_to '/homes/index'
        else
          flash[:notice ] = 'Sorry, You can login only after getting date for the exam.'
          render "new"
        end
      elsif user.has_role?('candidate')
        flash[:notice ] = 'You cant login again. Contact admin.'
        render "new"
      else
        flash[:notice ] = 'Invalid email/password combination'
        render "new"
      end
    else
        flash[:notice ] = 'email address not present'
        render "new"
      end

  end

  def destroy
    sign_out
    redirect_to root_path
  end
end
