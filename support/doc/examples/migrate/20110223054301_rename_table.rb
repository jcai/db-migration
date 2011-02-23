class RenameTable < ActiveRecord::Migration
  def self.up
    rename_table "test_table1","test_table2"
  end

  def self.down
    rename_table "test_table2","test_table1"
  end
end
