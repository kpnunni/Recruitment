class CandidatesController < ApplicationController
  require 'will_paginate/array'
  skip_before_filter :authenticate ,:create
  before_filter :chk_user ,:except =>[ :update ,:create]
  def chk_user
    if !current_user.has_role?('Manage Candidates')
      redirect_to '/homes/index'
    end
  end


  def show
    @candidate=Candidate.find(params[:id])
  end

  def index
    @candidates=Candidate.filtered(params[:search]).paginate(:page => params[:page], :per_page => 20)
    @exam=Exam.all
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @candidates }
    end

  end

  def edit
    @candidate=Candidate.find(params[:id])
    @candidate.build_recruitment_test if !@candidate.schedule.nil?&&@candidate.recruitment_test.nil?
    @user=@candidate.user
  #  @experiences=@candidate.experiences.all
  #  @qualifications=@candidate.qualifications.all
  end

  def create
    @candidate=Candidate.new(params[:candidate])
    @candidate.user.login_password="12345"
    @candidate.user.login_password_confirmation="12345"
    @candidate.user.encrypt_password

    if @candidate.save
      # UserMailer.welcome_email(@candidate.user,@candidate.user.login_password).deliver
      redirect_to candidates_path , notice: 'Candidate was successfully created.'
    else

      render "new"
    end
  end

  def update
    @candidate=Candidate.find(params[:id])
      if @candidate.update_attributes(params[:candidate])
        if params[:candidate][:done]=="1"

        end
        redirect_to candidates_path , notice: 'Candidate was successfully updated.'
      else
        @user=@candidate.user
        @experiences=@candidate.experiences.all
        @qualifications=@candidate.qualifications.all
        render action: "edit"
      end
  end

  def destroy
    @candidate=Candidate.find(params[:id])
    @candidate.user.delete
    @candidate.destroy
    redirect_to candidates_path , notice: 'Candidate was successfully deleted.'
  end

  def new
    @candidate=Candidate.new
   # 2.times{@candidate.experiences.build }
   # 2.times{@candidate.qualifications.build }
    @candidate.build_user
    respond_to do |format|
      format.html # new.html.erb
      format.xml { render :xml => @candidate }
    end

  end
  def schedule_create
    @candidate=Candidate.find(params[:schedule][:candidate_ids].keys.first.to_i)
    @exam=Exam.all
#    if params[:schedule]["sh_date(1i)"].empty?||params[:schedule]["sh_date(2i)"].empty?||params[:schedule]["sh_date(3i)"].empty?||params[:schedule]["sh_date(4i)"].empty?||params[:schedule]["sh_date(5i)"].empty?
#       flash[:error]='Invalid date and time.'
#       redirect_to candidates_path
#       return
#    end
#    @date=Time.parse(params[:schedule]["sh_date(1i)"]+"-"+params[:schedule]["sh_date(2i)"]+"-"+params[:schedule]["sh_date(3i)"]+" "+params[:schedule]["sh_date(4i)"]+":"+params[:schedule]["sh_date(5i)"])
#    if @date < Time.now
#       flash[:error]='Date and time should be greater than current date and time.'
#       redirect_to candidates_path
#       return
#    end

    #Schedule
    if @candidate.schedule.nil?
       @schedule = Schedule.new(params[:schedule])
       @schedule.created_by=current_user.user_email
       if @schedule.save
         UserMailer.delay.schedule_email(@candidate.user)
         @users=User.all.select {|usr| usr.roles.include?(Role.find_by_role_name("Get Schedule Email"))}
         @users.each {|admin| UserMailer.delay.admin_schedule_email(admin,@schedule)  }
         flash[:notice]='Exam was successfully scheduled.'
       else
         flash[:error]='Error on scheduling.'
       end
    #Reschedule
    else
       @schedule = @candidate.schedule
       @schedule.updated_by=current_user.user_email
       if  @schedule.update_attributes(params[:schedule])
         UserMailer.delay.update_schedule_email(@candidate.user)
         @users=User.all.select {|usr| usr.roles.include?(Role.find_by_role_name("Get Schedule Email"))}
         @users.each {|admin| UserMailer.delay.admin_update_schedule_email(admin,@schedule)  }
         flash[:notice]='Exam was successfully re-scheduled.'
       else
         flash[:error]='Error on re-scheduling.'
       end
    end
      redirect_to candidates_path
  end

end