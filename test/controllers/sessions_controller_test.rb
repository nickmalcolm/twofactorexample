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

  test "with 2FA enabled, sign in redirects to #two_factor_required" do
    user = users(:nick)
    user.update(authy_id: 1)

    post :create, session: {
      email: "nick@revert.io",
      password: "secret"
    }
    assert_redirected_to session_two_factor_required_path
    assert_nil session[:user_id]
  end

  test "posting a valid token to #two_factor_verification signs in" do
    user = users(:nick)
    user.update(authy_id: 1)

    Authy::API.expects(:verify).with(
      id: 1,
      token: "authy-token",
      force: true
    ).returns(stub("ok?" => true))

    post :two_factor_verification, verification: {
      token: "authy-token"
    }
    assert_redirected_to root_path
    assert_equal users(:nick).id, session[:user_id]
  end

  test "posting an invalid token to #two_factor_verification requires sign in" do
    user = users(:nick)
    user.update(authy_id: 1)

    Authy::API.expects(:verify).with(
      id: 1,
      token: "authy-token",
      force: true
    ).returns(stub("ok?" => false))

    post :two_factor_verification, verification: {
      token: "authy-token"
    }
    assert_redirected_to new_session_path
    assert_nil session[:user_id]
  end

end
