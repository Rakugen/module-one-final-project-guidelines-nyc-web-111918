require 'bundler'
Bundler.require

require 'rake'
require 'active_record'
require 'rest-client'
require 'artii'

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: 'db/development.db')
ActiveRecord::Base.logger=nil
require_all 'lib'
require_all 'app'
