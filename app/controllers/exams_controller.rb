class ExamsController < ApplicationController
  
  def index
    @exams = Exam.all.paginate(:page => params[:page], :per_page => 20)

    respond_to do |format|
      format.html 
      format.json { render json: @exams }
    end
  end


  def show
    @exam = Exam.find(params[:id])
    @instructions=@exam .instructions .all
    respond_to do |format|
      format.html 
      format.json { render json: @exam }
    end
  end


  def new
    @exam = Exam.new
    @exam.categories =Array.new(Category.count)
    respond_to do |format|
      format.html 
      format.json { render json: @exam }
    end
  end


  def edit
    @exam = Exam.find(params[:id])
     @exam.categories =Array.new(Category.count)
  end


  def create
    @exam = Exam.new(params[:exam])
    @exam.created_by =current_user.user_email
    @q_count=@exam.generate_question_paper
    @exam.modified_by =""
    @exam.no_of_question= @exam.categories.values.collect {|v| v.to_i}.sum
    if @exam.no_of_question!=@q_count
       render 'new'
       return
    end
    @exam.total_time=@exam.questions.collect {|v| v.allowed_time}.sum
   #     render :text =>  @exam.no_of_question - ( (@exam.categories[".net"].to_i*0.3).to_i+(@exam.categories[".net"].to_i*0.3).to_i)
    respond_to do |format|

      if @exam.save
        format.html { redirect_to exams_path , notice: 'Exam was successfully created.' }
        format.json { render json: @exams, status: :created, location: @exam }
      else
        format.html { render action: "new" }
        format.json { render json: @exam.errors, status: :unprocessable_entity }
      end
    end
  end


  def update
    @exam = Exam.find(params[:id])
    @exam.modified_by =current_user .user_email
    @q_count=@exam.generate_question_paper
    @exam.no_of_question= @exam.categories.values.collect {|v| v.to_i}.sum
    @exam.total_time=@exam.questions.collect {|v| v.allowed_time}.sum
    if @exam.no_of_question!=@q_count
       render 'new'
       return
    end

    respond_to do |format|
      if @exam.update_attributes(params[:exam])
        format.html { redirect_to exams_path, notice: 'Exam was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @exam.errors, status: :unprocessable_entity }
      end
    end
  end


  def destroy
    @exam = Exam.find(params[:id])
    @exam.destroy

    respond_to do |format|
      format.html { redirect_to exams_url }
      format.json { head :no_content }
    end
  end

  def question_paper
    @exam = Exam.find(params[:id])
    @qpaper= @exam.questions.all
  end

  def remove_instruction
     @exam=Exam.find(params[:id])
     @exam.instructions.delete(Instruction.find params[:instruction_id])
   #  render :text => params[:instruction_id]
     redirect_to exam_path(@exam)
  end


end
