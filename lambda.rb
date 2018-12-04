# frozen_string_literal: true

require 'json'
require 'rack'
require 'base64'

# Global object that responds to the call method. Stay outside of the handler
# to take advantage of container reuse
$app ||= Rack::Builder.parse_file('config.ru').first

def event_to_env(event)
  {
    'REQUEST_METHOD' => event['httpMethod'],
    'SCRIPT_NAME' => '',
    'PATH_INFO' => event['path'] || '',
    'QUERY_STRING' => event['queryStringParameters'] || '',
    'SERVER_NAME' => 'localhost',
    'SERVER_PORT' => 443,

    'rack.version' => Rack::VERSION,
    'rack.url_scheme' => 'https',
    'rack.input' => StringIO.new(event['body'] || ''),
    'rack.errors' => $stderr
  }.merge(event['headers']&.transform_keys { |k| "HTTP_#{k.upcase}".tr('-', '_') })
end

def encode(body, headers)
  if headers['Content-Encoding']
    [Base64.encode64(body), true]
  else
    [body, false]
  end
end

def status_description(code)
  "#{code} #{Rack::Utils::HTTP_STATUS_CODES.fetch(code)}"
end

def response(status, headers, body)
  # We return the structure required by AWS API Gateway since we integrate with it
  # https://docs.aws.amazon.com/apigateway/latest/developerguide/set-up-lambda-proxy-integrations.html
  content, base64 = encode(body, headers)

  {
    'statusCode' => status,
    'headers' => headers,
    'body' => content,
    'isBase64Encoded' => base64
  }
end

def call(env)
  # Response from Rack must have status, headers and body
  status, headers, body = $app.call(env)

  # body is an array. We simply combine all the items to a single string
  body_content = StringIO.new
  body.each do |item|
    body_content << item.to_s
  end

  response(status, headers, body_content.string)
rescue StandardError => msg
  # If there is any exception, we return a 500 error with an error message
  response(500, {}, msg.message)
end

def handler(event:, context:)
  # Environment required by Rack (http://www.rubydoc.info/github/rack/rack/file/SPEC)
  call event_to_env(event)
end
