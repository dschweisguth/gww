class FlickrCredentials
  FILE = YAML.load_file "#{RAILS_ROOT}/config/flickr_credentials.yml"
  CREDENTIALS = FILE['flickr_credentials']
  SECRET = CREDENTIALS['secret']
  API_KEY = CREDENTIALS['api_key']
  AUTH_TOKEN = CREDENTIALS['auth_token']

  def self.request(api_method, extra_params = {})
    url = api_url api_method, extra_params
    xml = submit url
    XmlSimple.xml_in xml
  end

  def self.api_url(api_method, extra_params = {})
    params = {
      'api_key' => API_KEY,
      'auth_token' => AUTH_TOKEN,
      'group_id' => '32053327@N00',
      'method' => api_method
    }
    params.merge! extra_params
    params['api_sig'] = signature params
    query_string = ''
    params.each_pair do |name, value|
      if ! query_string.empty?
        query_string += '&'
      end
      query_string += name + '=' + value
    end
    'http://api.flickr.com/services/rest/?' + query_string
  end

  def self.signature(params)
    signature = SECRET
    params.keys.sort.each { |name| signature += name + params[name] }
    MD5.hexdigest signature
  end

  def self.submit(url)
    failure_count = 0
    begin
      response = Net::HTTP.get_response URI.parse url
      response.body
    rescue StandardError, Timeout::Error => e
      failure_count += 1
      sleep_time = 30 * (2 ** failure_count)
      warning = e.message
      if failure_count <= 3
        warning += "; sleeping #{sleep_time} seconds and retrying ..."
      end
      logger.warn warning
      if failure_count <= 3
        sleep sleep_time
        retry
      elsif
        raise
      end
    end
  end

end
