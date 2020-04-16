class Dog
    attr_accessor :name, :breed, :id

    def initialize(name:, breed:, id: nil)
        @name = name
        @breed = breed
        @id = id
    end

    def self.create_table
        sql = <<-SQL
        CREATE TABLE IF NOT EXISTS dogs (
            id INTEGER PRIMARY KEY,
            name TEXT,
            breed TEXT
        );
        SQL
        DB[:conn].execute(sql)
    end

    def self.drop_table
        DB[:conn].execute("DROP TABLE dogs")
    end

    def save
        sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, self.name, self.breed) #calls the SQL to be exicuted and passes in the the name and breed
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0] #selects the row ID from the dog in the table
      self #returns the instance of the Dog class
    end

    def self.create(hash) #takes in a hash of data
       dog = Dog.new(name: hash[:name], breed: hash[:breed]) #uses the hash to create a new instance and assign attributes
       dog.save #calls save method on new instance 
    end 

    def self.new_from_db(row)
        attributes_hash = {
          :id => row[0],
          :name => row[1],
          :breed => row[2]
        }
        self.new(attributes_hash)
      end

    def self.find_by_id(num)
        row = DB[:conn].execute("SELECT * FROM dogs WHERE id = ?",num)[0][0] #sets row  = array of data from dogs table based on ID
        new_dog = self.new(name: row[1], breed: row[2], id: row[0]) #creates a new Dog instance based on the row 
    end

    def self.find_or_create_by(row)
        sql = <<-SQL
        SELECT * FROM dogs
        WHERE name = ? AND breed = ?
        LIMIT 1
        SQL
        dog = DB[:conn].execute(sql, row[:name], row[:breed])
        if dog.empty?  #if the arguement hash is empty, calls create method and passes in the hash(row)
            create(row)
        else
            dog = dog[0]  #sets the variable dog = to the array of the returned dog
            dog = Dog.new(id:dog[0],name:dog[1],breed:dog[2])  #creates a new instance with the dog array
        end
    end

    def self.find_by_name(name)
        dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? LIMIT 1;", name)
        dog.map do |n|
            self.new_from_db(n)
        end.first
    end

    def update
        sql = "UPDATE dogs SET name = ?, breed = ?  WHERE id = ?"
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

end