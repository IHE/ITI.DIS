## DIS Conformance Test Plan

This draft checklist follows [Volume 1](volume-1.html), the authoritative profile baseline. Detailed procedures, fixtures and expected messages remain drafting work. This page does not report executed interoperability tests.

## Actor and Transaction Conformance

### Actor and Option Coverage

- De-Identification Requester: ITI-x1; ITI-x4 when DIS-ASYNC-JOB is declared.
- De-ID Manager: ITI-x1 and ITI-x3; ITI-x4 for DIS-ASYNC-JOB and ITI-x7 for DIS-ASYNC-TASK.
- De-Identifier: ITI-x3; ITI-x7 when DIS-ASYNC-TASK is declared.
- Integrated De-ID Manager/De-Identifier: content conformance in standalone mode; ITI-x1 when external job submission is supported, and ITI-x4 when DIS-ASYNC-JOB is declared. ITI-x3 and ITI-x7 do not apply.

Check the mandatory R4 protocol binding, required content modules and actor groupings against Volume 1. All actors require DIS-FHIR-Payload in Phase 1. Processing actors declare at least one of DIS-IRREVERSIBLE or DIS-REVERSIBLE. Test async job and task options independently and reject unsupported capability combinations before dispatch.

### Policy Admission and Execution

Cover canonical policy URL/version declarations and their match to data request authorization. Test both optional JWS-signed Requester-carried content and Manager-resolved content using the deployment's trust model. Verify authorization consistency, integrity, schema conformance and currency before acceptance or dispatch; failed or incomplete admission validation produces a synchronous error.

Cover Semantic-Level compilation, Syntax-Level validation and packaging, ordered rules, one execution plan per ruleSet, and optional stage ordering. Full composable execution plans and dataset-level statistical disclosure control are outside Phase 1.

Compile a policy targeting `@dates` against R4 and R5 Encounter payloads. Verify that the plan uses `Encounter.period` for R4 and `Encounter.actualPeriod` for R5, that the plans preserve source rule and selector order, and that no semantic group references remain. Use an unknown group or a release with no binding and verify that the Manager fails compilation before dispatch. For a choice selector, verify that a dateTime or Period value is selected and a free-text value is outside the selection. Compile separate rules for `@birth-dates`, `@dates`, and `@subject-demographics` using binding version 0.2.0 for R4 and R5. Verify that only the `@birth-dates` rule emits a selector for `Patient.birthDate`.

### Transformation Actions

For each core action, specify valid and invalid parameters, applicable data types, expected transformed values and failure outcomes:

`remove`, `redact`, `replace`, `hash`, `truncate-date`, `round`, `truncate`, `date-shift`, and `keep`.

