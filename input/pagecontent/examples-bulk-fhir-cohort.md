<div markdown="1" class="stu-note">
**Informative example.** The manifest and NDJSON files are synthetic fixtures. Example URLs represent authorized endpoints in the walkthrough.
</div>

An authorized Requester submits a two-Patient R4 cohort as an asynchronous job. The [input manifest](examples/bulk-fhir/input-manifest.json) lists two prepared files, [input file 1](examples/bulk-fhir/input-patients-1.ndjson) and [input file 2](examples/bulk-fhir/input-patients-2.ndjson). Each file contains one complete Patient. The approved irreversible policy removes `Patient.name`. This example assigns fresh opaque resource identities for the output and introduces no mapping for reversal.

| Exchange | What the message carries |
|----------|--------------------------|
| ITI-x1 | A Job Task with authorization and one `payload-set` input with `setId = cohort-r4`, `payloadBinding = DIS-FHIR-Payload`, `payloadVersion = R4`, and the approved policy URL and version. Use `manifestFormat = fhir-bulk-data` and an `application/json` manifest attachment with the HTTPS input manifest URL. The Requester sends `Prefer: respond-async`. The Manager returns `202 Accepted` with the job polling URL. |
| ITI-x3 | The Manager dispatches that set with a concrete R4 execution plan and irreversible mode. The De-Identifier obtains credentials accepted by the manifest and file services and retrieves both files. The manifest sets `requiresAccessToken = true`. |
| ITI-x4 | After validation, the Manager returns a [result for `cohort-r4`](Parameters-bulk-r4-result.html) with a `resultPackage` attachment. The [R4 Bundle](Bundle-bulk-r4-result.html) contains the [output manifest](examples/bulk-fhir/output-manifest.json), file descriptors and Provenance. The response carries top-level `validationStatus = valid`. |
{: .grid}

The two file descriptors identify [output file 1](examples/bulk-fhir/output-patients-1.ndjson) and [output file 2](examples/bulk-fhir/output-patients-2.ndjson). The Provenance targets those descriptors by their Bundle entry URLs. The Requester extracts the manifest JSON from its carrier and retrieves the files using its authorized access.

For the failure variant, file 2 becomes unavailable after the Manager accepts the job. A worker may have already processed file 1. The next authorized ITI-x4 poll for the failed job returns HTTP 422 with an OperationOutcome, and neither file is released. See the [bulk file manifest rules](volume-3.html#3pxx3224-bulk-file-manifests-and-authorized-retrieval) and [ITI-x4](volume-2.html#23x4-retrieve-job-output-iti-x4).
