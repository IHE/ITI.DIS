The inline rule attachment carries the complete [UC-2 Agreement](odrl-content.html#decoded-authorization-example) as Base64-encoded JSON-LD. This example mirrors its two permissions. The approved purpose and ISO category are shared. The R4 clinical and R5 imaging permissions retain their own policy versions.

| Field | Summary |
| --- | --- |
| Issuer | Approval authority |
| Requester and result recipient | Coordinator organization, recorded in both roles |
| Approved purpose | Multimodal research data preparation |
| ISO/TS 14265:2024 classification | `4.2` Health technology innovation |
| Permission validity | 2026-01-01 00:00 UTC inclusive to 2028-01-01 00:00 UTC exclusive |

| Permission | Approved de-identification policy |
| --- | --- |
| `patient-r4` | `https://governance.example.org/policies/patient-name-removal` &#124; `1.0` |
| `imaging-report-r5` | `https://governance.example.org/policies/imaging-report-subject-removal` &#124; `1.0` |
