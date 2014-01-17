class SettingsController < ApplicationController
  before_filter :chk_role
  def edit
     @setting = Setting.new
     @settings = Setting.all
     @load_more = get_status('load_more')
     @negative_mark = get_status('negative_mark')
     @auto_result = get_status('auto_result')
     @from = get_status('can_start_exam')
     @untill = get_status('canot_start_exam')
     @each_mode = get_status('time_limit_for_each_question')
     @categories =Category.all
     @cut_off = (0..100).to_a.select {|v| v%5==0 }
  end
  def update
    @load_more=Setting.find_by_name('load_more')
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
    if params[:load_more]=="1"
      @load_more.update_attribute(:status,:on)
    else
      @load_more.update_attribute(:status,:off)
    end
    if params[:each_mode]=="1" && @each_mode.status == "off"
      @each_mode.update_attribute(:status,:on)
      increase_total_time
    elsif params[:each_mode].nil? && @each_mode.status == "on"
      @each_mode.update_attribute(:status,:off)
      reduce_total_time
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
  def reduce_total_time
    Exam.all.each do |exam|
      current_time = exam.total_time
      new_time = current_time * 0.88
      exam.update_attribute(:total_time, new_time)
    end
  end

  def increase_total_time
    Exam.all.each do |exam|
      new_time = exam.questions.collect {|v| v.allowed_time}.sum
      exam.update_attribute(:total_time, new_time)
    end
  end
  def get_status(name)
    @settings.select { |s| s.name == name }.map(&:status).join
  end
end
