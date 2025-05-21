class CreatePolicies < ActiveRecord::Migration[8.0]
  def change
    create_table :policies do |t|
      t.string :title, null: false      # 정책의 제목 (예: '서비스 이용약관', '개인정보처리방침')
      t.string :kind, null: false       # 정책의 종류 구분 ('terms', 'privacy', 'marketing' 등)
      t.text :content, null: false      # 정책의 실제 내용 텍스트
      t.string :version, null: false    # 정책의 버전 정보 (예: '1.0', '2.1')
      t.boolean :is_active, default: true  # 현재 활성화된 정책인지 여부 (최신 버전만 true)
      t.datetime :effective_date, null: false  # 정책이 효력을 발휘하는 시작 날짜

      t.timestamps  # created_at, updated_at 자동 생성 (생성일시, 수정일시)
    end

    add_index :policies, [ :kind, :version ], unique: true  # 정책 종류와 버전의 조합은 유일해야 함
  end
end
