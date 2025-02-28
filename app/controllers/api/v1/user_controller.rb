class Api::V1::UserController < Api::ApplicationApiController
  def is_email_taken
    puts "User is email taken"
  end

  def show
    puts "User show"
  end

  def update
    puts "User update"
  end

  def update_password_by_otp
    puts "User update password by otp"
  end

  def update_password
    puts "User update password"
  end

  def reset_data
    puts "User update reset data"
  end

  def destroy
    puts "User destroy"
  end
end
