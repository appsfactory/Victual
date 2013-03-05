class Venue < ActiveRecord::Base
  attr_accessible :distance, :name, :foodtype
  has_many :groups
end
