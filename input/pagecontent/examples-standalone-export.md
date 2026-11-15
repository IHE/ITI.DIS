<div markdown="1" class="stu-note">
**Informative example.** This synthetic case illustrates content conformance for the standalone Integrated De-ID Manager/De-Identifier.
</div>

A clinician uses a local workstation to export a FHIR R4 discharge summary. The workstation hosts the Integrated actor. It checks local authorization for the export and applies a locally approved DPV–ODRL policy. It compiles the patient name target using the [FHIR R4 DPV Category Mapping](volume-3-execution-plan.html#fhir-r4-dpv-mapping), applies `remove` to `Patient.name`, and validates the resulting document. The actor invokes the workflow locally.

| Artifact | What to inspect |
|----------|-----------------|
| [Input document Bundle](Bundle-standalone-export-input.html) | The Composition selects a Patient with a synthetic name and references the included author. |
| [Locally approved policy](Contract-standalone-export-policy.html) | The R4 Contract carries an irreversible policy targeting the patient's structured `pd:Name` data. |
| [Result document Bundle](Bundle-standalone-export-output.html) | The Patient's name is absent. The output has fresh resource and document identities, and the Composition's subject, author, and section references resolve within the output Bundle. |
| [Provenance evidence](Provenance-standalone-export-evidence.html) | The evidence identifies the output Bundle, policy, ruleSet, Integrated actor, validation result, and audit correlation. |
{: .grid}

The actor validates the document and its references, then makes the document and evidence available through the workstation's export mechanism. It records the policy, ruleSet, outcome, and correlation identifier in its ATNA audit trail. The reviewer checks that the exported Provenance and the audit record identify the same local export. This use case is a local invocation, so its conformance claim is for the content. See [De-Identified Health Data Export](volume-1.html#1pxx425-use-case-5-de-identified-health-data-export-content-conformance).
