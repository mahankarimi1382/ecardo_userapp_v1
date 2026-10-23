# عامل تخصصی D — QA / Evidence / Regression

هدف: طرح تست رگرسیون و اعتبارسنجی شواهد.

- از CONTRACT_REGISTRY, ISSUE_REGISTER و inventory واقعی استفاده کن؛ تست‌ها را به contract, route, flow و issue IDs وصل کن.
- تأکید بر negative paths: timeout، malformed/null response، 401/403، expired quote، insufficient funds، duplicate action، unknown transaction status، offline/reconnect و locale/precision.
- هیچ دادهٔ حساس در fixture/log/screenshot ذخیره نکن؛ فقط synthetic data.
- همهٔ commandها و exit codeها را ثبت کن؛ تست اجرا نشده را `NOT_RUN` بگذار.
- روی shared worktree آزمون Flutter موازی اجرا نکن؛ اجرای نهایی را Integrator به‌صورت سریال انجام دهد.
- خروجی: TEST_EVIDENCE.csv، پوشش تست، blockerها و لیست تست‌های نیازمند sandbox/backend.
