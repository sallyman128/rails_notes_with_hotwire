require 'rails_helper'

RSpec.describe 'Notes', type: :system do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:note) { create(:note, user: user) }
  let(:other_note) { create(:note, user: other_user) }

  before do
    driven_by(:selenium_chrome_headless)
  end

  describe 'Notes index page' do
    context 'when user is authenticated' do
      before do
        sign_in user
        visit notes_path
      end

      it 'displays the page title' do
        expect(page).to have_content('My Notes')
      end

      it 'shows the new note button' do
        expect(page).to have_link('New Note')
      end

      context 'when user has notes' do
        let!(:user_notes) { create_list(:note, 3, user: user) }
        let!(:other_notes) { create_list(:note, 2, user: other_user) }

        before do
          visit notes_path
        end

        it 'displays user notes' do
          user_notes.each do |note|
            expect(page).to have_content(note.title)
          end
        end

        it 'does not display other users notes' do
          other_notes.each do |note|
            expect(page).not_to have_content(note.title)
          end
        end

        it 'shows edit and delete links for each note' do
          user_notes.each do |note|
            expect(page).to have_link('Edit', href: edit_note_path(note))
            expect(page).to have_link('Delete', href: note_path(note))
          end
        end

        it 'shows note creation dates' do
          user_notes.each do |note|
            expect(page).to have_content(note.created_at.strftime('%B %d, %Y'))
          end
        end
      end

      context 'when user has no notes' do
        before do
          visit notes_path
        end

        it 'shows empty state message' do
          expect(page).to have_content('No notes yet')
          expect(page).to have_content('Create your first note to get started!')
        end

        it 'shows create note button' do
          expect(page).to have_link('Create Note')
        end
      end
    end

    context 'when user is not authenticated' do
      it 'redirects to sign in page' do
        visit notes_path
        expect(page).to have_current_path(new_user_session_path)
      end
    end
  end

  describe 'Creating a new note' do
    before do
      sign_in user
      visit new_note_path
    end

    it 'displays the create note form' do
      expect(page).to have_content('Create New Note')
      expect(page).to have_field('Title')
      expect(page).to have_field('Content')
      expect(page).to have_button('Create Note')
    end

    context 'with valid data' do
      it 'creates a new note' do
        fill_in 'Title', with: 'Test Note Title'
        fill_in 'Content', with: 'This is the test content for the note.'
        click_button 'Create Note'

        expect(page).to have_content('Test Note Title')
        expect(page).to have_content('This is the test content for the note.')
        expect(page).to have_content('Note was successfully created.')
      end
    end

    context 'with invalid data' do
      it 'shows validation errors' do
        fill_in 'Title', with: ''
        fill_in 'Content', with: ''
        click_button 'Create Note'

        expect(page).to have_content("can't be blank")
        expect(page).to have_current_path(new_note_path)
      end
    end

    it 'has a cancel link' do
      expect(page).to have_link('Cancel', href: notes_path)
    end
  end

  describe 'Viewing a note' do
    before do
      sign_in user
      visit note_path(note)
    end

    it 'displays the note content' do
      expect(page).to have_content(note.title)
      expect(page).to have_content(note.content)
    end

    it 'shows creation and update timestamps' do
      expect(page).to have_content(note.created_at.strftime('%B %d, %Y at %I:%M %p'))
    end

    it 'has edit and back links' do
      expect(page).to have_link('Edit', href: edit_note_path(note))
      expect(page).to have_link('Back to Notes', href: notes_path)
    end

    it 'has a delete link' do
      expect(page).to have_link('Delete Note')
    end

    context 'when user does not own the note' do
      it 'raises an error' do
        expect {
          visit note_path(other_note)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe 'Editing a note' do
    before do
      sign_in user
      visit edit_note_path(note)
    end

    it 'displays the edit form with current values' do
      expect(page).to have_content('Edit Note')
      expect(page).to have_field('Title', with: note.title)
      expect(page).to have_field('Content', with: note.content)
      expect(page).to have_button('Update Note')
    end

    context 'with valid data' do
      it 'updates the note' do
        fill_in 'Title', with: 'Updated Note Title'
        fill_in 'Content', with: 'This is the updated content.'
        click_button 'Update Note'

        expect(page).to have_current_path(note_path(note))
        expect(page).to have_content('Updated Note Title')
        expect(page).to have_content('This is the updated content.')
        expect(page).to have_content('Note was successfully updated.')
      end
    end

    context 'with invalid data' do
      it 'shows validation errors' do
        fill_in 'Title', with: ''
        fill_in 'Content', with: ''
        click_button 'Update Note'

        expect(page).to have_content("can't be blank")
        expect(page).to have_current_path(edit_note_path(note))
      end
    end

    it 'has a cancel link' do
      expect(page).to have_link('Cancel', href: note_path(note))
    end

    context 'when user does not own the note' do
      it 'raises an error' do
        expect {
          visit edit_note_path(other_note)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe 'Deleting a note' do
    let!(:note_to_delete) { create(:note, user: user) }

    before do
      sign_in user
      visit notes_path
    end

    it 'deletes the note when confirmed' do
      expect(page).to have_content(note_to_delete.title)
      
      accept_confirm do
        click_link 'Delete'
      end

      expect(page).to have_current_path(notes_path)
      expect(page).to have_content('Note was successfully deleted.')
      expect(page).not_to have_content(note_to_delete.title)
    end

    it 'does not delete when cancelled' do
      dismiss_confirm do
        click_link 'Delete'
      end

      expect(page).to have_current_path(notes_path)
      expect(page).to have_content(note_to_delete.title)
    end
  end

  describe 'Navigation' do
    before do
      sign_in user
    end

    it 'navigates from home to notes' do
      visit root_path
      click_link 'My Notes'
      expect(page).to have_current_path(notes_path)
    end

    it 'navigates from notes to new note' do
      visit notes_path
      click_link 'New Note', match: :first
      expect(page).to have_current_path(new_note_path)
    end

    it 'navigates from note to edit' do
      visit note_path(note)
      click_link 'Edit'
      expect(page).to have_current_path(edit_note_path(note))
    end

    it 'navigates back to notes from new' do
      visit new_note_path
      click_link 'Cancel'
      expect(page).to have_current_path(notes_path)
    end

    it 'navigates back to note from edit' do
      visit edit_note_path(note)
      click_link 'Cancel'
      expect(page).to have_current_path(note_path(note))
    end
  end

  describe 'Authentication' do
    it 'redirects unauthenticated users to sign in' do
      visit notes_path
      expect(page).to have_current_path(new_user_session_path)
    end

    it 'allows authenticated users to access notes' do
      sign_in user
      visit notes_path
      expect(page).to have_content('My Notes')
    end
  end

  describe 'Responsive design' do
    before do
      sign_in user
      create_list(:note, 5, user: user)
    end

    it 'displays notes in a grid layout' do
      visit notes_path
      expect(page).to have_css('.grid')
    end

    it 'shows navigation elements' do
      visit notes_path
      expect(page).to have_css('nav')
      expect(page).to have_link('Notes App')
      expect(page).to have_link('My Notes')
      expect(page).to have_link('New Note')
    end
  end
end 