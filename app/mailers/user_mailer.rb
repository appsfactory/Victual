class UserMailer < ActionMailer::Base
  default from: "cafvictual@gmail.com"
  def confirmation(user)
  	@user = user
    mail(to: user.email, subject: 'You just set a lunch with Victual matching')
  end

  def info(user)
  	@user = user
  	mail(to: user.email, subject: 'You Have Been Matched')
  end

  def apology(user)
  	@user = user
  	mail(to: user.email, subject: 'Sorry, You have not Been Matched')
  end
end
