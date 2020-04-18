# Mapping database tables to classes 
# Mapping instances of classes to rows in those tables.

class Dog 
  attr_accessor :id, :name, :breed 
  
  def initialize(id:nil, name:, breed:)
    @id = id
    @name = name 
    @breed = breed 
  end 
  
  #When we create a new song with the Song.new method, we do not set that song's id. A song gets an id only when it gets saved into the database. We therefore set the default value of the id argument that the #initialize method takes equal to nil, so that we can create new song instances that *do not have an id value. 
  
  def self.create_table 
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT)
    SQL
    DB[:conn].execute(sql)
    #need to tell the database to EXECUTE THE SQL 
  end 
  
  #To "map" our class to a database table, we will create a table with the same name as our class and give that table column names that match the attr_accessors of our class.
  
  
  
  def self.drop_table
    sql = <<-SQL 
      DROP TABLE IF EXISTS dogs 
    SQL
    DB[:conn].execute(sql)
  end 
  
  
  #Save methods handle the common action of INSERTing data into the database. 
  #Actually, we are not saving Ruby objects in our database. We are going to take the individual attributes of a given instance, in this case a dog's name and breed, and save those attributes that describe an individual dog to the database as one, single row.
  
  #Remember that the INTEGER PRIMARY KEY datatype will assign and auto-increment the id attribute of each record that gets saved.
  
  #The moment in which we create a new Song instance with the #new method is different than the moment in which we save a representation of that song to our database. The #new method creates a new instance of the song class, a new Ruby object. The #save method takes the attributes that characterize a given song and saves them in a new row of the songs table in our database.
  
  #We need our #save method to check to see if the object it is being called on has already been persisted. If so, don't INSERT a new row into the database, simply update an existing one. Now that we have our handy #update method ready to go, this should be easy.
  
  #How do we know if an object has been persisted? If it has an id that is not nil. Remember that an object's id attribute gets set only once it has been INSERTed into the database. We tackle this with the following if statement:
    
    
  def save 
    if self.id
      self.update
    else
      sql = <<-SQL 
       INSERT INTO dogs (name, breed) VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, self.name, self.breed)
      #self.name and self.breed go into the respective question marks above 
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      #what's returned here is an array that contains one array that contains one element––the last inserted row ID
      #At the end of our save method, we use a SQL query to grab the value of the ID column of the last inserted row, and set that equal to the given song instance's id attribute.
      self
    end 
  end 
  
  #This method will wrap the code we used above to create a new Song instance and save it.
  #Here, we use keyword arguments to pass a name and album into our .create method. We use that name and album to instantiate a new song. Then, we use the #save method to persist that song to the database.
  
  def self.create(name: name, breed: breed)
    #take in hash of attributes and uses metaprogramming to create a new dog object
    
    dog = Dog.new(name: name, breed: breed)
    #saves this dog to the database
    dog.save
  end 
  
  #New_from_db: The first thing we need to do is convert what the database gives us into a Ruby object. We will use this method to create all the Ruby objects in our next two methods.
  
 # Since we're retrieving data from a database, we are using new. We don't need to create records. With this method, we're reading data from SQLite and temporarily representing that data in Ruby.
  
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
  
  def self.find_or_create_by(name:, breed:)
    #if it exists, we want to find the dog in the database. If it doesn't exist, we want to create it.
    #First, we query the database: does a record exist that has this name and album?
    sql = <<-SQL 
      SELECT * FROM dogs WHERE name = ? AND breed = ? LIMIT 1 
    SQL
    dog = DB[:conn].execute(sql, name, breed)
    
    
    #the above line is the query. If the dog does exists, we want to find it: 
    if !dog.empty?
      
      #when two dogs have the same name and different breed, it returns the correct dog. Set dog equal to 1.
      #If this is the case, then the statement: !song.empty? will return true. Therefore, we will use the returned values to make a new "Dog" object that Ruby can play around with, but we will not save it to the database. That re-instantiation of an existing Dog object is accomplished with these lines:
      dog = dog[0]
      new_dog = Dog.new(id:dog[0],name:dog[1],breed:dog[2])
    else
      #However, if no record exists that matches the name and album passed in as arguments, then !song.empty? will return false, and we will instead create and save a new Song instance with the #create method.
      new_dog = self.create(name:name,breed:breed)
    end
    #At the end of our #find_or_create_by method, we will return the song object whose database entry we either found or created. This method assumes that there isn't already a song object matching these attributes, but that there may already exist a database entry with the same name and album. Therefore, it instantiates a new instance of the Song class while preventing a duplicate database entry.
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
  
  #The best way for us to do this is to simply update all the attributes whenever we update a record. That way, we will catch any changed attributes, while the un-changed ones will simply remain the same.
  
  def update
    sql = "UPDATE dogs SET name = ?, breed = ?  WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

 
end 
