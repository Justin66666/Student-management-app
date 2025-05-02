class Admin::ApplicationsController < Admin::ApplicationController
  before_action :set_course, only: [:new, :create, :update, :destroy]
  before_action :set_application, only: [:show, :edit, :update, :approve, :reject, :destroy]
  
  # 查看所有申请的页面
  def index
    # 基础查询
    @applications = Application.includes(:user, :course).order(created_at: :desc)
    
    # 过滤选项
    @status_filter = params[:status]
    @course_filter = params[:course_id]
    
    # 应用过滤器 - 修复过滤器功能
    @applications = @applications.where(status: @status_filter) if @status_filter.present?
    @applications = @applications.where(course_id: @course_filter) if @course_filter.present?
    
    # 基于推荐信的申请标记
    @recommendation_applications = []
    RecommendationLetter.where(status: 'approved').each do |rec|
      # Find student user
      student = User.find_by(email: rec.student_email)
      
      if student
        app = Application.find_by(user_id: student.id, course_id: rec.course_id)
        @recommendation_applications << app.id if app
      else
        # Log missing student information
        Rails.logger.warn "Recommendation Letter ##{rec.id} has approved status but student user with email #{rec.student_email} not found"
      end
    end
  end
  
  def show
    # 检查该申请是否是基于推荐信
    @recommendation_letter = nil
    if @application.present?
      @recommendation_letter = RecommendationLetter.find_by(
        student_email: @application.user.email,
        course_id: @application.course_id,
        status: 'approved'
      )
    end
  end
  
  def new
    @application = @course.applications.build
    
    if params[:student_email].present?
      @student = User.find_by(email: params[:student_email])
      if @student
        @application.user_id = @student.id
      else
        redirect_to admin_course_path(@course), alert: 'Student not found'
      end
    end
  end
  
  def create
    @application = @course.applications.build(application_params)
    
    if @application.save
      redirect_to admin_course_application_path(@course, @application), notice: 'Application was successfully created.'
    else
      render :new
    end
  end
  
  def edit
    @course = @application.course
  end
  
  def update
    # 支持简单表单提交status参数
    if params[:status].present?
      update_params = { status: params[:status] }
    else
      update_params = application_params
    end
    
    if @application.update(update_params)
      if params[:status].present?
        redirect_back(fallback_location: admin_applications_path, notice: "Application was successfully #{@application.status}.")
      else
        redirect_to admin_application_path(@application), notice: 'Application was successfully updated.'
      end
    else
      @course = @application.course
      render :edit
    end
  end
  
  # 批准申请
  def approve
    if @application.update(status: 'approved')
      redirect_back(fallback_location: admin_applications_path, notice: 'Application was successfully approved.')
    else
      redirect_back(fallback_location: admin_applications_path, alert: 'Could not approve application.')
    end
  end
  
  # 拒绝申请
  def reject
    if @application.update(status: 'rejected')
      redirect_back(fallback_location: admin_applications_path, notice: 'Application was successfully rejected.')
    else
      redirect_back(fallback_location: admin_applications_path, alert: 'Could not reject application.')
    end
  end
  
  def destroy
    @application.destroy
    redirect_to admin_course_path(@course), notice: 'Application was successfully deleted.'
  end
  
  private
  
  def set_course
    @course = Course.find(params[:course_id]) if params[:course_id]
  end
  
  def set_application
    if params[:course_id]
      @course = Course.find(params[:course_id])
      @application = @course.applications.find(params[:id])
    else
      @application = Application.find(params[:id])
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to(params[:course_id] ? admin_course_path(@course) : admin_applications_path, 
                alert: 'Application not found.')
  end
  
  def application_params
    params.require(:application).permit(
      :user_id,
      :position_type,
      :experience,
      :programming_languages,
      :available_hours,
      :status
    )
  end
end 