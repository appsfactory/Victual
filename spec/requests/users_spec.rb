require 'spec_helper'
require 'capybara'
require 'rspec-rails'
require 'user'

describe User do

	before :each do
	    @user = User.new
	    @user.email = "Email@email.com"
	    @user.name = "Name"
	end

	describe "user" do
		it { should respond_to(:name) }
		it { should respond_to(:email) }
	end

  it "should throw error messages" do
    user2 = User.new(:email => "Email").should_not be_valid
    user2 = User.new(:email => "Email@email.com").should_not be_valid
  end

end

describe 'Users' do

  describe "Sign Up" do

    it "should have the content 'Advanced Options'" do
      visit '/'
      page.should have_content('Advanced')

    end
    it 'should have a working form' do
    	visit '/'
    	fill_in "Email",	with: "Example User"
    	expect { click_button "Go Out" }.not_to change(User, :count)

      fill_in "Email",  with: "email@email.com"
      fill_in "Name", with: "name"
      expect { click_button "Go Out" }.to change(User, :count)

    end

  end
end
