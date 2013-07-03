class RecruitmentTest < ActiveRecord::Base
   attr_accessible :feedback ,:candidate_id, :is_completed,:completed_on,:right_answers,:no_of_question_attended,:mark_percentage,:is_passed,:comments
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
     q_attent=self.no_of_question_attended
     right_ans=self.right_answers.to_f
     total_q=user.candidate.answers.count
     wrong_ans=q_attent-right_ans
     if Setting.find_by_name('negative_mark').status.eql?("off")
       self.mark_percentage= (right_ans/total_q)*100
     else
      self.mark_percentage= ((right_ans-(wrong_ans/4.0))/total_q)*100
     end

   end
   def each_right_answers(cat)
      count=0
      candidate=self.candidate
      candidate.answers.where(question_id: candidate.schedule.exam.questions.where("category_id=?",cat.id).map(&:id)).each do |ans|
         if ans.answer==ans.question.answer_id
            count+=1
         end
      end
      count
   end
      def each_wrong_answers(cat)
      count=0
      candidate=self.candidate
      candidate.answers.where(question_id: candidate.schedule.exam.questions.where("category_id=?",cat.id).map(&:id)).each do |ans|
         if ans.answer!=ans.question.answer_id&&ans.answer!="0"
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
    wrong_ans=self.each_wrong_answers(cat)/4.0
    total_q=self.candidate.schedule.exam.no_of_question
    if ((self.right_answers.to_f/total_q)*100-self.mark_percentage)>1
      right_ans-wrong_ans
    else
       right_ans
    end

  end

    def calc_mark_percentage(cat)
    q_nos=self.candidate.schedule.exam.questions.where("category_id = ?",cat.id).count
    right_ans=self.each_right_answers(cat).to_f
    wrong_ans=self.each_wrong_answers(cat)/4.0
    total_q=self.candidate.schedule.exam.no_of_question
    if ((self.right_answers.to_f/total_q)*100-self.mark_percentage)>1     #negative mark is there in his exam
      mark_p=((right_ans-wrong_ans)/q_nos)*100
    else
      mark_p=(right_ans/q_nos)*100
    end

  end

  def self.filtered(search,sort)
      if search.nil?
        return @test=RecruitmentTest.includes(:candidate => [ :answers =>[:question] , :schedule => [:exam => [:questions]] ] ).order(sort)
      end
       name=range=min=max=RecruitmentTest.order(sort)
       name.select! {|test| test.candidate.name.include?(search["name"]) }             if  search["by"]!=""
      min.select! {|test| test.mark_percentage>=search["min"].to_f }             if  search["min"]!=""
      max.select! {|test| test.mark_percentage<=search["max"].to_f }             if  search["max"]!=""
      range=RecruitmentTest.where(:created_at => (search[:from].to_date)..(search[:to].to_date))     if search["from"]!="" && search["to"]!=""
      @test=name&range&min&max
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

