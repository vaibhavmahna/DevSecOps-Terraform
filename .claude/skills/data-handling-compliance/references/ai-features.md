## AI features

Applies to any feature that sends data to a model or acts on model output: prompts, completions, summaries, embeddings, classifications, scores, agents and MCP tools. The rules for whatever goes into the prompt apply as well (PII, PHI, Customer Data).

### Prohibited practices

The EU AI Act bans some uses outright. Do not build:

- Manipulative or deceptive techniques that distort behaviour and cause significant harm.
- Exploitation of vulnerabilities due to age, disability or social or economic situation.
- Social scoring of people.
- Emotion recognition in the workplace or education, except for medical or safety reasons.
- Biometric categorisation that infers sensitive attributes (race, political opinion, religion, sexual orientation).
- Untargeted scraping of facial images to build recognition databases.

These are BLOCK.

### BLOCK

- **Training on Customer Data or processor PII** without an explicit, contractual opt-in (see `customer-data.md`).
- **Sending PHI to a model provider** without a BAA (see `phi.md`).
- **A model provider that retains or trains on inputs** when your commitments say customer data is not used for training. Use zero-retention or no-training settings and verify them.

### REQUIRE

- **Disclose AI interaction.** Users know when they are talking to or reading output from an AI system.
- **Human review where it matters.** Model output that affects a person's rights, money or access is reviewed by a person before it takes effect.
- **Treat model output as untrusted input.** Validate, escape and constrain it before it reaches HTML, SQL, shell, file paths or tool calls. Tool calls an agent makes are authorised as the user, never with broader rights.
- **Treat retrieved content as data, not instructions.** Documents, web pages and tool results fed to a model can carry prompt injection.
- **Bound retention** of prompts, responses and feedback, and include them in deletion.
- **No personal data in prompt logs** beyond what the retention rule allows; redact in observability tools.
- **Record which model and provider** produced stored output, so it can be traced and re-evaluated.

### FLAG

- A new model provider, or a change of region for inference.
- A feature that could be high-risk under the EU AI Act (employment, credit, education, essential services, law enforcement). Classification is Legal's call.
- Presenting model output as professional advice (legal, medical, financial). Label output as informational and make users responsible for reviewing it.
- New MCP servers or tools that give a model access to customer data or the ability to act on it.
