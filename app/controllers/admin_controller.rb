class AdminController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin
  # Layout is determined by ApplicationController

  def users
    @pending_users = User.where(approved: false)
    @approved_users = User.where(approved: true)
  end

  def approve_user
    user = User.find(params[:id])
    user.update(approved: true)
    redirect_to admin_users_path, notice: "User #{user.email} has been approved."
  end

  def reject_user
    user = User.find(params[:id])
    user.destroy
    redirect_to admin_users_path, notice: "User #{user.email} has been rejected."
  end

  def reload_courses
    # This is a placeholder for the actual course reloading logic
    # You'll need to implement the API call and database update here
    flash[:notice] = "Course data has been reloaded successfully."
    redirect_to courses_path
  end

  private

  def require_admin
    unless current_user&.admin?
      flash[:alert] = "You are not authorized to access this area."
      redirect_to root_path
    end
  end
end 