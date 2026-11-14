<div markdown="1" class="stu-note">
**Informative example.** All identifiers and mappings on this page are synthetic. In a deployment, the source identifiers, lookup tables, and effective salt are protected.
</div>

In [UC-3 Clinical Pathology Order](volume-1.html#1pxx423-use-case-3-clinical-pathology-order-pseudonymous-care), a hospital EHR submits a synchronous job to prepare a `Patient` and linked `ServiceRequest` for an external laboratory. The order's `ServiceRequest.subject` points to the input Patient. Both resources are selected by a List in an inline R4 manifest package. The synthetic patient business identifier is `https://hospital.example.org/identifiers/mrn|A123`.

## Approved Reversible Policy

The job submission declares the approved versioned canonical and the Manager resolves it from the hospital policy store. This decoded Semantic-Level policy governs the Manager-managed variant. The Manager resolves the scope and expands the rule targets when compiling the [execution plan Set](odrl-content.html#execution-plan-set).

```json
{
  "@context": "https://profiles.ihe.net/ITI/DIS/schemas/dis-odrl-v1.jsonld",
  "@type": "Set",
  "uid": "https://hospital.example.org/policies/pathology/versions/1",
  "profile": "dis:DeIdentificationPolicy",
  "dis:representationLevel": "semantic",
  "dis:reversibilityMode": "reversible",
  "dis:identity-linkage-scope": {
    "@type": "@json",
    "@value": {
      "type": "source-institution",
      "identifier": {
        "system": "https://hospital.example.org/identifiers/linkage-scope",
        "value": "lab-project-2026"
      }
    }
  },
  "obligation": [
    {
      "uid": "https://hospital.example.org/policies/pathology/versions/1#P01",
      "target": {
        "@type": "AssetCollection",
        "source": "dis:semantic-elements",
        "refinement": {
          "leftOperand": "dis:semanticGroup",
          "operator": "eq",
          "rightOperand": "@subject-business-identifiers"
        }
      },
      "action": {
        "rdf:value": {
          "@id": "dis:hash"
        },
        "refinement": [
          {
            "leftOperand": "dis:mode",
            "operator": "eq",
            "rightOperand": "salted"
          },
          {
            "leftOperand": "dis:algorithm",
            "operator": "eq",
            "rightOperand": "SHA-256"
          },
          {
            "leftOperand": "dis:pseudonymSystem",
            "operator": "eq",
            "rightOperand": {
              "@id": "https://hospital.example.org/identifiers/pseudonym"
            }
          }
        ]
      }
    },
    {
      "uid": "https://hospital.example.org/policies/pathology/versions/1#P02",
      "target": {
        "@type": "AssetCollection",
        "source": "dis:semantic-elements",
        "refinement": {
          "leftOperand": "dis:semanticGroup",
          "operator": "eq",
          "rightOperand": "@subject-names"
        }
      },
      "action": "dis:remove"
    }
  ],
  "dis:ruleSets": {
    "@list": [
      {
        "dis:ruleSetId": "direct-identifiers",
        "dis:ruleOrder": {
          "@list": [
            {
              "@id": "https://hospital.example.org/policies/pathology/versions/1#P01"
            },
            {
              "@id": "https://hospital.example.org/policies/pathology/versions/1#P02"
            }
          ]
        }
      }
    ]
  }
}
```

## Synchronous Exchange

The EHR submits the de-identification job through ITI-x1. The Manager verifies the authorization and approved policy, expands the semantic groups into concrete R4 selectors, and dispatches a de-identification task through ITI-x3. Both calls use synchronous processing. The worker assigns the pseudonym, removes `Patient.name`, and updates the order's `ServiceRequest.subject` to reference the pseudonymized Patient. The Manager validates that the link resolves in the result package before completing ITI-x1.

| Step | Requester-supplied mapping | Manager-managed mapping |
|------|---------------------------|-------------------------|
| ITI-x1 | The set’s `lookupTable` subextension identifies the versioned [source table](DocumentReference-pathology-supplied-lookup.html). The approved policy selects lookup-backed `replace` on `Patient.identifier`. | The approved policy selects salted `hash` on `Patient.identifier`. See the [compiled pathology plan](volume-3.html#3pxx213-execution-plan-example). |
| ITI-x3 | The Manager pins the source table and grants the worker access to a [task-scoped subset](DocumentReference-pathology-task-lookup.html) containing only `A123`. The rule uses `parameters.source = lookupTable`. | The Manager dispatches the plan and authorized linkage scope. The worker uses its deployment-managed effective salt to compute the assigned pseudonym. |
| ITI-x3 response | The worker returns the Patient with identifier `https://hospital.example.org/identifiers/pseudonym|lab-supplied-0042` and Provenance. The supplied mapping remains in the source repository. | The worker returns the [pseudonymized Patient](Patient-pseudonym-abc123.html) and [Provenance](Provenance-dis-evidence-uc3-001.html), plus a protected [generated lookup table](DocumentReference-generated-lookup-uc3.html) for the Manager to validate and retain. |
| ITI-x1 response | The Requester receives one `payloadResult` with the submitted set ID, a result manifest, and evidence. | The Requester receives one `payloadResult` with the submitted set ID, a result manifest, and evidence. The Manager holds the mapping separately. |
{: .grid}

In the supplied-table variant, a missing mapping for `A123` fails the task. The Manager returns an OperationOutcome to the Requester and withholds the job output. The task does not substitute a generated pseudonym. See the [lookup table binding](volume-3.html#3pxx5-reversible-lookup-table) and [ITI-x3](volume-2.html#23x3-submit-de-identification-task-iti-x3).

The EHR sends the pseudonymized order to the laboratory. When a result returns, the EHR uses authorized pseudonym resolution to associate it with the patient chart. The lab exchange and resolution are outside DIS.
