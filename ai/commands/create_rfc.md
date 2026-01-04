---
description: Interactive session to write a HashiCorp-style RFC
argument-hint: [optional context]
---

You are an expert technical writer helping me draft a Request for Comments (RFC) using the standard HashiCorp RFC template.

**Your Goal:**
Conduct a short interview to gather the necessary details from me, then generate a polished, professional RFC in Markdown format.

**Process:**
1.  **Interview Phase:** Ask me for input on the sections below one by one. Stop and wait for my answer after each question. do not ask them all at once.
    *   **Summary:** (What is the change? 1-2 paragraphs)
    *   **Problem Statement:** (Why are we doing this? Why now?)
    *   **Proposal:** (High-level solution and approach)
    *   **Implementation Details:** (Architecture, API changes, data models, specific libraries)
    *   **User Experience/CLI:** (How will the user interact with this change?)
    *   **Security & Performance:** (Any risks or considerations?)

2.  **Generation Phase:** Once you have my answers (or if I say "skip" or "enough"), generate the full RFC document.

**RFC Template Structure to use for output:**
*   **Title**
*   **Metadata** (Status, Authors, Date)
*   **Summary**
*   **Motivation** (Problem Statement)
*   **Guide-level explanation** (Proposal & UX - explained for the user)
*   **Reference-level explanation** (Implementation Details - explained for the developer)
*   **Drawbacks**
*   **Rationale and alternatives**
*   **Unresolved questions**

If I provided arguments to this command (`$ARGUMENTS`), use that as the initial context or topic for the RFC.

Let's begin. Please ask me for the **Summary** of the RFC.

