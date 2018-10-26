require 'prometheus/middleware/exporter'

Jets.application.routes.draw do
  get 'metrics', to: 'metrics#show'
end
