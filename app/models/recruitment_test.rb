class RecruitmentTest < ActiveRecord::Base
   attr_accessible :candidate_id, :is_completed,:completed_on,:right_answers,:no_of_question_attended,:mark_percentage,:is_passed,:comments

   belongs_to :candidate

   def calc_right_answers(user)
      count=0
      user.candidate.answers.each do |ans|
         if ans.answer==ans.question.answer_id
            count+=1
         end
      end
      self.right_answers=count
   end

   def count_no_of_question_attended(user)
       self.no_of_question_attended=user.candidate.answers.where("answer!=?","0").count
   end

   def find_mark_percentage(user)
       self.mark_percentage= (self.right_answers.to_f/user.candidate.schedule.exam.no_of_question)*100
   end

   def each_right_answers(cat)
      count=0
      candidate=self.candidate
      candidate.answers.where(question_id: Question.where("category_id=?",cat.id).pluck(:id)).each do |ans|
         if ans.answer==ans.question.answer_id
            count+=1
         end
      end
      count
   end

   def completed?
     self.candidate.schedule.exam.questions.count==self.candidate.answers.count
   end

  def calc_mark(cat)
    q_nos=self.candidate.schedule.exam.questions.where("category_id = ?",cat.id).count
    right_ans=self.each_right_answers(cat)
    mark_p=(right_ans.to_f/q_nos)*100
  end

  def self.filtered search
       if search==""||search.nil?
         srch=RecruitmentTest.all(:order => 'id DESC')
       else
          search.gsub('+',' ')
          srch= RecruitmentTest.where(candidate_id: Candidate.where("name like ?","%#{search}%").pluck(:id))
       end
  end








  end

