require 'pry'
class Dog
    attr_reader
    attr_accessor :name, :breed, :id
    @@all = []
    def initialize(id: nil, name:, breed:)
        @name = name
        @breed = breed
        @id = id
        @@all << self
    end

    def self.create_table
        sql =  <<-SQL 
          CREATE TABLE IF NOT EXISTS dogs (
            id INTEGER PRIMARY KEY, 
            name TEXT, 
            breed TEXT
            )
            SQL
        DB[:conn].execute(sql) 
    end

    def self.drop_table
        sql = "DROP TABLE dogs"
        DB[:conn].execute(sql) 
    end

    def update
        sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end
    
    def save
        if self.id
          self.update
        else
          sql = <<-SQL
            INSERT INTO dogs (name, breed) 
            VALUES (?, ?)
          SQL
     
          DB[:conn].execute(sql, self.name, self.breed)
     
          @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        end
        return self
    end

    def self.create(properties)
        new_dog = Dog.new(properties)
        new_dog.save
    end

    def self.new_from_db(row)
        properties = {}
        properties[:id] = row[0]
        properties[:name] = row[1]
        properties[:breed] = row[2]
        #binding.pry
        new_dog = self.new(properties)
        #binding.pry
        #new_dog.id = row[0]
    end

    def self.find_by_id(id)
        sql = "Select * from dogs where id = ?"
        data = DB[:conn].execute(sql, id)
        row = data[0]
        #binding.pry
        properties = {}
        properties[:id] = row[0]
        properties[:name] = row[1]
        properties[:breed] = row[2]
        new_dog = self.new(properties)
    end

    def self.find_or_create_by(properties)
        dog_name = properties[:name]
        dog_breed = properties[:breed]
        #binding.pry
        found_dog = @@all.find do |dog|
            dog.name == dog_name && dog.breed == dog_breed
        end
        #binding.pry
        if !found_dog
            new_dog = self.create(properties)
            #binding.pry
            return new_dog
        else
            # sql = "Select id from dogs where name = ? and breed = ?"
            # id_array = DB[:conn].execute(sql, dog_name, dog_breed)
            # dog_id = id_array[0][0]
            return found_dog
        end
    end

    def self.find_by_name(name)
        sql = "Select id from dogs where name = ?"
        id_array = DB[:conn].execute(sql, name)
        dog_id = id_array[0][0]
        found_dog = @@all.find do |dog|
            dog.name == name
        end
        found_dog.id = dog_id
        #binding.pry
        found_dog
    end

end