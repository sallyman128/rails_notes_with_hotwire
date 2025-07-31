require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe 'helper methods' do
    it 'is included in the helper' do
      expect(ApplicationHelper).to be_a(Module)
    end

    # Add more specific helper method tests as needed
    # For example, if you add custom helper methods later
  end
end 