class Qualification < ActiveRecord::Base
  attr_accessible  :qualification_in, :qualification_from,  :from_date, :to_date, :mark_percentage, :comments ,:candidate_id
   belongs_to :candidate
  validates_presence_of :qualification_in,:from_date, :to_date
end
