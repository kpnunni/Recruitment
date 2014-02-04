class RecruitmentTestsController < ApplicationController
  include RecruitmentTestsHelper
  before_filter :chk_user , :except=> [:update ]
  before_filter :chk_result, :only=> :show
  skip_before_filter :authenticate,:only => :update
  helper_method :sort_column, :sort_direction
  def index
    @recruitment_tests = RecruitmentTest.filtered(params[:search],sort_column + " " + sort_direction).paginate(:page => params[:page], :per_page =>params[:per_page] || 20)
    @categories = Category.all
    @additional = Category.where("category = 'Additional'").first.questions.size
  end
  def show
    @recruitment_test = RecruitmentTest.includes(:candidate => [ :answers =>[:question=>[:options,:complexity, :category]] , :schedule => [:exam => [:questions=>[:complexity, :category]]] ] ).find(params[:id])
    @extra = find_extra(@recruitment_test)
    @additional = Category.where("category = 'Additional'").first.questions.size
    @categories = Category.all
  end
  def update
    @recruitment_test = RecruitmentTest.find(params[:id])
    if @recruitment_test.update_attributes(params[:recruitment_test])
      if params[:from]=="my_feedback"
        redirect_to congrats_answer_path(params[:recruitment_test][:candidate_id].to_i)
        return
      end
      redirect_to recruitment_tests_path , notice: 'RecruitmentTest was successfully updated.'
      head :no_content
    else
      render action: "edit"
      render json: @recruitment_test.errors, status: :unprocessable_entity
    end
  end
  def feedback
     @results = RecruitmentTest.where("feedback <> ''").reverse.group_by {|result| result.created_at.beginning_of_day}
   end
  def destroy
    @recruitment_test = RecruitmentTest.find(params[:id])
    @recruitment_test.destroy
    redirect_to recruitment_tests_url
  end
  def sent_mail
    if  params[:email]
      ids = params[:email][:sent_ids].map(&:to_i)
      call_rake :send_selected_result_mail, :candidate_ids => ids.join(",")
      redirect_to recruitment_tests_path , notice: 'details sent to emails.'
    else
      flash[:error]= 'Select results to sent.'
      redirect_to recruitment_tests_path
    end
  end
  def clear_answers
    @recruitment_test = RecruitmentTest.find(params[:id])
    @recruitment_test.candidate.answers.destroy_all
    redirect_to recruitment_tests_path, notice: "Answers cleared for #{@recruitment_test.candidate.name}"
  end
  def pass_or_fail
    @recruitment_test = RecruitmentTest.find(params[:id])
    if params[:status]
      @recruitment_test.update_attribute(:is_passed, params[:status])
    end
    respond_to do |format|
      format.html { redirect_to recruitment_tests_url }
      format.js { render :nothing }
    end
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
  #def find_extra(recruitment_test)
  #  @candidate = recruitment_test.candidate
  #  questions = @candidate.schedule.exam.question_ids
  #  @answers =  @candidate.answers.where("question_id in (?)",questions)
  #  @extra_answers = @candidate.answers.where("question_id not in (?)",questions)
  #end
end
