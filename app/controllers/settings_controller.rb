class SettingsController < ApplicationController
  before_filter :chk_role
  def show
     @setting=Setting.first
     @categories=Category.all
  end
  def edit
     @setting=Setting.first
     @categories=Category.all

     @cut_off=(0..100).to_a.select {|v| v%5==0 }
  end
  def update
      @setting=Setting.find(params[:id])
      @setting.set_cutoff(params[:categories_attributes])
      @setting.update_attributes(params[:setting])
      redirect_to @setting
  end
  def chk_role
    if current_user.roles.count!=Role.count-1
       redirect_to root_path
    end
  end
end
