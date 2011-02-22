class InitSchema < ActiveRecord::Migration
  def self.up
    create_table "browsers", :force => true,:comment => '浏览器' do |t|
      t.string "name", :limit => 100,:comment => '名称'
    end
    add_index "browsers", ["name"], :name => "index_name", :unique => true

    create_table "devices", :force => true,:comment => '手机类型' do |t|
      t.string "name", :limit => 200,:comment => '名称'
    end
    add_index "devices", ["name"], :name => "index_name", :unique => true

    create_table "districts", :force => true ,:comment=> '所属行政区划' do |t|
      t.string "name", :limit => 200,:comment => '名称'
    end
    add_index "districts", ["name"], :name => "index_name", :unique => true

    create_table "operate_systems", :force => true ,:comment=>'操作系统' do |t|
      t.string "name", :limit => 200,:comment => '名称'
    end
    add_index "operate_systems", ["name"], :name => "index_name", :unique => true

    create_table "searcher_engines", :force => true do |t|
      t.string "name", :limit => 200,:comment => '名称'
    end
    add_index "searcher_engines", ["name"], :name => "index_name", :unique => true

    create_table "site_day_browser_gather", :force => true ,:comment => '站点每日浏览器统计数据' do |t|
      t.integer "pv",         :default => 0,  :comment=>'pv'
      t.integer "day_time",   :limit => 8,  :comment => '统计所在天的毫秒数'
      t.integer "created_at", :limit => 8,  :comment => '创建时间'
      t.integer "site_id",    :limit => 8,  :comment => '关联站点ID',   :null => false
      t.integer "browser_id", :limit => 8,  :comment => '关联浏览器ID', :null => false
    end
    add_index "site_day_browser_gather", ["browser_id"]
    add_index "site_day_browser_gather", ["site_id"]

    create_table "site_day_device_gather", :force => true ,:comment => '站点每日手机设备统计数据' do |t|
      t.integer "pv",         :default => 0,  :comment=>'pv'
      t.integer "day_time",   :limit => 8,  :comment => '统计所在天的毫秒数'
      t.integer "created_at", :limit => 8,  :comment => '创建时间'
      t.integer "site_id",    :limit => 8,  :comment => '关联站点ID',       :null => false
      t.integer "device_id",  :limit => 8,  :comment => '关联手机设备的ID', :null => false
    end
    add_index "site_day_device_gather", ["device_id"]
    add_index "site_day_device_gather", ["site_id"]

    create_table "site_day_seo_gather", :force => true ,:comment=> '站点每天搜索引擎统计' do |t|
      t.integer "pv",         :default => 0,  :comment=>'pv'
      t.integer "day_time",   :limit => 8,  :comment => '统计所在天的毫秒数'
      t.integer "created_at", :limit => 8,  :comment => '创建时间'
      t.integer "site_id",    :limit => 8,  :comment => '关联站点ID',         :null => false
      t.integer "searcher_engine_id", :limit => 8,:comment=>'关联搜索引擎ID', :null => false
    end
    add_index "site_day_seo_gather", ["searcher_engine_id"]
    add_index "site_day_seo_gather", ["site_id"]

    create_table "site_day_gather", :force => true ,:comment => '站点每天统计' do |t|
      t.integer "pv",         :default => 0,  :comment=>'pv'
      t.integer "uv",         :default => 0,  :comment => 'uv'
      t.integer "ipv",        :default => 0,  :comment => 'ip view'
      t.integer "day_time",   :limit => 8,  :comment => '统计所在天的毫秒数'
      t.integer "created_at", :limit => 8,  :comment => '创建时间'
      t.integer "site_id",    :limit => 8,  :comment => '关联站点ID',       :null => false
    end
    add_index "site_day_gather", ["site_id"]

    create_table "site_hour_gather", :force => true,:comment=>'站点小时统计' do |t|
      t.integer "pv",         :default => 0,  :comment=>'pv'
      t.integer "uv",         :default => 0, :comment => 'uv'
      t.integer "ipv",        :default => 0, :comment => 'ip view'
      t.integer "hour_time",  :limit => 8,  :comment => '所在小时的毫秒数'
      t.integer "created_at", :limit => 8,  :comment => '创建时间'
      t.integer "site_id",    :limit => 8,  :comment => '关联站点ID',       :null => false
    end
    add_index "site_hour_gather", ["site_id"]

    create_table "users", :force => true ,:comment=>'用户' do |t|
      t.string  "login",         :limit => 20, :null => false,  :comment=>'登录用户名'
      t.string  "password",      :limit => 50, :null => false,  :comment=>'密码'
      t.integer "created_at",    :limit => 8,  :null => false,  :comment=>'创建时间'
      t.integer "last_login_at", :limit => 8,  :null => false,  :comment=>'最后一次登录时间'
    end

    create_table "sites", :force => true ,:comment=> '站点' do |t|
      t.integer "user_id",       :limit => 8,                  :null => false,  :comment=> '关联用户ID'
      t.string  "name",          :limit => 45,                 :null => false,  :comment=>'站点名称'
      t.string  "desc",          :limit => 500,                                 :comment=>'站点描述'
      t.string  "domain",        :limit => 100,                :null => false,  :comment=>'站点域名'
      t.integer "total_visitor", :limit => 8,   :default => 0, :null => false,  :comment=>'总访问数目'
      t.integer "site_order",    :limit => 8,                                   :comment=>'站点排名'
      t.integer "created_at",    :limit => 8,                  :null => false,  :comment=>'创建时间'
    end
    add_index "sites", ["user_id"]

    create_table "visitors", :force => true ,:comment=>'访客' do |t|
      t.integer "site_id",            :limit => 8,   :null => false,  :comment=>'站点ID'
      t.string  "host",               :limit => 200                ,  :comment=>'访问的域名'
      t.string  "referer",            :limit => 200                ,  :comment=>'来路页面'
      t.string  "user_agent",         :limit => 200                ,  :comment=>'用户访问头信息'
      t.string  "page",               :limit => 200, :null => false,  :comment=>'页面page'
      t.string  "ip",                 :limit => 20,  :null => false,  :comment=>'ip地址'
      t.integer "searcher_engine_id", :limit => 8                  ,  :comment=>'关联搜索引擎'
      t.integer "device_id",          :limit => 8                  ,  :comment=>'关联设备'
      t.integer "district_id",        :limit => 8                  ,  :comment=>'关联区域'
      t.integer "operate_system_id",  :limit => 8                  ,  :comment=>'关联操作系统'
      t.integer "browser_id",         :limit => 8                  ,  :comment=>'关联浏览器'
      t.integer "created_at",         :limit => 8,   :null => false,  :comment=>'创建时间'
    end
    add_index "visitors", ["browser_id"]
    add_index "visitors", ["device_id"]
    add_index "visitors", ["district_id"]
    add_index "visitors", ["operate_system_id"]
    add_index "visitors", ["searcher_engine_id"]
    add_index "visitors", ["site_id", "created_at"]
    add_index "visitors", ["site_id"]
  end

  def self.down
    remove_index "visitors", :column => ["site_id"]
    remove_index "visitors", :column => ["site_id", "created_at"]
    remove_index "visitors", :column => ["searcher_engine_id"]
    remove_index "visitors", :column => ["operate_system_id"]
    remove_index "visitors", :column => ["district_id"]
    remove_index "visitors", :column => ["device_id"]
    remove_index "visitors", :column => ["browser_id"]
    drop_table "visitors"

    remove_index "sites", :column => ["user_id"]
    drop_table "sites"

    drop_table "users"

    remove_index "site_hour_gather", :column => ["site_id"]
    drop_table "site_hour_gather"

    remove_index "site_day_gather", :column => ["site_id"]
    drop_table "site_day_gather"

    remove_index "site_day_seo_gather", :column => ["site_id"]
    remove_index "site_day_seo_gather", :column => ["searcher_engine_id"]
    drop_table "site_day_seo_gather"

    remove_index "site_day_device_gather", :column => ["site_id"]
    remove_index "site_day_device_gather", :column => ["device_id"]
    drop_table "site_day_device_gather"

    remove_index "site_day_browser_gather", :column => ["site_id"]
    remove_index "site_day_browser_gather", :column => ["browser_id"]
    drop_table "site_day_browser_gather"

    remove_index "searcher_engines", :name => "index_name"
    drop_table "searcher_engines"

    remove_index "operate_systems", :name => "index_name"
    drop_table "operate_systems"

    remove_index "districts", :name => "index_name"
    drop_table "districts"

    remove_index "devices", :name => "index_name"
    drop_table "devices"

    remove_index "browsers", :name => "index_name"
    drop_table "browsers"
  end
end
