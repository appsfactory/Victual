class UsersController < ApplicationController
  # All algorithm functions are in the application helper and helper helper. add_user_to_group will add a user 
  # to a group, but checks time contraints first (not garuanteed to add user).

  def new
  	@user = User.new
  end

  def create
    @user = User.find_by_email(params[:user][:email])
    updated = false
    if @user.nil?
      @user = User.new(params[:user])
      flashmessage = "Thanks for signing up for lunch, " + @user.name + ". You'll notified with your group information at " + @user.email + "."
    else
      if @user.matched == true
        flash.error = "Please decline your current matching before changing your options"
        render 'new'
      else
        flashmessage = "Your submission has been updated"
        updated = true
        @user.update_attributes(params[:user])
      end
    end


    @user.has_pref = false
    #Checks to see if the user wants to go out or has a packed lunch
    if params[:out] == 'Go Out'
         @user.going_out = true
    else
        @user.going_out = false
    end
    if @user.foodtype != 'Any'
       @user.has_pref = true
    end
    if @user.foodtype.nil? or @user.foodtype != String
      @user.foodtype = "any"
    end


    #Procedure used to parse time
    parseTime = lambda do |time, temp|
      if time[1] == ':'
        temp = time[0] +time[2]
        temp = temp.to_i
        temp = temp + 120
        temp = temp.to_s
      else
        temp = time[0..1] + time[3]
      end
      if temp[-1] == '3'
        temp[-1] = '5'
      end
      temp = temp + '0'
      temp = temp.to_f
      return temp
    end

    #If the user has preferences for start and end time
    #This block calls parseTime on both the start and end time selected
    if !@user.timeStart.nil?
      @user.start = parseTime.call(@user.timeStart, @user.start)
       @user.has_pref = true
    else
      @user.start = 1100
    end

    if !@user.timeEnd.nil?
      @user.end = parseTime.call(@user.timeEnd, @user.end)
      @user.has_pref = true
    else
      @user.end = 1500
    end

    if @user.distance == 'Any'
      puts "Dist = Any"
      @user.dist = 1000
      # Needs to be int, for comparison with how far away the venue is.
    elsif @user.distance.class == String
      puts "Converting dist to num"
      @user.dist = @user.distance[/\d+/].to_i
    else
      puts "Not a string"
      puts @user.distance.class
      puts @user.distance
      @user.dist = 1001
    end

    @user.matched = false
    @user.accepted = false
    while User.where("token = ?", @user.token) and @user.token.nil?
      @user.token = SecureRandom.urlsafe_base64
    end
    # Validates unique on save
    

    if @user.save
      if Phase.first.nil?
        current_phase = ""
        # this is a major error. Notify admin somehow
      else
        current_phase = Phase.first.current
      end
      if current_phase == "late" # After schedule has been run
        @user.keep = false
        @user.save!
        add_latecomer @user.going_out
        if @user.group.nil?
          flash.alert = flashmessage
          if updated
            UserMailer.updateoptions(@user).deliver
          else
            UserMailer.lateconfirm(@user).deliver
          end
          # Tells them to wait, gives them a link to the decline page, where they can choose any group
        else
          flash.alert = "You have been matched with a group. Please check your mail at " + @user.email
          UserMailer.info(@user).deliver
        end
      elsif current_phase == "toolate"
        @user.keep = true
        @user.matched = true
        # Will be set to matched = false, keep = false, once all other users have been deleted
        @user.save!
        UserMailer.tomorrow(@user).deliver
        flash.alert = "You will be matched for lunch tomorrow"
        # Tells them they will be signed up for tomorrow
      else
        flash.alert = flashmessage
        if updated
         UserMailer.updateoptions(@user).deliver
        else 
          UserMailer.confirmation(@user).deliver
        end
      end
    	redirect_to '/'
    else
    	render 'new'
    end
  end
  def decline
    @user = User.find_by_token(params[:token])
    if @user
      check_full
      # Will break apart group if now less than 4 peoples
      redistribute_all @user.going_out
      @user.accepted = false
      @user.matched = false
      # matched becomes false, so user is can be added to a new group
      @user.group_id = nil
    else
      render :nothing => true
      # Later, become "error page"
    end
  end
  def accept
    @user = User.find_by_token(params[:token])
    if @user
      @user.accepted = true
    end
    # and everyone was happy
  end
  def join_group
    @user = User.find_by_token(params[:token])
    @group = Group.find(params[:group_id])
    if @user and @group
      add_user_to_group_nocheck(@user.id, @group.id)
      UserMailer.info(@user).deliver
      @group.users.each do |user|
        UserMailer.adduser(user, @user).deliver
      end
      redirect_to "/accept?token="+@user.token
    else
      render 'decline'
    end
  end

end
