class Admin::LogsController < Admin::AdminController
  def index
    @log_types = [ "production", "development" ]
    @current_log = params[:log_type] || "application"
    @lines_count = params[:lines] || 100

    @log_content = fetch_log_content(@current_log, @lines_count.to_i)
    @log_entries = parse_log_content(@log_content)

    # 필터링
    @log_level = params[:log_level]
    if @log_level.present? && @log_level != "all"
      @log_entries = @log_entries.select { |entry| entry[:level]&.downcase == @log_level.downcase }
    end

    @search_query = params[:query]
    if @search_query.present?
      @log_entries = @log_entries.select { |entry| entry[:message].include?(@search_query) }
    end

    respond_to do |format|
      format.html
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace("log_entries",
          partial: "admin/logs/log_entries",
          locals: { log_entries: @log_entries }
        )
      end
    end
  end

  private

  def fetch_log_content(log_type, lines_count = 100)
    log_file = case log_type
    when "production"
        Rails.root.join("log", "production.log")
    when "development"
        Rails.root.join("log", "development.log")
    when "test"
        Rails.root.join("log", "test.log")
    else
        Rails.root.join("log", "#{Rails.env}.log")
    end

    if File.exist?(log_file)
      # tail 명령어를 사용해 로그 파일의 마지막 n줄을 가져옴
      `tail -n #{lines_count} #{log_file}`
    else
      "로그 파일이 존재하지 않습니다: #{log_file}"
    end
  end

  def parse_log_content(content)
    lines = content.split("\n")
    entries = []

    current_entry = nil

    lines.each do |line|
      # 새로운 로그 엔트리의 시작을 감지
      if line.match(/^\[\d{4}-\d{2}-\d{2}/) || line.match(/^Started/) || line.match(/^Processing/)
        # 이전 엔트리가 있으면 저장
        entries << current_entry if current_entry

        # 로그 레벨 추출
        level = if line.include?("INFO")
          "info"
        elsif line.include?("WARN") || line.include?("WARNING")
          "warning"
        elsif line.include?("ERROR") || line.include?("FATAL")
          "error"
        elsif line.include?("DEBUG")
          "debug"
        else
          "info" # 기본값
        end

        # 타임스탬프 추출 - 초까지 포함
        timestamp = line.match(/^\[(\d{4}-\d{2}-\d{2}\s\d{2}:\d{2}:\d{2}(\.\d+)?)\s/)&.[](1) ||
                    Time.now.strftime("%Y-%m-%d %H:%M:%S")

        current_entry = {
          timestamp: timestamp,
          level: level,
          message: line
        }
      elsif current_entry
        # 현재 엔트리에 줄 추가
        current_entry[:message] += "\n#{line}"
      end
    end

    # 마지막 엔트리 추가
    entries << current_entry if current_entry

    # 최신 로그가 먼저 표시되도록 역순으로 정렬
    entries.reverse
  end
end
