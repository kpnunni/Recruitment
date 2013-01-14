class RecruitmentTestsController < ApplicationController
      before_filter :chk_user , :except=> [:update ]
     before_filter :chk_result, :only=> :show
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


  def update
    @recruitment_test = RecruitmentTest.find(params[:id])

    respond_to do |format|
      if @recruitment_test.update_attributes(params[:recruitment_test])
        if @recruitment_test.is_passed=="Passed"
          UserMailer.delay.result_email(@recruitment_test.candidate.user)
          UserMailer.result_email(@recruitment_test.candidate.user).deliver
          @users=User.all.select {|usr| usr.roles.include?(Role.find_by_role_name("Get Selection Email"))}
          @users.each {|admin| UserMailer.delay.admin_result_email(admin,@recruitment_test.candidate)  }
          @users.each {|admin| UserMailer.admin_result_email(admin,@recruitment_test.candidate).deliver  }
        end
        if params[:from]=="my_feedback"
           redirect_to congrats_answer_path(current_user.id)
           return
        end
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
    if !(current_user.has_role?('Validate Result')||current_user.has_role?('View Result'))
       redirect_to '/homes/index'
    end

  end
  def chk_result
    if !current_user.has_role?('Validate Result')
       redirect_to '/homes/index'
    end
  end




end
