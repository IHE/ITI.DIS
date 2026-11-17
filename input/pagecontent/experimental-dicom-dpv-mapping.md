<div markdown="1" class="stu-note">
**Experimental.** This informative mapping supports review of the proposed DIS-DICOM1 binding. DIS conformance uses DIS-FHIR-Payload.
</div>

<div id="dicom-dpv-category-mapping"> </div>

[DICOM PS3.15 Annex E](https://dicom.nema.org/medical/dicom/current/output/chtml/part15/chapter_e.html) identifies attributes to protect or retain under the selected DICOM confidentiality profile and options. The mapping below uses [Table E.1-1](https://dicom.nema.org/medical/dicom/current/output/chtml/part15/chapter_e.html#table_E.1-1) to identify DICOM attributes that may carry or link to personal data.

Download the experimental mapping as [JSON-LD](bindings/dis-dicom-2026d-dpv-mapping-1.jsonld) or [CSV](bindings/dis-dicom-2026d-dpv-mapping-1.csv). Revision 1 covers all 657 rows in DICOM PS3.15 2026d Table E.1-1 and uses [DPV Personal Data Categories 2.3](https://w3c-cg.github.io/dpv/2.3/pd/). Each entry records the 1-based data row in Annex E, the tag or pattern, the DICOM keyword and value representation where available, the retirement flag, and the Basic Profile action code. Attribute keywords come from the [DICOM data element registry](https://dicom.nema.org/medical/dicom/current/output/chtml/part06/chapter_6.html), with file meta and directory entries from PS3.6 and command names from [PS3.7 Annex E](https://dicom.nema.org/medical/dicom/current/output/chtml/part07/chapter_E.html).

| Status | Meaning |
| --- | --- |
| `mapped` | The attribute has a defined DPV category, person role, and location when it describes a natural person. A coded sequence maps to the concept it carries. Applicable IOD and item context still govern individual values. |
| `context-dependent` | The attribute's referent, purpose, or link to a person depends on the IOD, report template, workflow, or release context. A candidate category, where present, is a review aid. A UID in a reference or a DIMSE command is an example. |
| `content-review` | Inspect the actual text, sequence items, graphics, private elements, or encapsulated content. A candidate category, where present, describes a likely type of content. |
| `no-category` | This revision assigns no DPV category to the attribute itself. Associated elements may still disclose personal data. |
{: .grid}

The mapping uses exact DPV concept IRIs. For example, Patient's Birth Date maps to `pd:BirthDate` and Patient's Age maps to `pd:Age`. Separate event dates, times, and UTC offsets remain context-dependent because DPV PD 2.3 has no dedicated categories for those values. An empty person role or location means the mapping leaves that dimension unresolved. The `narrative` location identifies text-bearing content and supplies no selector for a name or other substring within it.

The table contains 653 exact tags and four patterns for curves, overlays, and private attributes. A tag can occur at the dataset root or inside an item. Follow the IOD and item context to distinguish occurrences of the same tag. A sequence-level entry identifies the container or the concept it carries. Classify its children by their own meanings. The tag scope records conventional placement, including command, file meta, and directory elements.

<div id="dicom-patient-associated-uids"> </div>

## Patient-associated instance UIDs

For a patient-associated DICOM object, the root Study Instance UID `(0020,000D)`, Series Instance UID `(0020,000E)`, and SOP Instance UID `(0008,0018)` map to `pd:UID` in the patient role. Each identifies a level in the DICOM Patient Root hierarchy that can be linked to the patient. In a Part 10 file, Media Storage SOP Instance UID `(0002,0003)` has the same association when it matches the root SOP Instance UID of the patient-associated dataset. The mapping records this applicability in `roleRule`. [DICOM Patient Root hierarchy](https://dicom.nema.org/medical/dicom/current/output/chtml/part04/sect_C.3.html#sect_C.3.1), [DICOM SOP Common Module](https://dicom.nema.org/medical/dicom/current/output/chtml/part03/sect_C.12.html#sect_C.12.1.1.1), [DICOM File Meta Information](https://dicom.nema.org/medical/dicom/current/output/chtml/part10/chapter_7.html#table_7.1-1)

For a nested reference or a UID in a directory or DIMSE command, determine the patient association from the referenced instance and its DICOM context. A SOP Instance UID can also identify an object outside the patient hierarchy, such as a Hanging Protocol. [DICOM SOP Instance Reference Macro](https://dicom.nema.org/medical/dicom/current/output/chtml/part03/sect_10.3.html), [DICOM Hanging Protocol Information Model](https://dicom.nema.org/medical/dicom/current/output/chtml/part04/sect_U.3.html)

## Annex E actions

The action code is a source reference. Apply the selected Annex E options, the IOD's attribute requirements, and the sequence-handling rules when determining the action for an occurrence. See [Table E.1-1 for profile and option actions](https://dicom.nema.org/medical/dicom/current/output/chtml/part15/chapter_e.html#table_E.1-1) and [Table E.1-1a for code definitions](https://dicom.nema.org/medical/dicom/current/output/chtml/part15/chapter_e.html#table_E.1-1a). Evaluate main-image pixels and recognizable visual features under [Annex E.3](https://dicom.nema.org/medical/dicom/current/output/chtml/part15/sect_E.3.html).

| DPV category and role | DICOM attribute example | Annex E Basic Profile consideration |
| --- | --- | --- |
| `pd:Name`, patient | Patient's Name `(0010,0010)` | `Z` allows an empty or valid dummy value. A required attribute that permits an empty value may still prohibit DIS `remove`, which requires absence. |
| `pd:Identifier`, patient | Patient ID `(0010,0020)` | `Z/D` requires handling appropriate to the attribute type. Evaluate the identifier and its issuer context together. |
| `pd:BirthDate`, patient | Patient's Birth Date `(0010,0030)` | `Z` requires checking the attribute type and output constraints. |
| `pd:Name`, care provider | Performing Physician's Name `(0008,1050)` | `X` requires removal under the Basic Profile. A `keep` policy rule requires a separately applicable DICOM profile or option permitting retention. |
{: .grid}

Under this proposal, the Manager would check each DIS action against the applicable DICOM constraints for the concrete attribute, selected profile, and options. An incompatible action makes the assignment unsupported. For example, the Manager would reject a policy that keeps Performing Physician's Name when the selected DICOM profile requires its removal.

## Comparison with DICOM and DPV definitions

The [definition comparison](bindings/dis-dicom-2026d-dpv-definition-review-1.csv) covers all 657 Annex E rows. It locates semantic definitions for 618 rows, including 66 in historical DICOM editions. For 39 rows the review found registry or Annex E entries only. The comparison examines all 63 direct assignments individually. The `reviewDepth` column identifies individual comparisons, category-level checks for candidates, and source references for rows without an assigned category.

| Attribute | What the definitions support |
| --- | --- |
| Patient's Birth Date `(0010,0030)` and Birth Time `(0010,0032)` | Both fields describe a birth event. Only its calendar date fits `pd:BirthDate`. [DICOM Patient Demographic Module](https://dicom.nema.org/medical/dicom/current/output/chtml/part03/sect_C.2.3.html), [DPV BirthDate](https://w3c-cg.github.io/dpv/2.3/pd/#BirthDate) |
| Ethnic Group Code Sequence `(0010,2161)` and Ethnic Groups `(0010,2162)` | DICOM allows ethnic group or race. DPV places `pd:Race` under `pd:Ethnicity`, so the broader category fits both tags. A policy targeting `pd:Race` specifically needs to examine the values. [DICOM Patient Demographic Module](https://dicom.nema.org/medical/dicom/current/output/chtml/part03/sect_C.2.3.html), [DPV Race](https://w3c-cg.github.io/dpv/2.3/pd/#Race) |
| Branch of Service `(0010,1081)` and Military Rank `(0010,1080)` | These fields describe service affiliation and rank. `pd:Professional` is the better fit for both because its definition covers the person's career. `pd:Job` describes jobs and still fits Occupation `(0010,2180)`. [DICOM Patient Demographic Module](https://dicom.nema.org/medical/dicom/current/output/chtml/part03/sect_C.2.3.html), [DPV Professional](https://w3c-cg.github.io/dpv/2.3/pd/#Professional), [DPV Job](https://w3c-cg.github.io/dpv/2.3/pd/#Job) |
| Special Needs `(0038,0050)` | This patient narrative can describe medical, physical, or social support needed during care. Use `pd:MedicalHealth` as a candidate for clinical support such as oxygen. A specified language for communicating with the patient can fit `pd:Language`. Apply `pd:Disability` only when the text describes a disability. [DICOM Patient Medical Module](https://dicom.nema.org/medical/dicom/current/output/chtml/part03/sect_C.2.4.html), [DPV MedicalHealth](https://w3c-cg.github.io/dpv/2.3/pd/#MedicalHealth), [DPV Language](https://w3c-cg.github.io/dpv/2.3/pd/#Language), [DPV Disability](https://w3c-cg.github.io/dpv/2.3/pd/#Disability) |
| Study Instance UID `(0020,000D)` | The root study UID of a patient-associated instance maps to `pd:UID` in the patient role. The study belongs to the patient in the DICOM Patient Root hierarchy. [DICOM Patient Root hierarchy](https://dicom.nema.org/medical/dicom/current/output/chtml/part04/sect_C.3.html#sect_C.3.1), [DPV UID](https://w3c-cg.github.io/dpv/2.3/pd/#UID) |
{: .grid}

Of the 63 direct assignments, the definitions support 60, including 19 where DPV supplies a broader category. Branch of Service and Military Rank are flagged for refinement. The historical semantic definition for the retired Insurance Plan Identification `(0010,1050)` remains unverified. The comparison records these as findings for mapping revision 1.

## DPV Health Sector Concepts

The definition comparison includes 59 assessments using the [DPV 2.3 Health extension](https://w3c-cg.github.io/dpv/2.3/sector/health/), a Draft Community Group Report. Filter the CSV by `healthFit` to find attribute-level matches, concepts that require additional context, and cases where the tag definition supplies insufficient evidence. The Health terms in the review describe data. The guide uses DIS person roles for patients and care providers.

| Attribute | What the Health extension adds |
| --- | --- |
| Smoking Status `(0010,21A0)` | `sector-health:BehaviouralHealthDeterminant` captures the health relevance of the smoking behaviour recorded by this field. [DICOM Patient Study Module](https://dicom.nema.org/medical/dicom/current/output/chtml/part03/sect_C.7.2.2.html), [DPV Behavioural Health Determinant](https://w3c-cg.github.io/dpv/2.3/sector/health/#BehaviouralHealthDeterminant) |
| Histological Diagnoses Code Sequence `(0008,1304)` | `sector-health:MedicalTestResult` captures the coded finding confirmed by histopathological examination. [DICOM Patient Study Module](https://dicom.nema.org/medical/dicom/current/output/chtml/part03/sect_C.7.2.2.html), [DPV Medical Test Result](https://w3c-cg.github.io/dpv/2.3/sector/health/#MedicalTestResult) |
| Accession Number `(0008,0050)` | `sector-health:HealthAdminData` describes the workflow context when the imaging request can be linked to an identifiable person. The value identifies the request. [DICOM General Study Module](https://dicom.nema.org/medical/dicom/current/output/chtml/part03/sect_C.7.2.html), [DPV Health Admin Data](https://w3c-cg.github.io/dpv/2.3/sector/health/#HealthAdminData) |
| Study Instance UID `(0020,000D)` | `sector-health:MedicalImaging` describes the study context when the record is a personal medical imaging study. `pd:UID` describes the patient-associated study identifier. [DICOM General Study Module](https://dicom.nema.org/medical/dicom/current/output/chtml/part03/sect_C.7.2.html), [DPV Medical Imaging](https://w3c-cg.github.io/dpv/2.3/sector/health/#MedicalImaging) |
| Clinical Trial Subject ID `(0012,0040)` | `sector-health:ClinicalTrialsData` describes the source of health data when trial provenance is confirmed. `pd:Identifier` describes the participant ID. [DICOM Patient Medical Module](https://dicom.nema.org/medical/dicom/current/output/chtml/part03/sect_C.2.4.html), [DPV Clinical Trials Data](https://w3c-cg.github.io/dpv/2.3/sector/health/#ClinicalTrialsData) |
{: .grid}

Special Needs `(0038,0050)` can support `sector-health:SocioeconomicHealthDeterminant` when the text describes a socioeconomic factor affecting health. The tag has a wider scope and can also express clinical needs. Device Serial Number `(0018,1000)` identifies equipment. Applying `sector-health:MedicalDevicesData` requires evidence that the value conveys electronic health data from a medical device. [DICOM Patient Medical Module](https://dicom.nema.org/medical/dicom/current/output/chtml/part03/sect_C.2.4.html), [DICOM General Equipment Module](https://dicom.nema.org/medical/dicom/current/output/chtml/part03/sect_C.7.5.html), [DPV Socioeconomic Health Determinant](https://w3c-cg.github.io/dpv/2.3/sector/health/#SocioeconomicHealthDeterminant), [DPV Medical Devices Data](https://w3c-cg.github.io/dpv/2.3/sector/health/#MedicalDevicesData)

The Health extension columns are informative findings for the DICOM draft. The [DIS policy category operand](volume-3-policy.html#dpv-odrl-policy-profile) matches declared DPV Personal Data Categories by exact IRI.

See the [proposed DICOM payload binding](draft-native-payload-bindings.html#proposed-manifest-resolution) for the draft manifest and delivery conventions.
