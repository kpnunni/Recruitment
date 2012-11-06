class TemplatesController < ApplicationController
    before_filter :chk_user
   def show
     @template=Template.find(params[:id])
   end
  def update
    @template=Template.find(params[:id])
    if @template.update_attributes(params[:template])
       redirect_to root_path
    else
       render action: "show"
     end
  end

    def chk_user
    if !current_user.has_role?('Manage Templates')
      redirect_to '/homes/index'
    end

    end

end
