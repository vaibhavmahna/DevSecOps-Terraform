## PHI — protected health information

If your customers include healthcare providers, insurers or their business associates, health data can enter the product even if you never designed for it: a note on a contact record, an attachment, a form field. Under HIPAA, when a covered entity signs a Business Associate Agreement (BAA) with you, you take on business associate obligations for that data, and every vendor that touches it must be covered by a BAA too.

Treat ambiguity as PHI until someone confirms otherwise.

### BLOCK

- **Processing PHI through any vendor without a BAA.** This includes model providers, logging and APM tools, analytics, error trackers, email services and support tooling. If customer content that could contain PHI reaches a vendor, that vendor needs a BAA covering it.
- **Using PHI for anything beyond providing the service**: analytics, model training, marketing or product research.
- **PHI in non-production environments**, in any form, including "anonymised" copies that have not been through a documented de-identification method.

### REQUIRE

- **Access logging** for every read of records that may contain PHI, retained per your policy.
- **Minimum necessary access.** Support and engineering roles see PHI only when a specific task needs it, and that access is logged.
- **Encryption in transit and at rest**, with keys managed by your key management system.
- **Breach detection hooks.** Unusual bulk reads or exports of PHI-bearing records raise an alert.
- **Deletion and return** of PHI at contract end, per the BAA.

### FLAG

- Any new path by which customer free text, attachments or notes can reach a third party.
- A feature aimed at healthcare customers specifically.
- De-identification of health data for any purpose (Safe Harbor or Expert Determination needs to be chosen and documented).

### Before writing code

Ask: which customer instances could contain PHI, and does every vendor in this path have a BAA covering them? If you cannot answer, FLAG and route to Security before the data moves.
