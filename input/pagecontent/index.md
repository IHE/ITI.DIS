
The De-Identification Services (DIS) Profile defines interoperability requirements for policy-governed de-identification of HL7 FHIR health data. It defines four actors -- De-ID Manager, De-Identifier, De-Identification Requester, and Integrated De-ID Manager/De-Identifier -- four transactions (ITI-x1 Submit Job, ITI-x3 Submit Task, ITI-x4 Retrieve Job Output, and ITI-x7 Retrieve Task Output), a baseline policy execution model with flat, ordered rules, a minimum de-identification evidence baseline, and a FHIR payload binding (DIS-FHIR-Payload).

The Integrated actor may operate standalone with content conformance only, or support external jobs through ITI-x1 and, when DIS-ASYNC-JOB is declared, ITI-x4. DIS uses an R4 protocol binding and independently versioned R4/R5/R6 payloads; R6 support is provisional as described in Volume 1. Full composable execution plans are deferred.

DIS addresses the lack of a standard, interoperable workflow for how de-identification is requested, executed, validated, and delivered. It provides a governed, auditable path from authorization to delivery -- reducing reliance on manual processes and local one-off agreements. DIS starts after data request authorization has been established; it does not standardize permit lifecycle or data-request authorization.

<div markdown="1" class="stu-note">

| [Significant Changes, Open and Closed Issues](issues.html) |
{: .grid}

</div>

### Organization of This Guide

This guide is organized into the following sections:

- Volume 1: Profiles
  - [Introduction](volume-1.html)
  - [Actors, Transactions, and Content Responsibilities](volume-1.html#actors-and-transactions)
  - [Actor Options](volume-1.html#actor-options)
  - [Required Actor Groupings](volume-1.html#required-groupings)
  - [Overview](volume-1.html#overview)
  - [Security Considerations](volume-1.html#security-considerations)
  - [Cross Profile Considerations](volume-1.html#other-grouping)
- Volume 2: Transaction Detail
  - [Submit Job \[ITI-x1\]](volume-2.html#23x1-submit-de-identification-job-iti-x1)
  - [Submit Task \[ITI-x3\]](volume-2.html#23x3-submit-de-identification-task-iti-x3)
  - [Retrieve Job Output \[ITI-x4\]](volume-2.html#23x4-retrieve-job-output-iti-x4)
  - [Retrieve Task Output \[ITI-x7\]](volume-2.html#23x7-retrieve-task-output-iti-x7)
- Volume 3: Content Specifications
  - [De-Identification Policy](volume-3.html#de-identification-policy)
  - [De-Identification Execution Plan](volume-3.html#execution-plan-content)
  - [Payload Bindings](volume-3.html#payload-bindings)
  - [De-Identification Evidence](volume-3.html#evidence-baseline)
  - [Reversible Lookup Table and Examples](volume-3.html#3pxx5-reversible-lookup-table)
- Examples
  - [Policy Rules Examples](examples-policy-rules.html)
  - [Job with R4 and R5 Payload Sets](examples-grouped-fhir-job.html)
  - [Reversible Clinical Pathology Order](examples-reversible-pathology.html)
  - [Bulk FHIR Cohort Job](examples-bulk-fhir-cohort.html)
  - [Standalone Clinical Export](examples-standalone-export.html)
- Other
  - [Changes to Other IHE Specifications](other.html)
  - [Download and Analysis](download.html)
  - [JSON Schema Artifacts](download.html#json-schema-artifacts)
  - [Test Plan](testplan.html)

See also the [Table of Contents](toc.html) and the index of [Artifacts](artifacts.html) defined as part of this implementation guide.

### Conformance Expectations

IHE uses the normative words: "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL" according to [standards conventions](https://profiles.ihe.net/GeneralIntro/ch-E.html).

#### Must Support

The use of ```mustSupport``` in StructureDefinition profiles equivalent to the IHE use of **R2** as defined in [Appendix Z](https://profiles.ihe.net/ITI/TF/Volume2/ch-Z.html#z.10-profiling-conventions-for-constraints-on-fhir).

mustSupport of true - only has a meaning on items that are minimal cardinality of zero (0), and applies only to the source actor populating the data. The source actor shall populate the elements marked with MustSupport, if the concept is supported by the actor, a value exists, and security and consent rules permit.
The consuming actors should handle these elements being populated or being absent/empty.
Note that sometimes mustSupport will appear on elements with a minimal cardinality greater than zero (0), this is due to inheritance from a less constrained profile.
