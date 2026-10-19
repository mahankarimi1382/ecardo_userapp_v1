# eCardo Financial Content Style Guide & Glossary (U034)

**Document Version:** 1.0  
**Target App Version:** eCardo v1.0.180+180  
**Locales Supported:** 6 (`en`, `fa`, `ar`, `tr`, `ru`, `zh`)  
**Directionality:** LTR (`en`, `tr`, `ru`, `zh`), RTL (`fa`, `ar`)

---

## 1. Core Financial Principles (Invariants)

1. **No Fake Success:** A transaction whose state is pending, reconciling, or indeterminate must **never** be labeled as `Success`, colored green, or accompanied by a celebration animation.
2. **Authoritative Backend Ledger:** Financial amounts, account balances, conversion quotes, and crypto deposit addresses are authoritative only when validated by the backend server. The UI client is an interface, never the ultimate ledger authority.
3. **Explicit Precision:** Never truncate currencies using binary floating-point floats. Decimal currencies are formatted strictly to their designated precision:
   - **Toman (IRT) / Rial (IRR):** 0 decimal places (integers only), formatted with thousand separators (`1,500,000 تومان`).
   - **Major Fiat (USD, EUR, GBP, AED, TRY):** 2 decimal places (`$120.50`, `€95.00`).
   - **USDT (TRC-20):** Exact atomic units; up to 6 decimal places (`1.001 USDT`, never rounded to `1.00`).
   - **Bitcoin (BTC):** 8 decimal places.
4. **Fail-Closed Security:** In the absence of server confirmation or network availability, money movements fail gracefully with distinct retry mechanisms.

---

## 2. Multilingual Terminology Matrix

| Financial Concept | English (`en`) | Persian (`fa`) | Arabic (`ar`) | Turkish (`tr`) | Russian (`ru`) | Chinese (`zh`) |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Main Wallet** | Main Wallet | کیف پول اصلی | المحفظة الرئيسية | Ana Cüzdan | Основной кошелек | 主钱包 |
| **Available Balance**| Available Balance | موجودی قابل استفاده | الرصيد المتاح | Kullanılabilir Bakiye | Доступный баланс | 可用余额 |
| **Total Balance** | Total Balance | موجودی کل | إجمالي الرصيد | Toplam Bakiye | Общий баланс | 总资产 |
| **Deposit / Add** | Add Money / Deposit | افزایش موجودی | إيداع أموال | Para Yükle | Пополнить | 充值 / 入金 |
| **Withdraw / Cash Out**| Withdraw / Cash Out | برداشت وجه | سحب أموال | Para Çek | Вывод средств | 提现 / 出金 |
| **Transfer** | Transfer | انتقال وجه | تحويل أموال | Para Transferi | Перевод | 转账 |
| **Exchange** | Exchange | تبدیل ارز | تبادل العملات | Döviz Çevir | Обмен валют | 货币兑换 |
| **Virtual Card** | Virtual Card | کارت مجازی | بطاقة افتراضية | Sanal Kart | Виртуальная карта | 虚拟卡 |
| **Crypto Wallet** | Crypto Wallet | کیف‌پول رمزارز | محفظة العملات المشفرة | Kripto Cüzdanı | Криптокошелек | 加密货币钱包 |
| **Transaction Ref** | Transaction Reference | شناسه رهگیری | رمز المعاملة | İşlem Referansı | Код транзакции | 交易单号 |
| **Fee** | Transaction Fee | کارمزد تراکنش | رسوم المعاملة | İşlem Ücreti | Комиссия | 手续费 |
| **Rate** | Exchange Rate | نرخ تبدیل | سعر الصرف | Döviz Kuru | Курс обмена | 汇率 |
| **Quote Expiry** | Quote Expires In | اعتبار نرخ تا | تنتهي صلاحية السعر في | Fiyat Geçerlilik Süresi | Курс действует до | 报价有效期至 |
| **Beneficiary** | Saved Beneficiary | مخاطب ذخیره‌شده | المستفيد المحفوظ | Kayıtlı Alıcı | Сохраненный получатель | 已存收款人 |
| **Pending** | Pending Verification | در انتظار بررسی | قيد المعالجة | İşlemde / Beklemede | В обработке | 处理中 |
| **Success** | Successful | موفق | مكتملة بنجاح | Başarılı | Успешно | 成功 |
| **Failed** | Failed | ناموفق | غير ناجحة | Başarısız | Отклонено | 失败 |
| **Reconciling** | Reconciling On-Chain | در حال نهایی‌سازی زنجیره | قيد التسوية في الشبكة | Zincirde Uzlaştırılıyor | Подтверждение в сети | 链上确认中 |

---

## 3. Microcopy Guidelines for Critical States

### 3.1. Recipient Lookup (Transfer Flow)
- **Verifying State:**
  - `en`: *Verifying recipient account...*
  - `fa`: *در حال استعلام حساب مقصد...*
  - `ar`: *جاري التحقق من حساب المستلم...*
- **Verified State:**
  - `en`: *Verified Account: [Recipient Name]*
  - `fa`: *حساب تاییدشده: [نام گیرنده]*
  - `ar`: *حساب موثق: [اسم المستلم]*
- **Not Found State:**
  - `en`: *No recipient found with this account number*
  - `fa`: *کاربری با این شماره حساب یافت نشد*
  - `ar`: *لم يتم العثور على مستخدم برقم الحساب هذا*

### 3.2. Rate Lock & Countdown (Exchange Flow)
- **Active Quote:** *Rate guaranteed for [SS]s* (Color: Mint Emerald / Theme Primary)
- **Expiring Quote (<15s):** *Quote expiring soon* (Color: Amber / Warning)
- **Expired Quote:** *Quote expired. Tap to refresh live rate.* (Action: Swipe button disabled, user must refresh)

### 3.3. Card Controls & Security (Virtual Card Flow)
- **Card Active:** *Card is active and ready for online payments*
- **Card Frozen:** *Card is frozen. All incoming transactions will be declined.*
- **Dynamic OTP:** *Valid for [MM:SS]. Never share this code with anyone.*

### 3.4. Crypto Deposit Safeguards (TRC-20 USDT)
- **Network Notice:** *Deposit USDT exclusively via the TRON (TRC-20) network. Deposits via other networks cannot be recovered.*
- **Confirmation Requirement:** *Requires a minimum of 19 network block confirmations before ledger credit.*
- **Verification Label:** *Checksum-verified TRON address* (Scoped strictly to address checksum, never implying private key proof).

---

## 4. Typography & Layout Specifications

- **Monospace Strings:** All transaction IDs, wallet addresses, and OTP codes must use `TextStyle(fontFamily: 'monospace', letterSpacing: 1.0)`.
- **Text Scaling:** Critical labels and amounts must tolerate accessibility text scaling up to 1.5× without clipping. Use `FittedBox(fit: BoxFit.scaleDown)` or `Flexible` with `TextOverflow.ellipsis`.
- **Bidirectionality (RTL):** Persian and Arabic interfaces must mirror horizontal flow (start-to-end), flip directional chevrons (`Icons.arrow_forward` -> `Icons.arrow_back` where contextually appropriate), but keep numeric amounts and currency symbols in canonical order.
