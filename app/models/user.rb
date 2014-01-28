class User < ActiveRecord::Base
   attr_accessor :login_password_confirmation  ,:encrypted_password  ,:flag  ,:login_password
   attr_accessible :user_email, :password ,:login_password_confirmation ,:login_password ,  :role_ids ,:salt

   has_and_belongs_to_many :roles
   has_one :candidate  ,:dependent => :destroy
   before_create :set_alive
   before_create :sent_welcome_email
   #  after_save :chk_role
   before_create  :create_remember_token

   email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
   validates :user_email,    :presence   => true,:format     => { :with => email_regex },:uniqueness => { :case_sensitive => false }
   validates :login_password, :presence => true,:confirmation => true,:length => { :within => 4..20 } ,:if => :there?
   validate :include_role
   def self.ransackable_attributes(auth_object = nil)
      super & ['user_email', 'isAlive']
   end
   def set_alive
     self.isAlive= 1
     self.isDelete= 0
   end
   def include_role
     if self.roles.empty?
       self.errors[:base]<<"Select atleast one role"
     end
   end
   def admin?
     self.roles.count==Role.count-1
   end

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

   def sent_welcome_email
     @user=self
   end
   def self.filtered(search,filter,current_user_id)
     @users = User.order('created_at DESC').includes([:roles, :candidate])
     @users.select! {|user| user.isAlive == (filter[:type].to_i==1) }     if filter.try(:[],:type).present?
     @users.select! {|user| user.role_ids.include?(filter[:role].to_i) }  if filter.try(:[],:role).present?
     @users.select! {|user| user.user_email.include?(search) }            if search.present?
     @users.delete_if  {|usr| usr.id==current_user_id}
   end

    def encrypt_password
      self.salt = make_salt if new_record?
      self.password = encrypt(login_password)
    end

    def encrypt(string)
      secure_hash("#{salt}--#{string}")
    end

    def make_salt
      secure_hash("#{Time.now.utc}--#{user_email}")
    end

    def secure_hash(string)
      Digest::SHA2.hexdigest(string)
    end

    def create_remember_token
       self.remember_token = SecureRandom.urlsafe_base64
    end
end
