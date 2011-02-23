class CreateTestTable < ActiveRecord::Migration
  def self.up
    create_table "test_table1",:comment=>"测试表格1" do |t|
      t.string "varchar_col",:limit=>100,:comment=>"varchar(100)的列"
      t.integer 'int_col',:comment=>"整数列"
    end
    add_index "test_table1",["varchar_col"]
  end

  def self.down
    remove_index "test_table1", :column => ["varchar_col"]
    drop_table "test_table1"
  end
end
