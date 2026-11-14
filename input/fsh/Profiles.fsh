// DIS Profiles

Extension: DISTargetFhirVersion
Id: dis-target-fhir-version
Title: "DIS Target FHIR Release"
Description: "FHIR release to request and validate when resolving a direct DIS payload reference. DIS uses 5.0 for a hosted R5 resource."
* ^context[0].type = #element
* ^context[0].expression = "List.entry.item"
* ^context[1].type = #element
* ^context[1].expression = "Provenance.target"
* value[x] 1..1
* value[x] only code
* valueCode = #5.0 (exactly)

Invariant: dis-target-fhir-version-vread
Description: "A release-qualified target SHALL be an absolute HTTPS FHIR version-specific read URL."
Severity: #error
Expression: "extension.where(url = 'https://profiles.ihe.net/ITI/DIS/StructureDefinition/dis-target-fhir-version').empty() or (reference.exists() and reference.matches('^https://[^?#/]+(/[^?#]+)?/[A-Z][A-Za-z0-9]*/[A-Za-z0-9.-]{1,64}/_history/[A-Za-z0-9.-]{1,64}$'))"

// ── DIS-Evidence ─────────────────────────────────────────────────────────────

Profile: DISEvidence
Parent: Provenance
Id: DIS-Evidence
Title: "DIS Evidence"
Description: """
DIS de-identification evidence. A Provenance resource recording the outcome,
policy reference, ruleSet identifier, reversibility state, validation result,
and audit correlation for a completed de-identification task. An optional
transformation summary records the per-element actions applied.
"""
* ^url = "https://profiles.ihe.net/ITI/DIS/StructureDefinition/DIS-Evidence"
* ^status = #active
* ^experimental = false
* extension contains
    DisOutcomeStatusExt named outcomeStatus 1..1 and
    DisRulesetExt named ruleSet 1..1 and
    DisReversibilityExt named reversibility 1..1 and
    DisValidationStatusExt named validationStatus 1..1 and
    DisAuditCorrelationExt named auditCorrelation 1..1 and
    DisTransformationSummaryExt named transformationSummary 0..1
* id 1..1
* target 1..*
* target.extension contains DISTargetFhirVersion named targetFhirVersion 0..1
* target obeys dis-target-fhir-version-vread
* recorded 1..1
* policy 1..*
* activity 1..1
* agent 1..*
* obeys dis-evidence-one-performer

Invariant: dis-evidence-one-performer
Description: "Exactly one agent identifies the performer of the de-identification task."
Severity: #error
Expression: "agent.where(type.coding.where(system = 'http://terminology.hl7.org/CodeSystem/provenance-participant-type' and code = 'performer').exists()).count() = 1"


RuleSet: DISODRLContract
* id 1..1
* meta.versionId 1..1
* url 1..1
* version 1..1
* identifier 1..1
* identifier.system 1..1
* identifier.system = "urn:ietf:rfc:3986" (exactly)
* identifier.value 1..1
* identifier.value obeys dis-absolute-iri
* name 1..1
* issued 1..1
* rule 1..1
* rule.content[x] only Attachment
* rule.contentAttachment.contentType 1..1
* rule.contentAttachment.contentType = #"application/ld+json" (exactly)
* rule.contentAttachment.data 1..1
* rule.contentAttachment.url 0..0

Profile: DISPolicy
Parent: Contract
Id: DIS-Policy
Title: "DIS De-Identification Policy Contract"
Description: "Versioned Contract carrying a reusable ODRL Set of de-identification duties."
* insert DISODRLContract
* status 1..1
* authority 1..1
* authority only Reference(Organization)
* applies 1..1

Profile: DISExecutionPlan
Parent: Contract
Id: DIS-ExecutionPlan
Title: "DIS De-Identification Execution Plan Contract"
Description: "Task-specific Contract carrying a compiled ODRL Set derived from the approved policy."
* insert DISODRLContract
* authority 1..1
* authority only Reference(Organization)
* subject 1..1
* subject only Reference(Organization)
* supportingInfo 1..1
* supportingInfo only Reference(DISPolicy)
* supportingInfo.reference 1..1
* supportingInfo.reference obeys dis-versioned-contract-reference

