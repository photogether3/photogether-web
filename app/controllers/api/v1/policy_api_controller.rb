class Api::V1::PolicyApiController < ApiController
  # 약관 목록 조회
  def index
    # 활성화된 최신 버전의 정책들만 반환
    policies = Policy.where(is_active: true)
                    .order(id: :asc)
                    .group_by(&:kind)
                    .transform_values { |versions| versions.max_by(&:effective_date) }
                    .values

    render json: policies.map { |policy|
      {
        id: policy.id,
        title: policy.title,
        kind: policy.kind,
        version: policy.version,
        is_required: policy.is_required,
        effective_date: policy.effective_date.iso8601,
        content_preview: truncate_html(policy.content, 100)
      }
    }
  end

  # 특정 약관 상세 조회
  def show
    policy = Policy.find_by(id: params[:id])

    if policy.nil?
      render json: { status: "error", message: "정책을 찾을 수 없습니다." }, status: :not_found
      return
    end

    render json: {
      id: policy.id,
      title: policy.title,
      kind: policy.kind,
      version: policy.version,
      is_required: policy.is_required,
      effective_date: policy.effective_date.iso8601,
      content: policy.content
    }
  end

  private

  # HTML 내용을 일정 길이로 자르는 메서드
  def truncate_html(html, length = 100)
    # HTML 태그를 제거하고 일반 텍스트만 추출
    text = ActionController::Base.helpers.strip_tags(html)
    # 텍스트를 지정된 길이로 자르고 말줄임표 추가
    text.length > length ? "#{text[0...length]}..." : text
  end
end
