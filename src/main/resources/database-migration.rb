require 'rubygems'
gem "activerecord"
gem 'activerecord-jdbc-adapter'
gem 'activerecord-jdbcmysql-adapter'

require 'arjdbc'

require 'active_record/connection_adapters/jdbc_adapter'
require 'active_record/connection_adapters/jdbcmysql_adapter'
require "active_record"
require 'yaml'    
require 'logger'

class DBMigrator
    def migrate host,db,username,password,migrate_dir
        ActiveRecord::Base.logger=Logger.new($stdout)
        db_dir="support/test-migration"
        ActiveRecord::Base.establish_connection(
            :adapter => "jdbcmysql",
            :host => host,
            :database => db,
            :username => username,
            :password => password,
            :encoding => 'utf8')
        #do migration
        ActiveRecord::Base.logger.info("migration dir:#{migrate_dir}")
        ActiveRecord::Migrator.migrate(migrate_dir, ENV["VERSION"] ? ENV["VERSION"].to_i : nil)
        ActiveRecord::Base.logger.info("current version: #{ActiveRecord::Migrator.current_version}")
    end
    def migrate2 config,migrate_dir
        ActiveRecord::Base.logger=Logger.new($stdout)
        dbconfig = YAML::load(File.open(config))    
        ActiveRecord::Base.establish_connection(dbconfig)    
        ActiveRecord::Base.logger.info("migration dir:#{migrate_dir}")
        ActiveRecord::Migrator.migrate(migrate_dir, ENV["VERSION"] ? ENV["VERSION"].to_i : nil)
        return ActiveRecord::Migrator.current_version
    end
end
DBMigrator.new
