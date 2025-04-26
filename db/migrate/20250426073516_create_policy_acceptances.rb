class CreatePolicyAcceptances < ActiveRecord::Migration[8.0]
  def change
    create_table :policy_acceptances do |t|
      t.references :user, null: false, foreign_key: true   # 정책에 동의한 사용자 ID (users 테이블 참조)
      t.references :policy, null: false, foreign_key: true # 동의한 정책의 ID (policies 테이블 참조)
      t.datetime :accepted_at, null: false                 # 사용자가 정책에 동의한 정확한 일시
      t.string :ip_address                                 # 동의 당시 사용자의 IP 주소 (법적 증거용)
      t.string :user_agent                                 # 동의 당시 사용자의 브라우저/기기 정보

      t.timestamps                                         # created_at, updated_at 자동 생성
    end

    add_index :policy_acceptances, [ :user_id, :policy_id ], unique: true  # 한 사용자가 특정 정책에 한 번만 동의할 수 있도록 제약
  end
end
