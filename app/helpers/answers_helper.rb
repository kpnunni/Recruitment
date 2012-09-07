module AnswersHelper
  attr_accessor :q_array
  def q_array=(val)
    @q_array = val
  end

  def q_array
    @q_array= User.find_by_remember_token(cookies[:remember_token]).candidate.schedule.exam.questions.all
  end
end
