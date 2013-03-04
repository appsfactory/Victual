class UsersController < ApplicationController
  def new
  	@user = User.new
  end

  def create
    @user = User.new(params[:user])
    if @user.save 
    	redirect_to '/'
    else 
    	redirect_to '/'
    end

  end

end
