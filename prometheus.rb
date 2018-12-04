# frozen_string_literal: true

require 'prometheus/client'
require 'prometheus/client/metric'

require_relative 'rohlik'

module RohlikAPI
  class PrometheusMetric < Prometheus::Client::Metric
    attr_reader :attribute

    def initialize(name, docstring, kind, attribute)
      super(name, docstring)
      @rohlik = RohlikAPI::Client.new
      @kind = kind
      @attribute = attribute.freeze
    end

    def type
      :gauge
    end

    def values
      synchronize do
        inventory = @rohlik.public_send(@kind)

        inventory.map do |product|
          [{ product_id: product.id }, product.public_send(attribute)]
        end.to_h
      end
    end
  end
end

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
