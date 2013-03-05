class Group < ActiveRecord::Base
  attr_accessible :dist, :end, :start, :type, :venue_id
  has_many users
  belongs_to venue
  def create
    @group.type = "Any"
    @group.dist = 1000
    @group.start = 1100
    @group.end = 1500
    @group.save
    render nothing: true
  end
end
