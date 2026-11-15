These informative examples show the decoded JSON-LD attachments and their relationship to FHIR Contracts and evidence. See the [normative ODRL binding](odrl-content.html).

## UC-2 mixed-release examples

These JSON-LD examples show the decoded attachments for the [mixed-release exchange](examples-grouped-fhir-job.html#grouped-fhir-submission). The FHIR resources carry the same JSON-LD as Base64 in their attachment data fields. The policy and plan below follow the R4 clinical set.

<a name="decoded-authorization-example"> </a>

### Data Request Authorization Agreement Example

This Agreement is the decoded attachment in the [UC-2 Data Request Authorization Contract](Contract-grouped-fhir-authorization-contract.html). It includes both permissions selected by the [ITI-x1 de-identification job](Task-grouped-fhir-job-request.html). Both permissions classify the approved project to develop a healthcare algorithm under code `4.2` (health technology innovation).

```json
{
  "@context": "https://profiles.ihe.net/ITI/DIS/schemas/dis-odrl-v1.jsonld",
  "@type": "Agreement",
  "uid": "https://governance.example.org/permits/grouped-fhir-permit/versions/2",
  "profile": "dis:DataRequestAuthorization",
  "dis:approvedRequest": {
    "@id": "https://governance.example.org/requests/grouped-fhir-job-request/versions/1"
  },
  "permission": [
    {
      "uid": "https://governance.example.org/permits/grouped-fhir-permit/versions/2#patient-r4",
      "assigner": "https://governance.example.org/organizations/approval-authority",
      "assignee": "https://coordinator.example.org/organizations/requester",
      "action": "dis:deIdentify",
      "target": "https://governance.example.org/scopes/grouped-fhir-permit/patient-r4/versions/1",
      "constraint": [
        {
          "leftOperand": "purpose",
          "operator": "eq",
          "rightOperand": {
            "@id": "https://governance.example.org/purposes/multimodal-research"
          }
        },
        {
          "leftOperand": "dateTime",
          "operator": "gteq",
          "rightOperand": {
            "@value": "2026-01-01T00:00:00Z",
            "@type": "xsd:dateTime"
          }
        },
        {
          "leftOperand": "dateTime",
          "operator": "lt",
          "rightOperand": {
            "@value": "2028-01-01T00:00:00Z",
            "@type": "xsd:dateTime"
          }
        },
        {
          "leftOperand": "dis:approvedPolicy",
          "operator": "eq",
          "rightOperand": "https://governance.example.org/policies/patient-name-removal|1.0"
        },
        {
          "leftOperand": "dis:payloadBinding",
          "operator": "eq",
          "rightOperand": "DIS-FHIR-Payload"
        },
        {
          "leftOperand": "dis:payloadVersion",
          "operator": "eq",
          "rightOperand": "R4"
        },
        {
          "leftOperand": "recipient",
          "operator": "eq",
          "rightOperand": {
            "@id": "https://coordinator.example.org/organizations/requester"
          }
        }
      ],
      "dis:parentAliasRecipient": {
        "@id": "https://dis.example.org/organizations/example-worker"
      },
      "dis:purposeClassification": {
        "dis:classificationSystem": {
          "@id": "https://www.iso.org/standard/83447.html"
        },
        "dis:classificationVersion": "2024",
        "dis:classificationCode": [
          "4.2"
        ]
      }
    },
    {
      "uid": "https://governance.example.org/permits/grouped-fhir-permit/versions/2#imaging-report-r5",
      "assigner": "https://governance.example.org/organizations/approval-authority",
      "assignee": "https://coordinator.example.org/organizations/requester",
      "action": "dis:deIdentify",
      "target": "https://governance.example.org/scopes/grouped-fhir-permit/imaging-report-r5/versions/1",
      "constraint": [
        {
          "leftOperand": "purpose",
          "operator": "eq",
          "rightOperand": {
            "@id": "https://governance.example.org/purposes/multimodal-research"
          }
        },
        {
          "leftOperand": "dateTime",
          "operator": "gteq",
          "rightOperand": {
            "@value": "2026-01-01T00:00:00Z",
            "@type": "xsd:dateTime"
          }
        },
        {
          "leftOperand": "dateTime",
          "operator": "lt",
          "rightOperand": {
            "@value": "2028-01-01T00:00:00Z",
            "@type": "xsd:dateTime"
          }
        },
        {
          "leftOperand": "dis:approvedPolicy",
          "operator": "eq",
          "rightOperand": "https://governance.example.org/policies/imaging-report-subject-removal|1.0"
        },
        {
          "leftOperand": "dis:payloadBinding",
          "operator": "eq",
          "rightOperand": "DIS-FHIR-Payload"
        },
        {
          "leftOperand": "dis:payloadVersion",
          "operator": "eq",
          "rightOperand": "R5"
        },
        {
          "leftOperand": "recipient",
          "operator": "eq",
          "rightOperand": {
            "@id": "https://coordinator.example.org/organizations/requester"
          }
        }
      ],
      "dis:purposeClassification": {
        "dis:classificationSystem": {
          "@id": "https://www.iso.org/standard/83447.html"
        },
        "dis:classificationVersion": "2024",
        "dis:classificationCode": [
          "4.2"
        ]
      }
    }
  ]
}
```

<a name="decoded-policy-example"> </a>

### De-Identification Policy Set Example

This Set is the decoded attachment in the `grouped-fhir-policy-patient-r4` Policy Contract. The `patient-r4` permission approves version `1.0` of that Contract. The policy selects `@subject-names` for removal. The Manager expands the group to `Patient.name` for the R4 clinical set.

```json
{
  "@context": "https://profiles.ihe.net/ITI/DIS/schemas/dis-odrl-v1.jsonld",
  "@type": "Set",
  "uid": "https://governance.example.org/policies/patient-name-removal/versions/1.0",
  "profile": "dis:DeIdentificationPolicy",
  "dis:representationLevel": "semantic",
  "dis:reversibilityMode": "irreversible",
  "obligation": [
    {
      "uid": "https://governance.example.org/policies/patient-name-removal/versions/1.0#remove-01",
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
        "dis:ruleSetId": "remove-direct-link",
        "dis:ruleOrder": {
          "@list": [
            {
              "@id": "https://governance.example.org/policies/patient-name-removal/versions/1.0#remove-01"
            }
          ]
        }
      }
    ]
  }
}
```

<a name="decoded-plan-example"> </a>

### Execution Plan Set Example

This Set is the decoded attachment in the `grouped-fhir-plan-patient-r4` Execution Plan Contract referenced by the [ITI-x3 de-identification task](Task-grouped-fhir-task-patient-r4.html). It binds the selector to the assigned manifest and links the compiled obligation to the source policy rule.

```json
{
  "@context": "https://profiles.ihe.net/ITI/DIS/schemas/dis-odrl-v1.jsonld",
  "@type": "Set",
  "uid": "https://dis.example.org/fhir/plans/patient-r4/versions/1.0",
  "profile": "dis:ExecutionPlan",
  "dis:ruleSetId": "remove-direct-link",
  "dis:payloadBinding": "DIS-FHIR-Payload",
  "dis:payloadVersion": "R4",
  "dis:payloadSet": "patient-r4",
  "obligation": [
    {
      "uid": "https://dis.example.org/fhir/plans/patient-r4/versions/1.0#remove-01",
      "target": {
        "@type": "AssetCollection",
        "source": "https://source.example.org/fhir/r4/List/grouped-fhir-r4-input/_history/1",
        "refinement": {
          "leftOperand": "dis:fhirPath",
          "operator": "eq",
          "rightOperand": "Patient.name"
        }
      },
      "action": "dis:remove",
      "dis:sourceRule": {
        "@id": "https://governance.example.org/policies/patient-name-removal/versions/1.0#remove-01"
      }
    }
  ],
  "dis:ruleOrder": {
    "@list": [
      {
        "@id": "https://dis.example.org/fhir/plans/patient-r4/versions/1.0#remove-01"
      }
    ]
  }
}
```

<a name="hosted-input-digest-example"> </a>

### Hosted Input Digests Example

This Execution Plan Set fragment binds the manifest and two files in the [synthetic bulk input example](examples-bulk-fhir-cohort.html). Its obligation targets use the manifest URL as `source`.

```json
{
  "dis:inputDigests": [
    {
      "dis:inputUrl": {
        "@id": "https://source.example.org/bulk/input-manifest.json"
      },
      "dis:sha256": "28173d50a4cf5c753ed8be98700054824dd03c55ce1426a2baaffe99cf7ec315"
    },
    {
      "dis:inputUrl": {
        "@id": "https://source.example.org/bulk/input-patients-1.ndjson"
      },
      "dis:sha256": "1ee32345f27e8e7008ffdedcb7f7e802ecb2069ebe2cd6ff68fdbb2e70603df6"
    },
    {
      "dis:inputUrl": {
        "@id": "https://source.example.org/bulk/input-patients-2.ndjson"
      },
      "dis:sha256": "6d8de3efa2474b4e81609cad605556c5325f0869b2567cba9c49ff7a368c0fbf"
    }
  ]
}
```

<a name="dpv-odrl-worked-examples"> </a>

## DPV–ODRL worked policies and evidence

Both policies target the same synthetic R4 input scope. They cover structured names under the FHIR R4 mapping. The through-line uses two independent assignments, each granted to the same Requester and recipient for the same purpose. Each permission explicitly authorizes its own policy revision.

| Example | Authorization | Policy | Execution Plan | Expected result |
| --- | --- | --- | --- | --- |
| Remove every in-scope name | [Agreement A](examples/dpv-odrl/remove-all-agreement.json) | [Policy A](examples/dpv-odrl/remove-all-policy.json) | [Plan A](examples/dpv-odrl/remove-all-plan.json) | Remove every patient, contact, and practitioner name, including the care provider's name. |
| Keep care-provider names | [Agreement B](examples/dpv-odrl/keep-providers-agreement.json) | [Policy B](examples/dpv-odrl/keep-providers-policy.json) | [Plan B](examples/dpv-odrl/keep-providers-plan.json) | Keep the name on the Practitioner who is a member of the assigned care team. Remove the names on the Patient, their contact, and the other Practitioner. |
{: .grid}

The attachments are shown decoded. The [fixture and trace](examples/dpv-odrl/example-trace.json) show the assigned resource-list manifest, resources, approved scope, exact Contract references, and expected evidence linkage for both assignments. In the fixture, the patient and the care-provider Practitioner represent the same fictional person in two roles. Policy B preserves the name only on the Practitioner. The Manager checks the exact source policy reference in `Provenance.policy` when accepting the evidence.

[Test Plan cases](testplan.html#dpv-odrl-policy-cases) exercise these outcomes and the admission and compilation failures.
