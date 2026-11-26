# Final Submission Assembly

This is the assembly map for the three-laptop project. It separates existing
implementation, measured evidence, and items still awaiting teammate results.
Do not mark a row complete from another member's plan or template alone.

## Submission map

| Deliverable | Source / destination | Current state |
|---|---|---|
| Architecture and three-laptop topology | `docs/ARCHITECTURE.md` | Updated with current role-check results; subnet mask discrepancy remains open. |
| IP, interface, subnet, gateway, service inventory | `docs/IP-INVENTORY.md` | Current host facts reconciled from all three role reports; prefix mismatch needs confirmation. |
| DNS → TCP → TLS → HTTP flow | `docs/ARCHITECTURE.md` and `final-report.md` | Main flow verified from Sankalp; system DNS/backup DNS path incomplete. |
| Phase 1 nginx and DNS configurations | `configs/edge/`, `configs/dns/` | Main edge syntax/live baseline verified; both DNS templates not remotely validated. |
| Phase 2 configurations and scripts | `configs/`, `scripts/` | Main edge and diagnostic script verified; isolation rules prepared, not activated. |
| Backend source | `backend/server.py` | Both backends return remote HTTP 200 through direct host checks and main edge. |
| Certificate setup | `docs/phase2/tls-setup.md`, `configs/tls/gen-cert.sh` | Local SAN certificate validates TLS 1.2/1.3; OS/browser trust pending. |
| Firewall rules and rollback | `configs/firewall/`, `scripts/pf-backend-*.sh` | Prepared; PF isolation not active and requires backend-host admin coordination. |
| Screenshots, logs, packet captures | `evidence/` | Historical Phase 1 retained; current logs in `evidence/phase2/`; required screenshots pending actual capture. |
| Phase 2 reports | `docs/phase2/*-report.md` | All three role reports available; Sarthak's DNS results predate the role transfer and remain historical. |
| Final report | `final-report.md` | Integrated draft includes actual results and open blockers; not ready for final submission. |
| Presentation | `presentation-outline.md` | Slide-by-slide outline prepared; final deck awaits remaining tests/evidence. |
| Live demonstration guide | `demo-guide.md` | Eleven-step sequence prepared; disruptive steps require READY coordination. |
| Individual viva preparation | `viva-questions.md` | Sankalp questions and short answers prepared. |

## Suggested package layout

```text
submission/
  architecture.md                  # verified three-host design
  final-report.md                  # integrated report, after all host results
  configs/                          # reviewed configs, no private keys
  scripts/                          # reviewed start/diagnostic/rollback scripts
  backend/                          # shared backend source
  evidence/
    phase1/                         # retained original evidence
    phase2/prateek/                 # teammate-provided evidence
    phase2/sankalp/                 # evidence/phase2/sankalp/
    phase2/sarthak/                 # teammate-provided evidence
  presentation/                     # slides and demo guide
  viva/                             # individual question sheets
```

The integrated report is a draft. Presentation slides, current screenshots, and
current packet captures remain pending. Never include private TLS keys or
unverified faculty evaluation results.
