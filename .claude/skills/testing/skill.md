# Testing Standards: AppIdeaSocialApp

## 1. Automation Architecture (Playwright.js)
- **Pattern:** Mandatory Page Object Model (POM) for all E2E tests to ensure maintainability.
- **Selector Strategy:** Strictly follow the priority to ensure accessibility and stability:
    1. getByRole (Primary - enforces A11y standards)
    2. getByLabel
    3. getByTestId (Last resort for non-semantic elements)
- **Quality Gate:** Every feature must include a "Happy Path" E2E test and a full Accessibility Tree audit.
- **Reporting:** Failures must be logged with a trace file and a DOM snapshot for rapid debugging.

## 2. Test Logic & Patterns (thoughtbot Integrated)
- **Four Phase Test:** Every test must strictly follow the Setup, Exercise, Verify, and Teardown pattern for clarity and isolation.
- **Avoid Mystery Guests:** Explicitly define critical test data within the test block; do not rely on hidden factory defaults that obscure the test's intent.
- **Brittle Test Prevention:** Avoid hardcoded CSS selectors or testing implementation details; focus on user behavior and semantic roles.

## 3. Coverage & Reliability
- **Data Isolation:** Tests must run independently and clean up after themselves to prevent intermittent failures.
- **Reliability:** Flag and remove usage of 'sleep' or time-dependent logic without proper cleanup.