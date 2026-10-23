# Ownership و قواعد همکاری Agent/PR

## اصل
این برنامه task plan است و اجازهٔ نوشتن روی فایل‌های مشترک را خودکار نمی‌دهد. نسخهٔ جاری `FILE_OWNERSHIP.md` و قواعد `AGENTS.md` در checkout واقعی مقدم‌اند.

## تقسیم ownership پیشنهادی
- Navigation/Home: routes registry only after owner approval; Home screen/controller separate ownership.
- Accounts/Wallets/Cards: screens/controllers/models by explicit file set.
- Money movement: each transaction flow isolated; backend contract files require backend owner review.
- Authentication/Security: passcode, session, local auth by single owner due sensitive cross-cutting behavior.
- Activity/Receipts/Support: isolated modules.
- Design tokens/shared widgets: one designated design-system owner only.
- Localization ARB: one localization owner to avoid simultaneous edits.
- Golden files: one central test owner; no parallel baseline updates.

## PR checklist
- Explain goal and non-goals.
- List exact routes and files.
- Include before/after screenshots for visible changes.
- Prove no mock data/dead CTA/security regression.
- Mention accessibility + six locale coverage.
- Tests/analyze output refer to same SHA.
- No PII in screenshots or logs.
- No unrelated redesign of existing flows.
- No push, tag, release or deploy without explicit authorization.
