class ProcessImageVariantsJob < ApplicationJob
  queue_as :default

  def perform(post_id)
    post = Post.find(post_id)
    return unless post.image.attached?

    # 재시도 로직 포함
    3.times do |attempt|
      begin
        post.image.variant(:blur).processed
        post.image.variant(:grid).processed
        post.image.variant(:detail).processed
        Rails.logger.info("게시물 #{post_id}의 이미지 변형 처리 완료 (시도: #{attempt + 1})")
        break  # 성공하면 루프 종료
      rescue ActiveStorage::FileNotFoundError
        Rails.logger.warn("게시물 #{post_id}의 이미지 파일을 찾을 수 없음, 재시도 중... (시도: #{attempt + 1})")
        sleep(1)  # 1초 대기 후 재시도
      end
    end
  rescue => e
    Rails.logger.error("게시물 #{post_id}의 이미지 변형 처리 중 오류 발생: #{e.message}")
  end
end
