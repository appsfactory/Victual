task(:lunch => :environment) do
  require 'application_controller'
  require 'application_helper'
  include ApplicationHelper
  # By type (users who are going out and have type preference)
  prev = 0;
  count = 0
  @users = User.where("has_pref = ? AND matched = ? AND NOT foodtype = ? AND going_out = ?", true, false, "any", true).order('dist asc').limit(6)
  while @users and @users.length >= 1 and count < 20
    @group = create_group(true)
    add_user_to_group @users[0].id, @group.id
    match_by_type(@users[0].id, @group.id)
    @users = User.where("has_pref = ? AND matched = ? AND NOT foodtype = ? AND going_out = ?", true, false, "any", true).order('dist asc').limit(6)
    if prev == @users.length
      count+=1;
    end
    prev = @users.length
  end

  # Users with time constraint, going out
  @users = User.where("has_pref = ? AND matched = ? AND foodtype = ? AND going_out = ?", true, false, "any", true).order('dist asc').limit(6)
  prev = 0;
  count = 0
  while @users and @users.length >= 1 and count < 20
    temp = []
    fill_given_group(@users[0].id, create_group(true).id, temp,true)
    @users = User.where("has_pref = ? AND matched = ? AND foodtype = ? AND going_out = ?", true, false, "any", true).order('dist asc').limit(6)
    if prev == @users.length
      count+=1;
    end
    prev = @users.length
  end
  # Users with time constraint, packed lunch
  @users = User.where("matched = ? AND going_out = ?", false, false)
  prev = 0;
  count = 0
  while @users and @users.length >= 1 and count < 20
    temp = []
    fill_given_group(@users[0].id, create_group(false).id, temp,true)
    @users = User.where("matched = ? AND going_out = ?", false, false)
    if prev == @users.length
      count+=1;
    end
    prev = @users.length
  end


  match_remainder true
  match_remainder false


  # Call these again after declinations
  check_full
  redistribute_all true
  redistribute_all false

  assign_venues
end
