class ChangeColumnTest < ActiveRecord::Migration
  def self.up
    change_column "test_table1","col_name",:integer
  end

  def self.down
    change_column "test_table1","col_name"
  end
end
