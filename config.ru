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
                                           :inventory, :price)
metrics << RohlikAPI::PrometheusMetric.new(:rohlik_product_price_per_unit,
                                           'Rohlik product prices per unit',
                                           :inventory, :price_for_unit)
metrics << RohlikAPI::PrometheusMetric.new(:rohlik_product_availability,
                                           'Rohlik product availability',
                                           :inventory, :available)

metrics << RohlikAPI::PrometheusMetric.new(:rohlik_sale_availability,
                                           'Rohlik sale availability',
                                           :sales, :available)

metrics << RohlikAPI::PrometheusMetric.new(:rohlik_sale_price,
                                           'Rohlik sale price',
                                           :sales, :price)

metrics << RohlikAPI::PrometheusMetric.new(:rohlik_sale_price_per_unit,
                                           'Rohlik sale price per unit',
                                           :sales, :price_for_unit)

metrics.each(&prometheus.method(:register))

run ->(_) { [200, { 'Content-Type' => 'text/html' }, ['OK']] }
