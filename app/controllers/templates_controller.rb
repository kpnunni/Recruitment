class TemplatesController < ApplicationController
    before_filter :chk_user
   def show
     @template=Template.find(params[:id])
   end
  def update
    @template=Template.find(params[:id])
    if @template.update_attributes(params[:template])
       redirect_to @template ,:notice => "Saved changes"
    else
       render action: "show"
     end
  end

    def chk_user
    if !my_roles.include?('Manage Templates')
      redirect_to '/homes/index'
    end

    end

end
