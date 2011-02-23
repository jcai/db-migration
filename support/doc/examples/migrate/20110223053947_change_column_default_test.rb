class ChangeColumnDefaultTest < ActiveRecord::Migration
  def self.up
    change_column_default "test_table1","col_name",12
  end

  def self.down
  end
end
