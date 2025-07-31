require 'rails_helper'

RSpec.describe 'Notes routing', type: :routing do
  describe 'root route' do
    it 'routes to home#index' do
      expect(get: '/').to route_to('home#index')
    end
  end

  describe 'notes routes' do
    it 'routes GET /notes to notes#index' do
      expect(get: '/notes').to route_to('notes#index')
    end

    it 'routes GET /notes/:id to notes#show' do
      expect(get: '/notes/1').to route_to('notes#show', id: '1')
    end

    it 'routes GET /notes/new to notes#new' do
      expect(get: '/notes/new').to route_to('notes#new')
    end

    it 'routes POST /notes to notes#create' do
      expect(post: '/notes').to route_to('notes#create')
    end

    it 'routes GET /notes/:id/edit to notes#edit' do
      expect(get: '/notes/1/edit').to route_to('notes#edit', id: '1')
    end

    it 'routes PATCH /notes/:id to notes#update' do
      expect(patch: '/notes/1').to route_to('notes#update', id: '1')
    end

    it 'routes PUT /notes/:id to notes#update' do
      expect(put: '/notes/1').to route_to('notes#update', id: '1')
    end

    it 'routes DELETE /notes/:id to notes#destroy' do
      expect(delete: '/notes/1').to route_to('notes#destroy', id: '1')
    end
  end

  describe 'devise routes' do
    it 'routes GET /users/sign_in to devise/sessions#new' do
      expect(get: '/users/sign_in').to route_to('devise/sessions#new')
    end

    it 'routes POST /users/sign_in to devise/sessions#create' do
      expect(post: '/users/sign_in').to route_to('devise/sessions#create')
    end

    it 'routes DELETE /users/sign_out to devise/sessions#destroy' do
      expect(delete: '/users/sign_out').to route_to('devise/sessions#destroy')
    end

    it 'routes GET /users/sign_up to devise/registrations#new' do
      expect(get: '/users/sign_up').to route_to('devise/registrations#new')
    end

    it 'routes POST /users to devise/registrations#create' do
      expect(post: '/users').to route_to('devise/registrations#create')
    end

    it 'routes GET /users/password/new to devise/passwords#new' do
      expect(get: '/users/password/new').to route_to('devise/passwords#new')
    end

    it 'routes POST /users/password to devise/passwords#create' do
      expect(post: '/users/password').to route_to('devise/passwords#create')
    end
  end

  describe 'health check route' do
    it 'routes GET /up to rails/health#show' do
      expect(get: '/up').to route_to('rails/health#show')
    end
  end

  describe 'route helpers' do
    it 'generates notes_path' do
      expect(notes_path).to eq('/notes')
    end

    it 'generates note_path' do
      expect(note_path(1)).to eq('/notes/1')
    end

    it 'generates new_note_path' do
      expect(new_note_path).to eq('/notes/new')
    end

    it 'generates edit_note_path' do
      expect(edit_note_path(1)).to eq('/notes/1/edit')
    end

    it 'generates root_path' do
      expect(root_path).to eq('/')
    end

    it 'generates new_user_session_path' do
      expect(new_user_session_path).to eq('/users/sign_in')
    end

    it 'generates new_user_registration_path' do
      expect(new_user_registration_path).to eq('/users/sign_up')
    end

    it 'generates destroy_user_session_path' do
      expect(destroy_user_session_path).to eq('/users/sign_out')
    end
  end

  describe 'RESTful routes' do
    it 'provides all RESTful routes for notes' do
      expect(get: '/notes').to route_to('notes#index')
      expect(get: '/notes/1').to route_to('notes#show', id: '1')
      expect(get: '/notes/new').to route_to('notes#new')
      expect(post: '/notes').to route_to('notes#create')
      expect(get: '/notes/1/edit').to route_to('notes#edit', id: '1')
      expect(patch: '/notes/1').to route_to('notes#update', id: '1')
      expect(put: '/notes/1').to route_to('notes#update', id: '1')
      expect(delete: '/notes/1').to route_to('notes#destroy', id: '1')
    end
  end
end 