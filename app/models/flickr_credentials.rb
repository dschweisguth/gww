require 'net/http'
require 'timeout'
require 'xmlsimple'

class FlickrCredentials
  FILE = YAML.load_file "#{Rails.root.to_s}/config/flickr_credentials.yml"
  CREDENTIALS = FILE['flickr_credentials']
  SECRET = CREDENTIALS['secret']
  API_KEY = CREDENTIALS['api_key']
  AUTH_TOKEN = CREDENTIALS['auth_token']
  SCORE_TOPIC_URL = CREDENTIALS['score_topic_url']

  class << self; attr_accessor :retry_quantum end
  @retry_quantum = 30

  def self.request(api_method, extra_params = {})
    url = api_url api_method, extra_params
    xml = submit url
    parsed_xml = XmlSimple.xml_in xml
    if parsed_xml['stat'] != 'ok'
      # One way we get here is if we request information we don't have access to, e.g. a deleted user
      raise FlickrRequestFailedError, "stat=\"#{parsed_xml['stat']}\""
    end
    parsed_xml
  end

  private

  def self.api_url(api_method, extra_params = {})
    params = {
      'api_key' => API_KEY,
      'auth_token' => AUTH_TOKEN,
      'group_id' => '32053327@N00',
      'method' => api_method
    }
    params.merge! extra_params
    params['api_sig'] = signature params
    'http://api.flickr.com/services/rest/?' +
      params.each_with_object('') do |param, query_string|
        if ! query_string.empty?
          query_string << '&'
        end
        query_string << param[0] + '=' + param[1]
      end
  end

  def self.signature(params)
    signature = SECRET
    params.keys.sort.each { |name| signature += name + params[name] }
    Digest::MD5.hexdigest signature
  end

  def self.submit(url)
    failure_count = 0
    begin
      response = Net::HTTP.get_response URI.parse url
      response.body
    rescue StandardError, Timeout::Error => e
      failure_count += 1
      sleep_time = retry_quantum * (2 ** failure_count)
      warning = e.message
      if failure_count <= 3
        warning += "; sleeping #{sleep_time} seconds and retrying ..."
      end
      Rails.logger.warn warning
      if failure_count <= 3
        sleep sleep_time
        retry
      else
        raise FlickrRequestFailedError, "Request and retries failed; gave up."
      end
    end
  end

  class FlickrRequestFailedError < StandardError
  end

end
