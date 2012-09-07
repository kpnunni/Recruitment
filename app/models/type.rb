class Type < ActiveRecord::Base
   attr_accessible :question_type
   has_many :questions  ,:dependent => :destroy
    accepts_nested_attributes_for :questions
 end
