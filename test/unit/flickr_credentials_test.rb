class FlickrCredentialsTest < Test::Unit::TestCase
    def test_all
	credentials = FlickrCredentials.new
	assert ! credentials.secret.empty?
	assert ! credentials.api_key.empty?
	assert ! credentials.auth_token.empty?
    end
end
