class UserMailer < ActionMailer::Base
  default from: "suyationlinetest@gmail.com"

  def welcome_email(user,pass)
    @user = user
    @pass=pass
    @url  = "http://recruitment-suyati.herokuapp.com"
    mail(:to => user.user_email, :subject => "Welcome to Suyati online recruitment test Site")
  end
    def schedule_email(user)
    @user = user
    @url  = "http://recruitment-suyati.herokuapp.com"
    mail(:to => user.user_email, :subject => "Recruitment test")
    end
   def admin_schedule_email (admin,schedule)
    @user = admin
    @schedule= schedule
    mail(:to => admin.user_email, :subject => "New Schedule")
   end
  def result_email(user)
    @user = user
    mail(:to => user.user_email, :subject => "Recruitment test result")
  end

  def cancel_schedule_email(user,schedule)
    @user = user
    @schedule= schedule
    @url  = "http://recruitment-suyati.herokuapp.com"
    mail(:to => user.user_email, :subject => "Scheduled exam canceled")
  end
  def update_schedule_email(user)
    @user = user
    @url  = "http://recruitment-suyati.herokuapp.com"
    mail(:to => user.user_email, :subject => "Update schedule")
  end
  def admin_update_schedule_email(user,schedule)
    @user = user
    @schedule= schedule
    @url  = "http://recruitment-suyati.herokuapp.com"
    mail(:to => user.user_email, :subject => "Update schedule")
  end



end
