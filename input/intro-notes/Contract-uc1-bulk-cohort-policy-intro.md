<a name="decoded-odrl"> </a>

### Decoded ODRL De-Identification Policy Set

This JSON-LD is the decoded Base64 content of `Contract.rule.contentAttachment.data` in this example.

```json
{
  "@context": "https://profiles.ihe.net/ITI/DIS/schemas/dis-dpv-odrl-draft-1.jsonld",
  "@type": "Set",
  "uid": "https://governance.example.org/policies/uc1-bulk-cohort/versions/1.0",
  "profile": "disdpv:Policy",
  "dis:reversibilityMode": "irreversible",
  "dis:identity-linkage-scope": {
    "@type": "@json",
    "@value": {
      "type": "cross-community",
      "identifier": {
        "system": "https://study.example.org/identifiers/linkage-scope",
        "value": "epi-cohort-2026"
      }
    }
  },
  "obligation": [
    {
      "uid": "https://governance.example.org/policies/uc1-bulk-cohort/versions/1.0#hash-identifier",
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
              "@id": "https://study.example.org/identifiers/pseudonym"
            }
          }
        ]
      }
    },
    {
      "uid": "https://governance.example.org/policies/uc1-bulk-cohort/versions/1.0#remove-name",
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
    },
    {
      "uid": "https://governance.example.org/policies/uc1-bulk-cohort/versions/1.0#birth-year",
      "target": {
        "@type": "AssetCollection",
        "source": "disdpv:personal-information",
        "refinement": [
          {
            "leftOperand": "disdpv:category",
            "operator": "eq",
            "rightOperand": {
              "@id": "pd:BirthDate"
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
          "@id": "dis:truncate-date"
        },
        "refinement": [
          {
            "leftOperand": "dis:precision",
            "operator": "eq",
            "rightOperand": "year"
          }
        ]
      }
    }
  ],
  "dis:ruleSets": {
    "@list": [
      {
        "dis:ruleSetId": "pseudonymize-patient",
        "dis:ruleOrder": {
          "@list": [
            {
              "@id": "https://governance.example.org/policies/uc1-bulk-cohort/versions/1.0#hash-identifier"
            },
            {
              "@id": "https://governance.example.org/policies/uc1-bulk-cohort/versions/1.0#remove-name"
            }
          ]
        }
      },
      {
        "dis:ruleSetId": "generalize-birth-date",
        "dis:ruleOrder": {
          "@list": [
            {
              "@id": "https://governance.example.org/policies/uc1-bulk-cohort/versions/1.0#birth-year"
            }
          ]
        }
      }
    ]
  },
  "dis:stages": {
    "@list": [
      {
        "dis:stageId": "preliminary",
        "dis:ruleSetRefs": {
          "@list": [
            "pseudonymize-patient"
          ]
        }
      },
      {
        "dis:stageId": "advanced",
        "dis:ruleSetRefs": {
          "@list": [
            "generalize-birth-date"
          ]
        }
      }
    ]
  }
}
```
