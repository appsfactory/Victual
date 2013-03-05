class UserMailer < ActionMailer::Base
  default from: "cafvictual@gmail.com"
  def confirmation(user)
  	@user = user
    mail(to: user.email, subject: 'You just set a lunch with Victual matching')
  end
end