Invariant: dis-versioned-contract-reference
Description: "Reference identifies one exact Contract revision on an HTTPS FHIR server."
Severity: #error
Expression: "$this.matches('^https://[^?# ]+/Contract/[A-Za-z0-9.-]{1,64}/_history/[A-Za-z0-9.-]{1,64}$')"

Invariant: dis-source-policy-version
Description: "The source policy identifier includes its URL and business version."
Severity: #error
Expression: "$this.matches('^[A-Za-z][A-Za-z0-9+.-]*:[^|]+[|][^|]+$')"

// ── Persistent, referenceable lookup table ──────────────────────────────────
Profile: DISLookupTable
Parent: DocumentReference
Id: DIS-LookupTable
Title: "DIS Lookup Table"
Description: "Identified metadata for a protected reversible mapping table. Requester-supplied tables carry inline JSON or reference a protected Binary. Task-generated tables carry inline JSON and are returned to the Manager for retention."
* ^url = "https://profiles.ihe.net/ITI/DIS/StructureDefinition/DIS-LookupTable"
* ^status = #active
* ^experimental = false
* masterIdentifier 1..1
* masterIdentifier.system 1..1
* masterIdentifier.value 1..1
* identifier 1..*
* identifier.system 1..1
* identifier.value 1..1
* status 1..1
* status ^comment = "Only current documents may be selected for new jobs; superseded and entered-in-error states remain available for repository lifecycle management."
* type 1..1
* type = https://profiles.ihe.net/ITI/DIS/CodeSystem/dis-document-type#lookup-table "DIS reversible lookup table"
* extension contains DisIdentityLinkageScopeExt named identityLinkageScope 1..1
* content 1..1
* content.attachment.contentType 1..1
* content.attachment.contentType = #"application/json"
* content.attachment obeys dis-lookup-content-choice
* content.attachment.url ^comment = "If present, resolves to a protected Binary conforming to DIS-LookupTableContent. Pin metadata and exact content bytes before processing."

Invariant: dis-lookup-content-choice
Description: "Lookup table content SHALL have exactly one of inline data or a Binary URL."
Severity: #error
Expression: "data.exists() xor url.exists()"

Profile: DISLookupTableContent
Parent: Binary
Id: DIS-LookupTableContent
Title: "DIS Lookup Table Content"
Description: "Protected JSON mapping content for a DIS Lookup Table DocumentReference. JSON conforms to the DIS lookup-table schema and semantic validation rules."
* ^url = "https://profiles.ihe.net/ITI/DIS/StructureDefinition/DIS-LookupTableContent"
* ^status = #active
* ^experimental = false
* contentType = #"application/json"
* data 1..1

// ── DIS Resource Manifest ────────────────────────────────────────────────────

Profile: DISResourceManifest
Parent: List
Id: DIS-ResourceManifest
Title: "DIS Resource Manifest"
Description: """
An explicit snapshot of references for one DIS payload set. A FHIR set lists
R4 payload resources, wrappers that carry or locate FHIR payload bytes, or release-qualified references to hosted R5 resources.
DICOM and CDA sets list R4 indexes or wrappers for the native objects. A manifest can enumerate inputs or results.
"""
* ^status = #active
* ^experimental = false
* meta 1..1
* meta.profile 1..*
* meta obeys dis-resource-manifest-profile
* status = #current
* mode = #snapshot
* entry 1..*
* entry.deleted = false
* entry.item.reference 1..1
* entry.item.extension contains DISTargetFhirVersion named targetFhirVersion 0..1
* entry.item obeys dis-resource-manifest-entry-reference and dis-target-fhir-version-vread

