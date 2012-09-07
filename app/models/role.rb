class Role < ActiveRecord::Base
   attr_accessible :role_name
  has_and_belongs_to_many :users
end
