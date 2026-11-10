# DIS Task request binding and synchronous example

**Status** — First drafting package for review. The field names, terminology and extension URL in the example are proposed. The example uses synthetic content and the input shape will be validated against the DIS Task profiles once those profiles are defined.

This draft applies the [complete Task work-order proposal](fhir-r4-task-work-orders.md) to ITI-x1 and ITI-x3. Each operation declares one required `workItem` input of type `Task`. The caller POSTs that Task directly. Successful operation outputs use R4 `Parameters`. [FHIR R4 operation requests and responses](https://hl7.org/fhir/R4/operations.html#request)

## Field mapping

| Field or constraint | De-identification job in ITI-x1 | De-identification task in ITI-x3 |
| --- | --- | --- |
| Work-order identity | Requester-assigned `Task.identifier` with a system and value | Manager-assigned `Task.identifier` with a system and value |
| Submitted state | Coded job type, `intent = order` and `status = requested` | Coded execution type, `intent = order` and `status = requested` |
| Authorization | One coded input with `valueReference` or `valueAttachment` | The Manager dispatches only the authorized set or subset and scoped inputs |
| Payload manifest and identity | One coded payload-set input per set. Its attachment carries the manifest. A required complex extension groups `setId`, `payloadBinding`, `payloadVersion` and `manifestFormat` | Exactly one coded payload-set input with the same metadata and an attachment selecting the assigned input |
| Approved policy and lookup | The payload-set extension carries the versioned policy canonical and can carry an authorized supplied lookup reference. For inline signed policy, define a local reference to a contained R4 `Binary` with `contentType = application/jose` and preserve its exact JWS bytes. | The versioned execution plan conveys the validated source policy identity and evidence URI. A separate coded input carries any protected, assignment-scoped lookup reference. |
| Execution instructions | The Manager validates the policy and prepares the plan | One coded input each for the execution plan reference, ruleSet ID, and reversibility mode. A stage ID input is required when the policy declares stages. |

Each `Task.input` has one typed value. For a payload-set input, the attachment carries the manifest and the extension associates the metadata with that particular attachment. The Task and its manifest package use R4. The set's declared payload version governs the selected clinical data. The Manager correlates the de-identification job with its de-identification tasks and may use `Task.partOf` where disclosure of the parent is authorized. [FHIR R4 Task inputs](https://hl7.org/fhir/R4/task-definitions.html#Task.input) · [DIS payload-set contract](../input/pagecontent/volume-2.md#grouped-payload-parameters)

**Identifier decision for review.** Scope the business identifier to the submitting actor and its declared namespace. Define what makes a retry equivalent, which authorized callers can recover an accepted order, and the response for an identifier reused with changed instructions. Keep the business identifier distinct from a resource ID and the async polling URL.

## Synchronous single-Patient exchange

Use the archived [synthetic R4 Patient manifest package](https://github.com/IHE/ITI.DIS/blob/4bd0d8bdd0ef86aa403a4ab91595fc619fec3e00/input/examples/Bundle-single-r4-patient-input.json) and [policy, plan and authorization fixtures](https://github.com/IHE/ITI.DIS/blob/4bd0d8bdd0ef86aa403a4ab91595fc619fec3e00/input/examples/Bundle-grouped-fhir-hosted-artifacts.json). The illustrative HTTPS endpoints in the Task attachments serve the same authorized manifest selection. The Manager can provide that selection through a scoped assignment endpoint. Assume the authorization covers the Patient and policy version. The policy removes the Patient's name in this synthetic example.

### 1. Requester submits the de-identification job

Send `POST [manager-base]/$submit-dis-job` with `Content-Type: application/fhir+json` and the following body. Synchronous processing is selected by omitting `Prefer: respond-async`. The Manager validates authorization, the exact approved policy and the selected payload set before dispatch.

```json
{
  "resourceType": "Task",
  "identifier": [
    {
      "system": "https://requester.example.org/dis/job-identifiers",
      "value": "job-001"
    }
  ],
  "intent": "order",
  "status": "requested",
  "code": {
    "coding": [
      {
        "system": "https://example.org/dis/work-order-type",
        "code": "de-identification-job"
      }
    ]
  },
  "input": [
    {
      "type": {
        "coding": [
          {
            "system": "https://example.org/dis/task-input",
            "code": "authorization"
          }
        ]
      },
      "valueReference": {
        "reference": "https://governance.example.org/fhir/DocumentReference/grouped-fhir-permit/_history/1"
      }
    },
    {
      "type": {
        "coding": [
          {
            "system": "https://example.org/dis/task-input",
            "code": "payload-set"
          }
        ]
      },
      "valueAttachment": {
        "contentType": "application/fhir+json",
        "url": "https://requester.example.org/dis/input/patient-r4"
      },
      "extension": [
        {
          "url": "https://example.org/dis/StructureDefinition/payload-set",
          "extension": [
            {
              "url": "setId",
              "valueString": "patient-r4"
            },
            {
              "url": "payloadBinding",
              "valueCode": "DIS-FHIR-Payload"
            },
            {
              "url": "payloadVersion",
              "valueCode": "R4"
            },
            {
              "url": "manifestFormat",
              "valueCode": "dis-resource-list"
            },
            {
              "url": "policy",
              "valueCanonical": "https://governance.example.org/policies/patient-name-removal|1.0"
            }
          ]
        }
      ]
    }
  ]
}
```

### 2. Manager submits the de-identification task

Send `POST [worker-base]/$submit-dis-task` with the following body using the same content type and synchronous selection. The assignment preserves `patient-r4`, its binding and version, and identifies the compiled plan and ruleSet for the De-Identifier.

```json
{
  "resourceType": "Task",
  "identifier": [
    {
      "system": "https://dis.example.org/dis/assignment-identifiers",
      "value": "assignment-001"
    }
  ],
  "intent": "order",
  "status": "requested",
  "code": {
    "coding": [
      {
        "system": "https://example.org/dis/work-order-type",
        "code": "de-identification-execution"
      }
    ]
  },
  "input": [
    {
      "type": {
        "coding": [
          {
            "system": "https://example.org/dis/task-input",
            "code": "payload-set"
          }
        ]
      },
      "valueAttachment": {
        "contentType": "application/fhir+json",
        "url": "https://dis.example.org/dis/assignments/patient-r4/input"
      },
      "extension": [
        {
          "url": "https://example.org/dis/StructureDefinition/payload-set",
          "extension": [
            {
              "url": "setId",
              "valueString": "patient-r4"
            },
            {
              "url": "payloadBinding",
              "valueCode": "DIS-FHIR-Payload"
            },
            {
              "url": "payloadVersion",
              "valueCode": "R4"
            },
            {
              "url": "manifestFormat",
              "valueCode": "dis-resource-list"
            }
          ]
        }
      ]
    },
    {
      "type": {
        "coding": [
          {
            "system": "https://example.org/dis/task-input",
            "code": "execution-plan"
          }
        ]
      },
      "valueReference": {
        "reference": "https://dis.example.org/fhir/Library/grouped-fhir-plan-patient-r4/_history/1"
      }
    },
    {
      "type": {
        "coding": [
          {
            "system": "https://example.org/dis/task-input",
            "code": "rule-set-id"
          }
        ]
      },
      "valueString": "remove-direct-link"
    },
    {
      "type": {
        "coding": [
          {
            "system": "https://example.org/dis/task-input",
            "code": "reversibility-mode"
          }
        ]
      },
      "valueCode": "irreversible"
    }
  ]
}
```

### 3. Responders deliver results

| Exchange | Expected response |
| --- | --- |
| De-Identifier → Manager | `200 OK` with the archived [ITI-x3 result Parameters](https://github.com/IHE/ITI.DIS/blob/4bd0d8bdd0ef86aa403a4ab91595fc619fec3e00/input/examples/Parameters-single-r4-patient-task-result.json). The result for `patient-r4` carries the selected output and evidence bound to the exact source policy from the execution plan. |
| Manager → Requester | `200 OK` with the archived [ITI-x1 result Parameters](https://github.com/IHE/ITI.DIS/blob/4bd0d8bdd0ef86aa403a4ab91595fc619fec3e00/input/examples/Parameters-single-r4-patient-job-result.json). The Manager validates the result, checks release authorization and returns the result package for `patient-r4`. |

Each response is delivered on its original HTTP call. If a completed Task is exposed to an authorized caller, its output can point to the same result package. For the rejection counterpart, use a policy version outside the authorization. The Manager returns an `OperationOutcome` before acceptance or dispatch and withholds the result. [Current DIS transaction examples](../input/pagecontent/volume-2.md#grouped-payload-parameters) · [DIS result and evidence packaging](../input/pagecontent/volume-3.md#result-evidence-placement)
