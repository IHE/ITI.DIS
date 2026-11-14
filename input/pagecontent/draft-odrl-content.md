<div markdown="1" class="stu-note">
**Informative proposal for committee review.** [Issue #57](https://github.com/IHE/ITI.DIS/issues/57#issuecomment-6873972266) asks the committee to decide whether to use an ODRL Agreement for organizational data request authorization and, independently, whether to use ODRL Sets for reusable De-Identification Policies and compiled Execution Plans. The examples link these artifacts across ITI-x1 and ITI-x3. The ODRL syntax for the optional encryption action depends on the decision about policy and plan representation. [Issue #50](https://github.com/IHE/ITI.DIS/issues/50)
</div>

## Authorization language selection

DIS needs an exchangeable grant from an issuing organization to a Requester. The proposed Agreement identifies what the organization approved, the conditions for processing and disclosure, and the applicable policy revision. The approved scope may describe selection criteria for data that will be prepared later. [ODRL Agreement](https://www.w3.org/TR/odrl-model/#policy-agreement)

IHE APPC provides a patient privacy consent profile using XACML. IHE PCF uses FHIR R4 Consent and defines how to make patient privacy consents available for access decisions. A DIS profile of either option would need to specify how the issuer grants an organization authority to process a versioned data request, and how the grant binds the approved policy and result conditions. A direct profile of R4 Consent would also need to define those bindings. ODRL offers an explicit assigner, assignee, and permission model for the grant, with DIS-specific vocabulary and validation rules needed for interoperable processing. [APPC](https://www.ihe.net/uploadedFiles/Documents/ITI/IHE_ITI_Suppl_APPC.pdf) · [PCF](https://profiles.ihe.net/ITI/PCF/index.html) · [FHIR R4 Consent](https://hl7.org/fhir/R4/consent.html)

## 1. Shared content rules

Use [ODRL 2.2](https://www.w3.org/TR/odrl-model/) serialized as [JSON-LD](https://www.w3.org/TR/odrl-vocab/#json-ld). Each artifact SHALL declare its DIS profile IRI and a unique identifier for the exact issued or published revision. DIS SHALL publish a versioned JSON-LD context and vocabulary defining the profile IRIs, custom terms, and their permitted values and datatypes. Senders and receivers SHALL interpret reserved terms using that context. An actor SHALL reject content with an unsupported profile, unresolved required reference, or unsupported rule that affects its decision or execution.

The proposed content uses DIS action semantics and the R4 protocol binding. Exchanging an ODRL policy or plan attachment requires a versioned content binding. The profile SHALL distinguish the formats by media type and profile or format identifier. The committee still needs to decide how implementations declare support for each format and whether DIS should support both formats. [Current policy and plan formats](volume-3.html)

## 2. Data Request Authorization

The ITI-x1 de-identification job SHALL include one authorization reference to an exact revision of a profiled R4 `DocumentReference`. The document SHALL carry one authoritative ODRL Agreement in `DocumentReference.content.attachment` with media type `application/ld+json`. The document's version-specific identity SHALL bind to the Agreement's immutable revision. A historical document can establish what was issued. The Manager SHALL also establish whether that grant is currently effective.

| Agreement content | Proposed requirement |
| --- | --- |
| `uid` | Identify the exact Agreement revision. |
| `assigner`, `assignee` | Each permission identifies the issuing organization and authorized Requester. Validate that the authenticated caller represents the assignee or an authorized delegate. |
| `dis:approvedRequest` and `dis:sourcePermit` | Identify the approved request revision. Include the source permit or source decision when the Agreement is derived from it. |
| `permission` | Include one or more permissions, each with a unique `uid`, the `dis:deIdentify` action, and an explicit target. A permission grants the assignee authority to have the selected data de-identified for the specified purpose. |
| `target` | Identify the approved data scope, including the applicable data sources and selection criteria. A versioned scope definition can be referenced when its membership depends on source-side checks. |
| `constraint` | Specify purpose, the period during which the grant may be exercised, and exactly one `dis:approvedPolicy` value in FHIR `canonical\|version` form. Identify permitted result access and any destination restrictions applicable to the exchange. |

Each payload set SHALL identify the applicable permission by `uid`, supply the prepared manifest, and declare its selected policy canonical and version. The existing `setId` correlates the input, assigned de-identification tasks, and result. The permission identifier identifies the approved scope within the Agreement. The approved scope may precede extraction and may cover several prepared sets.

Before synchronous processing or asynchronous acceptance, the Manager SHALL validate the issuer, current approval status, caller authority, and applicability of the selected permission. For every set it SHALL verify manifest coverage and an exact match between the declared policy and the approved canonical and version. Where authorized source-side verification is used, the Manager SHALL verify trusted preparation evidence binding the exact Agreement revision, permission, and manifest, including the input versions it identifies. Reject the job if the Manager cannot establish coverage through the required checks or accepted evidence. Recheck authorization before making results available, including asynchronous retrieval. The issuer trust, status lookup, and preparation evidence bindings must be specified before this proposal becomes a conformance requirement.

## 3. De-Identification Policy

Carry the reusable ODRL `Set` in the existing R4 De-Identification Policy `Library`. Its `Library.url` and `Library.version` identify the exact approved rules. The Agreement binds to that pair. ITI-x1 continues to declare it per set and can reuse the current policy resolution and signed-content mechanisms once their profiles permit the ODRL attachment.

The Set SHALL contain one or more ODRL `obligation` rules. Every rule SHALL have a unique `uid`, a target selector, and one action from the applicable DIS action vocabulary. Represent the action's typed parameters as action refinements. The profile SHALL define their allowed operands, operators, datatypes, and cardinalities per action. For a selector, use a profile-defined `AssetCollection` refinement that identifies a semantic group or uses the selector language defined by the payload binding. The containing rule set identifies which representation is in use.

The policy SHALL define the rule-set order and, where present, stage order explicitly. A single rule set can be expressed by the top-level Set with one `dis:ruleSetId` and one `dis:ruleOrder`. The rule order is a JSON-LD `@list` of references to obligation identifiers. Each obligation SHALL occur exactly once in that list. For policies with multiple rule sets or stages, the binding will define ordered references to the identified rule sets and stages, preserving the current DIS stage and first-match semantics. Ordinary JSON array order on the ODRL `obligation` property has no execution significance. [DIS policy order and stages](volume-3.html#3pxx13-policy-rules-json-structure)

## 4. Execution Plan

The Manager SHALL compile the approved policy into an ODRL `Set` carried in the ITI-x3 R4 Execution Plan `Library`. The assigned payload set, binding, and payload version SHALL agree with the de-identification task. The plan SHALL contain concrete selectors, resolved parameters, and the explicit order of its compiled obligations. Each compiled obligation SHALL reference the corresponding source rule. Preserve the existing versioned source-policy identity in `Library.relatedArtifact` and its version-specific evidence URI.

For the FHIR binding, the De-Identifier SHALL evaluate selectors on the input resource before applying mutations, apply the first matching rule per element occurrence, and reject conflicting ancestor and descendant actions as specified in Volume 3. Unsupported actions, invalid parameters, or unresolved selectors SHALL cause rejection without a successful result. The DICOM payload binding would define the evaluation of grouped tag actions and IOD-dependent rules. [DIS Execution Plan evaluation](volume-3.html#3pxx212-execution-plan-json-structure-and-rule-evaluation)

## 5. Example from grant to execution

These decoded JSON-LD fragments illustrate the proposed properties. Profile and example IRIs are placeholders. The first permission approves a scope defined in the source system. A de-identification job can later select that permission and submit a manifest produced under the approved criteria.

```json
{
  "@context": [
    "http://www.w3.org/ns/odrl.jsonld",
    {"dis": "https://example.org/dis/odrl/v1#"}
  ],
  "@type": "Agreement",
  "uid": "https://example.org/approvals/research-42/versions/2",
  "profile": "dis:DataRequestAuthorization",
  "dis:approvedRequest": {"@id": "https://example.org/requests/research-42/versions/3"},
  "permission": [{
    "uid": "https://example.org/approvals/research-42/versions/2#patients",
    "assigner": "https://example.org/organizations/data-governance",
    "assignee": "https://example.org/organizations/data-holder",
    "action": "dis:deIdentify",
    "target": "https://example.org/approved-scopes/research-42/patients/versions/3",
    "constraint": [
      {"leftOperand": "purpose", "operator": "eq", "rightOperand": {"@id": "https://example.org/purposes/research-42"}},
      {"leftOperand": "dateTime", "operator": "gteq", "rightOperand": {"@value": "2026-11-01T00:00:00Z", "@type": "http://www.w3.org/2001/XMLSchema#dateTime"}},
      {"leftOperand": "dateTime", "operator": "lt", "rightOperand": {"@value": "2027-02-01T00:00:00Z", "@type": "http://www.w3.org/2001/XMLSchema#dateTime"}},
      {"leftOperand": "dis:approvedPolicy", "operator": "eq", "rightOperand": "https://example.org/fhir/Library/patient-research|1.0.0"},
      {"leftOperand": "recipient", "operator": "eq", "rightOperand": {"@id": "https://example.org/organizations/data-holder"}}
    ]
  }]
}
```

The referenced policy can be approved for other requests. Its rule selects the semantic group for birth date and specifies the approved precision. In this example, the Set represents one rule set.

```json
{
  "@context": [
    "http://www.w3.org/ns/odrl.jsonld",
    {"dis": "https://example.org/dis/odrl/v1#", "rdf": "http://www.w3.org/1999/02/22-rdf-syntax-ns#"}
  ],
  "@type": "Set",
  "uid": "https://example.org/policies/patient-research/versions/1.0.0",
  "profile": "dis:DeIdentificationPolicy",
  "dis:representationLevel": "semantic",
  "dis:reversibilityMode": "irreversible",
  "dis:ruleSetId": "birth-dates",
  "dis:ruleOrder": {"@list": [{"@id": "https://example.org/policies/patient-research/versions/1.0.0#birth-date"}]},
  "obligation": [{
    "uid": "https://example.org/policies/patient-research/versions/1.0.0#birth-date",
    "target": {
      "@type": "AssetCollection",
      "source": "https://example.org/dis/asset-collections/fhir-elements",
      "refinement": {"leftOperand": "dis:semanticGroup", "operator": "eq", "rightOperand": "@birth-dates"}
    },
    "action": {
      "rdf:value": {"@id": "dis:truncate-date"},
      "refinement": {"leftOperand": "dis:precision", "operator": "eq", "rightOperand": "year"}
    }
  }]
}
```

The compiled obligation binds the concrete selector to the elements in the assigned manifest. This example shows the decoded Set. The surrounding Execution Plan Library carries the exact source-policy canonical and version.

```json
{
  "@context": [
    "http://www.w3.org/ns/odrl.jsonld",
    {"dis": "https://example.org/dis/odrl/v1#", "rdf": "http://www.w3.org/1999/02/22-rdf-syntax-ns#"}
  ],
  "@type": "Set",
  "uid": "https://example.org/plans/job-104/task-1/versions/1",
  "profile": "dis:ExecutionPlan",
  "dis:ruleSetId": "birth-dates",
  "dis:payloadSet": "patients-r4",
  "dis:payloadBinding": "DIS-FHIR-Payload",
  "dis:payloadVersion": "R4",
  "dis:ruleOrder": {"@list": [{"@id": "https://example.org/plans/job-104/task-1/versions/1#birth-date"}]},
  "obligation": [{
    "uid": "https://example.org/plans/job-104/task-1/versions/1#birth-date",
    "dis:sourceRule": {"@id": "https://example.org/policies/patient-research/versions/1.0.0#birth-date"},
    "target": {
      "@type": "AssetCollection",
      "source": "https://example.org/manifests/job-104/task-1/versions/1",
      "refinement": {"leftOperand": "dis:fhirPath", "operator": "eq", "rightOperand": "Patient.birthDate"}
    },
    "action": {
      "rdf:value": {"@id": "dis:truncate-date"},
      "refinement": {"leftOperand": "dis:precision", "operator": "eq", "rightOperand": "year"}
    }
  }]
}
```

## 6. Optional encryption action

If the committee adopts the ODRL Set binding and the optional encryption method, define `dis:encrypt` as an action on a transformation obligation under DIS-REVERSIBLE. Use the same action IRI in policy and plan. Each action refinement uses `eq` and the datatype defined for its operand. [Informative encryption design](draft-encryption-based-pseudonymization.html)

| Action refinement | De-Identification Policy | Execution Plan |
| --- | --- | --- |
| `dis:encryptionMethod` | Required method code, such as `AES-FF1`. | Same approved method. |
| `dis:configurationVersion` | Required IRI identifying an immutable configuration revision. | Same configuration revision, pinned for the assignment. |
| `dis:resolvedLinkageScope` | The policy declares the authorized linkage scope using the existing DIS scope model. | Required IRI identifying the exact resolved scope. The binding must define its mapping to the DIS scope type and identifier. |
| `dis:pseudonymSystem` | Defined in the approved configuration. | Required IRI equal to the approved output namespace. |
| `dis:keyVersion` | Selected during plan compilation under the approved scope and deployment policy. | Required non-secret identifier for the provisioned key version. |

The following is an action fragment for a compiled obligation targeting an approved patient identifier. The same structure in the policy carries the method and configuration refinements. The configuration defines the identifier format and the method-specific tweak or associated-data rules. Key bytes and local key handles remain in the protected deployments.

```json
{
  "rdf:value": {"@id": "dis:encrypt"},
  "refinement": [
    {"leftOperand": "dis:encryptionMethod", "operator": "eq", "rightOperand": "AES-FF1"},
    {"leftOperand": "dis:configurationVersion", "operator": "eq", "rightOperand": {"@id": "https://example.org/configurations/ff1-decimal10/versions/1"}},
    {"leftOperand": "dis:resolvedLinkageScope", "operator": "eq", "rightOperand": {"@id": "https://example.org/linkage-scopes/research-42"}},
    {"leftOperand": "dis:pseudonymSystem", "operator": "eq", "rightOperand": {"@id": "https://example.org/pseudonyms/research-42/v1"}},
    {"leftOperand": "dis:keyVersion", "operator": "eq", "rightOperand": "research-42-ff1-v1"}
  ]
}
```

Before dispatch the Manager SHALL verify configuration compatibility and key-version availability for encryption and authorized reversal. A conflict with a supplied lookup table for the same identifiers SHALL prevent dispatch. For testing, use the existing informative FF1 vector and add an exchange case that verifies the compiled parameters, matching outputs from independent De-Identifiers, authorized reversal, and rejection when the selected key version is unavailable. [FF1 interoperability vector](draft-encryption-based-pseudonymization.html#ff1-interoperability-vector)

## 7. Review and conformance checks

| Exchange | Check |
| --- | --- |
| ITI-x1 admission | Two Managers accept the same valid Agreement, permission, policy revision, and prepared manifest. They reject an altered manifest, a different policy version, an unrecognized required condition, and an unauthorized caller. |
| ITI-x1 or ITI-x4 release | Revocation after asynchronous acceptance prevents release. |
| ITI-x3 dispatch | The plan resolves target selectors, preserves the required rule order and approved parameters, and identifies the exact source policy revision. |
| ITI-x3 execution | Equivalent DIS JSON and ODRL examples produce equivalent transformed outputs and failure behavior using the same execution semantics. |

After the committee dispositions, reconcile the Volume 1 concepts, Volume 2 message semantics, Volume 3 content bindings, FHIR profile constraints, examples, and Test Plan. Before publication, settle the profile and context IRIs, the scope vocabulary, the Agreement status and attestation bindings, the stage and rule-set term definitions, format support and negotiation, and the optional encryption capability declaration. The examples above are illustrative content for review.
