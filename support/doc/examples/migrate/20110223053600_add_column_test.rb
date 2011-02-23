class AddColumnTest < ActiveRecord::Migration
  def self.up
    # 增加列长度为10的varchar
    add_column "test_table1","col_name",:string,:limit=>10
  end

  def self.down
    remove_column "test_table1","col_name"
  end
end
