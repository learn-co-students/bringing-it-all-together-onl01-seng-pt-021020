class Dog
  attr_accessor :id, :name, :breed

  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    sql = "CREATE TABLE IF NOT EXISTS dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT);"
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS dogs;"
    DB[:conn].execute(sql)
  end

  def save
    sql = "INSERT INTO dogs (name, breed) VALUES (?,?);"
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs;")[0][0]
    self
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?;"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def self.create(name:, breed:)
    n_dog = self.new(name: name, breed: breed)
    n_dog.save
    n_dog
  end

  def self.new_from_db(n_row)
    id = n_row[0]
    name = n_row[1]
    breed = n_row[2]
    self.new(name: name, breed: breed, id: id)
  end

  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ? LIMIT 1;"
    DB[:conn].execute(sql, id).map do |n_row|
      self.new_from_db(n_row)
    end.first
  end

  def self.find_or_create_by(name:, breed:)
    sql = "SELECT * FROM dogs WHERE name = ? AND breed = ?;"
    n_dog = DB[:conn].execute(sql, name, breed)
    if !n_dog.empty?
      dog_info = n_dog[0]
      dog = Dog.new(id: dog_info[0], name: dog_info[1], breed: dog_info[2])
    else
      n_dog = self.create(name: name, breed: breed)
    end
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ? LIMIT 1;"
    DB[:conn].execute(sql, name).map do |n_row|
      self.new_from_db(n_row)
    end.first
  end
end
