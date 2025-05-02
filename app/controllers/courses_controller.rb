# app/controllers/courses_controller.rb
class CoursesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_course, only: [:show, :edit, :update, :destroy]
  before_action :require_admin, only: [:edit, :update, :destroy]

  def index
    course_service = CourseService.new
    # 注释掉这行代码，不再每次自动获取Spring 2025学期的课程
    # course_service.fetch_and_store_courses(term: '1252') # Ensure the courses are being fetched

    # Debugging log: Show courses fetched from the database
    @courses = Course.all
    Rails.logger.debug("Courses after fetch: #{@courses.inspect}") # Log the courses

    # Apply search filter
    if params[:search].present?
      search_term = "%#{params[:search]}%"
      @courses = @courses.where("CAST(course_number AS TEXT) LIKE ? OR title LIKE ?", search_term, search_term)
    end

    # Apply level filter - fixed to properly use the level calculation
    if params[:level].present? && params[:level] != 'all'
      level_start = params[:level].to_i * 1000
      level_end = level_start + 999
      @courses = @courses.where("course_number BETWEEN ? AND ?", level_start, level_end)
    end

    # Apply sorting
    case params[:sort]
    when 'number_asc'
      @courses = @courses.order(course_number: :asc)
    when 'number_desc'
      @courses = @courses.order(course_number: :desc)
    when 'title_asc'
      @courses = @courses.order(title: :asc)
    when 'title_desc'
      @courses = @courses.order(title: :desc)
    else
      @courses = @courses.order(course_number: :asc) # Default sort by course number ascending
    end

    @courses = @courses.page(params[:page]).per(10)
  end

  def show
    # Ensure we load all sections for this course
    @sections = @course.sections.includes(:course) 
    
    # If no sections exist, create some default ones for testing purposes
    if @sections.empty? && Rails.env.development?
      create_sample_sections
      @sections = @course.sections.reload
    end
  end

  def edit
  end

  def update
    if @course.update(course_params)
      redirect_to @course, notice: 'Course was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @course.destroy
    redirect_to courses_url, notice: 'Course was successfully deleted.'
  end

  private

  def set_course
    @course = Course.find(params[:id])
  end

  def course_params
    params.require(:course).permit(:title, :description, :course_number, :term, :campus, :subject)
  end

  def require_admin
    unless current_user.admin?
      flash[:alert] = "You are not authorized to perform this action."
      redirect_to courses_path
    end
  end
  
  # Create sample sections for development testing
  def create_sample_sections
    return unless Rails.env.development?
    
    # Create two sample sections for testing
    @course.sections.create(
      number: '0001',
      instructor_name: 'Dr. Tang',
      schedule: 'MWF 10:20-11:15',
      location: 'Dreese Lab 264',
      current_enrollment: 25,
      max_enrollment: 30
    )
    
    @course.sections.create(
      number: '0002',
      instructor_name: 'Dr. Cheng',
      schedule: 'TR 12:40-2:00',
      location: 'Dreese Lab 305',
      current_enrollment: 18,
      max_enrollment: 30
    )
  end
end
