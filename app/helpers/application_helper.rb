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
  def match_by_type id, group_id 
    # id is id of user being matched
    # Finds all users matching food type, discards non-compatible times
    # Create group of up to 4 (preference given to similar distance)
    # Sets matched to true
    # If going out, finds place
    users = []
    @user = User.find id
    type = @user.foodtype
    if User.where("foodtype = ? AND going_out = ? AND matched = ?", type, true, false)
      users = (User.where("foodtype = ? AND going_out = ? AND matched = ?", type, true, false))
    end
    if users.length >= 1
      match_by_time(id, group_id, users,true)
    end
  end
  def match_by_time id, group_id, pool, going_out
    # Finds all with matching times from users with prefs.
    # Creates group of up to 4 (pref to distance match), sets matched to true
    # If going out, finds place
    if pool.length >= 1
      # There is a limited amount of users to select from
    else
      # Searches all users
      pool = User.where("going_out = ? AND matched = ? AND has_pref = ?", going_out, false, true)
    end
    pool.each do |user|
      if Group.find(group_id).users.length >= 4
        break
      else
        add_user_to_group(user.id, group_id)
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
    puts "-------------------------"
    puts "Users in match_remainder"
    puts users
    puts users.length

    while users.length >= 4
      @group = create_group going_out
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
    groups = Group.where("going_out = ?", true)
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
      puts "Group", group.attributes
      if group.users.length < 4
        group.users.each do |user|
          user.matched = false
          user.accepted = false
          user.group_id = nil
          user.save
        end
        group.delete
      end
    end
  end
  def redistribute_all going_out
    # Redistributes all users in that category
    users = User.where("matched = ? AND going_out = ?", false, going_out)
    while users and users.length >= 4
      @group = create_group going_out
      filled = false
      users.each do |user|
        if @group.users and @group.users.length >= 4
          filled = true
          break
        else
          add_user_to_group user.id, @group.id
          puts user.attributes
          users = User.where("matched = ? AND going_out = ?", false, going_out)
        end
      end
    end
    counter = 0
    while users and users.length >= 1 and counter < 20
      @groups = Group.where("going_out = ?", going_out)
      puts @groups
      @groups.each do |group|
        if group.users.length < 6
          puts "Adding to: " + group.id.to_s
          add_user_to_group users[0].id, group.id
          users = User.where("matched = ? AND going_out = ?", false, going_out)
          if users[0].nil?
            break
          end
        end
      end
      counter+=1 # Necessary if not enough groups to fill.
                 # Shouldn't be more than 3 left over users
    end
  end

  def add_user_to_group id, group_id
    @group = Group.find(group_id)
    @user = User.find(id)
    if @user.end > @group.start + 100 or @user.start < @group.end - 100
      # Gives half an hour for fast food or an hour for normal
      if ((@user.start < @group.end - 50 or @user.end > @group.start + 50 and type = "fast") or user.start < @group.end - 100 or user.end > @group.start + 100)

        if @user.start > @group.start
          @group.start = @user.start
        end
        if @user.end < @group.end
          @group.end = @user.end
        end
        if @group.type = "any" and @user.type != "any"
          @group.type = @user.type
        end
        if @group.dist > @user.dist
          @group.dist = @user.dist
        end

        @user.group_id = group_id
        @user.matched = true
        @user.save

      end
    end
  end

  def create_group
    @group = Group.new
    @group.type = "any"
    @group.dist = 1000
    @group.start = 1100
    @group.end = 1500
    @group.save
    return @group
  end
end
