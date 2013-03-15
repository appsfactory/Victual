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
          puts group.users.length
          puts User.where("group_id = ?", group.id)
          puts group.attributes
          puts group.users
          add_user_to_group(users[0].id, group.id)    
          puts users[0].group      
          users = User.where("matched = ? AND going_out = ?", false, going_out).order('dist asc').limit(6)
        end
      end
    end
  end
  def distribute_remaining going_out
    # Find available groups
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
          if @group.users.length >= 4
            break
          end
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
    # Add mail stuff here. If group.notified == true, send update on new member.
    @group = Group.find(group_id)
    @user = User.find(id)
    # Gives half an hour for fast food and packed lunch or an hour for normal
    if (((@user.start < @group.end - 50 or @user.end > @group.start + 50) and (@user.foodtype == "fastfood" or @user.going_out == false)) or 
        @user.start < @group.end - 100 or @user.end > @group.start + 100)
      puts "Adding user " + @user.name + " to " + @group.id.to_s

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
      if @group.notified == true
        @group.users.each do |user|
          UserMailer.adduser(user, @user).deliver
        end
        # Send notifying mail. Notifies all users in group (the new one hasn't been added yet)
      end
      @user.group_id = group_id
      @user.matched = true
      @user.save
    end
  end
  def add_user_to_group_nocheck id, group_id
    # This is for joining an existing group.
    @group = Group.find(group_id)
    @user = User.find(id)
    
    puts "Adding user " + @user.name + " to " + @group.id.to_s

    @group.save
    if @group.notified == true
      @group.users.each do |user|
        UserMailer.adduser(user, @user).deliver
      end
      # Send notifying mail. Notifies all users in group (the new one hasn't been added yet)
    end
    @user.group_id = group_id
    @user.matched = true
    @user.save
  end

  def create_group going_out
    @group = Group.new
    @group.foodtype = "any"
    @group.dist = 1000
    @group.start = 1100
    @group.end = 1500
    @group.going_out = going_out
    @group.notified = false
    @group.save
    return @group
  end
end
