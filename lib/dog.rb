require 'pry'

class Dog 
  
  attr_accessor :id, :name, :breed
  
  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end  
  
  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
        )
        SQL
        DB[:conn].execute(sql)
  end  
  
  def self.drop_table
   DB[:conn].execute("DROP TABLE IF EXISTS dogs;")
  end  
  
  def save
   if self.id == true
       update
    else
    sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?, ?)
    SQL
 
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    #binding.pry
   end
    self #returns an instance of the dog class
  end 
  
  def self.create(name:, breed:) 
   dog = Dog.new(name: name, breed: breed) 
   dog.save
   dog
  end  
  
 #this method convert what the database gives us into a object.we're reading data from SQLite and temporarily representing that data in Ruby
  def self.new_from_db(row)
    self.create(name: row[1], breed: row[2])
  end
  
  def self.find_by_id(id) #pass in the id_x parameter
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE id = ?", id).first #pass it in here #.first pulls out the 1st element
    dog = Dog.new(id: dog[0], name: dog[1], breed: dog[2])
    dog
  end  
  
  #creates an instance of a dog if it does not already exist
  def self.find_or_create_by(name:, breed:) 
    find_dogs = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if find_dogs.empty?
       find_dogs = self.create(name:name, breed:breed) 
    else 
        find_dogs = find_dogs[0]
        find_dogs = Dog.new(id: find_dogs[0], name: find_dogs[1], breed: find_dogs[2])
        binding.pry
    end
    find_dogs
  end  
  
  def self.find_by_name(name)
        dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name).first
        self.new(id: dog[0],name: dog[1],breed: dog[2])
    end
  
  def update
      DB[:conn].execute("UPDATE dogs SET name = ?, breed = ? WHERE id = ?", name,breed,id)
      self
    end
  
  
end