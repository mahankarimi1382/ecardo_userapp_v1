## 1.0.73+73 — auto-tag release pipeline

- CI: ensure-release-tag job on main creates missing v* tag so APK + server notify always run
- Prevents silent "CI green but no in-app update" when only main is pushed

Agent: server-user
