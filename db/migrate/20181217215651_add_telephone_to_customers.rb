class AddTelephoneToCustomers < ActiveRecord::Migration[5.1]
  def change
    add_column :customers, :telephone, :string
  end
end
