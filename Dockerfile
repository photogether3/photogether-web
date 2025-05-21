# syntax=docker/dockerfile:1
# check=error=true

ARG RUBY_VERSION=3.3.4
FROM docker.io/library/ruby:$RUBY_VERSION-slim AS base

WORKDIR /rails

# 기본 이미지 설정 - 필수 패키지만 설치
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libjemalloc2 libvips sqlite3 libpq5 && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development"

# 빌드 이미지 설정
FROM base AS build

# 빌드에 필요한 의존성 설치 (Node.js 제거)
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git pkg-config \
    curl ca-certificates libpq-dev && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Ruby 의존성 설치
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

# 프로젝트 파일 복사
COPY . .

# Ruby 코드 사전 컴파일
RUN bundle exec bootsnap precompile app/ lib/

# 에셋 빌드 (Node.js가 필요 없는 경우 이 단계도 제거 가능)
RUN SECRET_KEY_BASE=dummykeythatis32byteslongatleast \
    bin/rails assets:precompile

# 최종 배포 이미지
FROM base

# 운영에 필요한 최소한의 패키지만 설치
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y libpq5 && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# 빌드 이미지에서 필요한 파일만 복사
COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build /rails /rails

# 시스템 사용자 설정 및 권한 부여
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp
USER 1000:1000

# 컨테이너 실행 설정
ENTRYPOINT ["/rails/bin/docker-entrypoint"]
EXPOSE 80
CMD ["./bin/thrust", "./bin/rails", "server"]