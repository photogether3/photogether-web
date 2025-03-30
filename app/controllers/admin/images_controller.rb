class Admin::ImagesController < Admin::AdminController
  def extract_text
    file = params[:file]
    raise ActionController::BadRequest, "파일은 필수값 입니다." if file.blank?

    lines = VisionService.extract_text_lines(file)

    render json: { lines: lines }, status: :ok
  rescue => e
    render json: { error: e.message }, status: :bad_request
  end
end
