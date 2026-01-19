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
Procedure.find_or_create_by!(code: "99203") { |p| p.name = "New Patient Office Visit (Low/Mod)"; p.price = 150.00 }
Procedure.find_or_create_by!(code: "99204") { |p| p.name = "New Patient Office Visit (Mod/High)"; p.price = 220.00 }
Procedure.find_or_create_by!(code: "99213") { |p| p.name = "Established Patient Visit (Low/Mod)"; p.price = 100.00 }
Procedure.find_or_create_by!(code: "99214") { |p| p.name = "Established Patient Visit (Mod/High)"; p.price = 160.00 }
Procedure.find_or_create_by!(code: "93000") { |p| p.name = "Electrocardiogram (EKG)"; p.price = 75.00 }
puts "Done."
