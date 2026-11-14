<a name="decoded-odrl"> </a>

### Decoded ODRL Agreement

This JSON-LD is the decoded Base64 content of `Contract.rule.contentAttachment.data` in this example.

```json
{
  "@context": "https://profiles.ihe.net/ITI/DIS/schemas/dis-odrl-v1.jsonld",
  "@type": "Agreement",
  "uid": "https://governance.example.org/permits/staged-async-permit/versions/1",
  "profile": "dis:DataRequestAuthorization",
  "dis:approvedRequest": {
    "@id": "https://governance.example.org/requests/staged-async-job/versions/1"
  },
  "permission": [
    {
      "uid": "https://governance.example.org/permits/staged-async-permit/versions/1#staged-patient-r4",
      "assigner": "https://governance.example.org/organizations/approval-authority",
      "assignee": "https://hospital.example.org/organizations/requester",
      "action": "dis:deIdentify",
      "target": "https://governance.example.org/scopes/staged-async-permit/staged-patient-r4/versions/1",
      "constraint": [
        {
          "leftOperand": "purpose",
          "operator": "eq",
          "rightOperand": {
            "@id": "https://governance.example.org/purposes/clinical-export"
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
          "rightOperand": "https://governance.example.org/policies/staged-patient|1.0"
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
            "@id": "https://hospital.example.org/organizations/requester"
          }
        }
      ]
    }
  ]
}
```
