require 'rails_helper'

RSpec.describe NotesController, type: :controller do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:note) { create(:note, user: user) }
  let(:other_note) { create(:note, user: other_user) }

  before do
    sign_in user
  end

  describe 'GET #index' do
    context 'when user is authenticated' do
      let!(:user_notes) { create_list(:note, 3, user: user) }
      let!(:other_notes) { create_list(:note, 2, user: other_user) }

      it 'returns http success' do
        get :index
        expect(response).to have_http_status(:success)
      end

      it 'renders the index template' do
        get :index
        expect(response).to render_template(:index)
      end

      it 'assigns only user notes to @notes' do
        get :index
        expect(assigns(:notes)).to match_array(user_notes)
      end

      it 'orders notes by created_at desc' do
        get :index
        expect(assigns(:notes).to_a).to eq(user_notes.sort_by(&:created_at).reverse)
      end

      it 'does not include other users notes' do
        get :index
        expect(assigns(:notes)).not_to include(other_notes)
      end
    end

    context 'when user is not authenticated' do
      before { sign_out user }

      it 'redirects to sign in' do
        get :index
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'GET #show' do
    context 'when user owns the note' do
      it 'returns http success' do
        get :show, params: { id: note.id }
        expect(response).to have_http_status(:success)
      end

      it 'renders the show template' do
        get :show, params: { id: note.id }
        expect(response).to render_template(:show)
      end

      it 'assigns the requested note to @note' do
        get :show, params: { id: note.id }
        expect(assigns(:note)).to eq(note)
      end
    end

    context 'when user does not own the note' do
      it 'raises an error' do
        expect {
          get :show, params: { id: other_note.id }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when note does not exist' do
      it 'raises an error' do
        expect {
          get :show, params: { id: 99999 }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when user is not authenticated' do
      before { sign_out user }

      it 'redirects to sign in' do
        get :show, params: { id: note.id }
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'GET #new' do
    context 'when user is authenticated' do
      it 'returns http success' do
        get :new
        expect(response).to have_http_status(:success)
      end

      it 'renders the new template' do
        get :new
        expect(response).to render_template(:new)
      end

      it 'assigns a new note to @note' do
        get :new
        expect(assigns(:note)).to be_a_new(Note)
      end

      it 'associates the note with the current user' do
        get :new
        expect(assigns(:note).user).to eq(user)
      end
    end

    context 'when user is not authenticated' do
      before { sign_out user }

      it 'redirects to sign in' do
        get :new
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'POST #create' do
    context 'with valid parameters' do
      let(:valid_params) do
        { note: { title: 'Test Note', content: 'Test content' } }
      end

      it 'creates a new note' do
        expect {
          post :create, params: valid_params
        }.to change(Note, :count).by(1)
      end

      it 'associates the note with the current user' do
        post :create, params: valid_params
        expect(Note.last.user).to eq(user)
      end

      it 'redirects to the created note' do
        post :create, params: valid_params
        expect(response).to redirect_to(Note.last)
      end

      it 'sets a success notice' do
        post :create, params: valid_params
        expect(flash[:notice]).to eq('Note was successfully created.')
      end
    end

    context 'with invalid parameters' do
      let(:invalid_params) do
        { note: { title: '', content: '' } }
      end

      it 'does not create a note' do
        expect {
          post :create, params: invalid_params
        }.not_to change(Note, :count)
      end

      it 'renders the new template' do
        post :create, params: invalid_params
        expect(response).to render_template(:new)
      end

      it 'returns unprocessable entity status' do
        post :create, params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'assigns the note with errors to @note' do
        post :create, params: invalid_params
        expect(assigns(:note).errors).to be_present
      end
    end

    context 'when user is not authenticated' do
      before { sign_out user }

      it 'redirects to sign in' do
        post :create, params: { note: { title: 'Test', content: 'Test' } }
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'GET #edit' do
    context 'when user owns the note' do
      it 'returns http success' do
        get :edit, params: { id: note.id }
        expect(response).to have_http_status(:success)
      end

      it 'renders the edit template' do
        get :edit, params: { id: note.id }
        expect(response).to render_template(:edit)
      end

      it 'assigns the requested note to @note' do
        get :edit, params: { id: note.id }
        expect(assigns(:note)).to eq(note)
      end
    end

    context 'when user does not own the note' do
      it 'raises an error' do
        expect {
          get :edit, params: { id: other_note.id }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when user is not authenticated' do
      before { sign_out user }

      it 'redirects to sign in' do
        get :edit, params: { id: note.id }
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'PATCH #update' do
    context 'with valid parameters' do
      let(:valid_params) do
        { id: note.id, note: { title: 'Updated Title', content: 'Updated content' } }
      end

      it 'updates the requested note' do
        patch :update, params: valid_params
        note.reload
        expect(note.title).to eq('Updated Title')
        expect(note.content).to eq('Updated content')
      end

      it 'redirects to the note' do
        patch :update, params: valid_params
        expect(response).to redirect_to(note)
      end

      it 'sets a success notice' do
        patch :update, params: valid_params
        expect(flash[:notice]).to eq('Note was successfully updated.')
      end
    end

    context 'with invalid parameters' do
      let(:invalid_params) do
        { id: note.id, note: { title: '', content: '' } }
      end

      it 'does not update the note' do
        original_title = note.title
        patch :update, params: invalid_params
        note.reload
        expect(note.title).to eq(original_title)
      end

      it 'renders the edit template' do
        patch :update, params: invalid_params
        expect(response).to render_template(:edit)
      end

      it 'returns unprocessable entity status' do
        patch :update, params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'assigns the note with errors to @note' do
        patch :update, params: invalid_params
        expect(assigns(:note).errors).to be_present
      end
    end

    context 'when user does not own the note' do
      it 'raises an error' do
        expect {
          patch :update, params: { id: other_note.id, note: { title: 'Test' } }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when user is not authenticated' do
      before { sign_out user }

      it 'redirects to sign in' do
        patch :update, params: { id: note.id, note: { title: 'Test' } }
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:note_to_delete) { create(:note, user: user) }

    context 'when user owns the note' do
      it 'destroys the requested note' do
        expect {
          delete :destroy, params: { id: note_to_delete.id }
        }.to change(Note, :count).by(-1)
      end

      it 'redirects to the notes list' do
        delete :destroy, params: { id: note_to_delete.id }
        expect(response).to redirect_to(notes_path)
      end

      it 'sets a success notice' do
        delete :destroy, params: { id: note_to_delete.id }
        expect(flash[:notice]).to eq('Note was successfully deleted.')
      end
    end

    context 'when user does not own the note' do
      it 'raises an error' do
        expect {
          delete :destroy, params: { id: other_note.id }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when user is not authenticated' do
      before { sign_out user }

      it 'redirects to sign in' do
        delete :destroy, params: { id: note_to_delete.id }
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'strong parameters' do
    it 'permits title and content parameters' do
      params = { note: { title: 'Test', content: 'Test content', user_id: other_user.id } }
      post :create, params: params
      expect(assigns(:note).user_id).to eq(user.id) # Should be current user, not other_user
    end
  end

  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/notes').to route_to('notes#index')
    end

    it 'routes to #show' do
      expect(get: '/notes/1').to route_to('notes#show', id: '1')
    end

    it 'routes to #new' do
      expect(get: '/notes/new').to route_to('notes#new')
    end

    it 'routes to #create' do
      expect(post: '/notes').to route_to('notes#create')
    end

    it 'routes to #edit' do
      expect(get: '/notes/1/edit').to route_to('notes#edit', id: '1')
    end

    it 'routes to #update via PATCH' do
      expect(patch: '/notes/1').to route_to('notes#update', id: '1')
    end

    it 'routes to #update via PUT' do
      expect(put: '/notes/1').to route_to('notes#update', id: '1')
    end

    it 'routes to #destroy' do
      expect(delete: '/notes/1').to route_to('notes#destroy', id: '1')
    end
  end
end 