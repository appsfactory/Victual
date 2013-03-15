task(:lunch => :environment) do
  # Run at 10:30
  if Phase.first.nil?
    @phase = Phase.new()
    @phase.save
  end
  Phase.first.current = "late"
  Phase.first.save
  require 'application_controller'
  require 'application_helper'
  include ApplicationHelper
  # By type (users who are going out and have type preference)
  puts "type pref"
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
    fill_given_group(create_group(true).id, temp,true)
    @users = User.where("has_pref = ? AND matched = ? AND foodtype = ? AND going_out = ?", true, false, "any", true).order('dist asc').limit(6)
    if prev == @users.length
      count+=1;
    end
    prev = @users.length
  end
  # Users with time constraint, packed lunch
  puts "time constraint"
  @users = User.where("matched = ? AND going_out = ? AND has_pref = ?", false, false, true)
  prev = 0;
  count = 0;
  while @users and @users.length >= 1 and count < 20
    temp = []
    fill_given_group(create_group(false).id, temp,true)
    @users = User.where("matched = ? AND going_out = ? AND has_pref = ?", false, false, true)
    if prev == @users.length
      count+=1;
    end
    prev = @users.length
  end
  puts Group.all


  match_remainder true
  match_remainder false


  # Call these again after declinations
  check_full
  redistribute_all true
  redistribute_all false

  assign_venues

  users = User.where("matched = ?", true)
  users.each do |user|
    UserMailer.info(user).deliver
    if user.group.notified = false
      user.group.notified = true
      user.group.save
    end
  end
  @users = User.where("matched = ?", false)
  if @users[0]
    @users.each do |user|
      UserMailer.apology(user).deliver
    end
  end
end
