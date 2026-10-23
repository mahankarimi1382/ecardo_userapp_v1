# چک‌لیست Design Review برای هر PR

## UX
- [ ] هدف صفحه واضح است و primary action اولویت دارد.
- [ ] نام، مقدار، fee، status و destination hierarchy دارند.
- [ ] از componentهای مشترک و tokens استفاده شده‌اند.
- [ ] error/retry/pending/empty/offline/disabled حالت مناسب دارد.
- [ ] CTA بی‌عمل یا feature mock نیست.
- [ ] Back, dismiss, deep link و app resume رفتار قابل پیش‌بینی دارند.

## Finance safety
- [ ] هیچ UI optimistic state به عنوان server success نمایش داده نمی‌شود.
- [ ] operation ambiguity به status lookup/reconciliation می‌رود.
- [ ] amount/precision/fee/quote/network از authority مناسب می‌آیند.
- [ ] no double submit; retry semantics defined.
- [ ] no secrets/PII in screenshots, analytics or logs.

## Visual & accessibility
- [ ] Light/Dark.
- [ ] fa/ar RTL and en/zh/tr/ru.
- [ ] Small screen + large text + keyboard.
- [ ] Contrast/tap-target/semantics/focus.
- [ ] Reduced motion and performance impact considered.
- [ ] Before/after screenshot attached.

## Evidence
- [ ] Route ID, changed files and owner listed.
- [ ] Relevant tests written/run according to repo policy.
- [ ] Analyzer/test logs tied to same SHA.
- [ ] Golden changes reviewed.
- [ ] Remaining risks and rollback noted.
- [ ] No push/release/deploy authorization inferred from this PR.
