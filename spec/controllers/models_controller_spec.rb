require 'rails_helper'

RSpec.describe ModelsController, type: :controller do
  render_views
  describe 'GET index' do
    it 'responds to /Samsung query' do
      get :index, params: { brand_id: 'Samsung' }
      expect(response.content_type).to eq 'text/html'
    end
  end

  describe 'GET show' do
    it 'responds to Galaxy On7 Pro query' do
      get :show, params: { brand_id: 'Samsung', id: 'Galaxy On7 Pro' }
      expect(response.content_type).to eq 'text/html'
    end
  end
end
