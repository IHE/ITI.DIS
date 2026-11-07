<div markdown="1" class="stu-note">
**Informative example.** This synthetic example demonstrates the wire contract. Its policy removes one field and does not assess suitability for release of real patient data.
</div>

A Requester submits one inline R4 Patient using a single payload set. The set's manifest attachment contains a serialized [R4 collection package](Bundle-single-r4-patient-input.html). A List in that package selects the Patient by a bundle-local reference. The example uses the policy, plan, permit and hosted result artifacts illustrated in the [fixture collection](Bundle-grouped-fhir-hosted-artifacts.html). Assume the job authorization covers this Patient and the approved policy version.

| Step | Message | What to verify |
|---|---|---|
| 1 | POST `[manager-base]/$submit-dis-job` with the [ITI-x1 Parameters body](Parameters-single-r4-patient-job-request.html). Use `Content-Type: application/fhir+json` and omit `Prefer: respond-async`. | The request contains one authorization and one `payload` with `setId = patient-r4`. The Manager validates authorization and policy before dispatch. |
| 2 | POST `[worker-base]/$submit-dis-task` with the [ITI-x3 Parameters body](Parameters-single-r4-patient-task-request.html). Use the same content type and omit `Prefer: respond-async`. | The task preserves the set ID, binding, version, and selected Patient. It carries the compiled plan reference and irreversible mode. |
| 3 | The worker returns HTTP 200 with the [ITI-x3 result](Parameters-single-r4-patient-task-result.html). | One `payloadResult` selects the hosted output Patient, whose name has been removed. The evidence targets that Patient. The top-level `validationStatus` is `valid`. |
| 4 | The Manager returns HTTP 200 with the [ITI-x1 result](Parameters-single-r4-patient-job-result.html). | The result preserves `patient-r4` and its evidence. The Manager has checked the result and authorized retrieval from the result service. |
{: .grid}

The [fully inline ITI-x1 result alternative](Parameters-single-r4-patient-inline-result.html) carries a [manifest package](Bundle-single-r4-patient-inline-output.html) whose List selects the native R4 Patient. The same Bundle contains the Provenance, which targets the selected Patient by its entry URL. The result omits the outer evidence part.

See the [transaction matrix](volume-2.html#grouped-payload-parameters) and [manifest resolution rules](volume-3.html#resource-manifest-resolution).
