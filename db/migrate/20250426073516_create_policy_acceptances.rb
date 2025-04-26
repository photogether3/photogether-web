class CreatePolicyAcceptances < ActiveRecord::Migration[8.0]
  def change
    create_table :policy_acceptances do |t|
      t.references :user, null: false, foreign_key: true
      t.references :policy, null: false, foreign_key: true
      t.datetime :accepted_at, null: false
      t.string :ip_address
      t.string :user_agent

      t.timestamps
    end

    add_index :policy_acceptances, [ :user_id, :policy_id ], unique: true
  end
end
