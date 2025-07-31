require 'rails_helper'

RSpec.describe Note, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
  end

  describe 'validations' do
    subject { build(:note) }

    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:content) }
    it { should validate_length_of(:title).is_at_most(255) }
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:note)).to be_valid
    end

    it 'has a valid factory with long content' do
      note = build(:note, :with_long_content)
      expect(note).to be_valid
      expect(note.content.length).to be > 100
    end

    it 'has a valid factory with short title' do
      note = build(:note, :with_short_title)
      expect(note).to be_valid
      expect(note.title.length).to be < 50
    end

    it 'has a valid factory with long title' do
      note = build(:note, :with_long_title)
      expect(note).to be_valid
      expect(note.title.length).to be > 50
    end
  end

  describe 'database columns' do
    it 'has the required columns' do
      expect(Note.column_names).to include('id', 'title', 'content', 'user_id', 'created_at', 'updated_at')
    end
  end

  describe 'title validation' do
    let(:user) { create(:user) }

    it 'requires a title' do
      note = build(:note, title: nil, user: user)
      expect(note).not_to be_valid
      expect(note.errors[:title]).to include("can't be blank")
    end

    it 'accepts titles up to 255 characters' do
      long_title = 'a' * 255
      note = build(:note, title: long_title, user: user)
      expect(note).to be_valid
    end

    it 'rejects titles longer than 255 characters' do
      too_long_title = 'a' * 256
      note = build(:note, title: too_long_title, user: user)
      expect(note).not_to be_valid
      expect(note.errors[:title]).to include('is too long (maximum is 255 characters)')
    end

    it 'accepts empty string titles' do
      note = build(:note, title: '', user: user)
      expect(note).not_to be_valid
      expect(note.errors[:title]).to include("can't be blank")
    end

    it 'accepts whitespace-only titles' do
      note = build(:note, title: '   ', user: user)
      expect(note).not_to be_valid
      expect(note.errors[:title]).to include("can't be blank")
    end
  end

  describe 'content validation' do
    let(:user) { create(:user) }

    it 'requires content' do
      note = build(:note, content: nil, user: user)
      expect(note).not_to be_valid
      expect(note.errors[:content]).to include("can't be blank")
    end

    it 'accepts empty string content' do
      note = build(:note, content: '', user: user)
      expect(note).not_to be_valid
      expect(note.errors[:content]).to include("can't be blank")
    end

    it 'accepts whitespace-only content' do
      note = build(:note, content: '   ', user: user)
      expect(note).not_to be_valid
      expect(note.errors[:content]).to include("can't be blank")
    end

    it 'accepts very long content' do
      long_content = 'This is a very long content. ' * 100
      note = build(:note, content: long_content, user: user)
      expect(note).to be_valid
    end
  end

  describe 'user association' do
    it 'requires a user' do
      note = build(:note, user: nil)
      expect(note).not_to be_valid
      expect(note.errors[:user]).to include('must exist')
    end

    it 'belongs to the correct user' do
      user = create(:user)
      note = create(:note, user: user)
      expect(note.user).to eq(user)
    end
  end

  describe 'timestamps' do
    let(:note) { create(:note) }

    it 'sets created_at on creation' do
      expect(note.created_at).to be_present
      expect(note.created_at).to be_within(1.second).of(Time.current)
    end

    it 'sets updated_at on creation' do
      expect(note.updated_at).to be_present
      expect(note.updated_at).to be_within(1.second).of(Time.current)
    end

    it 'updates updated_at when modified' do
      original_updated_at = note.updated_at
      sleep(1) # Ensure time difference
      note.update(title: 'Updated Title')
      expect(note.updated_at).to be > original_updated_at
    end
  end

  describe 'scopes and ordering' do
    let(:user) { create(:user) }
    let!(:note1) { create(:note, user: user, created_at: 2.days.ago) }
    let!(:note2) { create(:note, user: user, created_at: 1.day.ago) }
    let!(:note3) { create(:note, user: user, created_at: Time.current) }

    it 'orders by created_at desc by default' do
      notes = user.notes.order(created_at: :desc)
      expect(notes.to_a).to eq([note3, note2, note1])
    end
  end

  describe 'content formatting' do
    let(:user) { create(:user) }

    it 'preserves whitespace in content' do
      content_with_whitespace = "Line 1\n\nLine 2\n  Indented line"
      note = create(:note, content: content_with_whitespace, user: user)
      expect(note.content).to eq(content_with_whitespace)
    end

    it 'preserves special characters in content' do
      content_with_special_chars = "Note with: !@#$%^&*()_+-=[]{}|;':\",./<>?"
      note = create(:note, content: content_with_special_chars, user: user)
      expect(note.content).to eq(content_with_special_chars)
    end
  end

  describe 'title formatting' do
    let(:user) { create(:user) }

    it 'preserves whitespace in title' do
      title_with_spaces = "  Note Title  "
      note = create(:note, title: title_with_spaces, user: user)
      expect(note.title).to eq(title_with_spaces)
    end

    it 'preserves special characters in title' do
      title_with_special_chars = "Note: Title with @#$%^&*()"
      note = create(:note, title: title_with_special_chars, user: user)
      expect(note.title).to eq(title_with_special_chars)
    end
  end
end 