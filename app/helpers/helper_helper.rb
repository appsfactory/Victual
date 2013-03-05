module HelperHelper
  require 'application_controller'
  def fill_groups going_out
    # Find available groups
    # Doesn't match time (yet)
    users = User.where("matched = ? AND going_out = ?", false, going_out)
    Group.all.each do |group|
      while group.users.length < 4
        while users and users.length >= 1
          ## Possible Error when users is no longer array
          add_user_to_group(users[0].id, group.id)          
          users = User.where("matched = ? AND going_out = ?", false, going_out)
        end
      end
    end
  end
  def distribute_remaining going_out
    # Find available groups
    # Doesn't match time (yet)
    users = User.where("matched = ? AND going_out = ?", false, going_out)
    while users and users.length >= 1 and users[0]
      full = true
      if Group.all and Group.all.length >= 1
        Group.all.each do |group|
          if group.users.length < 6 and users[0]
            full = false
            add_user_to_group(users[0].id, group.id)
            users = User.where("matched = ? AND going_out = ?", false, going_out)
          end
        end
      else
        @group = create_group
        users.each do |user|
          add_user_to_group user.id, @group.id
        end
        break
      end
      if full
        break
      end
    end
  end
  def get_venue type, dist
    # Gets a restaurant matching food type
    # Each type must have TWO OR MORE venues, or else an error will occur
    if type == "any"
      venues = Venue.where("foodtype != 'fastfood'")
      return venues[Random.rand(venues.length)]
    else
      venues = Venue.find_by_foodtype type
      return venues[Random.rand(venues.length)]
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
        if @group.foodtype = "any" and @user.foodtype != "any"
          @group.foodtype = @user.foodtype
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
    @group.foodtype = "any"
    @group.dist = 1000
    @group.start = 1100
    @group.end = 1500
    @group.save
    return @group
  end
end
