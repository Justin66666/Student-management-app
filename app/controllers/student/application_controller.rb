class Student::ApplicationController < ApplicationController
  before_action :authenticate_user!
  before_action :require_student
  # Using layout determination from parent ApplicationController

  private

  def require_student
    unless current_user&.student?
      flash[:alert] = "You are not authorized to access this area."
      redirect_to root_path
    end
  end
end 