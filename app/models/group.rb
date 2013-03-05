class Group < ActiveRecord::Base
  attr_accessible :dist, :end, :start, :foodtype, :venue_id
  has_many :users
  belongs_to :venue

end
