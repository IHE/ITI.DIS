<a name="decoded-odrl"> </a>

### Decoded ODRL Execution Plan Set

This JSON-LD is the decoded Base64 content of `Library.content.data` in this example.

```json
{
  "@context": "https://profiles.ihe.net/ITI/DIS/schemas/dis-odrl-v1.jsonld",
  "@type": "Set",
  "uid": "https://dis.example.org/plans/staged-async-preliminary-plan/versions/1.0",
  "profile": "dis:ExecutionPlan",
  "dis:ruleSetId": "pseudonymize-patient",
  "dis:payloadBinding": "DIS-FHIR-Payload",
  "dis:payloadVersion": "R4",
  "dis:payloadSet": "staged-patient-r4",
  "dis:stageId": "preliminary",
  "obligation": [
    {
      "uid": "https://dis.example.org/plans/staged-async-preliminary-plan/versions/1.0#hash-identifier",
      "target": {
        "@type": "AssetCollection",
        "source": "https://dis.example.org/manifests/staged-async-preliminary-task",
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
          },
          {
            "leftOperand": "dis:identity-linkage-scope",
            "operator": "eq",
            "rightOperand": {
              "@type": "@json",
              "@value": {
                "type": "source-institution",
                "identifier": {
                  "system": "https://hospital.example.org/identifiers/linkage-scope",
                  "value": "lab-project-2026"
                }
              }
            }
          }
        ]
      },
      "dis:sourceRule": {
        "@id": "https://governance.example.org/policies/staged-patient/versions/1.0#hash-identifier"
      }
    },
    {
      "uid": "https://dis.example.org/plans/staged-async-preliminary-plan/versions/1.0#remove-name",
      "target": {
        "@type": "AssetCollection",
        "source": "https://dis.example.org/manifests/staged-async-preliminary-task",
        "refinement": {
          "leftOperand": "dis:fhirPath",
          "operator": "eq",
          "rightOperand": "Patient.name"
        }
      },
      "action": "dis:remove",
      "dis:sourceRule": {
        "@id": "https://governance.example.org/policies/staged-patient/versions/1.0#remove-name"
      }
    }
  ],
  "dis:ruleOrder": {
    "@list": [
      {
        "@id": "https://dis.example.org/plans/staged-async-preliminary-plan/versions/1.0#hash-identifier"
      },
      {
        "@id": "https://dis.example.org/plans/staged-async-preliminary-plan/versions/1.0#remove-name"
      }
    ]
  }
}
```
