class RecruitmentTestsController < ApplicationController
        require 'will_paginate/array'
     before_filter :chk_user

  def index
    @recruitment_tests = RecruitmentTest.filtered(params[:search]).paginate(:page => params[:page], :per_page => 20)

    respond_to do |format|
      format.html 
      format.json { render json: @recruitment_tests }
    end
  end


  def show
    @recruitment_test = RecruitmentTest.find(params[:id])
    respond_to do |format|

      format.html 
      format.json { render json: @recruitment_test }
    end
  end


  def new
    @recruitment_test = RecruitmentTest.new

    respond_to do |format|
      format.html 
      format.json { render json: @recruitment_test }
    end
  end


  def edit
    @recruitment_test = RecruitmentTest.find(params[:id])
  end


  def create



    respond_to do |format|


      if @recruitment_test.save
        format.html { redirect_to '/homes/index', notice: 'RecruitmentTest was successfully created.' }
        format.json { render json: '/homes/index', status: :created, location: @recruitment_test }
      else
        format.html { render action: "new" }
        format.json { render json: @recruitment_test.errors, status: :unprocessable_entity }
      end
    end
  end


  def update
    @recruitment_test = RecruitmentTest.find(params[:id])

    respond_to do |format|
      if @recruitment_test.update_attributes(params[:recruitment_test])
        UserMailer.result_email(@recruitment_test.candidate.user).deliver
        format.html { redirect_to recruitment_tests_path , notice: 'RecruitmentTest was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @recruitment_test.errors, status: :unprocessable_entity }
      end
    end
  end


  def destroy
    @recruitment_test = RecruitmentTest.find(params[:id])
    @recruitment_test.destroy

    respond_to do |format|
      format.html { redirect_to recruitment_tests_url }
      format.json { head :no_content }
    end
  end
  def chk_user
    if !current_user.has_role?('admin')
       redirect_to '/homes/index'
    end

  end

end
