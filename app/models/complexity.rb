class Complexity < ActiveRecord::Base
   attr_accessible :complexity
   validates :complexity,:presence =>true
   has_many :questions ,:dependent => :destroy
   has_many :exams
    accepts_nested_attributes_for :questions
end
