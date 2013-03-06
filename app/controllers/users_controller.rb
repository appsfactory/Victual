class UsersController < ApplicationController
  def new
  	@user = User.new
  end

  def create
    @user = User.new(params[:user])

    #Checks to see if the user wants to go out or has a packed lunch
    if params[:out] == 'Go Out'
         @user.going_out = true
    else
        @user.going_out = false
    end
    if @user.foodtype != 'Any' or @user.timeStart == String or @user.distance == String
       @user.has_pref = true
    else
      @user.has_pref = false
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
    if !@user.timeStart.nil? && !@user.timeEnd.nil?

      @user.start = parseTime.call(@user.timeStart, @user.start)
      @user.end = parseTime.call(@user.timeEnd, @user.end)
      @user.has_pref = true

    else
      @user.start = 1100
      @user.end = 1500
    end

    if @user.dist == 'Any'
      @user.dist = 1000
    elsif @user.dist == String
      @user.dist = @user.dist.to_i
    else
      @user.dist = 1000
    end

    @user.matched = false
    @user.accepted = false

    if @user.save
      UserMailer.confirmation(@user).deliver
    	redirect_to '/'
    else
    	redirect_to '/'
    end
  end

end
