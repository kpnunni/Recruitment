ActionMailer::Base.smtp_settings = {
      :address              => "smtp.gmail.com",  
      :port                 => 587,  
      :domain               => "gmail.com",  
      :user_name            => "suyationlinetest", #Your user name
      :password             => "suyati1234", #
      :authentication       => "plain",
      :enable_starttls_auto => true
   }
