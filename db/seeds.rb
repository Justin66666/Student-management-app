# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Create default admin user
admin = User.find_or_initialize_by(email: 'admin.1@osu.edu')
admin.assign_attributes(
  password: 'password123',  # Use stronger password in production environment
  password_confirmation: 'password123',
  role: 'admin',
  approved: true  # Admin account automatically approved
)
admin.save!

puts "Default admin user created:"
puts "Email: admin.1@osu.edu"
puts "Password: password123"

# Create some test users if in development environment
if Rails.env.development?
  # Test instructor
  instructor = User.find_or_initialize_by(email: 'instructor.1@osu.edu')
  instructor.assign_attributes(
    password: 'password123',
    password_confirmation: 'password123',
    role: 'instructor',
    approved: true
  )
  instructor.save!

  # Test student
  student = User.find_or_initialize_by(email: 'student.1@osu.edu')
  student.assign_attributes(
    password: 'password123',
    password_confirmation: 'password123',
    role: 'student',
    approved: true
  )
  student.save!

  puts "\nTest users created:"
  puts "Instructor - Email: instructor.1@osu.edu, Password: password123"
  puts "Student - Email: student.1@osu.edu, Password: password123"
end

# Create sample sections for courses if in development environment
if Rails.env.development?
  # Get all courses
  courses = Course.all
  
  # Only proceed if there are courses
  if courses.any?
    # For each course, create 2-3 sections
    courses.each do |course|
      # Generate between 2-3 sections for each course
      section_count = rand(2..3)
      
      section_count.times do |i|
        section_number = "#{i + 1}".rjust(3, '0')  # e.g., 001, 002, 003
        Section.find_or_create_by!(
          course: course,
          number: section_number,
          instructor_name: ["Dr. Smith", "Dr. Johnson", "Dr. Lee", "Dr. Brown", "Dr. Wilson"].sample,
          schedule: ["MWF 9:10-10:05", "TR 11:30-12:25", "MWF 3:00-3:55", "TR 12:40-2:30"].sample,
          location: ["Dreese Lab #{rand(100..399)}", "Caldwell Lab #{rand(100..399)}", "Baker Systems #{rand(100..399)}"].sample,
          current_enrollment: rand(5..25),
          max_enrollment: 30
        )
      end
    end
    
    puts "\nSample sections created for all courses"
  end
end

# Add sample prerequisites to courses
if Rails.env.development?
  # Get all courses
  courses = Course.all
  
  # Only proceed if there are courses
  if courses.any?
    # Sample prerequisite data based on course levels
    courses.each do |course|
      case course.course_number
      when 1000..1999
        # 1000-level courses typically have no prerequisites
        course.update(prerequisites: nil)
      when 2000..2999
        # 2000-level courses might require 1000-level courses
        case course.course_number
        when 2123
          course.update(prerequisites: "CSE 1223 with a grade of C- or better")
        when 2221
          course.update(prerequisites: "CSE 1223 or CSE 1222 or CSE 1224 with a grade of C- or better")
        when 2231
          course.update(prerequisites: "CSE 2221 with a grade of C- or better")
        when 2321
          course.update(prerequisites: "CSE 1223 or CSE 1222 or CSE 1224 and Math 1151 or Math 1161")
        else
          course.update(prerequisites: "CSE 1223 or equivalent")
        end
      when 3000..3999
        # 3000-level courses require 2000-level courses
        course.update(prerequisites: "CSE 2231 and CSE 2321")
      when 4000..4999
        # 4000-level courses require 3000-level courses
        course.update(prerequisites: "CSE 3231 and CSE 3461")
      when 5000..5999
        # 5000-level courses require advanced prerequisites
        course.update(prerequisites: "CSE 3461 and Graduate standing, or permission of instructor")
      else
        course.update(prerequisites: "Permission of instructor")
      end
    end
    
    puts "\nAdded sample prerequisites to all courses"
  end
end
