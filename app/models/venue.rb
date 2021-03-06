class Venue < ActiveRecord::Base
  attr_accessible :distance, :name, :foodtype, :distString
  has_many :groups
  validates :name,
	:presence =>  {:message => "Name cant be blank"},
	uniqueness: {:message => "Venue exists", case_sensitive: false }


	validates :distance, :presence => {:message => "Venue needs a distance"}

	before_save { self.foodtype.downcase! }
end
