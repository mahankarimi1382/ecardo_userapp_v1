// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get comment_common_maintenance => '==== Maintenance ====';

  @override
  String get maintenanceTitle => 'تحت الصيانة';

  @override
  String get maintenanceSubtitle =>
      'نقوم حاليًا بإجراء صيانة مجدولة لتحسين تجربتك.';

  @override
  String get comment_common_alert_bottom_sheet =>
      '==== Alert Bottom Sheet ====';

  @override
  String get alertBottonSheetConfirmButton => 'تأكيد';

  @override
  String get alertBottonSheetCancelButton => 'إلغاء';

  @override
  String get comment_all_controller_load_Error =>
      '==== All Controller Load Error ====';

  @override
  String get allControllerLoadError => 'حدث خطأ ما!';

  @override
  String get comment_common_exit_application => '==== Exit Application ====';

  @override
  String get exitApplicationTitle => 'الخروج من التطبيق';

  @override
  String get exitApplicationMessage =>
      'هل أنت متأكد أنك تريد الخروج من التطبيق؟';

  @override
  String get comment_common_dropdown => '==== Common Dropdown ====';

  @override
  String get commonDropdownSelectGender => 'اختر الجنس';

  @override
  String get commonDropdownGender => 'الجنس';

  @override
  String get commonDropdownGenderNotFound => 'الجنس غير موجود';

  @override
  String get commonDropdownMale => 'ذكر';

  @override
  String get commonDropdownFemale => 'أنثى';

  @override
  String get commonDropdownOther => 'آخر';

  @override
  String get comment_welcome => '==== Welcome Screen ====';

  @override
  String get welcomeTitle => 'مرحباً بك في Qunzo';

  @override
  String get welcomeDescription =>
      'Qunzo تمكنك من إدارة متعددة للمحافظ والتحويلات الفورية والمعاملات الآمنة.';

  @override
  String get welcomeSignIn => 'تسجيل الدخول';

  @override
  String get welcomeCreateAccount => 'إنشاء حساب';

  @override
  String get comment_sign_in => '==== Sign In Screen ====';

  @override
  String get signInWelcomeBack => 'مرحباً بعودتك!';

  @override
  String get signInSubtitle => 'انضم وتحكم في أموالك اليوم';

  @override
  String get signInEmail => 'البريد الإلكتروني';

  @override
  String get signInPassword => 'كلمة المرور';

  @override
  String get signInForgotPassword => 'نسيت كلمة المرور';

  @override
  String get signInButton => 'تسجيل الدخول';

  @override
  String get signInNotRegistered => 'لم تقم بالتسجيل بعد؟ ';

  @override
  String get signInCreateAccount => 'إنشاء حساب';

  @override
  String get signInBiometricErrorFirstTime =>
      'أول تسجيل دخول باستخدام البريد الإلكتروني وكلمة المرور';

  @override
  String get signInBiometricErrorNotEnabled => 'التحقق البيومتري غير مفعل';

  @override
  String get signInRegistrationDisabled => 'التسجيل معطل';

  @override
  String get signInValidationEmailRequired => 'حقل البريد الإلكتروني مطلوب';

  @override
  String get signInValidationPasswordRequired => 'حقل كلمة المرور مطلوب';

  @override
  String get comment_two_factor_auth =>
      '==== Two Factor Authentication Screen ====';

  @override
  String get twoFactorAuthTitle => 'التحقق بخطوتين';

  @override
  String get twoFactorAuthSubtitle =>
      'أدخل الرمز من تطبيق Google Authenticator';

  @override
  String get twoFactorAuthEnterOtp => 'أدخل رمز التحقق';

  @override
  String get twoFactorAuthVerifyButton => 'تحقق';

  @override
  String get twoFactorAuthBackTo => 'العودة إلى؟ ';

  @override
  String get twoFactorAuthSignIn => 'تسجيل الدخول';

  @override
  String get twoFactorAuthOtpRequired => 'حقل رمز التحقق مطلوب';

  @override
  String get comment_forgot_password => '==== Forgot Password Screen ====';

  @override
  String get forgotPasswordTitle => 'إعادة تعيين كلمة المرور';

  @override
  String get forgotPasswordSubtitle =>
      'لا تقلق! يمكنك إعادة تعيين كلمة المرور. أدخل بريدك الإلكتروني.';

  @override
  String get forgotPasswordEmail => 'البريد الإلكتروني';

  @override
  String get forgotPasswordButton => 'نسيت كلمة المرور';

  @override
  String get forgotPasswordBackTo => 'العودة إلى؟ ';

  @override
  String get forgotPasswordSignIn => 'تسجيل الدخول';

  @override
  String get forgotPasswordEmailRequired => 'حقل البريد الإلكتروني مطلوب';

  @override
  String get comment_forgot_password_pin_verification =>
      '==== Forgot Password Pin Verification Screen ====';

  @override
  String get forgotPasswordPinVerifyTitle => 'تحقق البريد الإلكتروني';

  @override
  String get forgotPasswordPinOtpSent => 'تم إرسال رمز التحقق إلى ';

  @override
  String get forgotPasswordPinEnterOtp => 'أدخل رمز التحقق';

  @override
  String get forgotPasswordPinOtpCountdown => 'رمز التحقق خلال';

  @override
  String get forgotPasswordPinVerifyButton => 'تحقق من الرمز';

  @override
  String get forgotPasswordPinDidNotReceive => 'لم تستلم الرمز؟ ';

  @override
  String get forgotPasswordPinResend => 'إعادة إرسال';

  @override
  String get forgotPasswordPinOtpRequired => 'حقل رمز التحقق مطلوب';

  @override
  String get comment_reset_password => '==== Reset Password Screen ====';

  @override
  String get resetPasswordTitle => 'إعادة تعيين كلمة المرور';

  @override
  String get resetPasswordSubtitle => 'أدخل كلمة المرور الجديدة وتأكيدها.';

  @override
  String get resetPasswordPassword => 'كلمة المرور';

  @override
  String get resetPasswordConfirmPassword => 'تأكيد كلمة المرور';

  @override
  String get resetPasswordButton => 'إعادة تعيين';

  @override
  String get resetPasswordAlreadyHaveAccount => 'لديك حساب بالفعل؟ ';

  @override
  String get resetPasswordSignIn => 'تسجيل الدخول';

  @override
  String get resetPasswordValidationRequired => 'كلمة المرور مطلوبة';

  @override
  String get resetPasswordValidationMinLength =>
      'كلمة المرور يجب أن تكون 8 أحرف على الأقل';

  @override
  String get resetPasswordValidationConfirmRequired => 'يرجى تأكيد كلمة المرور';

  @override
  String get resetPasswordValidationMismatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get comment_auth_id_verification =>
      '==== Auth ID Verification Screen ====';

  @override
  String get authIdVerificationInvalidFieldType => 'نوع الحقل غير صالح';

  @override
  String get authIdVerificationUnknownFieldType => 'نوع حقل غير معروف: ';

  @override
  String get comment_camera_type_section => '==== Camera Type Section ====';

  @override
  String get cameraTypeBack => 'رجوع';

  @override
  String get cameraTypeNotAvailable => 'غير متاح';

  @override
  String get cameraTypeButton => 'الكاميرا';

  @override
  String get cameraTypeSkip => 'تخطي';

  @override
  String get comment_file_type_section => '==== File Type Section ====';

  @override
  String get fileTypeBack => 'رجوع';

  @override
  String get fileTypeNotAvailable => 'غير متاح';

  @override
  String get fileTypeChooseFile => 'اختر ملف';

  @override
  String get fileTypeSkip => 'تخطي';

  @override
  String get comment_front_camera_type_section =>
      '==== Front Camera Type Section ====';

  @override
  String get frontCameraTypeBack => 'رجوع';

  @override
  String get frontCameraTypeNotAvailable => 'غير متاح';

  @override
  String get frontCameraTypeButton => 'الكاميرا الأمامية';

  @override
  String get frontCameraTypeSkip => 'تخطي';

  @override
  String get comment_kyc_submission_section =>
      '==== KYC Submission Section ====';

  @override
  String get kycSubmissionIdVerification => 'التحقق من الهوية';

  @override
  String get kycSubmissionSubmit => 'إرسال';

  @override
  String get kycSubmissionNext => 'التالي';

  @override
  String get kycSubmissionReUpload => 'إعادة رفع';

  @override
  String get kycSubmissionRetake => 'إعادة التقاط';

  @override
  String get comment_email_screen => '==== Email Screen ====';

  @override
  String get emailScreenCreateAccount => 'إنشاء حسابك';

  @override
  String get emailScreenSubtitle => 'انضم وتحكم في أموالك اليوم';

  @override
  String get emailScreenEmail => 'البريد الإلكتروني';

  @override
  String get emailScreenContinue => 'متابعة';

  @override
  String get emailScreenAlreadyHaveAccount => 'لديك حساب بالفعل؟ ';

  @override
  String get emailScreenSignIn => 'تسجيل الدخول';

  @override
  String get emailScreenEmailRequired => 'يرجى إدخال البريد الإلكتروني';

  @override
  String get comment_personal_info_screen => '==== Personal Info Screen ====';

  @override
  String get personalInfoTitle => 'معلوماتك';

  @override
  String get personalInfoSubtitle => 'أدخل معلوماتك القانونية للمتابعة.';

  @override
  String get personalInfoFirstName => 'الاسم الأول';

  @override
  String get personalInfoLastName => 'الاسم الأخير';

  @override
  String get personalInfoUserName => 'اسم المستخدم';

  @override
  String get personalInfoCountry => 'البلد';

  @override
  String get personalInfoSelectCountry => 'اختر البلد';

  @override
  String get personalInfoPhoneNo => 'رقم الهاتف';

  @override
  String get personalInfoReferralCode => 'رمز الإحالة';

  @override
  String get personalInfoContinue => 'متابعة';

  @override
  String get personalInfoValidationFirstNameRequired => 'الاسم الأول مطلوب';

  @override
  String get personalInfoValidationLastNameRequired => 'الاسم الأخير مطلوب';

  @override
  String get personalInfoValidationUserNameRequired => 'اسم المستخدم مطلوب';

  @override
  String get personalInfoValidationCountryRequired => 'البلد مطلوب';

  @override
  String get personalInfoValidationPhoneRequired => 'رقم الهاتف مطلوب';

  @override
  String get personalInfoValidationReferralCodeRequired => 'رمز الإحالة مطلوب';

  @override
  String get personalInfoValidationGenderRequired => 'الجنس مطلوب';

  @override
  String get comment_setup_password_screen => '==== Setup Password Screen ====';

  @override
  String get setupPasswordTitle => 'إعداد كلمة المرور';

  @override
  String get setupPasswordSubtitle => 'أنشئ كلمة مرور قوية وأكدها';

  @override
  String get setupPasswordPassword => 'كلمة المرور';

  @override
  String get setupPasswordConfirmPassword => 'تأكيد كلمة المرور';

  @override
  String get setupPasswordAgreeTerms => 'أوافق على ';

  @override
  String get setupPasswordTermsConditions => 'الشروط والأحكام';

  @override
  String get setupPasswordButton => 'إعداد كلمة المرور';

  @override
  String get setupPasswordValidationRequired => 'كلمة المرور مطلوبة';

  @override
  String get setupPasswordValidationMinLength =>
      'كلمة المرور يجب أن تكون 8 أحرف على الأقل';

  @override
  String get setupPasswordValidationConfirmRequired => 'يرجى تأكيد كلمة المرور';

  @override
  String get setupPasswordValidationMismatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get setupPasswordValidationTermsRequired =>
      'يرجى الموافقة على الشروط والأحكام';

  @override
  String get comment_sign_up_status_screen => '==== Sign Up Status Screen ====';

  @override
  String get signUpStatusTitle => 'حالتك الحالية';

  @override
  String get signUpStatusSubtitle =>
      'عملية سريعة من 4 خطوات للحفاظ على أمان حساب Qunzo الخاص بك';

  @override
  String get signUpStatusStep => 'الخطوة';

  @override
  String get signUpStatusEmailVerification => 'التحقق من البريد الإلكتروني';

  @override
  String get signUpStatusSetupPassword => 'إعداد كلمة المرور';

  @override
  String get signUpStatusPersonalInfo => 'المعلومات الشخصية';

  @override
  String get signUpStatusVerification => 'التحقق';

  @override
  String get signUpStatusInReview => 'قيد المراجعة';

  @override
  String get signUpStatusRejected => 'مرفوض';

  @override
  String get signUpStatusNoReason => 'لم يتم تقديم سبب';

  @override
  String get signUpStatusNextStep => 'الخطوة التالية';

  @override
  String get signUpStatusSubmitAgain => 'إرسال مرة أخرى';

  @override
  String get signUpStatusDashboard => 'لوحة التحكم';

  @override
  String get signUpStatusBack => 'رجوع';

  @override
  String get signUpStatusErrorProcessing =>
      'خطأ في معالجة الخطوة التالية. حاول مرة أخرى.';

  @override
  String get signUpStatusVerificationTypeEmpty => 'نوع التحقق فارغ!';

  @override
  String get signUpStatusErrorLoadingTypes =>
      'خطأ في تحميل أنواع التحقق. حاول مرة أخرى.';

  @override
  String get signUpStatusDropdownTwoVerificationNotFound =>
      'نوع التحقق غير موجود';

  @override
  String get comment_verify_email_screen => '==== Verify Email Screen ====';

  @override
  String get verifyEmailTitle => 'تحقق البريد الإلكتروني';

  @override
  String get verifyEmailOtpSent => 'تم إرسال رمز التحقق إلى ';

  @override
  String get verifyEmailEnterOtp => 'أدخل رمز التحقق';

  @override
  String get verifyEmailResendAvailable => 'يمكن إعادة الإرسال بعد';

  @override
  String get verifyEmailRequestNewOtp => 'يمكنك طلب رمز تحقق جديد الآن';

  @override
  String get verifyEmailButton => 'تحقق البريد الإلكتروني';

  @override
  String get verifyEmailDidNotReceive => 'لم تستلم الرمز؟ ';

  @override
  String get verifyEmailResend => 'إعادة إرسال';

  @override
  String get verifyEmailOtpRequired => 'حقل رمز التحقق مطلوب';

  @override
  String get comment_add_money_screen => '==== Add Money Screen ====';

  @override
  String get addMoneyTitle => 'إضافة أموال';

  @override
  String get addMoneyBalance => 'الرصيد';

  @override
  String get addMoneyHistory => 'سجل إضافة الأموال';

  @override
  String get addMoneyWalletsNotFound => 'المحافظ غير موجودة';

  @override
  String get comment_add_money_amount_step => '==== Add Money Amount Step ====';

  @override
  String get addMoneyGateway => 'بوابة الدفع';

  @override
  String get addMoneyGatewayNotFound => 'بوابة الدفع غير موجودة';

  @override
  String get addMoneySelectGateway => 'اختر بوابة الدفع';

  @override
  String get addMoneyCharge => 'الرسوم:';

  @override
  String get addMoneyAmount => 'المبلغ';

  @override
  String get addMoneyMin => 'الحد الأدنى';

  @override
  String get addMoneyMax => 'والحد الأقصى';

  @override
  String get addMoneyWriteHere => 'اكتب هنا...';

  @override
  String get addMoneyAddMoneyButton => 'إضافة أموال';

  @override
  String get comment_add_money_pending_step =>
      '==== Add Money Pending Step ====';

  @override
  String get addMoneyPendingTitle => 'عملية الإيداع الخاصة بك\nقيد الانتظار';

  @override
  String get addMoneyPendingAmount => 'المبلغ';

  @override
  String get addMoneyPendingTransactionId => 'رقم المعاملة';

  @override
  String get addMoneyPendingWalletName => 'اسم المحفظة';

  @override
  String get addMoneyPendingPaymentMethod => 'طريقة الدفع';

  @override
  String get addMoneyPendingCharge => 'الرسوم';

  @override
  String get addMoneyPendingType => 'النوع';

  @override
  String get addMoneyPendingFinalAmount => 'المبلغ النهائي';

  @override
  String get addMoneyPendingDepositAgain => 'إيداع مرة أخرى';

  @override
  String get addMoneyPendingBackHome => 'العودة للرئيسية';

  @override
  String get comment_add_money_review_step => '==== Add Money Review Step ====';

  @override
  String get addMoneyReviewTitle => 'مراجعة التفاصيل';

  @override
  String get addMoneyReviewAmount => 'المبلغ';

  @override
  String get addMoneyReviewWalletName => 'اسم المحفظة';

  @override
  String get addMoneyReviewPaymentMethod => 'طريقة الدفع';

  @override
  String get addMoneyReviewCharge => 'الرسوم';

  @override
  String get addMoneyReviewTotal => 'الإجمالي';

  @override
  String get addMoneyReviewBack => 'رجوع';

  @override
  String get addMoneyReviewConfirm => 'تأكيد';

  @override
  String get addMoneyReviewNoFileUploaded => 'لم يتم رفع ملف';

  @override
  String get comment_add_money_success_step =>
      '==== Add Money Success Step ====';

  @override
  String get addMoneySuccessTitle => 'تم إيداع الأموال بنجاح!';

  @override
  String get addMoneySuccessAmount => 'المبلغ';

  @override
  String get addMoneySuccessTransactionId => 'رقم المعاملة';

  @override
  String get addMoneySuccessCharge => 'الرسوم';

  @override
  String get addMoneySuccessTransactionType => 'نوع المعاملة';

  @override
  String get addMoneySuccessFinalAmount => 'المبلغ النهائي';

  @override
  String get addMoneySuccessAddMoneyAgain => 'إضافة أموال مرة أخرى';

  @override
  String get addMoneySuccessBackHome => 'العودة للرئيسية';

  @override
  String get comment_add_money_history => '==== Add Money History ====';

  @override
  String get addMoneyHistoryTitle => 'سجل إضافة الأموال';

  @override
  String get comment_add_money_filter_bottom_sheet =>
      '==== Add Money Filter Bottom Sheet ====';

  @override
  String get addMoneyFilterTransactionId => 'رقم المعاملة';

  @override
  String get addMoneyFilterStatus => 'الحالة';

  @override
  String get addMoneyFilterSuccess => 'ناجح';

  @override
  String get addMoneyFilterPending => 'قيد الانتظار';

  @override
  String get addMoneyFilterFailed => 'فشل';

  @override
  String get addMoneyFilterButton => 'تصفية';

  @override
  String get addMoneyFilterReset => 'إعادة ضبط';

  @override
  String get comment_create_beneficiary_screen =>
      '==== Create Beneficiary Screen ====';

  @override
  String get createBeneficiaryTitle => 'إنشاء جديد';

  @override
  String get createBeneficiaryAccountNumber => 'رقم الحساب';

  @override
  String get createBeneficiaryNickName => 'الاسم المستعار';

  @override
  String get createBeneficiaryCreateButton => 'إنشاء';

  @override
  String get createBeneficiaryValidationAccountNumber => 'أدخل رقم الحساب';

  @override
  String get createBeneficiaryValidationNickName => 'أدخل الاسم المستعار';

  @override
  String get comment_update_beneficiary_screen =>
      '==== Update Beneficiary Screen ====';

  @override
  String get updateBeneficiaryTitle => 'تحديث';

  @override
  String get updateBeneficiaryNickName => 'الاسم المستعار';

  @override
  String get updateBeneficiaryUpdateButton => 'تحديث';

  @override
  String get updateBeneficiaryValidationNickName => 'أدخل الاسم المستعار';

  @override
  String get comment_account_user_types => '==== Account User Types ====';

  @override
  String get accountUserMerchant => 'تاجر';

  @override
  String get accountUserBeneficiary => 'مستفيد';

  @override
  String get accountUserAgent => 'وكيل';

  @override
  String get comment_cash_out_screen => '==== Cash Out Screen ====';

  @override
  String get cashOutTitle => 'سحب أموال من الوكيل';

  @override
  String get cashOutHistory => 'سجل السحب';

  @override
  String get comment_cash_out_amount_step => '==== Cash Out Amount Step ====';

  @override
  String get cashOutAgentId => 'معرف الوكيل';

  @override
  String get cashOutAmount => 'المبلغ';

  @override
  String get cashOutMin => 'الحد الأدنى';

  @override
  String get cashOutMax => 'والحد الأقصى';

  @override
  String get cashOutButton => 'سحب';

  @override
  String get cashOutSavedAgents => 'الوكلاء المحفوظون';

  @override
  String get cashOutAgents => 'وكلاء';

  @override
  String get cashOutAddAgent => 'إضافة وكيل';

  @override
  String get cashOutAid => 'معرف الوكيل:';

  @override
  String get cashOutQrInvalidDigits =>
      'رمز QR غير صالح. يجب أن يكون معرف الوكيل أرقاماً فقط.';

  @override
  String get cashOutQrInvalidPrefix =>
      'رمز QR غير صالح. بادئة معرف الوكيل غير موجودة.';

  @override
  String get cashOutDeleteConfirm => 'هل أنت متأكد؟';

  @override
  String get cashOutDeleteMessage => 'هل تريد حذف هذا الوكيل؟';

  @override
  String get cashOutDeleteButton => 'حذف';

  @override
  String get cashOutCancelButton => 'إلغاء';

  @override
  String get comment_cash_out_review_step => '==== Cash Out Review Step ====';

  @override
  String get cashOutReviewTitle => 'مراجعة التفاصيل';

  @override
  String get cashOutReviewAmount => 'المبلغ';

  @override
  String get cashOutReviewWallet => 'المحفظة';

  @override
  String get cashOutReviewAgentAccount => 'حساب الوكيل';

  @override
  String get cashOutReviewCharge => 'الرسوم';

  @override
  String get cashOutReviewTotalAmount => 'المبلغ الإجمالي';

  @override
  String get cashOutReviewBack => 'رجوع';

  @override
  String get cashOutReviewConfirm => 'تأكيد';

  @override
  String get comment_cash_out_success_step => '==== Cash Out Success Step ====';

  @override
  String get cashOutSuccessTitle => 'تم السحب بنجاح!';

  @override
  String get cashOutSuccessAmount => 'المبلغ';

  @override
  String get cashOutSuccessTransactionId => 'رقم المعاملة';

  @override
  String get cashOutSuccessWalletName => 'اسم المحفظة';

  @override
  String get cashOutSuccessPaymentMethod => 'طريقة الدفع';

  @override
  String get cashOutSuccessCharge => 'الرسوم';

  @override
  String get cashOutSuccessType => 'النوع';

  @override
  String get cashOutSuccessFinalAmount => 'المبلغ النهائي';

  @override
  String get cashOutSuccessCashOutAgain => 'سحب مرة أخرى';

  @override
  String get cashOutSuccessBackHome => 'العودة للرئيسية';

  @override
  String get comment_cash_out_wallets_section =>
      '==== Cash Out Wallets Section ====';

  @override
  String get cashOutWalletsBalance => 'الرصيد';

  @override
  String get cashOutWalletsNotFound => 'المحافظ غير موجودة';

  @override
  String get comment_cash_out_history => '==== Cash Out History ====';

  @override
  String get cashOutHistoryTitle => 'سجل السحب';

  @override
  String get comment_cash_out_filter_bottom_sheet =>
      '==== Cash Out Filter Bottom Sheet ====';

  @override
  String get cashOutFilterTransactionId => 'رقم المعاملة';

  @override
  String get cashOutFilterStatus => 'الحالة';

  @override
  String get cashOutFilterButton => 'تصفية';

  @override
  String get cashOutFilterReset => 'إعادة ضبط';

  @override
  String get comment_exchange_screen => '==== Exchange Screen ====';

  @override
  String get exchangeTitle => 'تبديل المحفظة';

  @override
  String get exchangeHistory => 'سجل التبديل';

  @override
  String get comment_exchange_amount_step => '==== Exchange Amount Step ====';

  @override
  String get exchangeAmount => 'المبلغ';

  @override
  String get exchangeMin => 'الحد الأدنى';

  @override
  String get exchangeMax => 'والحد الأقصى';

  @override
  String get exchangeButton => 'تبديل';

  @override
  String get comment_exchange_review_step => '==== Exchange Review Step ====';

  @override
  String get exchangeReviewTitle => 'مراجعة التفاصيل';

  @override
  String get exchangeReviewAmount => 'المبلغ';

  @override
  String get exchangeReviewFromWallet => 'من محفظة';

  @override
  String get exchangeReviewCharge => 'الرسوم';

  @override
  String get exchangeReviewTotalAmount => 'المبلغ الإجمالي';

  @override
  String get exchangeReviewToWallet => 'إلى محفظة';

  @override
  String get exchangeReviewExchangeRate => 'سعر الصرف';

  @override
  String get exchangeReviewExchangeAmount => 'مبلغ التبديل';

  @override
  String get exchangeReviewBack => 'رجوع';

  @override
  String get exchangeReviewConfirm => 'تأكيد';

  @override
  String get comment_exchange_success_step => '==== Exchange Success Step ====';

  @override
  String get exchangeSuccessTitle => 'تم التبديل بنجاح!';

  @override
  String get exchangeSuccessAmount => 'المبلغ';

  @override
  String get exchangeSuccessTransactionId => 'رقم المعاملة';

  @override
  String get exchangeSuccessPayAmount => 'المبلغ المدفوع';

  @override
  String get exchangeSuccessConvertedAmount => 'المبلغ المحول';

  @override
  String get exchangeSuccessCharge => 'الرسوم';

  @override
  String get exchangeSuccessDate => 'التاريخ';

  @override
  String get exchangeSuccessFinalAmount => 'المبلغ النهائي';

  @override
  String get exchangeSuccessExchangeAgain => 'تبديل مرة أخرى';

  @override
  String get exchangeSuccessBackHome => 'العودة للرئيسية';

  @override
  String get comment_exchange_wallet_section =>
      '==== Exchange Wallet Section ====';

  @override
  String get exchangeWalletBalance => 'الرصيد';

  @override
  String get exchangeWalletsNotFound => 'المحافظ غير موجودة';

  @override
  String get comment_exchange_wallet_to_wallet =>
      '==== Exchange Wallet To Wallet ====';

  @override
  String get exchangeWalletToWallet => 'من محفظة إلى محفظة';

  @override
  String get exchangeFromWallet => 'من محفظة';

  @override
  String get exchangeToWallet => 'إلى محفظة';

  @override
  String get exchangeRate => 'سعر الصرف: ';

  @override
  String get exchangeWalletToWalletWalletsNotFound => 'المحافظ غير موجودة';

  @override
  String get comment_exchange_history => '==== Exchange History ====';

  @override
  String get exchangeHistoryTitle => 'سجل التبديل';

  @override
  String get comment_exchange_filter_bottom_sheet =>
      '==== Exchange Filter Bottom Sheet ====';

  @override
  String get exchangeFilterTransactionId => 'رقم المعاملة';

  @override
  String get exchangeFilterStatus => 'الحالة';

  @override
  String get exchangeFilterButton => 'تصفية';

  @override
  String get exchangeFilterReset => 'إعادة ضبط';

  @override
  String get comment_gift_code_screen => '==== Gift Code Screen ====';

  @override
  String get giftCodeTitle => 'رمز هدية';

  @override
  String get giftCodeCreateGift => 'إنشاء هدية';

  @override
  String get comment_create_gift_amount_step =>
      '==== Create Gift Amount Step ====';

  @override
  String get createGiftAmount => 'المبلغ';

  @override
  String get createGiftMin => 'الحد الأدنى';

  @override
  String get createGiftMax => 'والحد الأقصى';

  @override
  String get createGiftButton => 'إنشاء هدية';

  @override
  String get comment_create_gift_review_section =>
      '==== Create Gift Review Section ====';

  @override
  String get createGiftReviewTitle => 'مراجعة التفاصيل';

  @override
  String get createGiftReviewAmount => 'المبلغ';

  @override
  String get createGiftReviewWalletName => 'اسم المحفظة';

  @override
  String get createGiftReviewCharge => 'الرسوم';

  @override
  String get createGiftReviewTotalAmount => 'المبلغ الإجمالي';

  @override
  String get createGiftReviewBack => 'رجوع';

  @override
  String get createGiftReviewConfirm => 'تأكيد';

  @override
  String get comment_create_gift_success_step =>
      '==== Create Gift Success Step ====';

  @override
  String get createGiftSuccessTitle => 'تم إنشاء الهدية بنجاح!';

  @override
  String get createGiftSuccessAmount => 'المبلغ';

  @override
  String get createGiftSuccessCharge => 'الرسوم';

  @override
  String get createGiftSuccessFinalAmount => 'المبلغ النهائي';

  @override
  String get createGiftSuccessCreatedAt => 'تاريخ الإنشاء';

  @override
  String get createGiftSuccessCreateAgain => 'إنشاء رمز هدية مرة أخرى';

  @override
  String get createGiftSuccessBackHome => 'العودة للرئيسية';

  @override
  String get comment_create_gift_wallet_section =>
      '==== Create Gift Wallet Section ====';

  @override
  String get createGiftWalletBalance => 'الرصيد';

  @override
  String get createGiftWalletWalletsNotFound => 'المحافظ غير موجودة';

  @override
  String get comment_gift_code_header_section =>
      '==== Gift Code Header Section ====';

  @override
  String get giftCodeHeaderTitle => 'رمز هدية';

  @override
  String get giftCodeHeaderGiftRedeem => 'استبدال هدية';

  @override
  String get giftCodeHeaderMyGift => 'هديتي';

  @override
  String get giftCodeHeaderGiftRedeemHistory => 'سجل استبدال الهدايا';

  @override
  String get comment_gift_history => '==== Gift History ====';

  @override
  String get giftHistoryCreatedAt => 'تاريخ الإنشاء:';

  @override
  String get giftHistoryStatus => 'الحالة: ';

  @override
  String get giftHistoryClaimed => 'تم الاستلام';

  @override
  String get giftHistoryClaimable => 'قابل للاستلام';

  @override
  String get giftHistoryCodeCopied => 'تم نسخ رمز الهدية';

  @override
  String get comment_gift_history_filter_bottom_sheet =>
      '==== Gift History Filter Bottom Sheet ====';

  @override
  String get giftHistoryFilterGiftCode => 'رمز الهدية';

  @override
  String get giftHistoryFilterButton => 'تصفية';

  @override
  String get comment_gift_redeem_section => '==== Gift Redeem Section ====';

  @override
  String get giftRedeemGiftCode => 'رمز الهدية';

  @override
  String get giftRedeemButton => 'استبدال';

  @override
  String get giftRedeemValidation => 'يرجى إدخال رمز الهدية';

  @override
  String get comment_gift_redeem_history => '==== Gift Redeem History ====';

  @override
  String get giftRedeemHistoryTitle => 'سجل استبدالاتي';

  @override
  String get giftRedeemHistoryCreatedAt => 'تاريخ الإنشاء:';

  @override
  String get giftRedeemHistoryStatus => 'الحالة: ';

  @override
  String get giftRedeemHistoryClaimed => 'تم الاستلام';

  @override
  String get giftRedeemHistoryClaimable => 'قابل للاستلام';

  @override
  String get giftRedeemHistoryCodeCopied => 'تم نسخ رمز الهدية';

  @override
  String get comment_gift_redeem_filter_bottom_sheet =>
      '==== Gift Redeem Filter Bottom Sheet ====';

  @override
  String get giftRedeemFilterCode => 'الرمز';

  @override
  String get giftRedeemFilterButton => 'تصفية';

  @override
  String get giftRedeemFilterReset => 'إعادة ضبط';

  @override
  String get comment_drawer_section => '==== Drawer Section ====';

  @override
  String get drawerDashboard => 'لوحة التحكم';

  @override
  String get drawerMyWallets => 'محافظي';

  @override
  String get drawerAddMoney => 'إضافة أموال';

  @override
  String get drawerCashOut => 'سحب أموال';

  @override
  String get drawerBillPayments => 'دفع الفواتير';

  @override
  String get drawerVirtualCards => 'بطاقات افتراضية';

  @override
  String get drawerPaymentLinks => 'روابط الدفع';

  @override
  String get drawerMakePayment => 'إجراء دفعة';

  @override
  String get drawerTransfer => 'تحويل';

  @override
  String get drawerWithdraw => 'سحب';

  @override
  String get drawerExchange => 'تبديل';

  @override
  String get drawerInviting => 'دعوة';

  @override
  String get drawerGiftCard => 'بطاقة هدية';

  @override
  String get drawerP2pTrading => 'التجارة P2P';

  @override
  String get drawerKycVerification => 'يرجى التحقق من KYC الخاص بك!';

  @override
  String get comment_end_drawer_section => '==== End Drawer Section ====';

  @override
  String get endDrawerProfileSettings => 'إعدادات الملف الشخصي';

  @override
  String get endDrawerChangePassword => 'تغيير كلمة المرور';

  @override
  String get endDrawerAllNotification => 'جميع الإشعارات';

  @override
  String get endDrawerHelpSupport => 'المساعدة والدعم';

  @override
  String get endDrawerLanguage => 'اللغة';

  @override
  String get endDrawerBiometric => 'التحقق البيومتري';

  @override
  String get endDrawerSignOut => 'تسجيل الخروج';

  @override
  String get endDrawerLanguageNotFound => 'اللغة غير موجودة';

  @override
  String get endDrawerChooseLanguage => 'اختر اللغة';

  @override
  String get comment_recent_transaction_details =>
      '==== Recent Transaction Details ====';

  @override
  String get transactionDetailsTitle => 'تفاصيل المعاملة';

  @override
  String get transactionDetailsWallet => 'المحفظة';

  @override
  String get transactionDetailsCharge => 'الرسوم';

  @override
  String get transactionDetailsTransactionId => 'رقم المعاملة';

  @override
  String get transactionDetailsMethod => 'الطريقة';

  @override
  String get transactionDetailsTotalAmount => 'المبلغ الإجمالي';

  @override
  String get transactionDetailsStatus => 'الحالة';

  @override
  String get transactionDetailsDescription => 'الوصف';

  @override
  String get transactionStatusSuccess => 'ناجح';

  @override
  String get transactionStatusPending => 'قيد الانتظار';

  @override
  String get transactionStatusFailed => 'فشل';

  @override
  String get comment_wallet_details => '==== Wallet Details ====';

  @override
  String get walletDetailsHistory => 'السجل';

  @override
  String get walletDetailsAvailableBalance => 'الرصيد المتاح';

  @override
  String get walletDetailsTopUp => 'شحن';

  @override
  String get walletDetailsWithdraw => 'سحب';

  @override
  String get walletDetailsUserDepositNotEnabled => 'الإيداع غير مفعل للمستخدم';

  @override
  String get walletDetailsUserWithdrawNotEnabled => 'السحب غير مفعل للمستخدم';

  @override
  String get walletDetailsWalletsNotFound => 'المحافظ غير موجودة';

  @override
  String get comment_action_button_section => '==== Action Button Section ====';

  @override
  String get actionButtonTransfer => 'تحويل';

  @override
  String get actionButtonWithdraw => 'سحب';

  @override
  String get actionButtonPayment => 'دفع';

  @override
  String get actionButtonExchange => 'تبديل';

  @override
  String get actionButtonUserTransferNotEnabled => 'التحويل غير مفعل للمستخدم';

  @override
  String get actionButtonUserWithdrawNotEnabled => 'السحب غير مفعل للمستخدم';

  @override
  String get actionButtonUserPaymentNotEnabled => 'الدفع غير مفعل للمستخدم';

  @override
  String get actionButtonUserExchangeNotEnabled => 'التبديل غير مفعل للمستخدم';

  @override
  String get comment_my_wallet_section => '==== My Wallet Section ====';

  @override
  String get myWalletSectionTitle => 'محافظي';

  @override
  String get myWalletTopUp => 'شحن';

  @override
  String get myWalletWithdraw => 'سحب';

  @override
  String get myWalletUserDepositNotEnabled => 'الإيداع غير مفعل للمستخدم';

  @override
  String get myWalletUserWithdrawNotEnabled => 'السحب غير مفعل للمستخدم';

  @override
  String get comment_other_services_section =>
      '==== Other Services Section ====';

  @override
  String get otherServicesTitle => 'خدمات أخرى';

  @override
  String get otherServicesQrCode => 'رمز QR';

  @override
  String get otherServicesAddMoney => 'إضافة أموال';

  @override
  String get otherServicesCashOut => 'سحب أموال';

  @override
  String get otherServicesMakePayment => 'إجراء دفعة';

  @override
  String get otherServicesTransactions => 'المعاملات';

  @override
  String get otherServicesInvoice => 'فاتورة';

  @override
  String get otherServicesRequestMoney => 'طلب أموال';

  @override
  String get otherServicesGift => 'هدية';

  @override
  String get otherServicesWallets => 'محافظ';

  @override
  String get otherServicesWithdraw => 'سحب';

  @override
  String get otherServicesExchange => 'تبديل';

  @override
  String get otherServicesTransfer => 'تحويل';

  @override
  String get otherServicesInvite => 'دعوة';

  @override
  String get otherServicesBillPayment => 'دفع الفواتير';

  @override
  String get otherServicesVirtualCard => 'بطاقات افتراضية';

  @override
  String get otherServicesGiftCards => 'بطاقات الهدايا';

  @override
  String get otherServicesP2pTrading => 'تداول P2P';

  @override
  String get otherServicesPaymentLinks => 'روابط الدفع';

  @override
  String get otherServicesKycVerification => 'يرجى التحقق من KYC الخاص بك!';

  @override
  String get otherServicesUserGiftNotEnabled => 'الهدايا غير مفعلة للمستخدم';

  @override
  String get otherServicesUserDepositNotEnabled => 'الإيداع غير مفعل للمستخدم';

  @override
  String get otherServicesUserCashOutNotEnabled => 'السحب غير مفعل للمستخدم';

  @override
  String get otherServicesUserPaymentNotEnabled => 'الدفع غير مفعل للمستخدم';

  @override
  String get otherServicesUserRequestMoneyNotEnabled =>
      'طلب الأموال غير مفعل للمستخدم';

  @override
  String get otherServicesUserInvoiceNotEnabled =>
      'الفواتير غير مفعلة للمستخدم';

  @override
  String get comment_recent_transactions_section =>
      '==== Recent Transactions Section ====';

  @override
  String get recentTransactionsTitle => 'الأحدث';

  @override
  String get comment_section_header => '==== Section Header ====';

  @override
  String get sectionHeaderSeeAll => 'عرض الكل';

  @override
  String get comment_sign_up_bonus_popup => '==== Sign Up Bonus Popup ====';

  @override
  String get signUpBonusCongratulations => 'تهانينا!';

  @override
  String get signUpBonusReceived => 'لقد استلمت مكافأة';

  @override
  String get comment_user_profile_section => '==== User Profile Section ====';

  @override
  String get userProfileHello => 'مرحباً، 👋';

  @override
  String get userProfileUid => 'رقم المستخدم:';

  @override
  String get userProfileCopied => 'تم النسخ';

  @override
  String get comment_invoice_screen => '==== Invoice Screen ====';

  @override
  String get invoiceTitle => 'فاتورة';

  @override
  String get invoiceCreateInvoice => 'إنشاء فاتورة';

  @override
  String get invoiceAmount => 'المبلغ:';

  @override
  String get invoiceCharge => 'الرسوم:';

  @override
  String get invoiceStatus => 'الحالة: ';

  @override
  String get invoicePublished => 'منشور';

  @override
  String get invoiceDraft => 'مسودة';

  @override
  String get invoiceView => 'عرض';

  @override
  String get invoicePaid => 'مدفوع';

  @override
  String get invoiceUnpaid => 'غير مدفوع';

  @override
  String get comment_update_invoice => '==== Update Invoice ====';

  @override
  String get updateInvoiceTitle => 'تحديث الفاتورة';

  @override
  String get updateInvoiceItems => 'بنود الفاتورة';

  @override
  String get updateInvoiceAddItem => 'إضافة بند';

  @override
  String get updateInvoiceButton => 'تحديث الفاتورة';

  @override
  String get comment_update_invoice_add_item =>
      '==== Update Invoice Add Item ====';

  @override
  String get updateInvoiceItemName => 'اسم البند';

  @override
  String get updateInvoiceQuantity => 'الكمية';

  @override
  String get updateInvoiceUnitPrice => 'سعر الوحدة';

  @override
  String get updateInvoiceSubTotal => 'المجموع الفرعي';

  @override
  String get comment_update_invoice_information =>
      '==== Update Invoice Information ====';

  @override
  String get updateInvoiceInformationTitle => 'معلومات الفاتورة';

  @override
  String get updateInvoiceTo => 'إلى';

  @override
  String get updateInvoiceEmailAddress => 'البريد الإلكتروني';

  @override
  String get updateInvoiceAddress => 'العنوان';

  @override
  String get updateInvoiceWallet => 'المحفظة';

  @override
  String get updateInvoiceStatus => 'الحالة';

  @override
  String get updateInvoiceIssueDate => 'تاريخ الإصدار';

  @override
  String get updateInvoicePaymentStatus => 'حالة الدفع';

  @override
  String get updateInvoiceSelectWallet => 'اختر المحفظة';

  @override
  String get updateInvoiceSelectStatus => 'اختر الحالة';

  @override
  String get updateInvoiceSelectPaymentStatus => 'اختر حالة الدفع';

  @override
  String get updateInvoiceWalletNotFound => 'المحفظة غير موجودة';

  @override
  String get updateInvoiceStatusNotFound => 'الحالة غير موجودة';

  @override
  String get updateInvoicePaymentStatusNotFound => 'حالة الدفع غير موجودة';

  @override
  String get comment_invoice_status_options =>
      '==== Invoice Status Options ====';

  @override
  String get invoiceStatusDraft => 'مسودة';

  @override
  String get invoiceStatusPublished => 'منشور';

  @override
  String get invoiceStatusPaid => 'مدفوع';

  @override
  String get invoiceStatusUnpaid => 'غير مدفوع';

  @override
  String get comment_invoice_details => '==== Invoice Details ====';

  @override
  String get invoiceDetailsTitle => 'فاتورة';

  @override
  String get invoiceDetailsReference => 'المرجع:';

  @override
  String get invoiceDetailsIssued => 'تاريخ الإصدار:';

  @override
  String get invoiceDetailsName => 'الاسم';

  @override
  String get invoiceDetailsEmail => 'البريد الإلكتروني';

  @override
  String get invoiceDetailsCharge => 'الرسوم';

  @override
  String get invoiceDetailsAddress => 'العنوان';

  @override
  String get invoiceDetailsTotalAmount => 'المبلغ الإجمالي';

  @override
  String get invoiceDetailsStatus => 'الحالة';

  @override
  String get invoiceDetailsItemName => 'اسم البند';

  @override
  String get invoiceDetailsQuantity => 'الكمية';

  @override
  String get invoiceDetailsUnitPrice => 'سعر الوحدة';

  @override
  String get invoiceDetailsSubTotal => 'المجموع الفرعي';

  @override
  String get invoiceDetailsPayNow => 'ادفع الآن';

  @override
  String get invoiceDetailsPrintInvoice => 'طباعة الفاتورة';

  @override
  String get invoiceDetailsPaid => 'مدفوع';

  @override
  String get invoiceDetailsUnpaid => 'غير مدفوع';

  @override
  String get comment_invoice_pdf => '==== Invoice PDF ====';

  @override
  String get invoicePdfReference => 'المرجع:';

  @override
  String get invoicePdfIssued => 'تاريخ الإصدار:';

  @override
  String get invoicePdfPaid => 'مدفوع';

  @override
  String get invoicePdfUnpaid => 'غير مدفوع';

  @override
  String get invoicePdfTotalAmount => 'المبلغ الإجمالي:';

  @override
  String get invoicePdfAmount => 'المبلغ:';

  @override
  String get invoicePdfCharge => 'الرسوم:';

  @override
  String get invoicePdfItemName => 'اسم البند';

  @override
  String get invoicePdfQuantity => 'الكمية';

  @override
  String get invoicePdfUnitPrice => 'سعر الوحدة';

  @override
  String get invoicePdfSubtotal => 'المجموع الفرعي';

  @override
  String get invoicePdfSubtotalLabel => 'المجموع الفرعي: ';

  @override
  String get invoicePdfChargeLabel => 'الرسوم: ';

  @override
  String get invoicePdfTotalAmountLabel => 'المبلغ الإجمالي: ';

  @override
  String get invoicePdfThanks => 'شكراً لك على الشراء.';

  @override
  String get comment_create_invoice => '==== Create Invoice ====';

  @override
  String get createInvoiceTitle => 'إنشاء فاتورة';

  @override
  String get createInvoiceItems => 'بنود الفاتورة';

  @override
  String get createInvoiceAddItem => 'إضافة بند';

  @override
  String get createInvoiceButton => 'إنشاء فاتورة';

  @override
  String get createInvoiceStatusDraft => 'مسودة';

  @override
  String get comment_create_invoice_add_item_section =>
      '==== Create Invoice Add Item Section ====';

  @override
  String get createInvoiceAddItemSectionItemName => 'اسم البند';

  @override
  String get createInvoiceAddItemSectionQuantity => 'الكمية';

  @override
  String get createInvoiceAddItemSectionUnitPrice => 'سعر الوحدة';

  @override
  String get createInvoiceAddItemSectionSubTotal => 'المجموع الفرعي';

  @override
  String get comment_create_invoice_information_section =>
      '==== Create Invoice Information Section ====';

  @override
  String get createInvoiceInformationSectionTitle => 'معلومات الفاتورة';

  @override
  String get createInvoiceInformationSectionInvoiceTo => 'إلى';

  @override
  String get createInvoiceInformationSectionEmailAddress => 'البريد الإلكتروني';

  @override
  String get createInvoiceInformationSectionAddress => 'العنوان';

  @override
  String get createInvoiceInformationSectionWallet => 'المحفظة';

  @override
  String get createInvoiceInformationSectionStatus => 'الحالة';

  @override
  String get createInvoiceInformationSectionIssueDate => 'تاريخ الإصدار';

  @override
  String get createInvoiceInformationSectionWalletNotFound =>
      'المحافظ غير موجودة';

  @override
  String get createInvoiceInformationSectionWalletHint => 'اختر المحفظة';

  @override
  String get createInvoiceInformationSectionStatusTitle => 'الحالة';

  @override
  String get createInvoiceInformationSectionStatusNotFound =>
      'الحالة غير موجودة';

  @override
  String get createInvoiceInformationSectionStatusDraft => 'مسودة';

  @override
  String get createInvoiceInformationSectionStatusPublished => 'منشور';

  @override
  String get comment_make_payment_screen => '==== Make Payment Screen ====';

  @override
  String get makePaymentScreenTitle => 'إجراء دفعة';

  @override
  String get makePaymentScreenWalletsNotFound => 'المحافظ غير موجودة';

  @override
  String get makePaymentScreenBalance => 'الرصيد';

  @override
  String get makePaymentScreenHistory => 'سجل الدفعات';

  @override
  String get comment_make_payment_amount_step_section =>
      '==== Make Payment Amount Step Section ====';

  @override
  String get makePaymentAmountStepSectionMerchantId => 'معرف التاجر';

  @override
  String get makePaymentAmountStepSectionAmount => 'المبلغ';

  @override
  String get makePaymentAmountStepSectionMinLimit => 'الحد الأدنى';

  @override
  String get makePaymentAmountStepSectionMaxLimit => 'والحد الأقصى';

  @override
  String get makePaymentAmountStepSectionMakePaymentButton => 'إجراء دفعة';

  @override
  String get makePaymentAmountStepSectionSavedMerchantsButton =>
      'التجار المحفوظون';

  @override
  String get makePaymentAmountStepSectionInvalidQrCodeDigits =>
      'رمز QR غير صالح. يجب أن يكون معرف التاجر أرقاماً فقط.';

  @override
  String get makePaymentAmountStepSectionInvalidQrCodePrefix =>
      'رمز QR غير صالح. بادئة معرف التاجر غير موجودة.';

  @override
  String get makePaymentAmountStepSectionMerchantsTitle => 'التجار';

  @override
  String get makePaymentAmountStepSectionAddMerchant => 'إضافة تاجر';

  @override
  String get makePaymentAmountStepSectionMidLabel => 'معرف التاجر:';

  @override
  String get makePaymentAmountStepSectionDeleteConfirmationTitle =>
      'هل أنت متأكد؟';

  @override
  String get makePaymentAmountStepSectionDeleteConfirmationMessage =>
      'هل تريد حذف هذا التاجر؟';

  @override
  String get makePaymentAmountStepSectionDeleteButton => 'حذف';

  @override
  String get makePaymentAmountStepSectionCancelButton => 'إلغاء';

  @override
  String get comment_make_payment_review_step_section =>
      '==== Make Payment Review Step Section ====';

  @override
  String get makePaymentReviewStepSectionTitle => 'مراجعة التفاصيل';

  @override
  String get makePaymentReviewStepSectionAmount => 'المبلغ';

  @override
  String get makePaymentReviewStepSectionWallet => 'المحفظة';

  @override
  String get makePaymentReviewStepSectionMerchantAccount => 'حساب التاجر';

  @override
  String get makePaymentReviewStepSectionCharge => 'الرسوم';

  @override
  String get makePaymentReviewStepSectionTotalAmount => 'المبلغ الإجمالي';

  @override
  String get makePaymentReviewStepSectionBackButton => 'رجوع';

  @override
  String get makePaymentReviewStepSectionConfirmButton => 'تأكيد';

  @override
  String get comment_make_payment_success_step_section =>
      '==== Make Payment Success Step Section ====';

  @override
  String get makePaymentSuccessStepSectionTitle => 'تمت الدفعة بنجاح!';

  @override
  String get makePaymentSuccessStepSectionAmount => 'المبلغ';

  @override
  String get makePaymentSuccessStepSectionTransactionId => 'رقم المعاملة';

  @override
  String get makePaymentSuccessStepSectionWalletName => 'اسم المحفظة';

  @override
  String get makePaymentSuccessStepSectionPaymentMethod => 'طريقة الدفع';

  @override
  String get makePaymentSuccessStepSectionCharge => 'الرسوم';

  @override
  String get makePaymentSuccessStepSectionType => 'النوع';

  @override
  String get makePaymentSuccessStepSectionFinalAmount => 'المبلغ النهائي';

  @override
  String get makePaymentSuccessStepSectionPaymentAgainButton => 'دفع مرة أخرى';

  @override
  String get makePaymentSuccessStepSectionBackHomeButton => 'العودة للرئيسية';

  @override
  String get comment_make_payment_history_screen =>
      '==== Make Payment History Screen ====';

  @override
  String get makePaymentHistoryScreenTitle => 'سجل الدفعات';

  @override
  String get comment_make_payment_filter_bottom_sheet =>
      '==== Make Payment Filter Bottom Sheet ====';

  @override
  String get makePaymentFilterTransactionId => 'رقم المعاملة';

  @override
  String get makePaymentFilterStatus => 'الحالة';

  @override
  String get makePaymentFilterApplyButton => 'تصفية';

  @override
  String get makePaymentFilterResetButton => 'إعادة ضبط';

  @override
  String get comment_qr_code_screen => '==== QR Code Screen ====';

  @override
  String get qrCodeScreenTitle => 'رمز QR الخاص بي';

  @override
  String get qrCodeScreenDownloadButton => 'تحميل';

  @override
  String get qrCodeScreenPermissionRequired =>
      'الإذن مطلوب. يرجى السماح به في الإعدادات.';

  @override
  String get qrCodeScreenDownloadSuccess => 'تم التحميل بنجاح!';

  @override
  String get comment_referral_screen => '==== Referral Screen ====';

  @override
  String get referralScreenTitle => 'الإحالة';

  @override
  String get referralScreenEarnAmount => 'اربح';

  @override
  String get referralScreenAfterInviting => 'بعد دعوة';

  @override
  String get referralScreenOneMember => 'عضو واحد';

  @override
  String get referralScreenNoCode => 'لا يوجد رمز';

  @override
  String get referralScreenCodeCopied => 'تم نسخ الرمز';

  @override
  String get referralScreenShareButton => 'مشاركة';

  @override
  String get referralScreenReferredFriends => 'الأصدقاء المُحالون';

  @override
  String get comment_referred_friends_screen =>
      '==== Referred Friends Screen ====';

  @override
  String get referredFriendsScreenTitle => 'الأصدقاء المُحالون';

  @override
  String get referredFriendsScreenReferralTreeButton => 'شجرة الإحالة';

  @override
  String get comment_referred_friend_list => '==== Referred Friend List ====';

  @override
  String get referredFriendListJoinedOn => 'انضم في';

  @override
  String get referredFriendListActive => 'نشط';

  @override
  String get referredFriendListInactive => 'غير نشط';

  @override
  String get comment_referral_tree_screen => '==== Referral Tree Screen ====';

  @override
  String get referralTreeScreenTitle => 'شجرة الإحالة';

  @override
  String get comment_request_money_screen => '==== Request Money Screen ====';

  @override
  String get requestMoneyScreenTitle => 'طلب أموال';

  @override
  String get comment_request_money_amount_step_section =>
      '==== Request Money Amount Step Section ====';

  @override
  String get requestMoneyAmountStepSectionRecipientId => 'معرف المستلم';

  @override
  String get requestMoneyAmountStepSectionRequestAmount => 'المبلغ المطلوب';

  @override
  String get requestMoneyAmountStepSectionMin => 'الحد الأدنى';

  @override
  String get requestMoneyAmountStepSectionMax => 'والحد الأقصى';

  @override
  String get requestMoneyAmountStepSectionNote => 'ملاحظة';

  @override
  String get requestMoneyAmountStepSectionRequestMoneyButton => 'طلب أموال';

  @override
  String get requestMoneyAmountStepSectionInvalidQrCodeDigits =>
      'رمز QR غير صالح. يجب أن يكون معرف المستلم أرقاماً فقط.';

  @override
  String get requestMoneyAmountStepSectionInvalidQrCodePrefix =>
      'رمز QR غير صالح. بادئة معرف المستلم غير موجودة.';

  @override
  String get comment_request_money_header_section =>
      '==== Request Money Header Section ====';

  @override
  String get requestMoneyHeaderSectionTitle => 'طلب أموال';

  @override
  String get requestMoneyHeaderSectionRequestMoneyButton => 'طلب أموال';

  @override
  String get requestMoneyHeaderSectionReceivedRequestButton =>
      'الطلبات المستلمة';

  @override
  String get requestMoneyHeaderSectionHistory => 'سجل طلب الأموال';

  @override
  String get comment_request_money_review_step_section =>
      '==== Request Money Review Step Section ====';

  @override
  String get requestMoneyReviewStepSectionTitle => 'مراجعة التفاصيل';

  @override
  String get requestMoneyReviewStepSectionAmount => 'المبلغ';

  @override
  String get requestMoneyReviewStepSectionWalletName => 'اسم المحفظة';

  @override
  String get requestMoneyReviewStepSectionRecipientUid => 'معرف المستلم';

  @override
  String get requestMoneyReviewStepSectionBackButton => 'رجوع';

  @override
  String get requestMoneyReviewStepSectionConfirmButton => 'تأكيد';

  @override
  String get comment_request_money_success_step_section =>
      '==== Request Money Success Step Section ====';

  @override
  String get requestMoneySuccessStepSectionTitle => 'تم طلب الأموال بنجاح!';

  @override
  String get requestMoneySuccessStepSectionAmount => 'المبلغ';

  @override
  String get requestMoneySuccessStepSectionRecipientName => 'اسم المستلم';

  @override
  String get requestMoneySuccessStepSectionRequestWalletName =>
      'اسم محفظة الطلب';

  @override
  String get requestMoneySuccessStepSectionCharge => 'الرسوم';

  @override
  String get requestMoneySuccessStepSectionFinalAmount => 'المبلغ النهائي';

  @override
  String get requestMoneySuccessStepSectionStatus => 'الحالة';

  @override
  String get requestMoneySuccessStepSectionRequestAgainButton => 'طلب مرة أخرى';

  @override
  String get requestMoneySuccessStepSectionBackHomeButton => 'العودة للرئيسية';

  @override
  String get comment_request_money_wallet_section =>
      '==== Request Money Wallet Section ====';

  @override
  String get requestMoneyWalletSectionBalance => 'الرصيد';

  @override
  String get requestMoneyWalletSectionWalletsNotFound => 'المحافظ غير موجودة';

  @override
  String get comment_request_money_history_screen =>
      '==== Request Money History Screen ====';

  @override
  String get requestMoneyHistoryScreenTitle => 'سجل طلب الأموال';

  @override
  String get requestMoneyHistoryRequestedAt => 'تاريخ الطلب:';

  @override
  String get requestMoneyHistoryStatus => 'الحالة: ';

  @override
  String get comment_request_money_history_details =>
      '==== Request Money History Details ====';

  @override
  String get requestMoneyHistoryDetailsRequestEmail =>
      'البريد الإلكتروني للطلب';

  @override
  String get requestMoneyHistoryDetailsCurrency => 'العملة';

  @override
  String get requestMoneyHistoryDetailsCharge => 'الرسوم';

  @override
  String get requestMoneyHistoryDetailsFinalAmount => 'المبلغ النهائي';

  @override
  String get requestMoneyHistoryDetailsRequestAt => 'تاريخ الطلب';

  @override
  String get requestMoneyHistoryDetailsStatus => 'الحالة';

  @override
  String get comment_received_request_screen =>
      '==== Received Request Screen ====';

  @override
  String get receivedRequestRequestedAt => 'تاريخ الطلب:';

  @override
  String get receivedRequestStatus => 'الحالة: ';

  @override
  String get receivedRequestRejectButton => 'رفض';

  @override
  String get receivedRequestAcceptButton => 'قبول';

  @override
  String get comment_accept_request_dropdown =>
      '==== Accept Request Dropdown ====';

  @override
  String get acceptRequestDropdownTitle => 'هل أنت متأكد؟';

  @override
  String get acceptRequestDropdownMessage => 'هل تريد قبول طلب الأموال هذا؟';

  @override
  String get acceptRequestDropdownPayableAmount => 'المبلغ المستحق:';

  @override
  String get acceptRequestDropdownPayWallet => 'محفظة الدفع:';

  @override
  String get acceptRequestDropdownRequesterNote => 'ملاحظة الطالب:';

  @override
  String get acceptRequestDropdownNoteNotFound => 'لا توجد ملاحظة';

  @override
  String get acceptRequestDropdownAcceptButton => 'قبول';

  @override
  String get acceptRequestDropdownCancelButton => 'إلغاء';

  @override
  String get comment_received_request_details =>
      '==== Received Request Details ====';

  @override
  String get receivedRequestDetailsRequestEmail => 'البريد الإلكتروني للطلب';

  @override
  String get receivedRequestDetailsCurrency => 'العملة';

  @override
  String get receivedRequestDetailsCharge => 'الرسوم';

  @override
  String get receivedRequestDetailsFinalAmount => 'المبلغ النهائي';

  @override
  String get receivedRequestDetailsRequestAt => 'تاريخ الطلب';

  @override
  String get receivedRequestDetailsStatus => 'الحالة';

  @override
  String get comment_change_password_screen =>
      '==== Change Password Screen ====';

  @override
  String get changePasswordScreenTitle => 'تغيير كلمة المرور';

  @override
  String get changePasswordCurrentPassword => 'كلمة المرور الحالية';

  @override
  String get changePasswordNewPassword => 'كلمة المرور الجديدة';

  @override
  String get changePasswordConfirmPassword => 'تأكيد كلمة المرور';

  @override
  String get changePasswordSaveChangesButton => 'حفظ التغييرات';

  @override
  String get comment_id_verification_screen =>
      '==== ID Verification Screen ====';

  @override
  String get idVerificationScreenTitle => 'التحقق من الهوية';

  @override
  String get idVerificationHistoryButton => 'سجل التحقق';

  @override
  String get idVerificationCenterTitle => 'مركز التحقق';

  @override
  String get idVerificationNothingToSubmit => 'لا يوجد شيء لتقديمه';

  @override
  String get kycStatusVerified => 'لقد قدمت مستنداتك وتم التحقق منها';

  @override
  String get kycStatusPending => 'لقد قدمت مستنداتك وهي في انتظار الموافقة';

  @override
  String get kycStatusRejected =>
      'فشل التحقق من KYC الخاص بك. يرجى إعادة تقديم المستندات.';

  @override
  String get kycStatusNotSubmitted => 'لم تقم بتقديم أي مستندات KYC بعد';

  @override
  String get comment_kyc_history_screen => '==== KYC History Screen ====';

  @override
  String get kycHistoryScreenTitle => 'سجل التحقق';

  @override
  String get kycHistoryDate => 'التاريخ:';

  @override
  String get kycHistoryStatus => 'الحالة: ';

  @override
  String get kycHistoryStatusPending => 'قيد الانتظار';

  @override
  String get kycHistoryStatusApproved => 'تمت الموافقة';

  @override
  String get kycHistoryStatusRejected => 'مرفوض';

  @override
  String get kycHistoryViewButton => 'عرض';

  @override
  String get comment_kyc_details_bottom_sheet =>
      '==== KYC Details Bottom Sheet ====';

  @override
  String get kycDetailsTitle => 'تفاصيل التحقق';

  @override
  String get kycDetailsStatus => 'الحالة:';

  @override
  String get kycDetailsCreatedAt => 'تاريخ الإنشاء:';

  @override
  String get kycDetailsMessageFromAdmin => 'رسالة من الإدارة:';

  @override
  String get kycDetailsSubmittedData => 'البيانات المقدمة';

  @override
  String get kycDetailsStatusPending => 'قيد الانتظار';

  @override
  String get kycDetailsStatusApproved => 'تمت الموافقة';

  @override
  String get kycDetailsStatusRejected => 'مرفوض';

  @override
  String get comment_notifications_screen => '==== Notifications Screen ====';

  @override
  String get notificationsScreenTitle => 'جميع الإشعارات';

  @override
  String get notificationsMarkAllReadButton => 'تحديد الكل كمقروء';

  @override
  String get comment_profile_settings_screen =>
      '==== Profile Settings Screen ====';

  @override
  String get profileSettingsScreenTitle => 'إعدادات الملف الشخصي';

  @override
  String get profileSettingsFirstName => 'الاسم الأول';

  @override
  String get profileSettingsLastName => 'الاسم الأخير';

  @override
  String get profileSettingsUserName => 'اسم المستخدم';

  @override
  String get profileSettingsGender => 'الجنس';

  @override
  String get profileSettingsDateOfBirth => 'تاريخ الميلاد';

  @override
  String get profileSettingsEmailAddress => 'البريد الإلكتروني';

  @override
  String get profileSettingsPhone => 'الهاتف';

  @override
  String get profileSettingsCountry => 'البلد';

  @override
  String get profileSettingsCity => 'المدينة';

  @override
  String get profileSettingsZipCode => 'الرمز البريدي';

  @override
  String get profileSettingsJoiningDate => 'تاريخ الانضمام';

  @override
  String get profileSettingsAddress => 'العنوان';

  @override
  String get profileSettingsGenderTitle => 'الجنس';

  @override
  String get profileSettingsGenderNotFound => 'الجنس غير موجود';

  @override
  String get profileSettingsGenderMale => 'ذكر';

  @override
  String get profileSettingsGenderFemale => 'أنثى';

  @override
  String get profileSettingsGenderOther => 'آخر';

  @override
  String get profileSettingsSelectGender => 'اختر الجنس';

  @override
  String get profileSettingsCountryTitle => 'البلد';

  @override
  String get profileSettingsCountryNotFound => 'البلد غير موجود';

  @override
  String get profileSettingsSelectCountry => 'اختر البلد';

  @override
  String get profileSettingsSaveChangesButton => 'حفظ التغييرات';

  @override
  String get comment_support_tickets_screen =>
      '==== Support Tickets Screen ====';

  @override
  String get supportTicketsScreenTitle => 'تذكرة الدعم';

  @override
  String get supportTicketsCreateTicketButton => 'إنشاء تذكرة';

  @override
  String get supportTicketsLastUpdate => 'آخر تحديث';

  @override
  String get supportTicketsRequestedAt => 'تاريخ الطلب';

  @override
  String get supportTicketsPriorityHigh => 'عالية';

  @override
  String get supportTicketsPriorityMedium => 'متوسطة';

  @override
  String get supportTicketsPriorityLow => 'منخفضة';

  @override
  String get supportTicketsStatus => 'الحالة: ';

  @override
  String get supportTicketsStatusOpen => 'مفتوحة';

  @override
  String get supportTicketsStatusClose => 'مغلقة';

  @override
  String get supportTicketsReplyButton => 'رد';

  @override
  String get comment_ticket_details => '==== Ticket Details ====';

  @override
  String get ticketDetailsTitle => 'تفاصيل التذكرة';

  @override
  String get ticketDetailsTicketId => 'رقم التذكرة';

  @override
  String get ticketDetailsCategory => 'التصنيف';

  @override
  String get ticketDetailsPriority => 'الأولوية';

  @override
  String get ticketDetailsCreatedOn => 'تاريخ الإنشاء';

  @override
  String get ticketDetailsLastUpdated => 'آخر تحديث';

  @override
  String get ticketDetailsPriorityHigh => 'عالية';

  @override
  String get ticketDetailsPriorityMedium => 'متوسطة';

  @override
  String get ticketDetailsPriorityLow => 'منخفضة';

  @override
  String get comment_replay_ticket_screen => '==== Replay Ticket Screen ====';

  @override
  String get replayTicketMarkAsClosedButton => 'تحديد كمغلقة';

  @override
  String get replayTicketMessageHint => 'اكتب رسالتك...';

  @override
  String get replayTicketEmptyMessageError => 'يرجى إدخال رسالة';

  @override
  String get replayTicketAttachmentsLabel => 'المرفقات:';

  @override
  String get replayTicketUnknownFile => 'ملف غير معروف';

  @override
  String get replayTicketAttachmentPreviewTitle => 'معاينة المرفق';

  @override
  String get replayTicketAttachmentError => 'حدث خطأ ما!';

  @override
  String get comment_add_new_ticket_screen => '==== Add New Ticket Screen ====';

  @override
  String get addNewTicketScreenTitle => 'إنشاء تذكرة';

  @override
  String get addNewTicketTitle => 'العنوان';

  @override
  String get addNewTicketDescription => 'الوصف';

  @override
  String get addNewTicketAttachments => 'المرفقات';

  @override
  String get addNewTicketAttachFile => 'إرفاق ملف';

  @override
  String get addNewTicketAddButton => 'إضافة تذكرة';

  @override
  String get comment_two_factor_authentication_screen =>
      '==== Two Factor Authentication Screen ====';

  @override
  String get twoFactorAuthenticationScreenTitle => 'التحقق بخطوتين';

  @override
  String get comment_disable_2fa_section => '==== Disable 2FA Section ====';

  @override
  String get disable2FaSectionTitle => 'التحقق بخطوتين';

  @override
  String get disable2FaSectionDescription => 'noInternetConnectionRetryButton';

  @override
  String get disable2FaSectionDisableButton => 'تعطيل التحقق بخطوتين';

  @override
  String get disable2FaSectionPasswordRequired => 'يرجى إدخال كلمة المرور';

  @override
  String get comment_enable_2fa_section => '==== Enable 2FA Section ====';

  @override
  String get enable2FaSectionTitle => 'التحقق بخطوتين';

  @override
  String get enable2FaSectionDescription =>
      'امسح رمز QR بتطبيق Google Authenticator\nلتفعيل التحقق بخطوتين';

  @override
  String get enable2FaSectionPinLabel =>
      'رمز PIN من تطبيق Google Authenticator';

  @override
  String get enable2FaSectionEnableButton => 'تفعيل التحقق بخطوتين';

  @override
  String get enable2FaSectionPinRequired => 'يرجى إدخال رمز التحقق من Google';

  @override
  String get comment_generate_2fa_section => '==== Generate 2FA Section ====';

  @override
  String get generate2FaSectionTitle => 'التحقق بخطوتين';

  @override
  String get generate2FaSectionDescription =>
      'عزز أمان حسابك باستخدام التحقق بخطوتين';

  @override
  String get generate2FaSectionGenerateButton => 'إنشاء رمز التحقق';

  @override
  String get comment_settings_screen => '==== Settings Screen ====';

  @override
  String get settingsScreenTitle => 'الإعدادات';

  @override
  String get settingsProfileSettings => 'إعدادات الملف الشخصي';

  @override
  String get settingsChangePassword => 'تغيير كلمة المرور';

  @override
  String get settingsAllNotification => 'جميع الإشعارات';

  @override
  String get settingsTwoFactorAuthentication => 'التحقق بخطوتين';

  @override
  String get settingsIdVerification => 'التحقق من الهوية';

  @override
  String get settingsSupport => 'الدعم';

  @override
  String get settingsSignOut => 'تسجيل الخروج';

  @override
  String get settingsKycVerified => 'تم التحقق';

  @override
  String get settingsKycPending => 'قيد الانتظار';

  @override
  String get settingsKycFailed => 'فشل';

  @override
  String get settingsKycNotSubmitted => 'لم يتم التقديم';

  @override
  String get comment_transactions_screen => '==== Transactions Screen ====';

  @override
  String get transactionsScreenTitle => 'معاملاتي';

  @override
  String get comment_transactions_popup => '==== Transactions Popup ====';

  @override
  String get transactionsPopupDate => 'التاريخ';

  @override
  String get transactionsPopupTransactionId => 'رقم المعاملة';

  @override
  String get transactionsPopupWalletName => 'اسم المحفظة';

  @override
  String get transactionsPopupAmount => 'المبلغ';

  @override
  String get transactionsPopupCharge => 'الرسوم';

  @override
  String get transactionsPopupFinalAmount => 'المبلغ النهائي';

  @override
  String get transactionsPopupStatus => 'الحالة';

  @override
  String get comment_transaction_filter_bottom_sheet =>
      '==== Transaction Filter Bottom Sheet ====';

  @override
  String get transactionFilterTransactionId => 'رقم المعاملة';

  @override
  String get transactionFilterStatus => 'الحالة';

  @override
  String get transactionFilterApplyButton => 'تصفية';

  @override
  String get transactionFilterResetButton => 'إعادة ضبط';

  @override
  String get comment_transfer_screen => '==== Transfer Screen ====';

  @override
  String get transferScreenTitle => 'تحويل أموال';

  @override
  String get transferHistoryTransferHistory => 'سجل التحويلات';

  @override
  String get transferHistoryReceivedHistory => 'سجل المستلم';

  @override
  String get comment_transfer_received_history_screen =>
      '==== Transfer Received History Screen ====';

  @override
  String get transferReceivedHistoryScreenTitle => 'سجل المستلم';

  @override
  String get comment_transfer_received_filter_bottom_sheet =>
      '==== Transfer Received Filter Bottom Sheet ====';

  @override
  String get transferReceivedFilterTransactionId => 'رقم المعاملة';

  @override
  String get transferReceivedFilterStatus => 'الحالة';

  @override
  String get transferReceivedFilterApplyButton => 'تصفية';

  @override
  String get transferReceivedFilterResetButton => 'إعادة ضبط';

  @override
  String get comment_transfer_history_screen =>
      '==== Transfer History Screen ====';

  @override
  String get transferHistoryScreenTitle => 'سجل التحويلات';

  @override
  String get comment_transfer_transaction_filter_bottom_sheet =>
      '==== Transfer Transaction Filter Bottom Sheet ====';

  @override
  String get transferTransactionFilterTransactionId => 'رقم المعاملة';

  @override
  String get transferTransactionFilterStatus => 'الحالة';

  @override
  String get transferTransactionFilterApplyButton => 'تصفية';

  @override
  String get transferTransactionFilterResetButton => 'إعادة ضبط';

  @override
  String get comment_transfer_amount_step_section =>
      '==== Transfer Amount Step Section ====';

  @override
  String get transferAmountStepSectionRecipientUid => 'معرف المستلم';

  @override
  String get transferAmountStepSectionAmount => 'المبلغ';

  @override
  String get transferAmountStepSectionMin => 'الحد الأدنى';

  @override
  String get transferAmountStepSectionMax => 'والحد الأقصى';

  @override
  String get transferAmountStepSectionTransferMoneyButton => 'تحويل الأموال';

  @override
  String get transferAmountStepSectionSavedBeneficiaryButton =>
      'المستفيدون المحفوظون';

  @override
  String get transferAmountStepSectionInvalidQrCodeDigits =>
      'رمز QR غير صالح. يجب أن يكون معرف المستلم أرقاماً فقط.';

  @override
  String get transferAmountStepSectionInvalidQrCodePrefix =>
      'رمز QR غير صالح. بادئة معرف المستلم غير موجودة.';

  @override
  String get transferAmountStepSectionBeneficiariesTitle => 'المستفيدون';

  @override
  String get transferAmountStepSectionAddBeneficiary => 'إضافة مستفيد';

  @override
  String get transferAmountStepSectionUidLabel => 'معرف المستخدم:';

  @override
  String get transferAmountStepSectionDeleteConfirmationTitle =>
      'هل أنت متأكد؟';

  @override
  String get transferAmountStepSectionDeleteConfirmationMessage =>
      'هل تريد حذف هذا المستفيد؟';

  @override
  String get transferAmountStepSectionDeleteButton => 'حذف';

  @override
  String get transferAmountStepSectionCancelButton => 'إلغاء';

  @override
  String get comment_transfer_review_step_section =>
      '==== Transfer Review Step Section ====';

  @override
  String get transferReviewStepSectionTitle => 'مراجعة التفاصيل';

  @override
  String get transferReviewStepSectionAmount => 'المبلغ';

  @override
  String get transferReviewStepSectionWallet => 'المحفظة';

  @override
  String get transferReviewStepSectionRecipientAccount => 'حساب المستلم';

  @override
  String get transferReviewStepSectionCharge => 'الرسوم';

  @override
  String get transferReviewStepSectionTotalAmount => 'المبلغ الإجمالي';

  @override
  String get transferReviewStepSectionBackButton => 'رجوع';

  @override
  String get transferReviewStepSectionConfirmButton => 'تأكيد';

  @override
  String get comment_transfer_success_step_section =>
      '==== Transfer Success Step Section ====';

  @override
  String get transferSuccessStepSectionTitle => 'تم تحويل الأموال بنجاح!';

  @override
  String get transferSuccessStepSectionAmount => 'المبلغ';

  @override
  String get transferSuccessStepSectionTransactionId => 'رقم المعاملة';

  @override
  String get transferSuccessStepSectionWalletName => 'اسم المحفظة';

  @override
  String get transferSuccessStepSectionPaymentMethod => 'طريقة الدفع';

  @override
  String get transferSuccessStepSectionDateTime => 'التاريخ والوقت';

  @override
  String get transferSuccessStepSectionName => 'الاسم';

  @override
  String get transferSuccessStepSectionCharge => 'الرسوم';

  @override
  String get transferSuccessStepSectionTotalAmount => 'المبلغ الإجمالي';

  @override
  String get transferSuccessStepSectionTransferAgainButton => 'تحويل مرة أخرى';

  @override
  String get transferSuccessStepSectionBackHomeButton => 'العودة للرئيسية';

  @override
  String get comment_transfer_wallet_section =>
      '==== Transfer Wallet Section ====';

  @override
  String get transferWalletSectionBalance => 'الرصيد';

  @override
  String get transferWalletSectionWalletsNotFound => 'المحافظ غير موجودة';

  @override
  String get comment_wallets_screen => '==== Wallets Screen ====';

  @override
  String get walletsScreenTitle => 'محافظي';

  @override
  String get comment_delete_wallet_bottom_sheet =>
      '==== Delete Wallet Bottom Sheet ====';

  @override
  String get deleteWalletBottomSheetTitle => 'هل أنت متأكد؟';

  @override
  String get deleteWalletBottomSheetMessage => 'هل تريد حذف هذه المحفظة؟';

  @override
  String get deleteWalletBottomSheetDeleteButton => 'حذف';

  @override
  String get deleteWalletBottomSheetCancelButton => 'إلغاء';

  @override
  String get comment_wallet_list_section => '==== Wallet List Section ====';

  @override
  String get walletListSectionTopUpButton => 'شحن';

  @override
  String get walletListSectionWithdrawButton => 'سحب';

  @override
  String get walletListSectionUserDepositNotEnabled =>
      'الإيداع غير مفعل للمستخدم';

  @override
  String get walletListSectionUserWithdrawNotEnabled =>
      'السحب غير مفعل للمستخدم';

  @override
  String get comment_create_new_wallet_screen =>
      '==== Create New Wallet Screen ====';

  @override
  String get createNewWalletScreenTitle => 'إنشاء محفظة جديدة';

  @override
  String get createNewWalletCurrency => 'العملة';

  @override
  String get createNewWalletSelectCurrency => 'اختر العملة';

  @override
  String get createNewWalletCurrencyNotFound => 'العملة غير موجودة';

  @override
  String get createNewWalletCreateButton => 'إنشاء';

  @override
  String get comment_withdraw_screen => '==== Withdraw Screen ====';

  @override
  String get withdrawScreenTitle => 'سحب أموال';

  @override
  String get withdrawScreenAddAccountButton => 'إضافة حساب';

  @override
  String get comment_withdraw_history_screen =>
      '==== Withdraw History Screen ====';

  @override
  String get withdrawHistoryScreenTitle => 'سجل السحب';

  @override
  String get comment_withdraw_transaction_filter_bottom_sheet =>
      '==== Withdraw Transaction Filter Bottom Sheet ====';

  @override
  String get withdrawTransactionFilterTransactionId => 'رقم المعاملة';

  @override
  String get withdrawTransactionFilterStatus => 'الحالة';

  @override
  String get withdrawTransactionFilterApplyButton => 'تصفية';

  @override
  String get withdrawTransactionFilterResetButton => 'إعادة ضبط';

  @override
  String get comment_delete_account_dropdown_section =>
      '==== Delete Account Dropdown Section ====';

  @override
  String get deleteAccountDropdownTitle => 'هل أنت متأكد؟';

  @override
  String get deleteAccountDropdownMessage => 'هل تريد حذف هذا الحساب؟';

  @override
  String get deleteAccountDropdownDeleteButton => 'حذف';

  @override
  String get deleteAccountDropdownCancelButton => 'إلغاء';

  @override
  String get comment_withdraw_account_filter_bottom_sheet =>
      '==== Withdraw Account Filter Bottom Sheet ====';

  @override
  String get withdrawAccountFilterMethodName => 'اسم الطريقة';

  @override
  String get withdrawAccountFilterApplyButton => 'تصفية';

  @override
  String get comment_withdraw_account_section =>
      '==== Withdraw Account Section ====';

  @override
  String get withdrawAccountSectionTitle => 'جميع الحسابات';

  @override
  String get comment_withdraw_amount_step_section =>
      '==== Withdraw Amount Step Section ====';

  @override
  String get withdrawAmountStepSectionWithdrawAccount => 'حساب السحب';

  @override
  String get withdrawAmountStepSectionAmount => 'المبلغ';

  @override
  String get withdrawAmountStepSectionMin => 'الحد الأدنى';

  @override
  String get withdrawAmountStepSectionMax => 'والحد الأقصى';

  @override
  String get withdrawAmountStepSectionWithdrawMoneyButton => 'سحب الأموال';

  @override
  String get withdrawAmountStepSectionWithdrawAccountTitle => 'حساب السحب';

  @override
  String get withdrawAmountStepSectionNoAccountsFound => 'لا توجد حسابات سحب';

  @override
  String get withdrawAmountStepSectionCurrencyLabel => 'العملة:';

  @override
  String get withdrawAmountStepSectionMinDescription => 'الحد الأدنى:';

  @override
  String get withdrawAmountStepSectionMaxDescription => 'الحد الأقصى:';

  @override
  String get comment_withdraw_header_section =>
      '==== Withdraw Header Section ====';

  @override
  String get withdrawHeaderSectionTitle => 'سحب أموال';

  @override
  String get withdrawHeaderSectionWithdrawButton => 'سحب';

  @override
  String get withdrawHeaderSectionWithdrawAccountButton => 'حساب السحب';

  @override
  String get withdrawHeaderSectionHistory => 'سجل السحب';

  @override
  String get comment_withdraw_review_step_section =>
      '==== Withdraw Review Step Section ====';

  @override
  String get withdrawReviewStepSectionTitle => 'مراجعة التفاصيل';

  @override
  String get withdrawReviewStepSectionAmount => 'المبلغ';

  @override
  String get withdrawReviewStepSectionCharge => 'الرسوم';

  @override
  String get withdrawReviewStepSectionTotalAmount => 'المبلغ الإجمالي';

  @override
  String get withdrawReviewStepSectionBackButton => 'رجوع';

  @override
  String get withdrawReviewStepSectionConfirmButton => 'تأكيد';

  @override
  String get comment_withdraw_success_step_section =>
      '==== Withdraw Success Step Section ====';

  @override
  String get withdrawSuccessStepSectionTitle => 'تم سحب الأموال بنجاح!';

  @override
  String get withdrawSuccessStepSectionAmount => 'المبلغ';

  @override
  String get withdrawSuccessStepSectionTransactionId => 'رقم المعاملة';

  @override
  String get withdrawSuccessStepSectionCharge => 'الرسوم';

  @override
  String get withdrawSuccessStepSectionTransactionType => 'نوع المعاملة';

  @override
  String get withdrawSuccessStepSectionFinalAmount => 'المبلغ النهائي';

  @override
  String get withdrawSuccessStepSectionWithdrawAgainButton =>
      'سحب أموال مرة أخرى';

  @override
  String get withdrawSuccessStepSectionBackHomeButton => 'العودة للرئيسية';

  @override
  String get comment_edit_withdraw_account_screen =>
      '==== Edit Withdraw Account Screen ====';

  @override
  String get editWithdrawAccountTitle => 'تحديث حساب السحب';

  @override
  String get editWithdrawAccountMethodName => 'اسم الطريقة';

  @override
  String get editWithdrawAccountMethodNameHint => 'أدخل اسم الطريقة';

  @override
  String get editWithdrawAccountFieldHint => 'اكتب هنا...';

  @override
  String get editWithdrawAccountGenericFieldHint => 'أدخل';

  @override
  String get editWithdrawAccountUpdateButton => 'تحديث الحساب';

  @override
  String get comment_create_withdraw_account_screen =>
      '==== Create Withdraw Account Screen ====';

  @override
  String get createWithdrawAccountTitle => 'إنشاء حساب سحب';

  @override
  String get createWithdrawAccountWallet => 'المحفظة';

  @override
  String get createWithdrawAccountWithdrawMethod => 'طريقة السحب';

  @override
  String get createWithdrawAccountMethodName => 'اسم الطريقة';

  @override
  String get createWithdrawAccountCreateButton => 'إنشاء حساب';

  @override
  String get createWithdrawAccountWalletsNotFound => 'المحافظ غير موجودة';

  @override
  String get createWithdrawAccountWithdrawMethodTitle => 'طريقة السحب';

  @override
  String get createWithdrawAccountWithdrawMethodNotFound =>
      'طريقة السحب غير موجودة';

  @override
  String get createWithdrawAccountFieldHint => 'اكتب هنا...';

  @override
  String get comment_dynamic_attachment_preview =>
      '==== Dynamic Attachment Preview ====';

  @override
  String get dynamicAttachmentPreviewTitle => 'معاينة المرفق';

  @override
  String get comment_no_internet_connection =>
      '==== No Internet Connection ====';

  @override
  String get noInternetConnectionTitle => 'لا يوجد اتصال بالإنترنت';

  @override
  String get noInternetConnectionMessage => 'يرجى التحقق من إعدادات الشبكة';

  @override
  String get noInternetConnectionRetryButton => 'إعادة المحاولة';

  @override
  String get comment_qr_scanner_screen => '==== QR Scanner Screen ====';

  @override
  String get qrScannerScreenInstruction => 'ضع رمز QR داخل الإطار للمسح';

  @override
  String get qrScannerScreenProcessing => 'جاري المعالجة...';

  @override
  String get comment_webview_screen => '==== WebView Screen ====';

  @override
  String get webViewScreenPaymentSuccessful => 'تمت الدفعة بنجاح!';

  @override
  String get webViewScreenPaymentFailed => 'فشلت الدفعة!';

  @override
  String get webViewScreenPaymentCancelled => 'تم إلغاء الدفعة!';

  @override
  String get comment_common_country_dropdown_bottom_sheet =>
      '==== Common Country Dropdown Bottom Sheet ====';

  @override
  String get commonCountryDropdownSearchHint => 'بحث';

  @override
  String get commonCountryDropdownNotFound => 'البلد غير موجود';

  @override
  String get comment_common_dropdown_bottom_sheet =>
      '==== Common Dropdown Bottom Sheet ====';

  @override
  String get commonDropdownSearchHint => 'بحث';

  @override
  String get comment_common_dropdown_bottom_sheet_three =>
      '==== Common Dropdown Bottom Sheet Three ====';

  @override
  String get commonDropdownThreeSearchHint => 'بحث';

  @override
  String get comment_common_dropdown_bottom_sheet_two =>
      '==== Common Dropdown Bottom Sheet Two ====';

  @override
  String get commonDropdownTwoSearchHint => 'بحث';

  @override
  String get comment_common_dropdown_wallet_bottom_sheet =>
      '==== Common Dropdown Wallet Bottom Sheet ====';

  @override
  String get commonDropdownWalletTitle => 'اختر المحفظة';

  @override
  String get comment_image_picker_dropdown_bottom_sheet =>
      '==== Image Picker Dropdown Bottom Sheet ====';

  @override
  String get imagePickerDropdownTitle => 'اختر مصدر الصورة';

  @override
  String get imagePickerDropdownCamera => 'الكاميرا';

  @override
  String get imagePickerDropdownGallery => 'معرض الصور';

  @override
  String get comment_multiple_image_picker_dropdown_bottom_sheet =>
      '==== Multiple Image Picker Dropdown Bottom Sheet ====';

  @override
  String get multipleImagePickerDropdownTitle => 'مصدر الصورة';

  @override
  String get multipleImagePickerDropdownCamera => 'الكاميرا';

  @override
  String get multipleImagePickerDropdownGallery => 'معرض الصور';

  @override
  String get comment_navigation_screen => '==== Navigation Screen ====';

  @override
  String get bottomNavHome => 'الرئيسية';

  @override
  String get bottomNavTransfer => 'تحويل';

  @override
  String get bottomNavGift => 'هدية';

  @override
  String get bottomNavSettings => 'الإعدادات';

  @override
  String get qrInvalidFormat =>
      'تنسيق QR غير صالح. يتم قبول رموز AID أو MID أو UID فقط.';

  @override
  String get userTransferNotEnabled => 'التحويل غير مفعل للمستخدم';

  @override
  String get userGiftNotEnabled => 'الهدايا غير مفعلة للمستخدم';

  @override
  String get comment_image_picker_controller =>
      '==== Image Picker Controller ====';

  @override
  String get imagePickerGalleryError => 'فشل اختيار الصورة من المعرض';

  @override
  String get imagePickerCameraError => 'فشل التقاط الصورة من الكاميرا';

  @override
  String get comment_multiple_image_picker_controller =>
      '==== Multiple Image Picker Controller ====';

  @override
  String get multipleImagePickerGalleryError => 'فشل اختيار الصورة من المعرض';

  @override
  String get multipleImagePickerCameraError => 'فشل التقاط الصورة من الكاميرا';

  @override
  String get comment_biometric_auth_service =>
      '==== Biometric Auth Service ====';

  @override
  String get biometricDeviceNotSupported =>
      'هذا الجهاز لا يدعم التحقق البيومتري.';

  @override
  String get biometricNotEnrolled =>
      'لا يوجد بصمة مسجلة. يرجى إعداد بصمة الإصبع';

  @override
  String get biometricUnavailable =>
      'ميزات التحقق البيومتري غير متوفرة حالياً.';

  @override
  String get biometricAuthenticationFailed => 'فشل التحقق البيومتري.';

  @override
  String get biometricCheckFailed => 'تعذر التحقق من توفر التحقق البيومتري.';

  @override
  String get biometricAuthReason => 'التحقق لتسجيل الدخول';

  @override
  String get comment_network_service => '==== Network Service ====';

  @override
  String get networkErrorGeneric => 'حدث خطأ غير متوقع. حاول مرة أخرى.';

  @override
  String get networkErrorTimeout => 'انتهت مهلة الطلب. حاول مرة أخرى.';

  @override
  String get networkErrorOccurred => 'حدث خطأ. حاول مرة أخرى.';

  @override
  String get unauthorizedDialogTitle => 'غير مصرح';

  @override
  String get unauthorizedDialogDescription =>
      'غير مصرح لك بالوصول إلى هذا المورد. يرجى تسجيل الدخول مرة أخرى!';

  @override
  String get unauthorizedDialogButton => 'موافق';

  @override
  String get comment_add_money_controller => '==== Add Money Controller ====';

  @override
  String get addMoneySuccess => 'تمت إضافة الأموال بنجاح';

  @override
  String get addMoneyValidationSelectWallet => 'يرجى اختيار محفظة';

  @override
  String get addMoneyValidationSelectGateway => 'يرجى اختيار بوابة دفع';

  @override
  String get addMoneyValidationEnterAmount => 'يرجى إدخال المبلغ';

  @override
  String get addMoneyValidationAmountGreaterThanZero =>
      'يجب أن يكون المبلغ أكبر من 0';

  @override
  String addMoneyValidationAmountMinimum(Object amount) {
    return 'يجب ألا يقل المبلغ عن $amount';
  }

  @override
  String addMoneyValidationAmountMaximum(Object amount) {
    return 'يجب ألا يزيد المبلغ عن $amount';
  }

  @override
  String addMoneyValidationUploadFile(Object fieldName) {
    return 'يرجى رفع ملف لـ $fieldName';
  }

  @override
  String addMoneyValidationFillField(Object fieldName) {
    return 'يرجى ملء حقل $fieldName';
  }

  @override
  String get comment_cash_out_controller => '==== Cash Out Controller ====';

  @override
  String get cashOutValidationSelectWallet => 'يرجى اختيار محفظة';

  @override
  String get cashOutValidationEnterAgentAid => 'يرجى إدخال معرف الوكيل';

  @override
  String get cashOutValidationEnterAmount => 'يرجى إدخال المبلغ';

  @override
  String cashOutValidationAmountMinimum(Object amount, Object currency) {
    return 'الحد الأدنى للمبلغ هو $amount $currency';
  }

  @override
  String cashOutValidationAmountMaximum(Object amount, Object currency) {
    return 'الحد الأقصى للمبلغ هو $amount $currency';
  }

  @override
  String get comment_exchange_controller => '==== Exchange Controller ====';

  @override
  String get exchangeValidationSelectFromWallet => 'يرجى اختيار محفظة المصدر';

  @override
  String get exchangeValidationSelectToWallet => 'يرجى اختيار محفظة الوجهة';

  @override
  String get exchangeValidationEnterAmount => 'يرجى إدخال المبلغ';

  @override
  String exchangeValidationAmountMinimum(Object amount, Object currency) {
    return 'الحد الأدنى للمبلغ هو $amount $currency';
  }

  @override
  String exchangeValidationAmountMaximum(Object amount, Object currency) {
    return 'الحد الأقصى للمبلغ هو $amount $currency';
  }

  @override
  String get comment_create_gift_controller =>
      '==== Create Gift Controller ====';

  @override
  String get createGiftValidationSelectWallet => 'يرجى اختيار محفظة';

  @override
  String get createGiftValidationEnterAmount => 'يرجى إدخال المبلغ';

  @override
  String createGiftValidationAmountMinimum(Object amount, Object currency) {
    return 'الحد الأدنى للمبلغ هو $amount $currency';
  }

  @override
  String createGiftValidationAmountMaximum(Object amount, Object currency) {
    return 'الحد الأقصى للمبلغ هو $amount $currency';
  }

  @override
  String get comment_home_controller => '==== Home Controller ====';

  @override
  String get homeLanguageChangeFailed => 'فشل تغيير اللغة';

  @override
  String get homeBiometricDeviceNotSupported =>
      'هذا الجهاز لا يدعم التحقق البيومتري.';

  @override
  String get homeBiometricAuthenticationFailed =>
      'فشل التحقق. لم يتم تغيير إعداد التحقق البيومتري.';

  @override
  String get homeBiometricEnabledSuccess => 'تم تفعيل التحقق البيومتري بنجاح';

  @override
  String get homeBiometricDisabledSuccess => 'تم تعطيل التحقق البيومتري بنجاح';

  @override
  String get homeBiometricNotFoundTitle => 'التحقق البيومتري غير موجود';

  @override
  String get homeBiometricNotFoundDescription =>
      'لا توجد بصمة أو تحقق بيومتري مسجل على هذا الجهاز. يمكنك إعداده من إعدادات النظام.';

  @override
  String get homeBiometricOpenSettings => 'فتح إعدادات الأمان';

  @override
  String get homeIosBiometricSetup =>
      'يرجى الذهاب إلى الإعدادات > Face ID & Passcode لإعداد التحقق البيومتري.';

  @override
  String get comment_create_invoice_controller =>
      '==== Create Invoice Controller ====';

  @override
  String get createInvoiceValidationEnterInvoiceTo => 'يرجى إدخال المستلم';

  @override
  String get createInvoiceValidationEnterEmailAddress =>
      'يرجى إدخال البريد الإلكتروني';

  @override
  String get createInvoiceValidationEnterAddress => 'يرجى إدخال العنوان';

  @override
  String get createInvoiceValidationSelectWallet => 'يرجى اختيار محفظة';

  @override
  String get createInvoiceValidationSelectStatus => 'يرجى اختيار الحالة';

  @override
  String get createInvoiceValidationSelectIssueDate =>
      'يرجى اختيار تاريخ الإصدار';

  @override
  String createInvoiceValidationItemNameRequired(Object itemNumber) {
    return 'البند $itemNumber: الاسم مطلوب';
  }

  @override
  String createInvoiceValidationItemQuantityGreaterThanZero(Object itemNumber) {
    return 'البند $itemNumber: يجب أن تكون الكمية أكبر من 0';
  }

  @override
  String createInvoiceValidationItemUnitPriceGreaterThanZero(
    Object itemNumber,
  ) {
    return 'البند $itemNumber: يجب أن يكون سعر الوحدة أكبر من 0';
  }

  @override
  String get comment_make_payment_controller =>
      '==== Make Payment Controller ====';

  @override
  String get makePaymentValidationSelectWallet => 'يرجى اختيار محفظة';

  @override
  String get makePaymentValidationEnterMerchantMid => 'يرجى إدخال معرف التاجر';

  @override
  String get makePaymentValidationEnterAmount => 'يرجى إدخال المبلغ';

  @override
  String makePaymentValidationAmountMinimum(Object amount, Object currency) {
    return 'الحد الأدنى للمبلغ هو $amount $currency';
  }

  @override
  String makePaymentValidationAmountMaximum(Object amount, Object currency) {
    return 'الحد الأقصى للمبلغ هو $amount $currency';
  }

  @override
  String get comment_request_money_controller =>
      '==== Request Money Controller ====';

  @override
  String get requestMoneyValidationSelectWallet => 'يرجى اختيار محفظة';

  @override
  String get requestMoneyValidationEnterRecipientUid =>
      'يرجى إدخال معرف المستلم';

  @override
  String get requestMoneyValidationEnterRequestAmount =>
      'يرجى إدخال المبلغ المطلوب';

  @override
  String requestMoneyValidationAmountMinimum(Object amount, Object currency) {
    return 'الحد الأدنى للمبلغ هو $amount $currency';
  }

  @override
  String requestMoneyValidationAmountMaximum(Object amount, Object currency) {
    return 'الحد الأقصى للمبلغ هو $amount $currency';
  }

  @override
  String get comment_add_new_ticket_controller =>
      '==== Add New Ticket Controller ====';

  @override
  String get addNewTicketSuccess => 'تم إنشاء التذكرة بنجاح';

  @override
  String get addNewValidationEnterTitle => 'يرجى إدخال العنوان';

  @override
  String get addNewValidationEnterDescription => 'يرجى إدخال الوصف';

  @override
  String get comment_change_password_controller =>
      '==== Change Password Controller ====';

  @override
  String get changePasswordValidationEnterCurrentPassword =>
      'يرجى إدخال كلمة المرور الحالية';

  @override
  String get changePasswordValidationEnterNewPassword =>
      'يرجى إدخال كلمة المرور الجديدة';

  @override
  String get changePasswordValidationPasswordMinLength =>
      'كلمة المرور يجب أن تكون 8 أحرف على الأقل';

  @override
  String get changePasswordValidationEnterConfirmPassword =>
      'يرجى إدخال تأكيد كلمة المرور';

  @override
  String get changePasswordValidationPasswordsDoNotMatch =>
      'كلمتا المرور غير متطابقتين';

  @override
  String get comment_transfer_controller => '==== Transfer Controller ====';

  @override
  String get transferValidationSelectWallet => 'يرجى اختيار محفظة';

  @override
  String get transferValidationEnterRecipientUid => 'يرجى إدخال معرف المستلم';

  @override
  String get transferValidationEnterAmount => 'يرجى إدخال المبلغ';

  @override
  String transferValidationAmountMinimum(Object amount, Object currency) {
    return 'الحد الأدنى للمبلغ هو $amount $currency';
  }

  @override
  String transferValidationAmountMaximum(Object amount, Object currency) {
    return 'الحد الأقصى للمبلغ هو $amount $currency';
  }

  @override
  String get comment_create_withdraw_account_controller =>
      '==== Create Withdraw Account Controller ====';

  @override
  String createWithdrawAccountFileRequiredError(Object fieldName) {
    return 'الملف مطلوب لـ $fieldName';
  }

  @override
  String createWithdrawAccountFieldRequiredError(Object fieldName) {
    return 'حقل $fieldName مطلوب';
  }

  @override
  String get createWithdrawAccountValidationSelectWallet => 'يرجى اختيار محفظة';

  @override
  String get createWithdrawAccountValidationSelectWithdrawMethod =>
      'يرجى اختيار طريقة سحب';

  @override
  String get createWithdrawAccountValidationEnterMethodName =>
      'يرجى إدخال اسم الطريقة';

  @override
  String createWithdrawAccountValidationUploadFile(Object fieldName) {
    return 'يرجى رفع ملف لـ $fieldName';
  }

  @override
  String createWithdrawAccountValidationFillField(Object fieldName) {
    return 'يرجى ملء حقل $fieldName';
  }

  @override
  String get comment_withdraw_controller => '==== Withdraw Controller ====';

  @override
  String get withdrawValidationSelectWithdrawAccount => 'يرجى اختيار حساب سحب';

  @override
  String get withdrawValidationEnterAmount => 'يرجى إدخال المبلغ';

  @override
  String withdrawValidationAmountMinimum(Object amount, Object currency) {
    return 'الحد الأدنى للمبلغ هو $amount $currency';
  }

  @override
  String withdrawValidationAmountMaximum(Object amount, Object currency) {
    return 'الحد الأقصى للمبلغ هو $amount $currency';
  }

  @override
  String get comment_airtime_controller => '==== Airtime Controller ====';

  @override
  String get airtimeCountryRequired => 'يرجى اختيار البلد';

  @override
  String get airtimeServiceRequired => 'يرجى اختيار الخدمة';

  @override
  String get airtimeAmountRequired => 'يرجى إدخال المبلغ';

  @override
  String get airtimeAmountValid => 'يرجى إدخال مبلغ صحيح';

  @override
  String airtimeDynamicFieldRequired(Object fieldName) {
    return 'يرجى إدخال $fieldName';
  }

  @override
  String get comment_cable_controller => '==== Cable Controller ====';

  @override
  String get cableCountryRequired => 'يرجى اختيار البلد';

  @override
  String get cableServiceRequired => 'يرجى اختيار الخدمة';

  @override
  String get cableAmountRequired => 'يرجى إدخال المبلغ';

  @override
  String get cableAmountValid => 'يرجى إدخال مبلغ صحيح';

  @override
  String cableDynamicFieldRequired(Object fieldName) {
    return 'يرجى إدخال $fieldName';
  }

  @override
  String get comment_toll_controller => '==== Toll Controller ====';

  @override
  String get tollCountryRequired => 'يرجى اختيار البلد';

  @override
  String get tollServiceRequired => 'يرجى اختيار الخدمة';

  @override
  String get tollAmountRequired => 'يرجى إدخال المبلغ';

  @override
  String get tollAmountValid => 'يرجى إدخال مبلغ صحيح';

  @override
  String tollDynamicFieldRequired(Object fieldName) {
    return 'يرجى إدخال $fieldName';
  }

  @override
  String get comment_electricity_controller =>
      '==== Electricity Controller ====';

  @override
  String get electricityCountryRequired => 'يرجى اختيار البلد';

  @override
  String get electricityServiceRequired => 'يرجى اختيار الخدمة';

  @override
  String get electricityAmountRequired => 'يرجى إدخال المبلغ';

  @override
  String get electricityAmountValid => 'يرجى إدخال مبلغ صحيح';

  @override
  String electricityDynamicFieldRequired(Object fieldName) {
    return 'يرجى إدخال $fieldName';
  }

  @override
  String get comment_internet_controller => '==== Internet Controller ====';

  @override
  String get internetCountryRequired => 'يرجى اختيار البلد';

  @override
  String get internetServiceRequired => 'يرجى اختيار الخدمة';

  @override
  String get internetAmountRequired => 'يرجى إدخال المبلغ';

  @override
  String get internetAmountValid => 'يرجى إدخال مبلغ صحيح';

  @override
  String internetDynamicFieldRequired(Object fieldName) {
    return 'يرجى إدخال $fieldName';
  }

  @override
  String get comment_data_bundle_controller =>
      '==== Data Bundle Controller ====';

  @override
  String get dataBundleCountryRequired => 'يرجى اختيار البلد';

  @override
  String get dataBundleServiceRequired => 'يرجى اختيار الخدمة';

  @override
  String get dataBundleAmountRequired => 'يرجى إدخال المبلغ';

  @override
  String get dataBundleAmountValid => 'يرجى إدخال مبلغ صحيح';

  @override
  String dataBundleDynamicFieldRequired(Object fieldName) {
    return 'يرجى إدخال $fieldName';
  }

  @override
  String get comment_airtime_screen => '==== Airtime Screen ====';

  @override
  String get airtimeAppBarTitle => 'رصيد';

  @override
  String get comment_airtime_amount_section =>
      '==== Airtime Amount Step Section ====';

  @override
  String get airtimeCountryLabel => 'البلد';

  @override
  String get airtimeCountryHint => 'اختر البلد';

  @override
  String get airtimeCountrySelectTitle => 'اختر البلد';

  @override
  String get airtimeCountryNotFound => 'البلد غير موجود';

  @override
  String get airtimeServiceLabel => 'الخدمة';

  @override
  String get airtimeServiceHint => 'اختر الخدمة';

  @override
  String get airtimeServiceSelectTitle => 'اختر الخدمة';

  @override
  String get airtimeServiceNotFound => 'الخدمة غير موجودة';

  @override
  String get airtimeAmountLabel => 'المبلغ';

  @override
  String get airtimePayButton => 'ادفع الآن';

  @override
  String get comment_airtime_review_section =>
      '==== Airtime Review Step Section ====';

  @override
  String get airtimeReviewTitle => 'مراجعة التفاصيل';

  @override
  String get airtimeReviewAmountLabel => 'المبلغ';

  @override
  String get airtimeReviewChargeLabel => 'الرسوم';

  @override
  String get airtimeReviewConversionRateLabel => 'سعر التحويل';

  @override
  String get airtimeReviewPayableAmountLabel => 'المبلغ المستحق';

  @override
  String get airtimeReviewBackButton => 'رجوع';

  @override
  String get airtimeReviewConfirmButton => 'تأكيد';

  @override
  String get comment_bill_payment_history => '==== Bill Payment History ====';

  @override
  String get billPaymentHistoryTitle => 'سجل دفع الفواتير';

  @override
  String get comment_bill_payment_details =>
      '==== Bill Payment Details Sheet ====';

  @override
  String get billPaymentDetailsTitle => 'تفاصيل دفع الفاتورة';

  @override
  String get billPaymentDetailsTime => 'الوقت';

  @override
  String get billPaymentDetailsAmount => 'المبلغ';

  @override
  String get billPaymentDetailsCharge => 'الرسوم';

  @override
  String get billPaymentDetailsMethod => 'الطريقة';

  @override
  String get billPaymentDetailsStatus => 'الحالة';

  @override
  String get comment_cable_screen => '==== Cable Screen ====';

  @override
  String get cableTitle => 'الكابل';

  @override
  String get comment_cable_amount_section =>
      '==== Cable Amount Step Section ====';

  @override
  String get cableCountryLabel => 'البلد';

  @override
  String get cableCountryHint => 'اختر البلد';

  @override
  String get cableCountrySelectTitle => 'اختر البلد';

  @override
  String get cableCountryNotFound => 'البلد غير موجود';

  @override
  String get cableServiceLabel => 'الخدمة';

  @override
  String get cableServiceHint => 'اختر الخدمة';

  @override
  String get cableServiceSelectTitle => 'اختر الخدمة';

  @override
  String get cableServiceNotFound => 'الخدمة غير موجودة';

  @override
  String get cableAmountLabel => 'المبلغ';

  @override
  String get cablePayButton => 'ادفع الآن';

  @override
  String get comment_cable_review_section =>
      '==== Cable Review Step Section ====';

  @override
  String get cableReviewTitle => 'مراجعة التفاصيل';

  @override
  String get cableReviewAmountLabel => 'المبلغ';

  @override
  String get cableReviewChargeLabel => 'الرسوم';

  @override
  String get cableReviewConversionRateLabel => 'سعر التحويل';

  @override
  String get cableReviewPayableAmountLabel => 'المبلغ المستحق';

  @override
  String get cableReviewBackButton => 'رجوع';

  @override
  String get cableReviewConfirmButton => 'تأكيد';

  @override
  String get comment_toll_screen => '==== Toll Screen ====';

  @override
  String get tollTitle => 'الرسوم';

  @override
  String get comment_toll_amount_section =>
      '==== Toll Amount Step Section ====';

  @override
  String get tollCountryLabel => 'البلد';

  @override
  String get tollCountryHint => 'اختر البلد';

  @override
  String get tollCountrySelectTitle => 'اختر البلد';

  @override
  String get tollCountryNotFound => 'البلد غير موجود';

  @override
  String get tollServiceLabel => 'الخدمة';

  @override
  String get tollServiceHint => 'اختر الخدمة';

  @override
  String get tollServiceSelectTitle => 'اختر الخدمة';

  @override
  String get tollServiceNotFound => 'الخدمة غير موجودة';

  @override
  String get tollAmountLabel => 'المبلغ';

  @override
  String get tollPayButton => 'ادفع الآن';

  @override
  String get comment_toll_review_section =>
      '==== Toll Review Step Section ====';

  @override
  String get tollReviewTitle => 'مراجعة التفاصيل';

  @override
  String get tollReviewAmountLabel => 'المبلغ';

  @override
  String get tollReviewChargeLabel => 'الرسوم';

  @override
  String get tollReviewConversionRateLabel => 'سعر التحويل';

  @override
  String get tollReviewPayableAmountLabel => 'المبلغ المستحق';

  @override
  String get tollReviewBackButton => 'رجوع';

  @override
  String get tollReviewConfirmButton => 'تأكيد';

  @override
  String get comment_electricity_screen => '==== Electricity Screen ====';

  @override
  String get electricityTitle => 'الكهرباء';

  @override
  String get comment_electricity_amount_section =>
      '==== Electricity Amount Step Section ====';

  @override
  String get electricityCountryLabel => 'البلد';

  @override
  String get electricityCountryHint => 'اختر البلد';

  @override
  String get electricityCountrySelectTitle => 'اختر البلد';

  @override
  String get electricityCountryNotFound => 'البلد غير موجود';

  @override
  String get electricityServiceLabel => 'الخدمة';

  @override
  String get electricityServiceHint => 'اختر الخدمة';

  @override
  String get electricityServiceSelectTitle => 'اختر الخدمة';

  @override
  String get electricityServiceNotFound => 'الخدمة غير موجودة';

  @override
  String get electricityAmountLabel => 'المبلغ';

  @override
  String get electricityPayButton => 'ادفع الآن';

  @override
  String get comment_electricity_review_section =>
      '==== Electricity Review Step Section ====';

  @override
  String get electricityReviewTitle => 'مراجعة التفاصيل';

  @override
  String get electricityReviewAmountLabel => 'المبلغ';

  @override
  String get electricityReviewChargeLabel => 'الرسوم';

  @override
  String get electricityReviewConversionRateLabel => 'سعر التحويل';

  @override
  String get electricityReviewPayableAmountLabel => 'المبلغ المستحق';

  @override
  String get electricityReviewBackButton => 'رجوع';

  @override
  String get electricityReviewConfirmButton => 'تأكيد';

  @override
  String get comment_internet_screen => '==== Internet Screen ====';

  @override
  String get internetTitle => 'الإنترنت';

  @override
  String get comment_internet_amount_section =>
      '==== Internet Amount Step Section ====';

  @override
  String get internetCountryLabel => 'البلد';

  @override
  String get internetCountryHint => 'اختر البلد';

  @override
  String get internetCountrySelectTitle => 'اختر البلد';

  @override
  String get internetCountryNotFound => 'البلد غير موجود';

  @override
  String get internetServiceLabel => 'الخدمة';

  @override
  String get internetServiceHint => 'اختر الخدمة';

  @override
  String get internetServiceSelectTitle => 'اختر الخدمة';

  @override
  String get internetServiceNotFound => 'الخدمة غير موجودة';

  @override
  String get internetAmountLabel => 'المبلغ';

  @override
  String get internetPayButton => 'ادفع الآن';

  @override
  String get comment_internet_review_section =>
      '==== Internet Review Step Section ====';

  @override
  String get internetReviewTitle => 'مراجعة التفاصيل';

  @override
  String get internetReviewAmountLabel => 'المبلغ';

  @override
  String get internetReviewChargeLabel => 'الرسوم';

  @override
  String get internetReviewConversionRateLabel => 'سعر التحويل';

  @override
  String get internetReviewPayableAmountLabel => 'المبلغ المستحق';

  @override
  String get internetReviewBackButton => 'رجوع';

  @override
  String get internetReviewConfirmButton => 'تأكيد';

  @override
  String get comment_data_bundle_screen => '==== Data Bundle Screen ====';

  @override
  String get dataBundleTitle => 'باقة بيانات';

  @override
  String get comment_data_bundle_amount_section =>
      '==== Data Bundle Amount Step Section ====';

  @override
  String get dataBundleCountryLabel => 'البلد';

  @override
  String get dataBundleCountryHint => 'اختر البلد';

  @override
  String get dataBundleCountrySelectTitle => 'اختر البلد';

  @override
  String get dataBundleCountryNotFound => 'البلد غير موجود';

  @override
  String get dataBundleServiceLabel => 'الخدمة';

  @override
  String get dataBundleServiceHint => 'اختر الخدمة';

  @override
  String get dataBundleServiceSelectTitle => 'اختر الخدمة';

  @override
  String get dataBundleServiceNotFound => 'الخدمة غير موجودة';

  @override
  String get dataBundleAmountLabel => 'المبلغ';

  @override
  String get dataBundlePayButton => 'ادفع الآن';

  @override
  String get comment_data_bundle_review_section =>
      '==== Data Bundle Review Step Section ====';

  @override
  String get dataBundleReviewTitle => 'مراجعة التفاصيل';

  @override
  String get dataBundleReviewAmountLabel => 'المبلغ';

  @override
  String get dataBundleReviewChargeLabel => 'الرسوم';

  @override
  String get dataBundleReviewConversionRateLabel => 'سعر التحويل';

  @override
  String get dataBundleReviewPayableAmountLabel => 'المبلغ المستحق';

  @override
  String get dataBundleReviewBackButton => 'رجوع';

  @override
  String get dataBundleReviewConfirmButton => 'تأكيد';

  @override
  String get comment_bill_payment_screen =>
      '==== Bill Payment Main Screen ====';

  @override
  String get billPaymentScreenTitle => 'دفع الفواتير';

  @override
  String get billPaymentAirtime => 'رصيد';

  @override
  String get billPaymentElectricity => 'كهرباء';

  @override
  String get billPaymentInternet => 'إنترنت';

  @override
  String get billPaymentDataBundle => 'باقة بيانات';

  @override
  String get billPaymentCables => 'كابل';

  @override
  String get billPaymentToll => 'رسوم';

  @override
  String get comment_create_virtual_card_controller =>
      '==== Create Virtual Card Controller ====';

  @override
  String get createCardProviderRequired => 'يرجى اختيار مزود البطاقة';

  @override
  String get createCardHolderRequired => 'يرجى اختيار حامل البطاقة';

  @override
  String get createNameRequired => 'يرجى إدخال الاسم';

  @override
  String get createEmailRequired => 'يرجى إدخال البريد الإلكتروني';

  @override
  String get createEmailInvalid => 'يرجى إدخال بريد إلكتروني صحيح';

  @override
  String get createPhoneNumberRequired => 'يرجى إدخال رقم الهاتف';

  @override
  String get createCountryRequired => 'يرجى اختيار البلد';

  @override
  String get createCityRequired => 'يرجى إدخال المدينة';

  @override
  String get createStateRequired => 'يرجى إدخال المنطقة';

  @override
  String get createPostalCodeRequired => 'يرجى إدخال الرمز البريدي';

  @override
  String get createAddressRequired => 'يرجى إدخال العنوان';

  @override
  String get comment_virtual_card_details_controller =>
      '==== Virtual Card Details Controller ====';

  @override
  String get cardDetailsEnterAmount => 'يرجى إدخال المبلغ';

  @override
  String get cardDetailsAmountGreaterThanZero => 'يجب أن يكون المبلغ أكبر من 0';

  @override
  String cardDetailsAmountMinimumLimit(Object amount) {
    return 'يجب ألا يقل المبلغ عن $amount';
  }

  @override
  String cardDetailsAmountMaximumLimit(Object amount) {
    return 'يجب ألا يزيد المبلغ عن $amount';
  }

  @override
  String get comment_card_holder_tab_section =>
      '==== Card Holder Tab Section ====';

  @override
  String get cardHolderTabExistingCardholders => 'حاملي البطاقات الحاليين';

  @override
  String get cardHolderTabCreateCardholder => 'إنشاء حامل بطاقة';

  @override
  String get comment_choose_card_holder_section =>
      '==== Choose Card Holder Section ====';

  @override
  String get chooseCardHolderLabel => 'حامل البطاقة';

  @override
  String get chooseCardHolderDropdownNotFound => 'حامل البطاقة غير موجود';

  @override
  String get chooseCardHolderDropdownTitle => 'اختر حامل البطاقة';

  @override
  String get chooseCardHolderButtonCreate => 'إنشاء الآن';

  @override
  String get comment_choose_card_provider_section =>
      '==== Choose Card Provider Section ====';

  @override
  String get chooseCardProviderLabel => 'مزود البطاقة';

  @override
  String get chooseCardProviderDropdownNotFound => 'مزود البطاقة غير موجود';

  @override
  String get chooseCardProviderDropdownTitle => 'اختر مزود البطاقة';

  @override
  String get comment_create_new_card_holder_section =>
      '==== Create New Card Holder Section ====';

  @override
  String get createCardHolderLabelName => 'الاسم';

  @override
  String get createCardHolderLabelEmail => 'البريد الإلكتروني';

  @override
  String get createCardHolderLabelPhoneNumber => 'رقم الهاتف';

  @override
  String get createCardHolderLabelCountry => 'البلد';

  @override
  String get createCardHolderDropdownCountryNotFound => 'البلد غير موجود';

  @override
  String get createCardHolderDropdownCountryTitle => 'اختر البلد';

  @override
  String get createCardHolderLabelCity => 'المدينة';

  @override
  String get createCardHolderLabelState => 'المنطقة';

  @override
  String get createCardHolderLabelPostalCode => 'الرمز البريدي';

  @override
  String get createCardHolderLabelAddress => 'العنوان';

  @override
  String get createCardHolderButtonCreate => 'إنشاء الآن';

  @override
  String get comment_create_virtual_card_screen =>
      '==== Create Virtual Card Screen ====';

  @override
  String get createVirtualCardAppBarTitle => 'إنشاء بطاقة جديدة';

  @override
  String get comment_get_card_info_screen => '==== Get Card Info Screen ====';

  @override
  String get getCardInfoAppBarTitle => 'الحصول على بطاقة';

  @override
  String get getCardInfoBenefitsTitle => 'فوائد البطاقات الافتراضية';

  @override
  String get getCardInfoBenefitSecurityTitle => 'أمان أفضل';

  @override
  String get getCardInfoBenefitSecuritySubtitle =>
      'رقم بطاقتك الحقيقية يظل مخفياً';

  @override
  String get getCardInfoBenefitShoppingTitle => 'تسوق آمن عبر الإنترنت';

  @override
  String get getCardInfoBenefitShoppingSubtitle =>
      'أنشئ بطاقات افتراضية فقط للمشتريات عبر الإنترنت';

  @override
  String get getCardInfoBenefitActivationTitle => 'تفعيل سريع وسهل';

  @override
  String get getCardInfoBenefitActivationSubtitle => 'لا حاجة للتوصيل الفعلي';

  @override
  String get getCardInfoButtonContinue => 'متابعة';

  @override
  String get comment_card_details_info => '==== Card Details Info ====';

  @override
  String get cardDetailsInfoTitle => 'تفاصيل البطاقة';

  @override
  String get cardDetailsCardTypeLabel => 'نوع البطاقة';

  @override
  String get cardDetailsCardTypeValue => 'افتراضية';

  @override
  String get cardDetailsBillingAddressLabel => 'عنوان الفواتير';

  @override
  String get cardDetailsCardCurrencyLabel => 'عملة البطاقة';

  @override
  String get bsicardsCardDetailsCurrencyValue => 'USD';

  @override
  String get cardDetailsCardCreatedLabel => 'تاريخ إنشاء البطاقة';

  @override
  String get cardDetailsStatusButtonActive => 'نشطة';

  @override
  String get cardDetailsStatusButtonInactive => 'غير نشطة';

  @override
  String get comment_card_top_up_bottom_sheet =>
      '==== Card Top Up Bottom Sheet ====';

  @override
  String get cardTopUpTitle => 'شحن رصيد البطاقة';

  @override
  String get cardTopUpMainWalletBalance => 'رصيد المحفظة الرئيسية';

  @override
  String get cardTopUpLabelAmount => 'المبلغ';

  @override
  String cardTopUpAmountLimits(Object currency, Object max, Object min) {
    return 'الحد الأدنى $min $currency الحد الأقصى $max $currency';
  }

  @override
  String get cardTopUpReviewTopupAmount => 'مبلغ الشحن';

  @override
  String get cardTopUpReviewTopupCharge => 'رسوم الشحن';

  @override
  String get cardTopUpReviewTotalTopupBalance => 'إجمالي رصيد الشحن';

  @override
  String get cardTopUpButtonTopupNow => 'اشحن الآن';

  @override
  String get bsicardsTopUpInfoMessage =>
      'يرجى إرسال أموالك إلى عنوان العملة المشفرة المقدم. بمجرد تأكيد معاملتك، سيتم إضافة الرصيد إلى بطاقتك.';

  @override
  String get bsicardsTopUpCopyButton => 'نسخ';

  @override
  String get bsicardsTopUpCopySuccess => 'تم نسخ العنوان';

  @override
  String get comment_virtual_card_display => '==== Virtual Card Display ====';

  @override
  String get virtualCardExpiryDateLabel => 'تاريخ الانتهاء';

  @override
  String get virtualCardCvcLabel => 'رمز CVC';

  @override
  String get comment_virtual_card_details_screen =>
      '==== Virtual Card Details Screen ====';

  @override
  String get virtualCardDetailsAppBarTitle => 'تفاصيل البطاقة الافتراضية';

  @override
  String get virtualCardDetailsFloatingButton => 'إضافة رصيد';

  @override
  String get comment_virtual_card_transaction_screen =>
      '==== Virtual Card Transaction Screen ====';

  @override
  String get virtualCardTransactionAppBarTitle => 'معاملات البطاقة';

  @override
  String get virtualCardTransactionSyncButton => 'مزامنة';

  @override
  String get comment_virtual_card_screen => '==== Virtual Card Screen ====';

  @override
  String get virtualCardScreenAppBarTitle => 'البطاقات الافتراضية';

  @override
  String get virtualCardCardExpiryDateLabel => 'تاريخ الانتهاء';

  @override
  String get virtualCardCardCvcLabel => 'رمز CVC';

  @override
  String get virtualCardCreateCardTitle => 'أنشئ بطاقتك الافتراضية للبدء';

  @override
  String get virtualCardCreateCardButton => 'إنشاء بطاقة';

  @override
  String get comment_verify_passcode_controller =>
      '==== Verify Passcode Controller ====';

  @override
  String get verifyPasscodeValidationEnterPasscode => 'يرجى إدخال رمز المرور';

  @override
  String get comment_change_passcode_bottom_sheet =>
      '==== Change Passcode Bottom Sheet ====';

  @override
  String get changePasscodeTitle => 'تغيير رمز المرور';

  @override
  String get changePasscodeLabelOldPasscode => 'رمز المرور القديم';

  @override
  String get changePasscodeLabelNewPasscode => 'رمز المرور الجديد';

  @override
  String get changePasscodeLabelConfirmPasscode => 'تأكيد رمز المرور';

  @override
  String get changePasscodeButtonChange => 'تغيير رمز المرور';

  @override
  String get comment_disable_and_change_passcode_section =>
      '==== Disable and Change Passcode Section ====';

  @override
  String get disableChangePasscodeTitle => 'رمز المرور';

  @override
  String get disableChangePasscodeButtonChange => 'تغيير رمز المرور';

  @override
  String get disableChangePasscodeButtonDisable => 'تعطيل رمز المرور';

  @override
  String get comment_disable_passcode_bottom_sheet =>
      '==== Disable Passcode Bottom Sheet ====';

  @override
  String get disablePasscodeTitle => 'تعطيل رمز المرور';

  @override
  String get disablePasscodeLabelPassword => 'كلمة المرور';

  @override
  String get disablePasscodeButtonDisable => 'تعطيل رمز المرور';

  @override
  String get comment_generate_passcode_bottom_sheet =>
      '==== Generate Passcode Bottom Sheet ====';

  @override
  String get generatePasscodeTitle => 'إضافة رمز مرور';

  @override
  String get generatePasscodeLabelPasscode => 'رمز المرور';

  @override
  String get generatePasscodeLabelConfirmPasscode => 'تأكيد رمز المرور';

  @override
  String get generatePasscodeButtonConfirm => 'تأكيد';

  @override
  String get comment_generate_passcode_section =>
      '==== Generate Passcode Section ====';

  @override
  String get generatePasscodeSectionTitle => 'رمز المرور';

  @override
  String get generatePasscodeSectionDescription =>
      'أنشئ رمز مرور آمن للوصول السريع إلى حسابك';

  @override
  String get generatePasscodeSectionButtonGenerate => 'إنشاء رمز مرور';

  @override
  String get comment_verify_passcode_bottom_sheet =>
      '==== Verify Passcode Bottom Sheet ====';

  @override
  String get verifyPasscodeTitle => 'تأكيد رمز المرور';

  @override
  String get verifyPasscodeLabelPasscode => 'رمز المرور';

  @override
  String get verifyPasscodeButtonConfirm => 'تأكيد';

  @override
  String get comment_payment_links_amount_section =>
      '==== Payment Links Amount Section ====';

  @override
  String get paymentLinksAmountSectionTitle => 'المبلغ';

  @override
  String get paymentLinksCurrencyLabel => 'العملة';

  @override
  String get paymentLinksCurrencyHint => 'اختر العملة';

  @override
  String get paymentLinksCurrencyDropdownTitle => 'العملة';

  @override
  String get paymentLinksCurrencyNotFound => 'العملة غير موجودة';

  @override
  String get paymentLinksNoteLabel => 'ملاحظة';

  @override
  String get paymentLinksCreateLinkButton => 'إنشاء رابط';

  @override
  String get comment_payment_links_create_section =>
      '==== Payment Links Create Section ====';

  @override
  String get paymentLinksInstructionText =>
      'يمكنك إنشاء رابط دفع دون تحديد المبلغ أو العملة. يمكن للدافع ملء الحساب والعملة أثناء الدفع.';

  @override
  String get comment_payment_links_header_section =>
      '==== Payment Links Header Section ====';

  @override
  String get paymentLinksAppBarTitle => 'روابط الدفع';

  @override
  String get paymentLinksTabList => 'القائمة';

  @override
  String get paymentLinksTabCreate => 'إنشاء';

  @override
  String get comment_payment_links_history_filter_bottom_sheet =>
      '==== Payment Links History Filter Bottom Sheet ====';

  @override
  String get paymentLinksFilterNumberLabel => 'الرقم';

  @override
  String get paymentLinksFilterButton => 'تصفية';

  @override
  String get comment_payment_links_list_section =>
      '==== Payment Links List Section ====';

  @override
  String get paymentLinksListItemCreatedAt => 'تاريخ الإنشاء: ';

  @override
  String get paymentLinksListItemStatus => 'الحالة: ';

  @override
  String get paymentLinksStatusPaid => 'مدفوع';

  @override
  String get paymentLinksStatusUnpaid => 'غير مدفوع';

  @override
  String get paymentLinksCopySuccessToast => 'تم نسخ رمز رابط الدفع';

  @override
  String get comment_gift_card_header_section =>
      '---- Gift Card Header Section ----';

  @override
  String get giftCardHeaderTitle => 'بطاقة هدية';

  @override
  String get giftCardHeaderTabCards => 'البطاقات';

  @override
  String get giftCardHeaderTabHistory => 'السجل';

  @override
  String get comment_gift_card_history_filter_bottom_sheet =>
      '---- Gift Card History Filter Bottom Sheet ----';

  @override
  String get giftCardHistoryFilterSearchLabel => 'بحث';

  @override
  String get giftCardHistoryFilterSearchButton => 'بحث';

  @override
  String get comment_gift_card_filter_bottom_sheet =>
      '---- Gift Card Filter Bottom Sheet ----';

  @override
  String get giftCardFilterGiftCardLabel => 'بطاقة هدية';

  @override
  String get giftCardFilterCountryLabel => 'البلد';

  @override
  String get giftCardFilterCountrySelectTitle => 'اختر البلد';

  @override
  String get giftCardFilterAllOption => 'الكل';

  @override
  String get giftCardFilterCountryNotFound => 'البلد غير موجود';

  @override
  String get giftCardFilterCategoryLabel => 'التصنيف';

  @override
  String get giftCardFilterCategorySelectTitle => 'اختر التصنيف';

  @override
  String get giftCardFilterCategoryNotFound => 'التصنيف غير موجود';

  @override
  String get giftCardFilterSearchButton => 'بحث';

  @override
  String get comment_gift_card_history_details =>
      '---- Gift Card History Details ----';

  @override
  String get giftCardHistoryDetailsTitle => 'تفاصيل المعاملة';

  @override
  String giftCardHistoryQtyLabel(Object qty) {
    return 'الكمية: $qty';
  }

  @override
  String get giftCardTransactionIdLabel => 'رقم المعاملة';

  @override
  String get giftCardProductNameLabel => 'اسم المنتج';

  @override
  String get giftCardSenderNameLabel => 'اسم المرسل';

  @override
  String get giftCardRecipientEmailLabel => 'البريد الإلكتروني للمستلم';

  @override
  String get giftCardRecipientPhoneLabel => 'هاتف المستلم';

  @override
  String get giftCardUnitPriceLabel => 'سعر الوحدة';

  @override
  String get giftCardTotalAmountLabel => 'المبلغ الإجمالي';

  @override
  String get comment_gift_card_review_details =>
      '---- Gift Card Review Details ----';

  @override
  String get giftCardReviewDetailsTitle => 'مراجعة التفاصيل';

  @override
  String get giftCardSubTotalLabel => 'المجموع الفرعي';

  @override
  String get giftCardTotalFeeLabel => 'إجمالي الرسوم';

  @override
  String get giftCardTotalLabel => 'الإجمالي';

  @override
  String get giftCardReviewBackButton => 'رجوع';

  @override
  String get giftCardReviewPayNowButton => 'ادفع الآن';

  @override
  String get comment_gift_card_success_section =>
      '---- Gift Card Success Section ----';

  @override
  String get giftCardSuccessTitle => 'تم تقديم طلب بطاقة الهدية بنجاح!';

  @override
  String get giftCardSuccessGiftCardsButton => 'بطاقات الهدايا';

  @override
  String get giftCardSuccessBackHomeButton => 'العودة للرئيسية';

  @override
  String get comment_gift_card_amount_validation =>
      '---- Gift Card Controller Amount Validation ----';

  @override
  String get giftCardAmountRequired => 'يرجى إدخال المبلغ';

  @override
  String get giftCardAmountInvalid => 'يجب أن يكون المبلغ أكبر من صفر';

  @override
  String giftCardAmountMinError(Object min) {
    return 'يجب ألا يقل المبلغ عن $min';
  }

  @override
  String giftCardAmountMaxError(Object max) {
    return 'يجب ألا يزيد المبلغ عن $max';
  }

  @override
  String get comment_gift_card_user_validation =>
      '---- Gift Card Controller User Validation ----';

  @override
  String get giftCardEmailRequired => 'يرجى إدخال البريد الإلكتروني';

  @override
  String get giftCardEmailInvalid => 'يرجى إدخال بريد إلكتروني صحيح';

  @override
  String get giftCardCountryRequired => 'يرجى اختيار البلد';

  @override
  String get giftCardPhoneRequired => 'يرجى إدخال رقم الهاتف';

  @override
  String get giftCardNameRequired => 'يرجى إدخال الاسم';

  @override
  String get comment_gift_card_details_section =>
      '---- Gift Card Details Section ----';

  @override
  String get giftCardDetailsTitle => 'تفاصيل بطاقة الهدية';

  @override
  String get giftCardAmountLabel => 'المبلغ';

  @override
  String giftCardAmountBetweenLabel(Object currency, Object max, Object min) {
    return 'المبلغ بين $min $currency و $max $currency';
  }

  @override
  String get giftCardEmailLabel => 'البريد الإلكتروني';

  @override
  String get giftCardCountryLabel => 'البلد';

  @override
  String get giftCardSelectCountryTitle => 'اختر البلد';

  @override
  String get giftCardCountryNotFound => 'البلد غير موجود';

  @override
  String get giftCardPhoneLabel => 'الهاتف';

  @override
  String get giftCardYourNameLabel => 'اسمك';

  @override
  String get giftCardQuantityLabel => 'الكمية';

  @override
  String get giftCardBuyNowButton => 'اشتر الآن';

  @override
  String get giftCardRedeemInstructionTitle => 'تعليمات الاستبدال';

  @override
  String get comment_p2p => '==== P2P ====';

  @override
  String get p2pMyOrder => 'طلبي';

  @override
  String get p2pPaymentAccount => 'حساب الدفع';

  @override
  String get p2pCreateAd => 'إنشاء إعلان';

  @override
  String get p2pApplyVerification => 'طلب التحقق';

  @override
  String get p2pP2p => 'الند للند';

  @override
  String get p2pMyOrders => 'طلباتي';

  @override
  String get p2pPaymentAccounts => 'حسابات الدفع';

  @override
  String get p2pMyAds => 'إعلاناتي';

  @override
  String get p2pSelectAsset => 'اختر الأصل';

  @override
  String get p2pSelectFiat => 'اختر العملة النقدية';

  @override
  String get p2pBuy => 'شراء';

  @override
  String get p2pSell => 'بيع';

  @override
  String get p2pAmount => 'المبلغ';

  @override
  String get p2pPayment => 'الدفع';

  @override
  String get p2pOrders => 'طلبات';

  @override
  String get p2pCompletion => 'الإكمال';

  @override
  String get p2pLimit => 'الحد';

  @override
  String get p2pAvailable => 'المتاح';

  @override
  String get p2pOrderDetails => 'تفاصيل الطلب';

  @override
  String get p2pNoOrderDetailsFound => 'لم يتم العثور على تفاصيل الطلب';

  @override
  String get p2pNoAdDetailsFound => 'لم يتم العثور على تفاصيل الإعلان';

  @override
  String get p2pPrice => 'السعر';

  @override
  String get p2pOrderLimit => 'حد الطلب';

  @override
  String get p2pYouPay => 'أنت تدفع';

  @override
  String get p2pYouSell => 'أنت تبيع';

  @override
  String get p2pYouReceive => 'أنت تستلم';

  @override
  String get p2pPaymentMethods => 'طرق الدفع';

  @override
  String get p2pLoadingPaymentMethods => 'جار تحميل طرق الدفع...';

  @override
  String get p2pSelectPaymentMethod => 'اختر طريقة الدفع';

  @override
  String get p2pNoPaymentMethodFound => 'لم يتم العثور على طريقة دفع';

  @override
  String get p2pAdvertisersTerms => 'شروط المعلن (يرجى القراءة بعناية)';

  @override
  String get p2pPaymentTimeLimit => 'مهلة الدفع';

  @override
  String get p2pAvgReleaseTime => 'متوسط وقت الإفراج';

  @override
  String get p2pNoTermsProvided => 'لا توجد شروط';

  @override
  String get p2pOrderNumber => 'رقم الطلب';

  @override
  String get p2pSearchOrderNumber => 'رقم طلب البحث';

  @override
  String get p2pOrderNumberCopied => 'تم نسخ رقم الطلب';

  @override
  String get p2pCopied => 'تم النسخ';

  @override
  String get p2pOrderCreated => 'تم إنشاء الطلب';

  @override
  String get p2pFiatAmount => 'المبلغ النقدي';

  @override
  String get p2pReceiveQuantity => 'الكمية المستلمة';

  @override
  String get p2pPaymentMethod => 'طريقة الدفع';

  @override
  String get p2pChange => 'تغيير';

  @override
  String get p2pRecipient => 'المستلم';

  @override
  String get p2pView => 'عرض';

  @override
  String get p2pFilterAmount => 'مبلغ التصفية';

  @override
  String get p2pEnterAmount => 'أدخل المبلغ';

  @override
  String get p2pFilterPaymentMethod => 'تصفية طريقة الدفع';

  @override
  String get p2pUnableToLoadImage => 'تعذر تحميل الصورة';

  @override
  String get p2pUnableToLoadAttachment => 'تعذر تحميل المرفق';

  @override
  String get p2pTransferredNotifySeller => 'تم التحويل، إشعار البائع';

  @override
  String get p2pCancelOrder => 'إلغاء الطلب';

  @override
  String get p2pDisputeOrder => 'فتح نزاع';

  @override
  String get p2pPaymentReceived => 'تم استلام الدفع';

  @override
  String get p2pEnterDisputeReason => 'أدخل سبب النزاع';

  @override
  String get p2pWriteYourReason => 'اكتب السبب...';

  @override
  String get p2pEnterReason => 'إدخال السبب';

  @override
  String get p2pReasonIsRequired => 'السبب مطلوب';

  @override
  String get p2pCancelOrderConfirmation =>
      'هل أنت متأكد أنك تريد إلغاء هذا الطلب؟';

  @override
  String get p2pOrderCompleted => 'اكتمل الطلب';

  @override
  String get p2pOrderCancelled => 'تم إلغاء الطلب';

  @override
  String get p2pPendingRelease => 'بانتظار الإفراج';

  @override
  String get p2pOrderDisputed => 'الطلب متنازع عليه';

  @override
  String get p2pOrderExpired => 'انتهت صلاحية الطلب';

  @override
  String get p2pBuyerMarkedAsPaid => 'قام المشتري بتحديده كمدفوع';

  @override
  String get p2pOrderCreatedPayTheSellerWithin =>
      'تم إنشاء الطلب، ادفع للبائع خلال';

  @override
  String get p2pBuyerHasNotPaidYetPaymentDueWithin =>
      'لم يدفع المشتري بعد. الدفع مستحق خلال';

  @override
  String get p2pSellerFundsLockedInEscrow =>
      'أموال البائع مقفلة في الضمان. سيقوم فريق الدعم بمراجعة الأدلة والرد قريبًا.';

  @override
  String get p2pYourLockedAssetsInEscrow =>
      'أصولك المقفلة في الضمان. سيقوم فريق الدعم بمراجعة هذا النزاع قريبًا.';

  @override
  String get p2pPaymentNotCompletedInAllowedTime =>
      'لم تكمل الدفع خلال الوقت المسموح.';

  @override
  String get p2pBuyerDidNotCompletePaymentInAllowedTime =>
      'لم يكمل المشتري الدفع في الوقت المسموح.';

  @override
  String p2pConfirmPaymentFrom(Object name) {
    return 'أكد أن الدفع من (المشتري: $name)';
  }

  @override
  String get p2pVerifyAmountAndSender =>
      'يرجى التحقق من المبلغ وبيانات المرسل في حسابك ثم المتابعة بإجراء الإفراج.';

  @override
  String get p2pTransferFundsToSeller =>
      'حوّل الأموال إلى حساب البائع الموضح أدناه.';

  @override
  String get p2pNotifySeller => 'إشعار البائع';

  @override
  String get p2pConfirmPaymentReceived => 'تأكيد استلام الدفع';

  @override
  String get p2pConfirmPaymentReceivedDescription =>
      'بعد التأكد من استلام الدفع، اضغط زر \"تم استلام الدفع\" أدناه.';

  @override
  String get p2pNotifySellerDescription =>
      'بعد الدفع، تذكر الضغط على زر \'تم التحويل، إشعار البائع\' لتسهيل الإفراج عن العملة المشفرة بواسطة البائع.';

  @override
  String get p2pAllAccount => 'كل الحسابات';

  @override
  String get p2pAddPaymentMethod => 'إضافة طريقة دفع';

  @override
  String get p2pEdit => 'تعديل';

  @override
  String get p2pEditPaymentAccount => 'تعديل حساب الدفع';

  @override
  String get p2pUpdateAccount => 'تحديث الحساب';

  @override
  String get p2pCancel => 'إلغاء';

  @override
  String get p2pSubmit => 'إرسال';

  @override
  String get p2pBack => 'رجوع';

  @override
  String get p2pNext => 'التالي';

  @override
  String get p2pDone => 'تم';

  @override
  String get p2pIWantToBuy => 'أريد الشراء';

  @override
  String get p2pIWantToSell => 'أريد البيع';

  @override
  String get p2pAsset => 'الأصل';

  @override
  String get p2pWithFiat => 'مع العملة النقدية';

  @override
  String get p2pPriceType => 'نوع السعر';

  @override
  String get p2pYourPrice => 'سعرك';

  @override
  String get p2pHighestOrderPrice => 'أعلى سعر طلب';

  @override
  String get p2pTotalAmount => 'المبلغ الإجمالي';

  @override
  String get p2pSelectAtLeastOnePaymentMethod =>
      'اختر طريقة دفع واحدة على الأقل';

  @override
  String get p2pAdd => 'إضافة';

  @override
  String get p2pMinutes => 'دقائق';

  @override
  String get p2pTerms => 'الشروط';

  @override
  String get p2pAutomaticReply => 'الرد التلقائي';

  @override
  String get p2pFixed => 'ثابت';

  @override
  String get p2pFloat => 'عائم';

  @override
  String get p2pSelectPriceType => 'اختر نوع السعر';

  @override
  String get p2pNoAssetsFound => 'لم يتم العثور على أصول';

  @override
  String get p2pNoFiatCurrenciesFound => 'لم يتم العثور على عملات نقدية';

  @override
  String get p2pNoPriceTypeFound => 'لم يتم العثور على نوع سعر';

  @override
  String get p2pAdSuccessfullyPosted => 'تم نشر الإعلان بنجاح';

  @override
  String get p2pAdsSubmittedUnderReview =>
      'تم إرسال الإعلانات وهي قيد المراجعة.';

  @override
  String get p2pAdPublishedDescription =>
      'تم نشر إعلانك ويمكن للمستخدمين الآن إنشاء طلبات. يرجى الانتباه إلى التنبيهات للطلبات الجديدة.';

  @override
  String get p2pAdUnderReviewDescription =>
      'إعلانك قيد المراجعة. بمجرد الموافقة عليه سيتم نشره ويمكن للمستخدمين إنشاء طلبات. يرجى الانتباه إلى التنبيهات للطلبات الجديدة.';

  @override
  String get p2pAdNumber => 'رقم الإعلان';

  @override
  String get p2pMethod => 'الطريقة';

  @override
  String get p2pGoToMyAds => 'اذهب إلى إعلاناتي';

  @override
  String get p2pEligibilityValidationFailed => 'فشل التحقق من الأهلية';

  @override
  String get p2pPleaseFulfillRequirements => 'يرجى استيفاء المتطلبات التالية:';

  @override
  String get p2pNotEligibleCreateAd => 'أنت غير مؤهل حاليًا لإنشاء إعلان.';

  @override
  String get p2pCompletedTradeQty => 'كمية التداول المكتملة';

  @override
  String get p2pStatus => 'الحالة';

  @override
  String get p2pAdsView => 'عرض الإعلان';

  @override
  String get p2pAdNumberTitle => 'رقم الإعلان';

  @override
  String get p2pType => 'النوع';

  @override
  String get p2pAssetFiat => 'الأصل/النقدي';

  @override
  String get p2pPriceExchangeRate => 'السعر\nسعر الصرف';

  @override
  String get p2pLastUpdated => 'آخر تحديث';

  @override
  String get p2pCreateTime => 'وقت الإنشاء';

  @override
  String get p2pDeleteAdConfirmation =>
      'هل أنت متأكد أنك تريد حذف هذا الإعلان؟';

  @override
  String get p2pFiat => 'نقدي';

  @override
  String get p2pCryptoAmount => 'مبلغ العملة المشفرة';

  @override
  String get p2pCounterparty => 'الطرف المقابل';

  @override
  String get p2pChat => 'محادثة';

  @override
  String get p2pNoMessagesYet => 'لا توجد رسائل بعد';

  @override
  String get p2pTypeYourMessage => 'اكتب رسالتك...';

  @override
  String get p2pCamera => 'الكاميرا';

  @override
  String get p2pGallery => 'المعرض';

  @override
  String get p2pAttachment => 'مرفق';

  @override
  String get p2pUser => 'مستخدم';

  @override
  String get p2pYouAreVerifiedTrader => 'أنت متداول موثّق';

  @override
  String get p2pVerifiedTraderStatusActive =>
      'حالة المتداول الموثق الخاصة بك مفعلة.';

  @override
  String get p2pVerificationUnderReview => 'التحقق قيد المراجعة';

  @override
  String get p2pVerificationRequestUnderReview =>
      'طلب التحقق الخاص بك قيد المراجعة حاليًا.';

  @override
  String get p2pSubmittedOn => 'تم الإرسال في';

  @override
  String get p2pVerificationDataUnavailable => 'بيانات التحقق غير متاحة';

  @override
  String get p2pPleaseRefreshAndTryAgain => 'يرجى التحديث والمحاولة مرة أخرى.';

  @override
  String get p2pPreviousVerificationRejected => 'تم رفض طلب التحقق السابق';

  @override
  String get p2pReason => 'السبب';

  @override
  String get p2pCorrectInformationApplyAgain =>
      'يرجى تصحيح المعلومات والتقديم مرة أخرى.';

  @override
  String get p2pApplyVerificationTitle => 'طلب التحقق';

  @override
  String get p2pFillRequiredFieldsVerification =>
      'املأ جميع الحقول المطلوبة لإرسال طلب التحقق.';

  @override
  String get p2pNoVerificationFormFieldsFound =>
      'لم يتم العثور على حقول نموذج التحقق.';

  @override
  String get p2pSubmitVerification => 'إرسال التحقق';

  @override
  String p2pEnterField(Object field) {
    return 'أدخل $field';
  }

  @override
  String get edit_my_ad => 'تعديل الإعلان';

  @override
  String get amount => 'المبلغ';

  @override
  String get total_amount => 'إجمالي المبلغ';

  @override
  String get min_amount => 'الحد الأدنى';

  @override
  String get max_amount => 'الحد الأقصى';

  @override
  String get payment_duration => 'مدة الدفع';

  @override
  String get payment_method => 'طريقة الدفع';

  @override
  String get no_payment_method => 'لا توجد طريقة دفع';

  @override
  String get terms => 'الشروط';

  @override
  String get auto_response => 'رسالة الرد التلقائي';

  @override
  String get update => 'تحديث';

  @override
  String get error_ad_invalid => 'بيانات الإعلان غير صالحة';

  @override
  String get error_amount_zero => 'لا يمكن أن يكون المبلغ صفر';

  @override
  String get error_total_amount_zero => 'لا يمكن أن يكون إجمالي المبلغ صفر';

  @override
  String get error_min_zero => 'لا يمكن أن يكون الحد الأدنى صفر';

  @override
  String get error_max_zero => 'لا يمكن أن يكون الحد الأقصى صفر';

  @override
  String get error_min_greater =>
      'الحد الأدنى لا يمكن أن يكون أكبر من الحد الأقصى';

  @override
  String get error_payment_duration_zero => 'مدة الدفع لا يمكن أن تكون صفر';

  @override
  String get error_select_payment => 'يرجى اختيار طريقة الدفع';

  @override
  String get error_terms_empty => 'الشروط لا يمكن أن تكون فارغة';

  @override
  String get error_select_asset => 'يرجى اختيار الأصل';

  @override
  String get error_select_fiat => 'يرجى اختيار العملة';

  @override
  String get error_select_price_type => 'يرجى اختيار نوع السعر';

  @override
  String get error_price_zero => 'لا يمكن أن يكون السعر صفر';

  @override
  String get error_enter_total_amount => 'يرجى إدخال إجمالي المبلغ';

  @override
  String get error_enter_min_order => 'يرجى إدخال الحد الأدنى للطلب';

  @override
  String get error_enter_max_order => 'يرجى إدخال الحد الأقصى للطلب';

  @override
  String get error_payment_time_zero => 'مدة الدفع لا يمكن أن تكون صفر';

  @override
  String get error_enter_terms => 'يرجى إدخال الشروط';

  @override
  String get filterMyAds => 'تصفية إعلاناتي';

  @override
  String get status => 'الحالة';

  @override
  String get type => 'النوع';

  @override
  String get fiatCurrency => 'العملة النقدية';

  @override
  String get assetCurrency => 'عملة الأصل';

  @override
  String get reset => 'إعادة تعيين';

  @override
  String get search => 'بحث';

  @override
  String get select => 'اختر';

  @override
  String get selectStatus => 'اختر الحالة';

  @override
  String get selectType => 'اختر النوع';

  @override
  String get selectFiatCurrency => 'اختر العملة النقدية';

  @override
  String get selectAssetCurrency => 'اختر عملة الأصل';

  @override
  String get noStatusFound => 'لا توجد حالة';

  @override
  String get noTypeFound => 'لا يوجد نوع';

  @override
  String get noDataFound => 'لم يتم العثور على بيانات';

  @override
  String get noFiatCurrencyFound => 'لا توجد عملة نقدية';

  @override
  String get noAssetCurrencyFound => 'لا توجد عملة أصل';

  @override
  String get filterPaymentAccount => 'تصفية حساب الدفع';

  @override
  String get filterMyOrder => 'تصفية طلبي';
}
