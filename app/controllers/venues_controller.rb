class VenuesController < ApplicationController
	def new
		@venue = Venue.new
	end

	def create
	@venue = Venue.new(params[:venue])
		if @venue.distString != 'Other'
	      if @venue.distString[2] == '5'
	        @venue.distance = 5
	      else
	        @venue.distance = 10
	      end
	  else
	      @venue.distance = 1000
	  end

    if @venue.save!
    	redirect_to '/venues'
    else
    	redirect_to '/add'
    end
	end
	def index
		@venue = Venue.find_by_id(1)
	end

end
