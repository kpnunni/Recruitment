class CategoriesController < ApplicationController
       def index
      @categories = Category.all(:order => 'created_at DESC').paginate(:page => params[:page], :per_page => 20)
      @category = Category.new
      respond_to do |format|
        format.html
        format.json { render json: @categories }
      end
    end

    def new
      @category = Category.new

      respond_to do |format|
        format.html
        format.json { render json: @category }
      end
    end


    def edit
      @category = Category.find(params[:id])
    end


    def create
      @category = Category.new(params[:category])

      respond_to do |format|
        if @category.save
         if params[:by]=="add"
          format.html { redirect_to new_question_path , notice: 'Category  was successfully created.' }
        else
          format.html { redirect_to categories_path, notice: 'Category was successfully created.' }
          format.json { render json: @categories, status: :created, location: @category }
         end
        else
          flash[:error]="Category already exists/empty."
         if params[:by]=="add"
          format.html { redirect_to new_question_path }
         else
          format.html { redirect_to categories_path }
          format.json { render json: @category.errors, status: :unprocessable_entity }
          end
         end
      end
    end


    def update
      @category = Category.find(params[:id])

      respond_to do |format|
        if @category.update_attributes(params[:category])
          format.html { redirect_to categories_path, notice: 'Category was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @category.errors, status: :unprocessable_entity }
        end
      end
    end


    def destroy
      @category = Category.find(params[:id])
      @category.destroy

      respond_to do |format|
        format.html { redirect_to categories_path, notice: 'Category was successfully deleted.' }
        format.json { head :no_content }
      end
  end

end
