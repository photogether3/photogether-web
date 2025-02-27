class CustomException < StandardError
  attr_reader :error_code, :code, :message

  def initialize(error_code, code, message)
    @error_code = error_code
    @code = code
    @message = message
  end
end
