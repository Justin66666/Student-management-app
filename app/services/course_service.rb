# app/services/course_service.rb
class CourseService
  include HTTParty
  base_uri 'https://contenttest.osu.edu/v2/classes/search'

  def fetch_and_store_courses(term:, campus: 'col', page: 1)
    response = self.class.get('', query: {
      q: 'cse',                # Searching for CSE courses
      client: 'class-search-ui',
      campus: campus,          # Campus (e.g., col for Columbus)
      p: page,                 # Page number (pagination)
      term: term,              # Term code (e.g., '1252' for Spring 2025)
      class_attribute: 'ge2'   # Filter for general education classes (if needed)
    })

    if response.success?
      data = response.parsed_response
      process_data(data)
    else
      Rails.logger.error "API error: #{response.code}"
    end
  rescue => e
    Rails.logger.error "Error in fetch_and_store_courses: #{e.message}"
  end

  private

  def process_data(json)
    courses_array = json.dig("data", "courses") || []

    Rails.logger.debug("Fetched courses: #{courses_array.inspect}") # Log the API response

    courses_array.each do |item|
      course_info = item["course"] || {}
      subject = course_info["subject"]
      catalog_num = course_info["catalogNumber"]
      title = course_info["title"]
      desc = course_info["description"]
      term = course_info["term"]
      campus = course_info["campus"]

      # Log the course being processed
      Rails.logger.debug("Processing course: #{course_info.inspect}")

      next if subject.blank? || catalog_num.blank? || title.blank?

      # Create or update the course record
      course = Course.find_or_initialize_by(subject: subject, course_number: catalog_num)
      course.title = title
      course.description = desc
      course.term = term
      course.campus = campus
      course.save!
      
      # Process sections if available in the API response
      process_sections(course, item)
    end
  end
  
  # Process and store course sections with instructor information
  def process_sections(course, course_data)
    # Check if the API response includes section information
    sections_data = course_data["sections"] || []
    
    # If no sections data is available, return early
    return if sections_data.empty?
    
    sections_data.each do |section_data|
      # Extract section details from API data
      section_number = section_data["number"]
      instructor_name = extract_instructor_name(section_data)
      schedule = extract_schedule(section_data)
      location = extract_location(section_data)
      enrollment = section_data["enrollment"] || {}
      current_enrollment = enrollment["current"] || 0
      max_enrollment = enrollment["max"] || 30
      
      # Log the section being processed
      Rails.logger.debug("Processing section: #{section_data.inspect}")
      
      # Create or update the section
      section = course.sections.find_or_initialize_by(number: section_number)
      section.instructor_name = instructor_name
      section.schedule = schedule
      section.location = location
      section.current_enrollment = current_enrollment
      section.max_enrollment = max_enrollment
      section.graders_required = 1 # Default value
      section.save!
    end
  end
  
  # Extract instructor name from section data
  def extract_instructor_name(section_data)
    # Different APIs might structure this data differently
    # Try various possible paths to find instructor information
    instructor = section_data.dig("instructors", 0, "name") || 
                section_data.dig("instructor", "name") ||
                section_data.dig("instructorName")
    
    # Fall back to default if not found
    instructor.presence || "Staff"
  end
  
  # Extract schedule information from section data
  def extract_schedule(section_data)
    # Try various possible paths to find schedule information
    schedule = section_data.dig("meetingTime") ||
              section_data.dig("schedule") ||
              section_data.dig("meetingPattern")
    
    # Fall back to default if not found
    schedule.presence || "TBA"
  end
  
  # Extract location information from section data
  def extract_location(section_data)
    # Try various possible paths to find location information
    location = section_data.dig("location") ||
              section_data.dig("room") ||
              section_data.dig("buildingName")
    
    # Fall back to default if not found
    location.presence || "TBA"
  end
end
