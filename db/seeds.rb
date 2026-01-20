# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end


puts "Seeding CPT Codes..."

CptCode.create!([
  { code: '99203', description: 'Office/outpatient visit new' },
  { code: '99213', description: 'Office/outpatient visit est' },
  { code: '99214', description: 'Office/outpatient visit est mod' },
  { code: '73030', description: 'X-ray exam of shoulder' },
  { code: '90715', description: 'Tdap vaccine' }
])

puts "Done!"
