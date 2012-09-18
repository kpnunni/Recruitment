class SessionsController < ApplicationController
  skip_before_filter :authenticate

  def new
    if signed_in?
      redirect_to '/homes/index'
    end
  end

  def create
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
      else
        flash[:notice ] = 'Invalid email/password combination'
        render "new"
      end
    else
        flash[:notice ] = 'Invalid email/password combination'
        render "new"
      end

  end

  def destroy
    sign_out
    redirect_to root_path
  end
end
