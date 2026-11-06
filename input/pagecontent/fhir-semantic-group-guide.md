This informative guide accompanies the [R4/R5 PII path catalog CSV](bindings/dis-fhir-pii-path-catalog-0.2.0.csv). The [Volume 3 binding table](volume-3.html#3pxx122-semantic-groups) defines the authoritative selectors for DIS semantic-level policies. The catalog helps authors identify candidate paths for syntax-level policies.

The companion CSV contains 8,489 unique declaration and value-type rows. It covers all 146 concrete FHIR R4 (4.0.1) resource types and all 158 concrete FHIR R5 (5.0.0) resource types, their base types, and reusable complex datatypes. Each row identifies a path, allowed value type, screening classification, semantic group, source StructureDefinition and element ID, and any recursive expansion rule. Deployment profiles, custom extensions, and actual instances require separate review. [HL7 R4 definitions](https://hl7.org/fhir/R4/downloads.html) · [HL7 R5 definitions](https://hl7.org/fhir/R5/downloads.html)

## Version applicability

`FHIR R4` and `FHIR R5` show `Yes` where that declaration and value-type pair applies. A blank means the pair is absent from that version's base declarations. There are 5,534 R4 rows, 7,079 R5 rows, and 4,124 shared rows. Shared rows retain both source versions. Fields such as reference targets are labeled by version when their values differ.

The flags apply to declarations rather than every inherited or expanded path in an instance. For example, R4 declares `Organization.contact.name` within a backbone element. R5 declares `Organization.contact` as `ExtendedContactDetail`, which declares `ExtendedContactDetail.name`. Both versions can therefore carry a contact name at the same instance location. The contact name remains QI in both versions. [R4 Organization definitions](https://hl7.org/fhir/R4/organization-definitions.html) · [R5 Organization definitions](https://hl7.org/fhir/R5/organization-definitions.html) · [ExtendedContactDetail](https://hl7.org/fhir/R5/metadatatypes.html#ExtendedContactDetail)

The FHIR Privacy Reviewer also identified R5 linkage paths such as `DeviceAssociation.subject`, `DeviceAssociation.device`, `GenomicStudy.analysis.focus`, and `SubscriptionStatus.notificationEvent.focus`. R5 `CodeableReference` separates the coded concept from the reference. Assess the concept for what it discloses and the reference for what it can link. [DeviceAssociation](https://hl7.org/fhir/R5/deviceassociation-definitions.html) · [GenomicStudy](https://hl7.org/fhir/R5/genomicstudy-definitions.html) · [SubscriptionStatus](https://hl7.org/fhir/R5/subscriptionstatus-definitions.html) · [CodeableReference](https://hl7.org/fhir/R5/references.html#CodeableReference)

## Classifications

| Label | Meaning |
|---|---|
| DI | A value can identify a person directly, as with a known person-specific identifier. |
| QI | A value can narrow the candidate set in combination with other data, as with birth date or postal code. ITI.DIS also assigns human names to this group. |
| DI / QI | The role depends on the value or issuer. A personal email can identify directly. A shared phone number can link a household. |
| QI / Linkage | A stable ID or resolvable reference can connect records. Identifiability depends on what the recipient can join it to. |
| DI / Review | The field can directly identify a person if its content does so, as with a recognizable patient photo. |
| Sensitive value / Review | A value can disclose sensitive information about a linked person and may also help identify them. |
| Review | Inspect text, URI, payload, reference display, extension, or recursive content. |
| Non-PII | The screening rule found no dedicated identifying signal at this declaration. Inspect actual values, combinations, and child declarations when relevant. |

These are rule-based screening labels. For example, a name may identify a caregiver, a date may describe publication of a specification, and an identifier may name an organization. The labels describe possible exposure and do not establish whether a specific instance contains PII. Sensitive-value flags are illustrative rather than a complete taxonomy of clinical sensitivity.

ITI.DIS classifies human names as QI regardless of the person’s role. This includes patients, contacts, relatives, practitioners, and other people represented in the data. A distinctive full name can still identify someone on its own. Review ambiguous free-text fields for actual human names.

## Semantic groups

Every row other than `Non-PII` has a semantic group. The group describes the kind of information or exposure route. The classification describes its possible privacy effect, and the FHIR data value type describes its structure. For example, `HumanName.family` belongs to `person-name`, `Device.serialNumber` belongs to `device-identifier`, and `Practitioner.identifier` belongs to `care-provider-identifier`. All three are QI under the ITI.DIS convention.

For fields that require inspection, groups such as `free-text`, `attachment`, and `extension-content` describe the carrier. The actual content may resolve to a more specific group. A `Non-PII` parent can still contain classified children. For example, `Organization.contact` is a container and the applicable name declaration belongs to `person-name`.

`Patient.birthDate` belongs to the dedicated `birth-dates` group in both versions and remains QI. Event dates and recorded ages retain their separate groups. [DIS Volume 3](volume-3.html#3pxx122-semantic-groups)

## Device and care-provider identifiers

ITI.DIS classifies device identifiers and care-provider identifiers as QI. The catalog records these bindings at `Device.identifier`, `Device.distinctIdentifier`, `Device.serialNumber`, `Practitioner.identifier`, and `PractitionerRole.identifier`. For an Identifier datatype, apply the binding to its `.value` and use the namespace to interpret it.

Apply the same QI rule to inherited resource IDs and reference keys when they identify a device, care provider, or care-provider role. For example, `Device.id` and `Practitioner.id` still resolve to the single `Resource.id` declaration. A device assignment register can connect a device key to a patient, and a provider directory can connect a provider key to a practitioner or help narrow a match to an encounter. Check whether a device code identifies an individual unit or a product model.

## Declaration and inheritance

A declaration appears under its defining type. Inherited copies are omitted using the source snapshot's `ElementDefinition.base.path`. Nested backbone fields declared by a resource remain under that resource. Datatype children are listed under their datatype and are not expanded at each use. Each permitted choice type has its own row because the value type and screening label can differ.

| Concrete path to review | How to locate its declaration |
|---|---|
| `Patient.id` | Read `Resource.id`. |
| `Patient.meta.source` | Follow `Resource.meta` to `Meta.source`. |
| `Patient.text.div` | Follow `DomainResource.text` to `Narrative.div`. |
| `Patient.contact.name.family` | Follow `Patient.contact.name` to `HumanName.family`. |
| `Patient.identifier.value` | Follow `Patient.identifier` to `Identifier.value`. Evaluate the issuer and the identity represented at that use. |

`Resource`, `DomainResource`, and the R5 base resource types `CanonicalResource` and `MetadataResource` are listed as templates. Concrete resource declarations have scope `Resource`. Datatype and base declarations have scope `Template`. For an inherited field, apply the declaration in the context of the concrete resource and any governing profile. [Resource](https://hl7.org/fhir/R4/resource.html) · [DomainResource](https://hl7.org/fhir/R4/domainresource.html) · [ElementDefinition](https://hl7.org/fhir/R4/elementdefinition.html)

## Path conventions

- Paths start with the declaring type and omit array indices. Apply a path to each repetition. Choice rows use concrete FHIR names such as `Observation.valueString`. Their source element IDs retain the original `[x]` notation. Container rows and their descendants can both appear. [FHIR JSON representation](https://hl7.org/fhir/R4/json.html)
- For an extension, apply the `Extension` template at the field path and repeat for nested extensions. Use the actual extension definition and slice to determine the allowed values. Primitive extensions use the JSON underscore companion property, such as `Patient._birthDate.extension`, and follow the same template. [Extensibility](https://hl7.org/fhir/R4/extensibility.html) · [FHIR JSON representation](https://hl7.org/fhir/R4/json.html)
- For an embedded resource, apply the rows for its actual `resourceType` at the embedding path. For a recursive backbone element, repeat the children at the source indicated in the expansion rule. This covers arbitrarily nested structures using a finite set of rows. [DomainResource](https://hl7.org/fhir/R4/domainresource.html) · [ElementDefinition](https://hl7.org/fhir/R4/elementdefinition.html)
- Treat `.reference`, `.identifier`, and `.display` as separate exposure routes. Target types appear on the parent reference row. Reference resolution, parsing free text, and decoding attachments require access to the actual instance or payload. [References](https://hl7.org/fhir/R4/references.html)
