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
    @answer.answer= @answer.set_answer

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
    if  params[:to]=="finish"||params[:to].nil?
      @answer.save_mark(current_user)
      @answer.make_result(current_user)

      redirect_to feed_back_answer_path(@answer.candidate.recruitment_test.id)
    else
      @nxt=params[:to].to_i
      redirect_to answer_path(@nxt)
    end

  end

  def candidate_detail
      @candidate=current_user.candidate

  end
  def candidate_update
      @candidate=Candidate.find(params[:id])
      if params[:candidate][:address]==""||params[:candidate][:phone1]==""||params[:candidate][:technology]==""||params[:candidate][:certification]==""||params[:candidate][:skills]==""
        flash.now[:error]="You should fill all mandatory fields"
        render '/answers/candidate_detail'
        return
      end
      if @candidate.update_attributes(params[:candidate])
          redirect_to instructions_answers_path
      else
        render 'answers/candidate_detail' ,:notice=>"error"
      end
  end

  def instructions
      @instructions=current_user.candidate.schedule.exam.instructions.all
      @schedule=current_user.candidate.schedule
      @exam=@schedule.exam
      @ngtv=Setting.find_by_name('negative_mark').status.eql?("on")
      @diff=(@schedule.sh_date.to_i-Time.now.to_i)/60
  end

  def chk_user
    if !my_roles.include?('Candidate')
       redirect_to '/homes/index'
    end

  end

  def congrats
     @candidate=User.find(params[:id]).candidate
     #if @candidate.recruitment_test.is_passed=="Passed"
       #UserMailer.result_email(@candidate.user).deliver
       #  UserMailer.delay.result_email(@candidate.user)
       #@users=User.all.select {|usr| usr.roles.include?(Role.find_by_role_name("Get Selection Email"))}
       #@users.each {|admin| UserMailer.admin_result_email(admin,@candidate).deliver  }
       #    @users.each {|admin| UserMailer.delay.admin_result_email(admin,@candidate)  }
     #else
       #@users=User.all.select {|usr| usr.has_role?("Validate Result")||usr.has_role?("View Result")}
       #@users.each {|admin| UserMailer.exam_complete_email(admin,current_user.candidate).deliver }
       #    @users.each {|admin| UserMailer.delay.exam_complete_email(admin,current_user.candidate) }
     #end

     sign_out
  end
  def blank
  end

  def clogin
     @user=User.find_by_salt(params[:id])
     return if @user.nil?||!@user.isAlive||@user.candidate.schedule.nil?
     sign_in(@user)
     redirect_to '/answers/candidate_detail'
  end

  def feed_back
      @recruitment_test = RecruitmentTest.find(params[:id])
  end

end
