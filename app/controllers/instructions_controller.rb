class InstructionsController < ApplicationController
  def index
    @instructions = Instruction.all(:order => 'created_at DESC').paginate(:page => params[:page], :per_page => 20)
    @instruction = Instruction.new
  end
  def show
    @instruction = Instruction.find(params[:id])
  end
  def new
    @instruction = Instruction.new
  end
  def edit
    @instruction = Instruction.find(params[:id])
  end
  def create
    @instruction = Instruction.new(params[:instruction])

    if @instruction.save
      if params[:by]=="add"
        redirect_to new_exam_path , notice: 'Instruction was successfully created.' }
      else
        redirect_to instructions_path , notice: 'Instruction was successfully created.' }
      end
    else
      flash[:error]="Instruction is empty /already exists"
      redirect_to instructions_path     if params[:by]!="add"
      redirect_to new_exam_path    if params[:by]=="add"
    end
  end
  def update
    @instruction = Instruction.find(params[:id])
    if @instruction.update_attributes(params[:instruction])
      redirect_to instructions_path , notice: 'Instruction was successfully updated.'
    else
      render action: "edit"
    end
  end
  def destroy
    @instruction = Instruction.find(params[:id])
    @instruction.destroy
    redirect_to instructions_url, notice: 'Instruction was successfully deleted.'
  end
end

