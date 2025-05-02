require "test_helper"

class Admin::CoursesControllerTest < ActionDispatch::IntegrationTest
  test "should get reload" do
    get admin_courses_reload_url
    assert_response :success
  end
end
