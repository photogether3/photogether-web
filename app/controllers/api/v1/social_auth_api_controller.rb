class Api::V1::SocialAuthApiController < ApiController
  def register
    result = User::SocialRegister.new(params).call
    render_result(result, success_status: :created)
  end
end
