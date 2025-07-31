# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Create a demo user
user = User.find_or_create_by!(email: 'demo@example.com') do |u|
  u.password = 'password123'
  u.password_confirmation = 'password123'
end

# Create sample notes for the demo user
notes_data = [
  {
    title: "Welcome to Notes App",
    content: "This is your first note! You can create, edit, and delete notes to keep your thoughts organized. The app is built with Ruby on Rails, Hotwire, and Tailwind CSS for a modern, responsive experience."
  },
  {
    title: "Ruby on Rails Features",
    content: "This app demonstrates several modern Rails features:\n\n• Hotwire and Turbo for fast, SPA-like interactions\n• Devise for user authentication\n• Tailwind CSS for modern styling\n• RESTful routing and CRUD operations\n• Form validation and error handling\n• Responsive design for all devices"
  },
  {
    title: "Development Notes",
    content: "Key technologies used in this project:\n\n- Ruby on Rails 8.0.2\n- SQLite database\n- Devise gem for authentication\n- Tailwind CSS for styling\n- Hotwire/Turbo for dynamic interactions\n- Stimulus for JavaScript functionality\n\nThis makes for an excellent portfolio piece showcasing modern Rails development skills!"
  },
  {
    title: "Todo List",
    content: "Things to do:\n\n☐ Review the codebase\n☐ Test all CRUD operations\n☐ Check responsive design\n☐ Verify authentication flow\n☐ Test form validations\n☐ Ensure proper error handling\n\nThis app is ready for your resume!"
  }
]

notes_data.each do |note_data|
  Note.find_or_create_by!(title: note_data[:title], user: user) do |note|
    note.content = note_data[:content]
  end
end

puts "Seed data created successfully!"
puts "Demo user: demo@example.com"
puts "Password: password123"
