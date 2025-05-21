class RemoveColumnsFromPolicyAcceptances < ActiveRecord::Migration[8.0]
  def change
    remove_column :policy_acceptances, :ip_address, :string
    remove_column :policy_acceptances, :user_agent, :string
  end
end
