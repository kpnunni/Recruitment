class AnswersController < ApplicationController
  before_filter :chk_user, :except => [:congrats,:clogin,:feed_back, :check_popup  ]
  skip_before_filter :authenticate, :only => [:congrats ,:clogin,:feed_back, :check_popup  ]

  def make
    @candidate=current_user.candidate
    if @candidate.answers.empty?

      questions = @candidate.schedule.exam.questions
      ordered_questions = []
      catogry=questions.map(&:category_id).uniq
      ordered_catogry = catogry
      subjects=[]
      ordered_catogry.each{ |v| subjects<< Category.find(v).category }
      ordered_subjects = subjects
      subjects.each{ |v|
        if v =~ /group/i
          ordered_subjects.delete(v)
          ordered_subjects.unshift(v)
        end
      }

      ordered_subjects.each{ |v|
        if v =~ /group/i
          ordered_questions << questions.where(category_id: Category.find_by_category(v).id).all.sort
        else
          ordered_questions << questions.where(category_id: Category.find_by_category(v).id).all.shuffle
        end
      }
      ordered_questions.flatten!

      ordered_questions.each do |q|
        @answer=Answer.new
        @answer.question=q
        @answer.candidate=@candidate
        @answer.time_taken=0
        @answer.answer="0"
        @answer.save
      end
    end
    @anss=Answer.where("candidate_id=?",@candidate.id )
    min=@anss.first.id
    @anss.each{|v| min=v.id if v.id<min}
    @ans=Answer.find(min)
    @c_option=Array.new(@ans.question.options.count)
    redirect_to answer_path(@ans.id)

  end


  def show
    @each_mode=Setting.find_by_name('time_limit_for_each_question')
    @answer = Answer.includes([:question => [:category], :candidate => [:answers => [:question => [:category]]]]).find(params[:id])
    @candidate = @answer.candidate
    @answer.q_no=current_user.candidate.answers.where("id <= ?",@answer.id ).count
    @answer.dec_time =Time.now
    @c_option=Array.new(@answer.question.options.count)
    @tick=Array.new(@answer.question.options.count)
    @tick.each_with_index do |val,i|
      @tick[i]= @answer.answer[i]=="1"
    end
    if @each_mode.status == "on"
      @count=@answer.question.allowed_time-@answer.time_taken
      @next = next_present_answer(@answer.id)
    else
      @count = calculate_remaining_time
      @load_more = feature_enabled && answered_all_except_last && more_questions_available
      @answered_all = answered_all
      @submit = show_submit
      @next = next_answer(@answer.id)
      @back = previous_answer(@answer.id)
    end
  end

  def update
    @each_mode=Setting.find_by_name('time_limit_for_each_question')
    if @each_mode.status == "on"
      each_mode_answers
    else
      single_mode_answers
    end
  end

  def candidate_detail
    @candidate=current_user.candidate

  end
  def check_popup
    render layout: false
  end
  def candidate_update
    @candidate=Candidate.find(params[:id])
    if params[:candidate][:address]==""||params[:candidate][:phone1]==""
      flash.now[:error]="You should fill all mandatory fields"
      render '/answers/candidate_detail'
      return
    end
    if @candidate.update_attributes(params[:candidate])
      if @candidate.schedule.remote
       redirect_to instructions_answers_path
      else
       redirect_to entry_pass_answers_path
      end
    else
      render 'answers/candidate_detail' ,:notice=>"error"
    end
  end

  def entry_pass
    @candidate = current_user.candidate
  end
  def entry_pass_validation
    actual_code = Setting.find_by_name('start_code').status
    if params[:pass] == actual_code
    redirect_to instructions_answers_path
    else
      flash[:error] = "Invalid code"
      redirect_to entry_pass_answers_path
    end
  end

  def instructions
    @instructions=current_user.candidate.schedule.exam.instructions.all
    @schedule=current_user.candidate.schedule
    @exam=@schedule.exam
    @ngtv=Setting.find_by_name('negative_mark').status.eql?("on")
    @diff=(@schedule.sh_date.to_i-Time.now.to_i)/60
    @untill=Setting.find_by_name('canot_start_exam')
  end

  def chk_user
    if !my_roles.include?('Candidate')
      redirect_to '/homes/index'
    end

  end

  def congrats
    @candidate=Candidate.find(params[:id])
  end
  def blank
  end

  def clogin
    @user=User.find_by_salt(params[:id])
    @diff=(@user.candidate.schedule.sh_date.to_i-Time.now.to_i)/60
    return if @user.nil?||!@user.isAlive||@user.candidate.schedule.nil?
    sign_in(@user)
    if @diff > 30
      redirect_to '/homes/index'
    else
      redirect_to '/answers/candidate_detail'
    end
  end

  def feed_back
    @recruitment_test = RecruitmentTest.find(params[:id])
    @candidate = current_user.candidate.id
    call_rake :send_result_mail, :candidate_ids => params[:id]
    sign_out
  end


  def each_mode_answers
    @candidate=current_user.candidate
    @answer = Answer.find(params[:id])
    @answer.c_option=params[:answer][:c_option]
    @answer.time_taken=((Time.now.to_f-Time.parse(params[:answer][:dec_time]).to_f).to_i)+@answer.time_taken
    @answer.answer= @answer.set_answer

    if !@answer.update_attributes(params[:answer])
      params[:to]="finish"
    end

    if params[:to]=="timer"
      if @answer.no_more
        params[:to]="finish"
      else
        params[:to]=@answer.get_next_ans(params[:id].to_i+1)
      end
    end
    if  params[:to]=="finish"||params[:to].nil?
      @answer.save_mark(current_user)
      @answer.make_result(current_user)

      redirect_to feed_back_answer_path(@answer.candidate.recruitment_test.id)
    else
      @nxt=@answer.get_next_ans(params[:to].to_i)
      redirect_to answer_path(@nxt)
    end
  end

  def single_mode_answers
    @candidate=current_user.candidate
    @answer = Answer.find(params[:id])
    @answer.c_option=params[:answer][:c_option]
    #@answer.time_taken=((Time.now.to_f-Time.parse(params[:answer][:dec_time]).to_f).to_i)+@answer.time_taken
    @answer.time_taken += params[:time_used].to_i
    @answer.answer= @answer.set_answer

    if !@answer.update_attributes(params[:answer])
      params[:to]="finish"
    end

    if  params[:to]=="finish"||params[:to].nil?||params[:to]=="timer"
      @answer.save_mark(current_user)
      @answer.make_result(current_user)

      redirect_to feed_back_answer_path(@answer.candidate.recruitment_test.id)
    elsif params[:to] == "more"
      @nxt=get_more_question
      redirect_to answer_path(@nxt)
    else
      @nxt=@answer.get_next_ans_in_single_mode(params[:to].to_i)
      redirect_to answer_path(@nxt)
    end
  end


  def calculate_remaining_time
    total = @candidate.schedule.exam.total_time
    used = @candidate.answers.collect {|v| v.time_taken }.sum
    remaining = total - used
  end

  def answered_all_except_last
    @candidate.answers.select{|ans|ans.answer == '0'}.size <= 1 ?  true : false
  end
  def answered_all
    @candidate.answers.select{|ans|ans.answer == '0'}.size == 0 ?  true : false
  end

  def more_questions_available
    exam_question_ids = @candidate.answers.map(&:question_id)
    more_category = Category.where("category = 'Additional'").first.id
    questions = Question.where("category_id = ? and id not in (?)",more_category,exam_question_ids)
    questions.present? ? true : false
  end

  def get_more_question
    exam_question_ids = @candidate.answers.map(&:question_id)
    #exam_questions = Question.find(exam_question_ids)
    #catogry=exam_questions.map(&:category_id).uniq
    #questions = Question.where("category_id in (?)",catogry)
    more_category = Category.where("category = 'Additional'").first.id
    questions = Question.where("category_id = ? and id not in (?)",more_category,exam_question_ids)
    next_question = questions.shuffle.first
    @answer=Answer.new
    @answer.question=next_question
    @answer.candidate=@candidate
    @answer.time_taken=0
    @answer.answer="0"
    @answer.save
    @answer.id
  end

  def next_answer(current_id)
    ans = @candidate.answers.where("id > ?",current_id )
    if ans
      ans.sort.first
    else
      nil
    end
  end

  def previous_answer(current_id)
    ans = @candidate.answers.where("id < ?",current_id )
    if ans
      ans.sort.last
    else
      nil
    end
  end

  def next_present_answer(current_id)
    @candidate.answers.where("id > ?",current_id ).sort.each do |ans|
      if (ans.question.allowed_time-ans.time_taken)>3
        return ans
      end
    end
    return  nil
  end
  def feature_enabled
     Setting.find_by_name('load_more').status.eql?("on")
  end
  def show_submit
    more_q = Category.find_by_category('Additional').questions.count
    @candidate.answers.size == @candidate.schedule.exam.no_of_question + more_q
  end
end
