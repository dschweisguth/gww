class FlickrCredentials
    require 'yaml'

    def initialize
        file = YAML.load_file("#{RAILS_ROOT}/config/flickr_credentials.yml")
        @credentials = file['flickr_credentials']
    end

    def secret
	@credentials['secret']
    end

    def api_key
	@credentials['api_key']
    end

    def auth_token
	@credentials['auth_token']
    end

end
