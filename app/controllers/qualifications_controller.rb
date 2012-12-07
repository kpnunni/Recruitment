class QualificationsController < ApplicationController
   def edit
    @candidate=Candidate.find(params[:candidate_id])
    @qualification=@candidate.qualifications.find(params[:id])
  end
  def create
    @candidate=Candidate.find(params[:candidate_id])
    @qualification=@candidate.qualifications.build(params[:qualification])
    if @qualification.save
      redirect_to  edit_candidate_path(@candidate), :action => "new"
    else
      render action: "new"
    end
  end
  def update
    @candidate=Candidate.find(params[:candidate_id])
    @qualification=@candidate.qualifications.find(params[:id])
    if @qualification.update_attributes(params[:qualification])
      redirect_to edit_candidate_path(@candidate) , notice: 'Qualification was successfully updated.'
    else
      render action: "edit"
    end
  end
  def destroy
    @candidate=Candidate.find(params[:candidate_id])
    @qualification=@candidate.qualifications.find(params[:id])
    @qualification.destroy
    redirect_to edit_candidate_path(@candidate) , notice: 'deleted.'
  end
  def new
    @candidate=Candidate.find(params[:candidate_id])
    @qualification=@candidate.qualifications.build
  end
end
