<a name="decoded-odrl"> </a>

### Decoded ODRL De-Identification Policy Set

This JSON-LD is the decoded Base64 content of `Contract.rule.contentAttachment.data` in this example.

```json
{
  "@context": "https://profiles.ihe.net/ITI/DIS/schemas/dis-dpv-odrl-draft-1.jsonld",
  "@type": "Set",
  "uid": "https://export.example.org/fhir/Contract/standalone-export-policy/versions/1.0",
  "profile": "disdpv:Policy",
  "dis:reversibilityMode": "irreversible",
  "obligation": [
    {
      "uid": "https://export.example.org/fhir/Contract/standalone-export-policy/versions/1.0#remove-name",
      "target": {
        "@type": "AssetCollection",
        "source": "disdpv:personal-information",
        "refinement": [
          {
            "leftOperand": "disdpv:category",
            "operator": "eq",
            "rightOperand": {
              "@id": "pd:Name"
            }
          },
          {
            "leftOperand": "disdpv:personRole",
            "operator": "eq",
            "rightOperand": {
              "@id": "disdpv:patient"
            }
          },
          {
            "leftOperand": "disdpv:location",
            "operator": "eq",
            "rightOperand": {
              "@id": "disdpv:structured"
            }
          }
        ]
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
              "@id": "https://export.example.org/fhir/Contract/standalone-export-policy/versions/1.0#remove-name"
            }
          ]
        }
      }
    ]
  }
}
```
