class AnswersController < ApplicationController
  before_filter :chk_user
  skip_before_filter :authenticate, :only => :congrats
  skip_before_filter :chk_user , :only => :congrats
  def show
       @answer = Answer.new
       @answer.question=Question.find(params[:id])
       @total_question=current_user.candidate.schedule.exam.questions.count
       @answer.dec_time = @answer.question.allowed_time
       @answer.q_no=current_user.candidate.answers.count+1
  end

  def new
    @answer = Answer.new
    @answer.question=@answer.get_next_question(current_user.candidate)

    redirect_to answer_path(@answer.question)
  end


  def create


    @answer = Answer.new(params[:answer])
    @answer.candidate=current_user.candidate
    @answer.answer= @answer.get_answer
    if !@answer.save
       params[:to]="finish"
    end
    if params[:to]=="timer" && current_user.candidate.answers.count==current_user.candidate.schedule.exam.questions.count
       params[:to]="finish"
    end
    if  params[:to]=="finish"
      @answer.save_mark(current_user)
      sign_out
      redirect_to '/answers/congrats'
    else
      redirect_to new_answer_path(:q_id=>params[:q_id])
    end

  end







  def candidate_detail
      @candidate=current_user.candidate

  end
  def candidate_update
      @candidate=Candidate.find(:id)
      if @candidate.update_attributes(params[:candidate])
          redirect_to instructions_answer_path
      else
        render 'answers/candidate_detail'
      end

  end

  def instructions
      @instructions=current_user.candidate.schedule.exam.instructions.all
      @schedule=current_user.candidate.schedule
      @exam=@schedule.exam
      @date= DateTime.new(@schedule.sh_date.year, @schedule.sh_date.month, @schedule.sh_date.day,@schedule.sh_time.hour-6, @schedule.sh_time.min-30, @schedule.sh_time.sec)
      @diff=(Time.now.to_i-@date.to_i)/60
  end

  def chk_user
    if !current_user.has_role?('candidate')
       redirect_to '/homes/index'
    end

  end

  def congrats
  end

  def blank
  end
end
