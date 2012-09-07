class OptionsController < ApplicationController

      def index
        @question=Question.find(params[:question_id])
        @options = @question.options.all

        respond_to do |format|
          format.html
          format.json { render json: @options }
        end
      end

      def show
        @option = Option.find(params[:question_id])

        respond_to do |format|
          format.html
          format.json { render json: @option }
        end
      end

      def new
        @question=Question.find(params[:question_id])
        @option = @question.options.build

        respond_to do |format|
          format.html
          format.json { render json: @option }
        end
      end

      def edit
        @question=Question.find(params[:question_id])
        @option = @question.options.find(params[:id])
      end

      def create
        @question=Question.find(params[:question_id])
        @option = @question.options.new(params[:option])
        respond_to do |format|
          if @option.save
            format.html { redirect_to question_path(@question), notice: 'Option was successfully created.' }
            format.json { render json: question_path(@question), status: :created, location: @option }
          else
            format.html { render action: "new" }
            format.json { render json: @option.errors, status: :unprocessable_entity }
          end
        end
      end

      def update
        @question=Question.find(params[:question_id])
        @option = @question.options.find(params[:id])

        respond_to do |format|
          if @option.update_attributes(params[:option])
            format.html { redirect_to question_path(@question) , notice: 'Option was successfully updated.' }
            format.json { head :no_content }
          else
            format.html { render action: "edit" }
            format.json { render json: @option.errors, status: :unprocessable_entity }
          end
        end
      end

      def destroy
        @question=Question.find(params[:question_id])
        @option = @question.options.find(params[:id])
        @option.destroy

        respond_to do |format|
          format.html { redirect_to question_path(@question) }
          format.json { head :no_content }
        end
      end
end
