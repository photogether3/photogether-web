class BaseUseCase
  Result = Struct.new(:success?, :data, :error_message)

  private

    def success(data = nil)
      Result.new(true, data, nil)
    end

    def failure(message)
      Result.new(false, nil, message)
    end
end
