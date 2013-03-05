class Admin < ActiveRecord::Base
  has_secure_password
  attr_accessible :name, :password
  validates :name, presence: true
end
