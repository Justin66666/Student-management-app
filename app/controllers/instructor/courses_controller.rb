class Instructor::CoursesController < Instructor::ApplicationController
  def index
    @courses = Course.all.order(:subject, :course_number)
  end

  def show
    @course = Course.find(params[:id])
  end
end 