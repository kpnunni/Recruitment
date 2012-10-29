class Category < ActiveRecord::Base
 attr_accessible :category,:cutoff
 validates :category,:presence =>true
 validates_uniqueness_of :category
 has_many :questions ,:dependent => :destroy
 accepts_nested_attributes_for :questions
end
