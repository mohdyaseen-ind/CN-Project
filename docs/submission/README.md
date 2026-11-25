# Final Submission Assembly

This is the assembly map for the three-laptop project. It separates existing
implementation, measured evidence, and items still awaiting teammate results.
Do not mark a row complete from another member's plan or template alone.

## Submission map

| Deliverable | Source / destination | Current state |
|---|---|---|
| Architecture and three-laptop topology | `docs/ARCHITECTURE.md` | Existing; update after each host is verified. |
| IP, interface, subnet, gateway, service inventory | `docs/IP-INVENTORY.md` | Existing; only measured host values are verified there. |
| DNS → TCP → TLS → HTTP flow | `docs/ARCHITECTURE.md` and `final-report-outline.md` | Architecture documented; live flow pending integration. |
| Phase 1 nginx and DNS configurations | `configs/edge/`, `configs/dns/` | Templates retained; validate on assigned hosts. |
| Phase 2 configurations and scripts | `configs/`, `scripts/` | Includes Sankalp main edge and diagnostic scripts; runtime validation pending. |
| Backend source | `backend/server.py` | Existing shared implementation; both assigned instances still need verification. |
| Certificate setup | `docs/phase2/tls-setup.md`, `configs/tls/gen-cert.sh` | Local SAN certificate generated; client trust and HTTPS pending. |
| Firewall rules and rollback | `configs/firewall/`, `scripts/pf-backend-a-*.sh` | Prepared for Prateek; activation requires host/admin coordination. |
| Screenshots, logs, packet captures | `evidence/` | Historical Phase 1 retained; current logs in `evidence/phase2/`; required screenshots pending actual capture. |
| Phase 2 reports | `docs/phase2/*-report.md` | Sankalp and Prateek reports available; Sarthak results pending. |
| Final report | `final-report-outline.md` | Outline only; integrate after both teammates provide verified results. |
| Live demonstration guide | `demo-guide.md` | Prepared; perform only after prerequisites and coordination gates. |
| Individual viva preparation | `viva-questions.md` | Sankalp questions prepared. |

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

The integrated report and presentation remain pending until team evidence is
received. Never include private TLS keys or unverified faculty evaluation
results.
