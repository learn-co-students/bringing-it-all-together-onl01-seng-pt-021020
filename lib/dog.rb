class Dog
  attr_accessor :name, :breed
  attr_reader :id

  def initialize (id:nil, name:, breed:)
      @id = id
      @name = name
      @breed = breed
  end

  def save
       sql = <<-SQL
       INSERT INTO dogs (id, name, breed) VALUES (?,?,?)
       SQL
       DB[:conn].execute(sql, self.id, self.name, self.breed)
       dog_array_id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0]
      #  binding.pry
       @id= dog_array_id[0]
       self
  end

  def self.create(name:, breed:)
      dog= Dog.new(name: name,breed: breed)
      dog.save
      dog
  end

  def self.new_from_db(row)
      self.new(id:row[0],name:row[1], breed:row[2])
  end

  def self.find_by_id(id)
      sql = <<-SQL
            SELECT * FROM dogs WHERE dogs.id = ? LIMIT 1
          SQL

      DB[:conn].execute(sql, id).map do |row|
        self.new_from_db(row)
      end.first

  end

  def self.find_or_create_by(name:, breed:)
          sql= <<-SQL
          SELECT * FROM dogs
          WHERE name = ? AND breed = ?
          SQL
    dog = DB[:conn].execute(sql, name, breed)[0]
    # binding.pry
    if dog
        Dog.new(id: dog[0], name: dog[1], breed: dog[2])
    else
      Dog.create(name: name, breed: breed)
    end

  end

  def self.find_by_name(name)
      sql = <<-SQL
            SELECT * FROM dogs WHERE name = ?
            SQL

      dog_by_name = DB[:conn].execute(sql, name)[0]
      # binding.pry
      self.new_from_db(dog_by_name)
  end

  def update
      sql = <<-SQL
          UPDATE dogs
          SET name = ?, breed = ? WHERE id = ?
          SQL
      DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def self.create_table
      sql = <<-SQL
          CREATE TABLE dogs(
            id INTEGER PRIMARY KEY,
            name TEXT,
            breed TEXT
          );
          SQL

      DB[:conn].execute(sql)
  end

  def self.drop_table
      sql= <<-SQL
          DROP TABLE IF EXISTS dogs ;
          SQL

      DB[:conn].execute(sql)
  end

end
