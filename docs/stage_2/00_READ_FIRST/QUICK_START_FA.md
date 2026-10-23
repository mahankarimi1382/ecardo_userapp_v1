# شروع سریع مرحلهٔ ۲

1. ابتدا خروجی stage 1 را در checkout واقعی پیدا کن؛ SHA آن را با HEAD فعلی تطبیق بده.
2. در صورت نبودن خروجی واقعی مرحلهٔ ۱، اول stage 1 را اجرا کن و برایش دادهٔ ساختگی نساز.
3. فایل `02_PROMPTS/STAGE_2_MASTER_AGENT_PROMPT_FA.md` را به agent اصلی بده.
4. CSVهای template را به `docs/integration/` کپی/تکمیل کن؛ template را به‌عنوان نتیجهٔ واقعی معرفی نکن.
5. هر کاندیدای ریسک را فقط بعد از اثبات به issue واقعی تبدیل کن.
6. اول P0، سپس P1؛ هر اصلاح با regression test و شاهد دقیق.
7. تست نهایی فقط serial توسط integrator؛ هیچ عملیات مالی واقعی و هیچ remote release.
8. قبل از اعلام پایان، `05_SCRIPTS/validate_stage2_evidence.py <repo-root>` را اجرا و خروجی را ذخیره کن.
