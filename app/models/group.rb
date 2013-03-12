class Group < ActiveRecord::Base
  attr_accessible :dist, :end, :start, :foodtype, :venue_id, :going_out
  has_many :users
  belongs_to :venue

end
