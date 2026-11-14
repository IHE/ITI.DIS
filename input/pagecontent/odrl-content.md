## Common JSON-LD requirements

This section defines the DIS profile of [ODRL 2.2](https://www.w3.org/TR/odrl-model/) and its [JSON-LD representation](https://www.w3.org/TR/odrl-vocab/#json-ld) for the data request authorization, policy and plan. The carriers and transaction requirements are defined in [Volume 3](volume-3.html).

The decoded attachment SHALL be one UTF-8 JSON object. It SHALL use the [DIS version 1 context](schemas/dis-odrl-v1.jsonld) as its sole `@context`, and one `profile` and `@type` from the table. The context defines `dis:` as `https://profiles.ihe.net/ITI/DIS/odrl/v1#` and includes the W3C ODRL context. Receivers SHALL resolve the two known contexts using their published definitions and SHALL reject additional or overridden contexts. Receivers may use local copies.

| Artifact | `@type` | `profile` |
| --- | --- | --- |
| Data Request Authorization | `Agreement` | `dis:DataRequestAuthorization` |
| De-Identification Policy | `Set` | `dis:DeIdentificationPolicy` |
| Execution Plan | `Set` | `dis:ExecutionPlan` |
{: .grid}

Use the compact terms and value forms defined here. An artifact or rule `uid` SHALL be an absolute IRI and unique within its artifact. Unless a compact value is explicitly prescribed, IRI fields carry an absolute IRI without a compact prefix. A policy or plan's `uid` SHALL identify one immutable attachment revision and be bound to the carrier's `Library.url` and `Library.version`. Unless marked optional, listed properties are required. Arrays specified as nonempty SHALL contain at least one entry. A receiver SHALL reject duplicate JSON members, unknown properties or terms, unsupported values or conditions, unresolved required references, and inconsistent identifiers. Policy inheritance, ODRL conflict strategies, prohibitions, permission duties, and obligation consequences are outside this profile. Version 1 uses no alternate wire encoding for the three artifacts.

<a name="odrl-authorization"> </a>

## Agreement for organizational data request authorization

The Agreement contains an immutable `uid`, a `dis:approvedRequest` identifying the exact approved request revision as an `{"@id": "..."}` reference, and an optional `dis:sourcePermit` IRI reference when derived from a separate approval. It SHALL contain a nonempty `permission` array. Each permission has its own `uid`, one `assigner` IRI identifying the issuing organization, one `assignee` IRI identifying the authorized Requester organization, the action `dis:deIdentify`, and a `target` IRI identifying an immutable approved scope. All permissions SHALL name the same assigner and assignee.

| `leftOperand` | Operator | `rightOperand` and evaluation |
| --- | --- | --- |
| `purpose` | `eq` | One IRI reference identifying the approved purpose. |
| `dateTime` | `gteq` and `lt` | Exactly one of each operator with an `xsd:dateTime` value in UTC. Start is inclusive and end is exclusive. Start SHALL precede end. |
| `dis:approvedPolicy` | `eq` | One string in `Library.url\|Library.version` form. |
| `dis:payloadBinding`, `dis:payloadVersion` | `eq` | One string for each operand, matching the applicable DIS payload binding and release. |
| `recipient` | `eq` | One IRI reference identifying the organization entitled to receive results. |
| `dis:resultDestination` | `eq` | Optional. One IRI reference identifying an authorized HTTPS service base. Every referenced result endpoint and redirect SHALL remain within that service boundary. |
{: .grid}

A permission SHALL carry the conditions above in a `constraint` array and all conditions SHALL hold. An IRI reference in a right operand uses the explicit `{"@id": "..."}` form. The scope identified by the target defines eligible data sources and selection criteria or identifies exact eligible resources or files and versions. The scope can precede extraction. The Manager SHALL verify the scope and its binding to the grant under the [admission and release rules](volume-3.html#data-request-authorization). An optional `dis:parentAliasRecipient` IRI reference on a permission identifies a worker organization authorized to receive the alias for that set. Absence of the property grants no such disclosure.

## Sets for policy and plan

Both Sets carry `obligation` as a nonempty array of ODRL Duty rules. Each obligation has a unique absolute IRI `uid`, exactly one `target` and one `action`. An obligation SHALL NOT carry its own assigner or assignee. The eligible role performs each obligation. The Manager compiles the Policy obligations, and the De-Identifier or Integrated actor applies the compiled Plan obligations to its assigned inputs.

The target SHALL be an ODRL `AssetCollection` with exactly one `source` IRI and one `refinement` using `eq`. For a Semantic-Level Policy, use the IRI `dis:semantic-elements` and `dis:semanticGroup` with the semantic-group string including its `@` prefix. For a Syntax-Level Policy, use `dis:fhir-elements` and `dis:fhirPath` for FHIR, with the concrete path as a string. For a plan, use an assignment-specific manifest IRI as the source and the same concrete selector operand for the binding. Every obligation in a plan SHALL use the same source IRI for the manifest in the de-identification task. For inline manifests the Manager SHALL mint an assignment-specific absolute IRI and use it consistently across all targets in the plan. For referenced manifests it SHALL use the assigned manifest URL. The De-Identifier SHALL apply rule selectors only to the manifest supplied with the de-identification task.

The action SHALL be a `dis:` action IRI for an action code listed in [Volume 3](volume-3.html#transformation-actions). For an action with parameters, use an object containing `rdf:value` as an IRI reference to the action and a nonempty `refinement` array. Each refinement has a `dis:` left operand named for the parameter, the operator `eq`, and the right operand from the parameter table. Encode actions without parameters as the action IRI string. Reject duplicates, extraneous parameters and actions outside the declared binding. Action applicability and parameter dependencies in Volume 3 also apply.

| Action | Parameters and JSON value form |
| --- | --- |
| `remove`, `keep`, `redact` | No parameters. |
| `replace` | Exactly one of `dis:value` (nonempty string) or `dis:source` (string `lookupTable`). |
| `hash` | `dis:mode` (string `salted` or `unsalted`) and `dis:algorithm` (string `SHA-256`). `dis:pseudonymSystem` is an IRI reference and is required for `Identifier` targets. A compiled salted rule SHALL also carry `dis:identity-linkage-scope` as the JSON literal described below. Omit that refinement in the policy and in an unsalted plan rule. |
| `truncate-date` | `dis:precision` (string `year` or `year-month`). |
| `date-shift` | `dis:maxOffsetDays` (nonnegative integer) and optional `dis:scope` (nonempty consistency scope string). |
| `round` | `dis:step` (positive JSON number). |
| `truncate` | `dis:length` (positive integer). |
{: .grid}

A linkage scope is a JSON-LD JSON literal of the form `{"@type":"@json","@value":{"type":"...","identifier":{"system":"...","value":"..."}}}`. Its type uses the DIS linkage scope code, and the identifier uses the exact authorized scope system and value. Omit the identifier only for an unresolved policy scope of type `job`. No secret material is carried in these refinements.

### De-Identification Policy Set

The policy carries `dis:representationLevel` (`semantic` or `syntax`), `dis:reversibilityMode` (`irreversible` or `reversible`) and the `obligation` array. Syntax-Level content SHALL also declare `dis:payloadFamily` (`fhir` for DIS-FHIR-Payload) and `dis:payloadVersion` (`R4` or `R5` for FHIR). Semantic-Level content SHALL omit those two fields. `dis:identity-linkage-scope` carries the policy linkage scope when required by the selected actions.

`dis:ruleSets` is an explicit `{"@list":[...]}` with one entry per rule set in processing order. Each entry carries a unique `dis:ruleSetId` string, optional `dis:description` string and a nonempty `dis:ruleOrder` list of `{"@id":"..."}` references to the Set's obligations in first-match order. Every obligation SHALL occur in exactly one list, exactly once. No processing order is inferred from the `obligation` array.

Optional `dis:stages` is an explicit nonempty `@list` in dispatch order. Each entry has a unique `dis:stageId` string, optional `dis:description` string, and a nonempty `dis:ruleSetRefs` list of rule-set ID strings. Each defined rule set SHALL be referenced exactly once across the stages. When stages are present, the stage lists determine the effective rule-set execution order. Apply [Volume 3 compilation](volume-3.html#3pxx15-policy-compilation) and stage processing requirements.

### Execution Plan Set

The plan carries `dis:ruleSetId`, `dis:payloadSet`, `dis:payloadBinding` and `dis:payloadVersion` as strings equal to the corresponding task inputs. It also carries `dis:stageId` as a string exactly when the task has a stage ID. The root `dis:ruleOrder` is a nonempty explicit `@list` of IRI references to the compiled obligations. Each obligation SHALL be listed exactly once and SHALL carry a `dis:sourceRule` IRI reference to the original policy obligation. A source obligation can produce several compiled obligations, for example when a semantic group expands to several paths. The Manager SHALL preserve original order and the binding's expansion order. The De-Identifier SHALL validate the Set, and apply the [execution rules in Volume 3](volume-3.html#3pxx212-execution-plan-json-structure-and-rule-evaluation).

## Examples (Informative)

These JSON-LD examples show the decoded attachments for the [mixed-release exchange](examples-grouped-fhir-job.html#grouped-fhir-submission). The FHIR resources carry the same JSON-LD as Base64 in their attachment data fields. The policy and plan below follow the R4 clinical set.

<a name="decoded-authorization-example"> </a>

### Data Request Authorization Agreement Example

This Agreement is the decoded attachment in the `grouped-fhir-permit` DocumentReference in the [hosted artifact collection](Bundle-grouped-fhir-hosted-artifacts.html). It includes both permissions selected by the [ITI-x1 de-identification job](Task-grouped-fhir-job-request.html).

```json
{
  "@context": "https://profiles.ihe.net/ITI/DIS/schemas/dis-odrl-v1.jsonld",
  "@type": "Agreement",
  "uid": "https://governance.example.org/permits/grouped-fhir-permit/versions/1",
  "profile": "dis:DataRequestAuthorization",
  "dis:approvedRequest": {
    "@id": "https://governance.example.org/requests/grouped-fhir-job-request/versions/1"
  },
  "permission": [
    {
      "uid": "https://governance.example.org/permits/grouped-fhir-permit/versions/1#patient-r4",
      "assigner": "https://governance.example.org/organizations/approval-authority",
      "assignee": "https://coordinator.example.org/organizations/requester",
      "action": "dis:deIdentify",
      "target": "https://governance.example.org/scopes/grouped-fhir-permit/patient-r4/versions/1",
      "constraint": [
        {
          "leftOperand": "purpose",
          "operator": "eq",
          "rightOperand": {
            "@id": "https://governance.example.org/purposes/multimodal-research"
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
          "rightOperand": "https://governance.example.org/policies/patient-name-removal|1.0"
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
            "@id": "https://coordinator.example.org/organizations/requester"
          }
        }
      ],
      "dis:parentAliasRecipient": {
        "@id": "https://dis.example.org/organizations/example-worker"
      }
    },
    {
      "uid": "https://governance.example.org/permits/grouped-fhir-permit/versions/1#imaging-report-r5",
      "assigner": "https://governance.example.org/organizations/approval-authority",
      "assignee": "https://coordinator.example.org/organizations/requester",
      "action": "dis:deIdentify",
      "target": "https://governance.example.org/scopes/grouped-fhir-permit/imaging-report-r5/versions/1",
      "constraint": [
        {
          "leftOperand": "purpose",
          "operator": "eq",
          "rightOperand": {
            "@id": "https://governance.example.org/purposes/multimodal-research"
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
          "rightOperand": "https://governance.example.org/policies/imaging-report-subject-removal|1.0"
        },
        {
          "leftOperand": "dis:payloadBinding",
          "operator": "eq",
          "rightOperand": "DIS-FHIR-Payload"
        },
        {
          "leftOperand": "dis:payloadVersion",
          "operator": "eq",
          "rightOperand": "R5"
        },
        {
          "leftOperand": "recipient",
          "operator": "eq",
          "rightOperand": {
            "@id": "https://coordinator.example.org/organizations/requester"
          }
        }
      ]
    }
  ]
}
```

<a name="decoded-policy-example"> </a>

### De-Identification Policy Set Example

This Set is the decoded attachment in the `grouped-fhir-policy-patient-r4` Policy Library. The `patient-r4` permission approves version `1.0` of that Library. The policy selects `Patient.name` for removal.

```json
{
  "@context": "https://profiles.ihe.net/ITI/DIS/schemas/dis-odrl-v1.jsonld",
  "@type": "Set",
  "uid": "https://governance.example.org/policies/patient-name-removal/versions/1.0",
  "profile": "dis:DeIdentificationPolicy",
  "dis:representationLevel": "syntax",
  "dis:reversibilityMode": "irreversible",
  "dis:payloadFamily": "fhir",
  "dis:payloadVersion": "R4",
  "obligation": [
    {
      "uid": "https://governance.example.org/policies/patient-name-removal/versions/1.0#remove-01",
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
        "dis:ruleSetId": "remove-direct-link",
        "dis:ruleOrder": {
          "@list": [
            {
              "@id": "https://governance.example.org/policies/patient-name-removal/versions/1.0#remove-01"
            }
          ]
        }
      }
    ]
  }
}
```

<a name="decoded-plan-example"> </a>

### Execution Plan Set Example

This Set is the decoded attachment in the `grouped-fhir-plan-patient-r4` Execution Plan Library referenced by the [ITI-x3 de-identification task](Task-grouped-fhir-task-patient-r4.html). It binds the selector to the assigned manifest and links the compiled obligation to the source policy rule.

```json
{
  "@context": "https://profiles.ihe.net/ITI/DIS/schemas/dis-odrl-v1.jsonld",
  "@type": "Set",
  "uid": "https://dis.example.org/fhir/plans/patient-r4/versions/1.0",
  "profile": "dis:ExecutionPlan",
  "dis:ruleSetId": "remove-direct-link",
  "dis:payloadBinding": "DIS-FHIR-Payload",
  "dis:payloadVersion": "R4",
  "dis:payloadSet": "patient-r4",
  "obligation": [
    {
      "uid": "https://dis.example.org/fhir/plans/patient-r4/versions/1.0#remove-01",
      "target": {
        "@type": "AssetCollection",
        "source": "https://source.example.org/fhir/r4/List/grouped-fhir-r4-input/_history/1",
        "refinement": {
          "leftOperand": "dis:fhirPath",
          "operator": "eq",
          "rightOperand": "Patient.name"
        }
      },
      "action": "dis:remove",
      "dis:sourceRule": {
        "@id": "https://governance.example.org/policies/patient-name-removal/versions/1.0#remove-01"
      }
    }
  ],
  "dis:ruleOrder": {
    "@list": [
      {
        "@id": "https://dis.example.org/fhir/plans/patient-r4/versions/1.0#remove-01"
      }
    ]
  }
}
```
