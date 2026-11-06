<div markdown="1" class="stu-note">
**Draft design material.** This page preserves proposed DICOM and CDA bindings for review. Phase 1 conformance uses DIS-FHIR-Payload.
</div>

The proposals use the [common manifest contract](volume-3.html#payload-set-delivery) and [grouped payload parameters](volume-2.html#grouped-payload-parameters). The [informative mixed R5 and DICOM walkthrough](examples-mixed-r5-dicom.html) illustrates the proposed DICOM exchange.

## Proposed Manifest Resolution

| Binding | Resource selected by a List entry | Payload selected |
|---------|------------------------------------|------------------|
| DIS-DICOM1 (draft extension) | R4 [DIS DICOM Study Index](StructureDefinition-DIS-DICOMStudyIndex.html) or R4 DIS Payload Wrapper | The native instances enumerated by the study index, or the single DICOM Part 10 instance in the wrapper |
| DIS-CDA1 (draft extension) | R4 [DIS CDA Document Index](StructureDefinition-DIS-CDADocumentIndex.html) | The single native CDA XML document described by that DocumentReference |
{: .grid}

**DICOM.** The index identifies one study and explicitly enumerates selected series and SOP instances. For each selected series the retrieving actor SHALL resolve an unambiguous authorized [WADO-RS endpoint](https://hl7.org/fhir/R4/imagingstudy.html#endpoint). It uses the series endpoint when the series specifies one for WADO-RS and otherwise the study endpoint. It SHALL retrieve the enumerated instances using the Study, Series, and SOP Instance UIDs and verify that the returned instances match them. A series in the index SHALL enumerate its selected instances. The index does not authorize discovery or retrieval of unlisted instances.

**CDA.** The index identifies one current document and contains one CDA XML attachment. The retrieving actor SHALL obtain that document from the attachment data or its authorized HTTPS URL. For URL-based retrieval the endpoint SHALL provide the identified document in native XML. The actor SHALL verify the declared media type and that the returned content is a CDA document in the set's declared release. The Manager SHALL establish a stable document version for the job and its retries.

## Proposed Delivery Conventions

| Binding | Version | Inline content in a manifest package | Hosted content selected through a manifest |
|---------|---------|--------------------------------------|---------------------------------------------|
| DIS-DICOM1 (draft extension) | DICOM edition code declared by the option | DICOM Part 10 instance in a wrapper | Study index for [WADO-RS](https://dicom.nema.org/medical/dicom/current/output/chtml/part18/chapter_10.html) retrieval of listed instances, or a wrapper with an instance URL |
| DIS-CDA1 (draft extension) | `R2` | CDA XML in a CDA document index | CDA document index whose attachment URL retrieves the native XML |
{: .grid}

A DICOM wrapper would use `application/dicom` for the native instance.

## Open Binding Work

For DIS-DICOM1, the binding specification needs to publish supported SOP Classes, Transfer Syntaxes, and the exact edition codes. It needs to define DICOMweb authorization, approved [PS3.15 confidentiality profile and options](https://dicom.nema.org/medical/dicom/current/output/chtml/part15/chapter_E.html), tag and sequence selectors, pixel handling, UID integrity, and DICOM result and evidence validation.

For DIS-CDA1, the binding specification needs to publish the supported [CDA R2](https://hl7.org/cda/stds/online-navigation/infrastructure/cda/cda.htm) document types and templates. It needs to define document retrieval authorization, header, structured entry and narrative selectors, embedded content handling, document validation, and evidence mapping.

The DICOM and CDA rows define the draft delivery conventions. A conformance claim for either binding requires completion of its processing, policy, evidence, and capability definitions.

## Other Format Candidates

HL7 v2.x remains a future candidate. A binding could define segment, field, and component paths and carry ER7 or XML messages inline or by reference.
