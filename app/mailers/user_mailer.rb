class UserMailer < ApplicationMailer
  def send_otp_email(user)
    @user = user
    mail(
      to: @user.email_address,
      subject: "Your OTP Code"
    )
  end
end
