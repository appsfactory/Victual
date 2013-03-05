task(:lunch => :environment) do
  require 'application_controller'
  require 'application_helper'
  include ApplicationHelper
  @users = User.where("has_pref = ? AND matched = ? AND foodtype != ? AND going_out = ?", true, false, "any", true)
  while @users and @users.length >= 1
    match_by_type(@users[0].id, create_group.id, true)
    @users = User.where("has_pref = ? AND matched = ? AND foodtype != ? AND going_out = ?", true, false, "any", true)
  end

  @users = User.where("has_pref = ? AND matched = ? AND foodtype = ? AND going_out = ?", true, false, "any", true)
  while @users and @users.length >= 1
    temp = []
    match_by_time(@users[0].id, create_group.id, temp,true)
    @users = User.where("has_pref = ? AND matched = ? AND foodtype = ? AND going_out = ?", true, false, "any", true)
  end
  @users = User.where("has_pref = ? AND matched = ? AND going_out = ?", true, false, false)
  while @users and @users.length >= 1
    temp = []
    match_by_time(@users[0].id, create_group.id, temp,true)
    @users = User.where("has_pref = ? AND matched = ? AND going_out = ?", true, false, false)
  end

  match_remainder(true)
  match_remainder false

  assign_venues
  check_full

  redistribute_all true
  redistribute_all false
end
