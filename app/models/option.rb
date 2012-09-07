class Option < ActiveRecord::Base
  attr_accessible :option, :is_right ,:question_id
     validates :option,:presence =>true
  belongs_to :question

  after_save :set_answer ,:set_type
  after_destroy  :set_answer ,:set_type

  def set_answer
    ans=""
    self.question.options.each do |op|
      ans<<((op.is_right&&1).to_s.to_i.to_s)
    end
    self.question.update_attribute(:answer_id,ans)
  end

  def set_type
    if self.question.options.where("is_right=?",true).count>1
      self.question.update_attribute(:type_id,Type.where("question_type=?","check_box").first.id)
    else
      self.question.update_attribute(:type_id,Type.where("question_type=?","radio_button").first.id)
    end
  end

end



