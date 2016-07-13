require 'rails_helper'

RSpec.describe BrandsController, type: :controller do
  render_views

  describe 'GET index' do
    it 'has a 200 status code' do
      get :index
      expect(response.status).to eq(200)
      expect(response.body).to match(/mdl-layout__content/)
    end
  end

  describe 'responds to' do
    it 'responds to html by default' do
      get :index
      expect(response.content_type).to eq 'text/html'
    end

    it 'responds to custom formats when provided in the params' do
      get :index, format: :json
      expect(response.content_type).to eq 'application/json'
    end
  end
end
