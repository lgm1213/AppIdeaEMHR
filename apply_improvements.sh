#!/bin/bash
# save as: bin/apply_improvements

set -e  # Exit on error

echo "=== Phase 1: Static Files ==="
cp improvements/14a_404_page.html public/404.html
cp improvements/14b_500_page.html public/500.html
cp improvements/15_application_helper.rb app/helpers/application_helper.rb
mkdir -p app/models/concerns
cp improvements/10b_organization_scoped_concern_safe.rb app/models/concerns/organization_scoped.rb

echo "=== Phase 2: Models ==="
cp improvements/06c_current_model.rb app/models/current.rb
cp improvements/04a_user_model.rb app/models/user.rb
cp improvements/08c_organization_model.rb app/models/organization.rb
cp improvements/03_provider_model.rb app/models/provider.rb
cp improvements/08b_patient_model.rb app/models/patient.rb
cp improvements/04b_appointment_model.rb app/models/appointment.rb
cp improvements/08a_encounter_model.rb app/models/encounter.rb
cp improvements/05_encounter_procedure_model.rb app/models/encounter_procedure.rb

echo "=== Phase 3: Controllers ==="
cp improvements/06_application_controller.rb app/controllers/application_controller.rb
cp improvements/02_encounters_controller.rb app/controllers/encounters_controller.rb

echo "=== Phase 4: JavaScript ==="
cp improvements/09_cpt_search_controller.js app/javascript/controllers/cpt_search_controller.js

echo "=== Phase 5: Seeds & Tests ==="
cp improvements/07_seeds.rb db/seeds.rb
cp improvements/12_patient_model_test.rb test/models/patient_test.rb
cp improvements/13_user_model_test.rb test/models/user_test.rb

echo "=== Phase 6: Generate Migrations ==="
# You'll need to manually create these and paste contents
echo "Run these commands manually:"
echo "  bin/rails generate migration AddPerformanceIndexes"
echo "  bin/rails generate migration AddStatusToEncounters"
echo "Then paste contents from improvement files 01 and 11"

echo "=== Done! ==="
echo "Next steps:"
echo "  1. Create migrations (see above)"
echo "  2. bin/rails db:drop db:create db:migrate db:seed"
echo "  3. bin/rails test"