class HomesController < ApplicationController
  attr_accessor  :mail,:pass
  before_filter  :chk_admin ,:only => :admin
  def index
  end
  def admin

    @schedules1=Schedule.where("sh_date between ? and ?",Date.today ,Date.tomorrow  )
    @schedules7=Schedule.where("sh_date between ? and ?",Date.today.beginning_of_week,Date.today.end_of_week)
    @schedules30=Schedule.where("sh_date between ? and ?",Date.today.beginning_of_month,Date.today.end_of_month)

    @results1 =RecruitmentTest.where("completed_on between ? and ?",Date.today ,Date.tomorrow  )
    @results7 =RecruitmentTest.where("completed_on between ? and ?",Date.today.beginning_of_week,Date.today.end_of_week)
    @results30 =RecruitmentTest.where("completed_on between ? and ?",Date.today.beginning_of_month,Date.today.end_of_month)

    @questions=Question.last(10)
    @candidates=RecruitmentTest.find_all_by_is_passed("Passed").last(10)

  end
  def login

  end
  def schedule_range

  end
  def chk_admin
    if current_user.roles.count!=Role.count-1
      redirect_to  '/homes/index'
    end
  end

end
