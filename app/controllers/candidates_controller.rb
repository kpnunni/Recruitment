class CandidatesController < ApplicationController
   require 'will_paginate/array'
   before_filter :chk_user ,:except => :update
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

  end

  def create
      @candidate=Candidate.new(params[:candidate])
      @candidate.user.encrypt_password

      if @candidate.save
     #   UserMailer.welcome_email(@candidate.user,@candidate.user.login_password).deliver
        redirect_to candidate_path(@candidate)
      else
         render action: "new"
      end
  end

  def update
    @candidate=Candidate.find(params[:id])

      if params[:from]=="update"
              if @candidate.update_attributes(params[:candidate])
                 if @candidate.update_attributes(params[:candidate])
                 redirect_to  '/answers/instructions'
                 end
              else
                render  '/answers/candidate_detail'
              end
      else
                 if @candidate.update_attributes(params[:candidate])
                   redirect_to @candidate, notice: 'Candidate was successfully updated.'
                 else
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
      @candidate.build_user
      respond_to do |format|
        format.html # new.html.erb
        format.xml { render :xml => @candidate  }
      end

  end


end
