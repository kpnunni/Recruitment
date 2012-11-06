class Exam < ActiveRecord::Base
  attr_accessor :subj
   attr_accessible :name,:description,:created_by, :modified_by,:no_of_question , :instruction_ids , :complexity_id ,:subj ,:total_time
   validates :name, :presence =>true
  belongs_to  :complexity
  has_and_belongs_to_many :instructions
  has_and_belongs_to_many :questions

  has_many :schedules  ,:dependent => :destroy

  def generate_question_paper


    @categorys = Category.all
    @question_paper=Array.new


    if self.complexity_id.to_i == 4
      @categorys.each do |category|
        self.subj[category.category]=0     if self.subj[category.category].nil?
        nos=self.subj[category.category].to_i
        if nos!=0
           @questions=Question.where("category_id = ?",category.id ).shuffle.first(nos)
           @questions.each {|q| @question_paper<<q }
        end

      end
      self.questions=@question_paper
      return   @question_paper.count
    end
    if self.complexity_id.to_i == 2
      h=0.5
      l=0.2
    elsif self.complexity_id.to_i == 3
      h=0.33
      l=0.33
    else
      h=0.2
      l=0.5
    end



    #high questions  from each category
    comp_id=Complexity.find_by_complexity(:high).id
    @categorys.each do |category|
      self.subj[category.category]=0     if self.subj[category.category].nil?
      nos=(self.subj[category.category].to_i*h).to_i
      if nos!=0
        @questions=Question.where("complexity_id = ? AND category_id = ?",comp_id, category.id ).shuffle.first(nos)
         @questions.each {|q| @question_paper<<q }
      end
    end

    #medium questions from each category
    comp_id=Complexity.find_by_complexity(:low).id
    @categorys.each do |category|
      nos=(self.subj[category.category].to_i*l).to_i
      if nos!=0
        @questions=Question.where("complexity_id = ? AND category_id = ?",comp_id, category.id ).shuffle.first(nos)
        @questions.each {|q| @question_paper<<q }
      end
    end

    #low level questions from each category
    comp_id=Complexity.find_by_complexity(:medium).id
    @categorys.each do |category|
      nos=self.subj[category.category].to_i-((self.subj[category.category].to_i*l).to_i + (self.subj[category.category].to_i*h).to_i)
      if nos!=0
        @questions=Question.where("complexity_id = ? AND category_id = ?",comp_id, category.id ).shuffle.first(nos)
        @questions.each {|q| @question_paper<<q }
      end
    end


     self.questions=@question_paper
    @question_paper.count
  end
  
  def self.filtered search
      if search.nil?
        return @exam=Exam.all
      end
       name=by=range=Exam.all(:order => 'created_at DESC')
       name.select! {|xam| xam.name.include?(search["name"]) }             if  search["name"]!=""
       by.select! {|xam| xam.created_by.include?(search["by"]) }             if  search["by"]!=""
       range=Exam.where(:created_at => (search[:from].to_date)..(search[:to].to_date))     if search["from"]!="" && search["to"]!=""
      @exams=name&by&range
  end
    
end
