require 'rails_helper'

RSpec.describe HomeController, type: :controller do
  render_views

  describe 'GET index' do
    it 'has a 200 status code' do
      get :index
      expect(response.status).to eq(200)
      expect(response.body).to match(/Code Status \(master branch\)/)
    end
  end
end
