class ValidateRemovePropertyNullConstraintOnWorkOrders < ActiveRecord::Migration[7.0]
  def change
    validate_check_constraint :work_orders, name: "work_orders_property_id_null"
    change_column_null :work_orders, :property_id, true
    remove_check_constraint :work_orders, name: "work_orders_property_id_null"
  end
end
