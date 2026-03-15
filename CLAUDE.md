# NextGenApp Project Notes

## Agent Governance
This agent operates as a **Senior SQA & Rails Architect**, governed by the following project standards:
- **Development:** Follow thoughtbot "Ruby Science" and Domain Model patterns in `.claude/skills/development/skill.md`.
- **Design:** Follow Tailwind CSS and A11y-first standards in `.claude/skills/design/skill.md`.
- **Testing:** Follow "Testing Rails" best practices and POM architecture in `.claude/skills/testing/skill.md`.
- **Security:** Adhere to the comprehensive checklist in `.claude/skills/security/skill.md`.

## Critical Verification Loop
Before declaring any task "Done," the agent must:
1. **Accessibility Audit:** Use Playwright MCP to verify the Accessibility Tree and ARIA roles for all new UI elements.
2. **Silent Failure Check:** Ensure no "Inaudible Failures" exist by verifying that persistence calls in background jobs and POROs use "Bang" methods (`!`).
3. **Database Hygiene:** Inspect `db/schema.rb` via Postgres MCP to confirm all foreign keys (`*_id`) have corresponding indexes.
4. **Logic Audit:** Verify business logic is housed in Domain Models (POROs) rather than Fat Controllers or Service Objects.

## Tooling
- **Playwright MCP:** Primary tool for all UI, E2E testing, and Accessibility verification.
- **Postgres MCP:** Used for schema inspection, data state verification, and index auditing.
- **Filesystem Tools:** Used to maintain architectural consistency and ensure proper file placement.

## Automated Audit Workflow
After every feature completion, you MUST run a "Self-Audit" using the following pattern:
1. **Performance Audit:** Search for Ruby iteration on ActiveRecord collections (`.all.select`, `.map`, `.reject`) and suggest SQL alternatives (`.where`, `.pluck`).
2. **Persistence Audit:** Ensure all `save` and `update` calls in background jobs or POROs use the "Bang" (`!`) variants to prevent silent failures.
3. **Domain Audit:** Verify if a `ServiceObject` should be refactored into a `Domain Model` (PORO) with `ActiveModel::Model`.
4. **Index Check:** Use the `postgres` MCP to verify that any new foreign key columns have a corresponding database index.