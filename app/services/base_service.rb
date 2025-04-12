class BaseService
  Result = Struct.new(:success?, :failure?, :data, :error_message)

  private

    def success(data = nil)
      Result.new(true, false, data, nil)
    end

    def failure(message)
      Result.new(false, true, nil, message)
    end
end
