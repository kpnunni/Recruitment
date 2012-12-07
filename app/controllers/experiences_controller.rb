class ExperiencesController < ApplicationController

  def edit
      @candidate=Candidate.find(params[:candidate_id])
      @experience=@candidate.experiences.find(params[:id])
  end

  def create
      @candidate=Candidate.find(params[:candidate_id])
      @experience=@candidate.experiences.build(params[:experience])
      if @experience.save
         redirect_to  edit_candidate_path (@candidate ), :action => "new"
      else
         render action: "new"
      end
  end

  def update
      @candidate=Candidate.find(params[:candidate_id])
      @experience=@candidate.experiences.find(params[:id])
      if @experience.update_attributes(params[:experience])
        redirect_to edit_candidate_path(@candidate) , notice: 'Experience was successfully updated.'
      else
        render action: "edit"
      end
  end

  def destroy
    @candidate=Candidate.find(params[:candidate_id])
    @experience=@candidate.experiences.find(params[:id])
    @experience.destroy
    redirect_to edit_candidate_path(@candidate) , notice: 'deleted.'
  end

  def new
    @candidate=Candidate.find(params[:candidate_id])
    @experience=@candidate.experiences.build
  end

end
