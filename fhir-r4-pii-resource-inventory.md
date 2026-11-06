# FHIR R4 resources that may include PII

All 146 concrete FHIR R4 (4.0.1) resource types are in scope. This inventory describes schema-level exposure. Actual PII depends on instance values, applicable profiles, available linked data, and the recipient's ability to make a match.

The inventory uses snapshots from the official `hl7.fhir.r4.core#4.0.1` package. [HL7 R4 resource index](https://hl7.org/fhir/R4/resourcelist.html)

## Shared paths

- Every row inherits `id` and `meta`. A person-specific value or resolvable record key in `id`, `meta.source`, or metadata labels can expose identity or enable linkage. Standard artifact identifiers and labels typically describe specifications or vocabulary. [Resource and Meta](https://hl7.org/fhir/R4/resource.html)
- All rows except Binary, Bundle, and Parameters also inherit `text.div`, `contained`, `extension`, and `modifierExtension`. Inspect narrative, nested resources, and extension values using their applicable definitions. [DomainResource](https://hl7.org/fhir/R4/domainresource.html) · [Extensibility](https://hl7.org/fhir/R4/extensibility.html)

## Findings from the FHIR Privacy Reviewer

- Six resource types have dedicated name fields typed as HumanName. These are `InsurancePlan.contact.name`, `Organization.contact.name`, `Patient.name` and `Patient.contact.name`, `Person.name`, `Practitioner.name`, and `RelatedPerson.name`. The name may belong to a contact rather than the resource subject. [HumanName](https://hl7.org/fhir/R4/datatypes.html#HumanName)
- `Task.input.value[x]`, `Task.output.value[x]`, and `StructureMap.group.rule.source.defaultValue[x]` also allow HumanName as a choice type. Check the concrete type and value supplied. [Task](https://hl7.org/fhir/R4/task-definitions.html) · [StructureMap](https://hl7.org/fhir/R4/structuremap-definitions.html)
- References to person records can disclose a name or identifier directly, or enable a join when the recipient can resolve the reference or match it to another dataset. Shared addresses, event dates, and stable IDs can also enable identification in combination. [Reference](https://hl7.org/fhir/R4/references.html)

## Resource inventory

The examples column shows selected schema paths beyond the shared paths. It prioritizes names, references that can target people, content carriers, and fields named for identifiers, URLs, or diagnostics. Path names are relative to the resource type. An em dash means the selection did not yield an example. The shared paths still apply, and the linked definition may contain other relevant fields. Identifier, URL, and contact fields may describe artifacts, organizations, or publishers. Inspect their values before classifying them as PII. Review references through `.reference`, `.identifier`, and `.display` and resolve targets only when authorized. [Reference](https://hl7.org/fhir/R4/references.html)

| Resource | Selected paths to inspect |
|---|---|
| [Account](https://hl7.org/fhir/R4/account-definitions.html) | `guarantor.party`, `subject`, `description`, `identifier` |
| [ActivityDefinition](https://hl7.org/fhir/R4/activitydefinition-definitions.html) | `author`, `contact`, `editor`, `endorser`, `reviewer` |
| [AdverseEvent](https://hl7.org/fhir/R4/adverseevent-definitions.html) | `contributor`, `recorder`, `subject`, `suspectEntity.causality.author`, `identifier` |
| [AllergyIntolerance](https://hl7.org/fhir/R4/allergyintolerance-definitions.html) | `asserter`, `patient`, `recorder`, `note`, `reaction.note` |
| [Appointment](https://hl7.org/fhir/R4/appointment-definitions.html) | `participant.actor`, `description`, `identifier` |
| [AppointmentResponse](https://hl7.org/fhir/R4/appointmentresponse-definitions.html) | `actor`, `identifier` |
| [AuditEvent](https://hl7.org/fhir/R4/auditevent-definitions.html) | `agent.who`, `source.observer`, `entity.detail.value[x]`, `entity.query`, `agent.network.address` |
| [Basic](https://hl7.org/fhir/R4/basic-definitions.html) | `author`, `identifier` |
| [Binary](https://hl7.org/fhir/R4/binary-definitions.html) | `data`, `securityContext` |
| [BiologicallyDerivedProduct](https://hl7.org/fhir/R4/biologicallyderivedproduct-definitions.html) | `collection.collector`, `collection.source`, `identifier`, `manipulation.description`, `processing.description` |
| [BodyStructure](https://hl7.org/fhir/R4/bodystructure-definitions.html) | `patient`, `image`, `description`, `identifier` |
| [Bundle](https://hl7.org/fhir/R4/bundle-definitions.html) | `entry.resource`, `entry.fullUrl`, `entry.request.url`, `entry.response.outcome` |
| [CapabilityStatement](https://hl7.org/fhir/R4/capabilitystatement-definitions.html) | `contact`, `description`, `implementation.description`, `implementation.url`, `messaging.endpoint.address` |
| [CarePlan](https://hl7.org/fhir/R4/careplan-definitions.html) | `activity.detail.performer`, `author`, `contributor`, `subject`, `activity.progress` |
| [CareTeam](https://hl7.org/fhir/R4/careteam-definitions.html) | `participant.member`, `subject`, `note`, `identifier`, `telecom` |
| [CatalogEntry](https://hl7.org/fhir/R4/catalogentry-definitions.html) | `referencedItem`, `additionalIdentifier`, `identifier` |
| [ChargeItem](https://hl7.org/fhir/R4/chargeitem-definitions.html) | `enterer`, `performer.actor`, `subject`, `note`, `identifier` |
| [ChargeItemDefinition](https://hl7.org/fhir/R4/chargeitemdefinition-definitions.html) | `contact`, `applicability.description`, `description`, `identifier`, `url` |
| [Claim](https://hl7.org/fhir/R4/claim-definitions.html) | `careTeam.provider`, `enterer`, `patient`, `payee.party`, `provider` |
| [ClaimResponse](https://hl7.org/fhir/R4/claimresponse-definitions.html) | `addItem.provider`, `patient`, `requestor`, `form`, `identifier` |
| [ClinicalImpression](https://hl7.org/fhir/R4/clinicalimpression-definitions.html) | `assessor`, `subject`, `note`, `description`, `identifier` |
| [CodeSystem](https://hl7.org/fhir/R4/codesystem-definitions.html) | `contact`, `description`, `filter.description`, `identifier`, `property.description` |
| [Communication](https://hl7.org/fhir/R4/communication-definitions.html) | `recipient`, `sender`, `subject`, `note`, `payload.content[x]` |
| [CommunicationRequest](https://hl7.org/fhir/R4/communicationrequest-definitions.html) | `recipient`, `requester`, `sender`, `subject`, `note` |
| [CompartmentDefinition](https://hl7.org/fhir/R4/compartmentdefinition-definitions.html) | `contact`, `description`, `url` |
| [Composition](https://hl7.org/fhir/R4/composition-definitions.html) | `attester.party`, `author`, `section.author`, `identifier`, `relatesTo.target[x]` |
| [ConceptMap](https://hl7.org/fhir/R4/conceptmap-definitions.html) | `contact`, `description`, `group.unmapped.url`, `identifier`, `url` |
| [Condition](https://hl7.org/fhir/R4/condition-definitions.html) | `asserter`, `recorder`, `subject`, `note`, `identifier` |
| [Consent](https://hl7.org/fhir/R4/consent-definitions.html) | `patient`, `performer`, `provision.actor.reference`, `verification.verifiedWith`, `source[x]` |
| [Contract](https://hl7.org/fhir/R4/contract-definitions.html) | `author`, `contentDefinition.publisher`, `signer.party`, `term.action.performer`, `term.action.requester` |
| [Coverage](https://hl7.org/fhir/R4/coverage-definitions.html) | `beneficiary`, `payor`, `policyHolder`, `subscriber`, `identifier` |
| [CoverageEligibilityRequest](https://hl7.org/fhir/R4/coverageeligibilityrequest-definitions.html) | `enterer`, `item.provider`, `patient`, `provider`, `identifier` |
| [CoverageEligibilityResponse](https://hl7.org/fhir/R4/coverageeligibilityresponse-definitions.html) | `insurance.item.provider`, `patient`, `requestor`, `identifier`, `insurance.item.description` |
| [DetectedIssue](https://hl7.org/fhir/R4/detectedissue-definitions.html) | `author`, `mitigation.author`, `patient`, `identifier` |
| [Device](https://hl7.org/fhir/R4/device-definitions.html) | `patient`, `note`, `udiCarrier.carrierAIDC`, `identifier`, `url` |
| [DeviceDefinition](https://hl7.org/fhir/R4/devicedefinition-definitions.html) | `note`, `capability.description`, `identifier`, `url` |
| [DeviceMetric](https://hl7.org/fhir/R4/devicemetric-definitions.html) | `identifier` |
| [DeviceRequest](https://hl7.org/fhir/R4/devicerequest-definitions.html) | `performer`, `requester`, `subject`, `note`, `groupIdentifier` |
| [DeviceUseStatement](https://hl7.org/fhir/R4/deviceusestatement-definitions.html) | `source`, `subject`, `note`, `identifier` |
| [DiagnosticReport](https://hl7.org/fhir/R4/diagnosticreport-definitions.html) | `performer`, `resultsInterpreter`, `subject`, `presentedForm`, `identifier` |
| [DocumentManifest](https://hl7.org/fhir/R4/documentmanifest-definitions.html) | `author`, `recipient`, `subject`, `description`, `identifier` |
| [DocumentReference](https://hl7.org/fhir/R4/documentreference-definitions.html) | `authenticator`, `author`, `context.sourcePatientInfo`, `subject`, `content.attachment` |
| [EffectEvidenceSynthesis](https://hl7.org/fhir/R4/effectevidencesynthesis-definitions.html) | `author`, `certainty.certaintySubcomponent.note`, `certainty.note`, `contact`, `editor` |
| [Encounter](https://hl7.org/fhir/R4/encounter-definitions.html) | `participant.individual`, `subject`, `hospitalization.preAdmissionIdentifier`, `identifier` |
| [Endpoint](https://hl7.org/fhir/R4/endpoint-definitions.html) | `address`, `identifier` |
| [EnrollmentRequest](https://hl7.org/fhir/R4/enrollmentrequest-definitions.html) | `candidate`, `provider`, `identifier` |
| [EnrollmentResponse](https://hl7.org/fhir/R4/enrollmentresponse-definitions.html) | `requestProvider`, `identifier` |
| [EpisodeOfCare](https://hl7.org/fhir/R4/episodeofcare-definitions.html) | `careManager`, `patient`, `identifier` |
| [EventDefinition](https://hl7.org/fhir/R4/eventdefinition-definitions.html) | `author`, `contact`, `editor`, `endorser`, `reviewer` |
| [Evidence](https://hl7.org/fhir/R4/evidence-definitions.html) | `author`, `contact`, `editor`, `endorser`, `note` |
| [EvidenceVariable](https://hl7.org/fhir/R4/evidencevariable-definitions.html) | `author`, `contact`, `editor`, `endorser`, `note` |
| [ExampleScenario](https://hl7.org/fhir/R4/examplescenario-definitions.html) | `contact`, `actor.description`, `identifier`, `instance.description`, `instance.version.description` |
| [ExplanationOfBenefit](https://hl7.org/fhir/R4/explanationofbenefit-definitions.html) | `addItem.provider`, `careTeam.provider`, `enterer`, `patient`, `payee.party` |
| [FamilyMemberHistory](https://hl7.org/fhir/R4/familymemberhistory-definitions.html) | `name`, `patient`, `relationship`, `born[x]`, `note` |
| [Flag](https://hl7.org/fhir/R4/flag-definitions.html) | `author`, `subject`, `identifier` |
| [Goal](https://hl7.org/fhir/R4/goal-definitions.html) | `expressedBy`, `subject`, `note`, `description`, `identifier` |
| [GraphDefinition](https://hl7.org/fhir/R4/graphdefinition-definitions.html) | `contact`, `description`, `link.description`, `link.target.compartment.description`, `url` |
| [Group](https://hl7.org/fhir/R4/group-definitions.html) | `managingEntity`, `member.entity`, `identifier` |
| [GuidanceResponse](https://hl7.org/fhir/R4/guidanceresponse-definitions.html) | `subject`, `note`, `identifier`, `requestIdentifier` |
| [HealthcareService](https://hl7.org/fhir/R4/healthcareservice-definitions.html) | `photo`, `identifier`, `notAvailable.description`, `telecom` |
| [ImagingStudy](https://hl7.org/fhir/R4/imagingstudy-definitions.html) | `interpreter`, `referrer`, `series.performer.actor`, `subject`, `note` |
| [Immunization](https://hl7.org/fhir/R4/immunization-definitions.html) | `patient`, `performer.actor`, `note`, `identifier` |
| [ImmunizationEvaluation](https://hl7.org/fhir/R4/immunizationevaluation-definitions.html) | `patient`, `description`, `identifier` |
| [ImmunizationRecommendation](https://hl7.org/fhir/R4/immunizationrecommendation-definitions.html) | `patient`, `identifier`, `recommendation.description` |
| [ImplementationGuide](https://hl7.org/fhir/R4/implementationguide-definitions.html) | `contact`, `definition.grouping.description`, `definition.resource.description`, `description`, `url` |
| [InsurancePlan](https://hl7.org/fhir/R4/insuranceplan-definitions.html) | `contact.name`, `contact.address`, `contact.telecom`, `identifier`, `plan.identifier` |
| [Invoice](https://hl7.org/fhir/R4/invoice-definitions.html) | `participant.actor`, `recipient`, `subject`, `note`, `identifier` |
| [Library](https://hl7.org/fhir/R4/library-definitions.html) | `author`, `contact`, `content`, `editor`, `endorser` |
| [Linkage](https://hl7.org/fhir/R4/linkage-definitions.html) | `author` |
| [List](https://hl7.org/fhir/R4/list-definitions.html) | `source`, `subject`, `note`, `identifier` |
| [Location](https://hl7.org/fhir/R4/location-definitions.html) | `address`, `description`, `identifier`, `telecom` |
| [Measure](https://hl7.org/fhir/R4/measure-definitions.html) | `author`, `contact`, `editor`, `endorser`, `reviewer` |
| [MeasureReport](https://hl7.org/fhir/R4/measurereport-definitions.html) | `reporter`, `subject`, `identifier` |
| [Media](https://hl7.org/fhir/R4/media-definitions.html) | `operator`, `subject`, `content`, `note`, `identifier` |
| [Medication](https://hl7.org/fhir/R4/medication-definitions.html) | `identifier` |
| [MedicationAdministration](https://hl7.org/fhir/R4/medicationadministration-definitions.html) | `performer.actor`, `subject`, `note`, `identifier` |
| [MedicationDispense](https://hl7.org/fhir/R4/medicationdispense-definitions.html) | `performer.actor`, `receiver`, `subject`, `substitution.responsibleParty`, `note` |
| [MedicationKnowledge](https://hl7.org/fhir/R4/medicationknowledge-definitions.html) | `drugCharacteristic.value[x]` |
| [MedicationRequest](https://hl7.org/fhir/R4/medicationrequest-definitions.html) | `performer`, `recorder`, `reported[x]`, `requester`, `subject` |
| [MedicationStatement](https://hl7.org/fhir/R4/medicationstatement-definitions.html) | `informationSource`, `subject`, `note`, `identifier` |
| [MedicinalProduct](https://hl7.org/fhir/R4/medicinalproduct-definitions.html) | `contact`, `crossReference`, `identifier`, `manufacturingBusinessOperation.authorisationReferenceNumber`, `specialDesignation.identifier` |
| [MedicinalProductAuthorization](https://hl7.org/fhir/R4/medicinalproductauthorization-definitions.html) | `identifier`, `jurisdictionalAuthorization.identifier`, `procedure.identifier` |
| [MedicinalProductContraindication](https://hl7.org/fhir/R4/medicinalproductcontraindication-definitions.html) | — |
| [MedicinalProductIndication](https://hl7.org/fhir/R4/medicinalproductindication-definitions.html) | — |
| [MedicinalProductIngredient](https://hl7.org/fhir/R4/medicinalproductingredient-definitions.html) | `identifier` |
| [MedicinalProductInteraction](https://hl7.org/fhir/R4/medicinalproductinteraction-definitions.html) | `description` |
| [MedicinalProductManufactured](https://hl7.org/fhir/R4/medicinalproductmanufactured-definitions.html) | — |
| [MedicinalProductPackaged](https://hl7.org/fhir/R4/medicinalproductpackaged-definitions.html) | `batchIdentifier.immediatePackaging`, `batchIdentifier.outerPackaging`, `description`, `identifier`, `packageItem.identifier` |
| [MedicinalProductPharmaceutical](https://hl7.org/fhir/R4/medicinalproductpharmaceutical-definitions.html) | `identifier` |
| [MedicinalProductUndesirableEffect](https://hl7.org/fhir/R4/medicinalproductundesirableeffect-definitions.html) | — |
| [MessageDefinition](https://hl7.org/fhir/R4/messagedefinition-definitions.html) | `contact`, `description`, `identifier`, `url` |
| [MessageHeader](https://hl7.org/fhir/R4/messageheader-definitions.html) | `author`, `destination.receiver`, `enterer`, `responsible`, `sender` |
| [MolecularSequence](https://hl7.org/fhir/R4/molecularsequence-definitions.html) | `patient`, `identifier`, `repository.url` |
| [NamingSystem](https://hl7.org/fhir/R4/namingsystem-definitions.html) | `contact`, `description` |
| [NutritionOrder](https://hl7.org/fhir/R4/nutritionorder-definitions.html) | `orderer`, `patient`, `note`, `identifier` |
| [Observation](https://hl7.org/fhir/R4/observation-definitions.html) | `performer`, `subject`, `note`, `identifier` |
| [ObservationDefinition](https://hl7.org/fhir/R4/observationdefinition-definitions.html) | `identifier` |
| [OperationDefinition](https://hl7.org/fhir/R4/operationdefinition-definitions.html) | `contact`, `description`, `url` |
| [OperationOutcome](https://hl7.org/fhir/R4/operationoutcome-definitions.html) | `issue.diagnostics`, `issue.details`, `issue.expression` |
| [Organization](https://hl7.org/fhir/R4/organization-definitions.html) | `contact.name`, `address`, `contact.address`, `contact.telecom`, `identifier` |
| [OrganizationAffiliation](https://hl7.org/fhir/R4/organizationaffiliation-definitions.html) | `identifier`, `telecom` |
| [Parameters](https://hl7.org/fhir/R4/parameters-definitions.html) | `parameter.resource`, `parameter.value[x]`, `parameter.part` |
| [Patient](https://hl7.org/fhir/R4/patient-definitions.html) | `identifier.value`, `name`, `telecom`, `address`, `contact.name`, `link.other` |
| [PaymentNotice](https://hl7.org/fhir/R4/paymentnotice-definitions.html) | `payee`, `provider`, `identifier` |
| [PaymentReconciliation](https://hl7.org/fhir/R4/paymentreconciliation-definitions.html) | `detail.payee`, `detail.responsible`, `detail.submitter`, `requestor`, `detail.identifier` |
| [Person](https://hl7.org/fhir/R4/person-definitions.html) | `name`, `link.target`, `photo`, `address`, `identifier` |
| [PlanDefinition](https://hl7.org/fhir/R4/plandefinition-definitions.html) | `author`, `contact`, `editor`, `endorser`, `reviewer` |
| [Practitioner](https://hl7.org/fhir/R4/practitioner-definitions.html) | `name`, `photo`, `address`, `identifier`, `qualification.identifier` |
| [PractitionerRole](https://hl7.org/fhir/R4/practitionerrole-definitions.html) | `practitioner`, `identifier`, `notAvailable.description`, `telecom` |
| [Procedure](https://hl7.org/fhir/R4/procedure-definitions.html) | `asserter`, `performer.actor`, `recorder`, `subject`, `note` |
| [Provenance](https://hl7.org/fhir/R4/provenance-definitions.html) | `agent.onBehalfOf`, `agent.who` |
| [Questionnaire](https://hl7.org/fhir/R4/questionnaire-definitions.html) | `contact`, `item.initial.value[x]`, `description`, `identifier`, `url` |
| [QuestionnaireResponse](https://hl7.org/fhir/R4/questionnaireresponse-definitions.html) | `author`, `source`, `item.answer.value[x]`, `identifier` |
| [RelatedPerson](https://hl7.org/fhir/R4/relatedperson-definitions.html) | `name`, `patient`, `photo`, `address`, `identifier` |
| [RequestGroup](https://hl7.org/fhir/R4/requestgroup-definitions.html) | `action.participant`, `author`, `subject`, `note`, `action.description` |
| [ResearchDefinition](https://hl7.org/fhir/R4/researchdefinition-definitions.html) | `author`, `contact`, `editor`, `endorser`, `reviewer` |
| [ResearchElementDefinition](https://hl7.org/fhir/R4/researchelementdefinition-definitions.html) | `author`, `contact`, `editor`, `endorser`, `reviewer` |
| [ResearchStudy](https://hl7.org/fhir/R4/researchstudy-definitions.html) | `principalInvestigator`, `contact`, `note`, `arm.description`, `description` |
| [ResearchSubject](https://hl7.org/fhir/R4/researchsubject-definitions.html) | `individual`, `identifier` |
| [RiskAssessment](https://hl7.org/fhir/R4/riskassessment-definitions.html) | `performer`, `subject`, `note`, `identifier` |
| [RiskEvidenceSynthesis](https://hl7.org/fhir/R4/riskevidencesynthesis-definitions.html) | `author`, `certainty.certaintySubcomponent.note`, `certainty.note`, `contact`, `editor` |
| [Schedule](https://hl7.org/fhir/R4/schedule-definitions.html) | `actor`, `identifier` |
| [SearchParameter](https://hl7.org/fhir/R4/searchparameter-definitions.html) | `contact`, `description`, `url` |
| [ServiceRequest](https://hl7.org/fhir/R4/servicerequest-definitions.html) | `performer`, `requester`, `subject`, `note`, `identifier` |
| [Slot](https://hl7.org/fhir/R4/slot-definitions.html) | `identifier` |
| [Specimen](https://hl7.org/fhir/R4/specimen-definitions.html) | `collection.collector`, `subject`, `note`, `accessionIdentifier`, `container.description` |
| [SpecimenDefinition](https://hl7.org/fhir/R4/specimendefinition-definitions.html) | `identifier`, `typeTested.container.description` |
| [StructureDefinition](https://hl7.org/fhir/R4/structuredefinition-definitions.html) | `contact`, `description`, `identifier`, `url` |
| [StructureMap](https://hl7.org/fhir/R4/structuremap-definitions.html) | `group.rule.source.defaultValue[x]`, `contact`, `description`, `identifier`, `structure.url` |
| [Subscription](https://hl7.org/fhir/R4/subscription-definitions.html) | `contact`, `criteria`, `channel.endpoint`, `channel.header`, `error` |
| [Substance](https://hl7.org/fhir/R4/substance-definitions.html) | `description`, `identifier`, `instance.identifier` |
| [SubstanceNucleicAcid](https://hl7.org/fhir/R4/substancenucleicacid-definitions.html) | `subunit.sequenceAttachment`, `subunit.linkage.identifier`, `subunit.sugar.identifier` |
| [SubstancePolymer](https://hl7.org/fhir/R4/substancepolymer-definitions.html) | `repeat.repeatUnit.structuralRepresentation.attachment` |
| [SubstanceProtein](https://hl7.org/fhir/R4/substanceprotein-definitions.html) | `subunit.sequenceAttachment`, `subunit.cTerminalModificationId`, `subunit.nTerminalModificationId` |
| [SubstanceReferenceInformation](https://hl7.org/fhir/R4/substancereferenceinformation-definitions.html) | `geneElement.element`, `target.target` |
| [SubstanceSourceMaterial](https://hl7.org/fhir/R4/substancesourcematerial-definitions.html) | `organismId`, `parentSubstanceId` |
| [SubstanceSpecification](https://hl7.org/fhir/R4/substancespecification-definitions.html) | `structure.representation.attachment`, `description`, `identifier`, `moiety.identifier`, `structure.isotope.identifier` |
| [SupplyDelivery](https://hl7.org/fhir/R4/supplydelivery-definitions.html) | `patient`, `receiver`, `supplier`, `identifier` |
| [SupplyRequest](https://hl7.org/fhir/R4/supplyrequest-definitions.html) | `deliverTo`, `requester`, `identifier` |
| [Task](https://hl7.org/fhir/R4/task-definitions.html) | `input.value[x]`, `output.value[x]`, `owner`, `requester`, `restriction.recipient` |
| [TerminologyCapabilities](https://hl7.org/fhir/R4/terminologycapabilities-definitions.html) | `contact`, `description`, `implementation.description`, `implementation.url`, `url` |
| [TestReport](https://hl7.org/fhir/R4/testreport-definitions.html) | `identifier`, `test.description` |
| [TestScript](https://hl7.org/fhir/R4/testscript-definitions.html) | `contact`, `description`, `identifier`, `metadata.capability.description`, `metadata.link.description` |
| [ValueSet](https://hl7.org/fhir/R4/valueset-definitions.html) | `contact`, `description`, `identifier`, `url` |
| [VerificationResult](https://hl7.org/fhir/R4/verificationresult-definitions.html) | `attestation.onBehalfOf`, `attestation.who`, `primarySource.who` |
| [VisionPrescription](https://hl7.org/fhir/R4/visionprescription-definitions.html) | `patient`, `prescriber`, `lensSpecification.note`, `identifier` |
