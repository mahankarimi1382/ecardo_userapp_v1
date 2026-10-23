# Profile، Settings، Rewards و Support

- Profile summary: اطلاعات قابل‌ویرایش از read-only تفکیک شود؛ تغییرات sensitive با re-auth.
- Language: انتخاب زبان، RTL/LTR، زمان اعمال و حفظ مسیر فعلی مشخص باشد.
- Theme: Light/Dark/System با پیروی صحیح از تنظیم دستگاه.
- Accessibility settings: فونت/کنتراست/کاهش حرکت نباید با محدودکردن global TextScaler خنثی شود.
- Notification/privacy: هر toggle باید به preference یا backend واقعی متصل باشد.
- Rewards: امتیاز، تاریخ انقضا، شرایط، منابع و state pending/credited از دادهٔ واقعی و policy معتبر بیاید.
- Support ticket: ایجاد، attachment، status، reply و close/reopen با idempotent submit و upload recovery.
- Legal/privacy: نسخه و تاریخ policy، لینک رسمی و دسترس‌پذیری متن.
- App info: version/build/commit only from build metadata; diagnostics بدون token/PII.

## حالات الزامی
not logged in; read-only; save pending; conflict/409; validation error; upload fails; offline draft; session expires; permission denied; language change fails; support service down.
