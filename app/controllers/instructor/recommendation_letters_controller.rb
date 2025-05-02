class Instructor::RecommendationLettersController < Instructor::ApplicationController
  before_action :set_course, only: [:index, :new, :create]
  
  def index
    if params[:course_id]
      @recommendation_letters = @course.recommendation_letters
    else
      # When accessed outside a course context
      @recommendation_letters = RecommendationLetter.where(instructor_email: current_user.email)
    end
  end
  
  def new
    @recommendation_letter = @course.recommendation_letters.build
  end
  
  def create
    @recommendation_letter = @course.recommendation_letters.build(recommendation_letter_params)
    @recommendation_letter.instructor_email = current_user.email
    
    if @recommendation_letter.save
      redirect_to instructor_course_path(@course), notice: 'Recommendation letter was successfully submitted.'
    else
      render :new
    end
  end
  
  private
  
  def set_course
    @course = Course.find(params[:course_id]) if params[:course_id]
  end
  
  def recommendation_letter_params
    params.require(:recommendation_letter).permit(
      :instructor_name,
      :student_name, 
      :student_email, 
      :content
    )
  end
end 