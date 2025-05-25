class Pages::SessionController < PagesController
  def index
    credentials = flash[:credentials] || nil
    render Pages::Session::Login.new(credentials: credentials)
  end

  def login
    unless
      params.dig(:credentials, :email).present? &&
      params.dig(:credentials, :password).present?
      flash[:credentials] = credentials_params
      flash[:alert] = "아이디 또는 비밀번호를 입력해 주세요"
      return redirect_to session_login_path, status: :see_other
    end

    user = User.find_by(email_address: credentials_params[:email])
    puts user.inspect
    if user.nil?
      flash[:credentials] = credentials_params
      flash[:alert] = "아이디 또는 비밀번호가 틀렸습니다."
      return redirect_to session_login_path, status: :see_other
    end

    if !user.authenticate(credentials_params[:password])
      flash[:credentials] = credentials_params
      flash[:alert] = "아이디 또는 비밀번호가 틀렸습니다."
      return redirect_to session_login_path, status: :see_other
    end

    flash[:notice] = "로그인에 성공하였습니다."
    redirect_to session_login_path, status: :see_other
  end

  private

  def credentials_params
    params.require(:credentials).permit(:email, :password)
  end
end
