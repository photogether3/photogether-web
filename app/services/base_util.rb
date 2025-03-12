class BaseUtil
  def self.generate_random_nickname
    prefixes = %w[
      멋진 든든한 귀여운 강력한 재빠른
      화려한 용감한 현명한 활기찬 유쾌한
    ]

    suffixes = %w[
      고래밥 사자 호랑이 독수리 고양이
      강아지 여우 팬더 토끼 공룡
    ]

    random_prefix = prefixes.sample
    random_suffix = suffixes.sample

    "#{random_prefix} #{random_suffix}"
  end

  def self.generate_otp
    # 6자리 숫자 문자열 (100000~999999)
    (100_000 + rand(900_000)).to_s
  end
end
