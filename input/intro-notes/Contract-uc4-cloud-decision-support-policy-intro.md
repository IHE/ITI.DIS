<a name="decoded-odrl"> </a>

### Decoded ODRL De-Identification Policy Set

This JSON-LD is the decoded Base64 content of `Contract.rule.contentAttachment.data` in this example.

```json
{
  "@context": "https://profiles.ihe.net/ITI/DIS/schemas/dis-dpv-odrl-draft-1.jsonld",
  "@type": "Set",
  "uid": "https://governance.example.org/policies/uc4-cloud-decision-support/versions/1.0",
  "profile": "disdpv:Policy",
  "dis:reversibilityMode": "reversible",
  "dis:identity-linkage-scope": {
    "@type": "@json",
    "@value": {
      "type": "source-institution",
      "identifier": {
        "system": "https://hospital.example.org/identifiers/linkage-scope",
        "value": "cloud-cds-2026"
      }
    }
  },
  "obligation": [
    {
      "uid": "https://governance.example.org/policies/uc4-cloud-decision-support/versions/1.0#hash-identifier",
      "target": {
        "@type": "AssetCollection",
        "source": "disdpv:personal-information",
        "refinement": [
          {
            "leftOperand": "disdpv:category",
            "operator": "eq",
            "rightOperand": {
              "@id": "pd:Identifier"
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
              "@id": "https://hospital.example.org/identifiers/cds-pseudonym"
            }
          }
        ]
      }
    },
    {
      "uid": "https://governance.example.org/policies/uc4-cloud-decision-support/versions/1.0#remove-name",
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
        "dis:ruleSetId": "pseudonymize-patient",
        "dis:ruleOrder": {
          "@list": [
            {
              "@id": "https://governance.example.org/policies/uc4-cloud-decision-support/versions/1.0#hash-identifier"
            },
            {
              "@id": "https://governance.example.org/policies/uc4-cloud-decision-support/versions/1.0#remove-name"
            }
          ]
        }
      }
    ]
  }
}
```
