module ViteHelper
  # Vite 매니페스트에서 엔트리 파일 정보 가져오기
  def vite_manifest
    @vite_manifest ||= begin
      manifest_path = Rails.root.join("public/builds/.vite/manifest.json")
      if File.exist?(manifest_path)
        JSON.parse(File.read(manifest_path))
      else
        {}
      end
    end
  end

  # JS 파일 태그 생성
  def vite_javascript_tag(entry_point)
    entry_point = "app/assets/#{entry_point}" unless entry_point.start_with?("app/assets/")
    entry_point += ".js" unless entry_point.end_with?(".js")

    if !Rails.env.production? && ENV["VITE_DEV_SERVER"] == "true"
      # 개발 서버 모드
      return javascript_include_tag("http://localhost:5173/#{entry_point}")
    end

    if entry = vite_manifest[entry_point]
      javascript_include_tag("/builds/#{entry['file']}", type: "module")
    else
      raise "Vite entry point '#{entry_point}' not found in manifest"
    end
  end

  # CSS 파일 태그 생성
  def vite_stylesheet_tag(entry_point)
    entry_point = "app/assets/#{entry_point}" unless entry_point.start_with?("app/assets/")
    entry_point += ".js" unless entry_point.end_with?(".js")

    if !Rails.env.production? && ENV["VITE_DEV_SERVER"] == "true"
      # 개발 서버 모드의 경우 JS가 CSS를 로드함
      return ""
    end

    if entry = vite_manifest[entry_point]
      if entry["css"] && entry["css"].any?
        entry["css"].map do |file|
          stylesheet_link_tag("/builds/#{file}")
        end.join.html_safe
      end
    else
      raise "Vite entry point '#{entry_point}' not found in manifest"
    end
  end

  # JS와 CSS 태그를 한 번에 생성
  def vite_asset_tags(entry_point)
    [
      vite_javascript_tag(entry_point),
      vite_stylesheet_tag(entry_point)
    ].join.html_safe
  end
end
