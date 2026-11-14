<a name="decoded-odrl"> </a>

### Decoded ODRL De-Identification Policy Set

This JSON-LD is the decoded Base64 content of `Contract.rule.contentAttachment.data` in this example.

```json
{
  "@context": "https://profiles.ihe.net/ITI/DIS/schemas/dis-odrl-v1.jsonld",
  "@type": "Set",
  "uid": "https://export.example.org/fhir/Library/standalone-export-policy/versions/1.0",
  "profile": "dis:DeIdentificationPolicy",
  "dis:representationLevel": "syntax",
  "dis:reversibilityMode": "irreversible",
  "dis:payloadFamily": "fhir",
  "dis:payloadVersion": "R4",
  "obligation": [
    {
      "uid": "https://export.example.org/fhir/Library/standalone-export-policy/versions/1.0#remove-name",
      "target": {
        "@type": "AssetCollection",
        "source": "dis:fhir-elements",
        "refinement": {
          "leftOperand": "dis:fhirPath",
          "operator": "eq",
          "rightOperand": "Patient.name"
        }
      },
      "action": "dis:remove"
    }
  ],
  "dis:ruleSets": {
    "@list": [
      {
        "dis:ruleSetId": "local-name-removal",
        "dis:ruleOrder": {
          "@list": [
            {
              "@id": "https://export.example.org/fhir/Library/standalone-export-policy/versions/1.0#remove-name"
            }
          ]
        }
      }
    ]
  }
}
```
