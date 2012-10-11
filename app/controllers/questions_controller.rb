class QuestionsController < ApplicationController
  layout false ,:only => :show
  before_filter :chk_user
  require 'will_paginate/array'

    def chk_user
    if !current_user.has_role?('Add Questions Only')&&!current_user.has_role?('Manage Questions')&&!current_user.has_role?('Add Questions')
      redirect_to '/homes/index'
    end
    end

      def index
        @questions= Question.filtered(params[:search],params[:srch]).paginate(:page => params[:page], :per_page => 15)
 #       @questions=Question.paginate(:page => params[:page], :per_page => 10)
        if current_user.has_role?('Add Questions')&&!current_user.has_role?('Manage Questions')
          @questions.select! {|q| q.created_by==current_user.user_email}
        end
        if (current_user.has_role?('Add Questions Only')&&!current_user.has_role?('Manage Questions')&&!current_user.has_role?('Add Questions'))
           @questions.select! {|q| q.created_at>=(Time.now-1.minutes) }
        end
        @complexity=Complexity.first(3)
        @category=Category.all
        @types=Type.all
        @users=User.all
        @ids=Array.new(@questions.count)
        @users.select! {|usr| Question.where(:created_by =>usr.user_email).present?}
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
        @complexity=Complexity.first(3)
        @categorys=Category.all
        @category=Category.new
        @types=Type.all
        5.times { @question.options.build }
        respond_to do |format|
          format.html
          format.json { render json: @question }
        end
      end


      def edit
        @question = Question.find(params[:id])
        @opt=@question.options.all
        @complexity=Complexity.first(3)
        @category=Category.all
        @types=Type.all

      end


      def create
        @question = Question.new(params[:question])
        @question.created_by =current_user.user_email
        @question.answer_id=""
        @question.type_id=""
        @complexity=Complexity.first(3)
        @categorys=Category.all
        @category=Category.new
        @types=Type.all
        flag=0
        if params[:question][:question]==""&&params[:question][:question_image].nil?
            flash[:notice]="Question or image should not be blank"
            render action: "new"
            return
        end
        params[:question]['options_attributes'].each {|k,v| flag=1 if v['is_right']=='1'}
        if flag==0
            5.times { @question.options.build }
            flash[:notice]="atleast one option should be true"
            render action: "new"
            return
        end
        respond_to do |format|
          if @question.save
              format.html { redirect_to questions_path , notice: 'Question was successfully created.' }
          else
            5.times { @question.options.build }
            format.html { render action: "new" }
            format.json { render json: @question.errors, status: :unprocessable_entity }
          end
        end
      end


      def update
        @question = Question.find(params[:id])
        params[:question][:updated_by]=current_user.user_email
        @complexity=Complexity.first(3)
        @category=Category.all
        @types=Type.all
        @opt=@question.options.all
        flag=0
        params[:question]['options_attributes'].each {|k,v| flag=1 if v['is_right']=='1'}
        if params[:question][:question]==""&&params[:question][:question_image].nil?
            flash[:notice]="Question or image should not be blank"
            render action: "edit"
            return
        end
        if flag==0

            flash[:notice]="atleast one option should be true"
            render action: "new"
            return
        end
        respond_to do |format|
          if @question.update_attributes(params[:question])
            @question.options.first.save
            format.html { redirect_to questions_path , notice: 'Question was successfully updated.' }
            format.json { head :no_content }
          else
            @complexity=Complexity.all
            @category=Category.all
            @types=Type.all
            @opt=@question.options.all
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

  def delete_all
    flag=0
    if !params[:to_delete].nil?
     params[:to_delete].each do |k,v|
        @question=Question.find(k.to_i)
        flag=1 if !@question.exams.empty?&&v.to_i==1
        @question.delete if v.to_i==1&&@question.exams.empty?
     end
     if flag==1
       flash[:notice]="some questions are part of question paper.So you cant delete."
     else
       flash[:notice]="Question's' successfully deleted"
     end

    end
    redirect_to questions_path
  end

  def delete_image
    @question=Question.find(params[:id])
    @question.question_image.clear
    @question.save
    redirect_to edit_question_path(@question)
  end
end
