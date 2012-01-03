class UserMailer < ActionMailer::Base
  default :from => "hjoly@chenous.com"
  
  def follower_notification(user)
    @user = user
    attachments["rails.png"] = File.read("#{Rails.root}/app/assets/images/rails.png")
    mail(:to => "#{user.name} <#{user.email}>", :subject => "You have a new follower")
  end
end
