// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get comment_common_maintenance => '==== Maintenance ====';

  @override
  String get maintenanceTitle => 'Технические работы';

  @override
  String get maintenanceSubtitle =>
      'Мы выполняем плановое обслуживание для улучшения вашего опыта.';

  @override
  String get comment_common_alert_bottom_sheet =>
      '==== Alert Bottom Sheet ====';

  @override
  String get alertBottonSheetConfirmButton => 'Подтвердить';

  @override
  String get alertBottonSheetCancelButton => 'Отмена';

  @override
  String get comment_all_controller_load_Error =>
      '==== All Controller Load Error ====';

  @override
  String get allControllerLoadError => 'Произошла ошибка!';

  @override
  String get comment_common_exit_application => '==== Exit Application ====';

  @override
  String get exitApplicationTitle => 'Выход из приложения';

  @override
  String get exitApplicationMessage =>
      'Вы уверены, что хотите выйти из приложения?';

  @override
  String get comment_common_dropdown => '==== Common Dropdown ====';

  @override
  String get commonDropdownSelectGender => 'Выберите пол';

  @override
  String get commonDropdownGender => 'Пол';

  @override
  String get commonDropdownGenderNotFound => 'Пол не найден';

  @override
  String get commonDropdownMale => 'Мужской';

  @override
  String get commonDropdownFemale => 'Женский';

  @override
  String get commonDropdownOther => 'Другое';

  @override
  String get comment_welcome => '==== Welcome Screen ====';

  @override
  String get welcomeTitle => 'Добро пожаловать в eCardo';

  @override
  String get welcomeDescription =>
      'eCardo предоставляет управление несколькими кошельками, мгновенный обмен и безопасные транзакции.';

  @override
  String get welcomeSignIn => 'Войти';

  @override
  String get welcomeCreateAccount => 'Создать аккаунт';

  @override
  String get comment_sign_in => '==== Sign In Screen ====';

  @override
  String get signInWelcomeBack => 'С возвращением!';

  @override
  String get signInSubtitle => 'Возьмите под контроль свои финансы уже сегодня';

  @override
  String get signInEmail => 'Эл. почта';

  @override
  String get signInPassword => 'Пароль';

  @override
  String get signInForgotPassword => 'Забыли пароль';

  @override
  String get signInButton => 'Войти';

  @override
  String get signInNotRegistered => 'Ещё не зарегистрированы? ';

  @override
  String get signInCreateAccount => 'Создать аккаунт';

  @override
  String get signInBiometricErrorFirstTime =>
      'Сначала войдите с эл. почтой и паролем';

  @override
  String get signInBiometricErrorNotEnabled => 'Биометрия не включена';

  @override
  String get signInRegistrationDisabled => 'Регистрация отключена';

  @override
  String get signInValidationEmailRequired => 'Поле эл. почты обязательно';

  @override
  String get signInValidationPasswordRequired => 'Поле пароля обязательно';

  @override
  String get comment_two_factor_auth =>
      '==== Two Factor Authentication Screen ====';

  @override
  String get twoFactorAuthTitle => 'Подтверждение 2FA';

  @override
  String get twoFactorAuthSubtitle =>
      'Введите код из приложения Google Authenticator';

  @override
  String get twoFactorAuthEnterOtp => 'Введите OTP';

  @override
  String get twoFactorAuthVerifyButton => 'Подтвердить';

  @override
  String get twoFactorAuthBackTo => 'Вернуться к? ';

  @override
  String get twoFactorAuthSignIn => 'Войти';

  @override
  String get twoFactorAuthOtpRequired => 'Поле OTP обязательно';

  @override
  String get comment_forgot_password => '==== Forgot Password Screen ====';

  @override
  String get forgotPasswordTitle => 'Сброс пароля';

  @override
  String get forgotPasswordSubtitle =>
      'Не волнуйтесь, такое случается! Введите email для сброса пароля.';

  @override
  String get forgotPasswordEmail => 'Email';

  @override
  String get forgotPasswordButton => 'Забыли пароль?';

  @override
  String get forgotPasswordBackTo => 'Вернуться к? ';

  @override
  String get forgotPasswordSignIn => 'Войти';

  @override
  String get forgotPasswordEmailRequired => 'Поле email обязательно';

  @override
  String get comment_forgot_password_pin_verification =>
      '==== Forgot Password Pin Verification Screen ====';

  @override
  String get forgotPasswordPinVerifyTitle => 'Подтверждение email';

  @override
  String get forgotPasswordPinOtpSent => 'OTP-код отправлен на ';

  @override
  String get forgotPasswordPinEnterOtp => 'Введите OTP-код';

  @override
  String get forgotPasswordPinOtpCountdown => 'OTP-код через';

  @override
  String get forgotPasswordPinVerifyButton => 'Подтвердить OTP';

  @override
  String get forgotPasswordPinDidNotReceive => 'Не получили код? ';

  @override
  String get forgotPasswordPinResend => 'Отправить повторно';

  @override
  String get forgotPasswordPinOtpRequired => 'Поле OTP-кода обязательно';

  @override
  String get comment_reset_password => '==== Reset Password Screen ====';

  @override
  String get resetPasswordTitle => 'Сброс пароля';

  @override
  String get resetPasswordSubtitle => 'Введите пароль и подтвердите его.';

  @override
  String get resetPasswordPassword => 'Пароль';

  @override
  String get resetPasswordConfirmPassword => 'Подтвердите пароль';

  @override
  String get resetPasswordButton => 'Сбросить';

  @override
  String get resetPasswordAlreadyHaveAccount => 'Уже есть аккаунт? ';

  @override
  String get resetPasswordSignIn => 'Войти';

  @override
  String get resetPasswordValidationRequired => 'Пожалуйста, введите пароль';

  @override
  String get resetPasswordValidationMinLength =>
      'Пароль должен содержать не менее 8 символов';

  @override
  String get resetPasswordValidationConfirmRequired =>
      'Пожалуйста, подтвердите пароль';

  @override
  String get resetPasswordValidationMismatch => 'Пароли не совпадают';

  @override
  String get comment_auth_id_verification =>
      '==== Auth ID Verification Screen ====';

  @override
  String get authIdVerificationInvalidFieldType => 'Недопустимый тип поля';

  @override
  String get authIdVerificationUnknownFieldType => 'Неизвестный тип поля: ';

  @override
  String get comment_camera_type_section => '==== Camera Type Section ====';

  @override
  String get cameraTypeBack => 'Назад';

  @override
  String get cameraTypeNotAvailable => 'Н/Д';

  @override
  String get cameraTypeButton => 'Камера';

  @override
  String get cameraTypeSkip => 'Пропустить';

  @override
  String get comment_file_type_section => '==== File Type Section ====';

  @override
  String get fileTypeBack => 'Назад';

  @override
  String get fileTypeNotAvailable => 'Н/Д';

  @override
  String get fileTypeChooseFile => 'Выбрать файл';

  @override
  String get fileTypeSkip => 'Пропустить';

  @override
  String get comment_front_camera_type_section =>
      '==== Front Camera Type Section ====';

  @override
  String get frontCameraTypeBack => 'Назад';

  @override
  String get frontCameraTypeNotAvailable => 'Н/Д';

  @override
  String get frontCameraTypeButton => 'Фронтальная камера';

  @override
  String get frontCameraTypeSkip => 'Пропустить';

  @override
  String get comment_kyc_submission_section =>
      '==== KYC Submission Section ====';

  @override
  String get kycSubmissionIdVerification => 'Проверка личности';

  @override
  String get kycSubmissionSubmit => 'Отправить';

  @override
  String get kycSubmissionNext => 'Далее';

  @override
  String get kycSubmissionReUpload => 'Загрузить заново';

  @override
  String get kycSubmissionRetake => 'Переснять';

  @override
  String get comment_email_screen => '==== Email Screen ====';

  @override
  String get emailScreenCreateAccount => 'Создайте свой аккаунт';

  @override
  String get emailScreenSubtitle =>
      'Присоединяйтесь и берите свои финансы под контроль уже сегодня';

  @override
  String get emailScreenEmail => 'Email';

  @override
  String get emailScreenContinue => 'Продолжить';

  @override
  String get emailScreenAlreadyHaveAccount => 'Уже есть аккаунт? ';

  @override
  String get emailScreenSignIn => 'Войти';

  @override
  String get emailScreenEmailRequired => 'Введите email';

  @override
  String get comment_personal_info_screen => '==== Personal Info Screen ====';

  @override
  String get personalInfoTitle => 'Ваши данные';

  @override
  String get personalInfoSubtitle =>
      'Введите ваши официальные данные, чтобы продолжить.';

  @override
  String get personalInfoFirstName => 'Имя';

  @override
  String get personalInfoLastName => 'Фамилия';

  @override
  String get personalInfoUserName => 'Имя пользователя';

  @override
  String get personalInfoCountry => 'Страна';

  @override
  String get personalInfoSelectCountry => 'Выберите страну';

  @override
  String get personalInfoPhoneNo => 'Номер телефона';

  @override
  String get personalInfoReferralCode => 'Реферальный код';

  @override
  String get personalInfoContinue => 'Продолжить';

  @override
  String get personalInfoValidationFirstNameRequired => 'Укажите имя';

  @override
  String get personalInfoValidationLastNameRequired => 'Укажите фамилию';

  @override
  String get personalInfoValidationUserNameRequired =>
      'Укажите имя пользователя';

  @override
  String get personalInfoValidationCountryRequired => 'Укажите страну';

  @override
  String get personalInfoValidationPhoneRequired => 'Укажите номер телефона';

  @override
  String get personalInfoValidationReferralCodeRequired =>
      'Укажите реферальный код';

  @override
  String get personalInfoValidationGenderRequired => 'Укажите пол';

  @override
  String get comment_setup_password_screen => '==== Setup Password Screen ====';

  @override
  String get setupPasswordTitle => 'Задать пароль';

  @override
  String get setupPasswordSubtitle =>
      'Создайте надёжный пароль и подтвердите его';

  @override
  String get setupPasswordPassword => 'Пароль';

  @override
  String get setupPasswordConfirmPassword => 'Подтвердите пароль';

  @override
  String get setupPasswordAgreeTerms => 'Я соглашаюсь с ';

  @override
  String get setupPasswordTermsConditions => 'Условия и положения';

  @override
  String get setupPasswordButton => 'Задать пароль';

  @override
  String get setupPasswordValidationRequired => 'Пожалуйста, введите пароль';

  @override
  String get setupPasswordValidationMinLength =>
      'Пароль должен содержать не менее 8 символов';

  @override
  String get setupPasswordValidationConfirmRequired =>
      'Пожалуйста, подтвердите пароль';

  @override
  String get setupPasswordValidationMismatch => 'Пароли не совпадают';

  @override
  String get setupPasswordValidationTermsRequired =>
      'Пожалуйста, примите условия и положения';

  @override
  String get comment_sign_up_status_screen => '==== Sign Up Status Screen ====';

  @override
  String get signUpStatusTitle => 'Ваш текущий статус';

  @override
  String get signUpStatusSubtitle =>
      'Быстрый процесс из 4 шагов для защиты вашего аккаунта eCardo';

  @override
  String get signUpStatusStep => 'Шаг';

  @override
  String get signUpStatusEmailVerification => 'Верификация эл. почты';

  @override
  String get signUpStatusSetupPassword => 'Задать пароль';

  @override
  String get signUpStatusPersonalInfo => 'Личные данные';

  @override
  String get signUpStatusVerification => 'Верификация';

  @override
  String get signUpStatusInReview => 'На рассмотрении';

  @override
  String get signUpStatusRejected => 'Отклонено';

  @override
  String get signUpStatusNoReason => 'Причина не указана';

  @override
  String get signUpStatusNextStep => 'Следующий шаг';

  @override
  String get signUpStatusSubmitAgain => 'Отправить снова';

  @override
  String get signUpStatusDashboard => 'Главная';

  @override
  String get signUpStatusBack => 'Назад';

  @override
  String get signUpStatusErrorProcessing =>
      'Ошибка обработки следующего шага. Попробуйте ещё раз.';

  @override
  String get signUpStatusVerificationTypeEmpty => 'Тип верификации не задан!';

  @override
  String get signUpStatusErrorLoadingTypes =>
      'Ошибка загрузки типов верификации. Попробуйте ещё раз.';

  @override
  String get signUpStatusDropdownTwoVerificationNotFound =>
      'Тип верификации не найден';

  @override
  String get comment_verify_email_screen => '==== Verify Email Screen ====';

  @override
  String get verifyEmailTitle => 'Подтверждение эл. почты';

  @override
  String get verifyEmailOtpSent => 'OTP отправлен на ';

  @override
  String get verifyEmailEnterOtp => 'Введите OTP';

  @override
  String get verifyEmailResendAvailable => 'Повторная отправка через';

  @override
  String get verifyEmailRequestNewOtp => 'Можно запросить новый OTP';

  @override
  String get verifyEmailButton => 'Подтвердить эл. почту';

  @override
  String get verifyEmailDidNotReceive => 'Не получили код? ';

  @override
  String get verifyEmailResend => 'Отправить снова';

  @override
  String get verifyEmailOtpRequired => 'Поле OTP обязательно';

  @override
  String get comment_add_money_screen => '==== Add Money Screen ====';

  @override
  String get addMoneyTitle => 'Пополнить';

  @override
  String get addMoneyBalance => 'Баланс';

  @override
  String get addMoneyHistory => 'История пополнений';

  @override
  String get addMoneyWalletsNotFound => 'Кошельки не найдены';

  @override
  String get comment_add_money_amount_step => '==== Add Money Amount Step ====';

  @override
  String get addMoneyGateway => 'Платёжный шлюз';

  @override
  String get addMoneyGatewayNotFound => 'Шлюз не найден';

  @override
  String get addMoneySelectGateway => 'Выберите шлюз';

  @override
  String get addMoneyCharge => 'Комиссия:';

  @override
  String get addMoneyAmount => 'Сумма';

  @override
  String get addMoneyMin => 'Минимум';

  @override
  String get addMoneyMax => 'и максимум';

  @override
  String get addMoneyWriteHere => 'Напишите здесь...';

  @override
  String get addMoneyAddMoneyButton => 'Пополнить';

  @override
  String get comment_add_money_pending_step =>
      '==== Add Money Pending Step ====';

  @override
  String get addMoneyPendingTitle => 'Ваш депозит\nнаходится в обработке';

  @override
  String get addMoneyPendingAmount => 'Сумма';

  @override
  String get addMoneyPendingTransactionId => 'ID транзакции';

  @override
  String get addMoneyPendingWalletName => 'Название кошелька';

  @override
  String get addMoneyPendingPaymentMethod => 'Способ оплаты';

  @override
  String get addMoneyPendingCharge => 'Комиссия';

  @override
  String get addMoneyPendingType => 'Тип';

  @override
  String get addMoneyPendingFinalAmount => 'Итоговая сумма';

  @override
  String get addMoneyPendingDepositAgain => 'Пополнить снова';

  @override
  String get addMoneyPendingBackHome => 'На главную';

  @override
  String get comment_add_money_review_step => '==== Add Money Review Step ====';

  @override
  String get addMoneyReviewTitle => 'Проверка данных';

  @override
  String get addMoneyReviewAmount => 'Сумма';

  @override
  String get addMoneyReviewWalletName => 'Название кошелька';

  @override
  String get addMoneyReviewPaymentMethod => 'Способ оплаты';

  @override
  String get addMoneyReviewCharge => 'Комиссия';

  @override
  String get addMoneyReviewTotal => 'Итого';

  @override
  String get addMoneyReviewBack => 'Назад';

  @override
  String get addMoneyReviewConfirm => 'Подтвердить';

  @override
  String get addMoneyReviewNoFileUploaded => 'Файл не загружен';

  @override
  String get comment_add_money_success_step =>
      '==== Add Money Success Step ====';

  @override
  String get addMoneySuccessTitle => 'Пополнение выполнено!';

  @override
  String get addMoneySuccessAmount => 'Сумма';

  @override
  String get addMoneySuccessTransactionId => 'ID транзакции';

  @override
  String get addMoneySuccessCharge => 'Комиссия';

  @override
  String get addMoneySuccessTransactionType => 'Тип транзакции';

  @override
  String get addMoneySuccessFinalAmount => 'Итоговая сумма';

  @override
  String get addMoneySuccessAddMoneyAgain => 'Пополнить снова';

  @override
  String get addMoneySuccessBackHome => 'На главную';

  @override
  String get comment_add_money_history => '==== Add Money History ====';

  @override
  String get addMoneyHistoryTitle => 'История пополнений';

  @override
  String get comment_add_money_filter_bottom_sheet =>
      '==== Add Money Filter Bottom Sheet ====';

  @override
  String get addMoneyFilterTransactionId => 'ID транзакции';

  @override
  String get addMoneyFilterStatus => 'Статус';

  @override
  String get addMoneyFilterSuccess => 'Успешно';

  @override
  String get addMoneyFilterPending => 'В обработке';

  @override
  String get addMoneyFilterFailed => 'Ошибка';

  @override
  String get addMoneyFilterButton => 'Фильтр';

  @override
  String get addMoneyFilterReset => 'Сбросить';

  @override
  String get comment_create_beneficiary_screen =>
      '==== Create Beneficiary Screen ====';

  @override
  String get createBeneficiaryTitle => 'Создать нового';

  @override
  String get createBeneficiaryAccountNumber => 'Номер счёта';

  @override
  String get createBeneficiaryNickName => 'Имя (псевдоним)';

  @override
  String get createBeneficiaryCreateButton => 'Создать';

  @override
  String get createBeneficiaryValidationAccountNumber => 'Укажите номер счёта';

  @override
  String get createBeneficiaryValidationNickName => 'Укажите имя (псевдоним)';

  @override
  String get comment_update_beneficiary_screen =>
      '==== Update Beneficiary Screen ====';

  @override
  String get updateBeneficiaryTitle => 'Обновить';

  @override
  String get updateBeneficiaryNickName => 'Ник';

  @override
  String get updateBeneficiaryUpdateButton => 'Обновить';

  @override
  String get updateBeneficiaryValidationNickName => 'Укажите ник';

  @override
  String get comment_account_user_types => '==== Account User Types ====';

  @override
  String get accountUserMerchant => 'Мерчант';

  @override
  String get accountUserBeneficiary => 'Получатель';

  @override
  String get accountUserAgent => 'Агент';

  @override
  String get comment_cash_out_screen => '==== Cash Out Screen ====';

  @override
  String get cashOutTitle => 'Вывод через агента';

  @override
  String get cashOutHistory => 'История вывода наличных';

  @override
  String get comment_cash_out_amount_step => '==== Cash Out Amount Step ====';

  @override
  String get cashOutAgentId => 'ID агента';

  @override
  String get cashOutAmount => 'Сумма';

  @override
  String get cashOutMin => 'Минимум';

  @override
  String get cashOutMax => 'и максимум';

  @override
  String get cashOutButton => 'Вывести наличные';

  @override
  String get cashOutSavedAgents => 'Сохранённые агенты';

  @override
  String get cashOutAgents => 'Агенты';

  @override
  String get cashOutAddAgent => 'Добавить агента';

  @override
  String get cashOutAid => 'AID:';

  @override
  String get cashOutQrInvalidDigits =>
      'Неверный QR-код. AID агента должен состоять только из цифр.';

  @override
  String get cashOutQrInvalidPrefix =>
      'Неверный QR-код. Префикс AID не найден.';

  @override
  String get cashOutDeleteConfirm => 'Вы уверены?';

  @override
  String get cashOutDeleteMessage => 'Вы хотите удалить этого агента?';

  @override
  String get cashOutDeleteButton => 'Удалить';

  @override
  String get cashOutCancelButton => 'Отмена';

  @override
  String get comment_cash_out_review_step => '==== Cash Out Review Step ====';

  @override
  String get cashOutReviewTitle => 'Проверка данных';

  @override
  String get cashOutReviewAmount => 'Сумма';

  @override
  String get cashOutReviewWallet => 'Кошелёк';

  @override
  String get cashOutReviewAgentAccount => 'Счёт агента';

  @override
  String get cashOutReviewCharge => 'Комиссия';

  @override
  String get cashOutReviewTotalAmount => 'Итоговая сумма';

  @override
  String get cashOutReviewBack => 'Назад';

  @override
  String get cashOutReviewConfirm => 'Подтвердить';

  @override
  String get comment_cash_out_success_step => '==== Cash Out Success Step ====';

  @override
  String get cashOutSuccessTitle => 'Вывод наличных выполнен!';

  @override
  String get cashOutSuccessAmount => 'Сумма';

  @override
  String get cashOutSuccessTransactionId => 'ID транзакции';

  @override
  String get cashOutSuccessWalletName => 'Название кошелька';

  @override
  String get cashOutSuccessPaymentMethod => 'Способ оплаты';

  @override
  String get cashOutSuccessCharge => 'Комиссия';

  @override
  String get cashOutSuccessType => 'Тип';

  @override
  String get cashOutSuccessFinalAmount => 'Итоговая сумма';

  @override
  String get cashOutSuccessCashOutAgain => 'Вывести снова';

  @override
  String get cashOutSuccessBackHome => 'На главную';

  @override
  String get comment_cash_out_wallets_section =>
      '==== Cash Out Wallets Section ====';

  @override
  String get cashOutWalletsBalance => 'Баланс';

  @override
  String get cashOutWalletsNotFound => 'Кошельки не найдены';

  @override
  String get comment_cash_out_history => '==== Cash Out History ====';

  @override
  String get cashOutHistoryTitle => 'История вывода наличных';

  @override
  String get comment_cash_out_filter_bottom_sheet =>
      '==== Cash Out Filter Bottom Sheet ====';

  @override
  String get cashOutFilterTransactionId => 'ID транзакции';

  @override
  String get cashOutFilterStatus => 'Статус';

  @override
  String get cashOutFilterButton => 'Фильтр';

  @override
  String get cashOutFilterReset => 'Сбросить';

  @override
  String get comment_exchange_screen => '==== Exchange Screen ====';

  @override
  String get exchangeTitle => 'Обмен между кошельками';

  @override
  String get exchangeHistory => 'История обменов';

  @override
  String get comment_exchange_amount_step => '==== Exchange Amount Step ====';

  @override
  String get exchangeAmount => 'Сумма';

  @override
  String get exchangeMin => 'Минимум';

  @override
  String get exchangeMax => 'и максимум';

  @override
  String get exchangeButton => 'Обменять';

  @override
  String get comment_exchange_review_step => '==== Exchange Review Step ====';

  @override
  String get exchangeReviewTitle => 'Проверка данных';

  @override
  String get exchangeReviewAmount => 'Сумма';

  @override
  String get exchangeReviewFromWallet => 'Из кошелька';

  @override
  String get exchangeReviewCharge => 'Комиссия';

  @override
  String get exchangeReviewTotalAmount => 'Итоговая сумма';

  @override
  String get exchangeReviewToWallet => 'В кошелёк';

  @override
  String get exchangeReviewExchangeRate => 'Курс обмена';

  @override
  String get exchangeReviewExchangeAmount => 'Сумма обмена';

  @override
  String get exchangeReviewBack => 'Назад';

  @override
  String get exchangeReviewConfirm => 'Подтвердить';

  @override
  String get comment_exchange_success_step => '==== Exchange Success Step ====';

  @override
  String get exchangeSuccessTitle => 'Обмен выполнен!';

  @override
  String get exchangeSuccessAmount => 'Сумма';

  @override
  String get exchangeSuccessTransactionId => 'ID транзакции';

  @override
  String get exchangeSuccessPayAmount => 'Сумма списания';

  @override
  String get exchangeSuccessConvertedAmount => 'Конвертированная сумма';

  @override
  String get exchangeSuccessCharge => 'Комиссия';

  @override
  String get exchangeSuccessDate => 'Дата';

  @override
  String get exchangeSuccessFinalAmount => 'Итоговая сумма';

  @override
  String get exchangeSuccessExchangeAgain => 'Обменять снова';

  @override
  String get exchangeSuccessBackHome => 'На главную';

  @override
  String get comment_exchange_wallet_section =>
      '==== Exchange Wallet Section ====';

  @override
  String get exchangeWalletBalance => 'Баланс';

  @override
  String get exchangeWalletsNotFound => 'Кошельки не найдены';

  @override
  String get comment_exchange_wallet_to_wallet =>
      '==== Exchange Wallet To Wallet ====';

  @override
  String get exchangeWalletToWallet => 'Кошелёк → кошелёк';

  @override
  String get exchangeFromWallet => 'Из кошелька';

  @override
  String get exchangeToWallet => 'В кошелёк';

  @override
  String get exchangeRate => 'Курс обмена: ';

  @override
  String get exchangeWalletToWalletWalletsNotFound => 'Кошельки не найдены';

  @override
  String get exchangeWalletSectionFiat => 'Фиатные валюты';

  @override
  String get exchangeWalletSectionCrypto => 'Криптоактивы';

  @override
  String get exchangeAmountReceive => 'Вы получите';

  @override
  String get exchangeAmountSend => 'Вы отправляете';

  @override
  String get exchangeContinue => 'Продолжить';

  @override
  String get exchangeQuickPercent25 => '25%';

  @override
  String get exchangeQuickPercent50 => '50%';

  @override
  String get exchangeQuickPercent75 => '75%';

  @override
  String get exchangeQuickMax => 'Макс';

  @override
  String get exchangeMinHint => 'Мин';

  @override
  String get exchangeMaxHint => 'Макс';

  @override
  String get exchangeReviewRateLockedAt =>
      'Курс зафиксирован при подтверждении';

  @override
  String get exchangeReviewRateStaleBanner =>
      'Курс обновлён. Проверьте и подтвердите снова.';

  @override
  String get exchangeSuccessShareReceipt => 'Поделиться квитанцией';

  @override
  String get exchangeSuccessBackToWallet => 'В кошелёк';

  @override
  String get exchangeRateDisconnectedBanner =>
      'Сервис курсов временно недоступен.';

  @override
  String get exchangeRateStaleNotice => 'Показан последний известный курс';

  @override
  String get exchangeRateAutoCaption => 'Автообновление каждые 60 с';

  @override
  String get exchangeRecentPairs => 'Недавние пары';

  @override
  String get exchangeRateAlertTitle => 'Оповещение о курсе';

  @override
  String get exchangeRateAlertHint => 'Уведомить, когда курс достигнет';

  @override
  String get exchangeRateAlertSet => 'Установить оповещение';

  @override
  String get exchangeRateAlertPlaceholder => 'Скоро';

  @override
  String get exchangeRateServiceRefresh => 'Обновить';

  @override
  String get rate_service_unavailable => 'Сервис курсов недоступен';

  @override
  String get rate_stale_last_known => 'Показан последний известный курс';

  @override
  String get rate_auto_update_caption => 'Автообновление каждые 60 с';

  @override
  String get exchangeRate24hChange => '24ч';

  @override
  String get exchangeRateLastUpdate => 'Обновлено';

  @override
  String get refresh => 'Обновить';

  @override
  String get calculating => 'Расчёт…';

  @override
  String get comment_exchange_history => '==== Exchange History ====';

  @override
  String get exchangeHistoryTitle => 'История обменов';

  @override
  String get comment_exchange_filter_bottom_sheet =>
      '==== Exchange Filter Bottom Sheet ====';

  @override
  String get exchangeFilterTransactionId => 'ID транзакции';

  @override
  String get exchangeFilterStatus => 'Статус';

  @override
  String get exchangeFilterButton => 'Фильтр';

  @override
  String get exchangeFilterReset => 'Сбросить';

  @override
  String get comment_gift_code_screen => '==== Gift Code Screen ====';

  @override
  String get giftCodeTitle => 'Подарочный код';

  @override
  String get giftCodeCreateGift => 'Создать подарок';

  @override
  String get comment_create_gift_amount_step =>
      '==== Create Gift Amount Step ====';

  @override
  String get createGiftAmount => 'Сумма';

  @override
  String get createGiftMin => 'Минимум';

  @override
  String get createGiftMax => 'и максимум';

  @override
  String get createGiftButton => 'Создать подарок';

  @override
  String get comment_create_gift_review_section =>
      '==== Create Gift Review Section ====';

  @override
  String get createGiftReviewTitle => 'Проверка данных';

  @override
  String get createGiftReviewAmount => 'Сумма';

  @override
  String get createGiftReviewWalletName => 'Название кошелька';

  @override
  String get createGiftReviewCharge => 'Комиссия';

  @override
  String get createGiftReviewTotalAmount => 'Итоговая сумма';

  @override
  String get createGiftReviewBack => 'Назад';

  @override
  String get createGiftReviewConfirm => 'Подтвердить';

  @override
  String get comment_create_gift_success_step =>
      '==== Create Gift Success Step ====';

  @override
  String get createGiftSuccessTitle => 'Подарок создан!';

  @override
  String get createGiftSuccessAmount => 'Сумма';

  @override
  String get createGiftSuccessCharge => 'Комиссия';

  @override
  String get createGiftSuccessFinalAmount => 'Итоговая сумма';

  @override
  String get createGiftSuccessCreatedAt => 'Дата создания';

  @override
  String get createGiftSuccessCreateAgain => 'Создать подарочный код снова';

  @override
  String get createGiftSuccessBackHome => 'На главную';

  @override
  String get comment_create_gift_wallet_section =>
      '==== Create Gift Wallet Section ====';

  @override
  String get createGiftWalletBalance => 'Баланс';

  @override
  String get createGiftWalletWalletsNotFound => 'Кошельки не найдены';

  @override
  String get comment_gift_code_header_section =>
      '==== Gift Code Header Section ====';

  @override
  String get giftCodeHeaderTitle => 'Подарочный код';

  @override
  String get giftCodeHeaderGiftRedeem => 'Активация подарка';

  @override
  String get giftCodeHeaderMyGift => 'Мои подарки';

  @override
  String get giftCodeHeaderGiftRedeemHistory => 'История активаций';

  @override
  String get comment_gift_history => '==== Gift History ====';

  @override
  String get giftHistoryCreatedAt => 'Дата создания:';

  @override
  String get giftHistoryStatus => 'Статус: ';

  @override
  String get giftHistoryClaimed => 'Получен';

  @override
  String get giftHistoryClaimable => 'Доступен к получению';

  @override
  String get giftHistoryCodeCopied => 'Подарочный код скопирован';

  @override
  String get comment_gift_history_filter_bottom_sheet =>
      '==== Gift History Filter Bottom Sheet ====';

  @override
  String get giftHistoryFilterGiftCode => 'Подарочный код';

  @override
  String get giftHistoryFilterButton => 'Фильтр';

  @override
  String get comment_gift_redeem_section => '==== Gift Redeem Section ====';

  @override
  String get giftRedeemGiftCode => 'Подарочный код';

  @override
  String get giftRedeemButton => 'Активировать';

  @override
  String get giftRedeemValidation => 'Введите подарочный код';

  @override
  String get comment_gift_redeem_history => '==== Gift Redeem History ====';

  @override
  String get giftRedeemHistoryTitle => 'Моя история активаций';

  @override
  String get giftRedeemHistoryCreatedAt => 'Дата создания:';

  @override
  String get giftRedeemHistoryStatus => 'Статус: ';

  @override
  String get giftRedeemHistoryClaimed => 'Получен';

  @override
  String get giftRedeemHistoryClaimable => 'Доступен к получению';

  @override
  String get giftRedeemHistoryCodeCopied => 'Подарочный код скопирован';

  @override
  String get comment_gift_redeem_filter_bottom_sheet =>
      '==== Gift Redeem Filter Bottom Sheet ====';

  @override
  String get giftRedeemFilterCode => 'Код';

  @override
  String get giftRedeemFilterButton => 'Фильтр';

  @override
  String get giftRedeemFilterReset => 'Сбросить';

  @override
  String get comment_drawer_section => '==== Drawer Section ====';

  @override
  String get drawerDashboard => 'Панель управления';

  @override
  String get drawerMyWallets => 'Мои кошельки';

  @override
  String get drawerAddMoney => 'Пополнить';

  @override
  String get drawerCashOut => 'Вывести';

  @override
  String get drawerBillPayments => 'Оплата счетов';

  @override
  String get drawerRemittance => 'Международный перевод';

  @override
  String get drawerVirtualCards => 'Виртуальные карты';

  @override
  String get drawerPaymentLinks => 'Платёжные ссылки';

  @override
  String get drawerMakePayment => 'Оплатить';

  @override
  String get drawerTransfer => 'Перевод';

  @override
  String get drawerWithdraw => 'Вывод средств';

  @override
  String get drawerExchange => 'Обмен';

  @override
  String get drawerInviting => 'Приглашения';

  @override
  String get drawerGiftCard => 'Подарочные карты';

  @override
  String get drawerP2pTrading => 'P2P-торговля';

  @override
  String get drawerKycVerification => 'Пройдите верификацию KYC!';

  @override
  String get comment_end_drawer_section => '==== End Drawer Section ====';

  @override
  String get endDrawerProfileSettings => 'Настройки профиля';

  @override
  String get endDrawerChangePassword => 'Смена пароля';

  @override
  String get endDrawerAllNotification => 'Все уведомления';

  @override
  String get endDrawerHelpSupport => 'Помощь и поддержка';

  @override
  String get endDrawerLanguage => 'Язык';

  @override
  String get endDrawerBiometric => 'Биометрия';

  @override
  String get endDrawerSignOut => 'Выйти';

  @override
  String get endDrawerLanguageNotFound => 'Язык не найден';

  @override
  String get endDrawerChooseLanguage => 'Выбор языка';

  @override
  String get comment_recent_transaction_details =>
      '==== Recent Transaction Details ====';

  @override
  String get transactionDetailsTitle => 'Детали транзакции';

  @override
  String get transactionDetailsWallet => 'Кошелёк';

  @override
  String get transactionDetailsCharge => 'Комиссия';

  @override
  String get transactionDetailsTransactionId => 'ID транзакции';

  @override
  String get transactionDetailsMethod => 'Способ';

  @override
  String get transactionDetailsTotalAmount => 'Общая сумма';

  @override
  String get transactionDetailsStatus => 'Статус';

  @override
  String get transactionDetailsDescription => 'Описание';

  @override
  String get transactionStatusSuccess => 'Успешно';

  @override
  String get transactionStatusPending => 'В ожидании';

  @override
  String get transactionStatusFailed => 'Ошибка';

  @override
  String get comment_wallet_details => '==== Wallet Details ====';

  @override
  String get walletDetailsHistory => 'История';

  @override
  String get walletDetailsAvailableBalance => 'ДОСТУПНЫЙ БАЛАНС';

  @override
  String get walletDetailsTopUp => 'Пополнить';

  @override
  String get walletDetailsWithdraw => 'Вывести';

  @override
  String get walletDetailsUserDepositNotEnabled => 'Пополнение недоступно';

  @override
  String get walletDetailsUserWithdrawNotEnabled => 'Вывод недоступен';

  @override
  String get walletDetailsWalletsNotFound => 'Кошельки не найдены';

  @override
  String get comment_action_button_section => '==== Action Button Section ====';

  @override
  String get actionButtonTransfer => 'Перевод';

  @override
  String get actionButtonWithdraw => 'Вывод средств';

  @override
  String get actionButtonPayment => 'Оплата';

  @override
  String get actionButtonExchange => 'Обмен';

  @override
  String get actionButtonUserTransferNotEnabled =>
      'Перевод для пользователя не включён';

  @override
  String get actionButtonUserWithdrawNotEnabled =>
      'Вывод средств для пользователя не включён';

  @override
  String get actionButtonUserPaymentNotEnabled =>
      'Оплата для пользователя не включена';

  @override
  String get actionButtonUserExchangeNotEnabled =>
      'Обмен для пользователя не включён';

  @override
  String get comment_my_wallet_section => '==== My Wallet Section ====';

  @override
  String get myWalletSectionTitle => 'Мои кошельки';

  @override
  String get myWalletTopUp => 'Пополнить';

  @override
  String get myWalletWithdraw => 'Вывести';

  @override
  String get myWalletUserDepositNotEnabled => 'Пополнение не включено';

  @override
  String get myWalletUserWithdrawNotEnabled => 'Вывод средств не включён';

  @override
  String get comment_other_services_section =>
      '==== Other Services Section ====';

  @override
  String get otherServicesTitle => 'Другие услуги';

  @override
  String get dynamicPasswordTitle => 'Динамический пароль';

  @override
  String get dynamicPasswordDesc => '6-значный код для оплаты с кошелька';

  @override
  String get otherServicesQrCode => 'QR-код';

  @override
  String get otherServicesAddMoney => 'Пополнить';

  @override
  String get otherServicesCashOut => 'Вывод средств';

  @override
  String get otherServicesMakePayment => 'Совершить платёж';

  @override
  String get otherServicesTransactions => 'Транзакции';

  @override
  String get otherServicesInvoice => 'Счёт';

  @override
  String get otherServicesRequestMoney => 'Запросить средства';

  @override
  String get otherServicesGift => 'Подарок';

  @override
  String get otherServicesWallets => 'Кошельки';

  @override
  String get otherServicesWithdraw => 'Вывод';

  @override
  String get otherServicesExchange => 'Обмен';

  @override
  String get otherServicesTransfer => 'Перевод';

  @override
  String get otherServicesDynamicPassword => 'Динамичный PIN';

  @override
  String get commonComingSoon => 'Скоро';

  @override
  String get otherServicesInvite => 'Пригласить';

  @override
  String get otherServicesBillPayment => 'Оплата счетов';

  @override
  String get otherServicesVirtualCard => 'Виртуальные карты';

  @override
  String get otherServicesGiftCards => 'Подарочные карты';

  @override
  String get otherServicesP2pTrading => 'P2P-торговля';

  @override
  String get otherServicesPaymentLinks => 'Платёжные ссылки';

  @override
  String get otherServicesKycVerification => 'Пройдите верификацию KYC!';

  @override
  String get otherServicesUserGiftNotEnabled => 'Подарки не включены';

  @override
  String get otherServicesUserDepositNotEnabled => 'Пополнение не включено';

  @override
  String get otherServicesUserCashOutNotEnabled => 'Вывод средств не включён';

  @override
  String get otherServicesUserPaymentNotEnabled => 'Платежи не включены';

  @override
  String get otherServicesUserRequestMoneyNotEnabled =>
      'Запрос средств не включён';

  @override
  String get otherServicesUserInvoiceNotEnabled => 'Счета не включены';

  @override
  String get comment_recent_transactions_section =>
      '==== Recent Transactions Section ====';

  @override
  String get recentTransactionsTitle => 'Последние';

  @override
  String get comment_section_header => '==== Section Header ====';

  @override
  String get sectionHeaderSeeAll => 'Показать все';

  @override
  String get comment_sign_up_bonus_popup => '==== Sign Up Bonus Popup ====';

  @override
  String get signUpBonusCongratulations => 'Поздравляем!';

  @override
  String get signUpBonusReceived => 'Вы получили бонус';

  @override
  String get comment_user_profile_section => '==== User Profile Section ====';

  @override
  String get userProfileHello => 'Здравствуйте, 👋';

  @override
  String get userProfileUid => 'UID:';

  @override
  String get userProfileCopied => 'Скопировано';

  @override
  String get comment_invoice_screen => '==== Invoice Screen ====';

  @override
  String get invoiceTitle => 'Счёт';

  @override
  String get invoiceCreateInvoice => 'Создать счёт';

  @override
  String get invoiceAmount => 'Сумма:';

  @override
  String get invoiceCharge => 'Комиссия:';

  @override
  String get invoiceStatus => 'Статус: ';

  @override
  String get invoicePublished => 'Опубликован';

  @override
  String get invoiceDraft => 'Черновик';

  @override
  String get invoiceView => 'Просмотр';

  @override
  String get invoicePaid => 'Оплачен';

  @override
  String get invoiceUnpaid => 'Не оплачен';

  @override
  String get comment_update_invoice => '==== Update Invoice ====';

  @override
  String get updateInvoiceTitle => 'Обновить счёт';

  @override
  String get updateInvoiceItems => 'Позиции счёта';

  @override
  String get updateInvoiceAddItem => 'Добавить позицию';

  @override
  String get updateInvoiceButton => 'Обновить счёт';

  @override
  String get comment_update_invoice_add_item =>
      '==== Update Invoice Add Item ====';

  @override
  String get updateInvoiceItemName => 'Название позиции';

  @override
  String get updateInvoiceQuantity => 'Количество';

  @override
  String get updateInvoiceUnitPrice => 'Цена за единицу';

  @override
  String get updateInvoiceSubTotal => 'Промежуточный итог';

  @override
  String get comment_update_invoice_information =>
      '==== Update Invoice Information ====';

  @override
  String get updateInvoiceInformationTitle => 'Данные счёта';

  @override
  String get updateInvoiceTo => 'Кому выставлен счёт';

  @override
  String get updateInvoiceEmailAddress => 'Эл. почта';

  @override
  String get updateInvoiceAddress => 'Адрес';

  @override
  String get updateInvoiceWallet => 'Кошелёк';

  @override
  String get updateInvoiceStatus => 'Статус';

  @override
  String get updateInvoiceIssueDate => 'Дата выставления';

  @override
  String get updateInvoicePaymentStatus => 'Статус оплаты';

  @override
  String get updateInvoiceSelectWallet => 'Выберите кошелёк';

  @override
  String get updateInvoiceSelectStatus => 'Выберите статус';

  @override
  String get updateInvoiceSelectPaymentStatus => 'Выберите статус оплаты';

  @override
  String get updateInvoiceWalletNotFound => 'Кошелёк не найден';

  @override
  String get updateInvoiceStatusNotFound => 'Статус не найден';

  @override
  String get updateInvoicePaymentStatusNotFound => 'Статус оплаты не найден';

  @override
  String get comment_invoice_status_options =>
      '==== Invoice Status Options ====';

  @override
  String get invoiceStatusDraft => 'Черновик';

  @override
  String get invoiceStatusPublished => 'Опубликован';

  @override
  String get invoiceStatusPaid => 'Оплачен';

  @override
  String get invoiceStatusUnpaid => 'Не оплачен';

  @override
  String get comment_invoice_details => '==== Invoice Details ====';

  @override
  String get invoiceDetailsTitle => 'Счёт';

  @override
  String get invoiceDetailsReference => 'Реф.:';

  @override
  String get invoiceDetailsIssued => 'Дата выставления:';

  @override
  String get invoiceDetailsName => 'Название';

  @override
  String get invoiceDetailsEmail => 'Эл. почта';

  @override
  String get invoiceDetailsCharge => 'Комиссия';

  @override
  String get invoiceDetailsAddress => 'Адрес';

  @override
  String get invoiceDetailsTotalAmount => 'Итоговая сумма';

  @override
  String get invoiceDetailsStatus => 'Статус';

  @override
  String get invoiceDetailsItemName => 'Наименование товара';

  @override
  String get invoiceDetailsQuantity => 'Количество';

  @override
  String get invoiceDetailsUnitPrice => 'Цена за единицу';

  @override
  String get invoiceDetailsSubTotal => 'Подытог';

  @override
  String get invoiceDetailsPayNow => 'Оплатить';

  @override
  String get invoiceDetailsPrintInvoice => 'Распечатать счёт';

  @override
  String get invoiceDetailsPaid => 'Оплачено';

  @override
  String get invoiceDetailsUnpaid => 'Не оплачено';

  @override
  String get comment_invoice_pdf => '==== Invoice PDF ====';

  @override
  String get invoicePdfReference => 'Реф.:';

  @override
  String get invoicePdfIssued => 'Дата выставления:';

  @override
  String get invoicePdfPaid => 'Оплачен';

  @override
  String get invoicePdfUnpaid => 'Не оплачен';

  @override
  String get invoicePdfTotalAmount => 'Итоговая сумма:';

  @override
  String get invoicePdfAmount => 'Сумма:';

  @override
  String get invoicePdfCharge => 'Комиссия:';

  @override
  String get invoicePdfItemName => 'Наименование товара';

  @override
  String get invoicePdfQuantity => 'Количество';

  @override
  String get invoicePdfUnitPrice => 'Цена за единицу';

  @override
  String get invoicePdfSubtotal => 'Подытог';

  @override
  String get invoicePdfSubtotalLabel => 'Подытог: ';

  @override
  String get invoicePdfChargeLabel => 'Комиссия: ';

  @override
  String get invoicePdfTotalAmountLabel => 'Итоговая сумма: ';

  @override
  String get invoicePdfThanks => 'Спасибо за покупку.';

  @override
  String get comment_create_invoice => '==== Create Invoice ====';

  @override
  String get createInvoiceTitle => 'Создать счёт';

  @override
  String get createInvoiceItems => 'Позиции счёта';

  @override
  String get createInvoiceAddItem => 'Добавить позицию';

  @override
  String get createInvoiceButton => 'Создать счёт';

  @override
  String get createInvoiceStatusDraft => 'Черновик';

  @override
  String get comment_create_invoice_add_item_section =>
      '==== Create Invoice Add Item Section ====';

  @override
  String get createInvoiceAddItemSectionItemName => 'Наименование';

  @override
  String get createInvoiceAddItemSectionQuantity => 'Количество';

  @override
  String get createInvoiceAddItemSectionUnitPrice => 'Цена за единицу';

  @override
  String get createInvoiceAddItemSectionSubTotal => 'Подытог';

  @override
  String get comment_create_invoice_information_section =>
      '==== Create Invoice Information Section ====';

  @override
  String get createInvoiceInformationSectionTitle => 'Данные счёта';

  @override
  String get createInvoiceInformationSectionInvoiceTo => 'Плательщик';

  @override
  String get createInvoiceInformationSectionEmailAddress => 'Email';

  @override
  String get createInvoiceInformationSectionAddress => 'Адрес';

  @override
  String get createInvoiceInformationSectionWallet => 'Кошелёк';

  @override
  String get createInvoiceInformationSectionStatus => 'Статус';

  @override
  String get createInvoiceInformationSectionIssueDate => 'Дата выставления';

  @override
  String get createInvoiceInformationSectionWalletNotFound =>
      'Кошельки не найдены';

  @override
  String get createInvoiceInformationSectionWalletHint => 'Выберите кошелёк';

  @override
  String get createInvoiceInformationSectionStatusTitle => 'Статус';

  @override
  String get createInvoiceInformationSectionStatusNotFound =>
      'Статус не найден';

  @override
  String get createInvoiceInformationSectionStatusDraft => 'Черновик';

  @override
  String get createInvoiceInformationSectionStatusPublished => 'Опубликован';

  @override
  String get comment_make_payment_screen => '==== Make Payment Screen ====';

  @override
  String get makePaymentScreenTitle => 'Совершить платёж';

  @override
  String get makePaymentScreenWalletsNotFound => 'Кошельки не найдены';

  @override
  String get makePaymentScreenBalance => 'Баланс';

  @override
  String get makePaymentScreenHistory => 'История платежей';

  @override
  String get comment_make_payment_amount_step_section =>
      '==== Make Payment Amount Step Section ====';

  @override
  String get makePaymentAmountStepSectionMerchantId => 'ID мерчанта';

  @override
  String get makePaymentAmountStepSectionAmount => 'Сумма';

  @override
  String get makePaymentAmountStepSectionMinLimit => 'Минимум';

  @override
  String get makePaymentAmountStepSectionMaxLimit => 'и максимум';

  @override
  String get makePaymentAmountStepSectionMakePaymentButton => 'Оплатить';

  @override
  String get makePaymentAmountStepSectionSavedMerchantsButton =>
      'Сохранённые мерчанты';

  @override
  String get makePaymentAmountStepSectionInvalidQrCodeDigits =>
      'Неверный QR-код. MID мерчанта должен состоять только из цифр.';

  @override
  String get makePaymentAmountStepSectionInvalidQrCodePrefix =>
      'Неверный QR-код. Префикс MID не найден.';

  @override
  String get makePaymentAmountStepSectionMerchantsTitle => 'Мерчанты';

  @override
  String get makePaymentAmountStepSectionAddMerchant => 'Добавить мерчанта';

  @override
  String get makePaymentAmountStepSectionMidLabel => 'MID:';

  @override
  String get makePaymentAmountStepSectionDeleteConfirmationTitle =>
      'Вы уверены?';

  @override
  String get makePaymentAmountStepSectionDeleteConfirmationMessage =>
      'Удалить этого мерчанта?';

  @override
  String get makePaymentAmountStepSectionDeleteButton => 'Удалить';

  @override
  String get makePaymentAmountStepSectionCancelButton => 'Отмена';

  @override
  String get comment_make_payment_review_step_section =>
      '==== Make Payment Review Step Section ====';

  @override
  String get makePaymentReviewStepSectionTitle => 'Проверка данных';

  @override
  String get makePaymentReviewStepSectionAmount => 'Сумма';

  @override
  String get makePaymentReviewStepSectionWallet => 'Кошелёк';

  @override
  String get makePaymentReviewStepSectionMerchantAccount => 'Счёт мерчанта';

  @override
  String get makePaymentReviewStepSectionCharge => 'Комиссия';

  @override
  String get makePaymentReviewStepSectionTotalAmount => 'Итоговая сумма';

  @override
  String get makePaymentReviewStepSectionBackButton => 'Назад';

  @override
  String get makePaymentReviewStepSectionConfirmButton => 'Подтвердить';

  @override
  String get comment_make_payment_success_step_section =>
      '==== Make Payment Success Step Section ====';

  @override
  String get makePaymentSuccessStepSectionTitle => 'Платёж выполнен!';

  @override
  String get makePaymentSuccessStepSectionAmount => 'Сумма';

  @override
  String get makePaymentSuccessStepSectionTransactionId => 'ID транзакции';

  @override
  String get makePaymentSuccessStepSectionWalletName => 'Название кошелька';

  @override
  String get makePaymentSuccessStepSectionPaymentMethod => 'Способ оплаты';

  @override
  String get makePaymentSuccessStepSectionCharge => 'Комиссия';

  @override
  String get makePaymentSuccessStepSectionType => 'Тип';

  @override
  String get makePaymentSuccessStepSectionFinalAmount => 'Итоговая сумма';

  @override
  String get makePaymentSuccessStepSectionPaymentAgainButton =>
      'Оплатить снова';

  @override
  String get makePaymentSuccessStepSectionBackHomeButton => 'На главную';

  @override
  String get comment_make_payment_history_screen =>
      '==== Make Payment History Screen ====';

  @override
  String get makePaymentHistoryScreenTitle => 'История платежей';

  @override
  String get comment_make_payment_filter_bottom_sheet =>
      '==== Make Payment Filter Bottom Sheet ====';

  @override
  String get makePaymentFilterTransactionId => 'ID транзакции';

  @override
  String get makePaymentFilterStatus => 'Статус';

  @override
  String get makePaymentFilterApplyButton => 'Фильтр';

  @override
  String get makePaymentFilterResetButton => 'Сбросить';

  @override
  String get comment_qr_code_screen => '==== QR Code Screen ====';

  @override
  String get qrCodeScreenTitle => 'Мой QR-код';

  @override
  String get qrCodeScreenDownloadButton => 'Скачать';

  @override
  String get qrCodeScreenPermissionRequired =>
      'Требуется разрешение. Разрешите доступ в настройках.';

  @override
  String get qrCodeScreenDownloadSuccess => 'Успешно загружено!';

  @override
  String get comment_referral_screen => '==== Referral Screen ====';

  @override
  String get referralScreenTitle => 'Реферальная программа';

  @override
  String get referralScreenEarnAmount => 'Заработок';

  @override
  String get referralScreenAfterInviting => 'После приглашения';

  @override
  String get referralScreenOneMember => 'Один участник';

  @override
  String get referralScreenNoCode => 'Нет кода';

  @override
  String get referralScreenCodeCopied => 'Код скопирован';

  @override
  String get referralScreenShareButton => 'Поделиться';

  @override
  String get referralScreenReferredFriends => 'Приглашённые друзья';

  @override
  String get comment_referred_friends_screen =>
      '==== Referred Friends Screen ====';

  @override
  String get referredFriendsScreenTitle => 'Приглашённые друзья';

  @override
  String get referredFriendsScreenReferralTreeButton => 'Реферальное дерево';

  @override
  String get comment_referred_friend_list => '==== Referred Friend List ====';

  @override
  String get referredFriendListJoinedOn => 'Дата регистрации';

  @override
  String get referredFriendListActive => 'Активен';

  @override
  String get referredFriendListInactive => 'Неактивен';

  @override
  String get comment_referral_tree_screen => '==== Referral Tree Screen ====';

  @override
  String get referralTreeScreenTitle => 'Реферальное дерево';

  @override
  String get comment_request_money_screen => '==== Request Money Screen ====';

  @override
  String get requestMoneyScreenTitle => 'Запрос средств';

  @override
  String get comment_request_money_amount_step_section =>
      '==== Request Money Amount Step Section ====';

  @override
  String get requestMoneyAmountStepSectionRecipientId => 'ID получателя';

  @override
  String get requestMoneyAmountStepSectionRequestAmount => 'Сумма запроса';

  @override
  String get requestMoneyAmountStepSectionMin => 'Минимум';

  @override
  String get requestMoneyAmountStepSectionMax => 'и максимум';

  @override
  String get requestMoneyAmountStepSectionNote => 'Примечание';

  @override
  String get requestMoneyAmountStepSectionRequestMoneyButton =>
      'Запросить средства';

  @override
  String get requestMoneyAmountStepSectionInvalidQrCodeDigits =>
      'Неверный QR-код. UID получателя должен состоять только из цифр.';

  @override
  String get requestMoneyAmountStepSectionInvalidQrCodePrefix =>
      'Неверный QR-код. Префикс UID не найден.';

  @override
  String get comment_request_money_header_section =>
      '==== Request Money Header Section ====';

  @override
  String get requestMoneyHeaderSectionTitle => 'Запрос средств';

  @override
  String get requestMoneyHeaderSectionRequestMoneyButton =>
      'Запросить средства';

  @override
  String get requestMoneyHeaderSectionReceivedRequestButton =>
      'Полученные запросы';

  @override
  String get requestMoneyHeaderSectionHistory => 'История запросов средств';

  @override
  String get comment_request_money_review_step_section =>
      '==== Request Money Review Step Section ====';

  @override
  String get requestMoneyReviewStepSectionTitle => 'Проверка данных';

  @override
  String get requestMoneyReviewStepSectionAmount => 'Сумма';

  @override
  String get requestMoneyReviewStepSectionWalletName => 'Название кошелька';

  @override
  String get requestMoneyReviewStepSectionRecipientUid => 'UID получателя';

  @override
  String get requestMoneyReviewStepSectionBackButton => 'Назад';

  @override
  String get requestMoneyReviewStepSectionConfirmButton => 'Подтвердить';

  @override
  String get comment_request_money_success_step_section =>
      '==== Request Money Success Step Section ====';

  @override
  String get requestMoneySuccessStepSectionTitle => 'Запрос отправлен!';

  @override
  String get requestMoneySuccessStepSectionAmount => 'Сумма';

  @override
  String get requestMoneySuccessStepSectionRecipientName => 'Имя получателя';

  @override
  String get requestMoneySuccessStepSectionRequestWalletName =>
      'Кошелёк запроса';

  @override
  String get requestMoneySuccessStepSectionCharge => 'Комиссия';

  @override
  String get requestMoneySuccessStepSectionFinalAmount => 'Итоговая сумма';

  @override
  String get requestMoneySuccessStepSectionStatus => 'Статус';

  @override
  String get requestMoneySuccessStepSectionRequestAgainButton =>
      'Запросить снова';

  @override
  String get requestMoneySuccessStepSectionBackHomeButton => 'На главную';

  @override
  String get comment_request_money_wallet_section =>
      '==== Request Money Wallet Section ====';

  @override
  String get requestMoneyWalletSectionBalance => 'Баланс';

  @override
  String get requestMoneyWalletSectionWalletsNotFound => 'Кошельки не найдены';

  @override
  String get comment_request_money_history_screen =>
      '==== Request Money History Screen ====';

  @override
  String get requestMoneyHistoryScreenTitle => 'История запросов средств';

  @override
  String get requestMoneyHistoryRequestedAt => 'Дата запроса:';

  @override
  String get requestMoneyHistoryStatus => 'Статус: ';

  @override
  String get comment_request_money_history_details =>
      '==== Request Money History Details ====';

  @override
  String get requestMoneyHistoryDetailsRequestEmail => 'Эл. почта запроса';

  @override
  String get requestMoneyHistoryDetailsCurrency => 'Валюта';

  @override
  String get requestMoneyHistoryDetailsCharge => 'Комиссия';

  @override
  String get requestMoneyHistoryDetailsFinalAmount => 'Итоговая сумма';

  @override
  String get requestMoneyHistoryDetailsRequestAt => 'Дата запроса';

  @override
  String get requestMoneyHistoryDetailsStatus => 'Статус';

  @override
  String get comment_received_request_screen =>
      '==== Received Request Screen ====';

  @override
  String get receivedRequestRequestedAt => 'Дата запроса:';

  @override
  String get receivedRequestStatus => 'Статус: ';

  @override
  String get receivedRequestRejectButton => 'Отклонить';

  @override
  String get receivedRequestAcceptButton => 'Принять';

  @override
  String get comment_accept_request_dropdown =>
      '==== Accept Request Dropdown ====';

  @override
  String get acceptRequestDropdownTitle => 'Вы уверены?';

  @override
  String get acceptRequestDropdownMessage =>
      'Вы хотите принять этот запрос денег?';

  @override
  String get acceptRequestDropdownPayableAmount => 'Сумма к оплате:';

  @override
  String get acceptRequestDropdownPayWallet => 'Оплата с кошелька:';

  @override
  String get acceptRequestDropdownRequesterNote => 'Заметка отправителя:';

  @override
  String get acceptRequestDropdownNoteNotFound => 'Заметка не найдена';

  @override
  String get acceptRequestDropdownAcceptButton => 'Принять';

  @override
  String get acceptRequestDropdownCancelButton => 'Отмена';

  @override
  String get comment_received_request_details =>
      '==== Received Request Details ====';

  @override
  String get receivedRequestDetailsRequestEmail => 'Эл. почта запроса';

  @override
  String get receivedRequestDetailsCurrency => 'Валюта';

  @override
  String get receivedRequestDetailsCharge => 'Комиссия';

  @override
  String get receivedRequestDetailsFinalAmount => 'Итоговая сумма';

  @override
  String get receivedRequestDetailsRequestAt => 'Дата запроса';

  @override
  String get receivedRequestDetailsStatus => 'Статус';

  @override
  String get comment_change_password_screen =>
      '==== Change Password Screen ====';

  @override
  String get changePasswordScreenTitle => 'Смена пароля';

  @override
  String get changePasswordCurrentPassword => 'Текущий пароль';

  @override
  String get changePasswordNewPassword => 'Новый пароль';

  @override
  String get changePasswordConfirmPassword => 'Подтвердите пароль';

  @override
  String get changePasswordSaveChangesButton => 'Сохранить изменения';

  @override
  String get comment_id_verification_screen =>
      '==== ID Verification Screen ====';

  @override
  String get idVerificationScreenTitle => 'KYC';

  @override
  String get idVerificationHistoryButton => 'История KYC';

  @override
  String get idVerificationCenterTitle => 'Центр верификации';

  @override
  String get idVerificationNothingToSubmit => 'Вам нечего отправлять';

  @override
  String get kycStatusVerified =>
      'Вы отправили документы, и они верифицированы';

  @override
  String get kycStatusPending =>
      'Вы отправили документы, и они ожидают одобрения';

  @override
  String get kycStatusRejected =>
      'Не удалось пройти верификацию KYC. Пожалуйста, отправьте документы повторно.';

  @override
  String get kycStatusNotSubmitted => 'Вы ещё не отправляли документы KYC';

  @override
  String get comment_kyc_history_screen => '==== KYC History Screen ====';

  @override
  String get kycHistoryScreenTitle => 'История KYC';

  @override
  String get kycHistoryDate => 'Дата:';

  @override
  String get kycHistoryStatus => 'Статус: ';

  @override
  String get kycHistoryStatusPending => 'В ожидании';

  @override
  String get kycHistoryStatusApproved => 'Одобрено';

  @override
  String get kycHistoryStatusRejected => 'Отклонено';

  @override
  String get kycHistoryViewButton => 'Просмотр';

  @override
  String get comment_kyc_details_bottom_sheet =>
      '==== KYC Details Bottom Sheet ====';

  @override
  String get kycDetailsTitle => 'Данные KYC';

  @override
  String get kycDetailsStatus => 'Статус:';

  @override
  String get kycDetailsCreatedAt => 'Дата создания:';

  @override
  String get kycDetailsMessageFromAdmin => 'Сообщение от администратора:';

  @override
  String get kycDetailsSubmittedData => 'Отправленные данные';

  @override
  String get kycDetailsStatusPending => 'В ожидании';

  @override
  String get kycDetailsStatusApproved => 'Одобрено';

  @override
  String get kycDetailsStatusRejected => 'Отклонено';

  @override
  String get comment_notifications_screen => '==== Notifications Screen ====';

  @override
  String get notificationsScreenTitle => 'Все уведомления';

  @override
  String get notificationsMarkAllReadButton => 'Отметить все как прочитанные';

  @override
  String get comment_profile_settings_screen =>
      '==== Profile Settings Screen ====';

  @override
  String get profileSettingsScreenTitle => 'Настройки профиля';

  @override
  String get profileSettingsFirstName => 'Имя';

  @override
  String get profileSettingsLastName => 'Фамилия';

  @override
  String get profileSettingsUserName => 'Имя пользователя';

  @override
  String get profileSettingsGender => 'Пол';

  @override
  String get profileSettingsDateOfBirth => 'Дата рождения';

  @override
  String get profileSettingsEmailAddress => 'Адрес эл. почты';

  @override
  String get profileSettingsPhone => 'Телефон';

  @override
  String get profileSettingsCountry => 'Страна';

  @override
  String get profileSettingsCity => 'Город';

  @override
  String get profileSettingsZipCode => 'Почтовый индекс';

  @override
  String get profileSettingsJoiningDate => 'Дата регистрации';

  @override
  String get profileSettingsAddress => 'Адрес';

  @override
  String get profileSettingsGenderTitle => 'Пол';

  @override
  String get profileSettingsGenderNotFound => 'Пол не найден';

  @override
  String get profileSettingsGenderMale => 'Мужской';

  @override
  String get profileSettingsGenderFemale => 'Женский';

  @override
  String get profileSettingsGenderOther => 'Другой';

  @override
  String get profileSettingsSelectGender => 'Выберите пол';

  @override
  String get profileSettingsCountryTitle => 'Страна';

  @override
  String get profileSettingsCountryNotFound => 'Страна не найдена';

  @override
  String get profileSettingsSelectCountry => 'Выберите страну';

  @override
  String get profileSettingsSaveChangesButton => 'Сохранить изменения';

  @override
  String get comment_support_tickets_screen =>
      '==== Support Tickets Screen ====';

  @override
  String get supportTicketsScreenTitle => 'Обращение в поддержку';

  @override
  String get supportTicketsCreateTicketButton => 'Создать обращение';

  @override
  String get supportTicketsLastUpdate => 'Последнее обновление';

  @override
  String get supportTicketsRequestedAt => 'Дата обращения';

  @override
  String get supportTicketsPriorityHigh => 'Высокий';

  @override
  String get supportTicketsPriorityMedium => 'Средний';

  @override
  String get supportTicketsPriorityLow => 'Низкий';

  @override
  String get supportTicketsStatus => 'Статус: ';

  @override
  String get supportTicketsStatusOpen => 'Открыто';

  @override
  String get supportTicketsStatusClose => 'Закрыть';

  @override
  String get supportTicketsStatusInProgress => 'В работе';

  @override
  String get supportTicketsStatusWaitingUser => 'Ожидает вашего ответа';

  @override
  String get supportTicketsStatusResolved => 'Решено';

  @override
  String get supportTicketsStatusClosed => 'Закрыто';

  @override
  String get supportTicketsStatusArchived => 'В архиве';

  @override
  String get supportTicketsReplyButton => 'Ответить';

  @override
  String get comment_ticket_details => '==== Ticket Details ====';

  @override
  String get ticketDetailsTitle => 'Детали обращения';

  @override
  String get ticketDetailsTicketId => 'ID обращения';

  @override
  String get ticketDetailsCategory => 'Категория';

  @override
  String get ticketDetailsPriority => 'Приоритет';

  @override
  String get ticketDetailsCreatedOn => 'Дата создания';

  @override
  String get ticketDetailsLastUpdated => 'Последнее обновление';

  @override
  String get ticketDetailsPriorityHigh => 'Высокий';

  @override
  String get ticketDetailsPriorityMedium => 'Средний';

  @override
  String get ticketDetailsPriorityLow => 'Низкий';

  @override
  String get comment_replay_ticket_screen => '==== Replay Ticket Screen ====';

  @override
  String get replayTicketMarkAsClosedButton => 'Отметить как закрытый';

  @override
  String get replayTicketMessageHint => 'Введите сообщение...';

  @override
  String get replayTicketEmptyMessageError => 'Пожалуйста, введите сообщение';

  @override
  String get replayTicketAttachmentsLabel => 'Вложения:';

  @override
  String get replayTicketUnknownFile => 'Неизвестный файл';

  @override
  String get replayTicketAttachmentPreviewTitle => 'Предпросмотр вложения';

  @override
  String get replayTicketAttachmentError => 'Что-то пошло не так!';

  @override
  String get comment_add_new_ticket_screen => '==== Add New Ticket Screen ====';

  @override
  String get addNewTicketScreenTitle => 'Создать тикет';

  @override
  String get addNewTicketTitle => 'Заголовок';

  @override
  String get addNewTicketDescription => 'Описание';

  @override
  String get addNewTicketAttachments => 'Вложения';

  @override
  String get addNewTicketAttachFile => 'Прикрепить файл';

  @override
  String get addNewTicketAddButton => 'Создать тикет';

  @override
  String get comment_two_factor_authentication_screen =>
      '==== Two Factor Authentication Screen ====';

  @override
  String get twoFactorAuthenticationScreenTitle =>
      'Двухфакторная аутентификация';

  @override
  String get comment_disable_2fa_section => '==== Disable 2FA Section ====';

  @override
  String get disable2FaSectionTitle => 'Двухфакторная аутентификация (2FA)';

  @override
  String get disable2FaSectionDescription => 'noInternetConnectionRetryButton';

  @override
  String get disable2FaSectionDisableButton => 'Отключить 2FA';

  @override
  String get disable2FaSectionPasswordRequired => 'Введите пароль';

  @override
  String get comment_enable_2fa_section => '==== Enable 2FA Section ====';

  @override
  String get enable2FaSectionTitle => 'Двухфакторная аутентификация (2FA)';

  @override
  String get enable2FaSectionDescription =>
      'Отсканируйте QR-код в приложении\nGoogle Authenticator, чтобы включить 2FA';

  @override
  String get enable2FaSectionPinLabel =>
      'PIN-код из приложения Google Authenticator';

  @override
  String get enable2FaSectionEnableButton => 'Включить 2FA';

  @override
  String get enable2FaSectionPinRequired =>
      'Введите PIN-код из Google Authenticator';

  @override
  String get comment_generate_2fa_section => '==== Generate 2FA Section ====';

  @override
  String get generate2FaSectionTitle => 'Двухфакторная аутентификация (2FA)';

  @override
  String get generate2FaSectionDescription =>
      'Повысьте безопасность аккаунта с помощью двухфакторной аутентификации';

  @override
  String get generate2FaSectionGenerateButton => 'Настроить 2FA';

  @override
  String get comment_settings_screen => '==== Settings Screen ====';

  @override
  String get settingsScreenTitle => 'Настройки';

  @override
  String get settingsProfileSettings => 'Настройки профиля';

  @override
  String get settingsChangePassword => 'Сменить пароль';

  @override
  String get settingsAllNotification => 'Все уведомления';

  @override
  String get settingsTwoFactorAuthentication =>
      'Двухфакторная аутентификация (2FA)';

  @override
  String get settingsIdVerification => 'Проверка личности';

  @override
  String get settingsSupport => 'Поддержка';

  @override
  String get settingsSignOut => 'Выйти';

  @override
  String get settingsKycVerified => 'Верифицирован';

  @override
  String get settingsKycPending => 'В ожидании';

  @override
  String get settingsKycFailed => 'Не пройдена';

  @override
  String get settingsKycNotSubmitted => 'Не отправлено';

  @override
  String get comment_transactions_screen => '==== Transactions Screen ====';

  @override
  String get transactionsScreenTitle => 'Мои транзакции';

  @override
  String get comment_transactions_popup => '==== Transactions Popup ====';

  @override
  String get transactionsPopupDate => 'Дата';

  @override
  String get transactionsPopupTransactionId => 'ID транзакции';

  @override
  String get transactionsPopupWalletName => 'Название кошелька';

  @override
  String get transactionsPopupAmount => 'Сумма';

  @override
  String get transactionsPopupCharge => 'Комиссия';

  @override
  String get transactionsPopupFinalAmount => 'Итоговая сумма';

  @override
  String get transactionsPopupStatus => 'Статус';

  @override
  String get transactionsPopupClose => 'Закрыть';

  @override
  String get transactionsPopupReceiptTitle => 'Квитанция о транзакции';

  @override
  String get shareReceipt => 'Поделиться квитанцией';

  @override
  String get shareReceiptBody => 'Моя квитанция о транзакции eCardo';

  @override
  String get shareReceiptFailed => 'Не удалось поделиться квитанцией.';

  @override
  String get comment_transaction_filter_bottom_sheet =>
      '==== Transaction Filter Bottom Sheet ====';

  @override
  String get transactionFilterTransactionId => 'ID транзакции';

  @override
  String get transactionFilterStatus => 'Статус';

  @override
  String get transactionFilterApplyButton => 'Фильтр';

  @override
  String get transactionFilterResetButton => 'Сбросить';

  @override
  String get comment_transfer_screen => '==== Transfer Screen ====';

  @override
  String get transferScreenTitle => 'Перевод денег';

  @override
  String get transferHistoryTransferHistory => 'История переводов';

  @override
  String get transferHistoryReceivedHistory => 'История получения';

  @override
  String get comment_transfer_received_history_screen =>
      '==== Transfer Received History Screen ====';

  @override
  String get transferReceivedHistoryScreenTitle => 'История получения';

  @override
  String get comment_transfer_received_filter_bottom_sheet =>
      '==== Transfer Received Filter Bottom Sheet ====';

  @override
  String get transferReceivedFilterTransactionId => 'ID транзакции';

  @override
  String get transferReceivedFilterStatus => 'Статус';

  @override
  String get transferReceivedFilterApplyButton => 'Фильтр';

  @override
  String get transferReceivedFilterResetButton => 'Сбросить';

  @override
  String get comment_transfer_history_screen =>
      '==== Transfer History Screen ====';

  @override
  String get transferHistoryScreenTitle => 'История переводов';

  @override
  String get comment_transfer_transaction_filter_bottom_sheet =>
      '==== Transfer Transaction Filter Bottom Sheet ====';

  @override
  String get transferTransactionFilterTransactionId => 'ID транзакции';

  @override
  String get transferTransactionFilterStatus => 'Статус';

  @override
  String get transferTransactionFilterApplyButton => 'Фильтр';

  @override
  String get transferTransactionFilterResetButton => 'Сбросить';

  @override
  String get comment_transfer_amount_step_section =>
      '==== Transfer Amount Step Section ====';

  @override
  String get transferAmountStepSectionRecipientUid => 'UID получателя';

  @override
  String get transferAmountStepSectionAmount => 'Сумма';

  @override
  String get transferAmountStepSectionMin => 'Минимум';

  @override
  String get transferAmountStepSectionMax => 'и максимум';

  @override
  String get transferAmountStepSectionTransferMoneyButton => 'Перевести деньги';

  @override
  String get transferAmountStepSectionSavedBeneficiaryButton =>
      'Сохранённый получатель';

  @override
  String get transferAmountStepSectionInvalidQrCodeDigits =>
      'Неверный QR-код. UID получателя должен состоять только из цифр.';

  @override
  String get transferAmountStepSectionInvalidQrCodePrefix =>
      'Неверный QR-код. Префикс UID не найден.';

  @override
  String get transferAmountStepSectionBeneficiariesTitle => 'Получатели';

  @override
  String get transferAmountStepSectionAddBeneficiary => 'Добавить получателя';

  @override
  String get transferAmountStepSectionUidLabel => 'UID:';

  @override
  String get transferAmountStepSectionDeleteConfirmationTitle => 'Вы уверены?';

  @override
  String get transferAmountStepSectionDeleteConfirmationMessage =>
      'Удалить этого получателя?';

  @override
  String get transferAmountStepSectionDeleteButton => 'Удалить';

  @override
  String get transferAmountStepSectionCancelButton => 'Отмена';

  @override
  String get comment_transfer_review_step_section =>
      '==== Transfer Review Step Section ====';

  @override
  String get transferReviewStepSectionTitle => 'Проверка данных';

  @override
  String get transferReviewStepSectionAmount => 'Сумма';

  @override
  String get transferReviewStepSectionWallet => 'Кошелёк';

  @override
  String get transferReviewStepSectionRecipientAccount => 'Счёт получателя';

  @override
  String get transferReviewStepSectionCharge => 'Комиссия';

  @override
  String get transferReviewStepSectionTotalAmount => 'Общая сумма';

  @override
  String get transferReviewStepSectionBackButton => 'Назад';

  @override
  String get transferReviewStepSectionConfirmButton => 'Подтвердить';

  @override
  String get comment_transfer_success_step_section =>
      '==== Transfer Success Step Section ====';

  @override
  String get transferSuccessStepSectionTitle => 'Перевод выполнен!';

  @override
  String get transferSuccessStepSectionAmount => 'Сумма';

  @override
  String get transferSuccessStepSectionTransactionId => 'ID транзакции';

  @override
  String get transferSuccessStepSectionWalletName => 'Название кошелька';

  @override
  String get transferSuccessStepSectionPaymentMethod => 'Способ оплаты';

  @override
  String get transferSuccessStepSectionDateTime => 'Дата и время';

  @override
  String get transferSuccessStepSectionName => 'Имя';

  @override
  String get transferSuccessStepSectionCharge => 'Комиссия';

  @override
  String get transferSuccessStepSectionTotalAmount => 'Общая сумма';

  @override
  String get transferSuccessStepSectionTransferAgainButton => 'Перевести снова';

  @override
  String get transferSuccessStepSectionBackHomeButton => 'На главную';

  @override
  String get comment_transfer_wallet_section =>
      '==== Transfer Wallet Section ====';

  @override
  String get transferWalletSectionBalance => 'Баланс';

  @override
  String get transferWalletSectionWalletsNotFound => 'Кошельки не найдены';

  @override
  String get comment_wallets_screen => '==== Wallets Screen ====';

  @override
  String get walletsScreenTitle => 'Мои кошельки';

  @override
  String get comment_delete_wallet_bottom_sheet =>
      '==== Delete Wallet Bottom Sheet ====';

  @override
  String get deleteWalletBottomSheetTitle => 'Вы уверены?';

  @override
  String get deleteWalletBottomSheetMessage =>
      'Вы хотите удалить этот кошелёк?';

  @override
  String get deleteWalletBottomSheetDeleteButton => 'Удалить';

  @override
  String get deleteWalletBottomSheetCancelButton => 'Отмена';

  @override
  String get comment_wallet_list_section => '==== Wallet List Section ====';

  @override
  String get walletListSectionTopUpButton => 'Пополнить';

  @override
  String get walletListSectionWithdrawButton => 'Вывести';

  @override
  String get walletListSectionUserDepositNotEnabled => 'Пополнение недоступно';

  @override
  String get walletListSectionUserWithdrawNotEnabled => 'Вывод недоступен';

  @override
  String get comment_create_new_wallet_screen =>
      '==== Create New Wallet Screen ====';

  @override
  String get createNewWalletScreenTitle => 'Создать новый кошелёк';

  @override
  String get createNewWalletCurrency => 'Валюта';

  @override
  String get createNewWalletSelectCurrency => 'Выберите валюту';

  @override
  String get createNewWalletCurrencyNotFound => 'Валюта не найдена';

  @override
  String get createNewWalletCreateButton => 'Создать';

  @override
  String get comment_withdraw_screen => '==== Withdraw Screen ====';

  @override
  String get withdrawScreenTitle => 'Вывод денег';

  @override
  String get withdrawScreenAddAccountButton => 'Добавить счёт';

  @override
  String get comment_withdraw_history_screen =>
      '==== Withdraw History Screen ====';

  @override
  String get withdrawHistoryScreenTitle => 'История выводов';

  @override
  String get comment_withdraw_transaction_filter_bottom_sheet =>
      '==== Withdraw Transaction Filter Bottom Sheet ====';

  @override
  String get withdrawTransactionFilterTransactionId => 'ID транзакции';

  @override
  String get withdrawTransactionFilterStatus => 'Статус';

  @override
  String get withdrawTransactionFilterApplyButton => 'Фильтр';

  @override
  String get withdrawTransactionFilterResetButton => 'Сбросить';

  @override
  String get comment_delete_account_dropdown_section =>
      '==== Delete Account Dropdown Section ====';

  @override
  String get deleteAccountDropdownTitle => 'Вы уверены?';

  @override
  String get deleteAccountDropdownMessage => 'Вы хотите удалить этот аккаунт?';

  @override
  String get deleteAccountDropdownDeleteButton => 'Удалить';

  @override
  String get deleteAccountDropdownCancelButton => 'Отмена';

  @override
  String get comment_withdraw_account_filter_bottom_sheet =>
      '==== Withdraw Account Filter Bottom Sheet ====';

  @override
  String get withdrawAccountFilterMethodName => 'Название способа';

  @override
  String get withdrawAccountFilterApplyButton => 'Фильтр';

  @override
  String get comment_withdraw_account_section =>
      '==== Withdraw Account Section ====';

  @override
  String get withdrawAccountSectionTitle => 'Все счета';

  @override
  String get comment_withdraw_amount_step_section =>
      '==== Withdraw Amount Step Section ====';

  @override
  String get withdrawAmountStepSectionWithdrawAccount => 'Счёт для вывода';

  @override
  String get withdrawAmountStepSectionAmount => 'Сумма';

  @override
  String get withdrawAmountStepSectionMin => 'Минимум';

  @override
  String get withdrawAmountStepSectionMax => 'и максимум';

  @override
  String get withdrawAmountStepSectionWithdrawMoneyButton => 'Вывести деньги';

  @override
  String get withdrawAmountStepSectionWithdrawAccountTitle => 'Счёт для вывода';

  @override
  String get withdrawAmountStepSectionNoAccountsFound =>
      'Счета для вывода не найдены';

  @override
  String get withdrawAmountStepSectionCurrencyLabel => 'Валюта:';

  @override
  String get withdrawAmountStepSectionMinDescription => 'Мин.:';

  @override
  String get withdrawAmountStepSectionMaxDescription => 'Макс.:';

  @override
  String get comment_withdraw_header_section =>
      '==== Withdraw Header Section ====';

  @override
  String get withdrawHeaderSectionTitle => 'Вывод денег';

  @override
  String get withdrawHeaderSectionWithdrawButton => 'Вывести';

  @override
  String get withdrawHeaderSectionWithdrawAccountButton => 'Счёт для вывода';

  @override
  String get withdrawHeaderSectionHistory => 'История выводов';

  @override
  String get comment_withdraw_review_step_section =>
      '==== Withdraw Review Step Section ====';

  @override
  String get withdrawReviewStepSectionTitle => 'Проверка данных';

  @override
  String get withdrawReviewStepSectionAmount => 'Сумма';

  @override
  String get withdrawReviewStepSectionCharge => 'Комиссия';

  @override
  String get withdrawReviewStepSectionTotalAmount => 'Общая сумма';

  @override
  String get withdrawReviewStepSectionBackButton => 'Назад';

  @override
  String get withdrawReviewStepSectionConfirmButton => 'Подтвердить';

  @override
  String get comment_withdraw_success_step_section =>
      '==== Withdraw Success Step Section ====';

  @override
  String get withdrawSuccessStepSectionTitle => 'Вывод выполнен!';

  @override
  String get withdrawSuccessStepSectionAmount => 'Сумма';

  @override
  String get withdrawSuccessStepSectionTransactionId => 'ID транзакции';

  @override
  String get withdrawSuccessStepSectionCharge => 'Комиссия';

  @override
  String get withdrawSuccessStepSectionTransactionType => 'Тип транзакции';

  @override
  String get withdrawSuccessStepSectionFinalAmount => 'Итоговая сумма';

  @override
  String get withdrawSuccessStepSectionWithdrawAgainButton => 'Вывести снова';

  @override
  String get withdrawSuccessStepSectionBackHomeButton => 'На главную';

  @override
  String get comment_edit_withdraw_account_screen =>
      '==== Edit Withdraw Account Screen ====';

  @override
  String get editWithdrawAccountTitle => 'Изменить счёт для вывода';

  @override
  String get editWithdrawAccountMethodName => 'Название метода';

  @override
  String get editWithdrawAccountMethodNameHint => 'Введите название метода';

  @override
  String get editWithdrawAccountFieldHint => 'Напишите здесь...';

  @override
  String get editWithdrawAccountGenericFieldHint => 'Введите';

  @override
  String get editWithdrawAccountUpdateButton => 'Сохранить счёт';

  @override
  String get comment_create_withdraw_account_screen =>
      '==== Create Withdraw Account Screen ====';

  @override
  String get createWithdrawAccountTitle => 'Создать счёт для вывода';

  @override
  String get createWithdrawAccountWallet => 'Кошелёк';

  @override
  String get createWithdrawAccountWithdrawMethod => 'Метод вывода';

  @override
  String get createWithdrawAccountMethodName => 'Название метода';

  @override
  String get createWithdrawAccountCreateButton => 'Создать счёт';

  @override
  String get createWithdrawAccountWalletsNotFound => 'Кошельки не найдены';

  @override
  String get createWithdrawAccountWithdrawMethodTitle => 'Метод вывода';

  @override
  String get createWithdrawAccountWithdrawMethodNotFound =>
      'Метод вывода не найден';

  @override
  String get createWithdrawAccountFieldHint => 'Напишите здесь...';

  @override
  String get comment_dynamic_attachment_preview =>
      '==== Dynamic Attachment Preview ====';

  @override
  String get dynamicAttachmentPreviewTitle => 'Просмотр вложения';

  @override
  String get comment_no_internet_connection =>
      '==== No Internet Connection ====';

  @override
  String get noInternetConnectionTitle => 'Нет подключения к интернету';

  @override
  String get noInternetConnectionMessage => 'Проверьте настройки сети';

  @override
  String get noInternetConnectionRetryButton => 'Повторить';

  @override
  String get comment_qr_scanner_screen => '==== QR Scanner Screen ====';

  @override
  String get qrScannerScreenInstruction =>
      'Поместите QR-код в рамку для сканирования';

  @override
  String get qrScannerScreenProcessing => 'Обработка...';

  @override
  String get comment_webview_screen => '==== WebView Screen ====';

  @override
  String get webViewScreenPaymentSuccessful => 'Оплата прошла успешно!';

  @override
  String get webViewScreenPaymentFailed => 'Ошибка оплаты!';

  @override
  String get webViewScreenPaymentCancelled => 'Оплата отменена!';

  @override
  String get comment_common_country_dropdown_bottom_sheet =>
      '==== Common Country Dropdown Bottom Sheet ====';

  @override
  String get commonCountryDropdownSearchHint => 'Поиск';

  @override
  String get commonCountryDropdownNotFound => 'Страна не найдена';

  @override
  String get comment_common_dropdown_bottom_sheet =>
      '==== Common Dropdown Bottom Sheet ====';

  @override
  String get commonDropdownSearchHint => 'Поиск';

  @override
  String get comment_common_dropdown_bottom_sheet_three =>
      '==== Common Dropdown Bottom Sheet Three ====';

  @override
  String get commonDropdownThreeSearchHint => 'Поиск';

  @override
  String get comment_common_dropdown_bottom_sheet_two =>
      '==== Common Dropdown Bottom Sheet Two ====';

  @override
  String get commonDropdownTwoSearchHint => 'Поиск';

  @override
  String get comment_common_dropdown_wallet_bottom_sheet =>
      '==== Common Dropdown Wallet Bottom Sheet ====';

  @override
  String get commonDropdownWalletTitle => 'Выберите кошелёк';

  @override
  String get comment_image_picker_dropdown_bottom_sheet =>
      '==== Image Picker Dropdown Bottom Sheet ====';

  @override
  String get imagePickerDropdownTitle => 'Выберите источник изображения';

  @override
  String get imagePickerDropdownCamera => 'Камера';

  @override
  String get imagePickerDropdownGallery => 'Галерея';

  @override
  String get comment_multiple_image_picker_dropdown_bottom_sheet =>
      '==== Multiple Image Picker Dropdown Bottom Sheet ====';

  @override
  String get multipleImagePickerDropdownTitle => 'Источник изображения';

  @override
  String get multipleImagePickerDropdownCamera => 'Камера';

  @override
  String get multipleImagePickerDropdownGallery => 'Галерея';

  @override
  String get comment_navigation_screen => '==== Navigation Screen ====';

  @override
  String get bottomNavHome => 'Главная';

  @override
  String get bottomNavTransfer => 'Перевод';

  @override
  String get bottomNavGift => 'Подарки';

  @override
  String get bottomNavSettings => 'Настройки';

  @override
  String get qrInvalidFormat =>
      'Неверный формат QR-кода. Допускаются только коды AID, MID или UID.';

  @override
  String get userTransferNotEnabled => 'Переводы пользователя недоступны';

  @override
  String get userGiftNotEnabled => 'Подарки пользователя недоступны';

  @override
  String get comment_image_picker_controller =>
      '==== Image Picker Controller ====';

  @override
  String get imagePickerGalleryError =>
      'Не удалось выбрать изображение из галереи';

  @override
  String get imagePickerCameraError => 'Не удалось сделать снимок с камеры';

  @override
  String get comment_multiple_image_picker_controller =>
      '==== Multiple Image Picker Controller ====';

  @override
  String get multipleImagePickerGalleryError =>
      'Не удалось выбрать изображение из галереи';

  @override
  String get multipleImagePickerCameraError =>
      'Не удалось сделать снимок с камеры';

  @override
  String get comment_biometric_auth_service =>
      '==== Biometric Auth Service ====';

  @override
  String get biometricDeviceNotSupported =>
      'Это устройство не поддерживает биометрию.';

  @override
  String get biometricNotEnrolled =>
      'Биометрия не настроена. Настройте отпечаток пальца';

  @override
  String get biometricUnavailable =>
      'Биометрические функции сейчас недоступны.';

  @override
  String get biometricAuthenticationFailed =>
      'Не удалось пройти биометрическую аутентификацию.';

  @override
  String get biometricCheckFailed =>
      'Не удалось проверить доступность биометрии.';

  @override
  String get biometricAuthReason => 'Подтвердите вход';

  @override
  String get comment_network_service => '==== Network Service ====';

  @override
  String get networkErrorGeneric => 'Сетевая ошибка';

  @override
  String get networkErrorTimeout => 'Время ожидания истекло';

  @override
  String get networkErrorOccurred => 'Произошла сетевая ошибка';

  @override
  String get unauthorizedDialogTitle => 'Не авторизован';

  @override
  String get unauthorizedDialogDescription => 'Пожалуйста, войдите снова';

  @override
  String get unauthorizedDialogButton => 'Войти';

  @override
  String get comment_add_money_controller => '==== Add Money Controller ====';

  @override
  String get addMoneySuccess => 'Деньги успешно зачислены';

  @override
  String get addMoneyValidationSelectWallet => 'Выберите кошелёк';

  @override
  String get addMoneyValidationSelectGateway => 'Выберите платёжный шлюз';

  @override
  String get addMoneyValidationEnterAmount => 'Введите сумму';

  @override
  String get addMoneyValidationAmountGreaterThanZero =>
      'Сумма должна быть больше 0';

  @override
  String addMoneyValidationAmountMinimum(Object amount) {
    return 'Сумма не должна превышать $amount';
  }

  @override
  String addMoneyValidationAmountMaximum(Object amount) {
    return 'Сумма не должна превышать $amount';
  }

  @override
  String addMoneyValidationUploadFile(Object fieldName) {
    return 'Загрузите файл для $fieldName';
  }

  @override
  String addMoneyValidationFillField(Object fieldName) {
    return 'Заполните поле $fieldName';
  }

  @override
  String get comment_cash_out_controller => '==== Cash Out Controller ====';

  @override
  String get cashOutValidationSelectWallet => 'Выберите кошелёк';

  @override
  String get cashOutValidationEnterAgentAid => 'Введите AID агента';

  @override
  String get cashOutValidationEnterAmount => 'Введите сумму';

  @override
  String cashOutValidationAmountMinimum(Object amount, Object currency) {
    return 'Минимальная сумма — $amount $currency';
  }

  @override
  String cashOutValidationAmountMaximum(Object amount, Object currency) {
    return 'Максимальная сумма — $amount $currency';
  }

  @override
  String get comment_exchange_controller => '==== Exchange Controller ====';

  @override
  String get exchangeValidationSelectFromWallet => 'Выберите исходный кошелёк';

  @override
  String get exchangeValidationSelectToWallet => 'Выберите целевой кошелёк';

  @override
  String get exchangeValidationEnterAmount => 'Введите сумму';

  @override
  String exchangeValidationAmountMinimum(Object amount, Object currency) {
    return 'Минимальная сумма — $amount $currency';
  }

  @override
  String exchangeValidationAmountMaximum(Object amount, Object currency) {
    return 'Максимальная сумма — $amount $currency';
  }

  @override
  String exchangeValidationInsufficientBalance(Object amount, Object currency) {
    return 'Недостаточно средств — доступно: $amount $currency';
  }

  @override
  String get exchangeValidationSameWallet =>
      'Исходная и целевая валюты должны различаться.';

  @override
  String get dashboardReferralInvited => 'Приглашено';

  @override
  String get dashboardReferralBonus => 'Реферальный бонус';

  @override
  String get comment_create_gift_controller =>
      '==== Create Gift Controller ====';

  @override
  String get createGiftValidationSelectWallet => 'Выберите кошелёк';

  @override
  String get createGiftValidationEnterAmount => 'Введите сумму';

  @override
  String createGiftValidationAmountMinimum(Object amount, Object currency) {
    return 'Минимальная сумма — $amount $currency';
  }

  @override
  String createGiftValidationAmountMaximum(Object amount, Object currency) {
    return 'Максимальная сумма — $amount $currency';
  }

  @override
  String get comment_home_controller => '==== Home Controller ====';

  @override
  String get homeLanguageChangeFailed => 'Не удалось изменить язык';

  @override
  String get homeBiometricDeviceNotSupported =>
      'Это устройство не поддерживает биометрию.';

  @override
  String get homeBiometricAuthenticationFailed =>
      'Аутентификация не пройдена. Настройка биометрии не изменена.';

  @override
  String get homeBiometricEnabledSuccess => 'Биометрия успешно включена';

  @override
  String get homeBiometricDisabledSuccess => 'Биометрия успешно отключена';

  @override
  String get homeBiometricNotFoundTitle => 'Биометрия не найдена';

  @override
  String get homeBiometricNotFoundDescription =>
      'На этом устройстве не настроены отпечаток пальца или биометрия. Вы можете настроить их в системных настройках.';

  @override
  String get homeBiometricOpenSettings => 'Открыть настройки безопасности';

  @override
  String get homeIosBiometricSetup =>
      'Перейдите в Настройки > Face ID и код-пароль, чтобы настроить биометрию.';

  @override
  String get comment_create_invoice_controller =>
      '==== Create Invoice Controller ====';

  @override
  String get createInvoiceValidationEnterInvoiceTo => 'Укажите плательщика';

  @override
  String get createInvoiceValidationEnterEmailAddress => 'Введите email';

  @override
  String get createInvoiceValidationEnterAddress => 'Введите адрес';

  @override
  String get createInvoiceValidationSelectWallet => 'Выберите кошелёк';

  @override
  String get createInvoiceValidationSelectStatus => 'Выберите статус';

  @override
  String get createInvoiceValidationSelectIssueDate =>
      'Выберите дату выставления';

  @override
  String createInvoiceValidationItemNameRequired(Object itemNumber) {
    return 'Позиция $itemNumber: укажите наименование';
  }

  @override
  String createInvoiceValidationItemQuantityGreaterThanZero(Object itemNumber) {
    return 'Позиция $itemNumber: количество должно быть больше 0';
  }

  @override
  String createInvoiceValidationItemUnitPriceGreaterThanZero(
    Object itemNumber,
  ) {
    return 'Позиция $itemNumber: цена за единицу должна быть больше 0';
  }

  @override
  String get comment_make_payment_controller =>
      '==== Make Payment Controller ====';

  @override
  String get makePaymentValidationSelectWallet =>
      'Пожалуйста, выберите кошелёк';

  @override
  String get makePaymentValidationEnterMerchantMid =>
      'Пожалуйста, введите MID мерчанта';

  @override
  String get makePaymentValidationEnterAmount => 'Пожалуйста, введите сумму';

  @override
  String makePaymentValidationAmountMinimum(Object amount, Object currency) {
    return 'Минимальная сумма — $amount $currency';
  }

  @override
  String makePaymentValidationAmountMaximum(Object amount, Object currency) {
    return 'Максимальная сумма — $amount $currency';
  }

  @override
  String get comment_request_money_controller =>
      '==== Request Money Controller ====';

  @override
  String get requestMoneyValidationSelectWallet =>
      'Пожалуйста, выберите кошелёк';

  @override
  String get requestMoneyValidationEnterRecipientUid =>
      'Пожалуйста, введите UID получателя';

  @override
  String get requestMoneyValidationEnterRequestAmount =>
      'Пожалуйста, введите сумму запроса';

  @override
  String requestMoneyValidationAmountMinimum(Object amount, Object currency) {
    return 'Минимальная сумма — $amount $currency';
  }

  @override
  String requestMoneyValidationAmountMaximum(Object amount, Object currency) {
    return 'Максимальная сумма — $amount $currency';
  }

  @override
  String get comment_add_new_ticket_controller =>
      '==== Add New Ticket Controller ====';

  @override
  String get addNewTicketSuccess => 'Тикет успешно создан';

  @override
  String get addNewValidationEnterTitle => 'Введите заголовок';

  @override
  String get addNewValidationEnterDescription => 'Введите описание';

  @override
  String get comment_change_password_controller =>
      '==== Change Password Controller ====';

  @override
  String get changePasswordValidationEnterCurrentPassword =>
      'Введите текущий пароль';

  @override
  String get changePasswordValidationEnterNewPassword => 'Введите новый пароль';

  @override
  String get changePasswordValidationPasswordMinLength =>
      'Пароль должен содержать не менее 8 символов';

  @override
  String get changePasswordValidationEnterConfirmPassword =>
      'Введите подтверждение пароля';

  @override
  String get changePasswordValidationPasswordsDoNotMatch =>
      'Пароли не совпадают';

  @override
  String get comment_transfer_controller => '==== Transfer Controller ====';

  @override
  String get transferValidationSelectWallet => 'Выберите кошелёк';

  @override
  String get transferValidationEnterRecipientUid => 'Укажите UID получателя';

  @override
  String get transferValidationEnterAmount => 'Укажите сумму';

  @override
  String transferValidationAmountMinimum(Object amount, Object currency) {
    return 'Минимальная сумма — $amount $currency';
  }

  @override
  String transferValidationAmountMaximum(Object amount, Object currency) {
    return 'Максимальная сумма — $amount $currency';
  }

  @override
  String get comment_create_withdraw_account_controller =>
      '==== Create Withdraw Account Controller ====';

  @override
  String createWithdrawAccountFileRequiredError(Object fieldName) {
    return 'Для $fieldName требуется файл';
  }

  @override
  String createWithdrawAccountFieldRequiredError(Object fieldName) {
    return 'Поле $fieldName обязательно';
  }

  @override
  String get createWithdrawAccountValidationSelectWallet => 'Выберите кошелёк';

  @override
  String get createWithdrawAccountValidationSelectWithdrawMethod =>
      'Выберите метод вывода';

  @override
  String get createWithdrawAccountValidationEnterMethodName =>
      'Введите название метода';

  @override
  String createWithdrawAccountValidationUploadFile(Object fieldName) {
    return 'Загрузите файл для $fieldName';
  }

  @override
  String createWithdrawAccountValidationFillField(Object fieldName) {
    return 'Заполните поле $fieldName';
  }

  @override
  String get comment_withdraw_controller => '==== Withdraw Controller ====';

  @override
  String get withdrawValidationSelectWithdrawAccount =>
      'Выберите счёт для вывода';

  @override
  String get withdrawValidationEnterAmount => 'Укажите сумму';

  @override
  String withdrawValidationAmountMinimum(Object amount, Object currency) {
    return 'Минимальная сумма — $amount $currency';
  }

  @override
  String withdrawValidationAmountMaximum(Object amount, Object currency) {
    return 'Максимальная сумма — $amount $currency';
  }

  @override
  String get comment_airtime_controller => '==== Airtime Controller ====';

  @override
  String get airtimeCountryRequired => 'Выберите страну';

  @override
  String get airtimeServiceRequired => 'Выберите услугу';

  @override
  String get airtimeAmountRequired => 'Введите сумму';

  @override
  String get airtimeAmountValid => 'Введите корректную сумму';

  @override
  String airtimeDynamicFieldRequired(Object fieldName) {
    return 'Введите $fieldName';
  }

  @override
  String get comment_cable_controller => '==== Cable Controller ====';

  @override
  String get cableCountryRequired => 'Выберите страну';

  @override
  String get cableServiceRequired => 'Выберите услугу';

  @override
  String get cableAmountRequired => 'Введите сумму';

  @override
  String get cableAmountValid => 'Введите корректную сумму';

  @override
  String cableDynamicFieldRequired(Object fieldName) {
    return 'Введите $fieldName';
  }

  @override
  String get comment_toll_controller => '==== Toll Controller ====';

  @override
  String get tollCountryRequired => 'Пожалуйста, выберите страну';

  @override
  String get tollServiceRequired => 'Пожалуйста, выберите услугу';

  @override
  String get tollAmountRequired => 'Пожалуйста, введите сумму';

  @override
  String get tollAmountValid => 'Пожалуйста, введите корректную сумму';

  @override
  String tollDynamicFieldRequired(Object fieldName) {
    return 'Пожалуйста, введите $fieldName';
  }

  @override
  String get comment_electricity_controller =>
      '==== Electricity Controller ====';

  @override
  String get electricityCountryRequired => 'Выберите страну';

  @override
  String get electricityServiceRequired => 'Выберите услугу';

  @override
  String get electricityAmountRequired => 'Введите сумму';

  @override
  String get electricityAmountValid => 'Введите корректную сумму';

  @override
  String electricityDynamicFieldRequired(Object fieldName) {
    return 'Введите $fieldName';
  }

  @override
  String get comment_internet_controller => '==== Internet Controller ====';

  @override
  String get internetCountryRequired => 'Выберите страну';

  @override
  String get internetServiceRequired => 'Пожалуйста, выберите услугу';

  @override
  String get internetAmountRequired => 'Введите сумму';

  @override
  String get internetAmountValid => 'Введите корректную сумму';

  @override
  String internetDynamicFieldRequired(Object fieldName) {
    return 'Введите $fieldName';
  }

  @override
  String get comment_data_bundle_controller =>
      '==== Data Bundle Controller ====';

  @override
  String get dataBundleCountryRequired => 'Выберите страну';

  @override
  String get dataBundleServiceRequired => 'Выберите услугу';

  @override
  String get dataBundleAmountRequired => 'Введите сумму';

  @override
  String get dataBundleAmountValid => 'Введите корректную сумму';

  @override
  String dataBundleDynamicFieldRequired(Object fieldName) {
    return 'Введите $fieldName';
  }

  @override
  String get comment_airtime_screen => '==== Airtime Screen ====';

  @override
  String get airtimeAppBarTitle => 'Мобильная связь';

  @override
  String get comment_airtime_amount_section =>
      '==== Airtime Amount Step Section ====';

  @override
  String get airtimeCountryLabel => 'Страна';

  @override
  String get airtimeCountryHint => 'Выберите страну';

  @override
  String get airtimeCountrySelectTitle => 'Выбор страны';

  @override
  String get airtimeCountryNotFound => 'Страна не найдена';

  @override
  String get airtimeServiceLabel => 'Услуга';

  @override
  String get airtimeServiceHint => 'Выберите услугу';

  @override
  String get airtimeServiceSelectTitle => 'Выбор услуги';

  @override
  String get airtimeServiceNotFound => 'Услуга не найдена';

  @override
  String get airtimeAmountLabel => 'Сумма';

  @override
  String get airtimePayButton => 'Оплатить';

  @override
  String get comment_airtime_review_section =>
      '==== Airtime Review Step Section ====';

  @override
  String get airtimeReviewTitle => 'Проверка данных';

  @override
  String get airtimeReviewAmountLabel => 'Сумма';

  @override
  String get airtimeReviewChargeLabel => 'Комиссия';

  @override
  String get airtimeReviewConversionRateLabel => 'Курс конвертации';

  @override
  String get airtimeReviewPayableAmountLabel => 'Сумма к оплате';

  @override
  String get airtimeReviewBackButton => 'Назад';

  @override
  String get airtimeReviewConfirmButton => 'Подтвердить';

  @override
  String get comment_bill_payment_history => '==== Bill Payment History ====';

  @override
  String get billPaymentHistoryTitle => 'История платежей';

  @override
  String get comment_bill_payment_details =>
      '==== Bill Payment Details Sheet ====';

  @override
  String get billPaymentDetailsTitle => 'Детали платежа';

  @override
  String get billPaymentDetailsTime => 'Время';

  @override
  String get billPaymentDetailsAmount => 'Сумма';

  @override
  String get billPaymentDetailsCharge => 'Комиссия';

  @override
  String get billPaymentDetailsMethod => 'Способ';

  @override
  String get billPaymentDetailsStatus => 'Статус';

  @override
  String get comment_cable_screen => '==== Cable Screen ====';

  @override
  String get cableTitle => 'Кабельное ТВ';

  @override
  String get comment_cable_amount_section =>
      '==== Cable Amount Step Section ====';

  @override
  String get cableCountryLabel => 'Страна';

  @override
  String get cableCountryHint => 'Выберите страну';

  @override
  String get cableCountrySelectTitle => 'Выбор страны';

  @override
  String get cableCountryNotFound => 'Страна не найдена';

  @override
  String get cableServiceLabel => 'Услуга';

  @override
  String get cableServiceHint => 'Выберите услугу';

  @override
  String get cableServiceSelectTitle => 'Выбор услуги';

  @override
  String get cableServiceNotFound => 'Услуга не найдена';

  @override
  String get cableAmountLabel => 'Сумма';

  @override
  String get cablePayButton => 'Оплатить';

  @override
  String get comment_cable_review_section =>
      '==== Cable Review Step Section ====';

  @override
  String get cableReviewTitle => 'Проверка данных';

  @override
  String get cableReviewAmountLabel => 'Сумма';

  @override
  String get cableReviewChargeLabel => 'Комиссия';

  @override
  String get cableReviewConversionRateLabel => 'Курс конвертации';

  @override
  String get cableReviewPayableAmountLabel => 'Сумма к оплате';

  @override
  String get cableReviewBackButton => 'Назад';

  @override
  String get cableReviewConfirmButton => 'Подтвердить';

  @override
  String get comment_toll_screen => '==== Toll Screen ====';

  @override
  String get tollTitle => 'Платные дороги';

  @override
  String get comment_toll_amount_section =>
      '==== Toll Amount Step Section ====';

  @override
  String get tollCountryLabel => 'Страна';

  @override
  String get tollCountryHint => 'Выберите страну';

  @override
  String get tollCountrySelectTitle => 'Выбор страны';

  @override
  String get tollCountryNotFound => 'Страна не найдена';

  @override
  String get tollServiceLabel => 'Услуга';

  @override
  String get tollServiceHint => 'Выберите услугу';

  @override
  String get tollServiceSelectTitle => 'Выбор услуги';

  @override
  String get tollServiceNotFound => 'Услуга не найдена';

  @override
  String get tollAmountLabel => 'Сумма';

  @override
  String get tollPayButton => 'Оплатить';

  @override
  String get comment_toll_review_section =>
      '==== Toll Review Step Section ====';

  @override
  String get tollReviewTitle => 'Проверка данных';

  @override
  String get tollReviewAmountLabel => 'Сумма';

  @override
  String get tollReviewChargeLabel => 'Комиссия';

  @override
  String get tollReviewConversionRateLabel => 'Курс конверсии';

  @override
  String get tollReviewPayableAmountLabel => 'Сумма к оплате';

  @override
  String get tollReviewBackButton => 'Назад';

  @override
  String get tollReviewConfirmButton => 'Подтвердить';

  @override
  String get comment_electricity_screen => '==== Electricity Screen ====';

  @override
  String get electricityTitle => 'Электричество';

  @override
  String get comment_electricity_amount_section =>
      '==== Electricity Amount Step Section ====';

  @override
  String get electricityCountryLabel => 'Страна';

  @override
  String get electricityCountryHint => 'Выберите страну';

  @override
  String get electricityCountrySelectTitle => 'Выбор страны';

  @override
  String get electricityCountryNotFound => 'Страна не найдена';

  @override
  String get electricityServiceLabel => 'Услуга';

  @override
  String get electricityServiceHint => 'Выберите услугу';

  @override
  String get electricityServiceSelectTitle => 'Выбор услуги';

  @override
  String get electricityServiceNotFound => 'Услуга не найдена';

  @override
  String get electricityAmountLabel => 'Сумма';

  @override
  String get electricityPayButton => 'Оплатить';

  @override
  String get comment_electricity_review_section =>
      '==== Electricity Review Step Section ====';

  @override
  String get electricityReviewTitle => 'Проверка данных';

  @override
  String get electricityReviewAmountLabel => 'Сумма';

  @override
  String get electricityReviewChargeLabel => 'Комиссия';

  @override
  String get electricityReviewConversionRateLabel => 'Курс конвертации';

  @override
  String get electricityReviewPayableAmountLabel => 'Сумма к оплате';

  @override
  String get electricityReviewBackButton => 'Назад';

  @override
  String get electricityReviewConfirmButton => 'Подтвердить';

  @override
  String get comment_internet_screen => '==== Internet Screen ====';

  @override
  String get internetTitle => 'Интернет';

  @override
  String get comment_internet_amount_section =>
      '==== Internet Amount Step Section ====';

  @override
  String get internetCountryLabel => 'Страна';

  @override
  String get internetCountryHint => 'Выберите страну';

  @override
  String get internetCountrySelectTitle => 'Выбор страны';

  @override
  String get internetCountryNotFound => 'Страна не найдена';

  @override
  String get internetServiceLabel => 'Услуга';

  @override
  String get internetServiceHint => 'Выберите услугу';

  @override
  String get internetServiceSelectTitle => 'Выбор услуги';

  @override
  String get internetServiceNotFound => 'Услуга не найдена';

  @override
  String get internetAmountLabel => 'Сумма';

  @override
  String get internetPayButton => 'Оплатить';

  @override
  String get comment_internet_review_section =>
      '==== Internet Review Step Section ====';

  @override
  String get internetReviewTitle => 'Проверка данных';

  @override
  String get internetReviewAmountLabel => 'Сумма';

  @override
  String get internetReviewChargeLabel => 'Комиссия';

  @override
  String get internetReviewConversionRateLabel => 'Курс конверсии';

  @override
  String get internetReviewPayableAmountLabel => 'Сумма к оплате';

  @override
  String get internetReviewBackButton => 'Назад';

  @override
  String get internetReviewConfirmButton => 'Подтвердить';

  @override
  String get comment_data_bundle_screen => '==== Data Bundle Screen ====';

  @override
  String get dataBundleTitle => 'Мобильный интернет';

  @override
  String get comment_data_bundle_amount_section =>
      '==== Data Bundle Amount Step Section ====';

  @override
  String get dataBundleCountryLabel => 'Страна';

  @override
  String get dataBundleCountryHint => 'Выберите страну';

  @override
  String get dataBundleCountrySelectTitle => 'Выбор страны';

  @override
  String get dataBundleCountryNotFound => 'Страна не найдена';

  @override
  String get dataBundleServiceLabel => 'Услуга';

  @override
  String get dataBundleServiceHint => 'Выберите услугу';

  @override
  String get dataBundleServiceSelectTitle => 'Выбор услуги';

  @override
  String get dataBundleServiceNotFound => 'Услуга не найдена';

  @override
  String get dataBundleAmountLabel => 'Сумма';

  @override
  String get dataBundlePayButton => 'Оплатить';

  @override
  String get comment_data_bundle_review_section =>
      '==== Data Bundle Review Step Section ====';

  @override
  String get dataBundleReviewTitle => 'Проверка данных';

  @override
  String get dataBundleReviewAmountLabel => 'Сумма';

  @override
  String get dataBundleReviewChargeLabel => 'Комиссия';

  @override
  String get dataBundleReviewConversionRateLabel => 'Курс конвертации';

  @override
  String get dataBundleReviewPayableAmountLabel => 'Сумма к оплате';

  @override
  String get dataBundleReviewBackButton => 'Назад';

  @override
  String get dataBundleReviewConfirmButton => 'Подтвердить';

  @override
  String get comment_bill_payment_screen =>
      '==== Bill Payment Main Screen ====';

  @override
  String get billPaymentScreenTitle => 'Оплата счетов';

  @override
  String get billPaymentAirtime => 'Мобильная связь';

  @override
  String get billPaymentElectricity => 'Электричество';

  @override
  String get billPaymentInternet => 'Интернет';

  @override
  String get billPaymentDataBundle => 'Мобильный интернет';

  @override
  String get billPaymentCables => 'Кабельное ТВ';

  @override
  String get billPaymentToll => 'Платные дороги';

  @override
  String get comment_create_virtual_card_controller =>
      '==== Create Virtual Card Controller ====';

  @override
  String get createCardProviderRequired => 'Выберите эмитента карты';

  @override
  String get createCardHolderRequired => 'Выберите держателя карты';

  @override
  String get createNameRequired => 'Введите имя';

  @override
  String get createEmailRequired => 'Введите email';

  @override
  String get createEmailInvalid => 'Введите корректный email';

  @override
  String get createPhoneNumberRequired => 'Введите номер телефона';

  @override
  String get createCountryRequired => 'Выберите страну';

  @override
  String get createCityRequired => 'Введите город';

  @override
  String get createStateRequired => 'Введите область / штат';

  @override
  String get createPostalCodeRequired => 'Введите почтовый индекс';

  @override
  String get createAddressRequired => 'Введите адрес';

  @override
  String get comment_virtual_card_details_controller =>
      '==== Virtual Card Details Controller ====';

  @override
  String get cardDetailsEnterAmount => 'Введите сумму';

  @override
  String get cardDetailsAmountGreaterThanZero => 'Сумма должна быть больше 0';

  @override
  String cardDetailsAmountMinimumLimit(Object amount) {
    return 'Сумма не должна превышать $amount';
  }

  @override
  String cardDetailsAmountMaximumLimit(Object amount) {
    return 'Сумма не должна превышать $amount';
  }

  @override
  String get comment_card_holder_tab_section =>
      '==== Card Holder Tab Section ====';

  @override
  String get cardHolderTabExistingCardholders => 'Существующие держатели';

  @override
  String get cardHolderTabCreateCardholder => 'Создать держателя карты';

  @override
  String get comment_choose_card_holder_section =>
      '==== Choose Card Holder Section ====';

  @override
  String get chooseCardHolderLabel => 'Держатель карты';

  @override
  String get chooseCardHolderDropdownNotFound => 'Держатель карты не найден';

  @override
  String get chooseCardHolderDropdownTitle => 'Выберите держателя карты';

  @override
  String get chooseCardHolderButtonCreate => 'Создать сейчас';

  @override
  String get comment_choose_card_provider_section =>
      '==== Choose Card Provider Section ====';

  @override
  String get chooseCardProviderLabel => 'Эмитент карты';

  @override
  String get chooseCardProviderDropdownNotFound => 'Эмитент карты не найден';

  @override
  String get chooseCardProviderDropdownTitle => 'Выберите эмитента карты';

  @override
  String get comment_create_new_card_holder_section =>
      '==== Create New Card Holder Section ====';

  @override
  String get createCardHolderLabelName => 'Имя';

  @override
  String get createCardHolderLabelEmail => 'Email';

  @override
  String get createCardHolderLabelPhoneNumber => 'Номер телефона';

  @override
  String get createCardHolderLabelCountry => 'Страна';

  @override
  String get createCardHolderDropdownCountryNotFound => 'Страна не найдена';

  @override
  String get createCardHolderDropdownCountryTitle => 'Выберите страну';

  @override
  String get createCardHolderLabelCity => 'Город';

  @override
  String get createCardHolderLabelState => 'Область / штат';

  @override
  String get createCardHolderLabelPostalCode => 'Почтовый индекс';

  @override
  String get createCardHolderLabelAddress => 'Адрес';

  @override
  String get createCardHolderButtonCreate => 'Создать сейчас';

  @override
  String get comment_create_virtual_card_screen =>
      '==== Create Virtual Card Screen ====';

  @override
  String get createVirtualCardAppBarTitle => 'Создать новую карту';

  @override
  String get comment_get_card_info_screen => '==== Get Card Info Screen ====';

  @override
  String get getCardInfoAppBarTitle => 'Получить карту';

  @override
  String get getCardInfoBenefitsTitle => 'Преимущества виртуальных карт';

  @override
  String get getCardInfoBenefitSecurityTitle => 'Повышенная безопасность';

  @override
  String get getCardInfoBenefitSecuritySubtitle =>
      'Ваш настоящий номер карты остаётся скрытым';

  @override
  String get getCardInfoBenefitShoppingTitle => 'Безопасные онлайн-покупки';

  @override
  String get getCardInfoBenefitShoppingSubtitle =>
      'Создавайте виртуальные карты специально для онлайн-покупок';

  @override
  String get getCardInfoBenefitActivationTitle => 'Быстрая и простая активация';

  @override
  String get getCardInfoBenefitActivationSubtitle =>
      'Физическая доставка не требуется';

  @override
  String get getCardInfoButtonContinue => 'Продолжить';

  @override
  String get comment_card_details_info => '==== Card Details Info ====';

  @override
  String get cardDetailsInfoTitle => 'Детали карты';

  @override
  String get cardDetailsCardTypeLabel => 'Тип карты';

  @override
  String get cardDetailsCardTypeValue => 'Виртуальная';

  @override
  String get cardDetailsBillingAddressLabel => 'Платёжный адрес';

  @override
  String get cardDetailsCardCurrencyLabel => 'Валюта карты';

  @override
  String get bsicardsCardDetailsCurrencyValue => 'USD';

  @override
  String get cardDetailsCardCreatedLabel => 'Карта создана';

  @override
  String get cardDetailsStatusButtonActive => 'Активна';

  @override
  String get cardDetailsStatusButtonInactive => 'Неактивна';

  @override
  String get comment_card_top_up_bottom_sheet =>
      '==== Card Top Up Bottom Sheet ====';

  @override
  String get cardTopUpTitle => 'Пополнение баланса карты';

  @override
  String get cardTopUpMainWalletBalance => 'Баланс основного кошелька';

  @override
  String get cardTopUpLabelAmount => 'Сумма';

  @override
  String cardTopUpAmountLimits(Object currency, Object max, Object min) {
    return 'Минимум $min $currency, максимум $max $currency';
  }

  @override
  String get cardTopUpReviewTopupAmount => 'Сумма пополнения';

  @override
  String get cardTopUpReviewTopupCharge => 'Комиссия за пополнение';

  @override
  String get cardTopUpReviewTotalTopupBalance => 'Итоговая сумма';

  @override
  String get cardTopUpButtonTopupNow => 'Пополнить сейчас';

  @override
  String get bsicardsTopUpInfoMessage =>
      'Отправьте средства на указанный криптоадрес. После подтверждения транзакции баланс будет зачислен на вашу карту.';

  @override
  String get bsicardsTopUpCopyButton => 'Копировать';

  @override
  String get bsicardsTopUpCopySuccess => 'Адрес скопирован';

  @override
  String get comment_virtual_card_display => '==== Virtual Card Display ====';

  @override
  String get virtualCardExpiryDateLabel => 'Срок действия';

  @override
  String get virtualCardCvcLabel => 'CVC';

  @override
  String get comment_virtual_card_details_screen =>
      '==== Virtual Card Details Screen ====';

  @override
  String get virtualCardDetailsAppBarTitle => 'Данные виртуальной карты';

  @override
  String get virtualCardDetailsFloatingButton => 'Пополнить баланс';

  @override
  String get comment_virtual_card_transaction_screen =>
      '==== Virtual Card Transaction Screen ====';

  @override
  String get virtualCardTransactionAppBarTitle => 'Операции по карте';

  @override
  String get virtualCardTransactionSyncButton => 'Синхронизировать';

  @override
  String get comment_virtual_card_screen => '==== Virtual Card Screen ====';

  @override
  String get virtualCardScreenAppBarTitle => 'Виртуальные карты';

  @override
  String get virtualCardCardExpiryDateLabel => 'Срок действия';

  @override
  String get virtualCardCardCvcLabel => 'CVC';

  @override
  String get virtualCardCreateCardTitle =>
      'Создайте виртуальную карту, чтобы начать';

  @override
  String get virtualCardCreateCardButton => 'Создать карту';

  @override
  String get comment_verify_passcode_controller =>
      '==== Verify Passcode Controller ====';

  @override
  String get verifyPasscodeValidationEnterPasscode => 'Введите пароль';

  @override
  String get comment_change_passcode_bottom_sheet =>
      '==== Change Passcode Bottom Sheet ====';

  @override
  String get changePasscodeTitle => 'Изменение код-пароля';

  @override
  String get changePasscodeLabelOldPasscode => 'Старый код-пароль';

  @override
  String get changePasscodeLabelNewPasscode => 'Новый код-пароль';

  @override
  String get changePasscodeLabelConfirmPasscode => 'Подтвердите код-пароль';

  @override
  String get changePasscodeButtonChange => 'Изменить код-пароль';

  @override
  String get comment_disable_and_change_passcode_section =>
      '==== Disable and Change Passcode Section ====';

  @override
  String get disableChangePasscodeTitle => 'Код-пароль';

  @override
  String get disableChangePasscodeButtonChange => 'Изменить код-пароль';

  @override
  String get disableChangePasscodeButtonDisable => 'Отключить код-пароль';

  @override
  String get comment_disable_passcode_bottom_sheet =>
      '==== Disable Passcode Bottom Sheet ====';

  @override
  String get disablePasscodeTitle => 'Отключение код-пароля';

  @override
  String get disablePasscodeLabelPassword => 'Пароль';

  @override
  String get disablePasscodeButtonDisable => 'Отключить код-пароль';

  @override
  String get comment_generate_passcode_bottom_sheet =>
      '==== Generate Passcode Bottom Sheet ====';

  @override
  String get generatePasscodeTitle => 'Добавить код-пароль';

  @override
  String get generatePasscodeLabelPasscode => 'Код-пароль';

  @override
  String get generatePasscodeLabelConfirmPasscode => 'Подтвердите код-пароль';

  @override
  String get generatePasscodeButtonConfirm => 'Подтвердить';

  @override
  String get comment_generate_passcode_section =>
      '==== Generate Passcode Section ====';

  @override
  String get generatePasscodeSectionTitle => 'Код-пароль';

  @override
  String get generatePasscodeSectionDescription =>
      'Создайте безопасный код-пароль для быстрого доступа к аккаунту';

  @override
  String get generatePasscodeSectionButtonGenerate => 'Создать код-пароль';

  @override
  String get comment_verify_passcode_bottom_sheet =>
      '==== Verify Passcode Bottom Sheet ====';

  @override
  String get verifyPasscodeTitle => 'Подтвердите пароль';

  @override
  String get verifyPasscodeLabelPasscode => 'Пароль';

  @override
  String get verifyPasscodeButtonConfirm => 'Подтвердить';

  @override
  String get comment_payment_links_amount_section =>
      '==== Payment Links Amount Section ====';

  @override
  String get paymentLinksAmountSectionTitle => 'Сумма';

  @override
  String get paymentLinksCurrencyLabel => 'Валюта';

  @override
  String get paymentLinksCurrencyHint => 'Выберите валюту';

  @override
  String get paymentLinksCurrencyDropdownTitle => 'Валюта';

  @override
  String get paymentLinksCurrencyNotFound => 'Валюта не найдена';

  @override
  String get paymentLinksNoteLabel => 'Примечание';

  @override
  String get paymentLinksCreateLinkButton => 'Создать ссылку';

  @override
  String get comment_payment_links_create_section =>
      '==== Payment Links Create Section ====';

  @override
  String get paymentLinksInstructionText =>
      'Вы можете создать платёжную ссылку без указания суммы и валюты. Плательщик сможет указать счёт и валюту при оплате.';

  @override
  String get comment_payment_links_header_section =>
      '==== Payment Links Header Section ====';

  @override
  String get paymentLinksAppBarTitle => 'Платёжные ссылки';

  @override
  String get paymentLinksTabList => 'Список';

  @override
  String get paymentLinksTabCreate => 'Создание';

  @override
  String get comment_payment_links_history_filter_bottom_sheet =>
      '==== Payment Links History Filter Bottom Sheet ====';

  @override
  String get paymentLinksFilterNumberLabel => 'Номер';

  @override
  String get paymentLinksFilterButton => 'Фильтр';

  @override
  String get comment_payment_links_list_section =>
      '==== Payment Links List Section ====';

  @override
  String get paymentLinksListItemCreatedAt => 'Создано: ';

  @override
  String get paymentLinksListItemStatus => 'Статус: ';

  @override
  String get paymentLinksStatusPaid => 'Оплачена';

  @override
  String get paymentLinksStatusUnpaid => 'Не оплачена';

  @override
  String get paymentLinksCopySuccessToast => 'Код платёжной ссылки скопирован';

  @override
  String get comment_gift_card_header_section =>
      '---- Gift Card Header Section ----';

  @override
  String get giftCardHeaderTitle => 'Подарочная карта';

  @override
  String get giftCardHeaderTabCards => 'Карты';

  @override
  String get giftCardHeaderTabHistory => 'История';

  @override
  String get comment_gift_card_history_filter_bottom_sheet =>
      '---- Gift Card History Filter Bottom Sheet ----';

  @override
  String get giftCardHistoryFilterSearchLabel => 'Поиск';

  @override
  String get giftCardHistoryFilterSearchButton => 'Поиск';

  @override
  String get comment_gift_card_filter_bottom_sheet =>
      '---- Gift Card Filter Bottom Sheet ----';

  @override
  String get giftCardFilterGiftCardLabel => 'Подарочная карта';

  @override
  String get giftCardFilterCountryLabel => 'Страна';

  @override
  String get giftCardFilterCountrySelectTitle => 'Выбор страны';

  @override
  String get giftCardFilterAllOption => 'Все';

  @override
  String get giftCardFilterCountryNotFound => 'Страна не найдена';

  @override
  String get giftCardFilterCategoryLabel => 'Категория';

  @override
  String get giftCardFilterCategorySelectTitle => 'Выбор категории';

  @override
  String get giftCardFilterCategoryNotFound => 'Категория не найдена';

  @override
  String get giftCardFilterSearchButton => 'Поиск';

  @override
  String get comment_gift_card_history_details =>
      '---- Gift Card History Details ----';

  @override
  String get giftCardHistoryDetailsTitle => 'Детали транзакции';

  @override
  String giftCardHistoryQtyLabel(Object qty) {
    return 'Кол-во: $qty';
  }

  @override
  String get giftCardTransactionIdLabel => 'ID транзакции';

  @override
  String get giftCardProductNameLabel => 'Название продукта';

  @override
  String get giftCardSenderNameLabel => 'Имя отправителя';

  @override
  String get giftCardRecipientEmailLabel => 'Email получателя';

  @override
  String get giftCardRecipientPhoneLabel => 'Телефон получателя';

  @override
  String get giftCardUnitPriceLabel => 'Цена за единицу';

  @override
  String get giftCardTotalAmountLabel => 'Итоговая сумма';

  @override
  String get comment_gift_card_review_details =>
      '---- Gift Card Review Details ----';

  @override
  String get giftCardReviewDetailsTitle => 'Проверка данных';

  @override
  String get giftCardSubTotalLabel => 'Подытог';

  @override
  String get giftCardTotalFeeLabel => 'Общая комиссия';

  @override
  String get giftCardTotalLabel => 'Итого';

  @override
  String get giftCardReviewBackButton => 'Назад';

  @override
  String get giftCardReviewPayNowButton => 'Оплатить';

  @override
  String get comment_gift_card_success_section =>
      '---- Gift Card Success Section ----';

  @override
  String get giftCardSuccessTitle => 'Заказ подарочной карты успешно оформлен!';

  @override
  String get giftCardSuccessGiftCardsButton => 'Подарочные карты';

  @override
  String get giftCardSuccessBackHomeButton => 'На главную';

  @override
  String get comment_gift_card_amount_validation =>
      '---- Gift Card Controller Amount Validation ----';

  @override
  String get giftCardAmountRequired => 'Введите сумму';

  @override
  String get giftCardAmountInvalid => 'Сумма должна быть больше нуля';

  @override
  String giftCardAmountMinError(Object min) {
    return 'Сумма не должна превышать $min';
  }

  @override
  String giftCardAmountMaxError(Object max) {
    return 'Сумма не должна превышать $max';
  }

  @override
  String get comment_gift_card_user_validation =>
      '---- Gift Card Controller User Validation ----';

  @override
  String get giftCardEmailRequired => 'Введите email';

  @override
  String get giftCardEmailInvalid => 'Введите корректный email';

  @override
  String get giftCardCountryRequired => 'Выберите страну';

  @override
  String get giftCardPhoneRequired => 'Введите номер телефона';

  @override
  String get giftCardNameRequired => 'Введите имя';

  @override
  String get comment_gift_card_details_section =>
      '---- Gift Card Details Section ----';

  @override
  String get giftCardDetailsTitle => 'Детали подарочной карты';

  @override
  String get giftCardAmountLabel => 'Сумма';

  @override
  String giftCardAmountBetweenLabel(Object currency, Object max, Object min) {
    return 'Сумма от $min $currency до $max $currency';
  }

  @override
  String get giftCardEmailLabel => 'Email';

  @override
  String get giftCardCountryLabel => 'Страна';

  @override
  String get giftCardSelectCountryTitle => 'Выбор страны';

  @override
  String get giftCardCountryNotFound => 'Страна не найдена';

  @override
  String get giftCardPhoneLabel => 'Телефон';

  @override
  String get giftCardYourNameLabel => 'Ваше имя';

  @override
  String get giftCardQuantityLabel => 'Количество';

  @override
  String get giftCardBuyNowButton => 'Купить сейчас';

  @override
  String get giftCardRedeemInstructionTitle => 'Инструкция по активации';

  @override
  String get comment_p2p => '==== P2P ====';

  @override
  String get p2pMyOrder => 'Мой заказ';

  @override
  String get p2pPaymentAccount => 'Платёжный счёт';

  @override
  String get p2pCreateAd => 'Создать объявление';

  @override
  String get p2pApplyVerification => 'Подать заявку на верификацию';

  @override
  String get p2pP2p => 'P2P';

  @override
  String get p2pMyOrders => 'Мои заказы';

  @override
  String get p2pPaymentAccounts => 'Платёжные счета';

  @override
  String get p2pMyAds => 'Мои объявления';

  @override
  String get p2pSelectAsset => 'Выберите актив';

  @override
  String get p2pSelectFiat => 'Выберите фиат';

  @override
  String get p2pBuy => 'Купить';

  @override
  String get p2pSell => 'Продать';

  @override
  String get p2pAmount => 'Сумма';

  @override
  String get p2pPayment => 'Оплата';

  @override
  String get p2pOrders => 'Заказы';

  @override
  String get p2pCompletion => 'Завершённость';

  @override
  String get p2pLimit => 'Лимит';

  @override
  String get p2pAvailable => 'Доступно';

  @override
  String get p2pOrderDetails => 'Детали заказа';

  @override
  String get p2pNoOrderDetailsFound => 'Данные заказа не найдены';

  @override
  String get p2pNoAdDetailsFound => 'Данные объявления не найдены';

  @override
  String get p2pPrice => 'Цена';

  @override
  String get p2pOrderLimit => 'Лимит заказа';

  @override
  String get p2pYouPay => 'Вы платите';

  @override
  String get p2pYouSell => 'Вы продаёте';

  @override
  String get p2pYouReceive => 'Вы получаете';

  @override
  String get p2pPaymentMethods => 'Способы оплаты';

  @override
  String get p2pLoadingPaymentMethods => 'Загрузка способов оплаты...';

  @override
  String get p2pSelectPaymentMethod => 'Выберите способ оплаты';

  @override
  String get p2pNoPaymentMethodFound => 'Способ оплаты не найден';

  @override
  String get p2pAdvertisersTerms =>
      'Условия для рекламодателей (пожалуйста, прочитайте внимательно)';

  @override
  String get p2pPaymentTimeLimit => 'Срок оплаты';

  @override
  String get p2pAvgReleaseTime => 'Ср. время высвобождения';

  @override
  String get p2pNoTermsProvided => 'Условия не указаны';

  @override
  String get p2pOrderNumber => 'Номер заказа';

  @override
  String get p2pSearchOrderNumber => 'Поиск по номеру заказа';

  @override
  String get p2pOrderNumberCopied => 'Номер заказа скопирован';

  @override
  String get p2pCopied => 'Скопировано';

  @override
  String get p2pOrderCreated => 'Заказ создан';

  @override
  String get p2pFiatAmount => 'Сумма в фиате';

  @override
  String get p2pReceiveQuantity => 'Количество к получению';

  @override
  String get p2pPaymentMethod => 'Способ оплаты';

  @override
  String get p2pChange => 'Изменить';

  @override
  String get p2pRecipient => 'Получатель';

  @override
  String get p2pView => 'Просмотр';

  @override
  String get p2pFilterAmount => 'Фильтр по сумме';

  @override
  String get p2pEnterAmount => 'Введите сумму';

  @override
  String get p2pFilterPaymentMethod => 'Фильтр по способу оплаты';

  @override
  String get p2pUnableToLoadImage => 'Не удалось загрузить изображение';

  @override
  String get p2pFieldRequired => 'Это поле обязательно';

  @override
  String get p2pPleaseUpload => 'Загрузите файл для этого поля';

  @override
  String get p2pPleaseFill => 'Заполните это поле';

  @override
  String get p2pWriteMessageOrAttach =>
      'Напишите сообщение или добавьте вложение';

  @override
  String get p2pVerificationSubmitted => 'Заявка на верификацию отправлена';

  @override
  String get p2pCashDollar => 'Наличные доллары';

  @override
  String get p2pInPerson => 'Обмен при встрече';

  @override
  String get p2pMinutes => 'Минут';

  @override
  String get p2pNoPaymentMethodFound2 => 'Способ оплаты не найден';

  @override
  String p2pTransferInstruction(Object amount, Object paymentMethod) {
    return 'Откройте ($paymentMethod) и переведите $amount';
  }

  @override
  String p2pCashTransferInstruction(Object amount) {
    return 'Передайте $amount наличными продавцу';
  }

  @override
  String p2pInPersonInstruction(Object amount) {
    return 'Встретьтесь с продавцом и передайте $amount наличными';
  }

  @override
  String get p2pUnableToLoadAttachment => 'Не удалось загрузить вложение';

  @override
  String get p2pTransferredNotifySeller => 'Переведено, уведомить продавца';

  @override
  String get p2pCancelOrder => 'Отменить заказ';

  @override
  String get p2pDisputeOrder => 'Оспорить заказ';

  @override
  String get p2pPaymentReceived => 'Оплата получена';

  @override
  String get p2pEnterDisputeReason => 'Укажите причину спора';

  @override
  String get p2pWriteYourReason => 'Напишите причину...';

  @override
  String get p2pEnterReason => 'Укажите причину';

  @override
  String get p2pReasonIsRequired => 'Причина обязательна';

  @override
  String get p2pCancelOrderConfirmation =>
      'Вы уверены, что хотите отменить этот заказ?';

  @override
  String get p2pOrderCompleted => 'Заказ завершён';

  @override
  String get p2pOrderCancelled => 'Заказ отменён';

  @override
  String get p2pPendingRelease => 'Ожидает высвобождения';

  @override
  String get p2pOrderDisputed => 'Заказ оспорен';

  @override
  String get p2pOrderExpired => 'Срок заказа истёк';

  @override
  String get p2pBuyerMarkedAsPaid => 'Покупатель отметил оплату';

  @override
  String get p2pOrderCreatedPayTheSellerWithin =>
      'Заказ создан. Оплатите продавцу в течение';

  @override
  String get p2pBuyerHasNotPaidYetPaymentDueWithin =>
      'Покупатель ещё не оплатил. Срок оплаты в течение';

  @override
  String get p2pSellerFundsLockedInEscrow =>
      'Средства продавца заблокированы в эскроу. Наша служба поддержки рассмотрит доказательства и скоро ответит.';

  @override
  String get p2pYourLockedAssetsInEscrow =>
      'Ваши заблокированные активы находятся в эскроу. Наша служба поддержки скоро рассмотрит этот спор.';

  @override
  String get p2pPaymentNotCompletedInAllowedTime =>
      'Вы не завершили оплату в отведённое время.';

  @override
  String get p2pBuyerDidNotCompletePaymentInAllowedTime =>
      'Покупатель не завершил оплату в отведённое время.';

  @override
  String p2pConfirmPaymentFrom(Object name) {
    return 'Подтвердите, что оплата поступила от (покупатель: $name)';
  }

  @override
  String get p2pVerifyAmountAndSender =>
      'Проверьте сумму и данные отправителя в своём счёте, затем подтвердите высвобождение средств.';

  @override
  String get p2pTransferFundsToSeller =>
      'Переведите средства на счёт продавца, указанный ниже.';

  @override
  String get p2pNotifySeller => 'Уведомить продавца';

  @override
  String get p2pConfirmPaymentReceived => 'Подтвердить получение оплаты';

  @override
  String get p2pConfirmPaymentReceivedDescription =>
      'После подтверждения получения оплаты нажмите кнопку «Оплата получена» ниже.';

  @override
  String get p2pNotifySellerDescription =>
      'После оплаты не забудьте нажать кнопку «Переведено, уведомить продавца», чтобы продавец высвободил криптовалюту.';

  @override
  String get p2pAllAccount => 'Все счета';

  @override
  String get p2pAddPaymentMethod => 'Добавить способ оплаты';

  @override
  String get p2pEdit => 'Изменить';

  @override
  String get p2pEditPaymentAccount => 'Изменить платёжный счёт';

  @override
  String get p2pUpdateAccount => 'Обновить счёт';

  @override
  String get p2pCancel => 'Отмена';

  @override
  String get p2pSubmit => 'Отправить';

  @override
  String get p2pBack => 'Назад';

  @override
  String get p2pNext => 'Далее';

  @override
  String get p2pDone => 'Готово';

  @override
  String get p2pIWantToBuy => 'Хочу купить';

  @override
  String get p2pIWantToSell => 'Хочу продать';

  @override
  String get p2pAsset => 'Актив';

  @override
  String get p2pWithFiat => 'В фиате';

  @override
  String get p2pPriceType => 'Тип цены';

  @override
  String get p2pYourPrice => 'Ваша цена';

  @override
  String get p2pHighestOrderPrice => 'Наивысшая цена заказа';

  @override
  String get p2pTotalAmount => 'Итоговая сумма';

  @override
  String get p2pSelectAtLeastOnePaymentMethod =>
      'Выберите хотя бы один способ оплаты';

  @override
  String get p2pAdd => 'Добавить';

  @override
  String get p2pTerms => 'Условия';

  @override
  String get p2pAutomaticReply => 'Автоответ';

  @override
  String get p2pFixed => 'Фиксированная';

  @override
  String get p2pFloat => 'Плавающая';

  @override
  String get p2pSelectPriceType => 'Выберите тип цены';

  @override
  String get p2pNoAssetsFound => 'Активы не найдены';

  @override
  String get p2pNoFiatCurrenciesFound => 'Фиатные валюты не найдены';

  @override
  String get p2pNoPriceTypeFound => 'Тип цены не найден';

  @override
  String get p2pAdSuccessfullyPosted => 'Объявление успешно размещено';

  @override
  String get p2pAdsSubmittedUnderReview =>
      'Объявления отправлены и проверяются.';

  @override
  String get p2pAdPublishedDescription =>
      'Ваше объявление опубликовано, и пользователи могут размещать заказы. Следите за уведомлениями о новых заказах.';

  @override
  String get p2pAdUnderReviewDescription =>
      'Ваше объявление на проверке. После одобрения оно будет опубликовано, и пользователи смогут размещать заказы. Следите за уведомлениями о новых заказах.';

  @override
  String get p2pAdNumber => 'Номер объявления';

  @override
  String get p2pMethod => 'Способ';

  @override
  String get p2pGoToMyAds => 'Перейти к моим объявлениям';

  @override
  String get p2pEligibilityValidationFailed =>
      'Проверка права на размещение не пройдена';

  @override
  String get p2pPleaseFulfillRequirements =>
      'Пожалуйста, выполните следующие требования:';

  @override
  String get p2pNotEligibleCreateAd =>
      'Сейчас вы не можете создавать объявления.';

  @override
  String get p2pCompletedTradeQty => 'Завершённых сделок';

  @override
  String get p2pStatus => 'Статус';

  @override
  String get p2pAdsView => 'Просмотр объявлений';

  @override
  String get p2pAdNumberTitle => 'Номер объявления';

  @override
  String get p2pType => 'Тип';

  @override
  String get p2pAssetFiat => 'Актив/Фиат';

  @override
  String get p2pPriceExchangeRate => 'Цена\nКурс обмена';

  @override
  String get p2pLastUpdated => 'Последнее обновление';

  @override
  String get p2pCreateTime => 'Время создания';

  @override
  String get p2pDeleteAdConfirmation =>
      'Вы уверены, что хотите удалить это объявление?';

  @override
  String get p2pFiat => 'Фиат';

  @override
  String get p2pCryptoAmount => 'Сумма в криптовалюте';

  @override
  String get p2pCounterparty => 'Контрагент';

  @override
  String get p2pChat => 'Чат';

  @override
  String get p2pNoMessagesYet => 'Сообщений пока нет';

  @override
  String get p2pTypeYourMessage => 'Введите сообщение...';

  @override
  String get p2pCamera => 'Камера';

  @override
  String get p2pGallery => 'Галерея';

  @override
  String get p2pAttachment => 'Вложение';

  @override
  String get p2pUser => 'Пользователь';

  @override
  String get p2pYouAreVerifiedTrader => 'Вы верифицированный трейдер';

  @override
  String get p2pVerifiedTraderStatusActive =>
      'Ваш статус верифицированного трейдера активен.';

  @override
  String get p2pVerificationUnderReview => 'Верификация на рассмотрении';

  @override
  String get p2pVerificationRequestUnderReview =>
      'Ваша заявка на верификацию сейчас на рассмотрении.';

  @override
  String get p2pSubmittedOn => 'Дата отправки';

  @override
  String get p2pVerificationDataUnavailable => 'Данные верификации недоступны';

  @override
  String get p2pPleaseRefreshAndTryAgain =>
      'Пожалуйста, обновите страницу и попробуйте снова.';

  @override
  String get p2pPreviousVerificationRejected =>
      'Предыдущая заявка на верификацию была отклонена';

  @override
  String get p2pReason => 'Причина';

  @override
  String get p2pCorrectInformationApplyAgain =>
      'Пожалуйста, исправьте данные и подайте заявку снова.';

  @override
  String get p2pApplyVerificationTitle => 'Подать заявку на верификацию';

  @override
  String get p2pFillRequiredFieldsVerification =>
      'Заполните все обязательные поля для отправки заявки на верификацию.';

  @override
  String get p2pNoVerificationFormFieldsFound =>
      'Поля формы верификации не найдены.';

  @override
  String get p2pSubmitVerification => 'Отправить заявку на верификацию';

  @override
  String p2pEnterField(Object field) {
    return 'Введите $field';
  }

  @override
  String get edit_my_ad => 'Редактировать моё объявление';

  @override
  String get amount => 'Сумма';

  @override
  String get total_amount => 'Итоговая сумма';

  @override
  String get min_amount => 'Мин. сумма';

  @override
  String get max_amount => 'Макс. сумма';

  @override
  String get payment_duration => 'Срок оплаты';

  @override
  String get payment_method => 'Способ оплаты';

  @override
  String get no_payment_method => 'Способ оплаты не найден';

  @override
  String get terms => 'Условия';

  @override
  String get auto_response => 'Автоматический ответ';

  @override
  String get update => 'Обновить';

  @override
  String get error_ad_invalid => 'Данные объявления недействительны';

  @override
  String get error_amount_zero => 'Сумма не может быть нулевой';

  @override
  String get error_total_amount_zero => 'Общая сумма не может быть нулевой';

  @override
  String get error_min_zero => 'Минимальная сумма не может быть нулевой';

  @override
  String get error_max_zero => 'Максимальная сумма не может быть нулевой';

  @override
  String get error_min_greater =>
      'Минимальная сумма не может превышать максимальную';

  @override
  String get error_payment_duration_zero =>
      'Длительность оплаты не может быть нулевой';

  @override
  String get error_select_payment => 'Выберите способ оплаты';

  @override
  String get error_terms_empty => 'Условия не могут быть пустыми';

  @override
  String get error_select_asset => 'Выберите актив';

  @override
  String get error_select_fiat => 'Выберите фиатную валюту';

  @override
  String get error_select_price_type => 'Выберите тип цены';

  @override
  String get error_price_zero => 'Цена не может быть нулевой';

  @override
  String get error_enter_total_amount => 'Введите общую сумму';

  @override
  String get error_enter_min_order => 'Введите минимальный лимит заказа';

  @override
  String get error_enter_max_order => 'Введите максимальный лимит заказа';

  @override
  String get error_payment_time_zero => 'Время оплаты не может быть нулевым';

  @override
  String get error_enter_terms => 'Введите условия';

  @override
  String get filterMyAds => 'Фильтр моих объявлений';

  @override
  String get status => 'Статус';

  @override
  String get type => 'Тип';

  @override
  String get fiatCurrency => 'Фиатная валюта';

  @override
  String get assetCurrency => 'Валюта актива';

  @override
  String get reset => 'Сбросить';

  @override
  String get search => 'Поиск';

  @override
  String get select => 'Выбрать';

  @override
  String get selectStatus => 'Выберите статус';

  @override
  String get selectType => 'Выберите тип';

  @override
  String get selectFiatCurrency => 'Выберите фиатную валюту';

  @override
  String get selectAssetCurrency => 'Выберите валюту актива';

  @override
  String get noStatusFound => 'Статус не найден';

  @override
  String get noTypeFound => 'Тип не найден';

  @override
  String get noDataFound => 'Данные не найдены';

  @override
  String get noFiatCurrencyFound => 'Фиатная валюта не найдена';

  @override
  String get noAssetCurrencyFound => 'Валюта актива не найдена';

  @override
  String get filterPaymentAccount => 'Фильтр платёжных счетов';

  @override
  String get filterMyOrder => 'Фильтр моих заказов';

  @override
  String get comment_travel => '==== eCardo Travel ====';

  @override
  String get travelTitle => 'eCardo Travel';

  @override
  String get travelHeroEyebrow => 'Путешествия нового уровня';

  @override
  String get travelHeroTitle =>
      'Забронируйте следующее путешествие уже сегодня';

  @override
  String get travelFlights => 'Рейсы';

  @override
  String get travelHotels => 'Отели';

  @override
  String get travelEsim => 'eSIM';

  @override
  String get travelRecentActivity => 'Последние операции';

  @override
  String get travelViewAll => 'Показать все';

  @override
  String get travelMainWallet => 'Основной кошелёк eCardo';

  @override
  String get travelWalletSharedDescription =>
      'Тот же защищённый кошелёк, что и во всём приложении eCardo';

  @override
  String get travelHotelSearch => 'Поиск отелей';

  @override
  String get travelHotelHero => 'Остановитесь в незабываемом месте';

  @override
  String get travelDestinationCountry => 'Страна назначения';

  @override
  String get travelDestinationCity => 'Город';

  @override
  String get travelCheckIn => 'Заезд';

  @override
  String get travelCheckOut => 'Выезд';

  @override
  String get travelGuests => 'Гости';

  @override
  String get travelSearchHotels => 'Найти отели';

  @override
  String get travelRecentSearches => 'Недавние поиски';

  @override
  String get travelHotelResults => 'Результаты поиска отелей';

  @override
  String get travelNoHotelResults => 'Подходящие отели не найдены.';

  @override
  String get travelStartingPrice => 'Цена за проживание от';

  @override
  String get travelViewDetails => 'Подробнее';

  @override
  String get travelHotelDetails => 'Детали отеля';

  @override
  String get travelOfferUnavailable => 'Это предложение больше недоступно.';

  @override
  String get travelReserveHotel => 'Забронировать отель';

  @override
  String get travelIncluded => 'Включено';

  @override
  String get travelFree => 'Бесплатно';

  @override
  String get travelAboutHotel => 'Об отеле';

  @override
  String get travelHotelDescription =>
      'Изысканное пребывание в городе с комфортабельными номерами, внимательным сервисом и удобным доступом к главным достопримечательностям. Итоговое описание номеров и правила будут предоставлены API eCardo Travel.';

  @override
  String get travelPolicies => 'Правила';

  @override
  String get travelCancellation => 'Отмена';

  @override
  String get travelCancellationSummary =>
      'Бесплатная отмена до указанного срока';

  @override
  String get travelFlightSearch => 'Поиск рейсов';

  @override
  String get travelFlightHero => 'Ваше путешествие мечты начинается здесь';

  @override
  String get travelOrigin => 'Отправление';

  @override
  String get travelDestination => 'Направление';

  @override
  String get travelDepartureDate => 'Дата вылета';

  @override
  String get travelReturnDate => 'Дата возвращения';

  @override
  String get travelOneWay => 'В одну сторону';

  @override
  String get travelRoundTrip => 'Туда и обратно';

  @override
  String get travelAdults => 'Взрослые';

  @override
  String get travelChildren => 'Дети';

  @override
  String get travelInfants => 'Младенцы';

  @override
  String get travelCabinClass => 'Класс обслуживания';

  @override
  String get travelEconomy => 'Эконом';

  @override
  String get travelBusiness => 'Бизнес';

  @override
  String get travelSearchFlights => 'Найти рейсы';

  @override
  String get travelFlightResults => 'Результаты поиска рейсов';

  @override
  String get travelNoFlightResults => 'Подходящие рейсы не найдены.';

  @override
  String get travelAlternativeFlights => 'Альтернативные рейсы.';

  @override
  String get travelAlternativeFlightsDescription =>
      'По точному запросу совпадений нет. Эти ближайшие варианты показаны как альтернативы; измените маршрут или дату в поиске.';

  @override
  String get travelSelectFlight => 'Выбрать рейс';

  @override
  String get travelSelectReturnFlight => 'Выбрать обратный рейс';

  @override
  String get travelOutboundFlight => 'Рейс туда';

  @override
  String get travelReturnFlight => 'Обратный рейс';

  @override
  String get travelFlightDetails => 'Рейс и данные пассажиров';

  @override
  String get travelContinueToPayment => 'Перейти к оплате';

  @override
  String get travelPassengerReview => 'Проверка пассажиров';

  @override
  String get travelPrimaryPassenger => 'Главный пассажир';

  @override
  String get travelPassengerFromProfile =>
      'Данные взяты из вашего профиля eCardo';

  @override
  String get travelFareDetails => 'Детали тарифа';

  @override
  String get travelBaseFare => 'Базовый тариф';

  @override
  String get travelTaxesAndFees => 'Налоги и сборы';

  @override
  String get travelTotal => 'Итого';

  @override
  String get travelBrowseEsimPackages => 'Пакеты eSIM';

  @override
  String get travelEsimIntroTitle => 'Оставайтесь на связи в любых поездках';

  @override
  String get travelEsimIntroDescription =>
      'Выберите цифровой интернет-пакет, оплатите его из основного кошелька eCardo и активируйте без замены физической SIM-карты.';

  @override
  String get travelEsimInstantTitle => 'Мгновенная доставка';

  @override
  String get travelEsimInstantDescription =>
      'Данные для активации доступны сразу после оплаты.';

  @override
  String get travelEsimCoverageTitle => 'Покрытие в поездках';

  @override
  String get travelEsimCoverageDescription =>
      'Выберите местный или глобальный пакет для вашего направления.';

  @override
  String get travelEsimTransparentTitle => 'Прозрачные цены';

  @override
  String get travelEsimTransparentDescription =>
      'Смотрите итоговую сумму, подтверждённую сервером, до оплаты.';

  @override
  String get travelEsimPackages => 'Пакеты eSIM';

  @override
  String get travelNoEsimPackages => 'Подходящие пакеты eSIM не найдены.';

  @override
  String get travelChoosePackage => 'Выберите пакет';

  @override
  String get travelMostPopular => 'Популярное';

  @override
  String get travelSelect => 'Выбрать';

  @override
  String travelValidityDays(int days) {
    return 'Срок действия: $days дн.';
  }

  @override
  String get travelWalletCheckout => 'Оплата из кошелька';

  @override
  String get travelBackendConfirmedPrice => 'Цена подтверждена eCardo Travel';

  @override
  String get travelPaymentMethod => 'Способ оплаты';

  @override
  String get travelAvailableBalance => 'Доступный баланс';

  @override
  String get travelInsufficientBalance =>
      'На основном кошельке недостаточно средств. Пополните его и вернитесь, чтобы обновить оплату.';

  @override
  String get travelPriceSummary => 'Сводка по цене';

  @override
  String get travelSubtotal => 'Промежуточный итог';

  @override
  String get travelWalletPayment => 'Оплата кошельком';

  @override
  String get travelCheckoutSafetyNote =>
      'Оплата отправляется один раз по идемпотентному запросу бронирования.';

  @override
  String get travelPayFromWallet => 'Оплатить из кошелька';

  @override
  String get travelAddMoney => 'Пополнить';

  @override
  String get travelPaymentFailed => 'Оплата не завершена';

  @override
  String get travelPaymentFailedDescription =>
      'Оплата с кошелька не была проведена. Проверьте бронирование и попробуйте снова.';

  @override
  String get travelHotelVoucher => 'Ваучер на отель';

  @override
  String get travelFlightTicket => 'Авиабилет';

  @override
  String get travelEsimActivation => 'Активация eSIM';

  @override
  String get travelVoucherReady => 'Ваш подтверждённый ваучер на отель готов.';

  @override
  String get travelTicketReady => 'Ваш авиабилет оформлен и готов.';

  @override
  String get travelEsimReady => 'Ваша eSIM активна и готова к установке.';

  @override
  String get travelPurchaseSuccessful => 'Покупка выполнена';

  @override
  String get travelReference => 'Референс';

  @override
  String get travelStatus => 'Статус';

  @override
  String get travelActive => 'Активна';

  @override
  String get travelConfirmed => 'Подтверждено';

  @override
  String get travelCompleted => 'Завершено';

  @override
  String get travelRefunded => 'Возвращено';

  @override
  String get travelFailed => 'Ошибка';

  @override
  String get travelBookingFailed => 'Не удалось забронировать';

  @override
  String get travelBookingFailedDescription =>
      'Бронирование не завершено. Проверьте статус заказа перед повторной оплатой.';

  @override
  String get travelBookingRefunded => 'Средства возвращены';

  @override
  String get travelBookingRefundedDescription =>
      'Оплата за это бронирование возвращена в кошелёк.';

  @override
  String get travelPendingConfirmation => 'Ожидает подтверждения';

  @override
  String get travelHotelBookingSubmitted => 'Бронирование отеля отправлено';

  @override
  String get travelHotelPendingConfirmationDescription =>
      'Оплата получена. eCardo Travel подтверждает бронирование в отеле у официального поставщика перед выдачей ваучера.';

  @override
  String get travelPaidAmount => 'Оплаченная сумма';

  @override
  String get travelActivationDetails => 'Данные для активации';

  @override
  String get travelActivationInstructions =>
      'Откройте настройки сотовой связи на устройстве, добавьте eSIM и используйте защищённые данные для установки, полученные от сервера eCardo.';

  @override
  String get travelViewMyBookings => 'Показать мои бронирования';

  @override
  String get travelMyBookings => 'Мои бронирования';

  @override
  String get travelAllBookings => 'Все бронирования';

  @override
  String get travelMyHotels => 'Мои отели';

  @override
  String get travelMyFlights => 'Мои рейсы';

  @override
  String get travelMyEsims => 'Мои eSIM';

  @override
  String get travelMyHotelsDescription =>
      'Подтверждённое проживание и ваучеры на отели';

  @override
  String get travelMyFlightsDescription =>
      'Забронированные рейсы и оформленные билеты';

  @override
  String get travelMyEsimsDescription => 'Активные и прошлые интернет-пакеты';

  @override
  String get travelNoBookings => 'У вас пока нет бронирований.';

  @override
  String get travelNoHotels => 'У вас пока нет бронирований отелей.';

  @override
  String get travelNoFlights => 'У вас пока нет авиабронирований.';

  @override
  String get travelNoEsims => 'У вас пока нет покупок eSIM.';

  @override
  String get travelSavedTravelers => 'Сохранённые пассажиры';

  @override
  String get travelNoTravelers => 'Сохранённых пассажиров пока нет.';

  @override
  String get travelAddTraveler => 'Добавить пассажира';

  @override
  String get travelEditTraveler => 'Изменить пассажира';

  @override
  String get travelTravelerFullName => 'Полное имя';

  @override
  String get travelFirstName => 'Имя';

  @override
  String get travelLastName => 'Фамилия';

  @override
  String get travelBirthDate => 'Дата рождения';

  @override
  String get travelPassportExpiry => 'Срок действия паспорта';

  @override
  String get travelGender => 'Пол';

  @override
  String get travelMale => 'Мужской';

  @override
  String get travelFemale => 'Женский';

  @override
  String get travelNotificationContact => 'Уведомления о бронировании';

  @override
  String get travelPhone => 'Номер телефона';

  @override
  String get travelEmail => 'Электронная почта';

  @override
  String get travelPassengerDetailsRequired =>
      'Заполните данные всех пассажиров и укажите номер телефона или эл. почту для уведомлений о бронировании.';

  @override
  String get travelAdultPassenger => 'Взрослый пассажир';

  @override
  String get travelChildPassenger => 'Детский пассажир';

  @override
  String get travelInfantPassenger => 'Младенец (пассажир)';

  @override
  String get travelCompleteTravelerDetails => 'Заполнить данные пассажира';

  @override
  String get travelPassportNumber => 'Номер паспорта';

  @override
  String get travelNationalityCode => 'Код гражданства';

  @override
  String get travelNationalityCodeInvalid => 'Введите двухбуквенный код страны';

  @override
  String get travelFieldRequired => 'Обязательное поле';

  @override
  String get travelSaveTraveler => 'Сохранить пассажира';

  @override
  String get travelAccount => 'Счёт для путешествий';

  @override
  String get travelAccountHolder => 'Участник eCardo';

  @override
  String get travelMemberDescription =>
      'Общий профиль, кошелёк и данные пассажиров';

  @override
  String get travelMyBookingsDescription => 'Отели, рейсы и активные eSIM';

  @override
  String get travelSavedTravelersDescription =>
      'Безопасное повторное использование данных пассажиров';

  @override
  String get travelPersonalInformation => 'Личные данные';

  @override
  String get travelPersonalInformationDescription =>
      'Управляйте данными, передаваемыми в Travel';

  @override
  String get travelHistory => 'История поездок и кошелька';

  @override
  String get travelHistoryDescription =>
      'Покупки и операции с кошельком в одном месте';

  @override
  String get travelNoActivity => 'Нет операций по поездкам или кошельку.';

  @override
  String get travelMockIran => 'Иран';

  @override
  String get travelMockTehran => 'Тегеран';

  @override
  String get travelMockGuests => '2 взрослых, 1 ребёнок';

  @override
  String get travelMockTehranHotels => 'Отели Тегерана';

  @override
  String get travelMockHotelEspinas => 'Espinas Palace Hotel';

  @override
  String get travelMockHotelEspinasLocation => 'Саадат-Абад, Тегеран';

  @override
  String get travelMockHotelParsian => 'Parsian International Hotel';

  @override
  String get travelMockHotelParsianLocation => 'Улица Валиаср, Тегеран';

  @override
  String get travelMockHotelVisteria => 'Visteria Hotel';

  @override
  String get travelMockHotelVisteriaLocation => 'Таджриш, Тегеран';

  @override
  String get travelMockTehranAirport => 'Тегеран (THR)';

  @override
  String get travelMockIstanbulAirport => 'Стамбул (IST)';

  @override
  String get travelMockRouteTehranIstanbul => 'Тегеран → Стамбул';

  @override
  String get travelMockFlightTehranIstanbul => 'Тегеран — Стамбул';

  @override
  String get travelMockAirlineOne => 'eCardo Air';

  @override
  String get travelMockAirlineTwo => 'Atlas Airways';

  @override
  String get travelEsimTurkey => 'eSIM Турция';

  @override
  String get travelRecommended => 'Рекомендуем';

  @override
  String get travelBestValue => 'Оптимальный вариант';

  @override
  String get travelLuxury => 'Люкс';

  @override
  String get travelDirect => 'Без пересадок';

  @override
  String get travelLowestPrice => 'Самая низкая цена';

  @override
  String get travelFeatureBreakfast => 'Завтрак';

  @override
  String get travelFeaturePool => 'Бассейн';

  @override
  String get travelFeatureWifi => 'Wi-Fi';

  @override
  String get travelFeatureParking => 'Парковка';

  @override
  String get travelFeatureAirportTransfer => 'Трансфер';

  @override
  String get travelFeatureCabinBag => 'Ручная кладь';

  @override
  String get travelFeatureRefundable => 'С возможностью возврата';

  @override
  String get travelActivityFlightPurchase => 'Покупка авиабилета';

  @override
  String get travelActivityEsimPurchase => 'Покупка eSIM';

  @override
  String get travelActivityWalletTopUp => 'Пополнение кошелька';

  @override
  String get travelDemoOffer => 'Демо-предложение';

  @override
  String get travelRequiresConfirmation => 'Требуется подтверждение';

  @override
  String get travelHotelBooking => 'Бронирование отеля';

  @override
  String get travelReviewStep => 'Проверка';

  @override
  String get travelConfirmationStep => 'Подтверждение';

  @override
  String get travelReviewConfirmation =>
      'Я проверил(а) и подтверждаю эти данные';

  @override
  String get travelReviewConfirmationDescription =>
      'Подтвердите пассажира, услугу, итоговую сумму и кошелёк перед созданием резервирования.';

  @override
  String get travelReservationHoldActive =>
      'Завершите оплату до истечения срока резервирования';

  @override
  String get travelReservationExpired =>
      'Срок резервирования истёк. Начните заново, чтобы создать новое бронирование.';

  @override
  String get travelNeedsAttention => 'Требует внимания';

  @override
  String get travelUpcomingAndActive => 'Предстоящие и активные';

  @override
  String get travelCancellationsAndRefunds => 'Отмены и возвраты';

  @override
  String get travelPaymentPending => 'Ожидается оплата';

  @override
  String get travelPaymentProcessing => 'Обработка оплаты';

  @override
  String get travelVoucherIssued => 'Ваучер оформлен';

  @override
  String get travelCancellationRequested => 'Запрос на отмену отправлен';

  @override
  String get travelRefundInReview => 'Возврат на рассмотрении';

  @override
  String get travelCancelled => 'Отменено';

  @override
  String get travelExpired => 'Истёк';

  @override
  String get travelStatusUnavailable => 'Статус недоступен';

  @override
  String get travelBookingCancelled => 'Бронирование отменено';

  @override
  String get travelBookingExpired => 'Срок бронирования истёк';

  @override
  String get travelCompletePayment => 'Завершить оплату';

  @override
  String get travelPaymentIsProcessing => 'Идёт обработка оплаты';

  @override
  String get travelFlightRequestSubmitted => 'Запрос на рейс отправлен';

  @override
  String get travelEsimRequestSubmitted => 'Запрос на eSIM отправлен';

  @override
  String get travelBookingStatusUnavailable => 'Статус бронирования недоступен';

  @override
  String get travelBookingCancelledDescription =>
      'Это бронирование отменено. Активный ваучер недоступен.';

  @override
  String get travelBookingExpiredDescription =>
      'Время бронирования истекло до подтверждения.';

  @override
  String get travelCancellationRequestedDescription =>
      'Ваш запрос на отмену ожидает подтверждения от поставщика услуг.';

  @override
  String get travelRefundInReviewDescription =>
      'Ваш запрос на возврат рассматривается. Итоговая сумма и сроки пока не подтверждены.';

  @override
  String get travelPaymentPendingDescription =>
      'Оплата по этому бронированию не подтверждена.';

  @override
  String get travelPaymentProcessingDescription =>
      'Результат операции с кошельком ещё проверяется. Не отправляйте повторную оплату.';

  @override
  String get travelSupplierPendingDescription =>
      'Оплата получена, но подтверждение поставщика или дорожный документ пока не готовы.';

  @override
  String get travelUnknownStatusDescription =>
      'Не удалось распознать актуальный статус бронирования. Обновите «Мои бронирования» перед дальнейшими действиями.';

  @override
  String get travelConfirmedArtifactPendingDescription =>
      'Бронирование подтверждено, но ваучер или билет пока недоступны.';

  @override
  String get travelStatusReference => 'Референс статуса';

  @override
  String get travelRequestRefund => 'Запросить возврат';

  @override
  String get travelCancelBooking => 'Отменить бронирование';

  @override
  String get travelPurchaseDate => 'Дата покупки';

  @override
  String get travelSupplierReference => 'Референс поставщика';

  @override
  String get travelBookingNumber => 'Номер бронирования';

  @override
  String get travelVoucherNumber => 'Номер ваучера';

  @override
  String get travelRoom => 'Номер';

  @override
  String get travelRooms => 'Номера';

  @override
  String get travelBoard => 'Посадка';

  @override
  String get travelCancellationPolicy => 'Правила отмены';

  @override
  String get travelBeneficiary => 'Пассажир или получатель';

  @override
  String get travelDeparture => 'Вылет';

  @override
  String get travelArrival => 'Прибытие';

  @override
  String get travelFlightNumber => 'Номер рейса';

  @override
  String get travelAirline => 'Авиакомпания';

  @override
  String get travelCabin => 'Салон';

  @override
  String get travelBaggage => 'Багаж';

  @override
  String get travelRefundReviewNotice =>
      'Будет отправлен запрос на рассмотрение. Отмена и возврат происходят не мгновенно; возможно применение штрафов поставщика.';

  @override
  String get travelReason => 'Причина';

  @override
  String get travelReasonPlansChanged => 'Изменились планы на поездку';

  @override
  String get travelReasonBookingMistake => 'Ошибка при бронировании';

  @override
  String get travelReasonPersonal => 'Личная причина';

  @override
  String get travelAdditionalNoteOptional => 'Примечание (необязательно)';

  @override
  String get travelKeepBooking => 'Оставить бронирование';

  @override
  String get travelSubmitRequest => 'Отправить запрос';

  @override
  String get travelCancellationUnavailable =>
      'Бронирование нельзя отменить в его текущем статусе.';

  @override
  String get travelRefundRequestAwaitingReview =>
      'Ваш запрос на отмену и возврат ожидает рассмотрения.';

  @override
  String get travelPriceLowToHigh => 'Цена: по возрастанию';

  @override
  String get travelPriceHighToLow => 'Цена: по убыванию';

  @override
  String get travelRatingHighToLow => 'Рейтинг: по убыванию';

  @override
  String get travelAllRatings => 'Все оценки';

  @override
  String get travelRating => 'Рейтинг';

  @override
  String get travelSortAndFilter => 'Сортировка и фильтры';

  @override
  String get travelShortestDuration => 'Самая короткая длительность';

  @override
  String get travelNonRefundable => 'Без возможности возврата';

  @override
  String get travelEsimDeviceReadinessTitle =>
      'Проверьте совместимость устройства';

  @override
  String get travelEsimDeviceReadinessDescription =>
      'Перед покупкой убедитесь, что устройство поддерживает eSIM и не привязано к одному оператору.';

  @override
  String get travelEsimCompatibilityNotice =>
      'Покупка пакета не гарантирует совместимость с устройством. Данные для установки появятся после того, как сервер отметит eSIM готовой.';

  @override
  String get travelEsimValidity => 'Срок действия';

  @override
  String get travelEsimActivationReady => 'Данные для установки eSIM готовы.';

  @override
  String get travelPaymentReceived => 'Оплата получена';

  @override
  String get travelPaymentReceivedDescription =>
      'Оплата получена. eCardo Travel завершает подтверждение с поставщиком перед выдачей итогового документа.';

  @override
  String get travelSearchFailedDescription =>
      'Поиск не завершён. Прошлые результаты показываются, если доступны; измените запрос или повторите попытку.';

  @override
  String get travelReservationFailedDescription =>
      'Резервирование не создано. Списаний с кошелька в этом сеансе приложения не было.';

  @override
  String get travelRefundFailedDescription =>
      'Запрос на отмену или возврат не отправлен. Проверьте бронирование и попробуйте снова.';

  @override
  String get travelNoPaymentAttemptedAfterExpiry =>
      'За истёкшее бронирование оплата в этом сеансе приложения не взималась и не предпринималась.';

  @override
  String get travelLastUpdated => 'Обновлено';

  @override
  String get travelJourneySearch => 'Поиск';

  @override
  String get travelJourneyCompare => 'Сравнить';

  @override
  String get travelJourneyReview => 'Проверка';

  @override
  String get travelJourneyPay => 'Оплатить';

  @override
  String get travelHotelSearchGuidance =>
      'Выберите направление, даты и число гостей. Результаты и наличие всегда предоставляются сервером Travel.';

  @override
  String get travelHotelResultsGuidance =>
      'Перед открытием варианта сравните цену, рейтинг, удобства, расположение, номера и правила из данных сервера.';

  @override
  String get travelHotelDetailsGuidance =>
      'Проверьте отель, характеристики номеров, число гостей, цену и правила отмены перед продолжением.';

  @override
  String get travelFlightSearchGuidance =>
      'Выберите маршрут, дату и количество пассажиров. Наличие рейсов и тарифы всегда предоставляются сервером Travel.';

  @override
  String get travelFlightResultsGuidance =>
      'Перед выбором сравните время рейса, авиакомпанию, класс, багаж, тариф и возможность возврата из данных сервера.';

  @override
  String get travelFlightDetailsGuidance =>
      'Проверьте рейс, составляющие тарифа, багаж, количество пассажиров и правила отмены перед продолжением.';

  @override
  String travelSelectedForComparison(int count) {
    return 'Выбрано: $count';
  }

  @override
  String get travelCompare => 'Сравнить';

  @override
  String get travelCompareLimit =>
      'Можно сравнить до трёх вариантов одновременно.';

  @override
  String get travelCompareHotels => 'Сравнить отели';

  @override
  String get travelCompareFlights => 'Сравнить рейсы';

  @override
  String get travelComparisonUsesBackendFacts =>
      'Показаны только данные, полученные от сервера. Недостающие данные не предполагаются.';

  @override
  String get travelAddress => 'Адрес';

  @override
  String get travelAircraft => 'Самолёт';

  @override
  String get travelDescription => 'Описание';

  @override
  String get travelDuration => 'Длительность';

  @override
  String get travelRefundPolicy => 'Правила возврата';

  @override
  String get travelPostPurchaseGuidance =>
      'Сохраните номер подтверждения, обновляйте «Мои бронирования» для изменений статуса и используйте для поездки только оформленные документы от сервера.';

  @override
  String get remittanceTitle => 'Международный перевод';

  @override
  String get remittanceHistoryTitle => 'История переводов';

  @override
  String get remittanceDetailsTitle => 'Детали перевода';

  @override
  String get remittanceSelectPayoutMethod => 'Выберите способ выплаты';

  @override
  String get remittanceNoMethods =>
      'Доступные способы переводов не найдены.\nПожалуйста, попробуйте позже.';

  @override
  String get remittanceSendAmount => 'Сумма отправления';

  @override
  String get remittanceSendCurrency => 'Валюта отправки';

  @override
  String get remittanceSelectSendCurrency => 'Выберите валюту отправки';

  @override
  String get remittanceLoadingCurrencies => 'Загрузка валют…';

  @override
  String get remittanceNoCurrencies => 'Нет доступных валют';

  @override
  String get remittanceEnterAmount => 'Введите сумму';

  @override
  String get remittanceUnknownMethod => 'Неизвестно';

  @override
  String remittanceRateLocked(int seconds) {
    return 'Курс зафиксирован: $seconds с';
  }

  @override
  String get remittanceExchangeRate => 'Курс обмена';

  @override
  String get remittanceReceiveAmount => 'Сумма к получению';

  @override
  String get remittanceSystemFee => 'Системная комиссия';

  @override
  String get remittanceTotalPayable => 'Итого к оплате';

  @override
  String get remittanceGetQuote => 'Получить котировку';

  @override
  String get remittanceStepAmount => 'Сумма';

  @override
  String get remittanceStepSender => 'Отправитель';

  @override
  String get remittanceStepReceiver => 'Получатель';

  @override
  String get remittanceStepReview => 'Проверка';

  @override
  String get remittanceStepDone => 'Готово';

  @override
  String get remittanceSenderInfo => 'Информация об отправителе';

  @override
  String get remittanceSelectCountry => 'Выберите страну';

  @override
  String get remittanceSenderTypeIndividual => 'Физическое лицо';

  @override
  String get remittanceSenderTypeBusiness => 'Юридическое лицо';

  @override
  String get remittanceSenderName => 'Полное имя';

  @override
  String get remittanceSenderPhone => 'Номер телефона';

  @override
  String get remittanceSenderIdNumber => 'Номер документа';

  @override
  String get remittanceReceiverInfo => 'Информация о получателе';

  @override
  String get remittancePayoutDetails => 'Детали выплаты';

  @override
  String get remittancePayoutDetailsHint =>
      'Заполните поля, относящиеся к выбранному способу выплаты.';

  @override
  String get remittanceReceiverName => 'Полное имя';

  @override
  String get remittanceReceiverPhone => 'Номер телефона';

  @override
  String get remittanceBankName => 'Название банка';

  @override
  String get remittanceAccountNumber => 'Номер счёта';

  @override
  String get remittanceIban => 'IBAN';

  @override
  String get remittanceAlipayAccount => 'Счёт Alipay';

  @override
  String get remittanceWechatAccount => 'Счёт WeChat';

  @override
  String get remittanceReviewConfirm => 'Проверка и подтверждение';

  @override
  String get remittanceReviewHint =>
      'Проверьте все данные перед отправкой заявки на перевод.';

  @override
  String get remittanceTermsNotice =>
      'Отправляя заявку, вы соглашаетесь с условиями переводов. Курс фиксируется на 15 минут. После отправки потребуется загрузить документы KYC и квитанцию об оплате.';

  @override
  String get remittanceReviewSender => 'Отправитель';

  @override
  String get remittanceReviewReceiver => 'Получатель';

  @override
  String get remittanceReviewPayment => 'Платёж';

  @override
  String get remittanceRequestSubmitted => 'Заявка отправлена!';

  @override
  String get remittanceRequestCreated => 'Ваша заявка на перевод создана.';

  @override
  String get remittanceUploadDocuments => 'Загрузить документы';

  @override
  String get remittanceUploadHint =>
      'Загрузите документы KYC и квитанцию об оплате, чтобы продолжить.';

  @override
  String get remittanceAddDocument => 'Добавить документ';

  @override
  String get remittanceDocumentType => 'Тип документа';

  @override
  String get remittanceDocTypeKyc => 'Документ KYC';

  @override
  String get remittanceDocTypePaymentReceipt => 'Квитанция об оплате';

  @override
  String get remittanceDocTypePayoutReceipt => 'Квитанция о выплате';

  @override
  String get remittanceDocTypeOther => 'Другое';

  @override
  String get remittanceCancel => 'Отмена';

  @override
  String get remittanceAdd => 'Добавить';

  @override
  String get remittanceTakePhoto => 'Сделать фото';

  @override
  String get remittanceChooseFromGallery => 'Выбрать из галереи';

  @override
  String get remittanceChooseFile => 'Выбрать файл';

  @override
  String get remittanceErrFileNotFound => 'Выбранный файл не существует';

  @override
  String get remittanceErrPickFile => 'Не удалось выбрать файл';

  @override
  String get remittanceErrNoValidFiles =>
      'Нет подходящих файлов для загрузки. Пожалуйста, выберите документы заново.';

  @override
  String get remittanceContinue => 'Продолжить';

  @override
  String get remittanceSubmitRequest => 'Отправить заявку';

  @override
  String get remittanceUploading => 'Загрузка...';

  @override
  String get remittanceRefresh => 'Обновить';

  @override
  String get remittanceNoHistory => 'Переводов пока нет';

  @override
  String get remittanceNoHistoryHint =>
      'Здесь появится история ваших переводов.';

  @override
  String get remittanceSend => 'Отправка';

  @override
  String get remittanceReceive => 'Получение';

  @override
  String get remittanceDate => 'Дата';

  @override
  String get remittanceNotFound => 'Перевод не найден';

  @override
  String get remittanceStatusFinalized => 'Эта заявка завершена.';

  @override
  String get remittanceStatusProcessing => 'Ваша заявка обрабатывается.';

  @override
  String get remittanceStatusActionNeeded => 'Выполните необходимые шаги.';

  @override
  String get remittanceDetailsSectionSender => 'Информация об отправителе';

  @override
  String get remittanceDetailsSectionReceiver => 'Информация о получателе';

  @override
  String get remittanceDetailsSectionPayment => 'Детали платежа';

  @override
  String get remittanceDetailsSectionTimeline => 'Хронология статусов';

  @override
  String get remittanceErrLoadMethods => 'Не удалось загрузить способы';

  @override
  String get remittanceErrSelectPayout => 'Выберите способ выплаты';

  @override
  String get remittanceErrInvalidAmount => 'Введите корректную сумму';

  @override
  String get remittanceErrSelectSendCurrency => 'Выберите валюту отправления';

  @override
  String get remittanceErrQuoteFailed => 'Не удалось получить котировку';

  @override
  String get remittanceErrRequestQuoteFirst => 'Сначала запросите котировку';

  @override
  String get remittanceErrQuoteExpired =>
      'Срок котировки истёк. Запросите новую.';

  @override
  String get remittanceErrSenderInfo => 'Заполните информацию об отправителе';

  @override
  String get remittanceErrReceiverInfo => 'Заполните информацию о получателе';

  @override
  String get remittanceErrSubmissionFailed => 'Не удалось отправить заявку';

  @override
  String get remittanceErrNoRemittance =>
      'Нет перевода для загрузки документов';

  @override
  String get remittanceErrAddDocument => 'Добавьте хотя бы один документ';

  @override
  String get remittanceErrUploadFailed => 'Не удалось загрузить файлы';

  @override
  String get remittanceErrLoadDetails => 'Не удалось загрузить данные';

  @override
  String get remittanceErrCompleteSender => 'Заполните все поля отправителя';

  @override
  String get remittanceErrCompleteReceiver => 'Заполните все поля получателя';

  @override
  String get remittanceSuccessUploaded => 'Документы успешно загружены';

  @override
  String get remittanceError => 'Ошибка';

  @override
  String get remittanceStatusDraft => 'Черновик';

  @override
  String get remittanceStatusWaitingInformation => 'Ожидание информации';

  @override
  String get remittanceStatusWaitingDocuments => 'Ожидание документов';

  @override
  String get remittanceStatusWaitingPayment => 'Ожидание платежа';

  @override
  String get remittanceStatusPaymentReviewing => 'Платёж проверяется';

  @override
  String get remittanceStatusInProcess => 'В обработке';

  @override
  String get remittanceStatusDestinationProcessing => 'Выплата обрабатывается';

  @override
  String get remittanceStatusDestinationPaid => 'Выплачено получателю';

  @override
  String get remittanceStatusCompleted => 'Завершён';

  @override
  String get remittanceStatusRejected => 'Отклонён';

  @override
  String get remittanceStatusExpired => 'Истёк';

  @override
  String get remittanceStatusCancelled => 'Отменён';

  @override
  String get remittanceStatusRefundRequested => 'Запрошен возврат';

  @override
  String get remittanceStatusRefundCompleted => 'Возврат завершён';

  @override
  String get remittanceStatusUnknown => 'Неизвестен';

  @override
  String get remittanceRetry => 'Повторить';

  @override
  String get remittanceYouSend => 'Вы отправляете';

  @override
  String get remittanceReceiverGets => 'Получатель получит';

  @override
  String get remittanceDeliveryMethod => 'Способ доставки';

  @override
  String remittanceAmountLimitHint(String min, String max) {
    return 'Лимит: мин $min · макс $max';
  }

  @override
  String remittanceErrAmountLimits(String min, String max) {
    return 'Сумма должна быть от $min до $max';
  }

  @override
  String remittanceErrRequiredField(String field) {
    return 'Введите $field';
  }

  @override
  String get remittanceFieldSwift => 'Код SWIFT';

  @override
  String get remittanceFieldShabaNumber => 'Номер SHABA';

  @override
  String get remittanceFieldUsdtAddress => 'Адрес USDT (TRC20)';

  @override
  String get remittanceFieldCardNumber => 'Номер карты';

  @override
  String get remittanceRateSourceAdmin => 'Курс оператора';

  @override
  String get remittanceRateSourceAuto => 'Рыночный курс';

  @override
  String get exchangeCalculating => 'Расчёт…';

  @override
  String get biometricNotAvailable =>
      'Биометрическая аутентификация недоступна на этом устройстве';

  @override
  String get biometricSetupFailed =>
      'Не удалось запустить биометрическую аутентификацию';

  @override
  String biometricFailedAttempts(int attempts) {
    return 'Биометрия не пройдена. Осталось попыток: $attempts';
  }

  @override
  String get biometricMaxAttempts =>
      'Достигнут лимит биометрических попыток. Войдите с паролем';

  @override
  String get biometricReason => 'Пройдите аутентификацию для входа в eCardo';

  @override
  String get biometricGenericError =>
      'Биометрическая аутентификация не пройдена';

  @override
  String get dynamicPasswordUserNotFound =>
      'Ошибка: данные пользователя не найдены';

  @override
  String get dynamicPasswordGenerateError =>
      'Не удалось создать динамический пароль';

  @override
  String get licenseRequiredTitle => 'Требуется лицензия';

  @override
  String get commonClose => 'Закрыть';

  @override
  String get contactSupport => 'Связаться с поддержкой';

  @override
  String get updateCancelDownloadTitle => 'Отменить загрузку?';

  @override
  String get updateContinueDownload => 'Продолжить загрузку';

  @override
  String updateAvailableTitle(String version) {
    return 'Доступно обновление ($version)';
  }

  @override
  String get updateLater => 'Позже';

  @override
  String get kycDocumentsRequired => 'Необходимы документы.';

  @override
  String get kycUploadFailed => 'Не удалось загрузить. Попробуйте снова.';

  @override
  String get p2pSelectFiatFirst => 'Сначала выберите фиатную валюту';

  @override
  String get p2pLoadPaymentMethodsFailed =>
      'Не удалось загрузить способы оплаты';

  @override
  String get p2pLoadAdsFailed => 'Не удалось загрузить объявления';

  @override
  String get pickDocumentFailed =>
      'Не удалось выбрать документ. Попробуйте снова.';

  @override
  String get hotel_active_filters => 'Активные фильтры';

  @override
  String get hotel_all_cities_with_hotels => 'Все города с отелями';

  @override
  String get hotel_all_filters => 'Все фильтры';

  @override
  String get hotel_all_ratings => 'Все оценки';

  @override
  String get hotel_apply_filters => 'Применить фильтры';

  @override
  String get hotel_available_rooms => 'Доступные номера';

  @override
  String get hotel_by_continuing_you_accept_the => 'Продолжая, вы принимаете ';

  @override
  String get hotel_check_in => 'Заезд';

  @override
  String get hotel_check_in_and_check_out => 'Заезд и выезд';

  @override
  String get hotel_check_out => 'Выезд';

  @override
  String get hotel_checking_availability => 'Проверка наличия мест';

  @override
  String get hotel_clear_all => 'Очистить всё';

  @override
  String get hotel_close => 'Закрыть';

  @override
  String get hotel_complete_the_reservator_and_room_caretaker_i =>
      'Заполните данные бронирующего и ответственных за номера.';

  @override
  String get hotel_confirm_dates => 'Подтвердить даты';

  @override
  String get hotel_continue_booking => 'Продолжить бронирование';

  @override
  String get hotel_destination_city_or_hotel => 'Город или отель назначения';

  @override
  String get hotel_details => 'Подробнее';

  @override
  String get hotel_discounted => 'Со скидкой';

  @override
  String get hotel_discounted_hotels_only => 'Только отели со скидкой';

  @override
  String get hotel_edit_dates => 'Изменить даты';

  @override
  String get hotel_features => 'Удобства';

  @override
  String get hotel_for_example_non_smoking_room_or_estimated_ar =>
      'Например, номер для некурящих или предполагаемое время прибытия';

  @override
  String get hotel_gregorian => 'Григорианский календарь';

  @override
  String get hotel_guest_rating => 'Оценка гостей';

  @override
  String get hotel_guest_ratings_and_reviews => 'Оценки и отзывы гостей';

  @override
  String get hotel_hotel_features => 'Удобства отеля';

  @override
  String get hotel_hotel_filters => 'Фильтры отелей';

  @override
  String get hotel_hotel_stars => 'Звёзды отеля';

  @override
  String get hotel_hotels_with_available_rooms_only =>
      'Только отели со свободными номерами';

  @override
  String get hotel_nights => 'ночей';

  @override
  String get hotel_no_matching_city_or_hotel_was_found =>
      'Город или отель с таким названием не найден.';

  @override
  String get hotel_no_recommended_hotels_are_available_for_this =>
      'Для этого города нет рекомендуемых отелей.';

  @override
  String get hotel_only_one_responsible_guest_is_needed_for_eac =>
      'Для каждого номера достаточно данных одного ответственного гостя; вводить данные всех пассажиров не требуется.';

  @override
  String get hotel_overview => 'Обзор';

  @override
  String get hotel_passenger_information => 'Данные пассажира';

  @override
  String get hotel_persian => 'Персидский календарь';

  @override
  String get hotel_popular_cities => 'Популярные города';

  @override
  String get hotel_price_range => 'Диапазон цен';

  @override
  String get hotel_property_type => 'Тип размещения';

  @override
  String get hotel_recommended_hotels => 'Рекомендуемые отели';

  @override
  String get hotel_refine_your_results => 'Уточните результаты';

  @override
  String get hotel_reservation_details_and_every_order_update_w =>
      'Данные брони и все изменения заказа будут отправлены бронирующему.';

  @override
  String get hotel_reservator_information => 'Данные бронирующего';

  @override
  String get hotel_reviews => 'Отзывы';

  @override
  String get hotel_room => 'Номер';

  @override
  String get hotel_room_caretakers => 'Ответственные за номера';

  @override
  String get hotel_room_details => 'Детали номера';

  @override
  String get hotel_room_information => 'Информация о номере';

  @override
  String get hotel_rooms => 'Номера';

  @override
  String get hotel_rules => 'Правила';

  @override
  String get hotel_search_by_city_or_hotel_name =>
      'Поиск по городу или названию отеля';

  @override
  String get hotel_search_hotel_name => 'Поиск по названию отеля';

  @override
  String get hotel_search_results => 'Результаты поиска';

  @override
  String get hotel_select_a_destination_city_or_hotel =>
      'Выберите город или отель назначения.';

  @override
  String get hotel_select_stay_dates => 'Выберите даты проживания';

  @override
  String get hotel_show_less => 'Свернуть';

  @override
  String get hotel_show_more => 'Показать ещё';

  @override
  String get hotel_show_more_2 => 'Показать все удобства';

  @override
  String get hotel_similar_hotels => 'Похожие отели';

  @override
  String get hotel_special_offers => 'Специальные предложения';

  @override
  String get hotel_special_requests_optional =>
      'Особые пожелания (необязательно)';

  @override
  String get hotel_terms_and_privacy_policy =>
      'Условия и политика конфиденциальности';

  @override
  String get hotel_terms_and_privacy_policy_2 =>
      'условия и политику конфиденциальности';

  @override
  String get hotel_the_terms_for_this_service_are_admin_control =>
      'Условия этой услуги задаются администратором. Перед оплатой ознакомьтесь с правилами отеля, отмены, возврата средств и конфиденциальности.';

  @override
  String hotelHotelsCount(String count) {
    return '$count отелей';
  }

  @override
  String hotelRoomsForNights(int rooms, int nights) {
    return '$rooms номеров на $nights ночей';
  }

  @override
  String hotelPriceNightsOneRoom(int nights) {
    return 'Цена за $nights ночей и один номер';
  }

  @override
  String hotelRoomsTimesNights(int quantity, int nights) {
    return '$quantity номеров × $nights ночей';
  }

  @override
  String hotelOneRoomNights(int nights) {
    return 'Один номер на $nights ночей';
  }

  @override
  String hotelNightsCount(int count) {
    return '$count ночей';
  }

  @override
  String get dynamicPasswordServerError => 'Ошибка связи с сервером.';

  @override
  String get dynamicPasswordConnectionError => 'Ошибка соединения.';

  @override
  String get dynamicPasswordHeading => 'Динамический пароль';

  @override
  String get dynamicPasswordSubtitle =>
      'Шестизначный код для оплаты из кошелька.';

  @override
  String get dynamicPasswordValidity =>
      'Действует 60 секунд — только одно использование.';

  @override
  String get dynamicPasswordCopied => 'Код скопирован.';

  @override
  String get dynamicPasswordCopy => 'Копировать код';

  @override
  String get dynamicPasswordRegenerate => 'Сгенерировать новый код';

  @override
  String get dynamicPasswordGenerate => 'Сгенерировать динамический пароль';

  @override
  String get dynamicPasswordUsageHint =>
      'Введите этот код на странице оплаты. Код действует 60 секунд и может быть использован только один раз.';

  @override
  String get vcUnableLoadProducts => 'Не удалось загрузить продукты карт.';

  @override
  String get vcOrderNotCompleted => 'Не удалось завершить заказ карты.';

  @override
  String get vcProductUnavailable => 'Продукт карты недоступен.';

  @override
  String get vcEnterValidAmountIrr =>
      'Введите корректную сумму в иранских риалах.';

  @override
  String vcMinInitialLoad(num amount) {
    return 'Минимальное первоначальное пополнение — $amount IRR.';
  }

  @override
  String vcMaxInitialLoad(num amount) {
    return 'Максимальное первоначальное пополнение — $amount IRR.';
  }

  @override
  String get vcSelectIrrWallet => 'Выберите кошелёк IRR.';

  @override
  String get vcSelectGateway => 'Выберите платёжный шлюз.';

  @override
  String get vcCompleteCardholder => 'Заполните данные держателя карты.';

  @override
  String get vcStatusPaymentPending => 'Заказ карты создан и ожидает оплаты.';

  @override
  String get vcStatusProvisioning => 'Выполняется выпуск карты.';

  @override
  String get vcStatusReady => 'Ваша карта готова.';

  @override
  String get vcStatusCreated => 'Заказ карты создан.';

  @override
  String vcMinTopup(num amount, String currency) {
    return 'Минимальное пополнение — $amount $currency.';
  }

  @override
  String vcMaxTopup(num amount, String currency) {
    return 'Максимальное пополнение — $amount $currency.';
  }

  @override
  String get vcTopupNotCompleted => 'Не удалось завершить пополнение карты.';

  @override
  String get vcTopupSubmitted => 'Заявка на пополнение карты отправлена.';

  @override
  String get hotel_admin_configured_special_offers_will_appear =>
      'Специальные предложения, добавленные администратором, появятся здесь.';

  @override
  String get kycUpgradeRequiredTitle =>
      'Требуется повышение уровня верификации';

  @override
  String kycUpgradeBodyForLevel(int level) {
    return 'Чтобы использовать эту функцию, ваша верификация должна достичь уровня $level.';
  }

  @override
  String get kycUpgradeBodyGeneric =>
      'Ваш текущий уровень верификации не позволяет это действие. Завершите или повысьте уровень верификации.';

  @override
  String get kycUpgradeCurrentLevel => 'Текущий уровень:';

  @override
  String get kycUpgradeRequiredLevel => 'Требуемый уровень:';

  @override
  String kycUpgradeLevelChip(int level) {
    return 'Уровень $level';
  }

  @override
  String get kycUpgradeStartVerification => 'Начать верификацию';

  @override
  String get kycUpgradeLater => 'Сделаю позже';

  @override
  String get kycVerificationUnavailable =>
      'Сервис верификации временно недоступен. Пожалуйста, попробуйте ещё раз через несколько минут.';

  @override
  String get kycFeatureTransfer => 'Перевод';

  @override
  String get kycFeatureExchange => 'Обмен';

  @override
  String get kycFeatureWithdraw => 'Вывод средств';

  @override
  String get kycFeatureCashout => 'Обналичивание';

  @override
  String get kycFeatureGiftSend => 'Отправка подарков';

  @override
  String get kycFeatureGiftRedeem => 'Активация подарков';

  @override
  String get kycFeaturePayBill => 'Оплата счетов';

  @override
  String get kycFeatureRequestMoney => 'Запросы денег';

  @override
  String get kycFeaturePayment => 'Оплата продавцу';

  @override
  String get kycFeatureInvoices => 'Оплата инвойсов';

  @override
  String get kycFeaturePaymentLinks => 'Платёжные ссылки';

  @override
  String get kycFeatureTravel => 'Бронирование поездок';

  @override
  String get kycFeatureRemittance => 'Денежные переводы';

  @override
  String get kycFeatureEpay => 'Электронная оплата (ePay)';

  @override
  String get kycRoadmapTitle => 'Маршрут верификации';

  @override
  String kycRoadmapContinueForLevel(int level) {
    return 'Продолжить верификацию — уровень $level';
  }

  @override
  String get kycRoadmapPending =>
      'Ваши документы на рассмотрении. Обычно это занимает 1–2 рабочих дня.';

  @override
  String get kycRoadmapRejectedTitle => 'Ваша верификация отклонена.';

  @override
  String get kycRoadmapRejectedAction =>
      'Пожалуйста, отправьте документы снова.';

  @override
  String get kycRoadmapStatusCompleted => 'Завершён';

  @override
  String get kycRoadmapStatusCurrent => 'Текущий';

  @override
  String get kycRoadmapStatusAvailable => 'Доступен для повышения';

  @override
  String get kycRoadmapStatusLocked => 'Заблокирован';

  @override
  String get kycLimitsSectionTitle => 'Лимиты транзакций';

  @override
  String get kycLimitGroupCashin => 'Пополнение';

  @override
  String get kycLimitGroupCashout => 'Обналичивание';

  @override
  String get kycLimitGroupExchange => 'Обмен';

  @override
  String get kycLimitGroupTransfer => 'Перевод';

  @override
  String get kycLimitGroupPayment => 'Оплата';

  @override
  String get kycLimitGroupGift => 'Подарки';

  @override
  String get kycLimitPaycardoTopup => 'Пополнение PayCardo';

  @override
  String get kycLimitMeasureMin => 'мин';

  @override
  String get kycLimitMeasureMax => 'макс';

  @override
  String get kycLimitMeasureDaily => 'в день';

  @override
  String get kycLimitMeasureMonthly => 'в месяц';

  @override
  String get kycDocSelfie => 'Селфи';

  @override
  String get kycDocGovtId => 'Удостоверение личности';

  @override
  String get kycDocPersonalInfo => 'Личная информация';

  @override
  String get kycDocTradeLicense => 'Торговая лицензия';

  @override
  String get kycDocBusinessInfo => 'Информация о бизнесе';

  @override
  String get kycDocCompanyDocs => 'Документы компании';

  @override
  String get kycDocNationalCard => 'Национальное удостоверение личности';

  @override
  String get kycDocSourceOfFunds => 'Подтверждение источника средств';

  @override
  String get kycDocVideoVerification => 'Видеоверификация';

  @override
  String get kycDocSelfieHint =>
      'Сделайте чёткое селфи при хорошем освещении, лицо полностью видно.';

  @override
  String get kycDocGovtIdHint =>
      'Чёткое фото удостоверения личности с обеих сторон. Все данные должны быть читаемы.';

  @override
  String get kycDocPersonalInfoHint =>
      'Личная информация, включая адрес, почтовый индекс и номер телефона.';

  @override
  String get kycDocTradeLicenseHint =>
      'Отсканированная копия действующей торговой лицензии.';

  @override
  String get kycDocBusinessInfoHint =>
      'Полная информация о бизнесе, включая название, вид деятельности и адрес.';

  @override
  String get kycDocCompanyDocsHint =>
      'Регистрационные документы компании, устав и уведомление о создании.';

  @override
  String get kycDocNationalCardHint =>
      'Чёткое фото национального удостоверения с обеих сторон. Все данные должны быть читаемы.';

  @override
  String get kycDocSourceOfFundsHint =>
      'Документ, подтверждающий источник средств (расчётный лист, банковская выписка, доход от бизнеса…).';

  @override
  String get kycDocVideoVerificationHint =>
      'Запишите короткое видео своего лица, следуя инструкциям на экране.';

  @override
  String get kycDocGenericHint => 'Пожалуйста, загрузите необходимый документ.';

  @override
  String kycSubmitWizardTitleForLevel(int level) {
    return 'Верификация — уровень $level';
  }

  @override
  String get kycSubmitWizardInvalidLevel => 'Недопустимый уровень';

  @override
  String get kycSubmitWizardRequiredDoc => 'Необходимый документ';

  @override
  String get kycSubmitWizardTapToUpload => 'Нажмите для загрузки';

  @override
  String get kycSubmitWizardFileFormat =>
      'Формат: JPG, PNG, PDF — не более 20 МБ';

  @override
  String get kycSubmitWizardReviewTitle => 'Проверка и отправка';

  @override
  String get kycSubmitWizardNotUploaded => 'Не загружено';

  @override
  String get kycSubmitWizardReviewNote =>
      'После отправки ваши документы проверяет администратор. Обычно это занимает 1–2 рабочих дня.';

  @override
  String get kycSubmitWizardSubmit => 'Отправить документы';

  @override
  String get kycSubmitWizardContinue => 'Продолжить';

  @override
  String kycSubmitWizardUploaded(String fileName) {
    return 'Загружено: $fileName';
  }

  @override
  String get updateNotificationTitle => 'Доступна новая версия';

  @override
  String get updateNotificationTitleForce => 'Требуется обновление';

  @override
  String updateNotificationBody(String version) {
    return 'Доступна eCardo v$version. Нажмите для обновления.';
  }

  @override
  String get updateNotificationBodyGeneric =>
      'Доступна новая версия eCardo. Нажмите для обновления.';

  @override
  String get updateDialogBody =>
      'Доступна новая версия приложения. Пожалуйста, обновите, чтобы продолжить.';

  @override
  String updateWhatsNewTitle(String version) {
    return 'Что нового в v$version';
  }

  @override
  String get updateWhatsNewFallback =>
      'Исправления ошибок и улучшения производительности.';

  @override
  String get updateDialogDownload => 'Скачать и обновить';

  @override
  String get updateWebBody =>
      'Доступна новая версия. Обновите страницу, чтобы получить последнюю версию.';

  @override
  String get updateWebRefresh => 'Обновить страницу';

  @override
  String get updateSystemTitle => 'Система';

  @override
  String get updateUpToDate => 'У вас последняя версия.';

  @override
  String updateUpToDateWithVersion(String version) {
    return 'Приложение обновлено ($version).';
  }

  @override
  String get updateCancelDownloadBody =>
      'Загрузка обновления ещё идёт. Вы уверены, что хотите отменить?';

  @override
  String get updateCancel => 'Отмена';

  @override
  String get updateCheckingTitle => 'Проверка обновлений…';

  @override
  String get updateCheckingBody =>
      'Связываемся с сервером eCardo для получения последней версии.';

  @override
  String get updateUpToDateScreenTitle => 'У вас последняя версия!';

  @override
  String updateUpToDateScreenBody(String version) {
    return 'eCardo v$version — последняя доступная версия.';
  }

  @override
  String get updateDoneButton => 'Готово';

  @override
  String get updateCheckAgain => 'Проверить снова';

  @override
  String get updateAvailableScreenTitle => 'Доступно обновление';

  @override
  String get updateCurrentLabel => 'Текущая';

  @override
  String get updateNewLabel => 'Новая';

  @override
  String get updateForceNote =>
      'Это обновление обязательно. Приложением нельзя пользоваться, пока вы не обновитесь.';

  @override
  String get updateMaybeLater => 'Может быть, позже';

  @override
  String get updateStartingDownload => 'Начало загрузки…';

  @override
  String get updateInstallingTitle => 'Установка обновления…';

  @override
  String get updateInstallingBody =>
      'Android устанавливает новую версию. Следуйте системному запросу для завершения установки.';

  @override
  String get updateInstallFinished => 'Установка завершена';

  @override
  String get updateFailedTitle => 'Не удалось обновить';

  @override
  String get updateUnknownError => 'Произошла неизвестная ошибка.';

  @override
  String get updateTryAgain => 'Попробовать снова';

  @override
  String get updateGoBack => 'Назад';

  @override
  String kycBadgeUpgradeTo(Object level) {
    return 'Обновить до $level';
  }

  @override
  String get kycBadgeStatusVerified => 'Подтверждено';

  @override
  String get kycBadgeStatusPending => 'На рассмотрении';

  @override
  String get kycBadgeStatusRejected => 'Отклонено';

  @override
  String get kycBadgeStatusNotSubmitted => 'Не отправлено';

  @override
  String get kycUpgradeDialogTitle => 'Повышение уровня верификации';

  @override
  String kycUpgradeDialogBody(Object feature, Object level) {
    return 'Для доступа к «$feature» необходим уровень верификации $level.';
  }

  @override
  String kycUpgradeLevelValue(Object level) {
    return 'Уровень $level';
  }

  @override
  String get kycUpgradeStartAction => 'Начать верификацию';

  @override
  String get walletListEmptyTitle => 'Кошельков пока нет';

  @override
  String get walletListEmptySubtitle =>
      'Создайте первый кошелёк, чтобы начать.';

  @override
  String get walletListEmptyCreate => 'Создать кошелёк';

  @override
  String get p2pStepTypeAndPrice => 'Тип и цена';

  @override
  String get p2pStepAmountAndMethod => 'Сумма и способ оплаты';

  @override
  String get p2pStepConditions => 'Условия';

  @override
  String get p2pFailedToLoadAdDetails =>
      'Не удалось загрузить детали объявления';

  @override
  String get p2pFailedToLoadOrderDetails =>
      'Не удалось загрузить детали заказа';

  @override
  String get p2pFailedToCreateOrder => 'Не удалось создать заказ';

  @override
  String get p2pFailedToChangePaymentMethod =>
      'Не удалось изменить способ оплаты';

  @override
  String get p2pFailedToCancelOrder => 'Не удалось отменить заказ';

  @override
  String get p2pFailedToNotifySeller => 'Не удалось уведомить продавца';

  @override
  String get p2pFailedToSubmitDispute => 'Не удалось отправить спор';

  @override
  String get p2pFailedToReleaseOrder => 'Не удалось освободить заказ';

  @override
  String get p2pOrderCreatedMissingDetails =>
      'Заказ создан, но его детали не открылись';

  @override
  String get p2pEnterValidAssetAmount => 'Введите корректную сумму актива';

  @override
  String get p2pAdCreatedSuccess => 'Объявление успешно создано';

  @override
  String p2pAmountBetweenLimit(String min, String max, String currency) {
    return 'Сумма должна быть от $min до $max $currency';
  }

  @override
  String p2pAmountMinLimit(String min, String currency) {
    return 'Сумма должна быть не менее $min $currency';
  }

  @override
  String p2pAmountMaxLimit(String max, String currency) {
    return 'Сумма должна быть не более $max $currency';
  }

  @override
  String get p2pStatusPending => 'В ожидании';

  @override
  String get p2pStatusPendingPayment => 'Ожидание оплаты';

  @override
  String get p2pStatusPaid => 'Оплачено';

  @override
  String get p2pStatusCompleted => 'Завершено';

  @override
  String get p2pStatusCancelled => 'Отменено';

  @override
  String get p2pStatusExpired => 'Истёк';

  @override
  String get p2pStatusFailed => 'Не удалось';

  @override
  String get p2pStatusRejected => 'Отклонено';

  @override
  String get p2pStatusDisputed => 'Спор';

  @override
  String get p2pStatusActive => 'Активно';

  @override
  String get p2pStatusInactive => 'Неактивно';

  @override
  String get bottomNavMyCards => 'Карты';

  @override
  String get myCardsNotEnabled =>
      'Мои карты пока не включены для вашего аккаунта.';

  @override
  String get financialServicesTitle => 'Финансовые услуги';

  @override
  String get travelServicesTitle => 'Туристические услуги';

  @override
  String get travelServicesHint =>
      'Выберите страну назначения, чтобы увидеть доступные услуги';

  @override
  String get travelAvailableNow => 'Доступно сейчас';

  @override
  String get travelComingSoonSection => 'Скоро';

  @override
  String get businessServicesTitle => 'Деловые и коммерческие услуги';

  @override
  String get serviceNotAvailableYet =>
      'Эта услуга пока недоступна в вашем регионе. Повысьте уровень KYC, чтобы открыть её.';

  @override
  String get countryChina => 'Китай';

  @override
  String get countryRussia => 'Россия';

  @override
  String get countryTurkey => 'Турция';

  @override
  String get countryUAE => 'ОАЭ';

  @override
  String get countryIraq => 'Ирак';

  @override
  String get countryOman => 'Оман';

  @override
  String get countryGeorgia => 'Грузия';

  @override
  String get travelServiceVisa => 'Виза';

  @override
  String get travelServiceTaxi => 'Такси';

  @override
  String get travelServiceTour => 'Туры';

  @override
  String get travelServiceBoat => 'Лодка и паром';

  @override
  String get travelServiceRestaurant => 'Онлайн-ресторан';

  @override
  String get travelServiceStore => 'Онлайн-магазин';

  @override
  String get travelServiceTranslator => 'Переводчик';

  @override
  String get travelServiceEmergency => 'Помощь туристам';

  @override
  String get travelServiceAliPay => 'AliPay';

  @override
  String get travelServiceMirPay => 'MirPay';

  @override
  String get travelServiceSimTopUp => 'Пополнение SIM';

  @override
  String get travelServiceInsurance => 'Страхование';

  @override
  String get businessServiceP2pEscrow => 'Эскроу-услуги';

  @override
  String get businessServiceGuarantee => 'Гарантия услуг';

  @override
  String get businessServiceBankLoan => 'Банковский кредит';

  @override
  String get businessServiceLicense => 'Лицензия';

  @override
  String get businessServiceStocks => 'Акции и биржа';

  @override
  String get countryIran => 'Иран';

  @override
  String get travelServiceLocal => 'Местные услуги';

  @override
  String get travelServiceCarRental => 'Аренда авто';

  @override
  String get travelServiceFood => 'Заказ еды онлайн';

  @override
  String get travelServiceSupermarket => 'Онлайн-супермаркет';

  @override
  String get travelServiceTrain => 'Поезд';

  @override
  String get businessServiceMoneyTransfer => 'Денежный перевод';

  @override
  String get twoFactorValidationEnterPassword => 'Введите пароль';

  @override
  String get twoFactorValidationEnterOldPasscode =>
      'Введите старый код доступа';

  @override
  String get twoFactorValidationEnterNewPasscode => 'Введите новый код доступа';

  @override
  String get twoFactorValidationEnterConfirmPasscode =>
      'Подтвердите код доступа';

  @override
  String get twoFactorValidationEnterPasscode => 'Введите код доступа';

  @override
  String get twoFactorValidationPasscodesDoNotMatch =>
      'Код доступа и подтверждение не совпадают';

  @override
  String get twoFactorValidationNewPasscodesDoNotMatch =>
      'Новый код и подтверждение не совпадают';

  @override
  String get webViewLinkCannotOpen => 'Эту ссылку нельзя открыть в приложении.';

  @override
  String get networkReconnected => 'Вы снова в сети';

  @override
  String get vpnHintBanner =>
      'Обнаружен VPN — отключите его для более стабильной работы';

  @override
  String get signInWithTelegram => 'Продолжить через Telegram';

  @override
  String get signInTelegramUnavailable =>
      'Вход через Telegram станет доступен, когда он будет включён на сервере.';

  @override
  String get sessionExpiredMessage =>
      'Ваша сессия истекла. Пожалуйста, войдите снова.';

  @override
  String get travelFromPrice => 'От';

  @override
  String get travelSearchAction => 'Поиск';

  @override
  String get travelSearchPlaceholder => 'Поиск…';

  @override
  String get travelMockCurrency => 'томан';

  @override
  String get travelMyRequests => 'Мои заявки';

  @override
  String get travelRequestReference => 'Код отслеживания';

  @override
  String get travelRequestSubmittedAt => 'Дата отправки';

  @override
  String get travelRequestDetails => 'Детали заявки';

  @override
  String get travelRequestUnderReview => 'На рассмотрении';

  @override
  String get travelRequestApproved => 'Одобрено';

  @override
  String get travelRequestRejected => 'Отклонено';

  @override
  String get travelRequestSubmittedTitle => 'Заявка отправлена';

  @override
  String get travelRequestSubmittedDescription =>
      'Ваша заявка записана со статусом «На рассмотрении». Результат будет сообщён в разделе «Мои заявки».';

  @override
  String get travelRequestBackHome => 'Назад к туристическим услугам';

  @override
  String get travelRequestEmptyTitle => 'Заявок пока нет';

  @override
  String get travelRequestEmptyDescription =>
      'Заявки, отправленные через туристические услуги, и их статус появятся здесь.';

  @override
  String get travelFormSubmit => 'Отправить заявку';

  @override
  String get travelFormRequired => 'Обязательное поле';

  @override
  String get travelFormPickHint => 'Выбрать';

  @override
  String get travelExtraUnderReviewNote =>
      'Заявка сохраняется внутри системы; после проверки специалистами её статус обновится в «Моих заявках».';

  @override
  String get travelFieldTime => 'Время';

  @override
  String get travelFieldName => 'ФИО';

  @override
  String get travelFieldPhone => 'Номер телефона';

  @override
  String get travelFieldNote => 'Примечания';

  @override
  String get travelFieldQuantity => 'Количество';

  @override
  String get travelFieldAddress => 'Адрес';

  @override
  String get travelFieldAmount => 'Сумма (томан)';

  @override
  String get travelCatalogNoResults => 'Ничего не найдено по вашему запросу.';

  @override
  String get travelCatalogDetails => 'Детали';

  @override
  String get travelCatalogRating => 'Рейтинг';

  @override
  String get travelCatalogRequest => 'Отправить заявку';

  @override
  String get travelCatalogPerDay => 'день';

  @override
  String get travelCatalogPerPerson => 'за человека';

  @override
  String get travelCatalogPerItem => 'за единицу';

  @override
  String get travelCatalogPerService => 'за услугу';

  @override
  String get travelTrainHero => 'Путешествия на поезде — безопасно и выгодно';

  @override
  String get travelTrainClass => 'Класс поезда';

  @override
  String get travelTrainEconomy => 'Эконом';

  @override
  String get travelTrainCoupe => 'Купе';

  @override
  String get travelTrainVip => 'VIP';

  @override
  String get travelTrainResults => 'Результаты поиска поездов';

  @override
  String get travelTrainResultsGuidance =>
      'Выберите поезд; сравните время отправления, классы и оставшиеся места.';

  @override
  String get travelSortRecommended => 'Рекомендуемые';

  @override
  String get travelSortCheapest => 'Дешевле всех';

  @override
  String get travelSortEarliest => 'Раннее отправление';

  @override
  String get travelSortFastest => 'Быстрее всех';

  @override
  String get travelTrainNumber => 'Номер поезда';

  @override
  String get travelTrainDetails => 'Детали поезда';

  @override
  String get travelTrainContinueToPassengers => 'Перейти к пассажирам';

  @override
  String get travelTrainDetailsGuidance =>
      'Проверьте поезд, классы и правила отмены до добавления пассажиров.';

  @override
  String get travelTrainOperator => 'Перевозчик';

  @override
  String get travelTrainWagon => 'Вагон';

  @override
  String get travelTrainWagonType => 'Плацкарт / купе в зависимости от класса';

  @override
  String get travelTrainSeatsLeft => 'мест осталось';

  @override
  String get travelTrainPolicyNote =>
      'Отмена возможна не позднее чем за 48 часов до отправления со штрафом 10%. Контактный телефон должен быть активен; билет оформляется после подтверждения и оплаты, статус отслеживается в «Моих заявках».';

  @override
  String get travelTrainPassengers => 'Данные пассажиров';

  @override
  String get travelTrainPassengerLabel => 'Пассажир';

  @override
  String get travelTrainConfirmBooking => 'Отправить заявку на билет';

  @override
  String get travelTrainNationalCode => 'Национальный код';

  @override
  String get travelTrainGender => 'Пол';

  @override
  String get travelTrainContactPhone => 'Контактный мобильный';

  @override
  String get travelTrainBookingNote =>
      'Билет оформляется после подтверждения и оплаты; статус отслеживается в «Моих заявках».';

  @override
  String get travelVisaHero => 'Визы в страны назначения — без хлопот';

  @override
  String get travelVisaIntroDescription =>
      'Выберите страну, заполните форму заявки и отправьте документы. Проверку выполняют наши специалисты.';

  @override
  String get travelVisaStepDocuments => 'Отправка документов';

  @override
  String get travelVisaStepReview => 'Проверка специалистом';

  @override
  String get travelVisaStepIssue => 'Выдача визы';

  @override
  String get travelVisaCountries => 'Страны с визовой услугой';

  @override
  String travelVisaProcessingDays(int days) {
    return 'Срок рассмотрения: $days рабочих дней';
  }

  @override
  String get travelVisaFormTitle => 'Форма визовой заявки';

  @override
  String get travelVisaDocuments => 'Необходимые документы';

  @override
  String get travelVisaType => 'Тип визы';

  @override
  String get travelVisaTourist => 'Туристическая';

  @override
  String get travelVisaBusiness => 'Деловая';

  @override
  String get travelVisaEntries => 'Количество въездов';

  @override
  String get travelVisaSingleEntry => 'Однократная';

  @override
  String get travelVisaMultipleEntry => 'Многократная';

  @override
  String get travelVisaApplicants => 'Заявители';

  @override
  String get travelVisaTravelDate => 'Дата поездки';

  @override
  String get travelVisaFullName => 'ФИО (латиницей)';

  @override
  String get travelVisaPassportNumber => 'Номер паспорта';

  @override
  String get travelVisaPassportExpiry => 'Срок действия паспорта';

  @override
  String get travelVisaSubmit => 'Отправить визовую заявку';

  @override
  String get travelReserveDate => 'Дата бронирования';

  @override
  String get travelCarRentalHero => 'Арендуйте авто для поездки онлайн';

  @override
  String get travelCarAgency => 'Компания аренды';

  @override
  String get travelCarSeats => 'Мест';

  @override
  String get travelCarTransmission => 'Коробка передач';

  @override
  String get travelCarAutomatic => 'Автомат';

  @override
  String get travelCarManual => 'Механика';

  @override
  String get travelCarDeposit => 'Возвратный залог';

  @override
  String get travelCarPickupDate => 'Дата получения';

  @override
  String get travelCarReturnDate => 'Дата возврата';

  @override
  String get travelTourHero => 'Готовые туры с понятной программой';

  @override
  String get travelTourDays => 'Длительность тура';

  @override
  String get travelTourStars => 'Класс отеля';

  @override
  String get travelTourCapacity => 'Оставшиеся места';

  @override
  String get travelTourDepartureDate => 'Дата отправления';

  @override
  String get travelBoatHero => 'Морские и прогулочные маршруты';

  @override
  String get travelBoatDuration => 'Время в пути';

  @override
  String get travelBoatCapacity => 'Вместимость';

  @override
  String get travelBoatClass => 'Класс парома';

  @override
  String get travelRestaurantHero => 'Забронируйте столик до прибытия';

  @override
  String get travelRestaurantCuisine => 'Кухня';

  @override
  String get travelRestaurantHours => 'Часы работы';

  @override
  String get travelRestaurantCapacity => 'Вместимость';

  @override
  String get travelRestaurantGuests => 'Гости';

  @override
  String get travelFoodHero => 'Быстрая доставка к месту проживания';

  @override
  String get travelFoodPreparation => 'Время приготовления';

  @override
  String get travelSupermarketHero => 'Необходимое для поездки — к вашей двери';

  @override
  String get travelSupermarketUnit => 'Единица';

  @override
  String get travelStoreHero =>
      'Магазин в поездке — доставка в пункт назначения';

  @override
  String get travelStoreBrand => 'Бренд';

  @override
  String get travelStoreWarranty => 'Гарантия';

  @override
  String get travelLocalHero => 'Местные услуги в пункте назначения';

  @override
  String get travelLocalDuration => 'Длительность услуги';

  @override
  String get travelLocalLanguages => 'Языки';

  @override
  String get travelInsuranceHero => 'Застрахуйте свою поездку';

  @override
  String get travelInsuranceCoverage => 'Лимит покрытия';

  @override
  String get travelInsuranceDuration => 'Срок действия';

  @override
  String get travelTranslatorHero => 'Переводчик в пункте назначения';

  @override
  String get travelTranslatorLanguages => 'Языки';

  @override
  String get travelTranslatorExperience => 'Опыт';

  @override
  String get travelEmergencyHero => 'Экстренная поддержка путешественников';

  @override
  String get travelEmergencyContactsTitle => 'Экстренные номера';

  @override
  String get travelEmergencyRequest => 'Запросить помощь';

  @override
  String get travelEmergencySubject => 'Тема';

  @override
  String get travelTaxiHero => 'Трансфер и поездки по городу';

  @override
  String get travelTaxiCarClass => 'Класс автомобиля';

  @override
  String get travelSimTopUpHero => 'Пополнение SIM в стране назначения';

  @override
  String get travelSimOperator => 'Оператор';

  @override
  String get travelSimNumber => 'Мобильный номер';

  @override
  String get travelSimAmount => 'Сумма пополнения';

  @override
  String get travelPayDescription =>
      'Чтобы использовать этот способ оплаты, привяжите счёт и отправьте заявку на пополнение. Статус отслеживается в «Моих заявках».';

  @override
  String get travelPayLinkAccount => 'Привязать счёт и пополнить';

  @override
  String get travelPayTopUp => 'Пополнение кошелька';

  @override
  String get travelPayAccountId => 'ID счёта';

  @override
  String get travelAliPayDescription => 'Международные платежи через AliPay';

  @override
  String get travelMirPayDescription => 'Платежи в России через MirPay';

  @override
  String get travelContactPhone => 'Контактный мобильный';

  @override
  String get travelVisaCountry => 'Страна';

  @override
  String get travelQuickCipTitle => 'Аэропортовый зал CIP и VIP';
}
