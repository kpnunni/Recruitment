class Answer < ActiveRecord::Base
  attr_accessor :c_option, :dec_time ,:q_no
   attr_accessible :candidate_id,:question_id,:answer,:time_taken ,:c_option, :dec_time ,:q_no
  validates_uniqueness_of :question_id, :scope => :candidate_id
  belongs_to :candidate
  belongs_to :question


  def  get_answer
     question=self.question
    ans=""

    if self.c_option.nil?
      ans="0"
    elsif question.type=="checkbox"
     ans=self.c_option.values.join
    else
      question.options.sort.each do |op|
        if self.c_option["1"]==op.id.to_s
          ans<<"1"
        else
          ans<<"0"
        end
      end
    end
     ans
  end

  def get_next_question(candidate)
     questions=candidate.schedule.exam.questions.shuffle
     questions.each do |q|
       if candidate.answers.find_by_question_id(q.id).nil?
          return q
       end
     end
  end

   def save_mark(current_user)
     @recruitment_test=RecruitmentTest.new
     @recruitment_test.candidate=current_user.candidate
     @recruitment_test.is_completed= @recruitment_test.completed?
     @recruitment_test.is_passed="Pending"
     @recruitment_test.completed_on=Time.now
     @recruitment_test.calc_right_answers(current_user)
     @recruitment_test.count_no_of_question_attended(current_user)
     @recruitment_test.find_mark_percentage(current_user)
     @recruitment_test.save
     @user=User.find(current_user.id)
     @user.update_attribute(:isAlive,0)
   end
end
