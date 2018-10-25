# This file is used by Rack-based servers to start the application.

require "jets"
require 'prometheus/middleware/collector'

use Prometheus::Middleware::Collector
run Jets.application
