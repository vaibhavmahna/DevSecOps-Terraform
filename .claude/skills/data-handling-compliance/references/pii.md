## PII — personal data under GDPR

Personal data is anything that identifies a person directly or in combination. Before writing code, know whether you are the **controller** (you decide the purposes, for example your own users' accounts and billing) or the **processor** (you act on a customer's instructions, for example contacts a customer collects through your product). As a processor you may only use the data for the service the customer contracted.

### BLOCK

- **Using processor data for your own purposes**: marketing, enrichment, cross-customer analytics or model training on data you hold on a customer's behalf.
- **Collecting a new category of personal data with no stated purpose.** Data minimisation (Art 5(1)(c)) means "might be useful later" is not a purpose.
- **Selling or sharing personal data** with a party not disclosed in the privacy policy or subprocessor list.

### REQUIRE

- **Deletion path in the same change** for every new store (see SKILL.md).
- **Data subject requests work end to end.** Access (Art 15), rectification (Art 16), erasure (Art 17) and portability (Art 20) must reach the new field or store. If a DSAR export would miss it, add it.
- **Minimise at collection.** Store only the fields the feature needs; truncate or hash identifiers used only for matching.
- **Encryption in transit and at rest** for any store holding personal data.
- **Redact before logging**, including request bodies, query strings and error payloads.
- **Consent or another lawful basis recorded** where the processing depends on it (marketing, non-essential cookies, tracking).

### FLAG

- A new country or region where personal data will be stored or processed (international transfer, Chapter V).
- A new third party that receives personal data (subprocessor list and DPA need updating).
- Profiling or automated decisions with legal or similarly significant effects (Art 22).
- A new category of special-category data (Art 9): health, biometrics, religion, ethnicity, sexual orientation, political opinion.

### Deletion timing

- Deletion runs within the period your published policy states. Pick one end-to-end figure and make every store meet it, including caches, search indexes, warehouses and third-party destinations.
- Soft delete is not deletion. A soft-deleted record must be hard-deleted or irreversibly anonymised within the stated period.
- Backups age out on a documented, bounded rotation, and restored data is re-deleted before use. A backup rotation explains why a copy exists for a while; it does not justify a longer retention period.
- If a customer's contract sets a different period, support a per-account override rather than changing the default.
- Statutory exceptions (tax, audit, legal hold) keep only the minimum fields the obligation needs, and are recorded with the reason.