Invariant: dis-resource-manifest-profile
Description: "A DIS Resource Manifest SHALL declare its profile in meta.profile."
Severity: #error
Expression: "profile.where($this = 'https://profiles.ihe.net/ITI/DIS/StructureDefinition/DIS-ResourceManifest' or $this.startsWith('https://profiles.ihe.net/ITI/DIS/StructureDefinition/DIS-ResourceManifest|')).exists()"

Invariant: dis-resource-manifest-entry-reference
Description: "Each manifest item SHALL contain an absolute HTTPS reference or a bundle-local UUID reference."
Severity: #error
Expression: "reference.startsWith('https://') or reference.matches('^urn:uuid:[0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12}$')"

// ── Manifest package and cross-release wrapper ──────────────────────────────

Profile: DISManifestPackage
Parent: Bundle
Id: DIS-ManifestPackage
Title: "DIS Manifest Package"
Description: "FHIR R4 collection carrying one DIS Resource Manifest and any bundled payload resources, wrappers, or indexes needed to resolve that manifest."
* ^status = #draft
* type = #collection
* entry 1..*
* entry.fullUrl 1..1
* obeys dis-package-one-manifest

Invariant: dis-package-one-manifest
Description: "The package SHALL contain exactly one List declaring the DIS Resource Manifest profile."
Severity: #error
Expression: "entry.resource.ofType(List).where(meta.profile.where($this = 'https://profiles.ihe.net/ITI/DIS/StructureDefinition/DIS-ResourceManifest' or $this.startsWith('https://profiles.ihe.net/ITI/DIS/StructureDefinition/DIS-ResourceManifest|')).exists()).count() = 1"

Profile: DISPayloadWrapper
Parent: DocumentReference
Id: DIS-PayloadWrapper
Title: "DIS Payload Wrapper"
Description: "FHIR R4 carrier of one native payload object in an attachment. The set's binding and version govern the attachment content."
* ^status = #draft
* meta 1..1
* meta.profile 1..*
* meta obeys dis-payload-wrapper-profile
* status = #current
* content 1..1
* content.attachment.contentType 1..1
* content.attachment obeys dis-payload-attachment-source

Invariant: dis-payload-wrapper-profile
Description: "A DIS Payload Wrapper SHALL declare its profile in meta.profile."
Severity: #error
Expression: "profile.where($this = 'https://profiles.ihe.net/ITI/DIS/StructureDefinition/DIS-PayloadWrapper' or $this.startsWith('https://profiles.ihe.net/ITI/DIS/StructureDefinition/DIS-PayloadWrapper|')).exists()"

Invariant: dis-payload-attachment-source
Description: "The attachment SHALL contain exactly one of inline data or an absolute HTTPS URL."
Severity: #error
Expression: "(data.exists() xor url.exists()) and (url.empty() or url.startsWith('https://'))"

// ── Shared result package ───────────────────────────────────────────────────

Profile: DISResultPackage
Parent: Bundle
Id: DIS-ResultPackage
Title: "DIS Result Package"
Description: "FHIR R4 collection carrying the result manifest and evidence for one payload set."
* ^status = #draft
* type = #collection
* entry 2..*
* entry.fullUrl 1..1
* entry.resource 1..1
* obeys dis-result-entry-urls and dis-result-one-manifest and dis-result-evidence and dis-result-one-staged-release

Invariant: dis-result-entry-urls
Description: "Result package entry URLs SHALL be unique."
Severity: #error
Expression: "entry.fullUrl.isDistinct()"

Invariant: dis-result-one-manifest
Description: "A result package SHALL contain exactly one DIS Resource Manifest List or DIS Bulk Result Manifest DocumentReference."
Severity: #error
Expression: "entry.resource.where((ofType(List).exists() and meta.profile.where($this = 'https://profiles.ihe.net/ITI/DIS/StructureDefinition/DIS-ResourceManifest' or $this.startsWith('https://profiles.ihe.net/ITI/DIS/StructureDefinition/DIS-ResourceManifest|')).exists()) or (ofType(DocumentReference).exists() and meta.profile.where($this = 'https://profiles.ihe.net/ITI/DIS/StructureDefinition/DIS-BulkResultManifest' or $this.startsWith('https://profiles.ihe.net/ITI/DIS/StructureDefinition/DIS-BulkResultManifest|')).exists())).count() = 1"

