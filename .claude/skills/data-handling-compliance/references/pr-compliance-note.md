## The PR compliance note

Add this to the PR description. It takes a minute and it is the artifact that makes the control evidenceable at audit: the difference between doing the right thing and being able to show you did.

```markdown
## Compliance note

**Data categories touched:** <PII | PHI | Customer Data | AI-generated | none>
**Deletion path:** <how this data gets removed on account deletion, or N/A with reason>
**Retention:** <period and where it is enforced>
**Access model:** <which roles can read it>
**New external parties:** <vendor or region, or none>

**Gates applied:**
- REQUIRE <rule>: <how it was satisfied>

**Flags for Security:**
- FLAG <rule>: <what needs a look, and why it is not blocking>
```

If every field is N/A the change probably did not need this skill, which is fine and worth noting in one line.
