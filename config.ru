# frozen_string_literal: true

require 'rack'
require 'prometheus/middleware/collector'
require 'prometheus/middleware/exporter'

use Rack::Deflater
use Prometheus::Middleware::Collector
use Prometheus::Middleware::Exporter

require_relative 'prometheus'

run ->(_) { [200, { 'Content-Type' => 'text/html' }, ['OK']] }
