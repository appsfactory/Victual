class UsersController < ApplicationController
  def new
  	@user = User.new
  end

  def create
    @user = User.new(params[:user])
    puts '---- TYPE HERE ----'
    puts params[:commit]
    
    if params[:out] == 'Go Out'
         @user.going_out = true
    else
        @user.going_out = false
    end

    if !@user.timeStart.nil?
      if @user.timeStart[1] == ':'
        temp = @user.timeStart[0] + @user.timeStart[2] + '0'
      else
        temp = @user.timeStart[0..1] + @user.timeStart[3]
      end
      if temp[-1] == '3'
        temp[-1] = '5'
      end
        temp = temp + '0'
        @user.start = temp.to_f

      if @user.timeEnd[1] == ':'
        temp = @user.timeEnd[0] + @user.timeEnd[2]
      else
        temp = @user.timeEnd[0..1] + @user.timeEnd[3]
      end
      if temp[-1] == '3'
        temp[-1] = '5'
      end
        temp = temp + '0'
        @user.end = temp.to_f
    end

    if @user.dist != 'Any'
      if @user.dist[2] == '5'
        @user.dist = 5 
      else 
        @user.dist = 10
      end
    else 
      @user.dist = 'any'
    end

    if @user.save 
      UserMailer.confirmation(@user).deliver
    	redirect_to '/'
    else 
    	redirect_to '/'
    end
  end

end
