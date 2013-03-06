module HelperHelper
  require 'application_controller'
  def fill_groups going_out
    # Find available groups
    # Doesn't match time (yet)
    users = User.where("matched = ? AND going_out = ?", false, going_out).order('dist asc').limit(6)
    groups = (Group.where("going_out = ?", going_out))
    if groups.any? and groups.length >= 1
      groups.each do |group|
        while group.users.length < 4 and users and users.length >= 1
          ## Possible Error when users is no longer array
          add_user_to_group(users[0].id, group.id)          
          users = User.where("matched = ? AND going_out = ?", false, going_out).order('dist asc').limit(6)
        end
      end
    end
  end
  def distribute_remaining going_out
    # Find available groups
    # Doesn't match time (yet)
    users = User.where("matched = ? AND going_out = ?", false, going_out).order('dist asc').limit(6)
    while users and users.length >= 1 and users[0]
      full = true
      groups = Group.where("going_out = ?",going_out)
      if groups and groups.length >= 1
        groups.each do |group|
          if group.users.length < 6 and users[0]
            full = false
            add_user_to_group(users[0].id, group.id)
            users = User.where("matched = ? AND going_out = ?", false, going_out).order('dist asc').limit(6)
          end
        end
      else
        @group = create_group going_out
        users.each do |user|
          add_user_to_group user.id, @group.id
          if @group.users.length >= 4
            break
          end
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
    
    if Venue.first.nil?
      puts "No venues! Add some!"
    end
    if type == "any"
      venues = Venue.where("foodtype != ? AND distance < ?", 'fastfood' , dist)
      if venues.length >= 1
        return venues[Random.rand(venues.length)]
      else
        venues =  Venue.where("foodtype != ?", 'fastfood').order('distance asc')
        puts "Could not find within distance " + dist.to_s
        if venues[0]
          return venues[0]
        else
          return Venue.all[Random.rand(Venue.all.length)]
        end
      end
    else
      venues = Venue.where("foodtype = ? AND distance <= ?", type, dist)
      if venues.length >= 1
        return venues[Random.rand(venues.length)]
      else
        venues =  Venue.where("foodtype = ?", type).order('distance asc')
        if venues[0]
          return venues[0]
        else
          return Venue.all[Random.rand(Venue.all.length)]
        end
      end
    end
  end

  def add_user_to_group id, group_id
    @group = Group.find(group_id)
    @user = User.find(id)
    if @user.end > @group.start + 100 or @user.start < @group.end - 100
      # Gives half an hour for fast food or an hour for normal
      if ((@user.start < @group.end - 50 or @user.end > @group.start + 50 and type == "fastfood") or user.start < @group.end - 100 or user.end > @group.start + 100)

        if @user.start > @group.start
          @group.start = @user.start
        end
        if @user.end < @group.end
          @group.end = @user.end
        end
        if @group.foodtype == "any" and @user.foodtype != "any"
          @group.foodtype = @user.foodtype
        end
        if @group.dist > @user.dist
          @group.dist = @user.dist
        end
        @group.save
        @user.group_id = group_id
        @user.matched = true
        @user.save
        end
    end
  end

  def create_group going_out
    @group = Group.new
    @group.foodtype = "any"
    @group.dist = 1000
    @group.start = 1100
    @group.end = 1500
    @group.going_out = going_out
    @group.save
    return @group
  end
end
