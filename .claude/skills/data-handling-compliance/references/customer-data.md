## Customer Data

Customer Data is everything a customer puts into the product. The governing question is simple: whose data is it? It is the customer's. You hold it to provide the service, and your contracts and privacy policy should say so. Code has to match that.

### BLOCK

- **Training or fine-tuning any model on Customer Data** unless the customer has explicitly opted in under a contract that permits it. This includes embeddings stored for reuse across customers and "anonymised" training sets derived from customer content.
- **Cross-tenant access.** Any query, cache key, search index or export that can return one customer's data to another.
- **Moving Customer Data to a region** the contract or DPA does not permit.

### REQUIRE

- **Tenant isolation enforced at the data layer.** Every query is scoped by tenant on the server; the client never chooses which tenant it reads. Cache keys, search indexes, queues and file paths carry the tenant identifier.
- **Tests for isolation.** A new endpoint or store ships with a test showing that tenant A cannot read tenant B's data.
- **Export and deletion.** The customer can export their data and it is deleted at contract end, per the contract, including derived data (indexes, embeddings, summaries).
- **Bound prompt and response retention** when Customer Data is sent to a model, and include those records in deletion.
- **Support access is logged and time-boxed.** Staff reads of customer content need a reason and leave a record.

### FLAG

- A new vendor, region or subprocessor that receives Customer Data.
- Aggregated or derived statistics across customers (benchmarks, product analytics). Confirm the contract permits it and that no single customer is identifiable.
- Customer content entering internal tools: wikis, shared drives, chat, support systems searchable by the whole company.

### Residency

If you offer regional hosting, every store and processing step for that customer's data stays in the region, including backups, logs that contain content, model inference and third-party destinations. A new component that cannot be regional is a FLAG at minimum and a BLOCK if the contract promises residency.
