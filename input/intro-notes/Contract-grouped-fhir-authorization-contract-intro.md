This example mirrors the two permissions in the [UC-2 Agreement](odrl-content.html#decoded-authorization-example). The approved purpose and ISO category are shared. The R4 clinical and R5 imaging permissions retain their own policy versions. The original Agreement is referenced by its exact DocumentReference version.

| Field | Summary |
| --- | --- |
| Issuer | Approval authority |
| Requester and result recipient | Coordinator organization, recorded in both roles |
| Approved purpose | Multimodal research data preparation |
| ISO/TS 14265:2024 classification | `4.2` Health technology innovation |
| Permission validity | 2026-01-01 00:00 UTC inclusive to 2028-01-01 00:00 UTC exclusive |

| Permission | Approved de-identification policy |
| --- | --- |
| `patient-r4` | `https://governance.example.org/policies/patient-name-removal\|1.0` |
| `imaging-report-r5` | `https://governance.example.org/policies/imaging-report-subject-removal\|1.0` |
