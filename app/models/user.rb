class User < ActiveRecord::Base
 	attr_accessible :distance, :email, :matched, :name, :timeEnd, :timeStart, :type, :going_out, 
 	:has_pref, :accepted, :group_id, :start, :end, :dist
  belongs_to group
  	
  	validates :name, 
	:presence =>  {:message => "User name cant be blank"},
	uniqueness: {:message => "User name already taken", case_sensitive: false }

	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

	validates :email, :presence => {:message => "Email can't be blank"},
	format: { with: VALID_EMAIL_REGEX, :message => "Invalid Email" },
	uniqueness: {:message => "Email already taken", case_sensitive: false }

	before_save { self.email.downcase! }
	before_save { self.type.downcase! }
end
