require 'rails_helper'

RSpec.describe HomeController, type: :controller do
  describe 'GET #index' do
    context 'when user is not authenticated' do
      it 'returns http success' do
        get :index
        expect(response).to have_http_status(:success)
      end

      it 'renders the index template' do
        get :index
        expect(response).to render_template(:index)
      end

      it 'does not require authentication' do
        get :index
        expect(response).to have_http_status(:success)
      end
    end

    context 'when user is authenticated' do
      let(:user) { create(:user) }

      before do
        sign_in user
      end

      it 'returns http success' do
        get :index
        expect(response).to have_http_status(:success)
      end

      it 'renders the index template' do
        get :index
        expect(response).to render_template(:index)
      end

      it 'allows authenticated users to access' do
        get :index
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe 'authentication' do
    it 'skips authentication for index action' do
      # Test that the action is accessible without authentication
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/').to route_to('home#index')
    end

    it 'routes root to home#index' do
      expect(get: '/').to route_to('home#index')
    end
  end
end 