class CandidatesController < ApplicationController
  # skip_before_filter :authenticate ,:create
  # before_filter :chk_user ,:except =>[ :update ,:create]
  def chk_user
    if !my_roles.include?('Manage Candidates')
      redirect_to '/homes/index'
    end
  end


  def show
    @candidate=Candidate.find(params[:id])
  end

  def index
    @candidates=Candidate.filtered(params[:search]).paginate(:page => params[:page], :per_page => 20)
    @exam=Exam.all
  end

  def edit
    @candidate=Candidate.find(params[:id])
    @candidate.build_recruitment_test if @candidate.schedule && @candidate.recruitment_test.nil?
    @user=@candidate.user
  end

  def create
    @candidate=Candidate.new(params[:candidate])
    @candidate.user.login_password="Suyati123"
    @candidate.user.login_password_confirmation="Suyati123"
    @candidate.user.encrypt_password
    @candidate.user.roles.push(Role.find_by_role_name('Candidate'))
    if @candidate.save
      redirect_to candidates_path , notice: 'Candidate was successfully created.'
    else
      render "new"
    end
  end

  def update
    @candidate=Candidate.find(params[:id])
    if @candidate.update_attributes(params[:candidate])
      redirect_to candidates_path , notice: 'Candidate was successfully updated.'
    else
      @user=@candidate.user
      @experiences=@candidate.experiences.all
      @qualifications=@candidate.qualifications.all
      render action: "edit"
    end
  end

  def destroy
    @candidate=Candidate.find(params[:id])
    @candidate.user.delete
    @candidate.destroy
    redirect_to candidates_path , notice: 'Candidate was successfully deleted.'
  end

  def new
    @candidate=Candidate.new
    @candidate.build_user
  end
  def schedule_create
    @candidate=Candidate.find(params[:schedule][:candidate_ids].keys.first.to_i)
    @exam=Exam.all
    #Schedule
    if @candidate.schedule.nil?
      @schedule = Schedule.new(params[:schedule])
      @schedule.created_by=current_user.user_email
      if @schedule.save
        call_rake :send_one_schedule_mail, :candidate_id =>  @candidate.id
        flash[:notice]='Exam was successfully scheduled.'
        @candidate.user.update_attribute(:isAlive,false) if @schedule.remote
      else
        flash[:error]='Error on scheduling.'
      end
      #Reschedule
    else
      @schedule = @candidate.schedule
      @schedule.updated_by=current_user.user_email
      if  @schedule.update_attributes(params[:schedule])
        call_rake :send_one_update_schedule_mail, :candidate_id =>  @candidate.id
        flash[:notice]='Exam was successfully re-scheduled.'
        @candidate.user.update_attribute(:isAlive,false) if @schedule.remote
      else
        flash[:error]='Error on re-scheduling.'
      end
    end
    redirect_to candidates_path
  end
  def resent_schedule_email
    @candidate=Candidate.find(params[:id])
    if params[:status] == "schedule"
      call_rake :resend_one_schedule_mail, :candidate_id =>  @candidate.id
    else
      call_rake :resend_one_update_schedule_mail, :candidate_id =>  @candidate.id
    end
    redirect_to candidates_path, notice: 'Email was successfully resent.'
  end
end