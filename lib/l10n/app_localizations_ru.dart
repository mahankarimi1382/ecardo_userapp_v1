// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get comment_common_maintenance => '==== Техническое обслуживание ====';

  @override
  String get maintenanceTitle => 'На техническом обслуживании';

  @override
  String get maintenanceSubtitle =>
      'Мы проводим плановое техническое обслуживание для улучшения вашего опыта.';

  @override
  String get comment_common_alert_bottom_sheet =>
      '==== Нижний лист оповещения ====';

  @override
  String get alertBottonSheetConfirmButton => 'Подтвердить';

  @override
  String get alertBottonSheetCancelButton => 'Отмена';

  @override
  String get comment_all_controller_load_Error =>
      '==== Ошибка загрузки всех контроллеров ====';

  @override
  String get allControllerLoadError => 'Что-то пошло не так!';

  @override
  String get comment_common_exit_application => '==== Выход из приложения ====';

  @override
  String get exitApplicationTitle => 'Выход из приложения';

  @override
  String get exitApplicationMessage =>
      'Вы уверены, что хотите выйти из приложения?';

  @override
  String get comment_common_dropdown => '==== Общий выпадающий список ====';

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
  String get commonDropdownOther => 'Другой';

  @override
  String get comment_welcome => '==== Экран приветствия ====';

  @override
  String get welcomeTitle => 'Добро пожаловать в Qunzo';

  @override
  String get welcomeDescription =>
      'Qunzo дает вам управление несколькими кошельками, мгновенные обмены и безопасные транзакции.';

  @override
  String get welcomeSignIn => 'Войти';

  @override
  String get welcomeCreateAccount => 'Создать аккаунт';

  @override
  String get comment_sign_in => '==== Экран входа ====';

  @override
  String get signInWelcomeBack => 'С возвращением!';

  @override
  String get signInSubtitle =>
      'Присоединяйтесь и возьмите контроль над своими финансами сегодня';

  @override
  String get signInEmail => 'Электронная почта';

  @override
  String get signInPassword => 'Пароль';

  @override
  String get signInForgotPassword => 'Забыли пароль';

  @override
  String get signInButton => 'Войти';

  @override
  String get signInNotRegistered => 'Еще не зарегистрированы? ';

  @override
  String get signInCreateAccount => 'Создать аккаунт';

  @override
  String get signInBiometricErrorFirstTime =>
      'Первый вход с помощью электронной почты и пароля';

  @override
  String get signInBiometricErrorNotEnabled => 'Биометрия не включена';

  @override
  String get signInRegistrationDisabled => 'Регистрация отключена';

  @override
  String get signInValidationEmailRequired =>
      'Поле электронной почты обязательно';

  @override
  String get signInValidationPasswordRequired => 'Поле пароля обязательно';

  @override
  String get comment_two_factor_auth =>
      '==== Экран двухфакторной аутентификации ====';

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
  String get comment_forgot_password => '==== Экран восстановления пароля ====';

  @override
  String get forgotPasswordTitle => 'Сбросить пароль';

  @override
  String get forgotPasswordSubtitle =>
      'Не волнуйтесь! Введите вашу электронную почту для сброса пароля.';

  @override
  String get forgotPasswordEmail => 'Электронная почта';

  @override
  String get forgotPasswordButton => 'Забыли пароль';

  @override
  String get forgotPasswordBackTo => 'Вернуться к? ';

  @override
  String get forgotPasswordSignIn => 'Войти';

  @override
  String get forgotPasswordEmailRequired =>
      'Поле электронной почты обязательно';

  @override
  String get comment_forgot_password_pin_verification =>
      '==== Экран проверки PIN для восстановления пароля ====';

  @override
  String get forgotPasswordPinVerifyTitle => 'Подтвердить email';

  @override
  String get forgotPasswordPinOtpSent => 'OTP отправлен на ';

  @override
  String get forgotPasswordPinEnterOtp => 'Введите OTP';

  @override
  String get forgotPasswordPinOtpCountdown => 'OTP через';

  @override
  String get forgotPasswordPinVerifyButton => 'Подтвердить OTP';

  @override
  String get forgotPasswordPinDidNotReceive => 'Не получили код? ';

  @override
  String get forgotPasswordPinResend => 'Отправить повторно';

  @override
  String get forgotPasswordPinOtpRequired => 'Поле OTP обязательно';

  @override
  String get comment_reset_password => '==== Экран сброса пароля ====';

  @override
  String get resetPasswordTitle => 'Сброс пароля';

  @override
  String get resetPasswordSubtitle => 'Введите новый пароль и подтвердите его.';

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
  String get resetPasswordValidationRequired => 'Пароль обязателен';

  @override
  String get resetPasswordValidationMinLength =>
      'Пароль должен содержать не менее 8 символов';

  @override
  String get resetPasswordValidationConfirmRequired =>
      'Пожалуйста, подтвердите пароль';

  @override
  String get resetPasswordValidationMismatch => 'Пароли не совпадают';

  @override
  String get comment_auth_id_verification => '==== Экран верификации ID ====';

  @override
  String get authIdVerificationInvalidFieldType => 'Неверный тип поля';

  @override
  String get authIdVerificationUnknownFieldType => 'Неизвестный тип поля: ';

  @override
  String get comment_camera_type_section => '==== Раздел типа камеры ====';

  @override
  String get cameraTypeBack => 'Назад';

  @override
  String get cameraTypeNotAvailable => 'Н/Д';

  @override
  String get cameraTypeButton => 'Камера';

  @override
  String get cameraTypeSkip => 'Пропустить';

  @override
  String get comment_file_type_section => '==== Раздел типа файла ====';

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
      '==== Раздел фронтальной камеры ====';

  @override
  String get frontCameraTypeBack => 'Назад';

  @override
  String get frontCameraTypeNotAvailable => 'Н/Д';

  @override
  String get frontCameraTypeButton => 'Фронтальная камера';

  @override
  String get frontCameraTypeSkip => 'Пропустить';

  @override
  String get comment_kyc_submission_section => '==== Раздел отправки KYC ====';

  @override
  String get kycSubmissionIdVerification => 'Верификация ID';

  @override
  String get kycSubmissionSubmit => 'Отправить';

  @override
  String get kycSubmissionNext => 'Далее';

  @override
  String get kycSubmissionReUpload => 'Перезагрузить';

  @override
  String get kycSubmissionRetake => 'Переснять';

  @override
  String get comment_email_screen => '==== Экран электронной почты ====';

  @override
  String get emailScreenCreateAccount => 'Создайте свой аккаунт';

  @override
  String get emailScreenSubtitle =>
      'Присоединяйтесь и возьмите контроль над своими финансами сегодня';

  @override
  String get emailScreenEmail => 'Электронная почта';

  @override
  String get emailScreenContinue => 'Продолжить';

  @override
  String get emailScreenAlreadyHaveAccount => 'Уже есть аккаунт? ';

  @override
  String get emailScreenSignIn => 'Войти';

  @override
  String get emailScreenEmailRequired => 'Пожалуйста, введите email';

  @override
  String get comment_personal_info_screen =>
      '==== Экран личной информации ====';

  @override
  String get personalInfoTitle => 'Ваша информация';

  @override
  String get personalInfoSubtitle =>
      'Введите ваши юридические данные для продолжения.';

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
  String get personalInfoValidationFirstNameRequired => 'Имя обязательно';

  @override
  String get personalInfoValidationLastNameRequired => 'Фамилия обязательна';

  @override
  String get personalInfoValidationUserNameRequired =>
      'Имя пользователя обязательно';

  @override
  String get personalInfoValidationCountryRequired => 'Страна обязательна';

  @override
  String get personalInfoValidationPhoneRequired => 'Номер телефона обязателен';

  @override
  String get personalInfoValidationReferralCodeRequired =>
      'Реферальный код обязателен';

  @override
  String get personalInfoValidationGenderRequired => 'Пол обязателен';

  @override
  String get comment_setup_password_screen =>
      '==== Экран установки пароля ====';

  @override
  String get setupPasswordTitle => 'Установка пароля';

  @override
  String get setupPasswordSubtitle =>
      'Создайте надежный пароль и подтвердите его';

  @override
  String get setupPasswordPassword => 'Пароль';

  @override
  String get setupPasswordConfirmPassword => 'Подтвердите пароль';

  @override
  String get setupPasswordAgreeTerms => 'Я согласен с ';

  @override
  String get setupPasswordTermsConditions => 'Условиями использования';

  @override
  String get setupPasswordButton => 'Установить пароль';

  @override
  String get setupPasswordValidationRequired => 'Пароль обязателен';

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
  String get comment_sign_up_status_screen =>
      '==== Экран статуса регистрации ====';

  @override
  String get signUpStatusTitle => 'Ваш текущий статус';

  @override
  String get signUpStatusSubtitle =>
      'Быстрый 4-шаговый процесс для защиты вашего аккаунта Qunzo';

  @override
  String get signUpStatusStep => 'Шаг';

  @override
  String get signUpStatusEmailVerification => 'Подтверждение email';

  @override
  String get signUpStatusSetupPassword => 'Установка пароля';

  @override
  String get signUpStatusPersonalInfo => 'Личная информация';

  @override
  String get signUpStatusVerification => 'Верификация';

  @override
  String get signUpStatusInReview => 'На проверке';

  @override
  String get signUpStatusRejected => 'Отклонено';

  @override
  String get signUpStatusNoReason => 'Причина не указана';

  @override
  String get signUpStatusNextStep => 'Следующий шаг';

  @override
  String get signUpStatusSubmitAgain => 'Отправить заново';

  @override
  String get signUpStatusDashboard => 'Панель управления';

  @override
  String get signUpStatusBack => 'Назад';

  @override
  String get signUpStatusErrorProcessing =>
      'Ошибка обработки следующего шага. Попробуйте еще раз.';

  @override
  String get signUpStatusVerificationTypeEmpty => 'Тип верификации пуст!';

  @override
  String get signUpStatusErrorLoadingTypes =>
      'Ошибка загрузки типов верификации. Попробуйте еще раз.';

  @override
  String get signUpStatusDropdownTwoVerificationNotFound =>
      'Тип верификации не найден';

  @override
  String get comment_verify_email_screen =>
      '==== Экран подтверждения email ====';

  @override
  String get verifyEmailTitle => 'Подтвердить email';

  @override
  String get verifyEmailOtpSent => 'OTP отправлен на ';

  @override
  String get verifyEmailEnterOtp => 'Введите OTP';

  @override
  String get verifyEmailResendAvailable => 'Повторная отправка доступна через';

  @override
  String get verifyEmailRequestNewOtp => 'Вы можете запросить новый OTP сейчас';

  @override
  String get verifyEmailButton => 'Подтвердить email';

  @override
  String get verifyEmailDidNotReceive => 'Не получили код? ';

  @override
  String get verifyEmailResend => 'Отправить повторно';

  @override
  String get verifyEmailOtpRequired => 'Поле OTP обязательно';

  @override
  String get comment_add_money_screen => '==== Экран пополнения ====';

  @override
  String get addMoneyTitle => 'Пополнить счет';

  @override
  String get addMoneyBalance => 'Баланс';

  @override
  String get addMoneyHistory => 'История пополнений';

  @override
  String get addMoneyWalletsNotFound => 'Кошельки не найдены';

  @override
  String get comment_add_money_amount_step => '==== Шаг суммы пополнения ====';

  @override
  String get addMoneyGateway => 'Шлюз';

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
  String get addMoneyMax => 'и Максимум';

  @override
  String get addMoneyWriteHere => 'Введите здесь...';

  @override
  String get addMoneyAddMoneyButton => 'Пополнить';

  @override
  String get comment_add_money_pending_step =>
      '==== Шаг ожидания пополнения ====';

  @override
  String get addMoneyPendingTitle => 'Ваш процесс пополнения\nв ожидании';

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
  String get comment_add_money_review_step =>
      '==== Шаг проверки пополнения ====';

  @override
  String get addMoneyReviewTitle => 'Проверка деталей';

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
      '==== Шаг успешного пополнения ====';

  @override
  String get addMoneySuccessTitle => 'Пополнение успешно!';

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
  String get comment_add_money_history => '==== История пополнений ====';

  @override
  String get addMoneyHistoryTitle => 'История пополнений';

  @override
  String get comment_add_money_filter_bottom_sheet =>
      '==== Нижний лист фильтра пополнений ====';

  @override
  String get addMoneyFilterTransactionId => 'ID транзакций';

  @override
  String get addMoneyFilterStatus => 'Статус';

  @override
  String get addMoneyFilterSuccess => 'Успешно';

  @override
  String get addMoneyFilterPending => 'В ожидании';

  @override
  String get addMoneyFilterFailed => 'Не удалось';

  @override
  String get addMoneyFilterButton => 'Фильтровать';

  @override
  String get addMoneyFilterReset => 'Сбросить';

  @override
  String get comment_create_beneficiary_screen =>
      '==== Экран создания бенефициара ====';

  @override
  String get createBeneficiaryTitle => 'Создать новый';

  @override
  String get createBeneficiaryAccountNumber => 'Номер счета';

  @override
  String get createBeneficiaryNickName => 'Никнейм';

  @override
  String get createBeneficiaryCreateButton => 'Создать';

  @override
  String get createBeneficiaryValidationAccountNumber =>
      'Заполните номер счета';

  @override
  String get createBeneficiaryValidationNickName => 'Заполните никнейм';

  @override
  String get comment_update_beneficiary_screen =>
      '==== Экран обновления бенефициара ====';

  @override
  String get updateBeneficiaryTitle => 'Обновить';

  @override
  String get updateBeneficiaryNickName => 'Никнейм';

  @override
  String get updateBeneficiaryUpdateButton => 'Обновить';

  @override
  String get updateBeneficiaryValidationNickName => 'Заполните никнейм';

  @override
  String get comment_account_user_types =>
      '==== Типы пользователей аккаунта ====';

  @override
  String get accountUserMerchant => 'Мерчант';

  @override
  String get accountUserBeneficiary => 'Бенефициар';

  @override
  String get accountUserAgent => 'Агент';

  @override
  String get comment_cash_out_screen => '==== Экран вывода ====';

  @override
  String get cashOutTitle => 'Вывод через агента';

  @override
  String get cashOutHistory => 'История выводов';

  @override
  String get comment_cash_out_amount_step => '==== Шаг суммы вывода ====';

  @override
  String get cashOutAgentId => 'ID агента';

  @override
  String get cashOutAmount => 'Сумма';

  @override
  String get cashOutMin => 'Минимум';

  @override
  String get cashOutMax => 'и Максимум';

  @override
  String get cashOutButton => 'Вывести';

  @override
  String get cashOutSavedAgents => 'Сохраненные агенты';

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
  String get comment_cash_out_review_step => '==== Шаг проверки вывода ====';

  @override
  String get cashOutReviewTitle => 'Проверка деталей';

  @override
  String get cashOutReviewAmount => 'Сумма';

  @override
  String get cashOutReviewWallet => 'Кошелек';

  @override
  String get cashOutReviewAgentAccount => 'Аккаунт агента';

  @override
  String get cashOutReviewCharge => 'Комиссия';

  @override
  String get cashOutReviewTotalAmount => 'Итоговая сумма';

  @override
  String get cashOutReviewBack => 'Назад';

  @override
  String get cashOutReviewConfirm => 'Подтвердить';

  @override
  String get comment_cash_out_success_step => '==== Шаг успешного вывода ====';

  @override
  String get cashOutSuccessTitle => 'Вывод успешен!';

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
      '==== Раздел кошельков для вывода ====';

  @override
  String get cashOutWalletsBalance => 'Баланс';

  @override
  String get cashOutWalletsNotFound => 'Кошельки не найдены';

  @override
  String get comment_cash_out_history => '==== История выводов ====';

  @override
  String get cashOutHistoryTitle => 'История выводов';

  @override
  String get comment_cash_out_filter_bottom_sheet =>
      '==== Нижний лист фильтра выводов ====';

  @override
  String get cashOutFilterTransactionId => 'ID транзакций';

  @override
  String get cashOutFilterStatus => 'Статус';

  @override
  String get cashOutFilterButton => 'Фильтровать';

  @override
  String get cashOutFilterReset => 'Сбросить';

  @override
  String get comment_exchange_screen => '==== Экран обмена ====';

  @override
  String get exchangeTitle => 'Обмен кошелька';

  @override
  String get exchangeHistory => 'История обменов';

  @override
  String get comment_exchange_amount_step => '==== Шаг суммы обмена ====';

  @override
  String get exchangeAmount => 'Сумма';

  @override
  String get exchangeMin => 'Минимум';

  @override
  String get exchangeMax => 'и Максимум';

  @override
  String get exchangeButton => 'Обменять';

  @override
  String get comment_exchange_review_step => '==== Шаг проверки обмена ====';

  @override
  String get exchangeReviewTitle => 'Проверка деталей';

  @override
  String get exchangeReviewAmount => 'Сумма';

  @override
  String get exchangeReviewFromWallet => 'Из кошелька';

  @override
  String get exchangeReviewCharge => 'Комиссия';

  @override
  String get exchangeReviewTotalAmount => 'Итоговая сумма';

  @override
  String get exchangeReviewToWallet => 'В кошелек';

  @override
  String get exchangeReviewExchangeRate => 'Курс обмена';

  @override
  String get exchangeReviewExchangeAmount => 'Сумма обмена';

  @override
  String get exchangeReviewBack => 'Назад';

  @override
  String get exchangeReviewConfirm => 'Подтвердить';

  @override
  String get comment_exchange_success_step => '==== Шаг успешного обмена ====';

  @override
  String get exchangeSuccessTitle => 'Обмен успешен!';

  @override
  String get exchangeSuccessAmount => 'Сумма';

  @override
  String get exchangeSuccessTransactionId => 'ID транзакции';

  @override
  String get exchangeSuccessPayAmount => 'Сумма оплаты';

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
      '==== Раздел кошелька обмена ====';

  @override
  String get exchangeWalletBalance => 'Баланс';

  @override
  String get exchangeWalletsNotFound => 'Кошельки не найдены';

  @override
  String get comment_exchange_wallet_to_wallet =>
      '==== Обмен кошелька на кошелек ====';

  @override
  String get exchangeWalletToWallet => 'Кошелек на кошелек';

  @override
  String get exchangeFromWallet => 'Из кошелька';

  @override
  String get exchangeToWallet => 'В кошелек';

  @override
  String get exchangeRate => 'Курс обмена: ';

  @override
  String get exchangeWalletToWalletWalletsNotFound => 'Кошельки не найдены';

  @override
  String get comment_exchange_history => '==== История обменов ====';

  @override
  String get exchangeHistoryTitle => 'История обменов';

  @override
  String get comment_exchange_filter_bottom_sheet =>
      '==== Нижний лист фильтра обменов ====';

  @override
  String get exchangeFilterTransactionId => 'ID транзакций';

  @override
  String get exchangeFilterStatus => 'Статус';

  @override
  String get exchangeFilterButton => 'Фильтровать';

  @override
  String get exchangeFilterReset => 'Сбросить';

  @override
  String get comment_gift_code_screen => '==== Экран подарочного кода ====';

  @override
  String get giftCodeTitle => 'Подарочный код';

  @override
  String get giftCodeCreateGift => 'Создать подарок';

  @override
  String get comment_create_gift_amount_step =>
      '==== Шаг суммы создания подарка ====';

  @override
  String get createGiftAmount => 'Сумма';

  @override
  String get createGiftMin => 'Минимум';

  @override
  String get createGiftMax => 'и Максимум';

  @override
  String get createGiftButton => 'Создать подарок';

  @override
  String get comment_create_gift_review_section =>
      '==== Раздел проверки создания подарка ====';

  @override
  String get createGiftReviewTitle => 'Проверка деталей';

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
      '==== Шаг успеха создания подарка ====';

  @override
  String get createGiftSuccessTitle => 'Подарок успешно создан!';

  @override
  String get createGiftSuccessAmount => 'Сумма';

  @override
  String get createGiftSuccessCharge => 'Комиссия';

  @override
  String get createGiftSuccessFinalAmount => 'Итоговая сумма';

  @override
  String get createGiftSuccessCreatedAt => 'Создано';

  @override
  String get createGiftSuccessCreateAgain => 'Создать подарочный код снова';

  @override
  String get createGiftSuccessBackHome => 'На главную';

  @override
  String get comment_create_gift_wallet_section =>
      '==== Раздел кошелька создания подарка ====';

  @override
  String get createGiftWalletBalance => 'Баланс';

  @override
  String get createGiftWalletWalletsNotFound => 'Кошельки не найдены';

  @override
  String get comment_gift_code_header_section =>
      '==== Раздел заголовка подарочного кода ====';

  @override
  String get giftCodeHeaderTitle => 'Подарочный код';

  @override
  String get giftCodeHeaderGiftRedeem => 'Погашение подарка';

  @override
  String get giftCodeHeaderMyGift => 'Мой подарок';

  @override
  String get giftCodeHeaderGiftRedeemHistory => 'История погашения подарков';

  @override
  String get comment_gift_history => '==== История подарков ====';

  @override
  String get giftHistoryCreatedAt => 'Создано:';

  @override
  String get giftHistoryStatus => 'Статус: ';

  @override
  String get giftHistoryClaimed => 'Получено';

  @override
  String get giftHistoryClaimable => 'Доступно к получению';

  @override
  String get giftHistoryCodeCopied => 'Подарочный код скопирован';

  @override
  String get comment_gift_history_filter_bottom_sheet =>
      '==== Нижний лист фильтра истории подарков ====';

  @override
  String get giftHistoryFilterGiftCode => 'Подарочный код';

  @override
  String get giftHistoryFilterButton => 'Фильтровать';

  @override
  String get comment_gift_redeem_section =>
      '==== Раздел погашения подарка ====';

  @override
  String get giftRedeemGiftCode => 'Подарочный код';

  @override
  String get giftRedeemButton => 'Погасить';

  @override
  String get giftRedeemValidation => 'Пожалуйста, введите подарочный код';

  @override
  String get comment_gift_redeem_history =>
      '==== История погашения подарков ====';

  @override
  String get giftRedeemHistoryTitle => 'Моя история погашений';

  @override
  String get giftRedeemHistoryCreatedAt => 'Создано:';

  @override
  String get giftRedeemHistoryStatus => 'Статус: ';

  @override
  String get giftRedeemHistoryClaimed => 'Получено';

  @override
  String get giftRedeemHistoryClaimable => 'Доступно к получению';

  @override
  String get giftRedeemHistoryCodeCopied => 'Подарочный код скопирован';

  @override
  String get comment_gift_redeem_filter_bottom_sheet =>
      '==== Нижний лист фильтра погашения подарков ====';

  @override
  String get giftRedeemFilterCode => 'Код';

  @override
  String get giftRedeemFilterButton => 'Фильтровать';

  @override
  String get giftRedeemFilterReset => 'Сбросить';

  @override
  String get comment_drawer_section => '==== Раздел бокового меню ====';

  @override
  String get drawerDashboard => 'Панель управления';

  @override
  String get drawerMyWallets => 'Мои кошельки';

  @override
  String get drawerAddMoney => 'Пополнить';

  @override
  String get drawerCashOut => 'Вывод';

  @override
  String get drawerBillPayments => 'Оплата счетов';

  @override
  String get drawerVirtualCards => 'Виртуальные карты';

  @override
  String get drawerPaymentLinks => 'Платежные ссылки';

  @override
  String get drawerMakePayment => 'Сделать платеж';

  @override
  String get drawerTransfer => 'Перевод';

  @override
  String get drawerWithdraw => 'Вывод';

  @override
  String get drawerExchange => 'Обмен';

  @override
  String get drawerInviting => 'Приглашения';

  @override
  String get drawerGiftCard => 'Подарочная карта';

  @override
  String get drawerP2pTrading => 'P2P-торговля';

  @override
  String get drawerKycVerification => 'Пожалуйста, пройдите KYC!';

  @override
  String get comment_end_drawer_section => '==== Раздел конечного меню ====';

  @override
  String get endDrawerProfileSettings => 'Настройки профиля';

  @override
  String get endDrawerChangePassword => 'Сменить пароль';

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
  String get endDrawerChooseLanguage => 'Выбрать язык';

  @override
  String get comment_recent_transaction_details =>
      '==== Детали недавних транзакций ====';

  @override
  String get transactionDetailsTitle => 'Детали транзакции';

  @override
  String get transactionDetailsWallet => 'Кошелек';

  @override
  String get transactionDetailsCharge => 'Комиссия';

  @override
  String get transactionDetailsTransactionId => 'ID транзакции';

  @override
  String get transactionDetailsMethod => 'Метод';

  @override
  String get transactionDetailsTotalAmount => 'Итоговая сумма';

  @override
  String get transactionDetailsStatus => 'Статус';

  @override
  String get transactionDetailsDescription => 'Описание';

  @override
  String get transactionStatusSuccess => 'Успешно';

  @override
  String get transactionStatusPending => 'В ожидании';

  @override
  String get transactionStatusFailed => 'Не удалось';

  @override
  String get comment_wallet_details => '==== Детали кошелька ====';

  @override
  String get walletDetailsHistory => 'История';

  @override
  String get walletDetailsAvailableBalance => 'ДОСТУПНЫЙ БАЛАНС';

  @override
  String get walletDetailsTopUp => 'Пополнить';

  @override
  String get walletDetailsWithdraw => 'Вывести';

  @override
  String get walletDetailsUserDepositNotEnabled =>
      'Пополнение для пользователя отключено';

  @override
  String get walletDetailsUserWithdrawNotEnabled =>
      'Вывод для пользователя отключен';

  @override
  String get walletDetailsWalletsNotFound => 'Кошельки не найдены';

  @override
  String get comment_action_button_section =>
      '==== Раздел кнопок действий ====';

  @override
  String get actionButtonTransfer => 'Перевод';

  @override
  String get actionButtonWithdraw => 'Вывод';

  @override
  String get actionButtonPayment => 'Платеж';

  @override
  String get actionButtonExchange => 'Обмен';

  @override
  String get actionButtonUserTransferNotEnabled =>
      'Перевод для пользователя отключен';

  @override
  String get actionButtonUserWithdrawNotEnabled =>
      'Вывод для пользователя отключен';

  @override
  String get actionButtonUserPaymentNotEnabled =>
      'Платеж для пользователя отключен';

  @override
  String get actionButtonUserExchangeNotEnabled =>
      'Обмен для пользователя отключен';

  @override
  String get comment_my_wallet_section => '==== Раздел моих кошельков ====';

  @override
  String get myWalletSectionTitle => 'Мои кошельки';

  @override
  String get myWalletTopUp => 'Пополнить';

  @override
  String get myWalletWithdraw => 'Вывести';

  @override
  String get myWalletUserDepositNotEnabled => 'Пополнение отключено';

  @override
  String get myWalletUserWithdrawNotEnabled => 'Вывод отключен';

  @override
  String get comment_other_services_section => '==== Раздел других услуг ====';

  @override
  String get otherServicesTitle => 'Другие услуги';

  @override
  String get otherServicesQrCode => 'QR-код';

  @override
  String get otherServicesAddMoney => 'Пополнить';

  @override
  String get otherServicesCashOut => 'Вывод';

  @override
  String get otherServicesMakePayment => 'Сделать платеж';

  @override
  String get otherServicesTransactions => 'Транзакции';

  @override
  String get otherServicesInvoice => 'Счет';

  @override
  String get otherServicesRequestMoney => 'Запросить деньги';

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
  String get otherServicesPaymentLinks => 'Платежные ссылки';

  @override
  String get otherServicesKycVerification => 'Пожалуйста, пройдите KYC!';

  @override
  String get otherServicesUserGiftNotEnabled => 'Подарки отключены';

  @override
  String get otherServicesUserDepositNotEnabled => 'Пополнение отключено';

  @override
  String get otherServicesUserCashOutNotEnabled => 'Вывод отключен';

  @override
  String get otherServicesUserPaymentNotEnabled => 'Платежи отключены';

  @override
  String get otherServicesUserRequestMoneyNotEnabled => 'Запрос денег отключен';

  @override
  String get otherServicesUserInvoiceNotEnabled => 'Счета отключены';

  @override
  String get comment_recent_transactions_section =>
      '==== Раздел недавних транзакций ====';

  @override
  String get recentTransactionsTitle => 'Недавние';

  @override
  String get comment_section_header => '==== Заголовок раздела ====';

  @override
  String get sectionHeaderSeeAll => 'Посмотреть все';

  @override
  String get comment_sign_up_bonus_popup =>
      '==== Попап бонуса за регистрацию ====';

  @override
  String get signUpBonusCongratulations => 'Поздравляем!';

  @override
  String get signUpBonusReceived => 'Вы получили бонус';

  @override
  String get comment_user_profile_section =>
      '==== Раздел профиля пользователя ====';

  @override
  String get userProfileHello => 'Привет, 👋';

  @override
  String get userProfileUid => 'UID:';

  @override
  String get userProfileCopied => 'Скопировано';

  @override
  String get comment_invoice_screen => '==== Экран счета ====';

  @override
  String get invoiceTitle => 'Счет';

  @override
  String get invoiceCreateInvoice => 'Создать счет';

  @override
  String get invoiceAmount => 'Сумма:';

  @override
  String get invoiceCharge => 'Комиссия:';

  @override
  String get invoiceStatus => 'Статус: ';

  @override
  String get invoicePublished => 'Опубликовано';

  @override
  String get invoiceDraft => 'Черновик';

  @override
  String get invoiceView => 'Просмотр';

  @override
  String get invoicePaid => 'Оплачено';

  @override
  String get invoiceUnpaid => 'Не оплачено';

  @override
  String get comment_update_invoice => '==== Обновление счета ====';

  @override
  String get updateInvoiceTitle => 'Обновить счет';

  @override
  String get updateInvoiceItems => 'Позиции счета';

  @override
  String get updateInvoiceAddItem => 'Добавить позицию';

  @override
  String get updateInvoiceButton => 'Обновить счет';

  @override
  String get comment_update_invoice_add_item =>
      '==== Добавление позиции в обновление счета ====';

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
      '==== Информация об обновлении счета ====';

  @override
  String get updateInvoiceInformationTitle => 'Информация о счете';

  @override
  String get updateInvoiceTo => 'Счет на';

  @override
  String get updateInvoiceEmailAddress => 'Адрес электронной почты';

  @override
  String get updateInvoiceAddress => 'Адрес';

  @override
  String get updateInvoiceWallet => 'Кошелек';

  @override
  String get updateInvoiceStatus => 'Статус';

  @override
  String get updateInvoiceIssueDate => 'Дата выставления';

  @override
  String get updateInvoicePaymentStatus => 'Статус оплаты';

  @override
  String get updateInvoiceSelectWallet => 'Выберите кошелек';

  @override
  String get updateInvoiceSelectStatus => 'Выберите статус';

  @override
  String get updateInvoiceSelectPaymentStatus => 'Выберите статус оплаты';

  @override
  String get updateInvoiceWalletNotFound => 'Кошелек не найден';

  @override
  String get updateInvoiceStatusNotFound => 'Статус не найден';

  @override
  String get updateInvoicePaymentStatusNotFound => 'Статус оплаты не найден';

  @override
  String get comment_invoice_status_options =>
      '==== Варианты статуса счета ====';

  @override
  String get invoiceStatusDraft => 'Черновик';

  @override
  String get invoiceStatusPublished => 'Опубликовано';

  @override
  String get invoiceStatusPaid => 'Оплачено';

  @override
  String get invoiceStatusUnpaid => 'Не оплачено';

  @override
  String get comment_invoice_details => '==== Детали счета ====';

  @override
  String get invoiceDetailsTitle => 'Счет';

  @override
  String get invoiceDetailsReference => '№:';

  @override
  String get invoiceDetailsIssued => 'Выставлен:';

  @override
  String get invoiceDetailsName => 'Имя';

  @override
  String get invoiceDetailsEmail => 'Email';

  @override
  String get invoiceDetailsCharge => 'Комиссия';

  @override
  String get invoiceDetailsAddress => 'Адрес';

  @override
  String get invoiceDetailsTotalAmount => 'Итоговая сумма';

  @override
  String get invoiceDetailsStatus => 'Статус';

  @override
  String get invoiceDetailsItemName => 'Название позиции';

  @override
  String get invoiceDetailsQuantity => 'Количество';

  @override
  String get invoiceDetailsUnitPrice => 'Цена за единицу';

  @override
  String get invoiceDetailsSubTotal => 'Промежуточный итог';

  @override
  String get invoiceDetailsPayNow => 'Оплатить сейчас';

  @override
  String get invoiceDetailsPrintInvoice => 'Распечатать счет';

  @override
  String get invoiceDetailsPaid => 'Оплачено';

  @override
  String get invoiceDetailsUnpaid => 'Не оплачено';

  @override
  String get comment_invoice_pdf => '==== PDF счета ====';

  @override
  String get invoicePdfReference => '№:';

  @override
  String get invoicePdfIssued => 'Выставлен:';

  @override
  String get invoicePdfPaid => 'Оплачено';

  @override
  String get invoicePdfUnpaid => 'Не оплачено';

  @override
  String get invoicePdfTotalAmount => 'Итоговая сумма:';

  @override
  String get invoicePdfAmount => 'Сумма:';

  @override
  String get invoicePdfCharge => 'Комиссия:';

  @override
  String get invoicePdfItemName => 'Название позиции';

  @override
  String get invoicePdfQuantity => 'Количество';

  @override
  String get invoicePdfUnitPrice => 'Цена за единицу';

  @override
  String get invoicePdfSubtotal => 'Промежуточный итог';

  @override
  String get invoicePdfSubtotalLabel => 'Промежуточный итог: ';

  @override
  String get invoicePdfChargeLabel => 'Комиссия: ';

  @override
  String get invoicePdfTotalAmountLabel => 'Итоговая сумма: ';

  @override
  String get invoicePdfThanks => 'Спасибо за покупку.';

  @override
  String get comment_create_invoice => '==== Создание счета ====';

  @override
  String get createInvoiceTitle => 'Создать счет';

  @override
  String get createInvoiceItems => 'Позиции счета';

  @override
  String get createInvoiceAddItem => 'Добавить позицию';

  @override
  String get createInvoiceButton => 'Создать счет';

  @override
  String get createInvoiceStatusDraft => 'Черновик';

  @override
  String get comment_create_invoice_add_item_section =>
      '==== Раздел добавления позиции в создание счета ====';

  @override
  String get createInvoiceAddItemSectionItemName => 'Название позиции';

  @override
  String get createInvoiceAddItemSectionQuantity => 'Количество';

  @override
  String get createInvoiceAddItemSectionUnitPrice => 'Цена за единицу';

  @override
  String get createInvoiceAddItemSectionSubTotal => 'Промежуточный итог';

  @override
  String get comment_create_invoice_information_section =>
      '==== Раздел информации создания счета ====';

  @override
  String get createInvoiceInformationSectionTitle => 'Информация о счете';

  @override
  String get createInvoiceInformationSectionInvoiceTo => 'Счет на';

  @override
  String get createInvoiceInformationSectionEmailAddress =>
      'Адрес электронной почты';

  @override
  String get createInvoiceInformationSectionAddress => 'Адрес';

  @override
  String get createInvoiceInformationSectionWallet => 'Кошелек';

  @override
  String get createInvoiceInformationSectionStatus => 'Статус';

  @override
  String get createInvoiceInformationSectionIssueDate => 'Дата выставления';

  @override
  String get createInvoiceInformationSectionWalletNotFound =>
      'Кошельки не найдены';

  @override
  String get createInvoiceInformationSectionWalletHint => 'Выберите кошелек';

  @override
  String get createInvoiceInformationSectionStatusTitle => 'Статус';

  @override
  String get createInvoiceInformationSectionStatusNotFound =>
      'Статус не найден';

  @override
  String get createInvoiceInformationSectionStatusDraft => 'Черновик';

  @override
  String get createInvoiceInformationSectionStatusPublished => 'Опубликовано';

  @override
  String get comment_make_payment_screen => '==== Экран платежа ====';

  @override
  String get makePaymentScreenTitle => 'Сделать платеж';

  @override
  String get makePaymentScreenWalletsNotFound => 'Кошельки не найдены';

  @override
  String get makePaymentScreenBalance => 'Баланс';

  @override
  String get makePaymentScreenHistory => 'История платежей';

  @override
  String get comment_make_payment_amount_step_section =>
      '==== Раздел шага суммы платежа ====';

  @override
  String get makePaymentAmountStepSectionMerchantId => 'ID мерчанта';

  @override
  String get makePaymentAmountStepSectionAmount => 'Сумма';

  @override
  String get makePaymentAmountStepSectionMinLimit => 'Минимум';

  @override
  String get makePaymentAmountStepSectionMaxLimit => 'и Максимум';

  @override
  String get makePaymentAmountStepSectionMakePaymentButton => 'Сделать платеж';

  @override
  String get makePaymentAmountStepSectionSavedMerchantsButton =>
      'Сохраненные мерчанты';

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
      'Вы хотите удалить этого мерчанта?';

  @override
  String get makePaymentAmountStepSectionDeleteButton => 'Удалить';

  @override
  String get makePaymentAmountStepSectionCancelButton => 'Отмена';

  @override
  String get comment_make_payment_review_step_section =>
      '==== Раздел проверки платежа ====';

  @override
  String get makePaymentReviewStepSectionTitle => 'Проверка деталей';

  @override
  String get makePaymentReviewStepSectionAmount => 'Сумма';

  @override
  String get makePaymentReviewStepSectionWallet => 'Кошелек';

  @override
  String get makePaymentReviewStepSectionMerchantAccount => 'Аккаунт мерчанта';

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
      '==== Раздел успеха платежа ====';

  @override
  String get makePaymentSuccessStepSectionTitle => 'Платеж успешен!';

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
      '==== Экран истории платежей ====';

  @override
  String get makePaymentHistoryScreenTitle => 'История платежей';

  @override
  String get comment_make_payment_filter_bottom_sheet =>
      '==== Нижний лист фильтра платежей ====';

  @override
  String get makePaymentFilterTransactionId => 'ID транзакций';

  @override
  String get makePaymentFilterStatus => 'Статус';

  @override
  String get makePaymentFilterApplyButton => 'Фильтровать';

  @override
  String get makePaymentFilterResetButton => 'Сбросить';

  @override
  String get comment_qr_code_screen => '==== Экран QR-кода ====';

  @override
  String get qrCodeScreenTitle => 'Мой QR-код';

  @override
  String get qrCodeScreenDownloadButton => 'Скачать';

  @override
  String get qrCodeScreenPermissionRequired =>
      'Требуется разрешение. Пожалуйста, разрешите в настройках.';

  @override
  String get qrCodeScreenDownloadSuccess => 'Успешно загружено!';

  @override
  String get comment_referral_screen => '==== Экран рефералов ====';

  @override
  String get referralScreenTitle => 'Рефералы';

  @override
  String get referralScreenEarnAmount => 'Заработать';

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
  String get referralScreenReferredFriends => 'Приглашенные друзья';

  @override
  String get comment_referred_friends_screen =>
      '==== Экран приглашенных друзей ====';

  @override
  String get referredFriendsScreenTitle => 'Приглашенные друзья';

  @override
  String get referredFriendsScreenReferralTreeButton => 'Дерево рефералов';

  @override
  String get comment_referred_friend_list =>
      '==== Список приглашенных друзей ====';

  @override
  String get referredFriendListJoinedOn => 'Присоединился';

  @override
  String get referredFriendListActive => 'Активен';

  @override
  String get referredFriendListInactive => 'Неактивен';

  @override
  String get comment_referral_tree_screen => '==== Экран дерева рефералов ====';

  @override
  String get referralTreeScreenTitle => 'Дерево рефералов';

  @override
  String get comment_request_money_screen => '==== Экран запроса денег ====';

  @override
  String get requestMoneyScreenTitle => 'Запросить деньги';

  @override
  String get comment_request_money_amount_step_section =>
      '==== Раздел шага суммы запроса ====';

  @override
  String get requestMoneyAmountStepSectionRecipientId => 'ID получателя';

  @override
  String get requestMoneyAmountStepSectionRequestAmount =>
      'Запрашиваемая сумма';

  @override
  String get requestMoneyAmountStepSectionMin => 'Минимум';

  @override
  String get requestMoneyAmountStepSectionMax => 'и Максимум';

  @override
  String get requestMoneyAmountStepSectionNote => 'Примечание';

  @override
  String get requestMoneyAmountStepSectionRequestMoneyButton =>
      'Запросить деньги';

  @override
  String get requestMoneyAmountStepSectionInvalidQrCodeDigits =>
      'Неверный QR-код. UID получателя должен состоять только из цифр.';

  @override
  String get requestMoneyAmountStepSectionInvalidQrCodePrefix =>
      'Неверный QR-код. Префикс UID не найден.';

  @override
  String get comment_request_money_header_section =>
      '==== Раздел заголовка запроса денег ====';

  @override
  String get requestMoneyHeaderSectionTitle => 'Запросить деньги';

  @override
  String get requestMoneyHeaderSectionRequestMoneyButton => 'Запросить деньги';

  @override
  String get requestMoneyHeaderSectionReceivedRequestButton =>
      'Полученные запросы';

  @override
  String get requestMoneyHeaderSectionHistory => 'История запросов денег';

  @override
  String get comment_request_money_review_step_section =>
      '==== Раздел проверки запроса ====';

  @override
  String get requestMoneyReviewStepSectionTitle => 'Проверка деталей';

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
      '==== Раздел успеха запроса ====';

  @override
  String get requestMoneySuccessStepSectionTitle => 'Запрос денег успешен!';

  @override
  String get requestMoneySuccessStepSectionAmount => 'Сумма';

  @override
  String get requestMoneySuccessStepSectionRecipientName => 'Имя получателя';

  @override
  String get requestMoneySuccessStepSectionRequestWalletName =>
      'Название кошелька запроса';

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
      '==== Раздел кошелька запроса ====';

  @override
  String get requestMoneyWalletSectionBalance => 'Баланс';

  @override
  String get requestMoneyWalletSectionWalletsNotFound => 'Кошельки не найдены';

  @override
  String get comment_request_money_history_screen =>
      '==== Экран истории запросов ====';

  @override
  String get requestMoneyHistoryScreenTitle => 'История запросов денег';

  @override
  String get requestMoneyHistoryRequestedAt => 'Запрошено:';

  @override
  String get requestMoneyHistoryStatus => 'Статус: ';

  @override
  String get comment_request_money_history_details =>
      '==== Детали истории запросов ====';

  @override
  String get requestMoneyHistoryDetailsRequestEmail => 'Email запроса';

  @override
  String get requestMoneyHistoryDetailsCurrency => 'Валюта';

  @override
  String get requestMoneyHistoryDetailsCharge => 'Комиссия';

  @override
  String get requestMoneyHistoryDetailsFinalAmount => 'Итоговая сумма';

  @override
  String get requestMoneyHistoryDetailsRequestAt => 'Запрошено';

  @override
  String get requestMoneyHistoryDetailsStatus => 'Статус';

  @override
  String get comment_received_request_screen =>
      '==== Экран полученных запросов ====';

  @override
  String get receivedRequestRequestedAt => 'Запрошено:';

  @override
  String get receivedRequestStatus => 'Статус: ';

  @override
  String get receivedRequestRejectButton => 'Отклонить';

  @override
  String get receivedRequestAcceptButton => 'Принять';

  @override
  String get comment_accept_request_dropdown =>
      '==== Выпадающий список принятия запроса ====';

  @override
  String get acceptRequestDropdownTitle => 'Вы уверены?';

  @override
  String get acceptRequestDropdownMessage =>
      'Хотите принять этот запрос на деньги?';

  @override
  String get acceptRequestDropdownPayableAmount => 'Сумма к оплате:';

  @override
  String get acceptRequestDropdownPayWallet => 'Кошелек оплаты:';

  @override
  String get acceptRequestDropdownRequesterNote => 'Примечание отправителя:';

  @override
  String get acceptRequestDropdownNoteNotFound => 'Примечание не найдено';

  @override
  String get acceptRequestDropdownAcceptButton => 'Принять';

  @override
  String get acceptRequestDropdownCancelButton => 'Отмена';

  @override
  String get comment_received_request_details =>
      '==== Детали полученного запроса ====';

  @override
  String get receivedRequestDetailsRequestEmail => 'Email запроса';

  @override
  String get receivedRequestDetailsCurrency => 'Валюта';

  @override
  String get receivedRequestDetailsCharge => 'Комиссия';

  @override
  String get receivedRequestDetailsFinalAmount => 'Итоговая сумма';

  @override
  String get receivedRequestDetailsRequestAt => 'Запрошено';

  @override
  String get receivedRequestDetailsStatus => 'Статус';

  @override
  String get comment_change_password_screen => '==== Экран смены пароля ====';

  @override
  String get changePasswordScreenTitle => 'Сменить пароль';

  @override
  String get changePasswordCurrentPassword => 'Текущий пароль';

  @override
  String get changePasswordNewPassword => 'Новый пароль';

  @override
  String get changePasswordConfirmPassword => 'Подтвердите пароль';

  @override
  String get changePasswordSaveChangesButton => 'Сохранить изменения';

  @override
  String get comment_id_verification_screen => '==== Экран верификации ID ====';

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
      'Вы отправили документы, они ожидают одобрения';

  @override
  String get kycStatusRejected =>
      'Ваша верификация KYC не прошла. Пожалуйста, отправьте документы заново.';

  @override
  String get kycStatusNotSubmitted => 'Вы еще не отправили документы KYC';

  @override
  String get comment_kyc_history_screen => '==== Экран истории KYC ====';

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
      '==== Нижний лист деталей KYC ====';

  @override
  String get kycDetailsTitle => 'Детали KYC';

  @override
  String get kycDetailsStatus => 'Статус:';

  @override
  String get kycDetailsCreatedAt => 'Создано:';

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
  String get comment_notifications_screen => '==== Экран уведомлений ====';

  @override
  String get notificationsScreenTitle => 'Все уведомления';

  @override
  String get notificationsMarkAllReadButton => 'Отметить все как прочитанные';

  @override
  String get comment_profile_settings_screen =>
      '==== Экран настроек профиля ====';

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
  String get profileSettingsEmailAddress => 'Адрес электронной почты';

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
      '==== Экран тикетов поддержки ====';

  @override
  String get supportTicketsScreenTitle => 'Тикет поддержки';

  @override
  String get supportTicketsCreateTicketButton => 'Создать тикет';

  @override
  String get supportTicketsLastUpdate => 'Последнее обновление';

  @override
  String get supportTicketsRequestedAt => 'Запрошено';

  @override
  String get supportTicketsPriorityHigh => 'Высокий';

  @override
  String get supportTicketsPriorityMedium => 'Средний';

  @override
  String get supportTicketsPriorityLow => 'Низкий';

  @override
  String get supportTicketsStatus => 'Статус: ';

  @override
  String get supportTicketsStatusOpen => 'Открыт';

  @override
  String get supportTicketsStatusClose => 'Закрыт';

  @override
  String get supportTicketsReplyButton => 'Ответить';

  @override
  String get comment_ticket_details => '==== Детали тикета ====';

  @override
  String get ticketDetailsTitle => 'Детали тикета';

  @override
  String get ticketDetailsTicketId => 'ID тикета';

  @override
  String get ticketDetailsCategory => 'Категория';

  @override
  String get ticketDetailsPriority => 'Приоритет';

  @override
  String get ticketDetailsCreatedOn => 'Создано';

  @override
  String get ticketDetailsLastUpdated => 'Последнее обновление';

  @override
  String get ticketDetailsPriorityHigh => 'Высокий';

  @override
  String get ticketDetailsPriorityMedium => 'Средний';

  @override
  String get ticketDetailsPriorityLow => 'Низкий';

  @override
  String get comment_replay_ticket_screen => '==== Экран ответа на тикет ====';

  @override
  String get replayTicketMarkAsClosedButton => 'Отметить как закрытый';

  @override
  String get replayTicketMessageHint => 'Введите ваше сообщение...';

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
  String get comment_add_new_ticket_screen =>
      '==== Экран добавления нового тикета ====';

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
  String get addNewTicketAddButton => 'Добавить тикет';

  @override
  String get comment_two_factor_authentication_screen =>
      '==== Экран двухфакторной аутентификации ====';

  @override
  String get twoFactorAuthenticationScreenTitle => '2FA Аутентификация';

  @override
  String get comment_disable_2fa_section => '==== Раздел отключения 2FA ====';

  @override
  String get disable2FaSectionTitle => '2FA Аутентификация';

  @override
  String get disable2FaSectionDescription => 'noInternetConnectionRetryButton';

  @override
  String get disable2FaSectionDisableButton => 'Отключить 2FA';

  @override
  String get disable2FaSectionPasswordRequired => 'Пожалуйста, введите пароль';

  @override
  String get comment_enable_2fa_section => '==== Раздел включения 2FA ====';

  @override
  String get enable2FaSectionTitle => '2FA Аутентификация';

  @override
  String get enable2FaSectionDescription =>
      'Отсканируйте QR-код в приложении Google Authenticator\nдля включения 2FA';

  @override
  String get enable2FaSectionPinLabel =>
      'PIN из приложения Google Authenticator';

  @override
  String get enable2FaSectionEnableButton => 'Включить 2FA';

  @override
  String get enable2FaSectionPinRequired =>
      'Пожалуйста, введите PIN Google Authenticator';

  @override
  String get comment_generate_2fa_section => '==== Раздел генерации 2FA ====';

  @override
  String get generate2FaSectionTitle => '2FA Аутентификация';

  @override
  String get generate2FaSectionDescription =>
      'Повысьте безопасность аккаунта с помощью двухфакторной аутентификации';

  @override
  String get generate2FaSectionGenerateButton => 'Сгенерировать 2FA';

  @override
  String get comment_settings_screen => '==== Экран настроек ====';

  @override
  String get settingsScreenTitle => 'Настройки';

  @override
  String get settingsProfileSettings => 'Настройки профиля';

  @override
  String get settingsChangePassword => 'Сменить пароль';

  @override
  String get settingsAllNotification => 'Все уведомления';

  @override
  String get settingsTwoFactorAuthentication => '2FA Аутентификация';

  @override
  String get settingsIdVerification => 'Верификация ID';

  @override
  String get settingsSupport => 'Поддержка';

  @override
  String get settingsSignOut => 'Выйти';

  @override
  String get settingsKycVerified => 'Верифицировано';

  @override
  String get settingsKycPending => 'В ожидании';

  @override
  String get settingsKycFailed => 'Не удалось';

  @override
  String get settingsKycNotSubmitted => 'Не отправлено';

  @override
  String get comment_transactions_screen => '==== Экран транзакций ====';

  @override
  String get transactionsScreenTitle => 'Мои транзакции';

  @override
  String get comment_transactions_popup => '==== Попап транзакций ====';

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
  String get comment_transaction_filter_bottom_sheet =>
      '==== Нижний лист фильтра транзакций ====';

  @override
  String get transactionFilterTransactionId => 'ID транзакций';

  @override
  String get transactionFilterStatus => 'Статус';

  @override
  String get transactionFilterApplyButton => 'Фильтровать';

  @override
  String get transactionFilterResetButton => 'Сбросить';

  @override
  String get comment_transfer_screen => '==== Экран перевода ====';

  @override
  String get transferScreenTitle => 'Перевод денег';

  @override
  String get transferHistoryTransferHistory => 'История переводов';

  @override
  String get transferHistoryReceivedHistory => 'История получений';

  @override
  String get comment_transfer_received_history_screen =>
      '==== Экран истории полученных переводов ====';

  @override
  String get transferReceivedHistoryScreenTitle => 'История получений';

  @override
  String get comment_transfer_received_filter_bottom_sheet =>
      '==== Нижний лист фильтра полученных переводов ====';

  @override
  String get transferReceivedFilterTransactionId => 'ID транзакций';

  @override
  String get transferReceivedFilterStatus => 'Статус';

  @override
  String get transferReceivedFilterApplyButton => 'Фильтровать';

  @override
  String get transferReceivedFilterResetButton => 'Сбросить';

  @override
  String get comment_transfer_history_screen =>
      '==== Экран истории переводов ====';

  @override
  String get transferHistoryScreenTitle => 'История переводов';

  @override
  String get comment_transfer_transaction_filter_bottom_sheet =>
      '==== Нижний лист фильтра транзакций переводов ====';

  @override
  String get transferTransactionFilterTransactionId => 'ID транзакций';

  @override
  String get transferTransactionFilterStatus => 'Статус';

  @override
  String get transferTransactionFilterApplyButton => 'Фильтровать';

  @override
  String get transferTransactionFilterResetButton => 'Сбросить';

  @override
  String get comment_transfer_amount_step_section =>
      '==== Раздел шага суммы перевода ====';

  @override
  String get transferAmountStepSectionRecipientUid => 'UID получателя';

  @override
  String get transferAmountStepSectionAmount => 'Сумма';

  @override
  String get transferAmountStepSectionMin => 'Минимум';

  @override
  String get transferAmountStepSectionMax => 'и Максимум';

  @override
  String get transferAmountStepSectionTransferMoneyButton => 'Перевести деньги';

  @override
  String get transferAmountStepSectionSavedBeneficiaryButton =>
      'Сохраненные бенефициары';

  @override
  String get transferAmountStepSectionInvalidQrCodeDigits =>
      'Неверный QR-код. UID получателя должен состоять только из цифр.';

  @override
  String get transferAmountStepSectionInvalidQrCodePrefix =>
      'Неверный QR-код. Префикс UID не найден.';

  @override
  String get transferAmountStepSectionBeneficiariesTitle => 'Бенефициары';

  @override
  String get transferAmountStepSectionAddBeneficiary => 'Добавить бенефициара';

  @override
  String get transferAmountStepSectionUidLabel => 'UID:';

  @override
  String get transferAmountStepSectionDeleteConfirmationTitle => 'Вы уверены?';

  @override
  String get transferAmountStepSectionDeleteConfirmationMessage =>
      'Вы хотите удалить этого бенефициара?';

  @override
  String get transferAmountStepSectionDeleteButton => 'Удалить';

  @override
  String get transferAmountStepSectionCancelButton => 'Отмена';

  @override
  String get comment_transfer_review_step_section =>
      '==== Раздел проверки перевода ====';

  @override
  String get transferReviewStepSectionTitle => 'Проверка деталей';

  @override
  String get transferReviewStepSectionAmount => 'Сумма';

  @override
  String get transferReviewStepSectionWallet => 'Кошелек';

  @override
  String get transferReviewStepSectionRecipientAccount => 'Аккаунт получателя';

  @override
  String get transferReviewStepSectionCharge => 'Комиссия';

  @override
  String get transferReviewStepSectionTotalAmount => 'Итоговая сумма';

  @override
  String get transferReviewStepSectionBackButton => 'Назад';

  @override
  String get transferReviewStepSectionConfirmButton => 'Подтвердить';

  @override
  String get comment_transfer_success_step_section =>
      '==== Раздел успеха перевода ====';

  @override
  String get transferSuccessStepSectionTitle => 'Перевод успешен!';

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
  String get transferSuccessStepSectionTotalAmount => 'Итоговая сумма';

  @override
  String get transferSuccessStepSectionTransferAgainButton => 'Перевести снова';

  @override
  String get transferSuccessStepSectionBackHomeButton => 'На главную';

  @override
  String get comment_transfer_wallet_section =>
      '==== Раздел кошелька перевода ====';

  @override
  String get transferWalletSectionBalance => 'Баланс';

  @override
  String get transferWalletSectionWalletsNotFound => 'Кошельки не найдены';

  @override
  String get comment_wallets_screen => '==== Экран кошельков ====';

  @override
  String get walletsScreenTitle => 'Мои кошельки';

  @override
  String get comment_delete_wallet_bottom_sheet =>
      '==== Нижний лист удаления кошелька ====';

  @override
  String get deleteWalletBottomSheetTitle => 'Вы уверены?';

  @override
  String get deleteWalletBottomSheetMessage =>
      'Вы хотите удалить этот кошелек?';

  @override
  String get deleteWalletBottomSheetDeleteButton => 'Удалить';

  @override
  String get deleteWalletBottomSheetCancelButton => 'Отмена';

  @override
  String get comment_wallet_list_section => '==== Раздел списка кошельков ====';

  @override
  String get walletListSectionTopUpButton => 'Пополнить';

  @override
  String get walletListSectionWithdrawButton => 'Вывести';

  @override
  String get walletListSectionUserDepositNotEnabled => 'Пополнение отключено';

  @override
  String get walletListSectionUserWithdrawNotEnabled => 'Вывод отключен';

  @override
  String get comment_create_new_wallet_screen =>
      '==== Экран создания нового кошелька ====';

  @override
  String get createNewWalletScreenTitle => 'Создать новый кошелек';

  @override
  String get createNewWalletCurrency => 'Валюта';

  @override
  String get createNewWalletSelectCurrency => 'Выберите валюту';

  @override
  String get createNewWalletCurrencyNotFound => 'Валюта не найдена';

  @override
  String get createNewWalletCreateButton => 'Создать';

  @override
  String get comment_withdraw_screen => '==== Экран вывода ====';

  @override
  String get withdrawScreenTitle => 'Вывести деньги';

  @override
  String get withdrawScreenAddAccountButton => 'Добавить счет';

  @override
  String get comment_withdraw_history_screen =>
      '==== Экран истории вывода ====';

  @override
  String get withdrawHistoryScreenTitle => 'История вывода';

  @override
  String get comment_withdraw_transaction_filter_bottom_sheet =>
      '==== Нижний лист фильтра транзакций вывода ====';

  @override
  String get withdrawTransactionFilterTransactionId => 'ID транзакций';

  @override
  String get withdrawTransactionFilterStatus => 'Статус';

  @override
  String get withdrawTransactionFilterApplyButton => 'Фильтровать';

  @override
  String get withdrawTransactionFilterResetButton => 'Сбросить';

  @override
  String get comment_delete_account_dropdown_section =>
      '==== Раздел выпадающего списка удаления аккаунта ====';

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
      '==== Нижний лист фильтра счетов вывода ====';

  @override
  String get withdrawAccountFilterMethodName => 'Название метода';

  @override
  String get withdrawAccountFilterApplyButton => 'Фильтровать';

  @override
  String get comment_withdraw_account_section =>
      '==== Раздел счетов вывода ====';

  @override
  String get withdrawAccountSectionTitle => 'Все счета';

  @override
  String get comment_withdraw_amount_step_section =>
      '==== Раздел шага суммы вывода ====';

  @override
  String get withdrawAmountStepSectionWithdrawAccount => 'Счет вывода';

  @override
  String get withdrawAmountStepSectionAmount => 'Сумма';

  @override
  String get withdrawAmountStepSectionMin => 'Минимум';

  @override
  String get withdrawAmountStepSectionMax => 'и Максимум';

  @override
  String get withdrawAmountStepSectionWithdrawMoneyButton => 'Вывести деньги';

  @override
  String get withdrawAmountStepSectionWithdrawAccountTitle => 'Счет вывода';

  @override
  String get withdrawAmountStepSectionNoAccountsFound =>
      'Счета для вывода не найдены';

  @override
  String get withdrawAmountStepSectionCurrencyLabel => 'Валюта:';

  @override
  String get withdrawAmountStepSectionMinDescription => 'Мин:';

  @override
  String get withdrawAmountStepSectionMaxDescription => 'Макс:';

  @override
  String get comment_withdraw_header_section =>
      '==== Раздел заголовка вывода ====';

  @override
  String get withdrawHeaderSectionTitle => 'Вывести деньги';

  @override
  String get withdrawHeaderSectionWithdrawButton => 'Вывести';

  @override
  String get withdrawHeaderSectionWithdrawAccountButton => 'Счет вывода';

  @override
  String get withdrawHeaderSectionHistory => 'История вывода';

  @override
  String get comment_withdraw_review_step_section =>
      '==== Раздел проверки вывода ====';

  @override
  String get withdrawReviewStepSectionTitle => 'Проверка деталей';

  @override
  String get withdrawReviewStepSectionAmount => 'Сумма';

  @override
  String get withdrawReviewStepSectionCharge => 'Комиссия';

  @override
  String get withdrawReviewStepSectionTotalAmount => 'Итоговая сумма';

  @override
  String get withdrawReviewStepSectionBackButton => 'Назад';

  @override
  String get withdrawReviewStepSectionConfirmButton => 'Подтвердить';

  @override
  String get comment_withdraw_success_step_section =>
      '==== Раздел успеха вывода ====';

  @override
  String get withdrawSuccessStepSectionTitle => 'Вывод успешен!';

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
      '==== Экран редактирования счета вывода ====';

  @override
  String get editWithdrawAccountTitle => 'Обновить счет вывода';

  @override
  String get editWithdrawAccountMethodName => 'Название метода';

  @override
  String get editWithdrawAccountMethodNameHint => 'Введите название метода';

  @override
  String get editWithdrawAccountFieldHint => 'Введите здесь...';

  @override
  String get editWithdrawAccountGenericFieldHint => 'Введите';

  @override
  String get editWithdrawAccountUpdateButton => 'Обновить счет';

  @override
  String get comment_create_withdraw_account_screen =>
      '==== Экран создания счета вывода ====';

  @override
  String get createWithdrawAccountTitle => 'Создать счет вывода';

  @override
  String get createWithdrawAccountWallet => 'Кошелек';

  @override
  String get createWithdrawAccountWithdrawMethod => 'Метод вывода';

  @override
  String get createWithdrawAccountMethodName => 'Название метода';

  @override
  String get createWithdrawAccountCreateButton => 'Создать счет';

  @override
  String get createWithdrawAccountWalletsNotFound => 'Кошельки не найдены';

  @override
  String get createWithdrawAccountWithdrawMethodTitle => 'Метод вывода';

  @override
  String get createWithdrawAccountWithdrawMethodNotFound =>
      'Метод вывода не найден';

  @override
  String get createWithdrawAccountFieldHint => 'Введите здесь...';

  @override
  String get comment_dynamic_attachment_preview =>
      '==== Динамический предпросмотр вложения ====';

  @override
  String get dynamicAttachmentPreviewTitle => 'Предпросмотр вложения';

  @override
  String get comment_no_internet_connection =>
      '==== Нет подключения к интернету ====';

  @override
  String get noInternetConnectionTitle => 'Нет подключения к интернету';

  @override
  String get noInternetConnectionMessage => 'Проверьте настройки сети';

  @override
  String get noInternetConnectionRetryButton => 'Повторить';

  @override
  String get comment_qr_scanner_screen => '==== Экран сканера QR ====';

  @override
  String get qrScannerScreenInstruction =>
      'Поместите QR-код в рамку для сканирования';

  @override
  String get qrScannerScreenProcessing => 'Обработка...';

  @override
  String get comment_webview_screen => '==== Экран WebView ====';

  @override
  String get webViewScreenPaymentSuccessful => 'Платеж успешен!';

  @override
  String get webViewScreenPaymentFailed => 'Платеж не удался!';

  @override
  String get webViewScreenPaymentCancelled => 'Платеж отменен!';

  @override
  String get comment_common_country_dropdown_bottom_sheet =>
      '==== Нижний лист выбора страны ====';

  @override
  String get commonCountryDropdownSearchHint => 'Поиск';

  @override
  String get commonCountryDropdownNotFound => 'Страна не найдена';

  @override
  String get comment_common_dropdown_bottom_sheet =>
      '==== Нижний лист общего выпадающего списка ====';

  @override
  String get commonDropdownSearchHint => 'Поиск';

  @override
  String get comment_common_dropdown_bottom_sheet_three =>
      '==== Нижний лист общего выпадающего списка три ====';

  @override
  String get commonDropdownThreeSearchHint => 'Поиск';

  @override
  String get comment_common_dropdown_bottom_sheet_two =>
      '==== Нижний лист общего выпадающего списка два ====';

  @override
  String get commonDropdownTwoSearchHint => 'Поиск';

  @override
  String get comment_common_dropdown_wallet_bottom_sheet =>
      '==== Нижний лист выбора кошелька ====';

  @override
  String get commonDropdownWalletTitle => 'Выберите кошелек';

  @override
  String get comment_image_picker_dropdown_bottom_sheet =>
      '==== Нижний лист выбора изображения ====';

  @override
  String get imagePickerDropdownTitle => 'Выберите источник изображения';

  @override
  String get imagePickerDropdownCamera => 'Камера';

  @override
  String get imagePickerDropdownGallery => 'Галерея';

  @override
  String get comment_multiple_image_picker_dropdown_bottom_sheet =>
      '==== Нижний лист множественного выбора изображения ====';

  @override
  String get multipleImagePickerDropdownTitle => 'Источник изображения';

  @override
  String get multipleImagePickerDropdownCamera => 'Камера';

  @override
  String get multipleImagePickerDropdownGallery => 'Галерея';

  @override
  String get comment_navigation_screen => '==== Экран навигации ====';

  @override
  String get bottomNavHome => 'Главная';

  @override
  String get bottomNavTransfer => 'Перевод';

  @override
  String get bottomNavGift => 'Подарок';

  @override
  String get bottomNavSettings => 'Настройки';

  @override
  String get qrInvalidFormat =>
      'Неверный формат QR. Принимаются только коды AID, MID или UID.';

  @override
  String get userTransferNotEnabled => 'Перевод для пользователя отключен';

  @override
  String get userGiftNotEnabled => 'Подарки для пользователя отключены';

  @override
  String get comment_image_picker_controller =>
      '==== Контроллер выбора изображения ====';

  @override
  String get imagePickerGalleryError =>
      'Не удалось выбрать изображение из галереи';

  @override
  String get imagePickerCameraError =>
      'Не удалось выбрать изображение с камеры';

  @override
  String get comment_multiple_image_picker_controller =>
      '==== Контроллер множественного выбора изображения ====';

  @override
  String get multipleImagePickerGalleryError =>
      'Не удалось выбрать изображение из галереи';

  @override
  String get multipleImagePickerCameraError =>
      'Не удалось выбрать изображение с камеры';

  @override
  String get comment_biometric_auth_service =>
      '==== Сервис биометрической аутентификации ====';

  @override
  String get biometricDeviceNotSupported =>
      'Это устройство не поддерживает биометрию.';

  @override
  String get biometricNotEnrolled =>
      'Биометрия не настроена. Пожалуйста, настройте отпечаток пальца';

  @override
  String get biometricUnavailable =>
      'Функции биометрии в настоящее время недоступны.';

  @override
  String get biometricAuthenticationFailed =>
      'Биометрическая аутентификация не удалась.';

  @override
  String get biometricCheckFailed =>
      'Не удалось проверить доступность биометрии.';

  @override
  String get biometricAuthReason => 'Аутентифицируйтесь для входа';

  @override
  String get comment_network_service => '==== Сервис сети ====';

  @override
  String get networkErrorGeneric =>
      'Произошла неожиданная ошибка. Попробуйте еще раз.';

  @override
  String get networkErrorTimeout =>
      'Время ожидания запроса истекло. Попробуйте еще раз.';

  @override
  String get networkErrorOccurred => 'Произошла ошибка. Попробуйте еще раз.';

  @override
  String get unauthorizedDialogTitle => 'Не авторизован';

  @override
  String get unauthorizedDialogDescription =>
      'У вас нет доступа к этому ресурсу. Пожалуйста, войдите снова!';

  @override
  String get unauthorizedDialogButton => 'ОК';

  @override
  String get comment_add_money_controller => '==== Контроллер пополнения ====';

  @override
  String get addMoneySuccess => 'Деньги успешно добавлены';

  @override
  String get addMoneyValidationSelectWallet => 'Пожалуйста, выберите кошелек';

  @override
  String get addMoneyValidationSelectGateway => 'Пожалуйста, выберите шлюз';

  @override
  String get addMoneyValidationEnterAmount => 'Пожалуйста, введите сумму';

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
    return 'Пожалуйста, загрузите файл для $fieldName';
  }

  @override
  String addMoneyValidationFillField(Object fieldName) {
    return 'Пожалуйста, заполните поле $fieldName';
  }

  @override
  String get comment_cash_out_controller => '==== Контроллер вывода ====';

  @override
  String get cashOutValidationSelectWallet => 'Пожалуйста, выберите кошелек';

  @override
  String get cashOutValidationEnterAgentAid => 'Пожалуйста, введите AID агента';

  @override
  String get cashOutValidationEnterAmount => 'Пожалуйста, введите сумму';

  @override
  String cashOutValidationAmountMinimum(Object amount, Object currency) {
    return 'Минимальная сумма должна быть $amount $currency';
  }

  @override
  String cashOutValidationAmountMaximum(Object amount, Object currency) {
    return 'Максимальная сумма должна быть $amount $currency';
  }

  @override
  String get comment_exchange_controller => '==== Контроллер обмена ====';

  @override
  String get exchangeValidationSelectFromWallet =>
      'Пожалуйста, выберите исходный кошелек';

  @override
  String get exchangeValidationSelectToWallet =>
      'Пожалуйста, выберите целевой кошелек';

  @override
  String get exchangeValidationEnterAmount => 'Пожалуйста, введите сумму';

  @override
  String exchangeValidationAmountMinimum(Object amount, Object currency) {
    return 'Минимальная сумма должна быть $amount $currency';
  }

  @override
  String exchangeValidationAmountMaximum(Object amount, Object currency) {
    return 'Максимальная сумма должна быть $amount $currency';
  }

  @override
  String get comment_create_gift_controller =>
      '==== Контроллер создания подарка ====';

  @override
  String get createGiftValidationSelectWallet => 'Пожалуйста, выберите кошелек';

  @override
  String get createGiftValidationEnterAmount => 'Пожалуйста, введите сумму';

  @override
  String createGiftValidationAmountMinimum(Object amount, Object currency) {
    return 'Минимальная сумма должна быть $amount $currency';
  }

  @override
  String createGiftValidationAmountMaximum(Object amount, Object currency) {
    return 'Максимальная сумма должна быть $amount $currency';
  }

  @override
  String get comment_home_controller => '==== Контроллер главной страницы ====';

  @override
  String get homeLanguageChangeFailed => 'Не удалось сменить язык';

  @override
  String get homeBiometricDeviceNotSupported =>
      'Это устройство не поддерживает биометрию.';

  @override
  String get homeBiometricAuthenticationFailed =>
      'Аутентификация не удалась. Настройка биометрии не изменена.';

  @override
  String get homeBiometricEnabledSuccess => 'Биометрия успешно включена';

  @override
  String get homeBiometricDisabledSuccess => 'Биометрия успешно отключена';

  @override
  String get homeBiometricNotFoundTitle => 'Биометрия не найдена';

  @override
  String get homeBiometricNotFoundDescription =>
      'На этом устройстве не настроены отпечаток пальца или биометрия. Вы можете настроить её в системных настройках.';

  @override
  String get homeBiometricOpenSettings => 'Открыть настройки безопасности';

  @override
  String get homeIosBiometricSetup =>
      'Пожалуйста, перейдите в Настройки > Face ID и код-пароль для настройки биометрии.';

  @override
  String get comment_create_invoice_controller =>
      '==== Контроллер создания счета ====';

  @override
  String get createInvoiceValidationEnterInvoiceTo =>
      'Пожалуйста, введите получателя счета';

  @override
  String get createInvoiceValidationEnterEmailAddress =>
      'Пожалуйста, введите адрес электронной почты';

  @override
  String get createInvoiceValidationEnterAddress => 'Пожалуйста, введите адрес';

  @override
  String get createInvoiceValidationSelectWallet =>
      'Пожалуйста, выберите кошелек';

  @override
  String get createInvoiceValidationSelectStatus =>
      'Пожалуйста, выберите статус';

  @override
  String get createInvoiceValidationSelectIssueDate =>
      'Пожалуйста, выберите дату выставления';

  @override
  String createInvoiceValidationItemNameRequired(Object itemNumber) {
    return 'Позиция $itemNumber: Название обязательно';
  }

  @override
  String createInvoiceValidationItemQuantityGreaterThanZero(Object itemNumber) {
    return 'Позиция $itemNumber: Количество должно быть больше 0';
  }

  @override
  String createInvoiceValidationItemUnitPriceGreaterThanZero(
    Object itemNumber,
  ) {
    return 'Позиция $itemNumber: Цена за единицу должна быть больше 0';
  }

  @override
  String get comment_make_payment_controller => '==== Контроллер платежа ====';

  @override
  String get makePaymentValidationSelectWallet =>
      'Пожалуйста, выберите кошелек';

  @override
  String get makePaymentValidationEnterMerchantMid =>
      'Пожалуйста, введите MID мерчанта';

  @override
  String get makePaymentValidationEnterAmount => 'Пожалуйста, введите сумму';

  @override
  String makePaymentValidationAmountMinimum(Object amount, Object currency) {
    return 'Минимальная сумма должна быть $amount $currency';
  }

  @override
  String makePaymentValidationAmountMaximum(Object amount, Object currency) {
    return 'Максимальная сумма должна быть $amount $currency';
  }

  @override
  String get comment_request_money_controller =>
      '==== Контроллер запроса денег ====';

  @override
  String get requestMoneyValidationSelectWallet =>
      'Пожалуйста, выберите кошелек';

  @override
  String get requestMoneyValidationEnterRecipientUid =>
      'Пожалуйста, введите UID получателя';

  @override
  String get requestMoneyValidationEnterRequestAmount =>
      'Пожалуйста, введите сумму запроса';

  @override
  String requestMoneyValidationAmountMinimum(Object amount, Object currency) {
    return 'Минимальная сумма должна быть $amount $currency';
  }

  @override
  String requestMoneyValidationAmountMaximum(Object amount, Object currency) {
    return 'Максимальная сумма должна быть $amount $currency';
  }

  @override
  String get comment_add_new_ticket_controller =>
      '==== Контроллер добавления нового тикета ====';

  @override
  String get addNewTicketSuccess => 'Тикет успешно создан';

  @override
  String get addNewValidationEnterTitle => 'Пожалуйста, введите заголовок';

  @override
  String get addNewValidationEnterDescription => 'Пожалуйста, введите описание';

  @override
  String get comment_change_password_controller =>
      '==== Контроллер смены пароля ====';

  @override
  String get changePasswordValidationEnterCurrentPassword =>
      'Пожалуйста, введите текущий пароль';

  @override
  String get changePasswordValidationEnterNewPassword =>
      'Пожалуйста, введите новый пароль';

  @override
  String get changePasswordValidationPasswordMinLength =>
      'Пароль должен содержать не менее 8 символов';

  @override
  String get changePasswordValidationEnterConfirmPassword =>
      'Пожалуйста, введите подтверждение пароля';

  @override
  String get changePasswordValidationPasswordsDoNotMatch =>
      'Пароли не совпадают';

  @override
  String get comment_transfer_controller => '==== Контроллер перевода ====';

  @override
  String get transferValidationSelectWallet => 'Пожалуйста, выберите кошелек';

  @override
  String get transferValidationEnterRecipientUid =>
      'Пожалуйста, введите UID получателя';

  @override
  String get transferValidationEnterAmount => 'Пожалуйста, введите сумму';

  @override
  String transferValidationAmountMinimum(Object amount, Object currency) {
    return 'Минимальная сумма должна быть $amount $currency';
  }

  @override
  String transferValidationAmountMaximum(Object amount, Object currency) {
    return 'Максимальная сумма должна быть $amount $currency';
  }

  @override
  String get comment_create_withdraw_account_controller =>
      '==== Контроллер создания счета вывода ====';

  @override
  String createWithdrawAccountFileRequiredError(Object fieldName) {
    return 'Файл обязателен для $fieldName';
  }

  @override
  String createWithdrawAccountFieldRequiredError(Object fieldName) {
    return 'Поле $fieldName обязательно';
  }

  @override
  String get createWithdrawAccountValidationSelectWallet =>
      'Пожалуйста, выберите кошелек';

  @override
  String get createWithdrawAccountValidationSelectWithdrawMethod =>
      'Пожалуйста, выберите метод вывода';

  @override
  String get createWithdrawAccountValidationEnterMethodName =>
      'Пожалуйста, введите название метода';

  @override
  String createWithdrawAccountValidationUploadFile(Object fieldName) {
    return 'Пожалуйста, загрузите файл для $fieldName';
  }

  @override
  String createWithdrawAccountValidationFillField(Object fieldName) {
    return 'Пожалуйста, заполните поле $fieldName';
  }

  @override
  String get comment_withdraw_controller => '==== Контроллер вывода ====';

  @override
  String get withdrawValidationSelectWithdrawAccount =>
      'Пожалуйста, выберите счет вывода';

  @override
  String get withdrawValidationEnterAmount => 'Пожалуйста, введите сумму';

  @override
  String withdrawValidationAmountMinimum(Object amount, Object currency) {
    return 'Минимальная сумма должна быть $amount $currency';
  }

  @override
  String withdrawValidationAmountMaximum(Object amount, Object currency) {
    return 'Максимальная сумма должна быть $amount $currency';
  }

  @override
  String get comment_airtime_controller => '==== Контроллер Airtime ====';

  @override
  String get airtimeCountryRequired => 'Пожалуйста, выберите страну';

  @override
  String get airtimeServiceRequired => 'Пожалуйста, выберите услугу';

  @override
  String get airtimeAmountRequired => 'Пожалуйста, введите сумму';

  @override
  String get airtimeAmountValid => 'Пожалуйста, введите корректную сумму';

  @override
  String airtimeDynamicFieldRequired(Object fieldName) {
    return 'Пожалуйста, введите $fieldName';
  }

  @override
  String get comment_cable_controller => '==== Контроллер кабельного ТВ ====';

  @override
  String get cableCountryRequired => 'Пожалуйста, выберите страну';

  @override
  String get cableServiceRequired => 'Пожалуйста, выберите услугу';

  @override
  String get cableAmountRequired => 'Пожалуйста, введите сумму';

  @override
  String get cableAmountValid => 'Пожалуйста, введите корректную сумму';

  @override
  String cableDynamicFieldRequired(Object fieldName) {
    return 'Пожалуйста, введите $fieldName';
  }

  @override
  String get comment_toll_controller => '==== Контроллер дорожных сборов ====';

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
      '==== Контроллер электроэнергии ====';

  @override
  String get electricityCountryRequired => 'Пожалуйста, выберите страну';

  @override
  String get electricityServiceRequired => 'Пожалуйста, выберите услугу';

  @override
  String get electricityAmountRequired => 'Пожалуйста, введите сумму';

  @override
  String get electricityAmountValid => 'Пожалуйста, введите корректную сумму';

  @override
  String electricityDynamicFieldRequired(Object fieldName) {
    return 'Пожалуйста, введите $fieldName';
  }

  @override
  String get comment_internet_controller => '==== Контроллер интернета ====';

  @override
  String get internetCountryRequired => 'Пожалуйста, выберите страну';

  @override
  String get internetServiceRequired => 'Пожалуйста, выберите услугу';

  @override
  String get internetAmountRequired => 'Пожалуйста, введите сумму';

  @override
  String get internetAmountValid => 'Пожалуйста, введите корректную сумму';

  @override
  String internetDynamicFieldRequired(Object fieldName) {
    return 'Пожалуйста, введите $fieldName';
  }

  @override
  String get comment_data_bundle_controller =>
      '==== Контроллер пакета данных ====';

  @override
  String get dataBundleCountryRequired => 'Пожалуйста, выберите страну';

  @override
  String get dataBundleServiceRequired => 'Пожалуйста, выберите услугу';

  @override
  String get dataBundleAmountRequired => 'Пожалуйста, введите сумму';

  @override
  String get dataBundleAmountValid => 'Пожалуйста, введите корректную сумму';

  @override
  String dataBundleDynamicFieldRequired(Object fieldName) {
    return 'Пожалуйста, введите $fieldName';
  }

  @override
  String get comment_airtime_screen => '==== Экран Airtime ====';

  @override
  String get airtimeAppBarTitle => 'Airtime';

  @override
  String get comment_airtime_amount_section => '==== Раздел суммы Airtime ====';

  @override
  String get airtimeCountryLabel => 'Страна';

  @override
  String get airtimeCountryHint => 'Выберите страну';

  @override
  String get airtimeCountrySelectTitle => 'Выберите страну';

  @override
  String get airtimeCountryNotFound => 'Страна не найдена';

  @override
  String get airtimeServiceLabel => 'Услуга';

  @override
  String get airtimeServiceHint => 'Выберите услугу';

  @override
  String get airtimeServiceSelectTitle => 'Выберите услугу';

  @override
  String get airtimeServiceNotFound => 'Услуга не найдена';

  @override
  String get airtimeAmountLabel => 'Сумма';

  @override
  String get airtimePayButton => 'Оплатить сейчас';

  @override
  String get comment_airtime_review_section =>
      '==== Раздел проверки Airtime ====';

  @override
  String get airtimeReviewTitle => 'Проверка деталей';

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
  String get comment_bill_payment_history => '==== История оплаты счетов ====';

  @override
  String get billPaymentHistoryTitle => 'История оплаты счетов';

  @override
  String get comment_bill_payment_details =>
      '==== Лист деталей оплаты счетов ====';

  @override
  String get billPaymentDetailsTitle => 'Детали оплаты счета';

  @override
  String get billPaymentDetailsTime => 'Время';

  @override
  String get billPaymentDetailsAmount => 'Сумма';

  @override
  String get billPaymentDetailsCharge => 'Комиссия';

  @override
  String get billPaymentDetailsMethod => 'Метод';

  @override
  String get billPaymentDetailsStatus => 'Статус';

  @override
  String get comment_cable_screen => '==== Экран кабельного ТВ ====';

  @override
  String get cableTitle => 'Кабельное ТВ';

  @override
  String get comment_cable_amount_section =>
      '==== Раздел суммы кабельного ТВ ====';

  @override
  String get cableCountryLabel => 'Страна';

  @override
  String get cableCountryHint => 'Выберите страну';

  @override
  String get cableCountrySelectTitle => 'Выберите страну';

  @override
  String get cableCountryNotFound => 'Страна не найдена';

  @override
  String get cableServiceLabel => 'Услуга';

  @override
  String get cableServiceHint => 'Выберите услугу';

  @override
  String get cableServiceSelectTitle => 'Выберите услугу';

  @override
  String get cableServiceNotFound => 'Услуга не найдена';

  @override
  String get cableAmountLabel => 'Сумма';

  @override
  String get cablePayButton => 'Оплатить сейчас';

  @override
  String get comment_cable_review_section =>
      '==== Раздел проверки кабельного ТВ ====';

  @override
  String get cableReviewTitle => 'Проверка деталей';

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
  String get comment_toll_screen => '==== Экран дорожных сборов ====';

  @override
  String get tollTitle => 'Дорожные сборы';

  @override
  String get comment_toll_amount_section =>
      '==== Раздел суммы дорожных сборов ====';

  @override
  String get tollCountryLabel => 'Страна';

  @override
  String get tollCountryHint => 'Выберите страну';

  @override
  String get tollCountrySelectTitle => 'Выберите страну';

  @override
  String get tollCountryNotFound => 'Страна не найдена';

  @override
  String get tollServiceLabel => 'Услуга';

  @override
  String get tollServiceHint => 'Выберите услугу';

  @override
  String get tollServiceSelectTitle => 'Выберите услугу';

  @override
  String get tollServiceNotFound => 'Услуга не найдена';

  @override
  String get tollAmountLabel => 'Сумма';

  @override
  String get tollPayButton => 'Оплатить сейчас';

  @override
  String get comment_toll_review_section =>
      '==== Раздел проверки дорожных сборов ====';

  @override
  String get tollReviewTitle => 'Проверка деталей';

  @override
  String get tollReviewAmountLabel => 'Сумма';

  @override
  String get tollReviewChargeLabel => 'Комиссия';

  @override
  String get tollReviewConversionRateLabel => 'Курс конвертации';

  @override
  String get tollReviewPayableAmountLabel => 'Сумма к оплате';

  @override
  String get tollReviewBackButton => 'Назад';

  @override
  String get tollReviewConfirmButton => 'Подтвердить';

  @override
  String get comment_electricity_screen => '==== Экран электроэнергии ====';

  @override
  String get electricityTitle => 'Электроэнергия';

  @override
  String get comment_electricity_amount_section =>
      '==== Раздел суммы электроэнергии ====';

  @override
  String get electricityCountryLabel => 'Страна';

  @override
  String get electricityCountryHint => 'Выберите страну';

  @override
  String get electricityCountrySelectTitle => 'Выберите страну';

  @override
  String get electricityCountryNotFound => 'Страна не найдена';

  @override
  String get electricityServiceLabel => 'Услуга';

  @override
  String get electricityServiceHint => 'Выберите услугу';

  @override
  String get electricityServiceSelectTitle => 'Выберите услугу';

  @override
  String get electricityServiceNotFound => 'Услуга не найдена';

  @override
  String get electricityAmountLabel => 'Сумма';

  @override
  String get electricityPayButton => 'Оплатить сейчас';

  @override
  String get comment_electricity_review_section =>
      '==== Раздел проверки электроэнергии ====';

  @override
  String get electricityReviewTitle => 'Проверка деталей';

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
  String get comment_internet_screen => '==== Экран интернета ====';

  @override
  String get internetTitle => 'Интернет';

  @override
  String get comment_internet_amount_section =>
      '==== Раздел суммы интернета ====';

  @override
  String get internetCountryLabel => 'Страна';

  @override
  String get internetCountryHint => 'Выберите страну';

  @override
  String get internetCountrySelectTitle => 'Выберите страну';

  @override
  String get internetCountryNotFound => 'Страна не найдена';

  @override
  String get internetServiceLabel => 'Услуга';

  @override
  String get internetServiceHint => 'Выберите услугу';

  @override
  String get internetServiceSelectTitle => 'Выберите услугу';

  @override
  String get internetServiceNotFound => 'Услуга не найдена';

  @override
  String get internetAmountLabel => 'Сумма';

  @override
  String get internetPayButton => 'Оплатить сейчас';

  @override
  String get comment_internet_review_section =>
      '==== Раздел проверки интернета ====';

  @override
  String get internetReviewTitle => 'Проверка деталей';

  @override
  String get internetReviewAmountLabel => 'Сумма';

  @override
  String get internetReviewChargeLabel => 'Комиссия';

  @override
  String get internetReviewConversionRateLabel => 'Курс конвертации';

  @override
  String get internetReviewPayableAmountLabel => 'Сумма к оплате';

  @override
  String get internetReviewBackButton => 'Назад';

  @override
  String get internetReviewConfirmButton => 'Подтвердить';

  @override
  String get comment_data_bundle_screen => '==== Экран пакета данных ====';

  @override
  String get dataBundleTitle => 'Пакет данных';

  @override
  String get comment_data_bundle_amount_section =>
      '==== Раздел суммы пакета данных ====';

  @override
  String get dataBundleCountryLabel => 'Страна';

  @override
  String get dataBundleCountryHint => 'Выберите страну';

  @override
  String get dataBundleCountrySelectTitle => 'Выберите страну';

  @override
  String get dataBundleCountryNotFound => 'Страна не найдена';

  @override
  String get dataBundleServiceLabel => 'Услуга';

  @override
  String get dataBundleServiceHint => 'Выберите услугу';

  @override
  String get dataBundleServiceSelectTitle => 'Выберите услугу';

  @override
  String get dataBundleServiceNotFound => 'Услуга не найдена';

  @override
  String get dataBundleAmountLabel => 'Сумма';

  @override
  String get dataBundlePayButton => 'Оплатить сейчас';

  @override
  String get comment_data_bundle_review_section =>
      '==== Раздел проверки пакета данных ====';

  @override
  String get dataBundleReviewTitle => 'Проверка деталей';

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
      '==== Главный экран оплаты счетов ====';

  @override
  String get billPaymentScreenTitle => 'Оплата счетов';

  @override
  String get billPaymentAirtime => 'Airtime';

  @override
  String get billPaymentElectricity => 'Электроэнергия';

  @override
  String get billPaymentInternet => 'Интернет';

  @override
  String get billPaymentDataBundle => 'Пакет данных';

  @override
  String get billPaymentCables => 'Кабельное ТВ';

  @override
  String get billPaymentToll => 'Дорожные сборы';

  @override
  String get comment_create_virtual_card_controller =>
      '==== Контроллер создания виртуальной карты ====';

  @override
  String get createCardProviderRequired =>
      'Пожалуйста, выберите провайдера карты';

  @override
  String get createCardHolderRequired => 'Пожалуйста, выберите держателя карты';

  @override
  String get createNameRequired => 'Пожалуйста, введите имя';

  @override
  String get createEmailRequired => 'Пожалуйста, введите email';

  @override
  String get createEmailInvalid => 'Пожалуйста, введите действительный email';

  @override
  String get createPhoneNumberRequired => 'Пожалуйста, введите номер телефона';

  @override
  String get createCountryRequired => 'Пожалуйста, выберите страну';

  @override
  String get createCityRequired => 'Пожалуйста, введите город';

  @override
  String get createStateRequired => 'Пожалуйста, введите штат/область';

  @override
  String get createPostalCodeRequired => 'Пожалуйста, введите почтовый индекс';

  @override
  String get createAddressRequired => 'Пожалуйста, введите адрес';

  @override
  String get comment_virtual_card_details_controller =>
      '==== Контроллер деталей виртуальной карты ====';

  @override
  String get cardDetailsEnterAmount => 'Пожалуйста, введите сумму';

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
      '==== Раздел вкладки держателя карты ====';

  @override
  String get cardHolderTabExistingCardholders => 'Существующие держатели карт';

  @override
  String get cardHolderTabCreateCardholder => 'Создать держателя карты';

  @override
  String get comment_choose_card_holder_section =>
      '==== Раздел выбора держателя карты ====';

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
      '==== Раздел выбора провайдера карты ====';

  @override
  String get chooseCardProviderLabel => 'Провайдер карты';

  @override
  String get chooseCardProviderDropdownNotFound => 'Провайдер карты не найден';

  @override
  String get chooseCardProviderDropdownTitle => 'Выберите провайдера карты';

  @override
  String get comment_create_new_card_holder_section =>
      '==== Раздел создания нового держателя карты ====';

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
  String get createCardHolderLabelState => 'Штат/область';

  @override
  String get createCardHolderLabelPostalCode => 'Почтовый индекс';

  @override
  String get createCardHolderLabelAddress => 'Адрес';

  @override
  String get createCardHolderButtonCreate => 'Создать сейчас';

  @override
  String get comment_create_virtual_card_screen =>
      '==== Экран создания виртуальной карты ====';

  @override
  String get createVirtualCardAppBarTitle => 'Создать новую карту';

  @override
  String get comment_get_card_info_screen =>
      '==== Экран информации о карте ====';

  @override
  String get getCardInfoAppBarTitle => 'Получить карту';

  @override
  String get getCardInfoBenefitsTitle => 'Преимущества виртуальных карт';

  @override
  String get getCardInfoBenefitSecurityTitle => 'Лучшая безопасность';

  @override
  String get getCardInfoBenefitSecuritySubtitle =>
      'Ваш реальный номер карты остается скрытым';

  @override
  String get getCardInfoBenefitShoppingTitle => 'Безопасные онлайн-покупки';

  @override
  String get getCardInfoBenefitShoppingSubtitle =>
      'Создавайте виртуальные карты только для онлайн-покупок';

  @override
  String get getCardInfoBenefitActivationTitle => 'Быстрая и простая активация';

  @override
  String get getCardInfoBenefitActivationSubtitle =>
      'Не требуется физическая доставка';

  @override
  String get getCardInfoButtonContinue => 'Продолжить';

  @override
  String get comment_card_details_info =>
      '==== Информация о деталях карты ====';

  @override
  String get cardDetailsInfoTitle => 'Детали карты';

  @override
  String get cardDetailsCardTypeLabel => 'Тип карты';

  @override
  String get cardDetailsCardTypeValue => 'Виртуальная';

  @override
  String get cardDetailsBillingAddressLabel => 'Платежный адрес';

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
      '==== Нижний лист пополнения карты ====';

  @override
  String get cardTopUpTitle => 'Пополнение баланса карты';

  @override
  String get cardTopUpMainWalletBalance => 'Баланс основного кошелька';

  @override
  String get cardTopUpLabelAmount => 'Сумма';

  @override
  String cardTopUpAmountLimits(Object currency, Object max, Object min) {
    return 'Минимум $min $currency Максимум $max $currency';
  }

  @override
  String get cardTopUpReviewTopupAmount => 'Сумма пополнения';

  @override
  String get cardTopUpReviewTopupCharge => 'Комиссия пополнения';

  @override
  String get cardTopUpReviewTotalTopupBalance => 'Итоговая сумма';

  @override
  String get cardTopUpButtonTopupNow => 'Пополнить сейчас';

  @override
  String get bsicardsTopUpInfoMessage =>
      'Пожалуйста, отправьте средства на указанный крипто-адрес. После подтверждения транзакции баланс будет добавлен на вашу карту.';

  @override
  String get bsicardsTopUpCopyButton => 'Скопировать';

  @override
  String get bsicardsTopUpCopySuccess => 'Адрес скопирован';

  @override
  String get comment_virtual_card_display =>
      '==== Отображение виртуальной карты ====';

  @override
  String get virtualCardExpiryDateLabel => 'Дата истечения';

  @override
  String get virtualCardCvcLabel => 'CVC';

  @override
  String get comment_virtual_card_details_screen =>
      '==== Экран деталей виртуальной карты ====';

  @override
  String get virtualCardDetailsAppBarTitle => 'Детали виртуальной карты';

  @override
  String get virtualCardDetailsFloatingButton => 'Добавить баланс';

  @override
  String get comment_virtual_card_transaction_screen =>
      '==== Экран транзакций карты ====';

  @override
  String get virtualCardTransactionAppBarTitle => 'Транзакции карты';

  @override
  String get virtualCardTransactionSyncButton => 'Синхронизировать';

  @override
  String get comment_virtual_card_screen => '==== Экран виртуальных карт ====';

  @override
  String get virtualCardScreenAppBarTitle => 'Виртуальные карты';

  @override
  String get virtualCardCardExpiryDateLabel => 'Дата истечения';

  @override
  String get virtualCardCardCvcLabel => 'CVC';

  @override
  String get virtualCardCreateCardTitle =>
      'Создайте виртуальную карту, чтобы начать';

  @override
  String get virtualCardCreateCardButton => 'Создать карту';

  @override
  String get comment_verify_passcode_controller =>
      '==== Контроллер проверки пароля ====';

  @override
  String get verifyPasscodeValidationEnterPasscode =>
      'Пожалуйста, введите ваш пароль';

  @override
  String get comment_change_passcode_bottom_sheet =>
      '==== Нижний лист смены пароля ====';

  @override
  String get changePasscodeTitle => 'Сменить пароль';

  @override
  String get changePasscodeLabelOldPasscode => 'Старый пароль';

  @override
  String get changePasscodeLabelNewPasscode => 'Новый пароль';

  @override
  String get changePasscodeLabelConfirmPasscode => 'Подтвердите пароль';

  @override
  String get changePasscodeButtonChange => 'Сменить пароль';

  @override
  String get comment_disable_and_change_passcode_section =>
      '==== Раздел отключения и смены пароля ====';

  @override
  String get disableChangePasscodeTitle => 'Пароль';

  @override
  String get disableChangePasscodeButtonChange => 'Сменить пароль';

  @override
  String get disableChangePasscodeButtonDisable => 'Отключить пароль';

  @override
  String get comment_disable_passcode_bottom_sheet =>
      '==== Нижний лист отключения пароля ====';

  @override
  String get disablePasscodeTitle => 'Отключить пароль';

  @override
  String get disablePasscodeLabelPassword => 'Пароль';

  @override
  String get disablePasscodeButtonDisable => 'Отключить пароль';

  @override
  String get comment_generate_passcode_bottom_sheet =>
      '==== Нижний лист генерации пароля ====';

  @override
  String get generatePasscodeTitle => 'Добавить пароль';

  @override
  String get generatePasscodeLabelPasscode => 'Пароль';

  @override
  String get generatePasscodeLabelConfirmPasscode => 'Подтвердите пароль';

  @override
  String get generatePasscodeButtonConfirm => 'Подтвердить';

  @override
  String get comment_generate_passcode_section =>
      '==== Раздел генерации пароля ====';

  @override
  String get generatePasscodeSectionTitle => 'Пароль';

  @override
  String get generatePasscodeSectionDescription =>
      'Создайте безопасный пароль для быстрого доступа к аккаунту';

  @override
  String get generatePasscodeSectionButtonGenerate => 'Сгенерировать пароль';

  @override
  String get comment_verify_passcode_bottom_sheet =>
      '==== Нижний лист проверки пароля ====';

  @override
  String get verifyPasscodeTitle => 'Подтвердите ваш пароль';

  @override
  String get verifyPasscodeLabelPasscode => 'Пароль';

  @override
  String get verifyPasscodeButtonConfirm => 'Подтвердить';

  @override
  String get comment_payment_links_amount_section =>
      '==== Раздел суммы платежных ссылок ====';

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
      '==== Раздел создания платежных ссылок ====';

  @override
  String get paymentLinksInstructionText =>
      'Вы можете создать платежную ссылку без указания суммы или валюты. Плательщик сможет заполнить данные при оплате.';

  @override
  String get comment_payment_links_header_section =>
      '==== Раздел заголовка платежных ссылок ====';

  @override
  String get paymentLinksAppBarTitle => 'Платежные ссылки';

  @override
  String get paymentLinksTabList => 'Список';

  @override
  String get paymentLinksTabCreate => 'Создать';

  @override
  String get comment_payment_links_history_filter_bottom_sheet =>
      '==== Нижний лист фильтра истории платежных ссылок ====';

  @override
  String get paymentLinksFilterNumberLabel => 'Номер';

  @override
  String get paymentLinksFilterButton => 'Фильтровать';

  @override
  String get comment_payment_links_list_section =>
      '==== Раздел списка платежных ссылок ====';

  @override
  String get paymentLinksListItemCreatedAt => 'Создано: ';

  @override
  String get paymentLinksListItemStatus => 'Статус: ';

  @override
  String get paymentLinksStatusPaid => 'Оплачено';

  @override
  String get paymentLinksStatusUnpaid => 'Не оплачено';

  @override
  String get paymentLinksCopySuccessToast => 'Код платежной ссылки скопирован';

  @override
  String get comment_gift_card_header_section =>
      '---- Раздел заголовка подарочной карты ----';

  @override
  String get giftCardHeaderTitle => 'Подарочная карта';

  @override
  String get giftCardHeaderTabCards => 'Карты';

  @override
  String get giftCardHeaderTabHistory => 'История';

  @override
  String get comment_gift_card_history_filter_bottom_sheet =>
      '---- Нижний лист фильтра истории подарочных карт ----';

  @override
  String get giftCardHistoryFilterSearchLabel => 'Поиск';

  @override
  String get giftCardHistoryFilterSearchButton => 'Поиск';

  @override
  String get comment_gift_card_filter_bottom_sheet =>
      '---- Нижний лист фильтра подарочных карт ----';

  @override
  String get giftCardFilterGiftCardLabel => 'Подарочная карта';

  @override
  String get giftCardFilterCountryLabel => 'Страна';

  @override
  String get giftCardFilterCountrySelectTitle => 'Выберите страну';

  @override
  String get giftCardFilterAllOption => 'Все';

  @override
  String get giftCardFilterCountryNotFound => 'Страна не найдена';

  @override
  String get giftCardFilterCategoryLabel => 'Категория';

  @override
  String get giftCardFilterCategorySelectTitle => 'Выберите категорию';

  @override
  String get giftCardFilterCategoryNotFound => 'Категория не найдена';

  @override
  String get giftCardFilterSearchButton => 'Поиск';

  @override
  String get comment_gift_card_history_details =>
      '---- Детали истории подарочных карт ----';

  @override
  String get giftCardHistoryDetailsTitle => 'Детали транзакции';

  @override
  String giftCardHistoryQtyLabel(Object qty) {
    return 'КОЛ-ВО : $qty';
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
      '---- Детали проверки подарочной карты ----';

  @override
  String get giftCardReviewDetailsTitle => 'Проверка деталей';

  @override
  String get giftCardSubTotalLabel => 'Промежуточный итог';

  @override
  String get giftCardTotalFeeLabel => 'Общая комиссия';

  @override
  String get giftCardTotalLabel => 'Итого';

  @override
  String get giftCardReviewBackButton => 'Назад';

  @override
  String get giftCardReviewPayNowButton => 'Оплатить сейчас';

  @override
  String get comment_gift_card_success_section =>
      '---- Раздел успеха подарочной карты ----';

  @override
  String get giftCardSuccessTitle => 'Заказ подарочной карты успешно размещен!';

  @override
  String get giftCardSuccessGiftCardsButton => 'Подарочные карты';

  @override
  String get giftCardSuccessBackHomeButton => 'На главную';

  @override
  String get comment_gift_card_amount_validation =>
      '---- Валидация суммы контроллера подарочной карты ----';

  @override
  String get giftCardAmountRequired => 'Пожалуйста, введите сумму';

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
      '---- Валидация пользователя контроллера подарочной карты ----';

  @override
  String get giftCardEmailRequired => 'Пожалуйста, введите email';

  @override
  String get giftCardEmailInvalid => 'Пожалуйста, введите действительный email';

  @override
  String get giftCardCountryRequired => 'Пожалуйста, выберите страну';

  @override
  String get giftCardPhoneRequired => 'Пожалуйста, введите телефон';

  @override
  String get giftCardNameRequired => 'Пожалуйста, введите имя';

  @override
  String get comment_gift_card_details_section =>
      '---- Раздел деталей подарочной карты ----';

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
  String get giftCardSelectCountryTitle => 'Выберите страну';

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
  String get giftCardRedeemInstructionTitle => 'Инструкция по погашению';

  @override
  String get comment_p2p => '==== P2P ====';

  @override
  String get p2pMyOrder => 'Мой заказ';

  @override
  String get p2pPaymentAccount => 'Платежный аккаунт';

  @override
  String get p2pCreateAd => 'Создать объявление';

  @override
  String get p2pApplyVerification => 'Подать заявку на верификацию';

  @override
  String get p2pP2p => 'P2P';

  @override
  String get p2pMyOrders => 'Мои заказы';

  @override
  String get p2pPaymentAccounts => 'Платежные аккаунты';

  @override
  String get p2pMyAds => 'Мои объявления';

  @override
  String get p2pSelectAsset => 'Выбрать актив';

  @override
  String get p2pSelectFiat => 'Выбрать фиат';

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
  String get p2pCompletion => 'Завершение';

  @override
  String get p2pLimit => 'Лимит';

  @override
  String get p2pAvailable => 'Доступно';

  @override
  String get p2pOrderDetails => 'Детали заказа';

  @override
  String get p2pNoOrderDetailsFound => 'Детали заказа не найдены';

  @override
  String get p2pNoAdDetailsFound => 'Детали объявления не найдены';

  @override
  String get p2pPrice => 'Цена';

  @override
  String get p2pOrderLimit => 'Лимит заказа';

  @override
  String get p2pYouPay => 'Вы платите';

  @override
  String get p2pYouSell => 'Вы продаете';

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
      'Условия рекламодателей (пожалуйста, прочитайте внимательно)';

  @override
  String get p2pPaymentTimeLimit => 'Лимит времени оплаты';

  @override
  String get p2pAvgReleaseTime => 'Среднее время выпуска';

  @override
  String get p2pNoTermsProvided => 'Условия не предоставлены';

  @override
  String get p2pOrderNumber => 'Номер заказа';

  @override
  String get p2pSearchOrderNumber => 'Поиск номера заказа';

  @override
  String get p2pOrderNumberCopied => 'Номер заказа скопирован';

  @override
  String get p2pCopied => 'Скопировано';

  @override
  String get p2pOrderCreated => 'Заказ создан';

  @override
  String get p2pFiatAmount => 'Сумма в фиате';

  @override
  String get p2pReceiveQuantity => 'Получить количество';

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
  String get p2pEnterDisputeReason => 'Введите причину спора';

  @override
  String get p2pWriteYourReason => 'Напишите вашу причину...';

  @override
  String get p2pEnterReason => 'Введите причину';

  @override
  String get p2pReasonIsRequired => 'Причина обязательна';

  @override
  String get p2pCancelOrderConfirmation =>
      'Вы уверены, что хотите отменить этот заказ?';

  @override
  String get p2pOrderCompleted => 'Заказ завершен';

  @override
  String get p2pOrderCancelled => 'Заказ отменен';

  @override
  String get p2pPendingRelease => 'Ожидает выпуска';

  @override
  String get p2pOrderDisputed => 'Заказ оспорен';

  @override
  String get p2pOrderExpired => 'Заказ истек';

  @override
  String get p2pBuyerMarkedAsPaid => 'Покупатель отметил как оплаченный';

  @override
  String get p2pOrderCreatedPayTheSellerWithin =>
      'Заказ создан, оплатите продавцу в течение';

  @override
  String get p2pBuyerHasNotPaidYetPaymentDueWithin =>
      'Покупатель еще не оплатил. Оплата должна быть произведена в течение';

  @override
  String get p2pSellerFundsLockedInEscrow =>
      'Средства продавца заблокированы в эскроу. Наша служба поддержки рассмотрит доказательства и ответит в ближайшее время.';

  @override
  String get p2pYourLockedAssetsInEscrow =>
      'Ваши заблокированные активы находятся в эскроу. Наша служба поддержки рассмотрит этот спор в ближайшее время.';

  @override
  String get p2pPaymentNotCompletedInAllowedTime =>
      'Вы не завершили оплату в отведенное время.';

  @override
  String get p2pBuyerDidNotCompletePaymentInAllowedTime =>
      'Покупатель не завершил оплату в отведенное время.';

  @override
  String p2pConfirmPaymentFrom(Object name) {
    return 'Подтвердите, что платеж от (покупатель: $name)';
  }

  @override
  String get p2pVerifyAmountAndSender =>
      'Пожалуйста, проверьте сумму и данные отправителя в вашем аккаунте, затем продолжите действие выпуска.';

  @override
  String get p2pTransferFundsToSeller =>
      'Переведите средства на счет продавца, указанный ниже.';

  @override
  String get p2pNotifySeller => 'Уведомить продавца';

  @override
  String get p2pConfirmPaymentReceived => 'Подтвердить получение оплаты';

  @override
  String get p2pConfirmPaymentReceivedDescription =>
      'После подтверждения получения оплаты нажмите кнопку «Оплата получена» ниже.';

  @override
  String get p2pNotifySellerDescription =>
      'После оплаты не забудьте нажать кнопку «Переведено, уведомить продавца» для выпуска криптовалюты продавцом.';

  @override
  String get p2pAllAccount => 'Все аккаунты';

  @override
  String get p2pAddPaymentMethod => 'Добавить способ оплаты';

  @override
  String get p2pEdit => 'Редактировать';

  @override
  String get p2pEditPaymentAccount => 'Редактировать платежный аккаунт';

  @override
  String get p2pUpdateAccount => 'Обновить аккаунт';

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
  String get p2pIWantToBuy => 'Я хочу купить';

  @override
  String get p2pIWantToSell => 'Я хочу продать';

  @override
  String get p2pAsset => 'Актив';

  @override
  String get p2pWithFiat => 'С фиатом';

  @override
  String get p2pPriceType => 'Тип цены';

  @override
  String get p2pYourPrice => 'Ваша цена';

  @override
  String get p2pHighestOrderPrice => 'Самая высокая цена заказа';

  @override
  String get p2pTotalAmount => 'Итоговая сумма';

  @override
  String get p2pSelectAtLeastOnePaymentMethod =>
      'Выберите хотя бы один способ оплаты';

  @override
  String get p2pAdd => 'Добавить';

  @override
  String get p2pMinutes => 'Минуты';

  @override
  String get p2pTerms => 'Условия';

  @override
  String get p2pAutomaticReply => 'Автоматический ответ';

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
  String get p2pAdSuccessfullyPosted => 'Объявление успешно опубликовано';

  @override
  String get p2pAdsSubmittedUnderReview =>
      'Объявления отправлены и находятся на проверке.';

  @override
  String get p2pAdPublishedDescription =>
      'Ваше объявление опубликовано, пользователи могут размещать заказы. Следите за новыми заказами.';

  @override
  String get p2pAdUnderReviewDescription =>
      'Ваше объявление на проверке. После одобрения оно будет опубликовано, и пользователи смогут размещать заказы. Следите за новыми заказами.';

  @override
  String get p2pAdNumber => 'Номер объявления';

  @override
  String get p2pMethod => 'Метод';

  @override
  String get p2pGoToMyAds => 'Перейти к моим объявлениям';

  @override
  String get p2pEligibilityValidationFailed => 'Проверка eligibility не прошла';

  @override
  String get p2pPleaseFulfillRequirements =>
      'Пожалуйста, выполните следующие требования:';

  @override
  String get p2pNotEligibleCreateAd =>
      'Вы в настоящее время не можете создавать объявления.';

  @override
  String get p2pCompletedTradeQty => 'Завершенные сделки (кол-во)';

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
  String get p2pCryptoAmount => 'Сумма криптовалюты';

  @override
  String get p2pCounterparty => 'Контрагент';

  @override
  String get p2pChat => 'Чат';

  @override
  String get p2pNoMessagesYet => 'Сообщений пока нет';

  @override
  String get p2pTypeYourMessage => 'Введите ваше сообщение...';

  @override
  String get p2pCamera => 'Камера';

  @override
  String get p2pGallery => 'Галерея';

  @override
  String get p2pAttachment => 'Вложение';

  @override
  String get p2pUser => 'Пользователь';

  @override
  String get p2pYouAreVerifiedTrader =>
      'Вы являетесь верифицированным трейдером';

  @override
  String get p2pVerifiedTraderStatusActive =>
      'Ваш статус верифицированного трейдера активен.';

  @override
  String get p2pVerificationUnderReview => 'Верификация на проверке';

  @override
  String get p2pVerificationRequestUnderReview =>
      'Ваша заявка на верификацию сейчас на проверке.';

  @override
  String get p2pSubmittedOn => 'Отправлено';

  @override
  String get p2pVerificationDataUnavailable => 'Данные верификации недоступны';

  @override
  String get p2pPleaseRefreshAndTryAgain =>
      'Пожалуйста, обновите и попробуйте снова.';

  @override
  String get p2pPreviousVerificationRejected =>
      'Предыдущая заявка на верификацию была отклонена';

  @override
  String get p2pReason => 'Причина';

  @override
  String get p2pCorrectInformationApplyAgain =>
      'Пожалуйста, исправьте информацию и подайте заявку снова.';

  @override
  String get p2pApplyVerificationTitle => 'Подать заявку на верификацию';

  @override
  String get p2pFillRequiredFieldsVerification =>
      'Заполните все обязательные поля для отправки верификации.';

  @override
  String get p2pNoVerificationFormFieldsFound =>
      'Поля формы верификации не найдены.';

  @override
  String get p2pSubmitVerification => 'Отправить верификацию';

  @override
  String p2pEnterField(Object field) {
    return 'Введите $field';
  }

  @override
  String get edit_my_ad => 'Редактировать мое объявление';

  @override
  String get amount => 'Сумма';

  @override
  String get total_amount => 'Итоговая сумма';

  @override
  String get min_amount => 'Минимальная сумма';

  @override
  String get max_amount => 'Максимальная сумма';

  @override
  String get payment_duration => 'Срок оплаты';

  @override
  String get payment_method => 'Способ оплаты';

  @override
  String get no_payment_method => 'Способ оплаты не найден';

  @override
  String get terms => 'Условия';

  @override
  String get auto_response => 'Сообщение автоответа';

  @override
  String get update => 'Обновить';

  @override
  String get error_ad_invalid => 'Данные объявления недействительны';

  @override
  String get error_amount_zero => 'Сумма не может быть нулевой';

  @override
  String get error_total_amount_zero => 'Итоговая сумма не может быть нулевой';

  @override
  String get error_min_zero => 'Минимальная сумма не может быть нулевой';

  @override
  String get error_max_zero => 'Максимальная сумма не может быть нулевой';

  @override
  String get error_min_greater =>
      'Минимальная сумма не может быть больше максимальной';

  @override
  String get error_payment_duration_zero => 'Срок оплаты не может быть нулевым';

  @override
  String get error_select_payment => 'Пожалуйста, выберите способ оплаты';

  @override
  String get error_terms_empty => 'Условия не могут быть пустыми';

  @override
  String get error_select_asset => 'Пожалуйста, выберите актив';

  @override
  String get error_select_fiat => 'Пожалуйста, выберите фиат';

  @override
  String get error_select_price_type => 'Пожалуйста, выберите тип цены';

  @override
  String get error_price_zero => 'Цена не может быть нулевой';

  @override
  String get error_enter_total_amount => 'Пожалуйста, введите итоговую сумму';

  @override
  String get error_enter_min_order =>
      'Пожалуйста, введите минимальный лимит заказа';

  @override
  String get error_enter_max_order =>
      'Пожалуйста, введите максимальный лимит заказа';

  @override
  String get error_payment_time_zero => 'Время оплаты не может быть нулевым';

  @override
  String get error_enter_terms => 'Пожалуйста, введите условия';

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
  String get selectStatus => 'Выбрать статус';

  @override
  String get selectType => 'Выбрать тип';

  @override
  String get selectFiatCurrency => 'Выбрать фиатную валюту';

  @override
  String get selectAssetCurrency => 'Выбрать валюту актива';

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
  String get filterPaymentAccount => 'Фильтр платежного аккаунта';

  @override
  String get filterMyOrder => 'Фильтр моих заказов';

  @override
  String get comment_travel => '==== eCardo Travel ====';

  @override
  String get travelTitle => 'eCardo Travel';

  @override
  String get travelHeroEyebrow => 'A better travel experience';

  @override
  String get travelHeroTitle => 'Book your next journey today';

  @override
  String get travelFlights => 'Flights';

  @override
  String get travelHotels => 'Hotels';

  @override
  String get travelEsim => 'eSIM';

  @override
  String get travelRecentActivity => 'Recent activity';

  @override
  String get travelViewAll => 'View all';

  @override
  String get travelMainWallet => 'Main eCardo wallet';

  @override
  String get travelWalletSharedDescription =>
      'The same secure wallet you use across eCardo';

  @override
  String get travelHotelSearch => 'Hotel search';

  @override
  String get travelHotelHero => 'Stay somewhere unforgettable';

  @override
  String get travelDestinationCountry => 'Destination country';

  @override
  String get travelDestinationCity => 'City';

  @override
  String get travelCheckIn => 'Check-in';

  @override
  String get travelCheckOut => 'Check-out';

  @override
  String get travelGuests => 'Guests';

  @override
  String get travelSearchHotels => 'Search hotels';

  @override
  String get travelRecentSearches => 'Recent searches';

  @override
  String get travelHotelResults => 'Hotel results';

  @override
  String get travelNoHotelResults => 'No matching hotels were found.';

  @override
  String get travelStartingPrice => 'Starting price per stay';

  @override
  String get travelViewDetails => 'View details';

  @override
  String get travelHotelDetails => 'Hotel details';

  @override
  String get travelOfferUnavailable => 'This offer is no longer available.';

  @override
  String get travelReserveHotel => 'Reserve hotel';

  @override
  String get travelIncluded => 'Included';

  @override
  String get travelFree => 'Free';

  @override
  String get travelAboutHotel => 'About the hotel';

  @override
  String get travelHotelDescription =>
      'A refined city stay with comfortable rooms, attentive service and convenient access to major attractions. Final room content and policies will be supplied by the eCardo Travel API.';

  @override
  String get travelPolicies => 'Policies';

  @override
  String get travelCancellation => 'Cancellation';

  @override
  String get travelCancellationSummary =>
      'Free cancellation before the stated deadline';

  @override
  String get travelFlightSearch => 'Flight search';

  @override
  String get travelFlightHero => 'Your dream journey starts here';

  @override
  String get travelOrigin => 'Origin';

  @override
  String get travelDestination => 'Destination';

  @override
  String get travelDepartureDate => 'Departure date';

  @override
  String get travelAdults => 'Adults';

  @override
  String get travelChildren => 'Children';

  @override
  String get travelSearchFlights => 'Search flights';

  @override
  String get travelFlightResults => 'Flight results';

  @override
  String get travelNoFlightResults => 'No matching flights were found.';

  @override
  String get travelSelectFlight => 'Select flight';

  @override
  String get travelFlightDetails => 'Flight and passenger details';

  @override
  String get travelContinueToPayment => 'Continue to payment';

  @override
  String get travelPassengerReview => 'Passenger review';

  @override
  String get travelPrimaryPassenger => 'Primary passenger';

  @override
  String get travelPassengerFromProfile =>
      'Details are shared from your eCardo profile';

  @override
  String get travelFareDetails => 'Fare details';

  @override
  String get travelBaseFare => 'Base fare';

  @override
  String get travelTaxesAndFees => 'Taxes and fees';

  @override
  String get travelTotal => 'Total';

  @override
  String get travelBrowseEsimPackages => 'Browse eSIM packages';

  @override
  String get travelEsimIntroTitle => 'Stay connected wherever you travel';

  @override
  String get travelEsimIntroDescription =>
      'Choose a digital data package, pay from your main eCardo wallet and activate it without replacing your physical SIM.';

  @override
  String get travelEsimInstantTitle => 'Instant delivery';

  @override
  String get travelEsimInstantDescription =>
      'Activation details are available immediately after payment.';

  @override
  String get travelEsimCoverageTitle => 'Travel-ready coverage';

  @override
  String get travelEsimCoverageDescription =>
      'Choose local or global packages for your destination.';

  @override
  String get travelEsimTransparentTitle => 'Transparent pricing';

  @override
  String get travelEsimTransparentDescription =>
      'See the backend-confirmed total before you pay.';

  @override
  String get travelEsimPackages => 'eSIM packages';

  @override
  String get travelChoosePackage => 'Choose a package';

  @override
  String get travelMostPopular => 'Most popular';

  @override
  String get travelSelect => 'Select';

  @override
  String travelValidityDays(int days) {
    return '$days days validity';
  }

  @override
  String get travelWalletCheckout => 'Wallet checkout';

  @override
  String get travelBackendConfirmedPrice => 'Price confirmed by eCardo Travel';

  @override
  String get travelPaymentMethod => 'Payment method';

  @override
  String get travelAvailableBalance => 'Available balance';

  @override
  String get travelInsufficientBalance =>
      'Your main wallet balance is insufficient. Add money, then return to refresh checkout.';

  @override
  String get travelPriceSummary => 'Price summary';

  @override
  String get travelSubtotal => 'Subtotal';

  @override
  String get travelWalletPayment => 'Wallet payment';

  @override
  String get travelCheckoutSafetyNote =>
      'Payment is submitted once using an idempotent booking request.';

  @override
  String get travelPayFromWallet => 'Pay from wallet';

  @override
  String get travelAddMoney => 'Add money';

  @override
  String get travelPaymentFailed => 'Payment was not completed';

  @override
  String get travelPaymentFailedDescription =>
      'Your wallet was not treated as paid. Please review the booking and try again.';

  @override
  String get travelHotelVoucher => 'Hotel voucher';

  @override
  String get travelFlightTicket => 'Flight ticket';

  @override
  String get travelEsimActivation => 'eSIM activation';

  @override
  String get travelVoucherReady => 'Your confirmed hotel voucher is ready.';

  @override
  String get travelTicketReady => 'Your issued flight ticket is ready.';

  @override
  String get travelEsimReady => 'Your eSIM is active and ready to install.';

  @override
  String get travelPurchaseSuccessful => 'Purchase successful';

  @override
  String get travelReference => 'Reference';

  @override
  String get travelStatus => 'Status';

  @override
  String get travelActive => 'Active';

  @override
  String get travelConfirmed => 'Confirmed';

  @override
  String get travelCompleted => 'Completed';

  @override
  String get travelRefunded => 'Refunded';

  @override
  String get travelFailed => 'Failed';

  @override
  String get travelBookingFailed => 'Booking failed';

  @override
  String get travelBookingFailedDescription =>
      'This booking did not complete. Review the order status before trying another payment.';

  @override
  String get travelBookingRefunded => 'Booking refunded';

  @override
  String get travelBookingRefundedDescription =>
      'The payment for this booking has been returned to the wallet.';

  @override
  String get travelPendingConfirmation => 'Pending confirmation';

  @override
  String get travelHotelBookingSubmitted => 'Hotel booking submitted';

  @override
  String get travelHotelPendingConfirmationDescription =>
      'Payment was received. eCardo Travel is confirming the hotel with the authorized supplier before issuing your voucher.';

  @override
  String get travelPaidAmount => 'Paid amount';

  @override
  String get travelActivationDetails => 'Activation details';

  @override
  String get travelActivationInstructions =>
      'Open your device cellular settings, add an eSIM and use the secure installation details returned by the eCardo backend.';

  @override
  String get travelViewMyBookings => 'View my bookings';

  @override
  String get travelMyBookings => 'My bookings';

  @override
  String get travelAllBookings => 'All bookings';

  @override
  String get travelMyHotels => 'My hotels';

  @override
  String get travelMyFlights => 'My flights';

  @override
  String get travelMyEsims => 'My eSIMs';

  @override
  String get travelMyHotelsDescription => 'Confirmed stays and hotel vouchers';

  @override
  String get travelMyFlightsDescription => 'Booked flights and issued tickets';

  @override
  String get travelMyEsimsDescription => 'Active and previous data packages';

  @override
  String get travelNoBookings => 'You do not have any travel bookings yet.';

  @override
  String get travelNoHotels => 'You do not have any hotel bookings yet.';

  @override
  String get travelNoFlights => 'You do not have any flight bookings yet.';

  @override
  String get travelNoEsims => 'You do not have any eSIM purchases yet.';

  @override
  String get travelSavedTravelers => 'Saved travelers';

  @override
  String get travelNoTravelers => 'No saved travelers are available yet.';

  @override
  String get travelAddTraveler => 'Add traveler';

  @override
  String get travelEditTraveler => 'Edit traveler';

  @override
  String get travelTravelerFullName => 'Full name';

  @override
  String get travelPassportNumber => 'Passport number';

  @override
  String get travelNationalityCode => 'Nationality code';

  @override
  String get travelNationalityCodeInvalid => 'Enter a two-letter country code';

  @override
  String get travelFieldRequired => 'This field is required';

  @override
  String get travelSaveTraveler => 'Save traveler';

  @override
  String get travelAccount => 'Travel account';

  @override
  String get travelAccountHolder => 'eCardo member';

  @override
  String get travelMemberDescription =>
      'Shared profile, wallet and traveler information';

  @override
  String get travelMyBookingsDescription => 'Hotels, flights and active eSIMs';

  @override
  String get travelSavedTravelersDescription =>
      'Reuse passenger details securely';

  @override
  String get travelPersonalInformation => 'Personal information';

  @override
  String get travelPersonalInformationDescription =>
      'Manage details shared with Travel';

  @override
  String get travelHistory => 'Travel and wallet history';

  @override
  String get travelHistoryDescription =>
      'View purchases and wallet activity together';

  @override
  String get travelNoActivity => 'No travel or wallet activity is available.';

  @override
  String get travelMockIran => 'Iran';

  @override
  String get travelMockTehran => 'Tehran';

  @override
  String get travelMockGuests => '2 adults, 1 child';

  @override
  String get travelMockTehranHotels => 'Hotels in Tehran';

  @override
  String get travelMockHotelEspinas => 'Espinas Palace Hotel';

  @override
  String get travelMockHotelEspinasLocation => 'Saadat Abad, Tehran';

  @override
  String get travelMockHotelParsian => 'Parsian International Hotel';

  @override
  String get travelMockHotelParsianLocation => 'Valiasr Street, Tehran';

  @override
  String get travelMockHotelVisteria => 'Visteria Hotel';

  @override
  String get travelMockHotelVisteriaLocation => 'Tajrish, Tehran';

  @override
  String get travelMockTehranAirport => 'Tehran (THR)';

  @override
  String get travelMockIstanbulAirport => 'Istanbul (IST)';

  @override
  String get travelMockRouteTehranIstanbul => 'Tehran → Istanbul';

  @override
  String get travelMockFlightTehranIstanbul => 'Tehran to Istanbul';

  @override
  String get travelMockAirlineOne => 'eCardo Air';

  @override
  String get travelMockAirlineTwo => 'Atlas Airways';

  @override
  String get travelEsimTurkey => 'Turkey eSIM';

  @override
  String get travelRecommended => 'Recommended';

  @override
  String get travelBestValue => 'Best value';

  @override
  String get travelLuxury => 'Luxury';

  @override
  String get travelDirect => 'Direct';

  @override
  String get travelLowestPrice => 'Lowest price';

  @override
  String get travelFeatureBreakfast => 'Breakfast';

  @override
  String get travelFeaturePool => 'Pool';

  @override
  String get travelFeatureWifi => 'Wi-Fi';

  @override
  String get travelFeatureParking => 'Parking';

  @override
  String get travelFeatureAirportTransfer => 'Airport transfer';

  @override
  String get travelFeatureCabinBag => 'Cabin bag';

  @override
  String get travelFeatureRefundable => 'Refundable';

  @override
  String get travelActivityFlightPurchase => 'Flight purchase';

  @override
  String get travelActivityEsimPurchase => 'eSIM purchase';

  @override
  String get travelActivityWalletTopUp => 'Wallet top-up';

  @override
  String get travelDemoOffer => 'Demo offer';

  @override
  String get travelRequiresConfirmation => 'Confirmation required';

  @override
  String get travelHotelBooking => 'Hotel booking';
}
