class CustomError < StandardError
  def initialize(message = nil)
    super(message)
  end
end
