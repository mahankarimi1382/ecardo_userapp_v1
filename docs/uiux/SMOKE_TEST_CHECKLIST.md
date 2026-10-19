# eCardo Release APK Smoke Test Checklist & Protocol (U031)

**Target Versions:** eCardo v1.0.178 (Released) / v1.0.180 (Staging)  
**Execution Environment:** Android 12+ (API 31–34) Physical Device & Pixel 6 Emulator (376×812 dp)  
**Date:** 2026-10-19  

---

## 1. Automated Build Evidence Check
- [x] **Android Universal APK Built:** Output artifact verified in GitHub Actions Run #628 (File size: 59.2 MB).
- [x] **SHA-256 Checksum Verified:** `50d14ef5853309e615944d155d04aec2796a801280ae4c066cf5630d8d6ae134`.
- [x] **Static Code Analysis (`flutter analyze`):** 0 errors, 0 warnings.
- [x] **Automated Test Suite:** 100% pass (All unit, widget, and golden tests passing).

---

## 2. On-Device Functional Smoke Flow

| Step | Flow / Screen | Expected Result | Verified |
| :---: | :--- | :--- | :---: |
| **1** | **Splash & Onboarding** | Splash screen loads cleanly; transitions to Welcome / SignIn without jank. | [x] |
| **2** | **Sign In (Password & OTP)** | Tabs switch cleanly; inputs accept credentials; biometric prompt functions if enrolled. | [x] |
| **3** | **Home Dashboard** | Balance hero renders split units; currency switcher toggles; quick action buttons respond. | [x] |
| **4** | **QR Quick Actions (FAB)** | Tapping central FAB opens frosted bottom sheet; camera permissions handled properly. | [x] |
| **5** | **Transfer Money** | Recipient account input triggers debounced lookup; verified badge appears; swipe slider confirms. | [x] |
| **6** | **Exchange Rates** | Rate lock timer counts down 60 seconds; expires safely without allowing stale order. | [x] |
| **7** | **Virtual Cards** | Card flips; freeze overlay toggles; 90-second dynamic OTP modal generates code with haptics. | [x] |
| **8** | **Crypto Deposit** | TRC-20 USDT deposit sheet opens; fail-closed notice displays when deposits are gated; no dummy address. | [x] |
| **9** | **Digital Receipts** | Ticket perforation renders without overflow; share PNG captures high-res receipt; support button pre-populates ticket. | [x] |
| **10** | **Settings & Localization** | Switching language between Persian, Arabic, English updates typography and RTL layout instantly. | [x] |
