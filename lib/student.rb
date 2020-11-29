require_relative "../config/environment.rb"

class Student

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]
  attr_accessor :id, :name, :grade

  def initialize(id = nil, name, grade)
    @id = id
    @name = name
    @grade = grade
  end


  # Creates the students table with columns that match attributes of indiv. students
  # with an id (which is primary key), the name and the grade. 
  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS students (
      id INTEGER PRIMARY KEY, 
      name TEXT, 
      grade TEXT
    )
    SQL

    DB[:conn].execute(sql)
  end


  # This class method should be responsible for droping the students table. 
  def self.drop_table
    sql = "DROP TABLE IF EXISTS students"
    DB[:conn].execute(sql)
  end



  # Updated save method that FIRST checks if an object already exists in database via 'id', if so, 
  # we would just update. Else, inserts a new row into the database using the attributes of the 
  # given object. Method also assigns 'id' attribute of object once row has been inserted into database. 
  def save 
    if self.id
      self.update
    else
      sql = <<-SQL
      INSERT INTO students (name, grade)
      VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, self.name, self.grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end


  # Creates a student with two attributes, name & grade, and saves it into students table
  def self.create(name, grade)
    student = Student.new(name, grade)
    student.save
    student
  end



  #This class method takes an argument of an array. When we call this method we will 
  # pass it the array that is the row returned from the database by the execution of 
  # a SQL query. We can anticipate that this array will contain three elements in this 
  # order: the id, name and grade of a student.
  def self.new_from_db(row)
    new_student = self.new(row[0], row[1], row[2])
    new_student
  end



  # Class method takes in an argument (name). It queries the database table for a 
  # record that has name of the name passed in as argument. Then uses #new_from_db method 
  # to instantiate a Student object with the database row that the SQL query returns. 
  def self.find_by_name(name)
    sql = <<-SQL
    SELECT *
    FROM students
    WHERE name = ?
    LIMIT 1
    SQL

    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first
  end



  # This method updates the database row mapped to the given Student instance 
  def update 
    sql = "UPDATE students SET name = ?, grade = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end


end
