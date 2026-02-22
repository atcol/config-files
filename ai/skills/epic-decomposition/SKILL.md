---
name: epic-decomposer
description: Decompose epics into well-structured stories for any project management tool (JIRA, Linear, Asana, Shortcut, Azure DevOps, GitHub Issues, etc.) using a PRD, RFC, or design document as the requirements source. Use this skill whenever the user wants to break down an epic, create stories from a product spec, generate tickets from requirements, plan sprint work from a design doc, or turn a feature description into actionable stories. Also trigger when the user mentions "epic decomposition", "story breakdown", "ticket creation from PRD", "RFC to stories", "break this into tickets", "create issues from spec", or similar phrasing — regardless of which tool they use or whether they name one at all. If a user uploads or references a PRD, RFC, or design doc and asks to plan work or create tasks from it, this skill applies.
---

# Epic Decomposer

Break down an epic into well-scoped, implementable stories for any issue tracker by interviewing the user and grounding every story in a PRD, RFC, or design document they provide.

## Why this skill exists

Decomposing epics is one of the highest-leverage planning activities a team does, but it's easy to get wrong. Stories end up too big, too vague, missing acceptance criteria, or disconnected from the actual requirements. This skill ensures each story is traceable to the source document, right-sized for a sprint, and complete enough that an engineer can pick it up without ambiguity.

## Workflow Overview

The process has four phases. Move through them in order, but stay flexible — the user might already have answers to some questions, or might want to skip estimation entirely.

1. **Gather context** — understand the epic scope, ingest the reference document, and ask clarifying questions
2. **Decompose** — produce a structured list of stories with acceptance criteria, subtasks, and DoD
3. **Review & refine** — walk the user through each story, adjust scope, reorder, add/remove
4. **Deliver** — output as markdown and/or create directly in the user's project management tool via MCP

---

## Phase 1: Gather Context

### Ingest the reference document

The user should provide a PRD, RFC, or design doc. This is the source of truth for requirements. If they haven't provided one yet, ask for it — the skill doesn't work well without a reference document to ground the stories in.

Once you have the document:
- Read it thoroughly
- Identify the core goals, user personas, functional requirements, non-functional requirements, and any open questions or risks called out in the doc
- Note any explicit scope boundaries ("out of scope", "future work", "phase 2")

### Interview the user

Ask these questions conversationally — don't dump them all at once. Adapt based on what the document already answers. Skip questions the doc clearly addresses.

**Epic scope & boundaries:**
- What is the epic title and a one-line summary?
- Is this the full scope of the epic, or is some of it already done / being handled elsewhere?
- Are there any parts of the PRD/RFC that are explicitly out of scope for this epic?

**Team & technical context:**
- Who is the target team picking up these stories? (helps calibrate technical depth)
- Are there known technical constraints, dependencies on other teams, or prerequisite work?
- Are there any existing APIs, services, or components this builds on?

**Estimation preferences:**
- Ask: "Do you want estimation on these stories? I can do T-shirt sizes (S/M/L/XL), or skip estimation entirely."
- Default to no estimation if the user doesn't have a preference

**Delivery preferences:**
- Ask: "Which project management tool does your team use?" (JIRA, Linear, Asana, Shortcut, Azure DevOps, GitHub Issues, or something else)
- Ask: "I can output the stories as a markdown document, or if you have an MCP integration connected for your tool, I can create them directly. Which do you prefer?"
- If the user wants direct creation, ask them to confirm the relevant MCP is available and connected. See `references/tool-mapping.md` for known MCP integrations and field mappings per tool.
- Remind them: "I'll prompt you before creating each item so you can approve or skip it."

**Story sizing philosophy:**
- Ask: "How do you like your stories scoped — small enough for one engineer in a day or two, or larger feature-level chunks?"
- This calibrates granularity. Default to 1-3 day stories if they don't have a preference.

---

## Phase 2: Decompose

### Decomposition strategy

Work through the reference document systematically. The goal is to produce stories that are:

