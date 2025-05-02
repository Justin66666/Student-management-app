class Admin::RecommendationLettersController < Admin::ApplicationController
  before_action :set_recommendation_letter, only: [:show, :edit, :update, :destroy]
  
  def index
    @recommendation_letters = RecommendationLetter.all.includes(:course)
    
    # Apply status filter if provided
    if params[:status].present?
      @recommendation_letters = @recommendation_letters.where(status: params[:status])
    end
    
    # Apply course filter if provided
    if params[:course_id].present?
      @recommendation_letters = @recommendation_letters.where(course_id: params[:course_id])
    end
    
    # Order by most recent first
    @recommendation_letters = @recommendation_letters.order(created_at: :desc)
  end
  
  def show
    # The recommendation letter is set by the before_action
  end
  
  def edit
    # The recommendation letter is set by the before_action
  end
  
  def update
    # 如果是从简单按钮表单提交而不是编辑表单，处理status参数
    if params[:status].present?
      update_params = { status: params[:status] }
    else
      update_params = recommendation_letter_params
    end
    
    if @recommendation_letter.update(update_params)
      # Force application creation if recommendation was approved
      if update_params[:status] == 'approved'
        # Find or create student user
        student = User.find_by(email: @recommendation_letter.student_email)
        
        unless student
          # If student doesn't exist, create one
          random_password = SecureRandom.hex(8)
          student = User.create!(
            email: @recommendation_letter.student_email,
            password: random_password,
            role: :student,
            approved: true
          )
          Rails.logger.info "Created new student user with email: #{student.email}"
        end
        
        # Check if an application already exists
        existing_application = Application.find_by(user_id: student.id, course_id: @recommendation_letter.course_id)
        application_created = false
        
        if existing_application
          # Update existing application if needed
          if existing_application.status != 'approved'
            existing_application.update(status: 'approved')
            Rails.logger.info "Updated existing application ##{existing_application.id} to approved status"
          end
          redirect_to admin_application_path(existing_application), 
            notice: "Recommendation letter was approved and existing application ##{existing_application.id} was updated to approved status."
        else
          # Create new application
          new_application = Application.create!(
            user_id: student.id,
            course_id: @recommendation_letter.course_id,
            position_type: :grader,
            experience: "Recommended by #{@recommendation_letter.instructor_name} (#{@recommendation_letter.instructor_email})",
            programming_languages: "Not specified in recommendation",
            available_hours: 5,
            status: 'approved'
          )
          Rails.logger.info "Created new application ##{new_application.id} with approved status"
          redirect_to admin_application_path(new_application), 
            notice: "Recommendation letter was approved and a new application was created and approved automatically."
        end
        return # Return early to avoid the default redirect
      elsif update_params[:status] == 'rejected'
        redirect_to admin_recommendation_letters_path, 
          notice: "Recommendation letter was rejected."
        return
      end
      
      redirect_to admin_recommendation_letter_path(@recommendation_letter), 
        notice: "Recommendation letter was successfully updated."
    else
      render :edit
    end
  end
  
  def destroy
    @recommendation_letter.destroy
    redirect_to admin_recommendation_letters_path, notice: 'Recommendation letter was successfully deleted.'
  end
  
  private
  
  def set_recommendation_letter
    @recommendation_letter = RecommendationLetter.find(params[:id])
  end
  
  def recommendation_letter_params
    params.require(:recommendation_letter).permit(
      :instructor_name, 
      :instructor_email, 
      :student_name, 
      :student_email, 
      :course_id, 
      :content,
      :status
    )
  end
end 