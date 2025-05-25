require 'rubygems'
require 'sitemap_generator'

SitemapGenerator::Sitemap.default_host = 'http://photogether.app'

# 압축 비활성화
SitemapGenerator::Sitemap.compress = false

SitemapGenerator::Sitemap.create do
  # 랜딩 페이지 - 자주 변경될 예정
  add '/', changefreq: 'daily', priority: 0.9
  # 약관 - 거의 변경되지 않으며 우선순위 낮음
  add '/policies/privacy', changefreq: 'yearly', priority: 0.3
  add '/policies/terms', changefreq: 'yearly', priority: 0.3
  add '/policies/data-deletion', changefreq: 'yearly', priority: 0.3
end

# 구글 사이트맵 핑 기능 지원 중단함, 주석처리
# SitemapGenerator::Sitemap.ping_search_engines
