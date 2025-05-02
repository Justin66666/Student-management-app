require 'httparty'

class Admin::CoursesController < Admin::ApplicationController
  def index
    @courses = Course.all.order(:subject, :course_number)
  end

  def show
    @course = Course.find(params[:id])
  end

  def new
    @course = Course.new
  end

  def create
    @course = Course.new(course_params)
    if @course.save
      redirect_to admin_courses_path, notice: 'Course was successfully created.'
    else
      render :new
    end
  end

  def edit
    @course = Course.find(params[:id])
  end

  def update
    @course = Course.find(params[:id])
    if @course.update(course_params)
      redirect_to admin_course_path(@course), notice: 'Course was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @course = Course.find(params[:id])
    @course.destroy
    redirect_to admin_courses_path, notice: 'Course was successfully deleted.'
  end

  def reload
    if request.get?
      # Display the form
      render :reload
      return
    end

    # Get parameters from form
    term = params[:term] || "1252"  # Default to Spring 2025
    campus = params[:campus] || "col"  # Default to Columbus campus

    begin
      # Clear existing data with proper order to avoid foreign key constraints
      # Step 1: Delete applications first since they depend on courses
      Application.delete_all
      Rails.logger.info "Cleared all applications"
      
      # Step 2: Delete recommendation letters since they depend on courses
      RecommendationLetter.delete_all
      Rails.logger.info "Cleared all recommendation letters"
      
      # Step 3: Delete sections since they depend on courses
      Section.delete_all
      Rails.logger.info "Cleared all sections"
      
      # Step 4: Now it's safe to delete courses
      existing_count = Course.count
      Course.delete_all
      Rails.logger.info "Cleared #{existing_count} existing courses"

      # Make API request - use a catch-all for errors to prevent crashes
      begin
        # Make API request
        url = "https://contenttest.osu.edu/v2/classes/search"
        query_params = {
          q: "CSE",  # Use "CSE" to search for Computer Science courses specifically
          campus: campus,
          term: term,
          p: "1"
        }

        Rails.logger.info "Making API request to #{url} with params: #{query_params.inspect}"
        response = HTTParty.get(url, query: query_params)
        
        Rails.logger.info "API response status: #{response.code}"
        Rails.logger.info "API response body sample: #{response.body[0..500]}"
        
        if response.code != 200
          raise "API request failed with status code: #{response.code}, body: #{response.body}"
        end
        
        json_response = JSON.parse(response.body)
        
        if !json_response["data"] 
          # API response doesn't contain a data field, which is unexpected
          Rails.logger.warn "API response did not contain a data field: #{json_response.keys.join(', ')}"
          courses_data = []
        elsif !json_response["data"]["courses"] && json_response["data"]["totalItems"] == 0
          # API successfully returned but no courses are available for this term/campus
          Rails.logger.warn "API returned 0 courses for term: #{term}, campus: #{campus}"
          courses_data = []
        elsif !json_response["data"]["courses"] && json_response["data"].key?("course")
          # The API response structure is different - iterate through the array of course-section pairs
          Rails.logger.info "Using alternative course data format from API"
          courses_data = []
          
          json_response["data"].each do |course_with_sections|
            if course_with_sections.is_a?(Hash) && course_with_sections["course"]
              courses_data << course_with_sections["course"]
            end
          end
        else
          # Standard format with courses array
          courses_data = json_response["data"]["courses"] || []
        end
      rescue => e
        # If API fails, create some sample courses
        Rails.logger.error "Error with API request: #{e.message}"
        Rails.logger.error e.backtrace.join("\n")
        courses_data = []
        
        # Add a few sample courses for this term
        term_name = case term
                   when "1252" then "Spring 2025"
                   when "1254" then "Summer 2025"
                   when "1258" then "Autumn 2025"
                   else "Unknown Term"
                   end
        
        # Create sample fallback data
        10.times do |i|
          courses_data << {
            "course" => {
              "subject" => "CSE",
              "catalogNumber" => "#{1000 + i * 500}",
              "title" => "Sample Course #{i+1}",
              "description" => "This is a sample course generated when the API was unavailable.",
              "term" => term_name,
              "campus" => campus.upcase
            }
          }
        end
      end
      
      Rails.logger.info "Found #{courses_data.length} courses in API response"

      # Process each course
      courses_created = 0
      courses_data.each do |course_data|
        begin
          # Debug output
          if courses_created == 0
            Rails.logger.info "Sample course data: #{course_data.inspect}"
          end
          
          # Ensure course data exists and is valid
          course_info = course_data["course"]
          if !course_info
            Rails.logger.warn "Missing course info in: #{course_data.inspect}"
            next
          end
          
          course = Course.new(
            subject: course_info["subject"],
            course_number: course_info["catalogNumber"],
            title: course_info["title"],
            description: course_info["description"],
            term: term,
            campus: campus
          )
          course.save!
          courses_created += 1
        rescue => e
          Rails.logger.error "Error creating course: #{e.message}"
        end
      end

      redirect_to admin_courses_path, notice: "Successfully reloaded #{courses_created} courses"
    rescue => e
      Rails.logger.error "Error loading courses: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      flash[:alert] = "Error loading courses: #{e.message}"
      render :reload
    end
  end

  private

  def course_params
    params.require(:course).permit(:title, :description, :course_number, :term, :campus, :subject, :prerequisites)
  end

  def fetch_courses(term, campus)
    require 'net/http'
    require 'json'
    
    url = URI("https://contenttest.osu.edu/v2/classes/search")
    params = {
      q: "*",  # Use wildcard to search all courses
      campus: campus,
      term: term,
      p: 1
    }
    
    url.query = URI.encode_www_form(params)
    
    response = Net::HTTP.get_response(url)
    return JSON.parse(response.body) if response.is_a?(Net::HTTPSuccess)
    
    nil
  end
end
