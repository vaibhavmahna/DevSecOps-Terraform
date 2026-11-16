## SOC 2 — Security, Availability, Confidentiality

Many organisations are in scope for three of the five trust services criteria: Security, Availability and Confidentiality. Check which criteria are in your own scope.

The thing to understand about SOC 2 is that it does not prescribe controls. It tests whether the controls you say you have are actually operating. An exception is raised when practice diverges from stated policy, which means **overclaiming is the risk, not underbuilding**. A modest control that genuinely runs passes. An ambitious control described in a policy and not implemented fails.

Two consequences for how you write code:

1. If a policy or a customer-facing statement says you do something, the code has to do it. If the code cannot, the statement needs to change, and that is a conversation rather than a silent divergence.
2. A control that runs but produces no evidence is very hard to pass. Logs, records and audit trails are not overhead; they are the control.

### Security

- **Least privilege, enforced not documented.** A role that technically can read everything but conventionally does not is a finding.
- **No secrets in code, config files, environment dumps, or logs.** Use the secret manager.
- **Authentication and authorisation checked server side**, on every request, at the data layer where possible. Client-side filtering is not access control.
- **Changes go through review.** Direct production writes, manual data fixes and out-of-band migrations need a record of who did what and why.
- **Monitoring that would actually notice.** A control nobody watches is not operating.

### Availability

**Jobs that fail silently are an availability problem, not just a bug.** So:

- Anything scheduled or asynchronous needs failure surfacing and alerting.
- Batch work handles partial failure without either stopping entirely or pretending it succeeded.
- New stores need a backup, and a restore that has been tested rather than assumed.
- Long-running operations need a bounded, observable path rather than an endpoint that quietly times out.

Backups interact with deletion: you cannot surgically delete one record from a backup set, so data survives there until the set ages out. That is workable provided the rotation is documented and bounded and restored data is re-deleted. An archive with no expiry is not acceptable.

### Confidentiality

- **Tenant isolation.** Cross-tenant leakage is the clearest confidentiality failure (see `customer-data.md`).
- **Disposal is part of the lifecycle.** This is the criterion that makes deletion a SOC 2 matter and not only a GDPR one.
- **Data classification followed** in where things are stored and who can reach them. Customer content does not belong in a general-purpose wiki, shared drive or company-wide support tool.
- **Vendor handling.** Anything confidential going to a third party needs the contractual basis in place first.

### Where GDPR and SOC 2 pull in the same direction

Most controls serve both. Deletion satisfies Art 17 and Confidentiality disposal. Access logging satisfies accountability under Art 5(2) and the Security criterion. Retention limits satisfy Art 5(1)(e) and reduce confidentiality exposure. Minimisation reduces both breach scope and DSAR effort.

The difference in emphasis: GDPR asks whether the processing is lawful and necessary at all; SOC 2 asks whether you do what you said. A change can satisfy SOC 2 while being unlawful under GDPR if the policy it implements was itself indefensible. That is why the PII and AI references ask about purpose and lawful basis, not only controls.
