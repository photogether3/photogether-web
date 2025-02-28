class Api::V1::UserController < Api::ApplicationApiController
  before_action :authenticate_user!, except: [ :is_email_taken, :update_password_by_otp ]
  before_action :ensure_valid_email, only: [ :is_email_taken ]

  def is_email_taken
    user = User.find_by(email_address: params[:email])
    render json: { is_duplicated: !user.nil? }, status: :ok
  end

  def show
    puts "User show"
    puts @current_user.inspect
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
