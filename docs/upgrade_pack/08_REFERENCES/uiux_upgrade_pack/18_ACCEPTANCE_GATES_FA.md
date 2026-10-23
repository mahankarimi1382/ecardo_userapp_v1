# دروازه‌های پذیرش UI/UX

هر page/feature فقط وقتی Done است که:
1. Route واقعی و owner مشخص است؛ API/service/controller dependency ثبت شده.
2. هیچ mock data یا CTA بی‌عمل در release path نیست.
3. Loading, empty, error, offline, disabled, pending, success, failed و unknown state متناسب feature تعریف شده‌اند.
4. از tokens/components موجود استفاده شده یا استثنا ثبت شده.
5. مبلغ، کارمزد، rate، network، destination و status از منبع authority می‌آیند.
6. 6 locale، RTL/LTR و long text تست شده‌اند.
7. حداقل target، contrast، screen reader و large text بررسی شده‌اند.
8. widget/unit test موجود؛ critical flow integration test و selected golden دارند.
9. performance قبل/بعد با profile مناسب ثبت شده؛ package یا effect تازه دلیل دارد.
10. screenshots after، test output، analyzer result و risk notes به PR/commit لینک شده‌اند.

## P0 gate
- هیچ موفقیت کاذب؛ هیچ مبلغ یا آدرس جعلی؛ no double-submit; unknown status safe;
- no sensitive data in screenshot/log/analytics;
- no blocking accessibility issue in transaction path.

## Visual regression gate
- هر golden update باید قبل/بعد + دلیل طراحی داشته باشد.
- تغییرات font rendering/OS baseline توضیح داده شود.
- goldenها فقط با approve owner مرکزی update شوند.

## Release gate
- exact SHA, app version/build, CI run, APK artifact, screenshot matrix and test counts align.
- release/deploy only with explicit approval; UI task does not authorize release.
