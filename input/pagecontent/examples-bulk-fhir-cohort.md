<div markdown="1" class="stu-note">
**Informative example.** The manifest and NDJSON files are synthetic fixtures. Example URLs represent authorized endpoints in the walkthrough.
</div>

An authorized Requester submits a two-Patient R4 cohort as an asynchronous job. The [input manifest](examples/bulk-fhir/input-manifest.json) lists two prepared files, [input file 1](examples/bulk-fhir/input-patients-1.ndjson) and [input file 2](examples/bulk-fhir/input-patients-2.ndjson). Each file contains one complete Patient. The approved irreversible policy removes `Patient.name`. This example assigns fresh opaque resource identities for the output and introduces no mapping for reversal.

| Exchange | What the message carries |
|----------|--------------------------|
| ITI-x1 | The authorization, one `payload` group with `setId = cohort-r4`, `payloadBinding = DIS-FHIR-Payload`, `payloadVersion = R4`, and the approved policy URL and version. Use `manifestFormat = fhir-bulk-data` and an `application/json` manifest attachment with the HTTPS input manifest URL. The Requester sends `Prefer: respond-async`. The Manager returns `202 Accepted` with the job polling URL. |
| ITI-x3 | The Manager dispatches that set with a concrete R4 execution plan and irreversible mode. The De-Identifier obtains credentials accepted by the manifest and file services and retrieves both files. The manifest sets `requiresAccessToken = true`. |
| ITI-x4 | After validation, the Manager returns one `payloadResult` for `cohort-r4`. The `fhir-bulk-data` attachment URL identifies the [output manifest](examples/bulk-fhir/output-manifest.json), which lists [output file 1](examples/bulk-fhir/output-patients-1.ndjson) and [output file 2](examples/bulk-fhir/output-patients-2.ndjson). R4 Provenance is returned in the result group's `evidence` part. The response carries top-level `validationStatus = valid`. |
{: .grid}

In this example the Provenance target identifiers use the output identifier system `https://results.example.org/identifiers/cohort-result` with values `result-01` and `result-02`. These match the output Patients in the files. The manifest, file URLs, and evidence identify only the released cohort. The Requester retrieves the files using its own authorized access.

For the failure variant, file 2 becomes unavailable after the Manager accepts the job. A worker may have already processed file 1. The next authorized ITI-x4 poll for the failed job returns HTTP 422 with an OperationOutcome, and neither file is released. See the [bulk file manifest rules](volume-3.html#3pxx3224-bulk-file-manifests-and-authorized-retrieval) and [ITI-x4](volume-2.html#23x4-retrieve-job-output-iti-x4).
