module PaginationConcern
  private

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
