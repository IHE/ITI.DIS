### Readable JSON-LD attachments

This Bundle carries an [ODRL Agreement](odrl-content.html#decoded-authorization-example) for both sets. The guide shows the decoded [R4 policy](odrl-content.html#decoded-policy-example) and [R4 execution plan](odrl-content.html#decoded-plan-example). The R5 attachments are shown below.

<a name="decoded-r5-policy"> </a>

### R5 ODRL De-Identification Policy Set

This JSON-LD is the decoded `Library.content.data` of `grouped-fhir-policy-imaging-report-r5`.

```json
{
  "@context": "https://profiles.ihe.net/ITI/DIS/schemas/dis-odrl-v1.jsonld",
  "@type": "Set",
  "uid": "https://governance.example.org/policies/imaging-report-subject-removal/versions/1.0",
  "profile": "dis:DeIdentificationPolicy",
  "dis:representationLevel": "syntax",
  "dis:reversibilityMode": "irreversible",
  "dis:payloadFamily": "fhir",
  "dis:payloadVersion": "R5",
  "obligation": [
    {
      "uid": "https://governance.example.org/policies/imaging-report-subject-removal/versions/1.0#remove-01",
      "target": {
        "@type": "AssetCollection",
        "source": "dis:fhir-elements",
        "refinement": {
          "leftOperand": "dis:fhirPath",
          "operator": "eq",
          "rightOperand": "DiagnosticReport.subject"
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
              "@id": "https://governance.example.org/policies/imaging-report-subject-removal/versions/1.0#remove-01"
            }
          ]
        }
      }
    ]
  }
}
```

<a name="decoded-r5-plan"> </a>

### R5 ODRL Execution Plan Set

This JSON-LD is the decoded `Library.content.data` of `grouped-fhir-plan-imaging-report-r5`.

```json
{
  "@context": "https://profiles.ihe.net/ITI/DIS/schemas/dis-odrl-v1.jsonld",
  "@type": "Set",
  "uid": "https://dis.example.org/fhir/plans/imaging-report-r5/versions/1.0",
  "profile": "dis:ExecutionPlan",
  "dis:ruleSetId": "remove-direct-link",
  "dis:payloadBinding": "DIS-FHIR-Payload",
  "dis:payloadVersion": "R5",
  "dis:payloadSet": "imaging-report-r5",
  "obligation": [
    {
      "uid": "https://dis.example.org/fhir/plans/imaging-report-r5/versions/1.0#remove-01",
      "target": {
        "@type": "AssetCollection",
        "source": "https://source.example.org/fhir/r4/List/grouped-fhir-r5-input-list/_history/1",
        "refinement": {
          "leftOperand": "dis:fhirPath",
          "operator": "eq",
          "rightOperand": "DiagnosticReport.subject"
        }
      },
      "action": "dis:remove",
      "dis:sourceRule": {
        "@id": "https://governance.example.org/policies/imaging-report-subject-removal/versions/1.0#remove-01"
      }
    }
  ],
  "dis:ruleOrder": {
    "@list": [
      {
        "@id": "https://dis.example.org/fhir/plans/imaging-report-r5/versions/1.0#remove-01"
      }
    ]
  }
}
```
