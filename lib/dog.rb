# Mapping database tables to classes 
# Mapping instances of classes to rows in those tables.

class Dog 
  attr_accessor :id, :name, :breed 
  
  def initialize(id:nil, name:, breed:)
    @id = id
    @name = name 
    @breed = breed 
  end 
  
  def self.create_table 
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT)
    SQL
    DB[:conn].execute(sql)
    #need to tell the database to EXECUTE THE SQL 
  end 
  
  def self.drop_table
    sql = <<-SQL 
      DROP TABLE IF EXISTS dogs 
    SQL
    DB[:conn].execute(sql)
  end 
  
  def save 
    #Save methods handle the common action of INSERTing data into the database. 
    sql = <<-SQL 
      INSERT INTO dogs (name, breed) VALUES (?, ?)
    SQL
    DB[:conn].execute(sql, self.name, self.breed)
    #self.name and self.breed go into the respective question marks above 
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    #We save the id separately because the id comes from the database.
    self
  end 
  
  
  
  def self.create(name: name, breed: breed)
    #take in hash of attributes and uses metaprogramming to create a new dog object
    
    dog = Dog.new(name: name, breed: breed)
    #saves this dog to the database
    dog.save
  end 
  
  def self.new_from_db(row_from_db)
    #creates an instance with corresponding attribute values 
    new_dog = create(name:row_from_db[1],breed:row_from_db[2])
    #using the create method we built above
    new_dog.id = row_from_db[0]
    new_dog
  end
  
  def self.find_by_id(desired_id)
    db_row = DB[:conn].execute("SELECT * FROM dogs WHERE id = ?", desired_id)[0]
    #We just found the desired id from a row in the database. [0] accesses the id 
    new_dog = Dog.new(id:desired_id, name:db_row[1], breed:db_row[2])
    #Instantiating a new dog with this id, and returning that new dog
    new_dog
  end
  
  def self.find_or_create_by(name:name, breed:breed)
    #if it exists, we want to find the dog in the database. If it doesn't exist, we want to create it.
    sql = <<-SQL 
      SELECT * FROM dogs WHERE name = ? AND breed = ? LIMIT 1 
    SQL
    dog = DB[:conn].execute(sql, name, breed)
    #why not dog = DB[:conn].execute(sql, self.name, self.breed)?
    
    #the above line is the query. If the dog does exists, we want to find it: 
    if !dog.empty?
      dog = dog[0]
      #when two dogs have the same name and different breed, it returns the correct dog. Set dog equal to 1 
      new_dog = Dog.new(id:dog[0],name:dog[1],breed:dog[2])
    else
      new_dog = self.create(name:name,breed:breed)
    end
    new_dog 
  end 
  
  def self.find_by_name(name)
    #returns an instance of dog that matches the name from the DB 
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
      LIMIT 1
    SQL
    new_dog = DB[:conn].execute(sql, name)
    
    self.new_from_db(new_dog[0])
    #new_from_db takes in a row from the database, new_dog is a row from the database 

  end 
  
  def update
    sql = "UPDATE dogs SET name = ?, breed = ?  WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

 
end 
