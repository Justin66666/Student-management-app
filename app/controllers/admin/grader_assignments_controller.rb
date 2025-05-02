module Admin
  class GraderAssignmentsController < Admin::ApplicationController
    def index
      # 确保所有课程都有sections
      SectionService.ensure_sections_for_all_courses
      
      @sections = Section.includes(:course, :applications).all
      @approved_applications = Application.includes(:user, :course).where(status: 'approved').where(section_id: nil)
    end

    def assign_grader
      @application = Application.find(params[:application_id])
      @section = Section.find(params[:section_id])
      
      @application.update(section_id: @section.id)
      
      redirect_to admin_grader_assignments_path, notice: "#{@application.user.email} has been assigned to #{@section.course.subject} #{@section.course.course_number} Section #{@section.number}"
    end

    def unassign_grader
      @application = Application.find(params[:application_id])
      
      section_info = "#{@application.section.course.subject} #{@application.section.course.course_number} Section #{@application.section.number}"
      @application.update(section_id: nil)
      
      redirect_to admin_grader_assignments_path, notice: "#{@application.user.email} has been unassigned from #{section_info}"
    end

    def update_graders_required
      @section = Section.find(params[:section_id])
      if @section.update(graders_required: params[:graders_required])
        redirect_to admin_grader_assignments_path, notice: "Graders required for #{@section.course.subject} #{@section.course.course_number} Section #{@section.number} updated to #{@section.graders_required}"
      else
        redirect_to admin_grader_assignments_path, alert: "Failed to update graders required"
      end
    end
  end
end 