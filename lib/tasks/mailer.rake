desc "Send mailing"
task :send_welcome_mail => :environment do
  @user = User.find(ENV["MAILING_ID"])
  UserMailer.welcome_email(@user,ENV["PASS"]).deliver
end