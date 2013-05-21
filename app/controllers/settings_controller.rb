class SettingsController < ApplicationController
  before_filter :chk_role
  def edit
     @setting=Setting.new
     @negative_mark=Setting.find_by_name('negative_mark')
     @auto_result=Setting.find_by_name('auto_result')
     @from=Setting.find_by_name('can_start_exam')
     @untill=Setting.find_by_name('canot_start_exam')
     @each_mode=Setting.find_by_name('time_limit_for_each_question')
     @categories=Category.all
     @cut_off=(0..100).to_a.select {|v| v%5==0 }
  end
  def update
    @negative_mark=Setting.find_by_name('negative_mark')
    @auto_result=Setting.find_by_name('auto_result')
    @from=Setting.find_by_name('can_start_exam')
    @untill=Setting.find_by_name('canot_start_exam')
    @each_mode=Setting.find_by_name('time_limit_for_each_question')
    if params[:negative]=="1"
       @negative_mark.update_attribute(:status,:on)
    else
       @negative_mark.update_attribute(:status,:off)
    end
    @auto_result.set_cutoff(params[:categories_attributes])
    if params[:auto_result]=="1"
      @auto_result.update_attribute(:status,:on)
    else
      @auto_result.update_attribute(:status,:off)
    end
    if params[:each_mode]=="1"
      @each_mode.update_attribute(:status,:on)
    else
      @each_mode.update_attribute(:status,:off)
    end
    @from.update_attribute(:status,params[:from].to_i)
    @untill.update_attribute(:status,params[:untill].to_i)
      redirect_to '/settings/edit' ,:notice => "Settings updated"
  end
  def chk_role
    if current_user.roles.count!=Role.count-1
       redirect_to root_path
    end
  end
end
