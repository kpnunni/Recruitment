class Instruction < ActiveRecord::Base
   attr_accessible  :instruction
  has_and_belongs_to_many :exams

  validates_presence_of :instruction
  validates_uniqueness_of :instruction
end
