class UserMailer < ApplicationMailer
  def send_otp_email(user)
    @user = user
    mail(
      to: @user.email_address,
      subject: "Your OTP Code",
      template_path: "shared/mailers/user_mailer"
    )
  end
end
