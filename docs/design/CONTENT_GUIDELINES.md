# eCardo — Content Design & Error Copy Guidelines (DX-008)

**Document Version:** 1.0.0  
**Date:** 2026-10-14  
**Audit Context:** `ecardo_userapp_v1_audit_roadmap_fa (2).md` — Sections 15.1, 20 & Task DX-008  
**Core Standard:** Nielsen Norman Plain Language, Financial Transparency & Multi-Locale Harmony

---

## 1. Tone of Voice & Personality

| Dimension | Our Standard | What We Avoid |
| :--- | :--- | :--- |
| **Tone** | Calm, reassuring, respectful, authoritative | Slang, false urgency, panic, dismissive |
| **Financial Clarity** | Exact breakdown with currency tickers and fees | Vague estimates, hidden asterisks, confusing math |
| **Error Handling** | Explain what happened and provide a direct recovery CTA | Cryptic codes ("Error 500"), blame, raw exceptions |
| **Bilingual Voice** | Natural idiomatic Persian (`fa`) and international English (`en`) | Awkward machine translations, mixed RTL/LTR words |

---

## 2. Error Message Architecture: The 3-Part Rule

Every error message in eCardo must answer three questions:
1. **What happened?** (Plain language statement of the issue)
2. **Why did it happen?** (Clear context without technical jargon)
3. **What can the user do next?** (Actionable step, e.g. "Check your connection", "Try again in 30s", "Contact support")

### Example Comparisons

| Scenario | ❌ Poor / Anti-Pattern | ✅ eCardo Standard (En) | ✅ eCardo Standard (Fa) |
| :--- | :--- | :--- | :--- |
| **Network Timeout** | "DioException [receiveTimeout]" | "Connection timed out. We are verifying your request — please check Transaction History before retrying." | «زمان پاسخگویی به پایان رسید. تراکنش شما در حال بررسی است؛ لطفاً قبل از تلاش دوباره، تاریخچه تراکنش‌ها را بررسی کنید.» |
| **Insufficient Balance** | "Error: balance too low" | "Insufficient balance in your $CURRENCY wallet. You need $NEEDED more to complete this transfer." | «موجودی کیف پول $CURRENCY کافی نیست. برای این انتقال به $NEEDED بیشتر نیاز دارید.» |
| **Rate Expired** | "Quote invalid" | "Exchange rate updated. Please review and confirm the new rate." | «نرخ تبدیل به‌روزرسانی شد. لطفاً نرخ جدید را بررسی و تایید کنید.» |
| **Invalid Sheba** | "Format error" | "Please enter a valid 24-digit Sheba number starting with IR." | «لطفاً شماره شبای معتبر ۲۴ رقمی با پیشوند IR وارد کنید.» |
| **Session Expired** | "401 Unauthorized" | "Your session has expired for your security. Please sign in again." | «نشست کاربری شما به دلایل امنیتی پایان یافت. لطفاً دوباره وارد شوید.» |

---

## 3. Financial Terminology Glossary

| English Term | Persian Standard (`fa`) | Arabic Standard (`ar`) | Usage Rule |
| :--- | :--- | :--- | :--- |
| **Available Balance** | موجودی در دسترس | الرصيد المتاح | Funds immediately usable for transactions |
| **Pending Balance** | موجودی در حال پردازش | رصيد قيد الانتظار | Funds locked in escrow or awaiting gateway confirmation |
| **Platform Fee** | کارمزد سرویس | رسوم الخدمة | Clearly displayed before confirmation slider |
| **Network Fee** | کارمزد شبکه | رسوم الشبكة | Blockchain or interbank transfer fee |
| **Net Received** | مبلغ دریافتی نهایی | المبلغ الصافي المستلم | The exact amount credited to recipient |
| **Exchange Rate** | نرخ تبدیل | سعر الصرف | Must specify direction: "1 USD = 95,000 IRT" |
| **Idempotency** | عدم تکرار تراکنش | ضمان عدم التكرار | Transparently handled without technical wording |
