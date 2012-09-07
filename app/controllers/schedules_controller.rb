class SchedulesController < ApplicationController
   require 'will_paginate/array'
   before_filter :chk_user
  def index
    @schedules = Schedule.where("sh_date >= ?",Date.today).paginate(:page => params[:page], :per_page => 20)

    respond_to do |format|
      format.html 
      format.json { render json: @schedules }
    end
  end


  def show
    @schedule = Schedule.find(params[:id])

    respond_to do |format|

      format.html 
      format.json { render json: @schedule }
    end
  end


  def new
    @exam=Exam.all
    @schedule = Schedule.new
    @candidates=Candidate.all
     @candidates.delete_if {|c| !c.user.isAlive || !c.schedule_id.nil?  }
    respond_to do |format|
      format.html 
      format.json { render json: @schedule }
    end
  end


  def edit
    @exam=Exam.all
    @schedule = Schedule. find(params[:id])
    @candidates=Candidate.all
    @candidates.select!  {|c| @schedule.candidates.include?(c) || c.schedule_id.nil?  }
    @schedule.sh_time=@schedule.sh_time.strftime("%I:%M")
  end


  def create
    @schedule = Schedule.new(params[:schedule])
    @exam=Exam.all
    @candidates=Candidate.all
    @candidates.delete_if {|c| !c.user.isAlive || !c.schedule_id.nil?  }
    respond_to do |format|
      if @schedule.save
        @schedule.candidates.each{|c| UserMailer.schedule_email(c.user).deliver }
        @users=User.all.select {|usr| usr.roles.include?(Role.find_by_role_name("admin"))}
        @users.each {|admin| UserMailer.admin_schedule_email(admin,@schedule).deliver }
        format.html { redirect_to schedules_path, notice: 'Schedule was successfully created.' }
        format.json { render json: @schedule, status: :created, location: @schedule }
      else
        format.html { render action: "new" }
        format.json { render json: @schedule.errors, status: :unprocessable_entity }
      end
    end
  end


  def update
    @schedule = Schedule.find(params[:id])

    respond_to do |format|
      if @schedule.update_attributes(params[:schedule])
        format.html { redirect_to @schedule, notice: 'Schedule was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @schedule.errors, status: :unprocessable_entity }
      end
    end
  end


  def destroy
    @schedule = Schedule.find(params[:id])
    @schedule.destroy

    respond_to do |format|
      format.html { redirect_to schedules_url }
      format.json { head :no_content }
    end
  end

  def remove
      @schedule=Schedule.find(params[:id])
      @candidate=Candidate.find(params[:candidate_id])
      @schedule.candidates.delete(@candidate)
      @schedule.destroy if @schedule.candidates.empty?
      redirect_to schedule_path(@schedule) if !@schedule.candidates.empty?
      redirect_to schedules_path if @schedule.candidates.empty?
  end

  def chk_user
    if !current_user.has_role?('admin')
       redirect_to '/homes/index'
    end

  end
end
