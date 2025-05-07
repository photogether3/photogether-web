class Admin::LogsController < Admin::AdminController
  def index
    # 환경(production, development) 목록
    @environments = [ "production", "development" ]
    @current_env = params[:env] || Rails.env

    # 해당 환경의 날짜별 로그 파일 목록 가져오기
    @log_dates = available_log_dates(@current_env)

    # 현재 선택된 날짜 (기본값: 오늘 또는 가장 최근 로그)
    @current_date = params[:date] || @log_dates.first || Date.current.to_s

    @lines_count = params[:lines] || 100

    # 선택된 날짜 및 환경의 로그 가져오기
    @log_content = fetch_log_content(@current_env, @current_date, @lines_count.to_i)
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

  # 특정 환경에서 사용 가능한 로그 날짜 목록 조회
  def available_log_dates(env)
    log_dir = Rails.root.join("log", env)

    return [] unless Dir.exist?(log_dir)

    # 날짜별 로그 파일 패턴에 맞는 파일 찾기
    log_files = Dir.glob(File.join(log_dir, "*.log"))

    # 파일명에서 날짜 부분만 추출하여 정렬 (최신 날짜가 먼저 오도록)
    dates = log_files.map do |file|
      filename = File.basename(file, ".log")
      # YYYY-MM-DD 형식의 날짜만 포함
      filename if filename =~ /^\d{4}-\d{2}-\d{2}$/
    end.compact

    # 날짜 기준 내림차순 정렬 (최신 날짜가 먼저)
    dates.sort.reverse
  end

  def fetch_log_content(env, date, lines_count = 100)
    log_file = Rails.root.join("log", env, "#{date}.log")

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
    is_api_request = false  # API 요청인지 추적하는 플래그

    lines.each do |line|
      # 새로운 로그 엔트리의 시작을 감지
      if line.match(/^Started/) ||
        (line.match(/^\[\d{4}-\d{2}-\d{2}/) && !line.match(/Processing/) && !line.match(/Parameters/) && !line.match(/Completed/))

        # 이전 엔트리가 있고 API 요청인 경우에만 저장
        entries << current_entry if current_entry && is_api_request

        # 새 로그 항목 시작 - API 요청 여부 초기화
        is_api_request = false

        # 새 엔트리 생성
        current_entry = {
          timestamp: extract_timestamp(line),
          level: "info",  # 기본값
          message: line,
          raw_content: line
        }
      elsif current_entry
        # 현재 엔트리에 줄 추가
        current_entry[:message] += "\n#{line}"
        current_entry[:raw_content] += "\n#{line}"

        # API 요청인지 확인
        if line.include?("Processing by Api")
          is_api_request = true
        end
      end
    end

    # 마지막 엔트리 추가 (API 요청인 경우에만)
    entries << current_entry if current_entry && is_api_request

    # 각 엔트리의 전체 내용을 검사
    entries.each do |entry|
      full_content = entry[:raw_content]

      # 로그 레벨 분석 - 우선순위 순서대로
      if full_content =~ /\b(ERROR|FATAL)\b/i
        entry[:level] = "error"
      elsif full_content =~ /\b(WARN|WARNING)\b/i
        entry[:level] = "warning"
      elsif full_content =~ /\bDEBUG\b/i
        entry[:level] = "debug"
      end

      # HTTP 상태 코드 기반 분석
      if full_content =~ /Completed (\d+)/
        status_code = $1.to_i
        if status_code >= 500 && entry[:level] != "error"
          entry[:level] = "error"
        elsif status_code >= 400 && entry[:level] == "info"
          entry[:level] = "warning"
        end
      end

      # raw_content는 더 이상 필요 없음
      entry.delete(:raw_content)
    end

    # 최신 로그가 먼저 표시되도록 역순으로 정렬
    entries.reverse
  end

  # 타임스탬프 추출을 위한 헬퍼 메소드
  def extract_timestamp(line)
    # 표준 Rails 로그 형식에서 타임스탬프 추출
    if match = line.match(/at\s(\d{4}-\d{2}-\d{2}\s\d{2}:\d{2}:\d{2})/)
      match[1]
    # 커스텀 로그 형식에서 타임스탬프 추출
    elsif match = line.match(/^\[(\d{4}-\d{2}-\d{2}\s\d{2}:\d{2}:\d{2}(\.\d+)?)\s/)
      match[1]
    else
      Time.now.strftime("%Y-%m-%d %H:%M:%S")
    end
  end
end
