require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it { should have_many(:notes).dependent(:destroy) }
  end

  describe 'devise modules' do
    it 'includes the correct devise modules' do
      expect(User.devise_modules).to include(:database_authenticatable)
      expect(User.devise_modules).to include(:registerable)
      expect(User.devise_modules).to include(:recoverable)
      expect(User.devise_modules).to include(:rememberable)
      expect(User.devise_modules).to include(:validatable)
    end
  end

  describe 'database columns' do
    it 'has the required columns' do
      expect(User.column_names).to include('id', 'email', 'encrypted_password', 'created_at', 'updated_at')
    end
  end

  describe 'validations' do
    subject { build(:user) }

    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive }
    it { should validate_presence_of(:password) }
    it { should validate_length_of(:password).is_at_least(6) }
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:user)).to be_valid
    end

    it 'has a valid factory with notes' do
      user = create(:user, :with_notes)
      expect(user.notes.count).to eq(3)
    end

    it 'has a valid factory with many notes' do
      user = create(:user, :with_many_notes)
      expect(user.notes.count).to eq(10)
    end
  end

  describe 'note management' do
    let(:user) { create(:user) }

    it 'can create notes' do
      note = user.notes.create(title: 'Test Note', content: 'Test content')
      expect(user.notes).to include(note)
    end

    it 'can destroy notes' do
      note = create(:note, user: user)
      expect { note.destroy }.to change { user.notes.count }.by(-1)
    end

    it 'destroys associated notes when user is destroyed' do
      create_list(:note, 3, user: user)
      expect { user.destroy }.to change { Note.count }.by(-3)
    end
  end

  describe 'email format' do
    it 'accepts valid email addresses' do
      valid_emails = [
        'user@example.com',
        'user.name@example.com',
        'user+tag@example.com',
        'user@subdomain.example.com'
      ]

      valid_emails.each do |email|
        user = build(:user, email: email)
        expect(user).to be_valid
      end
    end

    it 'rejects obviously invalid email addresses' do
      invalid_emails = [
        'invalid-email',
        'user@@example.com'
      ]

      invalid_emails.each do |email|
        user = build(:user, email: email)
        expect(user).not_to be_valid, "Expected #{email} to be invalid"
        expect(user.errors[:email]).to be_present
      end
    end
  end

  describe 'password requirements' do
    it 'requires password confirmation to match' do
      user = build(:user, password: 'password123', password_confirmation: 'different')
      expect(user).not_to be_valid
      expect(user.errors[:password_confirmation]).to include("doesn't match Password")
    end

    it 'requires minimum password length' do
      user = build(:user, password: '12345', password_confirmation: '12345')
      expect(user).not_to be_valid
      expect(user.errors[:password]).to include('is too short (minimum is 6 characters)')
    end
  end
end 