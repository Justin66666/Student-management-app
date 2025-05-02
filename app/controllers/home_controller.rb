class HomeController < ApplicationController
  def index
    if user_signed_in?
      @user_role = current_user.role
    end
  end
end 