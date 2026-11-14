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

## DIS ODRL vocabulary

The [DIS ODRL vocabulary, version 1 (RDF Turtle)](schemas/dis-odrl-v1.ttl) declares the DIS profile identifiers, actions, operands, properties, and selector collection sources. The JSON-LD context expands the compact IRIs. The requirements below define permitted term use, cardinalities, and value forms. See the [W3C ODRL profile mechanism](https://www.w3.org/TR/odrl-model/#profile-mechanism).

| Profile | Allowed DIS actions | Profile-specific terms and usage |
| --- | --- | --- |
| Data Request Authorization | `dis:deIdentify` in a permission | Use the Agreement properties and constraint operands defined in [Agreement for organizational data request authorization](#odrl-authorization). |
| De-Identification Policy | `dis:remove`, `dis:replace`, `dis:keep`, `dis:hash`, `dis:truncate-date`, `dis:date-shift`, `dis:round`, `dis:truncate`, and `dis:redact` in obligations. A reversible policy may use `dis:encrypt` when the AES-FF1 capability applies. | Use policy representation, rule sets, and optional stages. Use `dis:semanticGroup` for Semantic-Level selectors or the binding's concrete selector for Syntax-Level selectors. |
| Execution Plan | The same nine core actions and optional `dis:encrypt` in obligations | Use concrete selectors, the assigned payload set, the explicit compiled rule order, and `dis:sourceRule`. A compiled salted hash rule uses the resolved linkage scope. |
{: .grid}

The action and procedure definitions in [Volume 3](volume-3.html#transformation-actions) apply to both Sets. Vocabulary declarations describe terms and their relationships. Receivers use the exact action IRIs allowed by the declared DIS profile when validating an exchange.

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

### Purpose classification

A permission MAY include one `dis:purposeClassification` object to classify the purpose in its required `purpose` constraint. The issuer selects the applicable headings or categories from [ISO/TS 14265:2024, Clause 6, Table 1](https://www.iso.org/standard/83447.html). A permission without this object is valid.

| Property | Value form |
| --- | --- |
| `dis:classificationSystem` | One IRI reference in `{"@id":"..."}` form. Use `https://www.iso.org/standard/83447.html` as the DIS identifier for the ISO publication. |
| `dis:classificationVersion` | One string equal to `2024`. |
| `dis:classificationCode` | A nonempty array of distinct, case-sensitive code strings from the table below. Array order has no significance. |

| ISO heading | Accepted codes, including the heading code |
| --- | --- |
| Person centred care | `1.0`, `1.1`, `1.2`, `1.3`, `1.4`, `1.5`, `1.6` |
| Health service management and quality assurance | `2.0`, `2.1`, `2.2`, `2.3`, `2.4`, `2.5`, `2.6` |
| Population and public health | `3.0`, `3.1`, `3.2`, `3.3`, `3.4`, `3.5`, `3.6` |
| Clinical research | `4.0`, `4.1`, `4.2`, `4.3`, `D4` |
| Education and training | `5.0`, `5.1`, `5.2` |
| Compliance with legal obligations | `6.0`, `6.1`, `6.2` |
| Not stated | `7.0`, `7.1`, `7.2` |

`D4` is the code printed for health systems evaluations in the 2024 table. Use the codes exactly as listed, including the trailing zero in a heading code.

The De-ID Manager SHALL validate the object when present. The object SHALL contain exactly the three properties listed above. An unsupported system or edition, an unknown code, a numeric value, a duplicate code, or an empty code array makes the Agreement invalid. The classification describes the issuer's approved purpose. The Manager SHALL still evaluate the `purpose` constraint by matching the job's purpose IRI to the selected permission's approved purpose IRI. A shared classification, including any `7.x` code, SHALL NOT satisfy that match, widen the grant, or substitute for the approved purpose IRI. No lookup of the ISO publication is needed to process the Agreement.

## Sets for policy and plan

Both Sets carry `obligation` as a nonempty array of ODRL Duty rules. Each obligation has a unique absolute IRI `uid`, exactly one `target` and one `action`. An obligation SHALL NOT carry its own assigner or assignee. The eligible role performs each obligation. The Manager compiles the Policy obligations, and the De-Identifier or Integrated actor applies the compiled Plan obligations to its assigned inputs.

The target SHALL be an ODRL `AssetCollection` with exactly one `source` IRI and one `refinement` using `eq`. For a Semantic-Level Policy, use the IRI `dis:semantic-elements` and `dis:semanticGroup` with the semantic-group string including its `@` prefix. For a Syntax-Level Policy, use `dis:fhir-elements` and `dis:fhirPath` for FHIR, with the concrete path as a string. For a plan, use an assignment-specific manifest IRI as the source and the same concrete selector operand for the binding. Every obligation in a plan SHALL use the same source IRI for the manifest in the de-identification task. For inline manifests the Manager SHALL mint an assignment-specific absolute IRI and use it consistently across all targets in the plan. For referenced manifests it SHALL use the assigned manifest URL. The De-Identifier SHALL apply rule selectors only to the manifest supplied with the de-identification task.

### Action parameters

In the RDF vocabulary, `dis:actionParameter` links each action to its available refinement operands. The links identify parameters allowed in the policy, the execution plan, or both. This property is vocabulary metadata only. In JSON-LD action expressions, send parameter values using `refinement` and apply the profile-specific requirements below.

The action SHALL be one of the [DIS transformation action IRIs](volume-3.html#transformation-actions). For `remove`, `keep`, or `redact`, encode `action` as the action IRI string. For the other actions, `action` SHALL be an object with one `rdf:value` IRI reference such as `{"@id":"dis:truncate-date"}` and a nonempty `refinement` array. Use one refinement per supplied parameter. Each refinement SHALL contain exactly one `leftOperand` from the table, the operator `eq`, and the listed `rightOperand` value form. The order of action refinements has no significance. Receivers SHALL reject duplicate operands, missing required parameters, extraneous parameters, and invalid operators, types, or values.

| Action | Policy rule parameters | Compiled plan rule parameters |
| --- | --- | --- |
| `remove`, `keep`, `redact` | None. | None. |
| `replace` | Exactly one of `dis:value` (nonempty string) or `dis:source` (the string `lookupTable`). The lookup mode requires a reversible policy and its authorized linkage scope. | Same selection. In lookup mode, ITI-x3 carries the assigned lookup table reference in the `lookup-table` input. |
| `hash` | `dis:mode` (string `salted` or `unsalted`) and `dis:algorithm` (string `SHA-256`). Supply `dis:pseudonymSystem` as an IRI reference for `Identifier` targets. Patient business identifiers require `salted`. Salted hashing requires a policy-level linkage scope. | Preserve the approved parameters. For `salted`, include the compiled `dis:identity-linkage-scope` refinement. For `unsalted`, omit that refinement. |
| `truncate-date` | `dis:precision` (string `year` or `year-month`). | Same parameter. |
| `date-shift` | `dis:maxOffsetDays` (nonnegative JSON integer) and optional `dis:scope` (nonblank consistency scope string). A policy-level linkage scope is required if the rule omits `dis:scope`. | Preserve `dis:maxOffsetDays` and any explicit `dis:scope`. If the rule omits `dis:scope`, the Manager SHALL ensure the applicable date-shift capability binds the assignment to the resolved policy linkage scope. Apply the [date-shift capability rules](volume-3.html#date-shift). |
| `round` | `dis:step` (positive JSON number). | Same parameter. |
| `truncate` | `dis:length` (positive JSON integer). | Same parameter. |
| `encrypt` | Reversible mode only. Require `dis:encryptionMethod` (string `AES-FF1`) and `dis:configurationVersion` (IRI reference to the immutable approved configuration). The Set SHALL declare the authorized linkage scope. | Preserve the two policy parameters and require `dis:identity-linkage-scope` (resolved scope), `dis:pseudonymSystem` (IRI reference equal to the configured output system), and `dis:keyVersion` (nonblank string identifying the provisioned key version). See the [AES-FF1 binding](draft-encryption-based-pseudonymization.html). |
{: .grid}

For a `dis:pseudonymSystem` value use `{"@id":"..."}` with an absolute IRI. For linkage scope use a JSON-LD JSON literal of the form `{"@type":"@json","@value":{"type":"...","identifier":{"system":"...","value":"..."}}}`. Use one of the [DIS linkage scope codes](volume-3.html#3pxx13-policy-rules-json-structure), an absolute IRI for `system`, and a nonblank string for `value`. A policy scope with type `job` SHALL omit `identifier`. A policy scope with another type and every compiled salted hash or encryption scope SHALL include it. Keep salts, encryption keys, local key handles, date-shift seeds, and actual offsets in the protected mechanisms defined by the applicable capability.

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

This Agreement is the decoded attachment in the [UC-2 Data Request Authorization Contract](Contract-grouped-fhir-authorization-contract.html). It includes both permissions selected by the [ITI-x1 de-identification job](Task-grouped-fhir-job-request.html). Both permissions classify the approved project to develop a healthcare algorithm under code `4.2` (health technology innovation).

```json
{
  "@context": "https://profiles.ihe.net/ITI/DIS/schemas/dis-odrl-v1.jsonld",
  "@type": "Agreement",
  "uid": "https://governance.example.org/permits/grouped-fhir-permit/versions/2",
  "profile": "dis:DataRequestAuthorization",
  "dis:approvedRequest": {
    "@id": "https://governance.example.org/requests/grouped-fhir-job-request/versions/1"
  },
  "permission": [
    {
      "uid": "https://governance.example.org/permits/grouped-fhir-permit/versions/2#patient-r4",
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
      },
      "dis:purposeClassification": {
        "dis:classificationSystem": {
          "@id": "https://www.iso.org/standard/83447.html"
        },
        "dis:classificationVersion": "2024",
        "dis:classificationCode": [
          "4.2"
        ]
      }
    },
    {
      "uid": "https://governance.example.org/permits/grouped-fhir-permit/versions/2#imaging-report-r5",
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
      ],
      "dis:purposeClassification": {
        "dis:classificationSystem": {
          "@id": "https://www.iso.org/standard/83447.html"
        },
        "dis:classificationVersion": "2024",
        "dis:classificationCode": [
          "4.2"
        ]
      }
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
