module Instructor
  class GradersController < Instructor::ApplicationController
    before_action :set_course_and_section

    def index
      @graders = @section.graders
    end

    private

    def set_course_and_section
      @course = Course.find(params[:course_id])
      @section = @course.sections.find(params[:section_id])
    end
  end
end 