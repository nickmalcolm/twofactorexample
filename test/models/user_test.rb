require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "can authenticate a user" do
    assert_equal users(:nick), User.authenticate("nick@revert.io", "secret")
  end

  test "can't authenticate a user with a bad password" do
    assert !User.authenticate("nick@revert.io", "socrot")
  end
end
