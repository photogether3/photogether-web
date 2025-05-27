class UpdatePasswordToUsers < ActiveRecord::Migration[8.0]
  def change
    # password_digest 컬럼에서 NOT NULL 제약 조건 제거
    change_column_null :users, :password_digest, true

    # provider 컬럼에 기본값 설정 (기존 사용자는 'email'로 간주)
    change_column_default :users, :provider, 'email' unless column_exists?(:users, :provider)
  end
end