- **Traceable**: every story maps to one or more requirements in the PRD/RFC
- **Independent**: stories can be worked on in parallel where possible (note dependencies explicitly when they can't)
- **Negotiable**: the story describes the "what" and "why", leaving implementation details to the engineer where appropriate
- **Valuable**: each story delivers a slice of user or business value (avoid pure-tech stories unless they're clearly prerequisites)
- **Estimable**: scoped clearly enough that the team can estimate them
- **Small**: right-sized per the user's preference (default: 1-3 engineering days)

### Decomposition approach

1. **Identify the major functional areas** from the document (these often map to sections or features in the PRD)
2. **For each area, extract the stories** — each story should represent a coherent, deliverable unit of work
3. **Order stories by dependency** — foundational work first, features that depend on it later
4. **Flag risks and open questions** — if the PRD has ambiguities, surface them as questions or spike stories rather than guessing

### Story format

Use this structure for every story. See `references/story-template.md` for the full template and examples.

```
### [STORY-TITLE]

**Summary**: One or two sentences describing what this story delivers and why.

**PRD/RFC Reference**: Section or requirement ID this maps to.

**Acceptance Criteria**:
- Given [precondition], when [action], then [expected result]
- Given ...
- ...

**Technical Subtasks**:
- [ ] Subtask 1 (e.g., "Create database migration for new table")
- [ ] Subtask 2 (e.g., "Implement API endpoint for X")
- [ ] Subtask 3
- ...

**Definition of Done**:
- [ ] Code reviewed and merged
- [ ] Unit tests written and passing
- [ ] Integration tests updated
- [ ] Documentation updated (if applicable)
- [ ] Deployed to staging and smoke-tested

**Estimation**: [T-shirt size if requested, otherwise omit]

**Dependencies**: [List any stories this depends on, or "None"]

**Open Questions**: [Any ambiguities from the PRD that need resolution]
```

#### Acceptance criteria guidance

Write acceptance criteria in Given/When/Then format. Each criterion should be specific and testable — an engineer or QA person should be able to verify it unambiguously. Avoid vague criteria like "works correctly" or "performs well." Instead: "Given a list of 10,000 items, when the user loads the page, then the initial render completes in under 2 seconds."

Aim for 3-7 acceptance criteria per story. Fewer than 3 usually means the story is under-specified. More than 7 might mean the story is too large and should be split.

#### Subtask guidance

Technical subtasks break the story into concrete implementation steps. They're not stories themselves — they're a checklist the engineer works through. Each subtask should be completable in a few hours at most. Common subtask patterns:
- Data model / migration changes
- API endpoint implementation
- Business logic / service layer
- UI component implementation
- Tests (unit, integration, e2e)
- Configuration / infrastructure changes

#### Definition of Done

Include a standard DoD checklist. The user may have team-specific items — ask during the interview if they want to customize the DoD. The default checklist covers code review, tests, docs, and staging deployment.

---

## Phase 3: Review & Refine

Present the full story list to the user as a numbered summary first (title + one-line summary + estimation if applicable), so they can see the big picture before diving into details.

Then ask:
- "Does this coverage look right? Anything missing or out of scope?"
- "Are any of these too big or too small?"
- "Should any be reordered or merged?"
- "Any acceptance criteria you want to adjust?"

Iterate until the user is satisfied. This phase is critical — don't rush it.

---

## Phase 4: Deliver

### Option A: Markdown output

Generate a clean markdown document with all stories. Structure it as:

```
# Epic: [Epic Title]

## Overview
[One paragraph summary of the epic, linking to the PRD/RFC]

## Stories

### 1. [Story Title]
[Full story content using the template above]

### 2. [Story Title]
...

## Dependency Map
[Simple text or mermaid diagram showing story dependencies]

## Open Questions
[Consolidated list of unresolved questions from across all stories]
```

Save to `/mnt/user-data/outputs/` and present to the user.

### Option B: Direct creation via MCP

If the user wants stories created directly in their project management tool and has confirmed the relevant MCP is connected:

1. Ask the user for the project identifier (e.g., JIRA project key "PROJ", Linear team, Asana project, GitHub repo) and the parent epic/initiative if it already exists
2. **For each story, present it to the user and ask for explicit confirmation before creating it.** Example: "Ready to create story 1: '[Title]' in [project]. Create it? (yes/skip/edit)"
3. If the user says "edit", let them adjust the story before creating
4. Use the appropriate MCP to create the item. Consult `references/tool-mapping.md` for the field mapping for each tool. The general pattern is:
   - Issue/item type: Story (or the tool's equivalent — "Issue" in Linear, "Task" in Asana, etc.)
   - Title/summary: story title
   - Description/body: full story content (summary, acceptance criteria, subtasks, DoD)
   - Parent link: the epic/initiative/project
   - Labels, components, or tags as appropriate
5. After each creation, confirm the resulting ID/URL back to the user (e.g., "Created PROJ-123" or "Created issue ENG-45")
6. Also create subtasks as child items linked to the parent story, if the user wants this and the tool supports it (ask once, apply to all)

**Important**: Always generate the markdown output as well, even when creating via MCP. The markdown serves as a local record and backup.

---

## Edge Cases & Guidance

- **No PRD/RFC provided**: You can still decompose based on a verbal description, but flag that the stories won't have document traceability. Encourage the user to provide a doc if one exists.
- **Very large epics (10+ stories)**: Group stories into logical phases or milestones. Suggest the user consider splitting into multiple epics.
- **Spike stories**: If the PRD has open questions that block story definition, create spike/research stories explicitly. These should have a clear timebox and deliverable (e.g., "Spike: Evaluate caching strategies — timebox 2 days, deliverable: ADR with recommendation").
- **Cross-team dependencies**: Flag these prominently. Suggest the user create linked stories or dependency items in the other team's project or board.
- **Non-functional requirements**: Don't forget performance, security, observability, and accessibility. These often get lost in decomposition. Create dedicated stories or weave them into acceptance criteria of existing stories, depending on scope.
