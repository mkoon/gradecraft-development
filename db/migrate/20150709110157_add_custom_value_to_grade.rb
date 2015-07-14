class AddCustomValueToGrade < ActiveRecord::Migration
  def change
    add_column :grades, :is_custom_value, :boolean, default: false
  end
end
