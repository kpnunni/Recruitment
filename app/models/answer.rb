class Answer < ActiveRecord::Base
  attr_accessor :c_option, :dec_time ,:q_no
   attr_accessible :candidate_id,:question_id,:answer,:time_taken ,:c_option, :dec_time ,:q_no
  validates_uniqueness_of :question_id, :scope => :candidate_id
  belongs_to :candidate
  belongs_to :question


  def  set_answer
     question=self.question
    ans=""

    if self.c_option.nil?
      ans="0"
    elsif question.type.question_type=="check_box"
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
    ans.include?("1") ? ans : "0"
  end

  def get_next_question(candidate)
     questions=candidate.schedule.exam.questions.shuffle
     questions.each do |q|
       if candidate.answers.find_by_question_id(q.id).nil?
          return q
       end
     end
  end


  def no_more
    self.candidate.answers.each do |ans|
       if (ans.question.allowed_time-ans.time_taken)>3
          return false
       end
    end
    return true
  end

  def get_ans
    self.candidate.answers.sort.each do |ans|
       if (ans.question.allowed_time-ans.time_taken)>3
          return ans.id
       end
    end
    return nil
  end

  def get_next_ans(current_id)
    self.candidate.answers.where("id >= ?",current_id ).sort.each do |ans|
      if (ans.question.allowed_time-ans.time_taken)>3
        return ans.id
      end
    end
    self.candidate.answers.where("id < ?",current_id ).sort.each do |ans|
      if (ans.question.allowed_time-ans.time_taken)>3
        return ans.id
      end
    end
    return self.candidate.answers.first.id
  end

  def get_next_ans_in_single_mode(current_id)
    ans = self.candidate.answers.where("id >= ?",current_id ).sort.first
    if ans
      ans
    else
      self.candidate.answers.first.id
    end
  end

   def save_mark(current_user)
     return if current_user.candidate.recruitment_test
     @recruitment_test=RecruitmentTest.new
     @recruitment_test.candidate=current_user.candidate
     @recruitment_test.is_completed= @recruitment_test.completed?
     @recruitment_test.is_passed="Pending"
     @recruitment_test.completed_on=Time.now
     @recruitment_test.calc_right_answers(current_user)
     @recruitment_test.count_no_of_question_attended(current_user)
     @recruitment_test.find_mark_percentage(current_user)
     @recruitment_test.save
     #@user=User.find(current_user.id)
     #@user.update_attribute(:isAlive,0)
   end

  def make_result(user)
    return  if Setting.find_by_name('auto_result').status=="off"

    passed=true
    user.candidate.schedule.exam.questions.all(:select=>:category_id,:group =>"category_id").each do |q|
      if user.candidate.recruitment_test.calc_mark(q.category)<q.category.cutoff
        passed=false
      end
    end
    if passed
     user.candidate.recruitment_test.update_attribute(:is_passed,"Passed")
    else
     user.candidate.recruitment_test.update_attribute(:is_passed,"Pending")
    end
  end
end
