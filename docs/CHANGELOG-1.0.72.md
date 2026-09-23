## 1.0.72+72 — ticket statuses (6 values)

- Support full backend ticket statuses: open, in_progress, waiting_user, resolved, closed, archived
- Ticket list + details show correct label/color per status
- Reply composer gated by can_reply; close button by !is_closed (not only open)
- TicketStatusHelper centralizes mapping; unknown status shows raw value
- l10n: en/fa/ar/zh (+ ru/tr fallbacks)

Agent: server-user
