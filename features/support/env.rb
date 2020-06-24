ENV['BUNDLE_GEMFILE'] = File.expand_path('../../../Gemfile', __FILE__)

require 'rubygems'
require 'bundler'
Bundler.setup

if File.directory?('test/rails_app')
  Dir.chdir('test/rails_app') do
    fail unless system('rm -f db/migrate/*create_invalid_records.rb && RAILS_ENV=test bin/rails db:drop db:create db:migrate')
  end
end

After do
  # Reset DB!
  tables = %w(categories invalid_records posts users)
  conn = ActiveRecord::Base.connection
  tables.each do |table|
    if conn.table_exists?(table)
      conn.execute("DELETE FROM '#{table}'")
      conn.execute("DELETE FROM sqlite_sequence WHERE name='#{table}'")
    end
  end
end
