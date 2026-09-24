## 1.0.88+88 — security hardening

- Fail closed when an in-app gateway return cannot be verified by the server.
- Restrict payment navigation to HTTPS and reject invalid initial payment URLs.
- Clear the offline request queue when a session ends.
- Restrict in-app updates to approved GitHub release URLs.
- Reduce FileProvider exposure, remove release cleartext exceptions, and allow installation on devices without cameras.
- Make the Android CI analyzer fail on analyzer/tool failures.

Agent: github-user
