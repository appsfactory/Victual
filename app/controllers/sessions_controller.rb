class SessionsController < ApplicationController

	def new

	end

  def create
  	puts "NAME"
  	puts params[:session][:name]
    if @admin = Admin.find_by_name(params[:session][:name])
      session[:current_admin_id] = @admin.id
      redirect_to '/add'
    else
    	render 'new'
    end
  end

  def destroy
    # Remove the user id from the session
    @_current_admin = session[:current_admin_id] = nil
    redirect_to '/admin'
  end
end
