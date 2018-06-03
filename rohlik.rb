# frozen_string_literal: true

require 'uri'
require 'net/https'
require 'json'
require 'money'
require 'prometheus/client/metric'

Money.use_i18n = false

module RohlikAPI
  class Entity
    attr_reader :id, :attributes

    def initialize(attributes)
      @id ||= Integer(attributes.fetch('id'))
      @attributes ||= attributes.freeze
    end

    def to_json(*options)
      @attributes.to_json(*options)
    end

    protected

    def read_attribute(name)
      @attributes.fetch(name.to_s)
    end
  end

  class Product < Entity
    ATTRIBUTES = %w[
      id description ingredients country_of_origin
      image image_large images unit categories primary_category brand
      badge weight weight_variations flags crc32 name
    ].freeze
  end

  class Category < Entity
  end

  class Inventory < Entity
    alias product_id id

    def price
      extract_money(__method__).to_f
    end

    def price_for_unit
      extract_money(__method__).to_f
    end

    def available
      read_attribute(__method__)
    end

    protected

    def extract_money(attribute)
      value = read_attribute(attribute.to_s)
      amount, currency = value.values_at('amount', 'currency')
      Money.new(amount * 100, currency)
    end
  end

  class Sale < Entity
    def initialize(attributes)
      @product = Product.new(attributes.delete('product'))
      @id = @product.id
      super
    end

    def price
      read_attribute(:sale_price).fetch('amount')
    end

    def price_for_unit
      read_attribute(__method__).fetch('amount')
    end

    def available
      read_attribute(__method__)
    end

    def type
      read_attribute(:sale_type)
    end
  end

  class Client
    def initialize(host: 'www.rohlik.cz',
                   port: URI::HTTPS::DEFAULT_PORT,
                   secure: true)
      @http = Net::HTTP.new(host, port)
      @http.use_ssl = secure
      @http.start
    end

    def products
      transform(http.request_post('/api/v4/products', nil),
                products: Product)
    end

    def categories
      transform(http.request_get('/api/v2/categories'),
                categories: Category)
    end

    def inventory(store = 8791)
      transform(http.request_get("/api/v2/stores/#{store}/products/inventory"),
                products: Inventory)
    end

    def sales(store = 8791)
      transform(http.request_get("/api/v2/stores/#{store}/sales"),
                sales: Sale)
    end

    protected

    def transform(response, **transforms)
      data = decode(response)

      raise 'only one transformation supported' if transforms.size != 1

      key, model = transforms.first

      data.fetch(key.to_s).map(&model.method(:new))
    end

    attr_reader :http

    def decode(response)
      case content_type = response['content-type']
        # yes, the API returns JSON with  application/octet-stream content-type
      when 'application/json', 'application/octet-stream', 'application/json;charset=UTF-8'
        JSON.parse(response.body)
      else raise "unsupported content type: #{content_type}"
      end
    end
  end

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
