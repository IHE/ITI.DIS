<div markdown="1" class="stu-note">
**Informative example.** The patient context, authorization, signing key, and URLs are synthetic. See [UC-4 Cloud Decision Support](volume-1.html#1pxx424-use-case-4-ai-assisted-clinical-decision-support-cloud-deployment).
</div>

An EHR prepares the authorized data for one encounter before sending them to a cloud decision support service. The [FHIR R4 `Task` for the job](Task-uc4-cloud-decision-support-job.html) selects a versioned HTTPS List for an R4 Patient, Encounter, and linked Observations. The Manager and De-Identifier operate within the hospital trust boundary. The EHR invokes the job synchronously.

## Approved Policy and Delivery

The de-identification job references the [synthetic Data Request Authorization](Contract-uc4-care-approval.html) and selects the permission that binds its set to the approved policy version.

The EHR declares `https://governance.example.org/policies/uc4-cloud-decision-support|1.0` and carries the approved [R4 Syntax-Level Policy Contract](Contract-uc4-cloud-decision-support-policy.html). The payload-set metadata's `policyContent` references `#approved-policy`, a contained Binary with `contentType = application/fhir+json`. Decoding `Binary.data` yields the complete Policy Contract, with the issuer's signature in `Contract.signer.signature`.

The policy targets `Patient.identifier` for reversible salted pseudonymization within the authorized `cloud-cds-2026` linkage scope and removes `Patient.name`. The Manager validates these concrete R4 paths and packages the approved rules in the execution plan. The selected Encounter and Observations retain references that resolve to the pseudonymized Patient. A real release needs approved rules covering any additional identifying content in its selected resources.

<a name="signature-verification"></a>

## Verify the Policy Contract Signature

This example deployment requires a Policy Contract signature in both delivery modes. It uses an independently provisioned synthetic public key for the approval authority. Its local settings accept the authorization through a trusted repository and establish execution-plan integrity through authenticated retrieval of the assigned revision. It releases clinical output and transformation Provenance to the EHR and keeps the supporting Contracts with the Manager.

```json
{
  "kty": "RSA",
  "n": "573gBsCLCcv7m2iX_gX2ldogOt-ubxBR04zsoujM924s1LWwzxbE-FNkjH-a9AWuh3y5KFAeuUBPvIMSAQyGMvOuAlW-iWkCk6TwsOyv8cpHa5uYxaW0Ls-YJcHnJSH5LRU9XgOY3VBzB673sgXK5Uh2K2Nj5I5g_tdQ9CTD5QBUK8XD8FcsJZVb3ECLgmWbJthnc2eSCzOKBfFdDiMs_TLloTA4d0lckyjdzx2WBYWRbKA8S0CReDgGaCWht_RhN-kogh_11ks62nSSU_Np3mbGb2BS_LPIl423W_ERCFCq5cid3YacmXTJV7Z61j69j5XrlWBgZZ9y2KVoVXHwZw",
  "e": "AQAB",
  "kid": "dis-example-issuer-rs256"
}
```

1. Decode the policy Binary and confirm the Contract's canonical URL and business version match those approved by the selected permission. The same signed Contract can be obtained from the trusted policy repository.
2. Read `Contract.signer[0].signature[0]` and Base64-decode its `data` to obtain the detached compact JWS. Confirm that the protected header identifies `RS256` and the provisioned key. Confirm that the signer and its stated party identify the trusted approval authority.
3. For this example's signing procedure, copy the entire Policy Contract and remove `signer[0].signature[0].data`. The example has one signer and one signature. Preserve the remaining fields, including `meta.versionId` and the ODRL attachment. Serialize as UTF-8 JSON with alphabetically sorted object properties, original array order and no whitespace between tokens. Preserve whitespace inside string values. This procedure applies to the example's JSON values.
4. Verify the detached JWS over those bytes using the provisioned key, per [RFC 7515 Appendix F](https://www.rfc-editor.org/rfc/rfc7515#appendix-F). The original policy verifies. Changing its Contract version or ODRL attachment makes verification fail. The Manager also checks the grant and policy currency before admission.

## Synchronous Exchange

| Step | Exchange | What to verify |
|---|---|---|
| 1 | The EHR submits the job through ITI-x1 and waits on the original HTTP call. | The Manager validates authorization, the signed policy, and the exact versions selected by the List. |
| 2 | The Manager dispatches one de-identification task through ITI-x3 with the versioned input selection, compiled plan and reversible mode. | The worker applies the approved rules, preserves the clinical references, and returns `200 OK` with the result package, Provenance, and the protected `generatedLookupTable` parameter. |
| 3 | The Manager validates the result and evidence and retains the lookup table in the hospital. It returns `200 OK` on ITI-x1 with the pseudonymized result and Provenance. | The returned `payloadResult` reuses `encounter-context-r4`. The EHR-facing response contains the approved result and evidence. The mapping stays with the Manager. |
{: .grid}

The EHR sends the pseudonymized clinical data to the cloud service outside DIS. On return, the recommendation identifies the encounter's patient by the project pseudonym. The EHR uses authorized resolution within the hospital to associate the recommendation with the patient chart.
