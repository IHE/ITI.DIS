<a name="decoded-odrl"> </a>

### Decoded ODRL De-Identification Policy Set

This JSON-LD is the decoded Base64 content of `Library.content.data` in this example.

```json
{
  "@context": "https://profiles.ihe.net/ITI/DIS/schemas/dis-odrl-v1.jsonld",
  "@type": "Set",
  "uid": "https://governance.example.org/policies/staged-patient/versions/1.0",
  "profile": "dis:DeIdentificationPolicy",
  "dis:representationLevel": "syntax",
  "dis:reversibilityMode": "irreversible",
  "dis:payloadFamily": "fhir",
  "dis:payloadVersion": "R4",
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
      "uid": "https://governance.example.org/policies/staged-patient/versions/1.0#hash-identifier",
      "target": {
        "@type": "AssetCollection",
        "source": "dis:fhir-elements",
        "refinement": {
          "leftOperand": "dis:fhirPath",
          "operator": "eq",
          "rightOperand": "Patient.identifier"
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
      "uid": "https://governance.example.org/policies/staged-patient/versions/1.0#remove-name",
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
    },
    {
      "uid": "https://governance.example.org/policies/staged-patient/versions/1.0#birth-year",
      "target": {
        "@type": "AssetCollection",
        "source": "dis:fhir-elements",
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
              "@id": "https://governance.example.org/policies/staged-patient/versions/1.0#hash-identifier"
            },
            {
              "@id": "https://governance.example.org/policies/staged-patient/versions/1.0#remove-name"
            }
          ]
        }
      },
      {
        "dis:ruleSetId": "generalize-birth-date",
        "dis:ruleOrder": {
          "@list": [
            {
              "@id": "https://governance.example.org/policies/staged-patient/versions/1.0#birth-year"
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
