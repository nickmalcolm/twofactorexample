require 'test_helper'

class TwoFactorAuthenticationControllerTest < ActionController::TestCase

  def setup
    log_in @user = users(:nick)
  end

  test "should get setup" do
    get :setup
    assert_response :success
  end

  test "can setup 2fa with country code and phone number and be txted" do
    response = stub()
    response.expects("ok?").returns(true)
    response.expects(:id).returns(1234) # Our new Authy ID

    Authy::API.expects(:register_user).with(
      email: @user.email,
      cellphone: 123,
      country_code: 1
    ).returns(response)

    patch :register, setup: {country_code: 1, cellphone: 123}
    assert_redirected_to two_factor_authentication_verify_path
    assert_equal 1234, session[:pending_authy_id], "The pending authy id should be stored in session"
  end

  test "should get verify" do
    get :verify
    assert_response :success
  end

  test "can successfully verify and be directed to the home page" do
    session[:pending_authy_id] = pending_authy_id = 1234
    response = stub()
    response.expects("ok?").returns(true)
    Authy::API.expects(:verify).with(
      id: pending_authy_id,
      token: "authy-token",
      force: true
    ).returns(response)

    post :verify, verify: {token: "authy-token"}
    assert_redirected_to root_path

    @user.reload
    assert_equal pending_authy_id, @user.authy_id
  end

end
