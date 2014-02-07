class SessionsController < ApplicationController
  skip_before_filter :authenticate

  def new
    if signed_in?&&my_roles.include?('Candidate')
      redirect_to '/homes/default_page'
    elsif signed_in?
      redirect_to '/homes/index'
    end
  end

  def create

    if params[:session][:email]==""
      flash.now[:error ] = 'Enter your Email id'
      render "new"
      return
    end
    if params[:session][:password]==""
      flash.now[:error ] = 'Enter the password'
      render "new"
      return
    end
    if (params[:session][:email]=~/\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i).nil?
      flash.now[:error ] = 'Invalid email id'
      render "new"
      return
    end
    user = User.find_by_user_email(params[:session][:email])
    login_password=params[:session][:password]
    if user.nil?
      flash.now[:error ] = "user doesn't exist"
      render "new"
      return
    end

    login_password=Digest::SHA2.hexdigest("#{user.salt}--#{login_password}")

    if !(user.password==login_password && user.isAlive== true && user.isDelete== false)
      flash.now[:error ] = "Invalid password/not alive"
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
      cookies[:remember_token] = user.remember_token
      redirect_to candidate_detail_answers_path
    elsif user.has_role?('Candidate')&&user.candidate.schedule.nil?
      flash.now[:error ] = 'Sorry, You can login only after getting date for the exam.'
      render "new"
    elsif user.admin?
      sign_in user
      redirect_to '/homes/admin'
    elsif user.has_role?('Manage Users')||user.has_role?('Manage Questions')||user.has_role?('Manage Candidates')||user.has_role?('Manage Exams')||user.has_role?('Schedule')||
        user.has_role?('Interviewer')||user.has_role?('Add Questions Only')|| user.has_role?('Add Questions')|| user.has_role?('Re Schedule')||user.has_role?('Cancel Schedule')||user.has_role?('Validate Result')||user.has_role?('Manage Templates')||user.has_role?('View Result')
      sign_in user
      redirect_to '/homes/index'
    else
      flash.now[:error ] = 'You cant login. Contact admin.'
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
      flash.now[:error]="Email id doesn't exist."
      render 'forgotpass'
      return
    end
    if @user.has_role?('Candidate')
      flash.now[:error]="Candidate can not able to do this."
      render 'forgotpass'
      return
    end
    if !@user.isAlive?
      flash.now[:error]="Email id is not alive."
      render 'forgotpass'
      return
    end
    token=@user.remember_token
    UserMailer.delay.sent_password(@user,token)
    UserMailer.sent_password(@user,token).deliver
  end
  def reset_pass
    @user=User.find_by_remember_token(params[:id])
    sign_in(@user)
    redirect_to chgpass_user_path(@user.id)
  end
  def registration
    if params[:can]=="Register"
       @candidate=Candidate.new(params[:candidate])
       if params[:confirm_email] != @candidate.user.user_email
         flash.now[:error] = "Email not matching with confirmation"
          render 'signup'
         return
       end

       @candidate.user.login_password="suyati123"
       @candidate.user.login_password_confirmation="suyati123"
       @candidate.user.encrypt_password
       @candidate.user.roles.push(Role.find_by_role_name('Candidate'))
      if @candidate.save
        redirect_to success_sessions_path(:as=>"can"), notice: 'Candidate was successfully created.'
      else
        render 'signup'
      end
    else
        @user=User.new(params[:user])
        if @user.user_email=~/\A[\w+\-.]+@suyati.com+\z/i
          rand_password=('0'..'z').to_a.shuffle.first(4).join
          @user.login_password=rand_password
          @user.login_password_confirmation=rand_password
          @user.encrypt_password
          @user.roles.push(Role.find_by_role_name('Add Questions Only'))
          UserMailer.delay.welcome_email(@user,@user.login_password)  if @user.save
          UserMailer.welcome_email(@user,@user.login_password).deliver  if @user.save
          redirect_to success_sessions_path(:as=>"emp"), notice: 'Employee was successfully registered.'
        else
          flash.now[:error]="Invalid Employee Email id"
          render 'signup'
        end
    end
  end
end