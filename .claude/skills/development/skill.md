# Development Standards: [AppIdeaSocialApp]

## 1. Architectural Integrity
- **Logic Placement:** Business logic belongs in Domain Models (POROs) or Helper modules, never in Views or Controllers.
- **POROs Over Services:** Favor domain models using 'ActiveModel::Model' over generic 'Service' or 'Manager' classes.
- **Law of Demeter:** Use 'delegate' to avoid "Voyeuristic Models" reaching through more than two associations.

## 2. Performance & Persistence
- **SQL Over Ruby:** Use database-level methods like '.where', '.pluck', and '.sum' instead of Ruby iteration like '.all.select' or '.map'.
- **Fail Loudly:** All persistence calls in background jobs, POROs, and migrations MUST use "Bang" methods (e.g., 'save!', 'update!') to prevent silent failures.

## 3. Clean Code & Git
- **Descriptive Naming:** Use clear variable names and strictly avoid "magic numbers."
- **Conventional Commits:** All git messages must follow the pattern: 'feat: description' or 'fix: description'.
- **Security:** Use '.env.local' for secrets; never commit sensitive data to the repository.