module ApplicationHelper
  include Heroicon::Engine.helpers

  # 페이지네이션 범위를 계산하는 헬퍼 메소드
  # @param current_page [Integer] 현재 페이지 번호
  # @param total_pages [Integer] 전체 페이지 수
  # @param sibling_count [Integer] 현재 페이지 양쪽에 표시할 페이지 수
  # @param boundary_count [Integer] 시작과 끝에 항상 표시할 페이지 수
  # @return [Array] 표시할 페이지 번호와 구분자("...")의 배열
  def pagination_range(current_page, total_pages, sibling_count = 1, boundary_count = 1)
    # 유효성 검사
    current_page = [ [ current_page, 1 ].max, total_pages ].min

    # 전체 페이지 수가 적으면 모든 페이지 표시
    if total_pages <= (boundary_count * 2) + (sibling_count * 2) + 3
      return (1..total_pages).to_a
    end

    # 결과 배열 초기화
    result = []

    # 왼쪽 경계 페이지
    left_boundary = (1..boundary_count).to_a

    # 오른쪽 경계 페이지
    right_boundary = ((total_pages - boundary_count + 1)..total_pages).to_a

    # 현재 페이지 주변 범위 계산
    sibling_start = [ current_page - sibling_count, boundary_count + 2 ].max
    sibling_end = [ current_page + sibling_count, total_pages - boundary_count - 1 ].min

    # 왼쪽 경계 추가
    result.concat(left_boundary)

    # 왼쪽 경계와 현재 페이지 주변 사이에 공백이 있는지 확인
    if sibling_start > boundary_count + 2
      result << "..."
    elsif sibling_start == boundary_count + 2
      result << boundary_count + 1
    end

    # 현재 페이지 주변 범위 추가
    result.concat((sibling_start..sibling_end).to_a)

    # 현재 페이지 주변과 오른쪽 경계 사이에 공백이 있는지 확인
    if sibling_end < total_pages - boundary_count - 1
      result << "..."
    elsif sibling_end == total_pages - boundary_count - 1
      result << total_pages - boundary_count
    end

    # 오른쪽 경계 추가
    result.concat(right_boundary)

    result
  end
end
