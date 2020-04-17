require_relative "../config/environment.rb"

class Dog
attr_accessor :name, :breed
attr_reader :id

  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    sql = <<-SQL
      create table if not exists dogs (
        id integer primary key,
        name text,
        breed text
      )
      SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute("drop table dogs")
  end

  def save
    if self.id
      self.update
    else
    sql = <<-SQL
      insert into dogs (name, breed)
      values (?, ?)
      SQL
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("select last_insert_rowid() from dogs")[0][0]
    end
    self
  end

  def self.create(name:, breed:)
    new_dog = Dog.new(name: name, breed: breed)
    new_dog.save
    new_dog
  end

  def self.new_from_db(row)
    id = row[0]
    name = row[1]
    breed = row[2]
    new_dog = Dog.new(id: id, name: name, breed: breed)
    new_dog
  end

  def self.find_by_id(id)
    result = DB[:conn].execute("select * from dogs where id = ?", id)[0]
    new_dog = Dog.new(id: result[0], name: result[1], breed: result[2])
    new_dog
  end

  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
      select * from dogs where name = ? and breed = ?
      SQL
      doge = DB[:conn].execute(sql, name, breed)
      if !doge.empty?
        result = doge[0]
        new_dog = Dog.new(id: result[0], name: result[1], breed: result[2])
      else
        new_dog = Dog.create(name: name, breed: breed)
      end
    new_dog
  end

  def self.find_by_name(name)
    result = DB[:conn].execute("select * from dogs where name = ?", name)[0]
    new_dog = Dog.new(id: result[0], name: result[1], breed: result[2])
    new_dog
  end

  def update
    sql = "update dogs set name = ?, breed = ? where id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

end
