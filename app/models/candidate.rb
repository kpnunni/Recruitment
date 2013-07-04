class Candidate < ActiveRecord::Base
  attr_accessor :exp,:qual,:done
  attr_accessible :done,:recruitment_test_attributes,:experiences_attributes, :qualifications_attributes ,:user_attributes,:exp,:qual,:name, :address ,:phone1, :phone2 , :technology , :certification ,
                  :skills ,:resume,:user_id,:resume_file_name,:resume_content_type,:resume_file_size
  
  has_many :answers ,:dependent => :destroy
  has_many :experiences ,:dependent => :destroy
  has_many :qualifications ,:dependent => :destroy
  belongs_to :user
  belongs_to :schedule
  has_one :recruitment_test ,:dependent => :destroy
  has_attached_file :resume

  validates :name,:presence =>true
  validates :user_id ,:uniqueness =>true
  validates_format_of :phone1,  :with => /\A[0-9]{10}\Z/  , :allow_blank => true
  validates_format_of :phone2,  :with => /\A[0-9]{10}\Z/  , :allow_blank => true

  accepts_nested_attributes_for :experiences, :allow_destroy => true,:reject_if => :all_blank
  accepts_nested_attributes_for :qualifications,:allow_destroy => true,:reject_if => :all_blank
  accepts_nested_attributes_for :user
  accepts_nested_attributes_for :recruitment_test,:allow_destroy => true,:reject_if => :all_blank
  accessible_attributes :user
  
  after_destroy :chk_schedule

  def id_present?
    !id.nil?
  end

  def chk_schedule
    self.schedule.destroy if !self.schedule.nil? && self.schedule.candidates.empty?
  end

  def set_role
    self.user.roles.push(Role.find_by_role_name('Candidate') )
  end

  def self.filtered search
    @candidates = Candidate.order('created_at DESC').includes([:user, :schedule, :recruitment_test]).all
    @candidates.select! {|can| can.name.include?(search[:name])                                         } if search.try(:[],:name).present?
    @candidates.select! {|can| can.user.user_email.include?(search[:email])                             } if search.try(:[],:email).present?
    @candidates.select! {|can| can.phone1.include?(search[:phone])||can.phone2.include?(search[:phone]) } if search.try(:[],:phone).present?
    @candidates.select! {|can| can.skills.include?(search[:skill])                                      } if search.try(:[],:skill).present?
    if search && search[:status]&& search[:status][:type] &&search[:status][:type]=="Exam Scheduled"
      @candidates.select! {|can| !can.schedule.nil? }
    elsif search && search[:status]!=""&&search[:status][:type]=="Exam not Scheduled"
      @candidates.select! {|can| can.schedule.nil? }
    elsif search && search[:status]!=""&&search[:status][:type]=="Exam Completed"
      @candidates.select! {|can| !can.recruitment_test.nil? }
    end
    @candidates
  end
  def to_param
     "#{id} #{name}".parameterize
  end
end