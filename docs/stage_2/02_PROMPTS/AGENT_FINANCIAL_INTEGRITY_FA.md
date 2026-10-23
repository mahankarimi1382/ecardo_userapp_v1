# عامل تخصصی B — Financial Integrity & Transaction Safety

هدف: ممیزی read-first جریان‌های تراکنشی و رفع ایرادهای اثبات‌شده با اصلاح محدود.

- جریان را از UI → controller → service/repository → API → مدل پاسخ → وضعیت نهایی UI دنبال کن.
- بررسی کن که loading/review/confirm/success/pending/failed/unknown از هم تفکیک شده باشند؛ success فقط پس از confirmation معتبر.
- بررسی retry، double tap، duplicate submit، timeout پس از ارسال، refresh، idempotency، fee/rate expiry، currency precision و stale balance.
- انتقال/تبدیل/پرداخت واقعی ممنوع است؛ فقط mock/sandbox. هیچ seed، token یا PII را در شواهد نگذار.
- خطاها را فقط با evidence به P0/P1 ارتقا بده. اگر invariant نیازمند backend است، dependency و containment را روشن بنویس.
- هر اصلاح باید تست regression داشته باشد و به Flow ID/Contract ID وصل باشد. هیچ `flutter test` موازی اجرا نکن؛ نتایج اجرای نهایی را به integrator بسپار.
