<div markdown="1" class="stu-note">
**Informative examples.** These decoded policies illustrate the [DIS policy rules JSON structure](volume-3.html#3pxx13-policy-rules-json-structure).
</div>

## Semantic-Level Reversible Clinical Pathology Policy

This decoded Semantic-Level policy illustrates reversible pseudonymization for Use Case 3 (Clinical Pathology Order). See the [compiled execution plan](volume-3.html#3pxx213-execution-plan-example) for the resolved scope and concrete targets.

```json
{
  "policyVersion": "1.0",
  "representationLevel": "semantic",
  "reversibilityMode": "reversible",
  "identity-linkage-scope": {
    "type": "source-institution",
    "identifier": {
      "system": "https://hospital.example.org/identifiers/linkage-scope",
      "value": "lab-project-2026"
    }
  },
  "ruleSets": [
    {
      "ruleSetId": "direct-identifiers",
      "rules": [
        {
          "ruleId": "P01",
          "target": "@subject-business-identifiers",
          "action": "hash",
          "parameters": {
            "mode": "salted",
            "algorithm": "SHA-256",
            "pseudonymSystem": "https://hospital.example.org/identifiers/pseudonym"
          }
        },
        {
          "ruleId": "P02",
          "target": "@subject-names",
          "action": "remove"
        }
      ]
    }
  ]
}
```

## Semantic-Level Staged Cohort Policy

This Semantic-Level policy illustrates staged irreversible pseudonymization for Use Case 1 (Cross-Border Epidemiological Study).

```json
{
  "policyVersion": "1.0",
  "representationLevel": "semantic",
  "reversibilityMode": "irreversible",
  "identity-linkage-scope": {
    "type": "cross-community",
    "identifier": {
      "system": "https://study.example/identifiers/linkage-scope",
      "value": "epi-study-2026-cohort-a"
    }
  },
  "ruleSets": [
    {
      "ruleSetId": "direct-identifiers",
      "description": "Irreversible hashing of direct identifiers",
      "rules": [
        {
          "ruleId": "P01",
          "target": "@subject-business-identifiers",
          "action": "hash",
          "parameters": {
            "mode": "salted",
            "algorithm": "SHA-256",
            "pseudonymSystem": "https://study.example/identifiers/pseudonym"
          }
        },
        {
          "ruleId": "P01N",
          "target": "@subject-names",
          "action": "remove"
        },
        {
          "ruleId": "P02",
          "target": "@contact-information",
          "action": "remove"
        },
        {
          "ruleId": "P03",
          "target": "@narrative",
          "action": "redact"
        },
        {
          "ruleId": "P04",
          "target": "@references",
          "action": "keep"
        }
      ]
    },
    {
      "ruleSetId": "quasi-identifiers",
      "description": "Record-level removal of quasi-identifiers",
      "rules": [
        {
          "ruleId": "A01",
          "target": "@dates",
          "action": "remove"
        },
        {
          "ruleId": "A02",
          "target": "@subject-demographics",
          "action": "remove"
        },
        {
          "ruleId": "A03",
          "target": "@provider-identifiers",
          "action": "remove"
        },
        {
          "ruleId": "A04",
          "target": "@device-identifiers",
          "action": "remove"
        },
        {
          "ruleId": "A05",
          "target": "@birth-dates",
          "action": "remove"
        }
      ]
    }
  ],
  "stages": [
    {
      "stageId": "preliminary",
      "description": "Direct identifier handling with trust isolation",
      "ruleSetRefs": [
        "direct-identifiers"
      ]
    },
    {
      "stageId": "advanced",
      "description": "Quasi-identifier truncation and removal",
      "ruleSetRefs": [
        "quasi-identifiers"
      ]
    }
  ]
}
```

## Syntax-Level Reversible Clinical Pathology Policy

This Syntax-Level policy illustrates the same Use Case 3 rules with concrete FHIR R4 targets.

```json
{
  "policyVersion": "1.0",
  "representationLevel": "syntax",
  "reversibilityMode": "reversible",
  "identity-linkage-scope": {
    "type": "source-institution",
    "identifier": {
      "system": "https://hospital.example.org/identifiers/linkage-scope",
      "value": "lab-project-2026"
    }
  },
  "payloadFamily": "fhir",
  "payloadVersion": "R4",
  "ruleSets": [
    {
      "ruleSetId": "direct-identifiers",
      "rules": [
        {
          "ruleId": "P01",
          "target": "Patient.identifier",
          "action": "hash",
          "parameters": {
            "mode": "salted",
            "algorithm": "SHA-256",
            "pseudonymSystem": "https://hospital.example.org/identifiers/pseudonym"
          }
        },
        {
          "ruleId": "P02",
          "target": "Patient.name",
          "action": "remove"
        }
      ]
    }
  ]
}
```

<div markdown="1" class="stu-note">
The date-shift derivation contract and the rules for combining concurrent ruleSet outputs remain open.
</div>
