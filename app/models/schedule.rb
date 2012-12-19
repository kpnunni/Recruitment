class Schedule < ActiveRecord::Base
  attr_accessor :candidate_ids
   attr_accessible  :created_by,:updated_by,:exam_id,:sh_date,:candidate_ids
  has_many :candidates
  belongs_to :exam
  accepts_nested_attributes_for :candidates
  after_save :select_candidate
  before_destroy :delete_cid
  validates_presence_of :sh_date,:candidate_ids


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


  def self.filtered search
      if search.nil?
        return @schedule=Schedule.all(:order => 'created_at DESC')
      end
       by=range=Schedule.all(:order => 'created_at DESC')
       by.select! {|schedul| schedul.created_by.include?(search["by"]) }             if  search["by"]!=""
       range=Schedule.where(:created_at => (search[:from].to_date)..(search[:to].to_date))     if search["from"]!="" && search["to"]!=""
      @schedules=by&range
  end

  def self.search(search)
    if search=="For today"
      where("sh_date between ? and ?",Date.today-1.day ,Date.tomorrow  )
    elsif search=="For this week"
     where("sh_date between ? and ?",Date.today.beginning_of_week,Date.today.end_of_week)
    elsif search=="For this month"
          where("sh_date between ? and ?",Date.today.beginning_of_month,Date.today.end_of_month)
    else
     find(:all)
   end
  end
end
