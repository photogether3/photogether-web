class Api::V1::ImageApiController < Api::ApplicationApiController
  before_action :authenticate_user!

  def preview
    result = Images::GoogleVision
      .new(params[:file])
      .extract_text_lines
    render_result(result)
  end
end
