class Student::ApplicationsController < Student::ApplicationController
  before_action :set_application, only: [:show, :destroy, :edit, :update]
  
  def index
    @applications = current_user.applications
  end

  def new
    @application = current_user.applications.build
  end

  def create
    @application = current_user.applications.build(application_params)
    if @application.save
      redirect_to student_applications_path, notice: 'Application was successfully submitted.'
    else
      render :new
    end
  end

  def show
    # Application is set by before_action
  end
  
  def edit
    # Allow editing of all applications, regardless of status
  end
  
  def update
    # Allow updating of all applications, regardless of status
    if @application.update(application_params)
      redirect_to student_application_path(@application), notice: 'Application was successfully updated.'
    else
      render :edit
    end
  end
  
  def destroy
    if @application.pending?
      @application.destroy
      redirect_to student_applications_path, notice: 'Application was successfully withdrawn.'
    else
      redirect_to student_applications_path, alert: 'Only pending applications can be withdrawn.'
    end
  end

  private

  def set_application
    @application = current_user.applications.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to student_applications_path, alert: 'Application not found.'
  end

  def application_params
    params.require(:application).permit(:course_id, :position_type, :experience, :programming_languages, :available_hours)
  end
end 