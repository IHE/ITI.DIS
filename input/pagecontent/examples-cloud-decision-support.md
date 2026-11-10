<div markdown="1" class="stu-note">
**Informative example.** The patient context, authorization, signing key, and URLs are synthetic. See [UC-4 Cloud Decision Support](volume-1.html#1pxx424-use-case-4-ai-assisted-clinical-decision-support-cloud-deployment).
</div>

An EHR prepares the authorized data for one encounter before sending them to a cloud decision support service. The [FHIR R4 `Task` for the job](Task-uc4-cloud-decision-support-job.html) selects a versioned HTTPS List for an R4 Patient, Encounter, and linked Observations. The Manager and De-Identifier operate within the hospital trust boundary. The EHR invokes the job synchronously.

## Approved Policy and Delivery

The EHR declares `https://governance.example.org/policies/uc4-cloud-decision-support|1.0` and carries the approved, JWS-signed [R4 Syntax-Level policy Library](Library-uc4-cloud-decision-support-policy.html). The payload-set metadata's `policyContent` references `#approved-policy`, the contained R4 Binary with `contentType = application/jose`. Its `data` decodes to the compact JWS. The JWS header includes the synthetic verification key. The Manager uses its configured trust model to verify the signature and checks the signed Library's canonical URL and version against the authorization and job submission.

The policy targets `Patient.identifier` for reversible salted pseudonymization within the authorized `cloud-cds-2026` linkage scope and removes `Patient.name`. The Manager validates these concrete R4 paths and packages the approved rules in the execution plan. The selected Encounter and Observations retain references that resolve to the pseudonymized Patient. A real release needs approved rules covering any additional identifying content in its selected resources.

## Synchronous Exchange

| Step | Exchange | What to verify |
|---|---|---|
| 1 | The EHR submits the job through ITI-x1 and waits on the original HTTP call. | The Manager validates authorization, the signed policy, and the exact versions selected by the List. |
| 2 | The Manager dispatches one de-identification task through ITI-x3 with the versioned input selection, compiled plan and reversible mode. | The worker applies the approved rules, preserves the clinical references, and returns `200 OK` with the result package, Provenance, and the protected `generatedLookupTable` parameter. |
| 3 | The Manager validates the result and evidence and retains the lookup table in the hospital. It returns `200 OK` on ITI-x1 with the pseudonymized result and Provenance. | The returned `payloadResult` reuses `encounter-context-r4`. The EHR-facing response contains the approved result and evidence. The mapping stays with the Manager. |
{: .grid}

The EHR sends the pseudonymized clinical data to the cloud service outside DIS. On return, the recommendation identifies the encounter's patient by the project pseudonym. The EHR uses authorized resolution within the hospital to associate the recommendation with the patient chart.
