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

          respond_to do |format|
            format.html # index.html.erb
            format.json { render json: @candidates }
          end

  end

  def edit
      @candidate=Candidate.find(params[:id])
      @candidate.build_recruitment_test if !@candidate.schedule.nil?&&@candidate.recruitment_test.nil?
      @user=@candidate.user
      @experiences=@candidate.experiences.all
      @qualifications=@candidate.qualifications.all
  end

  def create
      @candidate=Candidate.new(params[:candidate])
      @candidate.user.login_password="12345"
      @candidate.user.login_password_confirmation="12345"
      @candidate.user.encrypt_password
    if params[:can]=="Register"
      if @candidate.save
         redirect_to  success_sessions_path(:as=>"can")
      else
         2.times{@candidate.experiences.build }
         2.times{@candidate.qualifications.build }
         render  '/sessions/signup'
      end
      return
    end
      if @candidate.save
     #   UserMailer.welcome_email(@candidate.user,@candidate.user.login_password).deliver
        redirect_to candidate_path(@candidate)
      else
         2.times{@candidate.experiences.build }
         2.times{@candidate.qualifications.build }
         render action: "new"
      end
  end

  def update
    @candidate=Candidate.find(params[:id])

      if params[:from]=="update"
              if params[:candidate][:address]==""||params[:candidate][:phone1]==""||params[:candidate][:technology]==""||params[:candidate][:certification]==""||params[:candidate][:skills]==""
                 2.times{@candidate.experiences.build }   if @candidate.experiences.count==0
                 2.times{@candidate.qualifications.build }  if @candidate.qualifications.count==0
                 flash[:notice]="You should fill all mandatory fields"
                 render  '/answers/candidate_detail'
              return
              end
              if @candidate.update_attributes(params[:candidate])
                 if @candidate.update_attributes(params[:candidate])
                 redirect_to  '/answers/instructions'
                 end
              else
                 2.times{@candidate.experiences.build }   if @candidate.experiences.count==0
                 2.times{@candidate.qualifications.build }  if @candidate.qualifications.count==0
                render  '/answers/candidate_detail'
              end
      else
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
  end

  def destroy
    @candidate=Candidate.find(params[:id])
    @candidate.user.delete
    @candidate.destroy
    redirect_to candidates_path  , notice: 'deleted.'
  end

  def new
      @candidate=Candidate.new
      2.times{@candidate.experiences.build }
      2.times{@candidate.qualifications.build }
      @candidate.build_user
      respond_to do |format|
        format.html # new.html.erb
        format.xml { render :xml => @candidate  }
      end

  end


end
