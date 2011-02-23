class AddIndexTest < ActiveRecord::Migration
  def self.up
    add_index "test_table1",["col_name"]
  end

  def self.down
    remove_index "test_table1", :column => ["col_name"]
  end
end
