require 'spec_helper'
require 'capybara'
require 'rspec-rails'

describe UserMailer do
  describe 'confirmation' do
    let(:user) { mock_model(User, :name => 'Farhan', :email => 'farhan@email.com') }
    let(:mail) { UserMailer.confirmation(user) }

    #ensure that the subject is correct
    it 'renders the subject' do
      mail.subject.should == 'You just set a lunch with Victual matching'
    end

    #ensure that the receiver is correct
    it 'renders the receiver email' do
      mail.to.should == [user.email]
    end

    #ensure that the sender is correct
    it 'renders the sender email' do
      mail.from.should == ['cafvictual@gmail.com']
    end

    #ensure that the @name variable appears in the email body
    it 'assigns @name' do
      mail.body.encoded.should match(user.name)
    end

  end
end