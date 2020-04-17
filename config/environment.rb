require 'sqlite3'
require_relative '../lib/dog'

DB = {:conn => SQLite3::Database.new("db/dogs.db")}
#DB is set equal to a hash, which has a single key, :conn
#The key, :conn, will have a value of a connection to an sqlite3 database in the db directory. 

#This will create a new database called dogs.db, stored inside the db subdirectory of our app and it will return a Ruby object that represents the connection between our Ruby program and our newly created SQL database. 

