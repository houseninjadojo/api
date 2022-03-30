class RemovePropertyNullConstraintOnWorkOrders < ActiveRecord::Migration[7.0]
  def change
    add_check_constraint :work_orders, "property_id IS NULL", name: "work_orders_property_id_null", validate: false
  end
end
