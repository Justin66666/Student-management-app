class Instructor::ApplicationController < ApplicationController
  before_action :authenticate_user!
  before_action :require_instructor
  # Using layout determination from parent ApplicationController

  private

  def require_instructor
    unless current_user&.instructor?
      flash[:alert] = "You are not authorized to access this area."
      redirect_to root_path
    end
  end
end 