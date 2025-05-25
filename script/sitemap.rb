require 'rubygems'
require 'sitemap_generator'

SitemapGenerator::Sitemap.default_host = 'http://photogether.app'

# 압축 비활성화
SitemapGenerator::Sitemap.compress = false

SitemapGenerator::Sitemap.create do
  # 랜딩 페이지 - 자주 변경될 예정
  add '/', changefreq: 'daily', priority: 0.9
  # 블로그 - 매주 변경되며 중요함
  # add '/blog', changefreq: 'weekly', priority: 0.8
  # 정적 페이지 - 거의 변경되지 않으며 덜 중요함
  # add '/about', changefreq: 'monthly', priority: 0.5
  # 개인정보 처리방침 - 거의 변경되지 않으며 우선순위 낮음
  # add '/privacy', changefreq: 'yearly', priority: 0.3
end

# 구글 사이트맵 핑 기능 지원 중단함, 주석처리
# SitemapGenerator::Sitemap.ping_search_engines
