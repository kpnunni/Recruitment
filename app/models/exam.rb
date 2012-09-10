class Exam < ActiveRecord::Base
  attr_accessor :complex_id ,:categories
   attr_accessible :name,:description,:created_by, :modified_by,:no_of_question , :instruction_ids , :complex_id ,:categories ,:total_time
   validates :name, :presence =>true
  has_and_belongs_to_many :instructions
  has_and_belongs_to_many :questions

  has_many :schedules  ,:dependent => :destroy

  def generate_question_paper

    if self.complex_id.to_i == 2
      h=0.5
      l=0.2
    elsif self.complex_id.to_i == 3
      h=0.33
      l=0.33
    else
      h=0.2
      l=0.5
    end

    @categorys = Category.all
    @question_paper=Array.new

    #high questions  from each category
    comp_id=Complexity.find_by_complexity(:high).id
    @categorys.each do |category|
      self.categories[category.category]=0     if self.categories[category.category].nil?
      nos=(self.categories[category.category].to_i*h).to_i
      if nos!=0
        @questions=Question.where("complexity_id = ? AND category_id = ?",comp_id, category.id ).shuffle.first(nos)
         @questions.each {|q| @question_paper<<q }
      end
    end

    #medium questions from each category
    comp_id=Complexity.find_by_complexity(:low).id
    @categorys.each do |category|
      nos=(self.categories[category.category].to_i*l).to_i
      if nos!=0
        @questions=Question.where("complexity_id = ? AND category_id = ?",comp_id, category.id ).shuffle.first(nos)
        @questions.each {|q| @question_paper<<q }
      end
    end

    #low level questions from each category
    comp_id=Complexity.find_by_complexity(:medium).id
    @categorys.each do |category|
      nos=self.categories[category.category].to_i-((self.categories[category.category].to_i*l).to_i + (self.categories[category.category].to_i*h).to_i)
      if nos!=0
        @questions=Question.where("complexity_id = ? AND category_id = ?",comp_id, category.id ).shuffle.first(nos)
        @questions.each {|q| @question_paper<<q }
      end
    end


     self.questions=@question_paper
    @question_paper.count
  end


end
