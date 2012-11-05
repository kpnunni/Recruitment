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
    if user.nil?
      flash[:notice ] = "user doesn't exist"
      render "new"
      return
    end

    login_password=Digest::SHA2.hexdigest("#{user.salt}--#{login_password}")

    if !(user.password==login_password && user.isAlive== true && user.isDelete== false)
      flash[:notice ] = "Invalid password/not alive"
      render "new"
      return
    end

    if params[:session][:remember]=="0"
      cookies[:remember_token] = user.remember_token
    else
      cookies[:remember_token] = { :value => user.remember_token, :expires => 7.days.from_now }
    end

    if user.has_role?('Candidate')&&!user.candidate.schedule.nil?
      sign_in user
      redirect_to candidate_detail_answers_path
    elsif user.has_role?('Candidate')&&user.candidate.schedule.nil?
      flash[:notice ] = 'Sorry, You can login only after getting date for the exam.'
      render "new"
    elsif user.roles.count==Role.count-1
      sign_in user
      redirect_to '/homes/admin'
    elsif user.has_role?('Manage Users')||user.has_role?('Manage Questions')||user.has_role?('Manage Candidates')||user.has_role?('Manage Exams')||user.has_role?('Schedule')||
        user.has_role?('Interviewer')||user.has_role?('Add Questions Only')|| user.has_role?('Add Questions')|| user.has_role?('Re Schedule')||user.has_role?('Cancel Schedule')||user.has_role?('Validate Result')||user.has_role?('Manage Templates')||user.has_role?('View Result')
      sign_in user
      redirect_to '/homes/index'
    else
      flash[:notice ] = 'You cant login. Contact admin.'
      render "new"
    end
  end

  def destroy
    sign_out
    redirect_to root_path
  end
  def signup
    if params[:as]=="emp"
      @user=User.new
    else
      @candidate=Candidate.new
      @candidate.build_user
    end
  end

  def success
  end

  def forgotpass

  end
  def sent_pass
    @user=User.find_by_user_email(params[:session][:email])
    if @user.nil?
      render 'forgotpass'
      flash[:notice]="Email id doesn't exist."
      return
    end
    if @user.has_role?('Candidate')
      render 'forgotpass'
      flash[:notice]="Candidate not able to do this."
      return
    end
    if !@user.isAlive?
      render 'forgotpass'
      flash[:notice]="Email id is not alive."
      return
    end
    token=@user.remember_token
    UserMailer.sent_password(@user,token).deliver
  end
  def reset_pass
    @user=User.find_by_remember_token(params[:id])
    sign_in(@user)
    redirect_to chgpass_user_path(@user.id)
  end
end