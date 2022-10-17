class AddPolicyUrlToUsePolicies < ActiveRecord::Migration[6.1]
  def change
    add_column :use_policies, :policy_url, :string
  end
end
