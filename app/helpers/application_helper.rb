module ApplicationHelper
  DEFAULT_TIME = 1200
  # Put this into a rake task that runs at 10:30 every day
  #
  # Methods
  # match_by_type - matches up to four users of same food type pref(erence)
  # match_by_time - matches from a pool of users (default: all) with compatible times
  # Both require to be matched to existing user
  #
  # match_remainder - puts all remaining users into groups
  # fill_groups(M) - fills all groups that are too small
  # distribute_remaining(M) - puts remaining
  #
  # assign_venues - assigns venues and times to groups
  # get_venue(M) - returns a random venue object that matches type and distance prefs
  #
  # check_full - Checks all groups, destroys those not filled
  # redistribute_all - Takes all non-matched users and puts them in groups
  #

  include HelperHelper
  def match_by_type id, group_id, going_out
    # id is id of user being matched
    # Finds all users matching food type, discards non-compatible times
    # Create group of up to 4 (preference given to similar distance)
    # Sets matched to true
    # If going out, finds place
    users = []
    @user = User.find id
    type = @user.foodtype
    if User.where("foodtype = ? AND going_out = ? AND matched", type, going_out, false)
      users.push(User.where("foodtype = ? AND going_out = ? AND matched", type, going_out, false))
    end
    if users.any
      match_by_time(id, users, going_out)
    end
  end
  def match_by_time id, group_id, pool, going_out 
    # Finds all with matching times from users with prefs.
    # Creates group of up to 4 (pref to distance match), sets matched to true
    # If going out, finds place
    if pool.any
      # There is a limited amount of users to select from
    else
      # Searches all users
      pool = User.where("going_out = ? AND matched AND has_pref", going_out, false, true)
    end
    pool.each do |user|
      if users.find_by_group_id(group_id).length >= 4
        break
      else
        add_user_to_group(id, group_id)
      end
    end

    # Save time constraints for group

  end

  ############################################
  #### Matching those without prefs   ########
  ############################################
  def match_remainder going_out
    # Puts remaining users in groups of 4, then distributes remainder (max 3)
    # Ignores prefs, if any

    fill_groups going_out
    users = User.where("matched = ? AND going_out = ?", false, going_out)
    while users.length >= 4
      @group = create_group
      users[0..3].each do |user|
        add_user_to_group user.id, @group.id
      end
      
      users = User.where("matched = ? AND going_out = ?", false, going_out)
    end
    distribute_remaining going_out
  end
  
  

  ############################################
  #######   Setting up Group meeting   #######
  ############################################
  def assign_venues
    groups = Group.all
    groups.each do |group|
      if group.end.nil? or group.end > DEFAULT_TIME + 100
        meet_time = DEFAULT_TIME
      elsif group.start < group.end - 100
        meet_time = group.end - 100
      else
        meet_time = group.start
      end
      @venue = get_venue(group.foodtype, group.dist)
      group.venue_id = @venue.id
      group.save
    end
  end
  

  def check_full 
    # Checks if all groups are full. Redistributes those that aren't
    # Going out is not pertinent
    Group.all.each do |group|
      if group.users.length < 4
        group.users.each do |user|
          user.matched = false
          user.accepted = false
          user.group_id = nil
          user.save
        end
        group.destroy!
      end
    end
  end
  def redistribute_all going_out
    # Redistributes all users in that category
    users = User.where("matched = ? AND going_out = ?", false, going_out)
    while users and users.length >= 4
      @group = create_group
      filled = false
      users.each do |user|
        if @group.users and @group.users.length >= 4
          filled = true
          break
        else
          @group = create_group
          add_user_to_group user.id, @group.id
          users = User.where("matched = ? AND going_out = ?", false, going_out)
        end
      end
    end
    counter = 20
    while users and users.length >= 1 and counter < 20
      Group.each do |group|
        if group.users.length < 6
          add_user_to_group users[0].id, @group.id
        end
      end
      counter+=1 # Necessary if not enough groups to fill.
    end
  end
end
