require 'net/http'
require 'timeout'
require 'xmlsimple'

class FlickrCredentials
  FILE = YAML.load_file "#{Rails.root.to_s}/config/flickr_credentials.yml"
  CREDENTIALS = FILE['flickr_credentials']
  SECRET = CREDENTIALS['secret']
  OAUTH_CONSUMER_KEY = CREDENTIALS['api_key']
  OAUTH_TOKEN = CREDENTIALS['oauth_token']
  OAUTH_TOKEN_SECRET = CREDENTIALS['oauth_token_secret']
  SCORE_TOPIC_URL = CREDENTIALS['score_topic_url']

  class << self; attr_accessor :retry_quantum end
  @retry_quantum = 30

  def self.request(api_method, extra_params = {})
    url = api_url api_method, extra_params
    xml = submit url
    if xml !~ /<.*?>/m
      raise FlickrRequestFailedError, "Response was not XML: #{xml}"
    end
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
      'oauth_version' => '1.0',
      'oauth_signature_method' => 'HMAC-SHA1',
      'oauth_consumer_key' => OAUTH_CONSUMER_KEY,
      'oauth_token' => OAUTH_TOKEN,
      'oauth_timestamp' => Time.now.to_i.to_s,
      'oauth_nonce' => rand(10 ** 8).to_s.rjust(8, '0'),
      'method' => api_method,
      'group_id' => '32053327@N00' # TODO Dave move this to the calls that need it
    }
    params.merge! extra_params
    params['oauth_signature'] = signature params
    'http://api.flickr.com/services/rest/?' +
      params.each_with_object('') do |param, query_string|
        if ! query_string.empty?
          query_string << '&'
        end
        query_string << param[0] + '=' + param[1]
      end
  end

  def self.signature(params)
    key = "#{SECRET}&#{OAUTH_TOKEN_SECRET}"
    base_string = "GET&#{oauth_encode "http://api.flickr.com/services/rest/"}&" +
      oauth_encode(params.keys.sort.map { |name| "#{name}=#{oauth_encode params[name]}" }.join('&'))
    Base64.encode64 OpenSSL::HMAC.digest(OpenSSL::Digest::Digest.new('sha1'), key, base_string)
  end

  def self.oauth_encode(string)
    URI.encode string, /[^\w\-.~]/
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
