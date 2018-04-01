namespace :db do
  task :env do
    require 'dotenv'
    Dotenv.load!
  end

  desc "Create the database"
  task create: :env do
    dbname = URI.parse(ENV['DATABASE_URL']).path[1..-1]
    `createdb #{dbname}`
  end

  desc "Migrate the database"
  task migrate: :env do
    require './store.rb'
    Sequel.extension :migration
    Sequel::Migrator.apply(DB, 'migrations')
  end
end
