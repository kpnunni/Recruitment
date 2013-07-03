class CategoriesController < ApplicationController
  def index
    @categories = Category.all(:order => 'created_at DESC').paginate(:page => params[:page], :per_page => 20)
    @category = Category.new
  end
  def new
    @category = Category.new
  end
  def edit
    @category = Category.find(params[:id])
  end
  def create
    @category = Category.new(params[:category])
    if @category.save
      if params[:by]=="add"
        redirect_to categories_path, notice: 'Category was successfully created.'
      end
    else
      flash[:error]="Category already exists/empty."
      if params[:by]=="add"
        redirect_to new_question_path
      else
        redirect_to categories_path
      end
    end
  end
  def update
    @category = Category.find(params[:id])
    if @category.update_attributes(params[:category])
      redirect_to categories_path, notice: 'Category was successfully updated.'
    else
      render action: "edit"
    end
  end
  def destroy
    @category = Category.find(params[:id])
    @category.destroy
    redirect_to categories_path, notice: 'Category was successfully deleted.'
  end
end
