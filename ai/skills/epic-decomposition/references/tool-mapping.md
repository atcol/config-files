# Tool Mapping Reference

This document maps the generic story fields used by this skill to the specific terminology and field names in each supported project management tool. Consult this when delivering stories via MCP.

## Terminology Mapping

| Generic Term       | JIRA              | Linear            | Asana             | Shortcut          | Azure DevOps       | GitHub Issues      |
|--------------------|-------------------|-------------------|-------------------|-------------------|--------------------|--------------------|
| Story / Work Item  | Story (issue type) | Issue             | Task              | Story             | User Story (work item type) | Issue             |
| Epic               | Epic              | Project           | Project / Section | Epic              | Feature            | Milestone or Label |
| Subtask            | Sub-task          | Sub-issue         | Subtask           | Task (in Story)   | Task               | Task list item     |
| Sprint             | Sprint            | Cycle             | (not native)      | Iteration         | Iteration          | Milestone          |
| Project Identifier | Project Key (e.g., "PROJ") | Team identifier | Project GID      | (auto)            | Project name       | Repo (owner/repo)  |
| Label              | Label             | Label             | Tag               | Label             | Tag                | Label              |
| Priority           | Priority          | Priority (0-4)    | (custom field)    | (not native)      | Priority           | (not native)       |
| Estimation         | Story Points / custom | Estimate (points) | (custom field)   | Estimate          | Story Points       | (not native)       |

## MCP Integration Notes

### JIRA (Atlassian MCP)
- MCP name: typically `atlassian-mcp` or similar
- Create issues via the MCP's issue creation tool
- Set `issuetype` to "Story" and link to epic via the epic link field
- Description supports Atlassian Document Format (ADF) or wiki markup — prefer markdown, most MCPs handle conversion
- Subtasks: create as separate issues with `issuetype: "Sub-task"` and `parent` set to the story key

### Linear
- MCP name: typically `linear-mcp` or similar
- Create issues via the MCP's issue creation tool
- Link to a project (Linear's equivalent of epic) by setting the `projectId`
- Description is markdown-native
- Sub-issues: create with `parentId` set to the parent issue ID
- Estimation: use the team's configured point scale

### Asana
- MCP name: typically `asana-mcp` or similar
- Create tasks in a project, optionally within a section
- Description field supports rich text (HTML-like)
- Subtasks: create as subtasks of the parent task
- No native story points — use a custom field if the team has one

### Shortcut
- MCP name: typically `shortcut-mcp` or similar
- Create stories within an epic
- Description is markdown
- Tasks (subtasks) are created within the story directly
- Estimate field maps to story points

### Azure DevOps
- MCP name: typically `azure-devops-mcp` or similar
- Create work items of type "User Story"
- Link to parent Feature (Azure DevOps' equivalent of epic) via parent link
- Description supports HTML
- Tasks: create as child work items of type "Task"

### GitHub Issues
- MCP name: typically `github-mcp` or similar
- Create issues in the target repository
- Use labels to group by epic, or link to a Milestone
- Description is markdown
- Subtasks: use task lists in the issue body (`- [ ] subtask`) — GitHub doesn't have native subtask items
- No built-in estimation — note this to the user

## When No MCP Is Available

If the user's tool doesn't have an MCP integration, or they haven't connected it:
1. Generate the markdown output (Option A) — this is always the fallback
2. Suggest the user import manually. Some tools support CSV or bulk import:
   - JIRA: CSV import via project settings
   - Linear: CSV import or API
   - Asana: CSV import
   - Azure DevOps: CSV import or Excel plugin
3. If the user wants, you can also generate a CSV with columns mapped to their tool's import format