Invariant: dis-result-evidence
Description: "A result package SHALL contain at least one DIS Evidence Provenance."
Severity: #error
Expression: "entry.resource.ofType(Provenance).where(meta.profile.where($this = 'https://profiles.ihe.net/ITI/DIS/StructureDefinition/DIS-Evidence' or $this.startsWith('https://profiles.ihe.net/ITI/DIS/StructureDefinition/DIS-Evidence|')).exists()).exists()"

Invariant: dis-result-one-staged-release
Description: "A result package contains at most one DIS Staged Release Evidence Provenance."
Severity: #error
Expression: "entry.resource.ofType(Provenance).where(meta.profile.where($this = 'https://profiles.ihe.net/ITI/DIS/StructureDefinition/DIS-StagedReleaseEvidence' or $this.startsWith('https://profiles.ihe.net/ITI/DIS/StructureDefinition/DIS-StagedReleaseEvidence|')).exists()).count() <= 1"

Profile: DISBulkResultManifest
Parent: DocumentReference
Id: DIS-BulkResultManifest
Title: "DIS Bulk Result Manifest"
Description: "Carrier for the JSON file listing in a bulk DIS Result Package."
* ^status = #draft
* status = #current
* content 1..1
* content.attachment.contentType 1..1
* content.attachment.contentType = #application/json
* content.attachment obeys dis-payload-attachment-source

Profile: DISBulkResultFile
Parent: DocumentReference
Id: DIS-BulkResultFile
Title: "DIS Bulk Result File"
Description: "Descriptor identifying one NDJSON file selected by the bulk manifest. DIS Evidence targets this descriptor."
* ^status = #draft
* status = #current
* content 1..1
* content.attachment.contentType 1..1
* content.attachment.contentType = #application/fhir+ndjson
* content.attachment.data 0..0
* content.attachment.url 1..1
* content.attachment obeys dis-payload-attachment-source

Profile: DISStagedReleaseEvidence
Parent: Provenance
Id: DIS-StagedReleaseEvidence
Title: "DIS Staged Release Evidence"
Description: "Manager-authored Provenance for the authorized release of the final output of a distributed payload set processed in multiple stages."
* ^status = #draft
* extension contains DisValidatedStageExt named validatedStage 2..*
* id 1..1
* target 1..*
* target.extension contains DISTargetFhirVersion named targetFhirVersion 0..1
* target obeys dis-target-fhir-version-vread
* target.reference 1..1
* recorded 1..1
* policy 1..1
* agent 1..1
* agent.type 1..1
* agent.type = http://terminology.hl7.org/CodeSystem/provenance-participant-type#author
* entity 0..0
* obeys dis-release-stage-count and dis-release-stage-sequence

Invariant: dis-release-stage-count
Description: "Staged release evidence identifies at least two distinct stages."
Severity: #error
Expression: "extension.where(url = 'https://profiles.ihe.net/ITI/DIS/StructureDefinition/dis-validated-stage').extension.where(url = 'stageId').value.distinct().count() >= 2"

Invariant: dis-release-stage-sequence
Description: "The sequence values are unique and consecutive from one."
Severity: #error
Expression: "extension.where(url = 'https://profiles.ihe.net/ITI/DIS/StructureDefinition/dis-validated-stage').extension.where(url = 'sequence').value.isDistinct() and extension.where(url = 'https://profiles.ihe.net/ITI/DIS/StructureDefinition/dis-validated-stage').extension.where(url = 'sequence').value.all($this <= %resource.extension.where(url = 'https://profiles.ihe.net/ITI/DIS/StructureDefinition/dis-validated-stage').count())"
