# frozen_string_literal: true

require 'rack'
require 'prometheus/middleware/collector'
require 'prometheus/middleware/exporter'

use Rack::Deflater
use Prometheus::Middleware::Collector
use Prometheus::Middleware::Exporter

require_relative 'rohlik'

prometheus = Prometheus::Client.registry

metrics = []
metrics << RohlikAPI::PrometheusMetric.new(:rohlik_product_price,
                                           'Rohlik product prices',
                                           :price)
metrics << RohlikAPI::PrometheusMetric.new(:rohlik_product_price_per_unit,
                                           'Rohlik product prices per unit',
                                           :price_for_unit)
metrics << RohlikAPI::PrometheusMetric.new(:rohlik_product_availability,
                                           'Rohlik product availability',
                                           :available)

metrics.each(&prometheus.method(:register))

run ->(_) { [200, { 'Content-Type' => 'text/html' }, ['OK']] }
