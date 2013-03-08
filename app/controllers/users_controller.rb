class UsersController < ApplicationController
  
  def new
  	@user = User.new
  end

  def create
    @user = User.find_by_email(params[:user][:email])
    if @user.nil?
      @user = User.new(params[:user])
    else
      @user.update_attributes(params[:user])
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
    elsif @user.distance.class == String
      puts "Converting dist to num"
      @user.dist = @user.distance[/\d+/].to_i.to_i
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
    # We're not saving, so this is fine
    if @user.save
      UserMailer.confirmation(@user).deliver
    	redirect_to '/'
    else
    	render 'new'
    end
  end
  def decline
    @user = User.find_by_token(params[:token])
    if @user
      @user.accepted = false
      # matched remains true, so user is not auto-reassigned
      @user.group_id = nil
      check_full
      redistribute_all @user.going_out
    else
      render :nothing => true
      # Later, become "error page"
    end
  end

end
