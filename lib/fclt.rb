require 'yaml'
require 'digest/md5'
require 'timeout'
require 'net/http'
require 'uri'
require 'rubygems'
require 'xmlsimple'

FCLT_ROOT = File.expand_path(File.dirname(__FILE__) + "/..")

FILE = YAML.load_file "#{FCLT_ROOT}/config/fclt.yml"
CREDENTIALS = FILE['flickr_credentials']
API_KEY = CREDENTIALS['api_key']
SECRET = CREDENTIALS['secret']
AUTH_TOKEN = CREDENTIALS['auth_token']

def request(api_method, extra_params = {})
  url = api_url api_method, extra_params
  xml = submit url
  XmlSimple.xml_in xml
end

def api_url(method, extra_params = {})
  params = {
    'method' => method
  }
  signed_url 'http://api.flickr.com/services/rest/', params.merge(extra_params)
end

def signed_url(base_url, extra_params = {})
  params = {
    'api_key' => API_KEY
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
  base_url + '?' + query_string
end

def signature(params)
  signature = SECRET
  params.keys.sort.each { |name| signature += name + params[name] }
  Digest::MD5.hexdigest signature
end

def submit(url)
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
    warn warning
    if failure_count <= 3
      sleep sleep_time
      retry
    elsif
      raise
    end
  end
end

def post(method, extra_params = {})
  params = {
    'api_key' => API_KEY,
    'method' => method
  }
  params.merge! extra_params
  params['api_sig'] = signature params
  response = Net::HTTP.post_form(
    URI.parse('http://api.flickr.com/services/rest/'), params)
  xml = response.body
  XmlSimple.xml_in xml
end
