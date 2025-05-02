class RecommendationLettersController < ApplicationController
  before_action :set_recommendation_letter, only: [:show]
  
  def new
    @recommendation_letter = RecommendationLetter.new
    @courses = Course.all.order(:subject, :course_number)
  end
  
  def create
    @recommendation_letter = RecommendationLetter.new(recommendation_letter_params)
    
    if @recommendation_letter.save
      redirect_to @recommendation_letter, notice: 'Recommendation letter was successfully submitted.'
    else
      @courses = Course.all.order(:subject, :course_number)
      render :new
    end
  end
  
  def show
    # The recommendation letter is set by the before_action
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
      :content
    )
  end
end 