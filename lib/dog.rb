class Dog

  attr_reader :id
  attr_accessor :name, :breed

  def initialize(attr, id=nil)
    attr.each {|k, v| self.send(("#{k}="), v)}
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT)
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
    DROP TABLE dogs
    SQL
    DB[:conn].execute(sql)
  end

  def save
    sql = <<-SQL
    INSERT INTO dogs (name, breed) VALUES (?, ?)
    SQL
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

  def self.create(attr)
    dog = Dog.new(attr)
    dog.save
    dog 
  end















end
