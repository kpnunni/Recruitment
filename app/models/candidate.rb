class Candidate < ActiveRecord::Base
   attr_accessor  :exp,:qual
   has_many :answers  ,:dependent => :destroy
  has_many :experiences   ,:dependent => :destroy
  has_many :qualifications  ,:dependent => :destroy
  belongs_to :user
   belongs_to :schedule
   has_one :recruitment_test  ,:dependent => :destroy
  attr_accessible :experiences_attributes, :qualifications_attributes ,:user_attributes,:exp,:qual,:name, :address ,:phone1,  :phone2 , :technology , :certification ,
                  :skills ,:resume,:user_id,:resume_file_name,:resume_content_type,:resume_file_size
  validates  :name,:presence =>true
  validates  :user_id ,:uniqueness  =>true

   has_attached_file :resume
 #    :styles => {
 #      :thumb=> "100x100#",
 #      :small  => "400x400>" }

#  validates_format_of :phone1,:phone2 ,
#                    :with => /\A[0-9]{10}\Z/
  accepts_nested_attributes_for :experiences, :allow_destroy => true
  accepts_nested_attributes_for :qualifications,:allow_destroy => true
  accepts_nested_attributes_for :user
  accessible_attributes  :user
  before_create :set_role
  after_destroy :chk_schedule

  validates_presence_of :address ,:phone1,  :phone2 , :technology , :certification , :if => :id_present?

   def id_present?
      !id.nil?
   end

   def chk_schedule
     self.schedule.destroy if !self.schedule.nil? && self.schedule.candidates.empty?
   end

  def set_role
    self.user.roles.push(Role.find(2))
  end

end
