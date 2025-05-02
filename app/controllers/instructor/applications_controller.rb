class Instructor::ApplicationsController < Instructor::ApplicationController
  before_action :set_course
  before_action :set_application, only: [:show]

  def show
    # Application and course are set by before_action
  end

  private

  def set_course
    @course = Course.find(params[:course_id])
  end

  def set_application
    @application = @course.applications.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to instructor_course_path(@course), alert: 'Application not found.'
  end
end 