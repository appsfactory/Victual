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
  
  def lateconfirm(user)
    @user = user
    mail(to: user.email, subject: 'You set a lunch with Victual Matching')
  end
  def tomorrow(user)
    @user = user
    mail(to: user.email, subject: 'You set a lunch with Victual Matching for tomorrow')
  end
  def adduser(user, newuser)
    @user = newuser
    mail(to: user.email, subject: 'Someone has joined your group')
  end
  def updateoptions(user)
    @user = user
    mail(to: user.email, subject: 'You have updated your options for Victual')
  end
end
