class Experience < ActiveRecord::Base
  attr_accessible :from_date, :to_date,  :experience_in,  :experience_from ,:candidate_id
  validates_presence_of :from_date, :to_date,  :experience_in
  belongs_to :candidate

end
