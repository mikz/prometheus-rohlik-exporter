require 'spec_helper'

RSpec.describe MetricsController, type: :controller do
  it 'show returns a success response' do
    event = payload('metrics-show')
    controller = described_class.new(event, :show)
    response = controller.show

    expect(response['body']).to include("# TYPE rohlik_product_price gauge\n")
  end
end
