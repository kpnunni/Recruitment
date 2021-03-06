class UserMailer < ActionMailer::Base
  default from: "noreply@suyati.com"

  def welcome_email(user,pass)
    @user = user
    @pass=pass
    @url = "recruitment-suyati.herokuapp.com"
    mail(:to => user.user_email, :subject => "Welcome to Suyati online recruitment test Site")
  end
  def schedule_email(user)
    @user = user
    if @user.candidate.schedule.remote
      @content=Template.find(6)
    else
      @content=Template.find(1)
    end
    mail(:to => user.user_email, :subject => "Suyati Online Recruitment Test")
  end
  def admin_schedule_email (admin_emails,schedule)
    @schedule= schedule
    mail(:bcc => admin_emails, :subject => "New Schedule")
  end
  def update_schedule_email(user)
    @content=Template.find(2)
    @user = user
    mail(:to => user.user_email, :subject => "Update schedule")
  end
  def admin_update_schedule_email(admin_emails,schedule)
    @schedule= schedule
    mail(:bcc => admin_emails, :subject => "Update schedule")
  end
  def cancel_schedule_email(user,schedule)
    @content=Template.find(3)
    @user = user
    @schedule= schedule
    mail(:to => user.user_email, :subject => "Scheduled exam canceled")
  end
  def exam_complete_email(user,candidate)
    @user = user
    @candidate=candidate
    mail(:to => user.user_email, :subject => "Result for validation")
  end
  def admin_result_email(admin_emails,result)
    @additional = Question.additional.count
    @results = result
    mail(:bcc => admin_emails, :subject => "Test completed")
  end
  def admin_selected_result_email(admin_emails,result)
    @additional = Question.additional.count
    @results = result
    mail(:bcc => admin_emails, :subject => "Mark Details")
  end
  def result_email(user)
    @pass=Template.find(4)
    @fail=Template.find(5)
    @user = user
    mail(:to => user.user_email, :subject => "Recruitment test result")
  end
  def sent_password(user,token)
    @user = user
    @url = "recruitment-suyati.herokuapp.com/sessions/#{token}/reset_pass"
    mail(:to => user.user_email, :subject => "Reset password")
  end

end