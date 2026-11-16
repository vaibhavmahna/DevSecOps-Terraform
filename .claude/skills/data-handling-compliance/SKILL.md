---
name: data-handling-compliance
description: "GDPR, SOC 2 and health-data rules for code touching personal data, health data, customer data, or AI features. Use whenever writing, reviewing, or planning code that stores, moves, logs, exposes, deletes, or infers from data about people, and whenever adding or changing an AI feature, model provider, integration, subprocessor, or data store. Trigger even when the request never mentions compliance, privacy, GDPR, or SOC 2, because most gaps arrive inside ordinary feature work like \"add a field\", \"log this for debugging\", \"cache the response\" or \"send it to the warehouse\". If the change touches a user, contact, form submission, email body, health record, prompt, or model output, this skill applies."
---

# Data handling compliance

Most products that hold data about people carry two sets of obligations that show up in code: GDPR, and SOC 2 (commonly the Security, Availability and Confidentiality trust criteria). This skill turns those into rules you can apply while writing the code, so compliance is a property of the change rather than a review that happens afterwards.

Adjust the specifics (retention periods, regions, which criteria are in scope) to your organisation's own policies. Where this skill and your published policy disagree, the policy wins and this skill should be updated.

## Why this exists

Compliance gaps are rarely created by someone deciding to ignore policy. They build up one ordinary change at a time: a new table with no deletion path, a job that fails silently, an archive with no expiry, a warehouse that keeps everything because deleting is expensive. The most valuable thing this skill does is catch the small additions, because those are what compound.

## How to use it

1. **Classify the data** the change touches, using the tree below. A change can touch more than one category, in which case every applicable rule set applies.
2. **Apply the rules at the tier they carry.** BLOCK, REQUIRE and FLAG mean different things, described below.
3. **Add the compliance note to the PR** so the reviewer and any future auditor can see what was considered.

## Classify the data

Work through these in order. Stop at the first match, then check whether any later category also applies.

**Is it health data, or data from a customer in a healthcare context?**
Diagnoses, treatment, medication, insurance, clinical notes, or anything a covered entity put into the product. → PHI. The strictest category: treat ambiguity as PHI until someone confirms otherwise.

**Can it identify a person, directly or in combination?**
Names, emails, phone numbers, IP addresses, device or cookie identifiers, form submissions, billing addresses, user records, email metadata or bodies. → PII. Check whether you are the controller or the processor for it, because that changes what you may do with it.

**Does it belong to a customer under contract?**
Anything the customer put into the product: content, records, notes, attachments. → Customer Data. It may or may not contain PII, and the rules stack if it does.

**Is it produced by a model, or does it feed one?**
Prompts, completions, summaries, embeddings, scores, classifications, recommendations. → AI, plus the rules for whatever went into the prompt.

**None of the above?**
If it is genuinely not about people and not customer content, these rules do not apply. Secrets, credentials and internal system data still fall under Confidentiality, see `references/soc2.md`.

If you cannot confidently classify it, treat it as PII and add a FLAG. Guessing low is the expensive direction.

## The three tiers

**BLOCK** means stop. Do not write the code, do not merge it behind a flag, do not pilot it with one customer. These are cases where a public or contractual commitment would be broken, or the law prohibits it outright. There are deliberately few of them. When you hit one, say which commitment is in the way and what would need to change, then stop and route to Security.

**REQUIRE** means there is one correct way to do this, and you implement it as part of the change rather than asking. If it makes the work materially larger, say so in the PR, but implement it. A REQUIRE is not a follow-up ticket, because follow-up tickets are how gaps are built.

**FLAG** means proceed, but annotate. The situation is legitimate and probably fine, but has a dimension Security or Legal needs to know about: a new external party, a new region, or a novel kind of processing. Write the flag into the PR compliance note and carry on. You are not blocked waiting for an answer.

If a rule feels wrong for your case, surface it rather than working around it. A rule that is wrong in practice should be fixed in this skill.

## Rules that apply to everything

**Every new store of personal data needs a deletion path on day one.** A new table, index, cache, bucket, queue, warehouse table or third-party destination that holds data about people is wired into the account deletion process in the same change. A store left out is invisible to deletion forever.

**Deletion must fail loudly.** A deletion job that silently does nothing is worse than none, because you then report compliance you do not have. Anything that deletes needs error surfacing, alerting on failure, and a record of what it deleted.

**Retention is set when the store is created,** not decided later. Unbounded retention is a decision that needs a stated reason.

**No personal data in logs, traces, error messages, analytics events, or crash reports.** Redact before it leaves the request, including the contents of failed form submissions.

**No production personal data in dev, staging, test fixtures, seed data, or local environments.** Generate synthetic data instead.

**Access is role-scoped and least privilege.** "Everyone can read it" is not an access model. Where the data is sensitive, reads are logged.

## Rules by category

The detailed BLOCK, REQUIRE and FLAG rules live in one reference file per category. After classifying, read every file whose category you matched, in full, before writing or reviewing the code.

| Category matched | Read |
|---|---|
| PII and deletion timing | [references/pii.md](references/pii.md) |
| PHI and health data | [references/phi.md](references/phi.md) |
| Customer Data, tenant isolation, residency | [references/customer-data.md](references/customer-data.md) |
| AI features, prompts, model output, MCP | [references/ai-features.md](references/ai-features.md) |
| Secrets, internal data, jobs, backups, access control | [references/soc2.md](references/soc2.md) |
| Writing the PR compliance note | [references/pr-compliance-note.md](references/pr-compliance-note.md) |
| Unresolved questions and the changelog | [references/open-items.md](references/open-items.md) |

## How this is enforced here

`git commit` is refused until the `compliance-reviewer` agent has returned `COMPLIANCE: PASS` for exactly the files that are staged. A file edited after the review needs a new review. An open BLOCK or an unmet REQUIRE fails the review. FLAG items pass and go into the compliance note, which `python3 .claude/tools/compliance.py note` prints for the PR description. `gh pr create` is refused without that note.

## Escalation

FLAG items go in the PR and get picked up asynchronously.

BLOCK items and anything you cannot classify go to Security directly. Give them the change, the data involved, and which commitment you think is in the way. That framing gets a faster answer than "can you review this".

## Things this skill does not decide

Some questions belong to Legal: whether a retention period is defensible, whether a feature is high-risk under the EU AI Act, whether a contract permits a processing purpose. In those cases FLAG and keep moving rather than guessing on Legal's behalf.
