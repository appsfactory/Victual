class Venue < ActiveRecord::Base
  attr_accessible :distance, :name, :type
  has_many :groups
end
