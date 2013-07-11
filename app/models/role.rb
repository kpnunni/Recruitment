class Role < ActiveRecord::Base
   attr_accessible :role_name
  has_and_belongs_to_many :users
   def self.ransackable_attributes(auth_object = nil)
      super & ['role_name']
   end
end
