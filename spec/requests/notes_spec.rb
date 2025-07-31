require 'rails_helper'

RSpec.describe 'Notes', type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:note) { create(:note, user: user) }
  let(:other_note) { create(:note, user: other_user) }

  describe 'GET /notes' do
    context 'when user is authenticated' do
      before do
        sign_in user
      end

      it 'returns http success' do
        get notes_path
        expect(response).to have_http_status(:success)
      end

      it 'renders the index template' do
        get notes_path
        expect(response).to render_template(:index)
      end

      it 'shows only user notes' do
        user_note = create(:note, user: user)
        create(:note, user: other_user)
        
        get notes_path
        expect(response.body).to include(user_note.title)
        expect(response.body).not_to include(other_note.title)
      end
    end

    context 'when user is not authenticated' do
      it 'redirects to sign in' do
        get notes_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'GET /notes/:id' do
    context 'when user is authenticated and owns the note' do
      before do
        sign_in user
      end

      it 'returns http success' do
        get note_path(note)
        expect(response).to have_http_status(:success)
      end

      it 'renders the show template' do
        get note_path(note)
        expect(response).to render_template(:show)
      end

      it 'shows the note content' do
        get note_path(note)
        expect(response.body).to include(note.title)
        expect(response.body).to include(note.content)
      end
    end

    context 'when user is authenticated but does not own the note' do
      before do
        sign_in user
      end

      it 'returns not found' do
        expect {
          get note_path(other_note)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when user is not authenticated' do
      it 'redirects to sign in' do
        get note_path(note)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'GET /notes/new' do
    context 'when user is authenticated' do
      before do
        sign_in user
      end

      it 'returns http success' do
        get new_note_path
        expect(response).to have_http_status(:success)
      end

      it 'renders the new template' do
        get new_note_path
        expect(response).to render_template(:new)
      end

      it 'shows the new note form' do
        get new_note_path
        expect(response.body).to include('Create New Note')
        expect(response.body).to include('form')
      end
    end

    context 'when user is not authenticated' do
      it 'redirects to sign in' do
        get new_note_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'POST /notes' do
    context 'when user is authenticated with valid parameters' do
      before do
        sign_in user
      end

      it 'creates a new note' do
        expect {
          post notes_path, params: { note: { title: 'Test Note', content: 'Test content' } }
        }.to change(Note, :count).by(1)
      end

      it 'redirects to the created note' do
        post notes_path, params: { note: { title: 'Test Note', content: 'Test content' } }
        expect(response).to redirect_to(Note.last)
      end

      it 'sets a success notice' do
        post notes_path, params: { note: { title: 'Test Note', content: 'Test content' } }
        expect(flash[:notice]).to eq('Note was successfully created.')
      end

      it 'associates the note with the current user' do
        post notes_path, params: { note: { title: 'Test Note', content: 'Test content' } }
        expect(Note.last.user).to eq(user)
      end
    end

    context 'when user is authenticated with invalid parameters' do
      before do
        sign_in user
      end

      it 'does not create a note' do
        expect {
          post notes_path, params: { note: { title: '', content: '' } }
        }.not_to change(Note, :count)
      end

      it 'renders the new template' do
        post notes_path, params: { note: { title: '', content: '' } }
        expect(response).to render_template(:new)
      end

      it 'returns unprocessable entity status' do
        post notes_path, params: { note: { title: '', content: '' } }
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'shows validation errors' do
        post notes_path, params: { note: { title: '', content: '' } }
        expect(response.body).to include('error')
      end
    end

    context 'when user is not authenticated' do
      it 'redirects to sign in' do
        post notes_path, params: { note: { title: 'Test', content: 'Test' } }
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'GET /notes/:id/edit' do
    context 'when user is authenticated and owns the note' do
      before do
        sign_in user
      end

      it 'returns http success' do
        get edit_note_path(note)
        expect(response).to have_http_status(:success)
      end

      it 'renders the edit template' do
        get edit_note_path(note)
        expect(response).to render_template(:edit)
      end

      it 'shows the edit form with current values' do
        get edit_note_path(note)
        expect(response.body).to include(note.title)
        expect(response.body).to include(note.content)
      end
    end

    context 'when user is authenticated but does not own the note' do
      before do
        sign_in user
      end

      it 'returns not found' do
        expect {
          get edit_note_path(other_note)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when user is not authenticated' do
      it 'redirects to sign in' do
        get edit_note_path(note)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'PATCH /notes/:id' do
    context 'when user is authenticated with valid parameters' do
      before do
        sign_in user
      end

      it 'updates the note' do
        patch note_path(note), params: { note: { title: 'Updated Title', content: 'Updated content' } }
        note.reload
        expect(note.title).to eq('Updated Title')
        expect(note.content).to eq('Updated content')
      end

      it 'redirects to the note' do
        patch note_path(note), params: { note: { title: 'Updated Title', content: 'Updated content' } }
        expect(response).to redirect_to(note)
      end

      it 'sets a success notice' do
        patch note_path(note), params: { note: { title: 'Updated Title', content: 'Updated content' } }
        expect(flash[:notice]).to eq('Note was successfully updated.')
      end
    end

    context 'when user is authenticated with invalid parameters' do
      before do
        sign_in user
      end

      it 'does not update the note' do
        original_title = note.title
        patch note_path(note), params: { note: { title: '', content: '' } }
        note.reload
        expect(note.title).to eq(original_title)
      end

      it 'renders the edit template' do
        patch note_path(note), params: { note: { title: '', content: '' } }
        expect(response).to render_template(:edit)
      end

      it 'returns unprocessable entity status' do
        patch note_path(note), params: { note: { title: '', content: '' } }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'when user is authenticated but does not own the note' do
      before do
        sign_in user
      end

      it 'returns not found' do
        expect {
          patch note_path(other_note), params: { note: { title: 'Test' } }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when user is not authenticated' do
      it 'redirects to sign in' do
        patch note_path(note), params: { note: { title: 'Test' } }
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'DELETE /notes/:id' do
    let!(:note_to_delete) { create(:note, user: user) }

    context 'when user is authenticated and owns the note' do
      before do
        sign_in user
      end

      it 'destroys the note' do
        expect {
          delete note_path(note_to_delete)
        }.to change(Note, :count).by(-1)
      end

      it 'redirects to the notes list' do
        delete note_path(note_to_delete)
        expect(response).to redirect_to(notes_path)
      end

      it 'sets a success notice' do
        delete note_path(note_to_delete)
        expect(flash[:notice]).to eq('Note was successfully deleted.')
      end
    end

    context 'when user is authenticated but does not own the note' do
      before do
        sign_in user
      end

      it 'returns not found' do
        expect {
          delete note_path(other_note)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when user is not authenticated' do
      it 'redirects to sign in' do
        delete note_path(note_to_delete)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end 