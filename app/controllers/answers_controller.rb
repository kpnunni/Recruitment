class AnswersController < ApplicationController
  before_filter :chk_user, :except => [:congrats,:clogin,:feed_back, :check_popup  ]
  skip_before_filter :authenticate, :only => [:congrats ,:clogin,:feed_back, :check_popup  ]

  def make
    @candidate=current_user.candidate
    if @candidate.answers.empty?

      #questions = @candidate.schedule.exam.questions
      #ordered_questions = []
      #catogry=questions.map(&:category_id).uniq
      #ordered_catogry = catogry
      #subjects=[]
      #ordered_catogry.each{ |v| subjects<< Category.find(v).category }
      #ordered_subjects = subjects
      #subjects.each{ |v|
      #  if v =~ /group/i
      #    ordered_subjects.delete(v)
      #    ordered_subjects.unshift(v)
      #  end
      #}
      #
      #ordered_subjects.each{ |v|
      #  if v =~ /group/i
      #    ordered_questions << questions.where(category_id: Category.find_by_category(v).id).all.sort
      #  else
      #    ordered_questions << questions.where(category_id: Category.find_by_category(v).id).all.shuffle
      #  end
      #}
      #ordered_questions.flatten!

      @candidate.schedule.exam.questions.order(:category_id, :id).each do |q|
        Answer.create({candidate_id: @candidate.id, question_id: q.id, time_taken: 0, answer: "0"})
        #@answer.question=q
        #@answer.candidate=@candidate
        #@answer.time_taken=0
        #@answer.answer="0"
        #@answer.save
      end
    end
    if Setting.find_by_name('js_mode').status.eql?("on")
      salt= current_user.salt
      if @candidate.submitted
         redirect_to additional_answers_path(candidate_id: salt)
      else
         redirect_to answers_path(candidate_id: salt)
      end
    else
      @answers = Answer.where("candidate_id=?",@candidate.id )
      if @candidate.submitted
        min = @answers.sort.last.id
      else
        min = @answers.map(&:id).min
      end
      @ans=Answer.find(min)
      redirect_to answer_path(@ans)
    end

  end

  def index
    if params[:candidate_id] == current_user.salt
      @exam = current_user.candidate.schedule.exam
      @questions = @exam.questions.includes(:type, :options, :category).order(:category_id, :id)
      @used = current_user.candidate.answers.map(&:time_taken).sum
      @time = @exam.total_time - @used
    else
      render text: "Error"
    end
  end
  def additional
    if params[:candidate_id] == current_user.salt
      @questions = Question.includes(:type, :options, :category).additional
      @used = current_user.candidate.answers.where(question_id: @questions.map(&:id)).collect.map(&:time_taken).sum
      @time = @questions.map(&:allowed_time).sum - @used
   else
      render text: "Error"
    end
  end
  def show
    #@each_mode=Setting.find_by_name('time_limit_for_each_question')
    @answer = Answer.includes([:question => [:category], :candidate => [:answers => [:question => [:category]]]]).find(params[:id])
    @candidate = @answer.candidate
    #@answer.dec_time =Time.now
    #@c_option=Array.new(@answer.question.options.count)
    #@tick=Array.new(@answer.question.options.count)
    #@tick.each_with_index do |val,i|
    #  @tick[i]= @answer.answer[i]=="1"
    #end
    #if @each_mode.status == "on"
    #  @count=@answer.question.allowed_time-@answer.time_taken
    #  @next = next_present_answer(@answer.id)
    #else
      #@load_more = feature_enabled && answered_all_except_last && more_questions_available
      #@answered_all = answered_all
      #@submit = show_submit
      if @candidate.submitted
        @additional = Question.additional
        @id_s = @additional.map(&:id)
        @answers = @candidate.answers.select {|ans| @id_s.include?(ans.question_id)}
        @answer.q_no = @answers.select{|ans| ans.id <= @answer.id }.size
        @count = calculate_additional_remaining_time
        @next = next_additional_answer(@answer.id)
        @back = previous_additional_answer(@answer.id)
      else
        @answer.q_no = @candidate.answers.where("id <= ?",@answer.id ).count
        @answers = @candidate.answers
        @count = calculate_remaining_time
        @next = next_answer(@answer.id)
        @back = previous_answer(@answer.id)
      end
    #end
  end

  def create
    respond_to do |format|
      format.html{ single_mode_answers }
      format.json { single_mode_answers_with_js }
    end
  end
  def update
    #@each_mode=Setting.find_by_name('time_limit_for_each_question')
    #if @each_mode.status == "on"
    #  each_mode_answers
    #else
      single_mode_answers
    #end
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
    @instructions=current_user.candidate.schedule.exam.instructions
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
    @recruitment_test = current_user.candidate.recruitment_test
    @candidate = current_user.candidate.id
    call_rake :send_result_mail, :candidate_ids => @recruitment_test.id
    @user=User.find(current_user.id)
    @user.update_attribute(:isAlive,0)
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

      redirect_to feed_back_answers_path
    else
      @nxt=@answer.get_next_ans(params[:to].to_i)
      redirect_to answer_path(@nxt)
    end
  end

  def single_mode_answers
    @candidate=current_user.candidate
    @answer = Answer.find(params[:id])
    @answer.c_option= params[:answer] ? params[:answer][:c_option] : nil
    #@answer.time_taken=((Time.now.to_f-Time.parse(params[:answer][:dec_time]).to_f).to_i)+@answer.time_taken
    time_used = params[:time_used].to_i > 200 ? 200 : params[:time_used].to_i #handling low bandwidth request
    @answer.time_taken += time_used
    @answer.answer= @answer.set_answer

    if !@answer.update_attributes(params[:answer])
      params[:to]="finish"
    end

    if  params[:to]=="finish"||params[:to].nil?||params[:to]=="timer"
      if @candidate.submitted
        redirect_to feed_back_answers_path
      else
        start_additional_question
        redirect_to answer_path(@nxt)
      end
    else
      #@nxt=@answer.get_next_ans_in_single_mode(params[:to].to_i)
      redirect_to answer_path(params[:to].to_i)
    end
  end

  def single_mode_answers_with_js
    @candidate = current_user.candidate
    @answer = @candidate.answers.where(question_id: params[:question_id]).first
    @answer.answer = params[:option_id]
    @answer.time_taken += params[:time_used].to_i
    @answer.save
    if params[:finish] == "1"
      start_additional_question
    end
    render :json => { :success => "success", :status_code => "200" }
  end

  def start_additional_question
    @answer.save_mark(current_user)
    @answer.make_result(current_user)
    @candidate.update_attribute(:submitted, true)
    @nxt = add_additional_answers
  end

  def calculate_remaining_time
    total = @candidate.schedule.exam.total_time
    used = @candidate.answers.collect {|v| v.time_taken }.sum
    remaining = total - used
  end

  def calculate_additional_remaining_time
    total = @additional.map(&:allowed_time).sum
    used = @candidate.answers.where(question_id: @id_s).collect {|v| v.time_taken }.sum
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

  def next_additional_answer(current_id)
    ans = @answers.select{|ans| ans.id > current_id }
    if ans
      ans.sort.first
    else
      nil
    end
  end

  def previous_additional_answer(current_id)
    ans = @answers.select{|ans| ans.id < current_id }
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
    more_q = Question.additional.count
    @candidate.answers.select{|ans| ans.answer != "0"}.size >= @candidate.schedule.exam.no_of_question + more_q  - 1
  end

  def add_additional_answers
    @additional = Question.additional
    @additional.shuffle.each do |q|
      Answer.create(question_id: q.id, candidate_id: @candidate.id,time_taken: 0, answer: "0")
    end
    next_ans = @candidate.answers.where(question_id: @additional.map(&:id)).sort.first
  end


end
