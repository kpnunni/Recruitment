class UsersController < ApplicationController
    skip_before_filter :authenticate ,:create
    before_filter :chk_user, :except => [:profile,:chgpass ,:updatepass,:create]
  require 'will_paginate/array'

  def show
    @user= User.find(params[:id])
  end

  def index
    @users=User.filtered(params[:search],params[:filter],current_user.id).paginate(:page => params[:page], :per_page => 20)
    respond_to do |format|
      format.html
      format.json { render json: @users }
    end
  end

  def edit
    @user=User.find(params[:id])

  end

  def create
    @user=User.new(params[:user])
    if params[:emp]=="Register"
      if @user.user_email=~/\A[\w+\-.]+@suyati.com+\z/i
         @user.login_password="suyatiemp"
         @user.login_password_confirmation="suyatiemp"
         @user.encrypt_password
         @user.roles.push(Role.find_by_role_name('Interviewer'))
         UserMailer.welcome_email(@user,@user.login_password).deliver if @user.save
         redirect_to  success_sessions_path(:as=>"emp")
      else
         flash[:notice]="Invalid Employee Email id"
         render '/sessions/signup'
      end
      return
    end


      if params[:user][:role_ids].nil?
        flash[:notice]="Select atleast one role"
        render action:'new'
        return
      end

    @user.encrypt_password


    if @user.save
      UserMailer.welcome_email(@user,@user.login_password).deliver
      redirect_to users_path, notice: 'User was successfully created.'
    else
      render action: "new"
    end
  end

  def update

    @user=User.find(params[:id])
    @user.roles.delete_all
      if params[:user][:role_ids].nil?
        flash[:notice]="Select atleast one role"
        render action:'new'
        return
      end

    if @user.update_attributes(params[:user])

      @user.save
      #UserMailer.welcome_email(@user,@user.login_password).deliver
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

    respond_to do |format|
      format.html
      format.js { render js: @users }
    end
  end

  def delete
    @user=User.find(params[:id])
    if @user.isAlive?
      @user.update_attribute(:isAlive, 0)
      @user.update_attribute(:isDelete, 1)
    else
      @user.update_attribute(:isAlive, 1)
      @user.update_attribute(:isDelete, 0)
    end
    redirect_to users_path, notice: 'killed.'
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
      redirect_to chgpass_user_path(@user), :notice => "old password is not correct"
    elsif @user.update_attributes(params[:user])

      @user.encrypt_password
      @user.save

      redirect_to profile_user_path(@user), :notice => "your password updated successfully"
    else
       redirect_to chgpass_user_path(@user), :notice => "invalid new password"
    end

  end

  def chk_user
    if !current_user.has_role?('Manage Users')
      redirect_to '/homes/index'
    end
  end
end
