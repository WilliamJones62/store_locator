class AddCustGroupToCustomers < ActiveRecord::Migration[5.1]
  def change
    add_column :customers, :cust_group, :string
  end
end
