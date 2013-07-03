class HomesController < ApplicationController
  attr_accessor  :mail,:pass
  before_filter  :chk_admin ,:only => :admin
  #before_filter  :chk_user ,:only => :index
  skip_before_filter :authenticate,:only => :default_page
  def index
  end
  def admin

    @schedules1=Schedule.where("sh_date between ? and ?",Date.today ,Date.tomorrow  ).reverse_order
    @schedules7=Schedule.where("sh_date between ? and ?",Date.today.beginning_of_week,Date.today.end_of_week).reverse_order
    @schedules30=Schedule.where("sh_date between ? and ?",Date.today.beginning_of_month,Date.today.end_of_month).reverse_order

    @results1 =RecruitmentTest.includes([:candidate]).where("completed_on between ? and ?",Date.today ,Date.tomorrow  ).reverse_order
    @results7 =RecruitmentTest.includes([:candidate]).where("completed_on between ? and ?",Date.today.beginning_of_week,Date.today.end_of_week).reverse_order
    @results30 =RecruitmentTest.includes([:candidate]).where("completed_on between ? and ?",Date.today.beginning_of_month,Date.today.end_of_month).reverse_order

    @questions=Question.includes([:options,:category,:complexity,:type]).last(10).reverse
    @candidates=RecruitmentTest.includes([:candidate]).find_all_by_is_passed("Passed").last(10).reverse

  end

  def chk_admin
    if !admin?
      redirect_to  '/homes/index'
    end
  end
  def chk_user
    if my_roles.include?("Candidate")
      redirect_to  '/homes/default_page'
    end
  end
  def default_page

  end
end
