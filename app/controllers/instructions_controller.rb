class InstructionsController < ApplicationController
  require 'will_paginate/array'
  def index
    @instructions = Instruction.all(:order => 'created_at DESC').paginate(:page => params[:page], :per_page => 20)
     @instruction = Instruction.new
    respond_to do |format|
      format.html 
      format.json { render json: @instructions }
    end
  end




  def show
    @instruction = Instruction.find(params[:id])

    respond_to do |format|
      format.html
      format.json { render json: @instruction }
    end
  end


  def new
    @instruction = Instruction.new

    respond_to do |format|
      format.html 
      format.json { render json: @instruction }
    end
  end


  def edit
    @instruction = Instruction.find(params[:id])
  end


  def create
    @instruction = Instruction.new(params[:instruction])

    respond_to do |format|
      if @instruction.save
        if params[:by]=="add"
          format.html { redirect_to new_exam_path , notice: 'Instruction was successfully created.' }
        else
        format.html { redirect_to instructions_path , notice: 'Instruction was successfully created.' }
        format.json { render json: @instructions, status: :created, location: @instructions }
        end
      else
        flash[:error]="Instruction is empty /already exists"
        format.html { redirect_to instructions_path }   if params[:by]!="add"
        format.html { redirect_to new_exam_path }   if params[:by]=="add"
       end
    end
  end


  def update
    @instruction = Instruction.find(params[:id])

    respond_to do |format|
      if @instruction.update_attributes(params[:instruction])
        format.html { redirect_to instructions_path , notice: 'Instruction was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @instruction.errors, status: :unprocessable_entity }
      end
    end
  end


  def destroy
    @instruction = Instruction.find(params[:id])
    @instruction.destroy

    respond_to do |format|
      format.html { redirect_to instructions_url, notice: 'Instruction was successfully deleted.' }
      format.json { head :no_content }
    end
  end
end

