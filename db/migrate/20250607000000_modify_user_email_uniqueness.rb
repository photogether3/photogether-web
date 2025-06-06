class ModifyUserEmailUniqueness < ActiveRecord::Migration[8.0]
  def up
    # 기존 email_address 유니크 인덱스 제거
    remove_index :users, :email_address

    # 기존 provider 컬럼의 기본값이 없을 경우 설정
    unless column_exists?(:users, :provider)
      add_column :users, :provider, :string, default: 'email'
    else
      # 이미 존재하는 사용자 중 provider가 null인 경우 'email'로 설정
      execute "UPDATE users SET provider = 'email' WHERE provider IS NULL"
      change_column_default :users, :provider, 'email'
    end

    # provider + email_address 복합 유니크 인덱스 추가
    add_index :users, [ :provider, :email_address ], unique: true
  end

  def down
    # provider + email_address 복합 유니크 인덱스 제거
    remove_index :users, [ :provider, :email_address ]

    # 다시 email_address만으로 유니크 인덱스 추가
    add_index :users, :email_address, unique: true
  end
end
