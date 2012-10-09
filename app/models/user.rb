class User < ActiveRecord::Base
   attr_accessor :login_password_confirmation  ,:encrypted_password  ,:flag  ,:login_password
  attr_accessible :user_email, :password ,:login_password_confirmation ,:login_password ,  :role_ids ,:salt

   has_and_belongs_to_many :roles
   has_one :candidate  ,:dependent => :destroy
   before_create :set_alive
 #  after_save :chk_role
   def set_alive
    self.isAlive= 1
    self.isDelete= 0
   end
    before_create  :create_remember_token


    email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i



validates :user_email,    :presence   => true,
                     :format     => { :with => email_regex },
                     :uniqueness => { :case_sensitive => false }

validates :login_password, :presence => true,
                     :confirmation => true,
                     :length => { :within => 4..20 } ,:if => :there?
   def there?
     self.id.nil?
   end
   def chk_role
     if self.roles.count==0
       self.roles.push(Role.find(3))
     end
   end


   def has_role?(*role_names)
     self.roles.where(:role_name =>role_names ).present?
   end



        def encrypt_password
          self.salt = make_salt if new_record?
          self.password = encrypt(login_password)
        end

        def encrypt(string)
          secure_hash("#{salt}--#{string}")
        end

        def make_salt
          secure_hash("#{Time.now.utc}--#{login_password}")
        end

        def secure_hash(string)
          Digest::SHA2.hexdigest(string)
        end

        def create_remember_token
           self.remember_token = SecureRandom.urlsafe_base64
        end

     def self.filtered(search,filter,id)
       filt=User.all(:order => 'created_at DESC')
       if !(filter.nil?||filter[:type]=="")
          filt.select! {|v| v.isAlive==filter[:type].to_i }
       end

       if search==""||search.nil?
         srch=User.all(:order => 'created_at DESC')
       else
          srch= User.where("user_email like ?","%#{search}%").order('id DESC')
       end
       users=srch&filt
       users.delete_if  {|usr| usr.roles.include?(Role.find(14))||usr.id==id}

     end

end
