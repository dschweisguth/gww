class FlickrCredentialsTest < Test::Unit::TestCase
    def test_all
	credentials = FlickrCredentials.new
	assert_not_nil ! credentials.secret.empty?
	assert_not_nil ! credentials.api_key.empty?
	assert_not_nil ! credentials.auth_token.empty?
    end
end
