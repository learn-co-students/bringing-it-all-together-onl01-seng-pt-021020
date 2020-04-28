class Dog
	attr_reader :id, :breed
	attr_accessor :name

	# class methods
	def self.create(**kwargs)
		dog = self.new(**kwargs)
		dog.save
		dog
	end

	def self.create_table
		sql = <<~SQL
			CREATE TABLE dogs (
				id INTEGER PRIMARY KEY,
				name TEXT,
				breed TEXT
			);
		SQL

		DB[:conn].execute(sql)
	end

	def self.drop_table
		sql = <<~SQL
			DROP TABLE IF EXISTS dogs;
		SQL

		DB[:conn].execute(sql)
	end

	def self.find_by_id(id)
		query = <<~QRY
			SELECT *
			FROM
				dogs
			WHERE
				id = ?;
		QRY

		row = DB[:conn].execute(query, id)[0]
		new_from_db(row)
	end

	def self.find_by_name(name)
		query = <<~QRY
			SELECT *
			FROM
				dogs
			WHERE
				name = ?
			LIMIT 1;
		QRY

		results = DB[:conn].execute(query, name)
		new_from_db(results[0])
	end

	def self.find_or_create_by(**kwargs)
		query = <<~QRY
			SELECT *
			FROM
				dogs
			WHERE
				name = ?
				AND
				breed = ?
			LIMIT 1;
		QRY

		results = DB[:conn].execute(query, kwargs[:name], kwargs[:breed])
		if !results.empty?
			new_from_db(results[0])
		else
			create(**kwargs)
		end
	end

	def self.new_from_db(row)
		Dog.new(id: row[0], name: row[1], breed: row[2])
	end

	# instance methods
	def initialize(**kwargs)
		@id = kwargs[:id]
		@name = kwargs[:name]
		@breed = kwargs[:breed]
	end

	def save
		sql = <<~SQL
			INSERT INTO dogs (name, breed)
			VALUES (?, ?);
		SQL

		DB[:conn].execute(sql, @name, @breed)
		@id = DB[:conn].execute('SELECT last_insert_rowid() FROM dogs;')[0][0]
			
		self
	end

	def update
		sql = <<~SQL
			UPDATE dogs
			SET
				name = ?,
				breed = ?
			WHERE
				id = ?;
		SQL

		DB[:conn].execute(sql, @name, @breed, @id)
	end

end
