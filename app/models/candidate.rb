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
  validates_format_of :name, :with => /^[^0-9`!@#\$%\^&*+_=]+$/
   has_attached_file :resume
 #    :styles => {
 #      :thumb=> "100x100#",
 #      :small  => "400x400>" }

  validates_format_of :phone1,
                    :with => /\A[0-9]{10}\Z/  , :if => :there1?
    validates_format_of :phone1,
                    :with => /\A[0-9]{10}\Z/  , :if => :there2?




  accepts_nested_attributes_for :experiences, :allow_destroy => true
  accepts_nested_attributes_for :qualifications,:allow_destroy => true
  accepts_nested_attributes_for :user
  accessible_attributes  :user
  before_create :set_role
  after_destroy :chk_schedule

  #validates_presence_of :address ,:phone1,  :phone2 , :technology , :certification , :if => :id_present?

   def there1?
       !self.phone1.blank?
   end
   def there2?
       !self.phone2.blank?
   end

   def id_present?
      !id.nil?
   end

   def chk_schedule
     self.schedule.destroy if !self.schedule.nil? && self.schedule.candidates.empty?
   end

  def set_role
    self.user.roles.push(Role.find(14))
  end

  def self.filtered search
       if search==""||search.nil?
         srch=Candidate.all(:order => 'id DESC')
       else
          search.gsub('+',' ')
          srch= Candidate.where("name like ?","%#{search}%").order('id DESC')
       end
  end
end
