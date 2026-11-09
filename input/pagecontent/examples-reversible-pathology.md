<div markdown="1" class="stu-note">
**Informative example.** All identifiers and mappings on this page are synthetic. In a deployment, the source identifiers, lookup tables, and effective salt are protected.
</div>

The Requester submits a pathology order for one patient. This example isolates the Patient resource from the order to show how DIS replaces the patient business identifier. The approved policy has a source-institution linkage scope with identifier `https://hospital.example.org/identifiers/linkage-scope|lab-project-2026`. The source pair is `https://hospital.example.org/identifiers/mrn|A123`. Both variants remove `Patient.name` and use reversible mode. See [Clinical Pathology Order](volume-1.html#1pxx423-use-case-3-clinical-pathology-order-pseudonymous-care).

## Synchronous Job with an Asynchronous Task

The Requester sends a synchronous ITI-x1 submission with the authorized data scope, the canonical URL and version of the approved policy, and one Job Task payload-set input whose manifest selects the R4 Patient. The Manager validates the approval, linkage scope, and policy before dispatching ITI-x3 with `Prefer: respond-async`. The De-Identifier returns `202 Accepted` and a task polling URL in `Content-Location`. The Manager polls that URL using ITI-x7. An in-progress response has no task output. When the task completes, the Manager validates the returned output and evidence before completing ITI-x1.

| Step | Requester-supplied mapping | Manager-managed mapping |
|------|---------------------------|-------------------------|
| ITI-x1 | The set’s `lookupTable` subextension identifies the versioned [source table](DocumentReference-pathology-supplied-lookup.html). The approved policy selects lookup-backed `replace` on `Patient.identifier`. | The approved policy selects salted `hash` on `Patient.identifier`. See the [compiled pathology plan](volume-3.html#3pxx213-execution-plan-example). |
| ITI-x3 | The Manager pins the source table and grants the worker access to a [task-scoped subset](DocumentReference-pathology-task-lookup.html) containing only `A123`. The rule uses `parameters.source = lookupTable`. | The Manager dispatches the plan and authorized linkage scope. The worker uses its deployment-managed effective salt to compute the assigned pseudonym. |
| ITI-x7 | The worker returns the Patient with identifier `https://hospital.example.org/identifiers/pseudonym|lab-supplied-0042` and Provenance. The supplied mapping remains in the source repository. | The worker returns the [pseudonymized Patient](Patient-pseudonym-abc123.html) and [Provenance](Provenance-dis-evidence-uc3-001.html), plus a protected [generated lookup table](DocumentReference-generated-lookup-uc3.html) for the Manager to validate and retain. |
| ITI-x1 response | The Requester receives one `payloadResult` with the submitted set ID, a result manifest, and evidence. | The Requester receives one `payloadResult` with the submitted set ID, a result manifest, and evidence. The Manager holds the mapping separately. |
{: .grid}

In the supplied-table variant, a missing mapping for `A123` fails the task. The Manager returns an OperationOutcome to the Requester and withholds the job output. The task does not substitute a generated pseudonym. See the [lookup table binding](volume-3.html#3pxx5-reversible-lookup-table) and [ITI-x7](volume-2.html#23x7-retrieve-task-output-iti-x7).
