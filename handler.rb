# frozen_string_literal: true

require_relative './vendor/bundler/setup'
require_relative 'prometheus'
require 'prometheus/client/formats/text'

def main(*)
  registry = Prometheus::Client.registry
  output = Prometheus::Client::Formats::Text.marshal(registry)

  {
    statusCode: 200,
    body: output
  }
end
