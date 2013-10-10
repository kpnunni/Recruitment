class UsersController < ApplicationController
  #skip_before_filter :authenticate ,:create
  before_filter :chk_user, :except => [:profile,:chgpass ,:updatepass,:create]
  def show
    @user= User.find(params[:id])
  end
  def index
    @search = User.includes(:roles,:candidate).search(params[:q])
    @users = @search.result.delete_if {|user| user == current_user }.sort.paginate(page: params[:page], per_page: 15)
    #@users = @search.result.delete_if {|user| user.has_role?("Candidate") || user == current_user }.paginate(page: params[:page], per_page: 15)
    @search.build_condition
  end
  def edit
    @user=User.find(params[:id])
  end
  def create
    @user=User.new(params[:user])
    @user.encrypt_password
    if @user.save
      #UserMailer.delay.welcome_email(@user,@user.login_password)
      call_rake :send_welcome_mail, :mailing_id =>  @user.id , pass: @user.login_password
      #UserMailer.welcome_email(@user,@user.login_password).deliver
      redirect_to users_path, notice: 'User was successfully created.'
    else
      render action: "new"
    end
  end
  def update
    @user=User.find(params[:id])
    @user.roles.delete_all
    if @user.update_attributes(params[:user])
      @user.save
      redirect_to users_path, notice: 'User was successfully updated.'
    else
      render action: "edit"
    end
  end
  def destroy
    @user=User.find(params[:id])
    @user.destroy
    redirect_to users_path, notice: 'deleted.'
  end
  def new
    @user=User.new
  end
  def delete
    @user=User.find(params[:id])
    if @user.isAlive?
      @user.isAlive= false
      @user.isDelete= true
      @user.save
      flash[:notice]="User '#{@user.user_email}' is now Inactive"
    else
      @user.isAlive=  true
      @user.isDelete=  false
      @user.save
      flash[:notice]="User '#{@user.user_email}' is now Active"
    end
    if params[:from] == "candidate"
      redirect_to candidates_path, notice: "Activation changed for candidate '#{@user.candidate.name}'"
    else
      redirect_to users_path
    end
  end
  def profile
    @user=User.find(params[:id])
  end
  def chgpass
    @user=User.find(params[:id])
  end
  def updatepass
    @user=User.find(params[:id])
    @old_password=Digest::SHA2.hexdigest("#{@user.salt}--#{params[:old_password]}")

    if @old_password!=@user.password
      flash[:error]= "old password is not correct"
      redirect_to chgpass_user_path(@user)
      return
    end
    if params[:user][:login_password].length<4
      flash[:error]="Invalid new password"
      redirect_to chgpass_user_path(@user)
      return
    end
    if params[:user][:login_password]!=params[:user][:login_password_confirmation]
      flash[:error]="Password doesn't match confirmation."
      redirect_to chgpass_user_path(@user)
      return
    end
    if @user.update_attributes(params[:user])

      @user.encrypt_password
      @user.save
      redirect_to profile_user_path(@user), :notice => "your password updated successfully"
    else
      flash[:error]="invalid new password"
      redirect_to chgpass_user_path(@user)
    end
  end
  def chk_user
    if !my_roles.include?('Manage Users')
      flash.now[:warning]='Unauthorised Access'
      redirect_to '/homes/index'
    end
  end
end