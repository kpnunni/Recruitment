class QuestionsController < ApplicationController
  layout false ,:only => :show
  before_filter :chk_user
  require 'will_paginate/array'

    def chk_user
    if !current_user.has_role?('Manage Questions')
      redirect_to '/homes/index'
    end
    end

      def index
        @questions= Question.filtered(params[:search],params[:srch]).paginate(:page => params[:page], :per_page => 15)
 #       @questions=Question.paginate(:page => params[:page], :per_page => 10)
        @complexity=Complexity.all
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
        @complexity=Complexity.all
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
        @complexity=Complexity.all
        @category=Category.all
        @types=Type.all

      end


      def create
        @question = Question.new(params[:question])
        @question.created_by =current_user.user_email
        @question.answer_id=""
        @question.type_id=""
        @complexity=Complexity.all
        @categorys=Category.all
        @category=Category.new
        @types=Type.all
        flag=0
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
        params[:question][:update_by]=current_user.user_email
        flag=0
        params[:question]['options_attributes'].each {|k,v| flag=1 if v['is_right']=='1'}
        if flag==0
            @complexity=Complexity.all
            @category=Category.all
            @types=Type.all
            @opt=@question.options.all
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
     params[:to_delete].each do |k,v|
        Question.find(k.to_i).delete if v.to_i==1
     end
    redirect_to questions_path
  end
end
