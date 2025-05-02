class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  
  # Make current_user available to views
  helper_method :current_user
  
  # Ensure layout selection is consistent
  layout :determine_layout
  
  private
  
  # Determine the proper layout based on controller namespace and user role
  def determine_layout
    # Admin namespace gets admin layout
    return 'admin' if self.class.name.start_with?('Admin::')
    
    # Default to application layout
    'application'
  end
end
