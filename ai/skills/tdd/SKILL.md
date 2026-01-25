---
name: tdd
description: Test-Driven Development workflow for implementing features, fixes, and refactors. Triggers on "start TDD", "implement feature using TDD", "use test-driven development", "begin TDD workflow", or when asked to work on features/bugs/refactors following TDD principles.
---

# Test-Driven Development Workflow

Guide development using test-driven development principles. This skill establishes the mindset and process for implementing features, bug fixes, and refactors.

**Important:** Do not start working on features until explicitly asked. This document establishes the development approach.

## Workflow

### 1. Prepare the Branch

- Ensure you're on the main branch (unless instructed otherwise)
- Read and understand existing code before making changes
- Create a feature branch for the work

### 2. Understand the Task

- Read README.md and relevant documentation
- Ask clarifying questions for important ambiguities
  - Example: "Should this be a TUI, web-based, or something else?"
- Update README.md with insights gained

### 3. Create Notes

Create a markdown file under `notes/features/` matching the branch name:
- Record answers to clarifying questions
- Note important decisions and context
- Use as long-term memory if session is interrupted
- Keep notes brief and helpful

### 4. Red-Green-Refactor Cycle

Repeat this cycle for each piece of functionality:

#### Red Phase
- Write a failing test that enforces new desired behaviour
- Run the test - it should fail (or not compile)
- **Do NOT modify non-test code in this phase**

#### Green Phase
- Write the simplest code to make all tests pass
- **Do NOT modify tests in this phase**
- Commit when all tests pass (don't push yet)

#### Refactor Phase
- Improve code organisation, readability, and maintainability
- Consider how to enhance the broader codebase affected by changes
- Follow Martin Fowler's refactoring guidance
- Minor refactors: single commit
- Major refactors: commit in stages
- Commit when all tests pass

### 5. Wrap Up

- Push the branch to GitHub
- Submit a pull request
- Move on to the next task if working from a list

## Commit Messages

See `references/commit-conventions.md` for detailed formatting requirements.

Key points:
- Use conventional commits structure
- Use British English spelling and grammar
- Omit the "Claude" commit footer
- Include issue link on the last line (if applicable)

## Special Cases

### Pure Refactoring

When asked to refactor directly (not as part of the development cycle):
- Do NOT start with a new test
- Refactoring restructures without changing behaviour
- Existing tests should continue to pass

### Multiple Tasks

When given a list of tasks:
- Complete them one by one
- Create a separate branch for each
- Submit a pull request before moving to the next

## Capturing Guidance

When corrected during work:
- Update this skill document with generic guidance
- Add additional prompt documents as needed
- Keep guidance project-agnostic for future reuse
