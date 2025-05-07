class Admin::LogsController < Admin::AdminController
  def index
    # 환경(production, development) 목록
    @environments = [ "production", "development" ]
    @current_env = params[:env] || Rails.env

    # 현재 선택된 날짜 (기본값: 오늘)
    @current_date = params[:date] || Date.current.to_s

    # 시간대 선택 (기본값: 현재 시간에 가장 가까운 시간대)
    @time_ranges = generate_time_ranges
    current_hour = Time.now.hour
    default_time_range = "#{current_hour}-#{current_hour + 1}"
    @current_time_range = params[:time_range] || default_time_range

    # 시간대에서 시작/종료 시간 추출
    start_hour, end_hour = @current_time_range.split("-").map(&:to_i)

    puts "선택된 환경: #{@current_env}, 날짜: #{@current_date}, 시간대: #{@current_time_range}"
    puts "시작 시간: #{start_hour}, 종료 시간: #{end_hour}"

    # 선택된 날짜 및 환경의 로그 가져오기
    @log_content = fetch_log_content_by_time(
      @current_env,
      @current_date,
      start_hour,
      end_hour
    )
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

  # 시간대 목록 생성 (1시간 간격)
  def generate_time_ranges
    (0..23).map { |h| "#{h}-#{h + 1}" }
  end

  # 시간대 기반으로 로그 내용 가져오기
  def fetch_log_content_by_time(env, date, start_hour, end_hour, api_only = true)
    log_file = Rails.root.join("log", env, "#{date}.log")

    return "로그 파일이 존재하지 않습니다: #{log_file}" unless File.exist?(log_file)

    # 시간대 형식 준비
    start_hour_fmt = "%02d" % start_hour
    end_hour_fmt = "%02d" % end_hour

    # 로그 파일에서 전체 요청 패턴을 찾아 컨텍스트 유지
    # -A 10은 매치된 줄 이후 10줄을 함께 출력 (로그 항목 하나가 보통 5-10줄)
    api_pattern = api_only ? "Processing by Api|Api::" : ""

    # Started로 시작하는 줄을 찾되, 시간대와 날짜로 필터링
    cmd = "grep -a -B 0 -A 20 'Started.*#{date}.*#{start_hour_fmt}:' #{log_file}"

    # API 요청만 필터링 (옵션)
    if api_only
      cmd = "#{cmd} | grep -a -B 5 -A 15 -E '#{api_pattern}'"
    end

    # 검색어 필터 (있는 경우)
    if @search_query.present?
      escaped_query = @search_query.gsub("'", "\\\\'").gsub('"', '\\"')
      cmd = "#{cmd} | grep -a -B 5 -A 15 -i '#{escaped_query}'"
    end

    puts "로그 검색 명령어: #{cmd}"

    # 명령 실행
    result = `#{cmd}`

    # 결과가 없는 경우 재시도 - 시간대 필터를 넓혀보기
    if result.blank?
      puts "시간대 필터링 결과 없음. 날짜 전체에서 API 로그 검색"

      # 날짜만으로 전체 요청 블록 찾기
      date_cmd = "grep -a -B 0 -A 10 'Started.*#{date}' #{log_file}"

      if api_only
        date_cmd = "#{date_cmd} | grep -a -B 5 -A 15 -E '#{api_pattern}'"
      end

      date_result = `#{date_cmd}`

      if date_result.present?
        puts "날짜 기반 결과 찾음: #{date_result.lines.count}줄"
        return date_result
      else
        puts "날짜 기반 검색 결과 없음. 마지막 100개 요청 반환"
        # 마지막 시도: 전체 로그에서 최근 100개 요청
        tail_cmd = "grep -a -B 0 -A 10 'Started' #{log_file} | tail -n 500"

        if api_only
          tail_cmd = "#{tail_cmd} | grep -a -B 5 -A 15 -E '#{api_pattern}'"
        end

        tail_result = `#{tail_cmd}`

        return tail_result.present? ? tail_result : "로그를 찾을 수 없습니다."
      end
    end

    result
  end

  def parse_log_content(content)
    return [] if content.blank?

    # "Started"로 시작하는 블록으로 로그 분할
    entries = []

    # '--' 구분자를 제거하고 요청 단위로 분리
    content = content.gsub(/--\n/, "")

    # 전체 컨텍스트를 Started 단위로 분리
    chunks = content.split(/^Started /).reject(&:blank?)

    chunks.each do |chunk|
      # Started 접두어 복원
      full_content = "Started " + chunk

      # 공백 정리: 연속된 줄바꿈(\n\n)을 단일 줄바꿈(\n)으로 변경
      full_content = full_content.gsub(/\n{2,}/, "\n")

      # 앞뒤 공백 제거
      full_content = full_content.strip

      # 타임스탬프 추출
      timestamp = extract_timestamp(full_content)

      # 로그 레벨 결정
      level = "info"
      if full_content =~ /\b(ERROR|FATAL)\b/i
        level = "error"
      elsif full_content =~ /\b(WARN|WARNING)\b/i
        level = "warning"
      elsif full_content =~ /\bDEBUG\b/i
        level = "debug"
      end

      # HTTP 상태 코드 기반 분석
      if full_content =~ /Completed (\d+)/
        status_code = $1.to_i
        if status_code >= 500 && level != "error"
          level = "error"
        elsif status_code >= 400 && level == "info"
          level = "warning"
        end
      end

      # API 컨트롤러 확인
      is_api = full_content.include?("Api::") ||
               full_content.include?("Processing by Api") ||
               full_content.include?("api/v1")

      if is_api
        entries << {
          timestamp: timestamp,
          level: level,
          message: full_content
        }
      end
    end

    # 최신 로그가 먼저 표시되도록 역순 정렬
    entries.reverse
  end

  # 기존 코드 유지
  def extract_timestamp(line)
    if match = line.match(/at\s(\d{4}-\d{2}-\d{2}\s\d{2}:\d{2}:\d{2})/)
      match[1]
    elsif match = line.match(/^\[(\d{4}-\d{2}-\d{2}\s\d{2}:\d{2}:\d{2}(\.\d+)?)\s/)
      match[1]
    else
      Time.now.strftime("%Y-%m-%d %H:%M:%S")
    end
  end
end
