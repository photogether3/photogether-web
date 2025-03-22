class Api::V1::VisionApiController < Api::ApplicationApiController
  before_action :authenticate_user!

  def preview
    file = params[:file]
    raise CustomError, "파일은 필수값 입니다." if file.blank?

    lines = VisionService.extract_text_lines(file)

    render json: { lines: lines }, status: :ok
  end
end
