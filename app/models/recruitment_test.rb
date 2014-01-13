class RecruitmentTest < ActiveRecord::Base
  attr_accessible :feedback ,:candidate_id, :is_completed,:completed_on,:right_answers,:no_of_question_attended,:mark_percentage,:is_passed,:comments
  belongs_to :candidate

  def calc_right_answers(user)
    count=0
    user.candidate.answers.select{|ans| candidate.schedule.exam.questions.include?(ans.question) }.each do |ans|
      if ans.answer==ans.question.answer_id
        count+=1
      end
    end
    self.right_answers=count
  end

  def count_no_of_question_attended(user)
    self.no_of_question_attended = user.candidate.answers.select{|ans| candidate.schedule.exam.questions.include?(ans.question) && ans.answer != "0" }.size
  end

  def find_mark_percentage(user)
    q_attent = self.no_of_question_attended
    right_ans = self.right_answers.to_f
    total_q = user.candidate.schedule.exam.questions.size
    wrong_ans = q_attent-right_ans
    if Setting.find_by_name('negative_mark').status.eql?("off")
      self.mark_percentage= (right_ans/total_q)*100
    else
      self.mark_percentage= ((right_ans-(wrong_ans/4.0))/total_q)*100
    end

  end
  def each_right_answers(cat)
    count=0
    candidate.answers.each do |ans|
      if candidate.schedule.exam.questions.include?(ans.question)
        if ans.question.try(:category_id) == cat.id && ans.answer==ans.question.answer_id
          count+=1
        end
      end
    end
    count
  end
  def each_wrong_answers(cat)
    count=0
    candidate=self.candidate
    candidate.answers.each do |ans|
      if candidate.schedule.exam.questions.include?(ans.question)
        if ans.question.try(:category_id) == cat.id && ans.answer!=ans.question.answer_id && ans.answer!="0"
          count+=1
        end
      end
    end
    count
  end

  def completed?
    self.candidate.schedule.exam.questions.size==self.candidate.answers.size
  end

  def calc_mark(cat)
    q_nos=self.candidate.schedule.exam.questions.select { |q| q.category_id == cat.id}.size
    right_ans=self.each_right_answers(cat)
    wrong_ans=self.each_wrong_answers(cat)/4.0
    total_q=self.candidate.answers.size
    if ((self.right_answers.to_f/total_q)*100-self.mark_percentage)>1
      right_ans-wrong_ans
    else
      right_ans
    end

  end

  def calc_mark_percentage(cat)
    q_nos=self.candidate.schedule.exam.questions.select { |q| q.category_id == cat.id}.size
    right_ans=self.each_right_answers(cat).to_f
    wrong_ans=self.each_wrong_answers(cat)/4.0
    total_q=self.candidate.answers.size
    if ((self.right_answers.to_f/total_q)*100-self.mark_percentage)>1     #negative mark is there in his exam
      mark_p=((right_ans-wrong_ans)/q_nos)*100
    else
      mark_p=(right_ans/q_nos)*100
    end

  end

  def self.filtered(search,sort)
    @tests=RecruitmentTest.includes(:candidate => [ :answers =>[:question=>[:complexity, :category]] , :schedule => [:exam => [:questions=>[:complexity, :category]]] ] ).order(sort).all
    @tests.select! {|test| test.candidate.name.include?(search[:name])                         }  if  search.try(:[],:name).present?
    @tests.select! {|test| test.mark_percentage>=search[:min].to_f                             }  if  search.try(:[],:min).present?
    @tests.select! {|test| test.mark_percentage<=search[:max].to_f                             }  if  search.try(:[],:max).present?
    @tests.select! {|test| test.created_at.between?(search[:from].to_date,search[:to].to_date) } if search.try(:[],:from).present? && search.try(:[],:to).present?
    @tests
  end


  def self.search(search)
    if search=="For today"
      where("completed_on between ? and ?",Date.today-1.day ,Date.tomorrow)
    elsif search=="For this week"
      where("completed_on between ? and ?",Date.today.beginning_of_week,Date.today.end_of_week)
    elsif search=="For this month"
      where("completed_on between ? and ?",Date.today.beginning_of_month,Date.today.end_of_month)
    else
      find(:all)
    end
  end



end

