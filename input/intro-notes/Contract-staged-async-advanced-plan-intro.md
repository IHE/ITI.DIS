<a name="decoded-odrl"> </a>

### Decoded ODRL Execution Plan Set

This JSON-LD is the decoded Base64 content of `Contract.rule.contentAttachment.data` in this example.

```json
{
  "@context": "https://profiles.ihe.net/ITI/DIS/schemas/dis-dpv-odrl-draft-1.jsonld",
  "@type": "Set",
  "uid": "https://dis.example.org/plans/staged-async-advanced-plan/versions/1.0",
  "profile": "disdpv:ExecutionPlan",
  "dis:ruleSetId": "generalize-birth-date",
  "dis:payloadBinding": "DIS-FHIR-Payload",
  "dis:payloadVersion": "R4",
  "dis:payloadSet": "staged-patient-r4",
  "dis:stageId": "advanced",
  "obligation": [
    {
      "uid": "https://dis.example.org/plans/staged-async-advanced-plan/versions/1.0#birth-year",
      "target": {
        "@type": "AssetCollection",
        "source": "ni:///sha-256;wlqk8TimK8jRiH6jNJM20cK7EZwglJnlPGfC2ydOkLw",
        "refinement": {
          "leftOperand": "dis:fhirPath",
          "operator": "eq",
          "rightOperand": "Patient.birthDate"
        }
      },
      "action": {
        "rdf:value": {
          "@id": "dis:truncate-date"
        },
        "refinement": [
          {
            "leftOperand": "dis:precision",
            "operator": "eq",
            "rightOperand": "year"
          }
        ]
      },
      "dis:sourceRule": {
        "@id": "https://governance.example.org/policies/staged-patient/versions/1.0#birth-year"
      }
    }
  ],
  "dis:ruleOrder": {
    "@list": [
      {
        "@id": "https://dis.example.org/plans/staged-async-advanced-plan/versions/1.0#birth-year"
      }
    ]
  },
  "disdpv:mappingRevision": {
    "@id": "https://profiles.ihe.net/ITI/DIS/bindings/dis-fhir-r4-dpv-mapping-3.jsonld"
  }
}
```
