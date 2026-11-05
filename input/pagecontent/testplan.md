## DIS Conformance Test Plan

This draft checklist follows [Volume 1](volume-1.html), the authoritative profile baseline. Detailed procedures, fixtures and expected messages remain drafting work. This page does not report executed interoperability tests.

### Actor and Option Coverage

- De-Identification Requester: ITI-x1; ITI-x4 when DIS-ASYNC-JOB is declared.
- De-ID Manager: ITI-x1 and ITI-x3; ITI-x4 for DIS-ASYNC-JOB and ITI-x7 for DIS-ASYNC-TASK.
- De-Identifier: ITI-x3; ITI-x7 when DIS-ASYNC-TASK is declared.
- Integrated De-ID Manager/De-Identifier: content conformance in standalone mode; ITI-x1 when external job submission is supported, and ITI-x4 when DIS-ASYNC-JOB is declared. ITI-x3 and ITI-x7 do not apply.

Check the mandatory R4 protocol binding, required content modules and actor groupings against Volume 1. All actors require DIS-FHIR-Payload in Phase 1. Processing actors declare at least one of DIS-IRREVERSIBLE or DIS-REVERSIBLE. Test async job and task options independently and reject unsupported capability combinations before dispatch.

### Policy Admission and Execution

Cover canonical policy URL/version declarations and their match to data request authorization. Test both optional JWS-signed Requester-carried content and Manager-resolved content using the deployment's trust model. Verify authorization consistency, integrity, schema conformance and currency before acceptance or dispatch; failed or incomplete admission validation produces a synchronous error.

Cover Semantic-Level compilation, Syntax-Level validation and packaging, ordered rules, one execution plan per ruleSet, and optional stage ordering. Full composable execution plans and dataset-level statistical disclosure control are outside Phase 1.

### Transformation Actions

For each core action, specify valid and invalid parameters, applicable data types, expected transformed values and failure outcomes:

`remove`, `redact`, `replace`, `hash`, `truncate-date`, `round`, `truncate`, `date-shift`, and `keep`.

Use the action definitions in [Volume 3](volume-3.html#3593-transformation-actions). Cover scope/seed compatibility, date-shift consistency, derivation versions, rotation, collision handling and capability matching. Test protected parameter return/reuse only when an explicit capability contract permits it.

### Payload, Evidence and Release

Cover R4 workflow resources with independently versioned R4/R5/R6 payloads. R6 coverage is provisional, following the ballot-draft qualification in Volume 1. Verify declared-version validation and version-safe packaging; R5/R6 resources must not be embedded as native resources in R4 envelopes.

Cover synchronous inline output, asynchronous polling, both Bulk Data manifest directions, authorized file retrieval, expiry, missing files and failed-job output withholding. A failed job must release no partial dataset. Detailed manifest contracts remain subject to the payload and transaction bindings.

Inspect all nine evidence elements: evidence identifier, outcome status, workflow reference, target identifier, policy-decision reference, ruleSet identifier, reversibility state, validation status and audit correlation identifier. Verify reference integrity and handling of narratives, extensions, contained resources and attachments.

Check Manager custody of mappings/reversibility records, mode-dependent retention, task-terminal seed deletion and exclusion of protected transformation material from recipient-facing output, evidence and logs. Patient association in UC-3/4 remains implementation-defined and outside standardized DIS transactions.

### Validation and Reporting

Use synthetic fixtures. Validate available FHIR artifacts and examples, compile FSH, check links and diagrams, and build the guide. Record actor, declared options, preconditions, inputs, observable expected behavior and pass/fail criteria for each procedure. Standalone Integrated actor review includes pipeline behavior as well as output/evidence inspection. Artifact validity alone does not demonstrate operational interoperability or de-identification adequacy.

The Data Recipient and push-delivery proposal in UC-5 remains an open committee question; it is not an adopted Phase 1 test requirement.
