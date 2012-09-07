class QuestionsController < ApplicationController
 require 'will_paginate/array'
      def index
        @questions= Question.filtered(params[:search],params[:srch]).paginate(:page => params[:page], :per_page => 15)
 #       @questions=Question.paginate(:page => params[:page], :per_page => 10)
        @complexity=Complexity.all
        @category=Category.all
        @types=Type.all
       respond_to do |format|
          format.html
          format.json { render json: @questions }
        end

      end

      def show
        @question = Question.find(params[:id])
        @options = @question.options.all
        respond_to do |format|
          format.html
          format.json { render json: @question }
        end
      end


      def new
        @question = Question.new
        @complexity=Complexity.all
        @category=Category.all
        @types=Type.all
        4.times { @question.options.build }
        respond_to do |format|
          format.html
          format.json { render json: @question }
        end
      end


      def edit
        @question = Question.find(params[:id])
        @complexity=Complexity.all
        @category=Category.all
        @types=Type.all

      end


      def create
        @question = Question.new(params[:question])
        @question.created_by =current_user.user_email
        @question.answer_id=""
        @question.type_id=""

        respond_to do |format|
          if @question.save

              format.html { redirect_to question_path(@question) , notice: 'Question was successfully created.' }
              format.json { render json: @question, status: :created, location: new_question_category_path  }

          else
            @complexity=Complexity.all
            @category=Category.all
            @types=Type.all
            format.html { render action: "new" }
            format.json { render json: @question.errors, status: :unprocessable_entity }
          end
        end
      end


      def update
        @question = Question.find(params[:id])

        respond_to do |format|
          if @question.update_attributes(params[:question])
            @question.options.first.save
            format.html { redirect_to @question, notice: 'Question was successfully updated.' }
            format.json { head :no_content }
          else
            @complexity=Complexity.all
            @category=Category.all
            @types=Type.all
            format.html { render action: "edit" }
            format.json { render json: @question.errors, status: :unprocessable_entity }
          end
        end
      end


      def destroy
        @question = Question.find(params[:id])
        @question.destroy

        respond_to do |format|
          format.html { redirect_to questions_url }
          format.json { head :no_content }
        end
      end
end
