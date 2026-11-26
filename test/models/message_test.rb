require "test_helper"

class MessageTest < ActiveSupport::TestCase
  test "a message needs some content" do
    message = Message.new(role: "user", content: "")
    assert_not message.valid?
  end

  test "the role must be user or assistant" do
    message = Message.new(role: "robot", content: "Hello")
    assert_not message.valid?
    assert_includes message.errors[:role], "is not included in the list"
  end
end
