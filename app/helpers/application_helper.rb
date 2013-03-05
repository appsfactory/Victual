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
  # fill_groups - fills all groups that are too small
  # distribute_remaining - puts remaining
  #
  # assign_venues - assigns venues and times to groups
  # get_venue - returns a random venue object that matches type and distance prefs
  #
  # TO DO
  # redistributions - handling groups that are too small
  #

  def match_by_type id, group_id, going_out
    # id is id of user being matched
    # Finds all users matching food type, discards non-compatible times
    # Create group of up to 4 (preference given to similar distance)
    # Sets matched to true
    # If going out, finds place
    users = []
    @user = User.find id
    type = @user.type
    if User.where("type = ? AND going_out = ? AND matched", type, going_out, false)
      users.push(User.where("type = ? AND going_out = ? AND matched", type, going_out, false))
    end
    if users.any
      match_by_time(id, users, type)
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
      pool = User.where("going_out = ? AND matched AND has_pref", going_out, false, true))
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
    users = Users.where("matched = ? AND going_out = ?", false, going_out)
    while users.length >= 4
      @group = create_group
      users[0..3].each do |user|
        
      end
      
      users = Users.where("matched = ? AND going_out = ?", false, going_out)
    end
    distribute_remaining going_out
  end
  def fill_groups going_out
    # Find available groups
    # Doesn't match time (yet)
    users = Users.where("matched = ? AND going_out = ?", false, going_out)
    Group.all.each do |group|
      while group.users.length < 4
        while !users.nil?
          ## Possible Error when users is no longer array
          add_user_to_group(users[0].id, group_id)          
          users = Users.where("matched = ? AND going_out = ?", false, going_out)
        end
      end
    end
  end
  def distribute_remaining going_out
    # Find available groups
    # Doesn't match time (yet)
    users = Users.where("matched = ? AND going_out = ?", false, going_out)
    while !users.nil?
      Group.all.each do |group|
        if group.users.length < 6
          add_user_to_group(users[0].id, group_id)
          users = Users.where("matched = ? AND going_out = ?", false, going_out)
        end
      end
    end
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
      @venue =  = get_venue(group.type, group.dist)
      group.venue_id = @venue.id
      group.save
    end
  end
  def get_venue type, dist
    # Gets a restaurant matching food type
    # Each type must have TWO OR MORE venues, or else an error will occur
    if type == "any"
      venues = Venue.where("type != fastfood")
      return venues[Random.rand(venues.length)]
    else
      venues = Venue.find_by_type type
      return venues[Random.rand(venues.length)]
    end
  end

  def check_full 
    # Checks if all groups are full. Redistributes those that aren't
    # Going out is not pertinent
    Groups.each do |group|
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
    users = Users.where("matched = ? AND going_out = ?", false, going_out)
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
          users = Users.where("matched = ? AND going_out = ?", false, going_out)
        end
      end
    end
    counter = 20
    while users and users.length >= 1 and counter < 20
      Groups.each do |group|
        if group.users.length < 6
          add_user_to_group users[0].id, @group.id
        end
      end
      counter++ # Necessary if not enough groups to fill.
    end
  end

  def add_user_to_group id, group_id
    @group = Group.find(group_id)
    @user = User.find(id)
    if @user.end > @group.start + 100 or @user.start < @group.end - 100
      # Gives half an hour for fast food or an hour for normal
      if ((@user.start < @group.end - 50 or @user.end > @group.start + 50 and type = "fast") 
          or user.start < @group.end - 100 or user.end > @group.start + 100)

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
