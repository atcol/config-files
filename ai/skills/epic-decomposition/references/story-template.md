# Story Template Reference

This document contains the full story template and examples to guide consistent story creation.

## Template

```markdown
### [STORY-TITLE]

**Summary**: [1-2 sentences: what this delivers and why it matters to the user or business]

**PRD/RFC Reference**: [Section name, requirement ID, or page reference in the source document]

**Acceptance Criteria**:
- Given [precondition], when [action], then [expected result]
- ...

**Technical Subtasks**:
- [ ] [Concrete implementation step]
- [ ] ...

**Definition of Done**:
- [ ] Code reviewed and merged
- [ ] Unit tests written and passing
- [ ] Integration tests updated
- [ ] Documentation updated (if applicable)
- [ ] Deployed to staging and smoke-tested

**Estimation**: [S / M / L / XL — omit if user opted out]

**Dependencies**: [Story titles or "None"]

**Open Questions**: [Unresolved items or "None"]
```

---

## Sizing Guide (T-shirt)

| Size | Typical Scope | Duration (1 engineer) |
|------|--------------|----------------------|
| S    | Single API endpoint, simple UI change, config update | Half day to 1 day |
| M    | Feature slice with 2-3 components (API + UI + tests) | 1-3 days |
| L    | Multi-component feature, new service integration, complex business logic | 3-5 days |
| XL   | Consider splitting. Full feature with data model changes, multiple integrations, significant testing | 5+ days |

If a story lands at XL, it's a strong signal it should be broken into smaller stories. Flag this to the user.

---

## Example Stories

### Example 1: API Feature Story

### Implement User Preferences API

**Summary**: Create a REST API that allows users to read and update their notification preferences. This supports the "Notification Settings" feature described in the PRD, enabling users to control which notifications they receive.

**PRD/RFC Reference**: PRD Section 3.2 — Notification Preferences

**Acceptance Criteria**:
- Given an authenticated user, when they GET /api/v1/users/{id}/preferences, then they receive their current notification preferences as JSON with all preference categories
- Given an authenticated user, when they PATCH /api/v1/users/{id}/preferences with valid preference data, then the preferences are updated and a 200 response with the updated preferences is returned
- Given an unauthenticated request, when any preferences endpoint is called, then a 401 response is returned
- Given a user attempts to update another user's preferences, when the PATCH is made, then a 403 response is returned
- Given invalid preference values (e.g., unknown category), when a PATCH is made, then a 400 response with descriptive error message is returned

**Technical Subtasks**:
- [ ] Create database migration: add `user_preferences` table with columns for each notification category
- [ ] Implement `UserPreferencesRepository` with get/update methods
- [ ] Implement `GET /api/v1/users/{id}/preferences` endpoint with auth middleware
- [ ] Implement `PATCH /api/v1/users/{id}/preferences` endpoint with validation
- [ ] Add authorization check (user can only modify own preferences)
- [ ] Write unit tests for repository and service layers
- [ ] Write integration tests for both endpoints (happy path + error cases)
- [ ] Add OpenAPI spec documentation for new endpoints

**Definition of Done**:
- [ ] Code reviewed and merged
- [ ] Unit tests written and passing (>90% coverage on new code)
- [ ] Integration tests passing
- [ ] OpenAPI spec updated
- [ ] Deployed to staging and smoke-tested

**Estimation**: M

**Dependencies**: None (new table, no existing schema changes required)

**Open Questions**: None

---

### Example 2: Spike Story

### Spike: Evaluate Real-time Notification Delivery Options

**Summary**: Research and recommend an approach for delivering real-time notifications to the client. The PRD requires "near-instant" delivery but doesn't specify the mechanism. We need to evaluate WebSockets, Server-Sent Events, and polling to make an informed architectural decision.

**PRD/RFC Reference**: PRD Section 3.4 — Real-time Delivery (requirement: "Notifications should appear within 2 seconds of trigger event")

**Acceptance Criteria**:
- Given the spike is complete, when the findings are presented, then there is a written ADR (Architecture Decision Record) comparing at least 3 approaches
- Given each approach evaluated, when documented, then it includes: latency characteristics, infrastructure cost estimate, client complexity, and browser compatibility
- Given the team reviews the ADR, when a decision is made, then follow-up implementation stories can be written with confidence

**Technical Subtasks**:
- [ ] Research WebSocket approach: prototype, measure latency, document tradeoffs
- [ ] Research SSE approach: prototype, measure latency, document tradeoffs
- [ ] Research long-polling approach: prototype, measure latency, document tradeoffs
- [ ] Write ADR with comparison matrix and recommendation
- [ ] Present findings to team

**Definition of Done**:
- [ ] ADR written and shared with team
- [ ] Team has reviewed and agreed on approach
- [ ] Follow-up stories drafted based on chosen approach

**Estimation**: M (timeboxed to 2 days)

**Dependencies**: None

**Open Questions**:
- What is the expected peak concurrent connection count? (Impacts WebSocket feasibility)
- Does the infrastructure team have an existing preference or existing infra for any of these?

---

### Example 3: Frontend Story with Accessibility

### Build Notification Preferences Settings Page

**Summary**: Create the UI for users to view and manage their notification preferences. This is the user-facing counterpart to the preferences API, letting users toggle notification categories on/off from their account settings.

**PRD/RFC Reference**: PRD Section 4.1 — Settings UI, Wireframe Figure 3

**Acceptance Criteria**:
- Given a logged-in user, when they navigate to Settings > Notifications, then they see a list of all notification categories with toggle switches reflecting their current preferences
- Given the user toggles a notification category, when the toggle is changed, then the preference is saved via the API and a success confirmation is shown
- Given the API call to save preferences fails, when the error occurs, then the toggle reverts to its previous state and an error message is displayed
- Given a screen reader user, when they navigate the preferences page, then all toggles are properly labeled with accessible names and state announcements
- Given a slow network connection, when preferences are loading, then a skeleton loading state is shown (not a blank page)

**Technical Subtasks**:
- [ ] Create `NotificationPreferences` page component with route `/settings/notifications`
- [ ] Implement preference category toggle component with optimistic UI updates
- [ ] Integrate with `GET /api/v1/users/{id}/preferences` for initial load
- [ ] Integrate with `PATCH /api/v1/users/{id}/preferences` on toggle change
- [ ] Add error handling with rollback on failed save
- [ ] Implement loading skeleton state
- [ ] Add ARIA labels and keyboard navigation support
- [ ] Write component unit tests
- [ ] Write e2e test for the full toggle flow

**Definition of Done**:
- [ ] Code reviewed and merged
- [ ] Unit tests and e2e tests passing
- [ ] Accessibility audit passed (axe-core, keyboard navigation verified)
- [ ] Matches wireframe in PRD Figure 3
- [ ] Deployed to staging and smoke-tested on Chrome, Firefox, Safari

**Estimation**: L

**Dependencies**: "Implement User Preferences API" must be complete or available in staging

**Open Questions**: None
