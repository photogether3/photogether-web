class Pages::SessionController < PagesController
  before_action :authenticate_user, except: [ :index, :login ]

  helper_method :current_user

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

    session[:user_id] = user.id
    flash[:notice] = "로그인에 성공하였습니다."
    redirect_to "/users/me", status: :see_other
  end

  def logout
    session.delete(:user_id)
    flash[:notice] = "로그아웃 되었습니다."
    redirect_to "/", status: :see_other
  end

  private

  def credentials_params
    params.require(:credentials).permit(:email, :password)
  end

  # 현재 로그인된 사용자 반환
  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  # 로그인 필요 액션 검사
  def authenticate_user
    unless current_user
      flash[:alert] = "로그인이 필요한 서비스입니다."
      redirect_to session_login_path, status: :see_other
      return false
    end
    true
  end
end
