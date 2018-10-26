class MetricsController < ApplicationController
  raise "missing rohlik metrics" unless Rohlik::PrometheusMetric

  def show
    render body: ::Prometheus::Client::Formats::Text.marshal(registry)
  end

  protected

  def registry
    ::Prometheus::Client.registry
  end
end
