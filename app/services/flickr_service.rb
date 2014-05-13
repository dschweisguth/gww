require 'net/http'
require 'timeout'
require 'xmlsimple'

class FlickrService
  API_URL = "https://api.flickr.com/services/rest/"
  FILE = YAML.load_file "#{Rails.root.to_s}/config/flickr_credentials.yml"
  CREDENTIALS = FILE['flickr_credentials']
  SECRET = CREDENTIALS['secret']
  OAUTH_CONSUMER_KEY = CREDENTIALS['api_key']
  OAUTH_TOKEN = CREDENTIALS['oauth_token']
  OAUTH_TOKEN_SECRET = CREDENTIALS['oauth_token_secret']
  GROUP_ID = CREDENTIALS['group_id']
  SCORE_TOPIC_URL = CREDENTIALS['score_topic_url']

  def self.instance
    @instance ||= new
  end

  attr_accessor :retry_quantum

  def initialize
    @retry_quantum = 30
  end

  def wait_between_requests
    sleep Rails.env.test? ? 0 : 1.1
  end

  def groups_get_info(opts)
    request 'flickr.groups.getInfo', opts
  end

  def groups_pools_get_photos(opts)
    request 'flickr.groups.pools.getPhotos', opts
  end

  def people_get_info(opts)
    request 'flickr.people.getInfo', opts
  end

  def photos_get_favorites(opts)
    request 'flickr.photos.getFavorites', opts
  end

  def photos_comments_get_list(opts)
    request 'flickr.photos.comments.getList', opts
  end

  # Public for testing
  def request(api_method, extra_params = {})
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

  private def api_url(api_method, extra_params = {})
    params = {
      'oauth_version' => '1.0',
      'oauth_signature_method' => 'HMAC-SHA1',
      'oauth_consumer_key' => OAUTH_CONSUMER_KEY,
      'oauth_token' => OAUTH_TOKEN,
      'oauth_timestamp' => Time.now.to_i.to_s,
      'oauth_nonce' => rand(10 ** 8).to_s.rjust(8, '0'),
      'method' => api_method
    }
    params.merge! extra_params
    params['oauth_signature'] = signature params
    "#{API_URL}?" +
      params.each_with_object('') do |param, query_string|
        if ! query_string.empty?
          query_string << '&'
        end
        query_string << param[0] + '=' + param[1]
      end
  end

  private def signature(params)
    key = "#{SECRET}&#{OAUTH_TOKEN_SECRET}"
    base_string = "GET&#{oauth_encode API_URL}&" +
      oauth_encode(params.keys.sort.map { |name| "#{name}=#{oauth_encode params[name]}" }.join('&'))
    signature = Base64.encode64 OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha1'), key, base_string)
    oauth_encode signature.chomp
  end

  private def oauth_encode(string)
    URI.encode string, /[^\w\-.~]/
  end

  private def submit(url)
    failure_count = 0
    begin
      get(url).body
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

  # public so that it can be mocked in tests
  def get(url)
    uri = URI.parse url
    http = Net::HTTP.new uri.host, uri.port
    http.use_ssl = true
    http.request Net::HTTP::Get.new(uri.request_uri)
  end

  class FlickrRequestFailedError < StandardError
  end

end
