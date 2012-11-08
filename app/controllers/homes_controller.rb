class HomesController < ApplicationController
  attr_accessor  :mail,:pass
  before_filter  :chk_admin ,:only => :admin
  skip_before_filter :authenticate,:only => :default_page
  def index
  end
  def admin

    @schedules1=Schedule.where("sh_date between ? and ?",Date.today ,Date.tomorrow  ).reverse_order
    @schedules7=Schedule.where("sh_date between ? and ?",Date.today.beginning_of_week,Date.today.end_of_week).reverse_order
    @schedules30=Schedule.where("sh_date between ? and ?",Date.today.beginning_of_month,Date.today.end_of_month).reverse_order

    @results1 =RecruitmentTest.where("completed_on between ? and ?",Date.today ,Date.tomorrow  ).reverse_order
    @results7 =RecruitmentTest.where("completed_on between ? and ?",Date.today.beginning_of_week,Date.today.end_of_week).reverse_order
    @results30 =RecruitmentTest.where("completed_on between ? and ?",Date.today.beginning_of_month,Date.today.end_of_month).reverse_order

    @questions=Question.last(10).reverse
    @candidates=RecruitmentTest.find_all_by_is_passed("Passed").last(10).reverse

  end

  def chk_admin
    if current_user.roles.count!=Role.count-1
      redirect_to  '/homes/index'
    end
  end
  def default_page

  end
end
