class AddRequiredFieldToPolicies < ActiveRecord::Migration[8.0]
  def change
    add_column :policies, :is_required, :boolean, default: true, null: false
  end
end
