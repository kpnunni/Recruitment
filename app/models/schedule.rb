class Schedule < ActiveRecord::Base
  attr_accessor :candidate_ids
   attr_accessible  :exam_id,:sh_date,:sh_time,:candidate_ids
  has_many :candidates
  belongs_to :exam
  accepts_nested_attributes_for :candidates
  after_save :select_candidate
  before_destroy :delete_cid
  validates_presence_of :sh_date,:sh_time,:candidate_ids


  def delete_cid
    self.candidates.each do |c|
      c.recruitment_test.delete if !c.recruitment_test.nil?
      c.answers.delete_all
      c.update_attribute(:schedule_id,nil)
    end
  end


  def select_candidate
    self.candidates.delete_all
    self.candidate_ids.each do  |cid|
       if cid[1] == "1"
         @candidate=Candidate.find(cid[0].to_i)
         @candidate.update_attribute(:schedule_id,self.id)
         self.candidates.push(@candidate)
       end
    end
    self.destroy if self.candidates.empty?
  end
end
