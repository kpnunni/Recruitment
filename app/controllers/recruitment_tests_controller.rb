class RecruitmentTestsController < ApplicationController
      before_filter :chk_user , :except=> [:update ]
     before_filter :chk_result, :only=> :show
      skip_before_filter :authenticate,:only => :update
  helper_method :sort_column, :sort_direction , :find_extra
  def index
    @recruitment_tests = RecruitmentTest.filtered(params[:search],sort_column + " " + sort_direction).paginate(:page => params[:page], :per_page => 20)
    respond_to do |format|
      format.html 
      format.json { render json: @recruitment_tests }
    end
  end


  def show
    @recruitment_test = RecruitmentTest.find(params[:id])
    @extra = find_extra(@recruitment_test)
    respond_to do |format|

      format.html 
      format.json { render json: @recruitment_test }
    end
  end


  def update
    @recruitment_test = RecruitmentTest.find(params[:id])

    respond_to do |format|
      if @recruitment_test.update_attributes(params[:recruitment_test])
        #if @recruitment_test.is_passed=="Passed"
          #UserMailer.delay.result_email(@recruitment_test.candidate.user)
          #UserMailer.result_email(@recruitment_test.candidate.user).deliver
          #@users=User.all.select {|usr| usr.roles.include?(Role.find_by_role_name("Get Selection Email"))}
          #@users.each {|admin| UserMailer.delay.admin_result_email(admin,@recruitment_test.candidate)  }
          #@users.each {|admin| UserMailer.admin_result_email(admin,@recruitment_test.candidate).deliver  }
        #end
        if params[:from]=="my_feedback"
           redirect_to congrats_answer_path(params[:recruitment_test][:candidate_id].to_i)
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
  def sent_mail
    if  params[:email]
        ids = params[:email][:sent_ids].map(&:to_i)
       @results = RecruitmentTest.where("id in (?)", ids ).all
       @users=User.joins(:roles).where( roles: { role_name: "Get Selection Email"})
       @users.each {|admin| UserMailer.admin_result_email(admin,@results).deliver  }
       redirect_to recruitment_tests_path , notice: 'details sent to emails.'
    else
        flash[:error]= 'Select results to sent.'
        redirect_to recruitment_tests_path
    end
    #render text: @results
  end
  def chk_user
    if !(my_roles.include?('Validate Result')||my_roles.include?('View Result'))
       redirect_to '/homes/index'
    end

  end
  def chk_result
    if !my_roles.include?('Validate Result')
       redirect_to '/homes/index'
    end
  end

private
  def sort_column
    sort = params[:sort]
    if sort == "right_answers"
      "right_answers"
    elsif sort == "mark_percentage"
      "mark_percentage"
    else
      "created_at"
    end

  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
  end
  def find_extra(recruitment_test)
    @candidate = recruitment_test.candidate
    questions = @candidate.schedule.exam.question_ids
    @answers =  @candidate.answers.where("question_id in (?)",questions)
    @extra_answers = @candidate.answers.where("question_id not in (?)",questions)
  end

end
