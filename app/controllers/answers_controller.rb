class AnswersController < ApplicationController
  before_filter :chk_user, :except => [:congrats,:clogin,:feed_back  ]
  skip_before_filter :authenticate, :only => [:congrats ,:clogin,:feed_back  ]

  def make
     @candidate=current_user.candidate
     if @candidate.answers.empty?
        @candidate.schedule.exam.questions.shuffle.each do |q|
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
     @candidate=current_user.candidate
     @answer = Answer.find(params[:id])
     @answer.q_no=current_user.candidate.answers.where("id <= ?",@answer.id ).count
     @answer.dec_time =Time.now
     @count=@answer.question.allowed_time-@answer.time_taken
     @c_option=Array.new(@answer.question.options.count)
     @tick=Array.new(@answer.question.options.count)
     @tick.each_with_index do |val,i|
        @tick[i]= @answer.answer[i]=="1"
     end
  end

  def update
    @candidate=current_user.candidate
    @answer = Answer.find(params[:id])
    @answer.c_option=params[:answer][:c_option]
    @answer.time_taken=((Time.now.to_f-Time.parse(params[:answer][:dec_time]).to_f).to_i)+@answer.time_taken
    @answer.answer= @answer.get_answer

    if !@answer.update_attributes(params[:answer])
       params[:to]="finish"
    end

    if params[:to]=="timer"
      if @answer.no_more
       params[:to]="finish"
      else
       params[:to]=@answer.get_ans
      end
    end
    if  params[:to]=="finish"
      @answer.save_mark(current_user)
      @users=User.all.select {|usr| usr.has_role?("Validate Result")||usr.has_role?("View Result")}
      @users.each {|admin| UserMailer.exam_complete_email(admin,current_user.candidate).deliver }
      redirect_to feed_back_answer_path(@answer.candidate.recruitment_test.id)
    else
      @nxt=params[:to].to_i
      redirect_to answer_path(@nxt)
    end

  end

  def candidate_detail
      @candidate=current_user.candidate
      2.times{@candidate.experiences.build }    if @candidate.experiences.count==0
      2.times{@candidate.qualifications.build }  if @candidate.qualifications.count==0

  end
  def candidate_update
      @candidate=Candidate.find(:id)
      if @candidate.update_attributes(params[:candidate])
          redirect_to instructions_answer_path
      else
        2.times{@candidate.experiences.build }   if @candidate.experiences.first.id.present?
        2.times{@candidate.qualifications.build }  if @candidate.qualifications.count==0
        render 'answers/candidate_detail'
      end
  end

  def instructions
      @instructions=current_user.candidate.schedule.exam.instructions.all
      @schedule=current_user.candidate.schedule
      @exam=@schedule.exam
      @diff=(Time.now.to_i-@schedule.sh_date.to_i)/60
  end

  def chk_user
    if !current_user.has_role?('Candidate')
       redirect_to '/homes/index'
    end

  end

  def congrats
     @user=User.find(params[:id])

  end

  def blank
  end

  def clogin
     @user=User.find(params[:id])
     return if !@user.isAlive||@user.candidate.schedule.nil?
     sign_in(@user)
     redirect_to '/answers/candidate_detail'
  end

  def feed_back
      @recruitment_test = RecruitmentTest.find(params[:id])
  end

end
