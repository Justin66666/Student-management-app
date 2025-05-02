class SectionService
  def self.ensure_sections_for_all_courses
    default_instructors = ["Dr. Tang", "Dr. Cheng"]
    default_schedule = "MWF 10:30AM-11:30AM"
    default_location = "Dreese Lab 264"
    
    Course.all.each do |course|
      # Skip if course already has sections
      next if course.sections.any?
      
      # Create two default sections for each course
      2.times do |i|
        section_number = "000#{i+1}"
        instructor_name = default_instructors[i % default_instructors.length]
        
        Section.create!(
          course: course,
          number: section_number,
          instructor_name: instructor_name,
          schedule: default_schedule,
          location: default_location,
          current_enrollment: (15 + rand(15)),  # Random number between 15-30
          max_enrollment: 30,
          graders_required: 1
        )
      end
    end
  end
end 