Use the action definitions in [Volume 3](volume-3.html#3pxx13-transformation-actions). Cover scope and salt compatibility, date-shift consistency, derivation versions, rotation, collision handling and capability matching. Test protected parameter return/reuse only when an explicit capability contract permits it.

### Payload, Evidence and Release

Cover R4 workflow resources with independently versioned R4/R5/R6 payloads. R6 coverage is provisional, following the ballot-draft qualification in Volume 1. Verify declared-version validation and version-safe packaging; R5/R6 resources must not be embedded as native resources in R4 envelopes.

Exercise inline R4 and cross-version submissions, including dispatch to a separate De-Identifier using an authorized reference to the submitted content. Reject a relative reference with no unambiguous source base and a payload whose version metadata conflicts with `payloadVersion`. Submit a resource manifest and verify processing of its listed resources. Submit the same List as a direct `processingTarget` and verify that its entry references do not expand the target set. Reject a submission that supplies both `resourceManifest` and `processingTarget` or includes an unauthorized entry. Verify that a retry uses the same manifest entry set. Inspect task and job result manifests and verify that their entries resolve to authorized de-identified resources. For bulk input, exercise a complete authorized manifest, a dataset outside the job's approved scope, and missing files or expired access. Verify failure reporting and withholding of job output on any required input failure. Cover synchronous inline output, asynchronous polling, and authorized bulk result retrieval once the result encodings are defined.

Inspect all nine evidence elements: evidence identifier, outcome status, workflow reference, target identifier, policy-decision reference, ruleSet identifier, reversibility state, validation status and audit correlation identifier. Verify reference integrity and handling of narratives, extensions, contained resources and attachments.

Check Manager custody of mappings/reversibility records, mode-dependent retention, deletion of temporary mapping copies at task termination and exclusion of protected transformation material from recipient-facing output, evidence and logs. Patient association in UC-3/4 remains implementation-defined and outside standardized DIS transactions.

### Jobs with Multiple Payload Sets

Submit a grouped job containing two distinct set identifiers and approved policies. When the DICOM option is available, exercise one FHIR set and one DICOM set whose Resource Manifest points to an R4 ImagingStudy. Verify that only the enumerated SOP instances are retrieved. When the CDA option is available, verify that the manifest resolves a DocumentReference to one CDA document. Reject a manifest with the wrong index type, an ambiguous imaging endpoint, or an unauthorized native object. Verify that result manifests use result indexes and that their native content is de-identified. Verify dispatch and plan selection per set, including a handoff from bundled to hosted content that preserves the target set. Compare bundled and externally hosted manifest entries for each supported binding. For R5 and provisional R6, exercise an R4 wrapper with inline bytes and with an HTTPS attachment URL. Reject direct cross-release List references, unresolved bundle-local references, wrappers with both data and URL, a mismatched payload release, duplicate set identifiers, mixed grouped and ungrouped forms, and unauthorized manifest entries. Verify correlation of each result and its evidence to the submitted set. Fail one task after another set succeeds and verify that the Requester receives no output for either set.

#### Mixed R5 and DICOM Job Procedure

Use the [mixed payload walkthrough](examples-mixed-r5-dicom.html) once the DICOM binding is available for testing. Configure an R5-capable De-Identifier, a DICOM-capable De-Identifier, and an imaging endpoint with two authorized instances and an additional instance outside the manifest. Use one permit covering both sets and their approved policies.

| Step | Action | Expected result |
|------|--------|-----------------|
| 1 | Submit the inline R5 package and the version-specific imaging List in ITI-x1 with `Prefer: respond-async`. | The Manager returns `202 Accepted` and a polling URL. Both set-to-policy assignments are recorded under the job. |
| 2 | Inspect the two ITI-x3 requests and observe source retrieval. Repeat the imaging retrieval against the same job selection. | The clinical task receives the submitted R5 bytes. The imaging task uses the assigned endpoint and the same two SOP Instance UIDs on each attempt. The worker does not retrieve the unlisted instance. |
| 3 | Complete the clinical task while the imaging task remains in progress. Poll ITI-x4 with the Requester's credentials. | The Manager returns in-progress status and no payload results. The Requester cannot retrieve intermediate output through the result service. |
| 4 | Complete imaging and poll ITI-x4 again. | One successful response contains two `payloadResult` groups with the original set IDs. Verify that the clinical evidence resolves to the R4 wrapper, the draft imaging evidence resolves to the result index, and the manifest selects only the two de-identified DICOM instances. |
| 5 | Repeat with one imaging instance unavailable after acceptance and the clinical task successful. | The imaging task reports failure. ITI-x4 returns an `OperationOutcome`. Neither set is made available to the Requester. |
{: .grid}

### Reversible Lookup Mapping

Cover both mandatory DIS-REVERSIBLE arrangements: absent table causes Manager mapping creation/maintenance and persistence; supplied table causes authoritative direct-identifier replacement without mandatory Manager persistence. Test complete tables, missing entries before acceptance and after async acceptance, duplicate/ambiguous mappings, incompatible irreversible policy, unauthorized scope, no fallback generation, consistent patient identifier replacement and valid output references, task-scoped disclosure and terminal deletion. Missing entries must reject/fail the complete job and release no partial output. Inspect that source identifiers and mappings are absent from recipient-facing evidence, logs and error diagnostics.

### Cross-Community Consistency Prerequisites

For deployments claiming cross-community pseudonym consistency, inspect externally established identity resolution, shared-scope authorization and coordination of salt versions. For matching source identifier pairs, the same scope and salt version SHALL produce the same pseudonym across participating De-Identifiers. Cross-community prerequisites remain outside the DIS transaction test.

### Pseudonym Derivation and Policy Compatibility

Exercise the published salted and unsalted test vectors. Verify matching output across workers and retries using the same source identifier, scope and effective salt. Verify different salted scopes, rejection of an unauthorized scope, missing or incorrectly sized salts, and incompatible execution plan parameters. For patient identifier hashing, verify the replacement system and full digest. Verify that retained internal FHIR references resolve in the output.

For reversible patient hashing, verify the inline `generatedLookupTable` in synchronous ITI-x3 and asynchronous ITI-x7 completion. Validate the original-to-pseudonym pairs, resolved scope and Manager retention before release. Check that the supplied-table and irreversible patient workflows do not return a generated patient table. Verify that mapping artifacts and confidential salts stay out of recipient output, evidence, logs and errors.

### Persistent Lookup Table References

Check the DIS-LookupTable DocumentReference and DIS-LookupTableContent Binary profiles. Exercise literal and version-specific references, exact-version identifier resolution, inline JSON and Binary attachments, stable business identifiers and content-version masterIdentifier, policy/content scope agreement, current-status admission, unavailable or unauthorized retrieval, ambiguous identifiers, and changed bytes under a pinned identifier. Verify a job/retry uses one pinned snapshot and task subsets use distinct derived document identifiers with transforms provenance. Delete temporary snapshots and derived task artifacts without deleting the Requester's authoritative repository.

## Artifact Validation and Reporting

Use synthetic fixtures. Validate available FHIR artifacts and examples, compile FSH, check links and diagrams, and build the guide. Record actor, declared options, preconditions, inputs, observable expected behavior and pass/fail criteria for each procedure. Standalone Integrated actor review includes pipeline behavior as well as output/evidence inspection. Artifact validity alone does not demonstrate operational interoperability or de-identification adequacy.

The [Data Recipient and push-delivery proposal](issues.html#data-recipient-and-push-delivery) remains open. Phase 1 assesses the standalone UC-5 case through content conformance.

### Published Lookup Table Examples

Validate the [published lookup table examples](volume-3.html#3pxx18-worked-mapping-examples) against their declared FHIR profiles. Decode the Binary and inline attachments and check that they carry the same table. Check that the task-scoped example references the source version and contains only the assigned mappings. Validate the generated table and confirm that its pseudonym matches the salted test vector and the published Patient example.
