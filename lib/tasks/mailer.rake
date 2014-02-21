desc "Send welcome mailing"
task :send_welcome_mail => :environment do
  @user = User.find(ENV["MAILING_ID"])
  UserMailer.welcome_email(@user,ENV["PASS"]).deliver
end
desc "Send schedule email for 1 candidate"
task :send_one_schedule_mail => :environment do
  @candidate = Candidate.find(ENV["CANDIDATE_ID"])
  UserMailer.schedule_email(@candidate.user).deliver
  @users=User.joins(:roles).where(roles: {role_name: "Get Schedule Email"})
  @users.each {|admin| UserMailer.admin_schedule_email(admin,@candidate.schedule).deliver  }
end
desc "Send update schedule email for 1 candidate"
task :send_one_update_schedule_mail => :environment do
  @candidate = Candidate.find(ENV["CANDIDATE_ID"])
  UserMailer.update_schedule_email(@candidate.user).deliver
  @users=User.joins(:roles).where(roles: {role_name: "Get Schedule Email"})
  @users.each {|admin| UserMailer.admin_update_schedule_email(admin,@candidate.schedule).deliver  }
end
desc "Resend schedule email for 1 candidate"
task :resend_one_schedule_mail => :environment do
  @candidate = Candidate.find(ENV["CANDIDATE_ID"])
  UserMailer.schedule_email(@candidate.user).deliver
end
desc "Resend update schedule email for 1 candidate"
task :resend_one_update_schedule_mail => :environment do
  @candidate = Candidate.find(ENV["CANDIDATE_ID"])
  UserMailer.update_schedule_email(@candidate.user).deliver
end
desc "Send schedule email for many candidate"
task :send_schedule_mail => :environment do
  @schedule = Schedule.find(ENV["SCHEDULE_ID"])
  @schedule.candidates.each{|c| UserMailer.schedule_email(c.user).deliver  }
  @users=User.joins(:roles).where(roles: {role_name: "Get Schedule Email"})
  @users.each {|admin| UserMailer.admin_schedule_email(admin,@schedule).deliver }
end
desc "Send update schedule email for many candidate"
task :send_update_schedule_mail => :environment do
  @schedule = Schedule.find(ENV["SCHEDULE_ID"])
  @schedule.candidates.each{|c| UserMailer.update_schedule_email(c.user).deliver  }
  @users=User.joins(:roles).where(roles: {role_name: "Get Schedule Email"})
  @users.each {|admin| UserMailer.admin_update_schedule_email(admin,@schedule).deliver }
end
desc "Send result email"
task :send_result_mail => :environment do
  ids = ENV["CANDIDATE_IDS"].split(",")
  @results = RecruitmentTest.where(id: ids ).all
  @users=User.joins(:roles).where( roles: { role_name: "Get Selection Email"})
  @users.each {|admin| UserMailer.admin_result_email(admin,@results).deliver  }
end
desc "Send selected result email"
task :send_selected_result_mail => :environment do
  ids = ENV["CANDIDATE_IDS"].split(",")
  @results = RecruitmentTest.where(id: ids ).order(mark_percentage: :desc).all
  @users=User.joins(:roles).where( roles: { role_name: "Get Selection Email"})
  @users.each {|admin| UserMailer.admin_selected_result_email(admin,@results).deliver  }
end
