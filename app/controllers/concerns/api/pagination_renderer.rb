module Api
  module PaginationRenderer
    extend ActiveSupport::Concern

    # 페이지네이션 파라미터 추출
    def pagination_params
      {
        page: params[:page] ||= 1,
        per_page: params[:perPage] ||= 10,
        sort_order: params[:sortOrder] ||= "desc",
        sort_by: params[:sortBy] ||= "created_at"
      }
    end

    # 페이지네이션 메타데이터와 아이템 목록을 포함한 데이터 구조 생성
    def paginated_response_for(collection)
      # 페이지네이션 메타데이터 추출
      pagination_metadata = {
        per_page: collection.limit_value,
        total_item_count: collection.total_count,
        total_page_count: collection.total_pages,
        current_page: collection.current_page
      }

      # 블록이 제공된 경우 각 아이템에 대해 블록 실행
      items = if block_given?
                collection.map { |item| yield(item) }
      else
                collection
      end

      # 데이터 구조 반환
      pagination_metadata.merge(items: items)
    end
  end
end
