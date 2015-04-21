require 'test_helper'

class SessionsControllerTest < ActionController::TestCase
  test "should get new" do
    get :new
    assert_response :success
  end

  test "can sign in" do
    post :create, session: {
      email: "nick@revert.io",
      password: "secret"
    }
    assert_redirected_to root_path
    assert_equal users(:nick).id, session[:user_id]
  end

end
