class ExamsController < ApplicationController
  before_filter :chk_user
  def chk_user
    if !my_roles.include?('Manage Exams')
      redirect_to '/homes/index'
    end
  end
  def index
    @exams = Exam.filtered(params[:search]).paginate(:page => params[:page], :per_page => 20)
    @users=Exam.select(:created_by).uniq
  end
  def instruction
    @exam=Exam.find(params[:id])
    @instructions=@exam.instructions.all
    @ngtv=Setting.find_by_name('negative_mark').status.eql?("on")
  end
  def show
    @exam = Exam.find(params[:id])
    @qpaper= @exam.questions.all
    @instructions=@exam .instructions .all
  end
  def new
    @exam = Exam.new
    @instruction=Instruction.new
    @exam.subj =Array.new(Category.count)
  end
  def edit
    @exam = Exam.find(params[:id])
    @exam.subj =Array.new(Category.count)
    @instruction=Instruction.new
  end
  def create
    @exam = Exam.new(params[:exam])
    @instruction=Instruction.new
    @exam.subj.values.each do |sub|
      if sub.to_i<0
        flash.now[:error]="number of questions should be a positive number"
        render 'new'
        return
      end
    end
    @exam.no_of_question= @exam.subj.values.collect {|v| v.to_i}.sum
    @exam.created_by =current_user.user_email
    @q_count=@exam.generate_question_paper
    @exam.modified_by =""
    if @q_count <= 0
      flash.now[:error]="Total number of questions should not be '0'."
      render 'new'
      return
    end

    if @exam.no_of_question!=@q_count
      flash.now[:error]="Not enough questions (category wise/complexity wise).do you wish to schedule it for 'default' level instead of other complexity?"
      render 'new'
      return
    end
    @exam.total_time=@exam.questions.collect {|v| v.allowed_time}.sum
    if @exam.save
      calculate_total_time
      redirect_to exams_path , notice: 'Exam was successfully created.'
    else
      render action: "new"
    end
  end


  def update
    @exam = Exam.find(params[:id])
    @instruction=Instruction.new
    @exam.modified_by =current_user .user_email
    @exam.complexity_id=params[:exam][:complexity_id]
    params[:exam][:instruction_ids]=[] if params[:exam][:instruction_ids].nil?
    if regenerate_question_paper?
      @exam.subj= params[:exam][:subj]
      @q_count=@exam.generate_question_paper
      @exam.no_of_question= @exam.subj.values.collect {|v| v.to_i}.sum
      if @exam.no_of_question!=@q_count
        flash.now[:error]="Not enough questions (category wise/complexity wise)"
        render 'new'
        return
      end
      calculate_total_time
    end
    if @exam.update_attributes(params[:exam])
      calculate_total_time
      redirect_to exams_path, notice: 'Exam was successfully updated.'
    else
      render action: "edit"
    end
  end
  def destroy
    @exam = Exam.find(params[:id])
    @exam.destroy
    redirect_to exams_path , notice: 'Exam was successfully deleted.'
  end
  def instruction_order
    @exam = Exam.includes(:instructions).find(params[:id])
  end
  def update_instruction_order
    @exam = Exam.includes(:instructions).find(params[:id])
    @exam.instructions.delete_all
    #params[:exam][:instruction_ids].reverse!  if params[:exam]
    if @exam.update_attributes(params[:exam])
      calculate_total_time
      redirect_to exams_path, notice: 'Instructions reordered successfully.'
    else
      render action: "instruction_order"
    end
  end
  def question_paper
    @exam = Exam.find(params[:id])
    @qpaper= @exam.questions.all
  end
  def remove_instruction
    @exam=Exam.find(params[:id])
    @exam.instructions.delete(Instruction.find params[:instruction_id])
    redirect_to exam_path(@exam)
  end
  def regenerate
    @exam=Exam.find(params[:id])
    @exam.complexity_id=@exam.complexity.id
    @exam.subj= Hash.new(0)
    categories=[]
    @exam.questions.each {|q| categories<<q.category.category }
    categories.each{ |cat| @exam.subj[cat]+=1 }
    @exam.generate_question_paper
    calculate_total_time
    redirect_to  exam_path(@exam)  ,:notice => "Question paper regenerated successfully."
  end
  def regenerate_question_paper?
    categories = @exam.questions.group(:category_id).count
    subjects = {}
    categories.each{|k,v| subjects[Category.find(k).category]=v.to_s}
    new_subjects = params[:exam][:subj]
    new_subjects.delete_if {|k,v| v=="0"}
    if subjects == new_subjects
      false
    else
      true
    end
  end
  def calculate_total_time
    total_time = @exam.questions.map(&:allowed_time).sum
    if Setting.find_by_name("time_limit_for_each_question").status == "off"
      @exam.total_time = total_time * 2/3
    else
      @exam.total_time = total_time
    end
    @exam.save
  end
end
