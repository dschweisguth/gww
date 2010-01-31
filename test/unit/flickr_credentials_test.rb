require File.dirname(__FILE__) + '/../test_helper'

class FlickrCredentialsTest < Test::Unit::TestCase
  def test_new
    credentials = FlickrCredentials.new
    assert ! credentials.secret.empty?
    assert ! credentials.api_key.empty?
    assert ! credentials.auth_token.empty?
  end
end
