// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get comment_common_maintenance => '==== 维护 ====';

  @override
  String get maintenanceTitle => '系统维护中';

  @override
  String get maintenanceSubtitle => '我们正在进行计划维护以改善您的体验。';

  @override
  String get comment_common_alert_bottom_sheet => '==== 警报底部表单 ====';

  @override
  String get alertBottonSheetConfirmButton => '确认';

  @override
  String get alertBottonSheetCancelButton => '取消';

  @override
  String get comment_all_controller_load_Error => '==== 所有控制器加载错误 ====';

  @override
  String get allControllerLoadError => '出了点问题！';

  @override
  String get comment_common_exit_application => '==== 退出应用 ====';

  @override
  String get exitApplicationTitle => '退出应用';

  @override
  String get exitApplicationMessage => '您确定要退出应用吗？';

  @override
  String get comment_common_dropdown => '==== 通用下拉菜单 ====';

  @override
  String get commonDropdownSelectGender => '选择性别';

  @override
  String get commonDropdownGender => '性别';

  @override
  String get commonDropdownGenderNotFound => '未找到性别';

  @override
  String get commonDropdownMale => '男';

  @override
  String get commonDropdownFemale => '女';

  @override
  String get commonDropdownOther => '其他';

  @override
  String get comment_welcome => '==== 欢迎页面 ====';

  @override
  String get welcomeTitle => '欢迎来到 Qunzo';

  @override
  String get welcomeDescription => 'Qunzo 为您提供多钱包管理、即时兑换和安全交易。';

  @override
  String get welcomeSignIn => '登录';

  @override
  String get welcomeCreateAccount => '创建账户';

  @override
  String get comment_sign_in => '==== 登录页面 ====';

  @override
  String get signInWelcomeBack => '欢迎回来！';

  @override
  String get signInSubtitle => '加入并立即掌控您的财务';

  @override
  String get signInEmail => '邮箱';

  @override
  String get signInPassword => '密码';

  @override
  String get signInForgotPassword => '忘记密码';

  @override
  String get signInButton => '登录';

  @override
  String get signInNotRegistered => '还未注册？ ';

  @override
  String get signInCreateAccount => '创建账户';

  @override
  String get signInBiometricErrorFirstTime => '首次请使用邮箱和密码登录';

  @override
  String get signInBiometricErrorNotEnabled => '您的生物识别未启用';

  @override
  String get signInRegistrationDisabled => '注册已禁用';

  @override
  String get signInValidationEmailRequired => '邮箱字段为必填';

  @override
  String get signInValidationPasswordRequired => '密码字段为必填';

  @override
  String get comment_two_factor_auth => '==== 双因素认证页面 ====';

  @override
  String get twoFactorAuthTitle => '验证双因素认证';

  @override
  String get twoFactorAuthSubtitle => '通过 Google Authenticator 应用输入验证码';

  @override
  String get twoFactorAuthEnterOtp => '输入 OTP';

  @override
  String get twoFactorAuthVerifyButton => '验证';

  @override
  String get twoFactorAuthBackTo => '返回？ ';

  @override
  String get twoFactorAuthSignIn => '登录';

  @override
  String get twoFactorAuthOtpRequired => 'OTP 字段为必填';

  @override
  String get comment_forgot_password => '==== 忘记密码页面 ====';

  @override
  String get forgotPasswordTitle => '重置您的密码';

  @override
  String get forgotPasswordSubtitle => '别担心！请输入您的邮箱以重置密码。';

  @override
  String get forgotPasswordEmail => '邮箱';

  @override
  String get forgotPasswordButton => '忘记密码';

  @override
  String get forgotPasswordBackTo => '返回？ ';

  @override
  String get forgotPasswordSignIn => '登录';

  @override
  String get forgotPasswordEmailRequired => '邮箱字段为必填';

  @override
  String get comment_forgot_password_pin_verification =>
      '==== 忘记密码 PIN 验证页面 ====';

  @override
  String get forgotPasswordPinVerifyTitle => '验证邮箱';

  @override
  String get forgotPasswordPinOtpSent => 'OTP 已发送至 ';

  @override
  String get forgotPasswordPinEnterOtp => '输入 OTP';

  @override
  String get forgotPasswordPinOtpCountdown => 'OTP 剩余';

  @override
  String get forgotPasswordPinVerifyButton => '验证 OTP';

  @override
  String get forgotPasswordPinDidNotReceive => '没有收到验证码？ ';

  @override
  String get forgotPasswordPinResend => '重新发送';

  @override
  String get forgotPasswordPinOtpRequired => 'OTP 字段为必填';

  @override
  String get comment_reset_password => '==== 重置密码页面 ====';

  @override
  String get resetPasswordTitle => '重置密码';

  @override
  String get resetPasswordSubtitle => '请输入您的密码并确认密码。';

  @override
  String get resetPasswordPassword => '密码';

  @override
  String get resetPasswordConfirmPassword => '确认密码';

  @override
  String get resetPasswordButton => '重置';

  @override
  String get resetPasswordAlreadyHaveAccount => '已有账户？ ';

  @override
  String get resetPasswordSignIn => '登录';

  @override
  String get resetPasswordValidationRequired => '密码为必填';

  @override
  String get resetPasswordValidationMinLength => '密码至少需要 8 个字符';

  @override
  String get resetPasswordValidationConfirmRequired => '请确认您的密码';

  @override
  String get resetPasswordValidationMismatch => '密码不匹配';

  @override
  String get comment_auth_id_verification => '==== 身份验证页面 ====';

  @override
  String get authIdVerificationInvalidFieldType => '无效的字段类型';

  @override
  String get authIdVerificationUnknownFieldType => '未知字段类型： ';

  @override
  String get comment_camera_type_section => '==== 相机类型部分 ====';

  @override
  String get cameraTypeBack => '返回';

  @override
  String get cameraTypeNotAvailable => '不可用';

  @override
  String get cameraTypeButton => '相机';

  @override
  String get cameraTypeSkip => '跳过';

  @override
  String get comment_file_type_section => '==== 文件类型部分 ====';

  @override
  String get fileTypeBack => '返回';

  @override
  String get fileTypeNotAvailable => '不可用';

  @override
  String get fileTypeChooseFile => '选择文件';

  @override
  String get fileTypeSkip => '跳过';

  @override
  String get comment_front_camera_type_section => '==== 前置相机类型部分 ====';

  @override
  String get frontCameraTypeBack => '返回';

  @override
  String get frontCameraTypeNotAvailable => '不可用';

  @override
  String get frontCameraTypeButton => '前置相机';

  @override
  String get frontCameraTypeSkip => '跳过';

  @override
  String get comment_kyc_submission_section => '==== KYC 提交部分 ====';

  @override
  String get kycSubmissionIdVerification => '身份验证';

  @override
  String get kycSubmissionSubmit => '提交';

  @override
  String get kycSubmissionNext => '下一步';

  @override
  String get kycSubmissionReUpload => '重新上传';

  @override
  String get kycSubmissionRetake => '重新拍摄';

  @override
  String get comment_email_screen => '==== 邮箱页面 ====';

  @override
  String get emailScreenCreateAccount => '创建您的账户';

  @override
  String get emailScreenSubtitle => '加入并立即掌控您的财务';

  @override
  String get emailScreenEmail => '邮箱';

  @override
  String get emailScreenContinue => '继续';

  @override
  String get emailScreenAlreadyHaveAccount => '已有账户？ ';

  @override
  String get emailScreenSignIn => '登录';

  @override
  String get emailScreenEmailRequired => '请输入邮箱';

  @override
  String get comment_personal_info_screen => '==== 个人信息页面 ====';

  @override
  String get personalInfoTitle => '您的信息';

  @override
  String get personalInfoSubtitle => '请输入您的法定信息以继续。';

  @override
  String get personalInfoFirstName => '名字';

  @override
  String get personalInfoLastName => '姓氏';

  @override
  String get personalInfoUserName => '用户名';

  @override
  String get personalInfoCountry => '国家';

  @override
  String get personalInfoSelectCountry => '选择国家';

  @override
  String get personalInfoPhoneNo => '电话号码';

  @override
  String get personalInfoReferralCode => '推荐码';

  @override
  String get personalInfoContinue => '继续';

  @override
  String get personalInfoValidationFirstNameRequired => '名字为必填';

  @override
  String get personalInfoValidationLastNameRequired => '姓氏为必填';

  @override
  String get personalInfoValidationUserNameRequired => '用户名为必填';

  @override
  String get personalInfoValidationCountryRequired => '国家为必填';

  @override
  String get personalInfoValidationPhoneRequired => '电话号码为必填';

  @override
  String get personalInfoValidationReferralCodeRequired => '推荐码为必填';

  @override
  String get personalInfoValidationGenderRequired => '性别为必填';

  @override
  String get comment_setup_password_screen => '==== 设置密码页面 ====';

  @override
  String get setupPasswordTitle => '设置密码';

  @override
  String get setupPasswordSubtitle => '创建强密码并确认';

  @override
  String get setupPasswordPassword => '密码';

  @override
  String get setupPasswordConfirmPassword => '确认密码';

  @override
  String get setupPasswordAgreeTerms => '我同意 ';

  @override
  String get setupPasswordTermsConditions => '条款与条件';

  @override
  String get setupPasswordButton => '设置密码';

  @override
  String get setupPasswordValidationRequired => '密码为必填';

  @override
  String get setupPasswordValidationMinLength => '密码至少需要 8 个字符';

  @override
  String get setupPasswordValidationConfirmRequired => '请确认您的密码';

  @override
  String get setupPasswordValidationMismatch => '密码不匹配';

  @override
  String get setupPasswordValidationTermsRequired => '请接受条款和条件';

  @override
  String get comment_sign_up_status_screen => '==== 注册状态页面 ====';

  @override
  String get signUpStatusTitle => '您当前的状态';

  @override
  String get signUpStatusSubtitle => '一个简单的 4 步流程来保护您的 Qunzo 账户';

  @override
  String get signUpStatusStep => '步骤';

  @override
  String get signUpStatusEmailVerification => '邮箱验证';

  @override
  String get signUpStatusSetupPassword => '设置密码';

  @override
  String get signUpStatusPersonalInfo => '个人信息';

  @override
  String get signUpStatusVerification => '验证';

  @override
  String get signUpStatusInReview => '审核中';

  @override
  String get signUpStatusRejected => '已拒绝';

  @override
  String get signUpStatusNoReason => '未提供原因';

  @override
  String get signUpStatusNextStep => '下一步';

  @override
  String get signUpStatusSubmitAgain => '重新提交';

  @override
  String get signUpStatusDashboard => '仪表板';

  @override
  String get signUpStatusBack => '返回';

  @override
  String get signUpStatusErrorProcessing => '处理下一步时出错。请重试。';

  @override
  String get signUpStatusVerificationTypeEmpty => '验证类型为空！';

  @override
  String get signUpStatusErrorLoadingTypes => '加载验证类型时出错。请重试。';

  @override
  String get signUpStatusDropdownTwoVerificationNotFound => '未找到验证类型';

  @override
  String get comment_verify_email_screen => '==== 验证邮箱页面 ====';

  @override
  String get verifyEmailTitle => '验证邮箱';

  @override
  String get verifyEmailOtpSent => 'OTP 已发送至 ';

  @override
  String get verifyEmailEnterOtp => '输入 OTP';

  @override
  String get verifyEmailResendAvailable => '可重新发送剩余';

  @override
  String get verifyEmailRequestNewOtp => '您现在可以请求新的 OTP';

  @override
  String get verifyEmailButton => '验证邮箱';

  @override
  String get verifyEmailDidNotReceive => '没有收到验证码？ ';

  @override
  String get verifyEmailResend => '重新发送';

  @override
  String get verifyEmailOtpRequired => 'OTP 字段为必填';

  @override
  String get comment_add_money_screen => '==== 添加资金页面 ====';

  @override
  String get addMoneyTitle => '添加资金';

  @override
  String get addMoneyBalance => '余额';

  @override
  String get addMoneyHistory => '添加资金记录';

  @override
  String get addMoneyWalletsNotFound => '未找到钱包';

  @override
  String get comment_add_money_amount_step => '==== 添加资金金额步骤 ====';

  @override
  String get addMoneyGateway => '支付网关';

  @override
  String get addMoneyGatewayNotFound => '未找到网关';

  @override
  String get addMoneySelectGateway => '选择网关';

  @override
  String get addMoneyCharge => '手续费：';

  @override
  String get addMoneyAmount => '金额';

  @override
  String get addMoneyMin => '最低';

  @override
  String get addMoneyMax => '和最高';

  @override
  String get addMoneyWriteHere => '在此输入...';

  @override
  String get addMoneyAddMoneyButton => '添加资金';

  @override
  String get comment_add_money_pending_step => '==== 添加资金待处理步骤 ====';

  @override
  String get addMoneyPendingTitle => '您的存款流程正在\n处理中';

  @override
  String get addMoneyPendingAmount => '金额';

  @override
  String get addMoneyPendingTransactionId => '交易 ID';

  @override
  String get addMoneyPendingWalletName => '钱包名称';

  @override
  String get addMoneyPendingPaymentMethod => '支付方式';

  @override
  String get addMoneyPendingCharge => '手续费';

  @override
  String get addMoneyPendingType => '类型';

  @override
  String get addMoneyPendingFinalAmount => '最终金额';

  @override
  String get addMoneyPendingDepositAgain => '再次存款';

  @override
  String get addMoneyPendingBackHome => '返回首页';

  @override
  String get comment_add_money_review_step => '==== 添加资金审核步骤 ====';

  @override
  String get addMoneyReviewTitle => '审核详情';

  @override
  String get addMoneyReviewAmount => '金额';

  @override
  String get addMoneyReviewWalletName => '钱包名称';

  @override
  String get addMoneyReviewPaymentMethod => '支付方式';

  @override
  String get addMoneyReviewCharge => '手续费';

  @override
  String get addMoneyReviewTotal => '总计';

  @override
  String get addMoneyReviewBack => '返回';

  @override
  String get addMoneyReviewConfirm => '确认';

  @override
  String get addMoneyReviewNoFileUploaded => '未上传文件';

  @override
  String get comment_add_money_success_step => '==== 添加资金成功步骤 ====';

  @override
  String get addMoneySuccessTitle => '存款成功！';

  @override
  String get addMoneySuccessAmount => '金额';

  @override
  String get addMoneySuccessTransactionId => '交易 ID';

  @override
  String get addMoneySuccessCharge => '手续费';

  @override
  String get addMoneySuccessTransactionType => '交易类型';

  @override
  String get addMoneySuccessFinalAmount => '最终金额';

  @override
  String get addMoneySuccessAddMoneyAgain => '再次添加资金';

  @override
  String get addMoneySuccessBackHome => '返回首页';

  @override
  String get comment_add_money_history => '==== 添加资金记录 ====';

  @override
  String get addMoneyHistoryTitle => '添加资金记录';

  @override
  String get comment_add_money_filter_bottom_sheet => '==== 添加资金筛选底部表单 ====';

  @override
  String get addMoneyFilterTransactionId => '交易 ID';

  @override
  String get addMoneyFilterStatus => '状态';

  @override
  String get addMoneyFilterSuccess => '成功';

  @override
  String get addMoneyFilterPending => '待处理';

  @override
  String get addMoneyFilterFailed => '失败';

  @override
  String get addMoneyFilterButton => '筛选';

  @override
  String get addMoneyFilterReset => '重置';

  @override
  String get comment_create_beneficiary_screen => '==== 创建受益人页面 ====';

  @override
  String get createBeneficiaryTitle => '创建新受益人';

  @override
  String get createBeneficiaryAccountNumber => '账户号码';

  @override
  String get createBeneficiaryNickName => '昵称';

  @override
  String get createBeneficiaryCreateButton => '创建';

  @override
  String get createBeneficiaryValidationAccountNumber => '请填写账户号码';

  @override
  String get createBeneficiaryValidationNickName => '请填写昵称';

  @override
  String get comment_update_beneficiary_screen => '==== 更新受益人页面 ====';

  @override
  String get updateBeneficiaryTitle => '更新';

  @override
  String get updateBeneficiaryNickName => '昵称';

  @override
  String get updateBeneficiaryUpdateButton => '更新';

  @override
  String get updateBeneficiaryValidationNickName => '请填写昵称';

  @override
  String get comment_account_user_types => '==== 账户用户类型 ====';

  @override
  String get accountUserMerchant => '商户';

  @override
  String get accountUserBeneficiary => '受益人';

  @override
  String get accountUserAgent => '代理';

  @override
  String get comment_cash_out_screen => '==== 提现页面 ====';

  @override
  String get cashOutTitle => '从代理提现';

  @override
  String get cashOutHistory => '提现记录';

  @override
  String get comment_cash_out_amount_step => '==== 提现金额步骤 ====';

  @override
  String get cashOutAgentId => '代理 ID';

  @override
  String get cashOutAmount => '金额';

  @override
  String get cashOutMin => '最低';

  @override
  String get cashOutMax => '和最高';

  @override
  String get cashOutButton => '提现';

  @override
  String get cashOutSavedAgents => '已保存代理';

  @override
  String get cashOutAgents => '代理';

  @override
  String get cashOutAddAgent => '添加代理';

  @override
  String get cashOutAid => 'AID：';

  @override
  String get cashOutQrInvalidDigits => '无效的二维码。代理 AID 必须仅为数字。';

  @override
  String get cashOutQrInvalidPrefix => '无效的二维码。未找到 AID 前缀。';

  @override
  String get cashOutDeleteConfirm => '您确定吗？';

  @override
  String get cashOutDeleteMessage => '您要删除此代理吗？';

  @override
  String get cashOutDeleteButton => '删除';

  @override
  String get cashOutCancelButton => '取消';

  @override
  String get comment_cash_out_review_step => '==== 提现审核步骤 ====';

  @override
  String get cashOutReviewTitle => '审核详情';

  @override
  String get cashOutReviewAmount => '金额';

  @override
  String get cashOutReviewWallet => '钱包';

  @override
  String get cashOutReviewAgentAccount => '代理账户';

  @override
  String get cashOutReviewCharge => '手续费';

  @override
  String get cashOutReviewTotalAmount => '总金额';

  @override
  String get cashOutReviewBack => '返回';

  @override
  String get cashOutReviewConfirm => '确认';

  @override
  String get comment_cash_out_success_step => '==== 提现成功步骤 ====';

  @override
  String get cashOutSuccessTitle => '提现成功！';

  @override
  String get cashOutSuccessAmount => '金额';

  @override
  String get cashOutSuccessTransactionId => '交易 ID';

  @override
  String get cashOutSuccessWalletName => '钱包名称';

  @override
  String get cashOutSuccessPaymentMethod => '支付方式';

  @override
  String get cashOutSuccessCharge => '手续费';

  @override
  String get cashOutSuccessType => '类型';

  @override
  String get cashOutSuccessFinalAmount => '最终金额';

  @override
  String get cashOutSuccessCashOutAgain => '再次提现';

  @override
  String get cashOutSuccessBackHome => '返回首页';

  @override
  String get comment_cash_out_wallets_section => '==== 提现钱包部分 ====';

  @override
  String get cashOutWalletsBalance => '余额';

  @override
  String get cashOutWalletsNotFound => '未找到钱包';

  @override
  String get comment_cash_out_history => '==== 提现记录 ====';

  @override
  String get cashOutHistoryTitle => '提现记录';

  @override
  String get comment_cash_out_filter_bottom_sheet => '==== 提现筛选底部表单 ====';

  @override
  String get cashOutFilterTransactionId => '交易 ID';

  @override
  String get cashOutFilterStatus => '状态';

  @override
  String get cashOutFilterButton => '筛选';

  @override
  String get cashOutFilterReset => '重置';

  @override
  String get comment_exchange_screen => '==== 兑换页面 ====';

  @override
  String get exchangeTitle => '兑换钱包';

  @override
  String get exchangeHistory => '兑换记录';

  @override
  String get comment_exchange_amount_step => '==== 兑换金额步骤 ====';

  @override
  String get exchangeAmount => '金额';

  @override
  String get exchangeMin => '最低';

  @override
  String get exchangeMax => '和最高';

  @override
  String get exchangeButton => '兑换';

  @override
  String get comment_exchange_review_step => '==== 兑换审核步骤 ====';

  @override
  String get exchangeReviewTitle => '审核详情';

  @override
  String get exchangeReviewAmount => '金额';

  @override
  String get exchangeReviewFromWallet => '从钱包';

  @override
  String get exchangeReviewCharge => '手续费';

  @override
  String get exchangeReviewTotalAmount => '总金额';

  @override
  String get exchangeReviewToWallet => '至钱包';

  @override
  String get exchangeReviewExchangeRate => '汇率';

  @override
  String get exchangeReviewExchangeAmount => '兑换金额';

  @override
  String get exchangeReviewBack => '返回';

  @override
  String get exchangeReviewConfirm => '确认';

  @override
  String get comment_exchange_success_step => '==== 兑换成功步骤 ====';

  @override
  String get exchangeSuccessTitle => '兑换成功！';

  @override
  String get exchangeSuccessAmount => '金额';

  @override
  String get exchangeSuccessTransactionId => '交易 ID';

  @override
  String get exchangeSuccessPayAmount => '支付金额';

  @override
  String get exchangeSuccessConvertedAmount => '兑换金额';

  @override
  String get exchangeSuccessCharge => '手续费';

  @override
  String get exchangeSuccessDate => '日期';

  @override
  String get exchangeSuccessFinalAmount => '最终金额';

  @override
  String get exchangeSuccessExchangeAgain => '再次兑换';

  @override
  String get exchangeSuccessBackHome => '返回首页';

  @override
  String get comment_exchange_wallet_section => '==== 兑换钱包部分 ====';

  @override
  String get exchangeWalletBalance => '余额';

  @override
  String get exchangeWalletsNotFound => '未找到钱包';

  @override
  String get comment_exchange_wallet_to_wallet => '==== 钱包对钱包兑换 ====';

  @override
  String get exchangeWalletToWallet => '钱包对钱包';

  @override
  String get exchangeFromWallet => '从钱包';

  @override
  String get exchangeToWallet => '至钱包';

  @override
  String get exchangeRate => '汇率： ';

  @override
  String get exchangeWalletToWalletWalletsNotFound => '未找到钱包';

  @override
  String get comment_exchange_history => '==== 兑换记录 ====';

  @override
  String get exchangeHistoryTitle => '兑换记录';

  @override
  String get comment_exchange_filter_bottom_sheet => '==== 兑换筛选底部表单 ====';

  @override
  String get exchangeFilterTransactionId => '交易 ID';

  @override
  String get exchangeFilterStatus => '状态';

  @override
  String get exchangeFilterButton => '筛选';

  @override
  String get exchangeFilterReset => '重置';

  @override
  String get comment_gift_code_screen => '==== 礼品码页面 ====';

  @override
  String get giftCodeTitle => '礼品码';

  @override
  String get giftCodeCreateGift => '创建礼品';

  @override
  String get comment_create_gift_amount_step => '==== 创建礼品金额步骤 ====';

  @override
  String get createGiftAmount => '金额';

  @override
  String get createGiftMin => '最低';

  @override
  String get createGiftMax => '和最高';

  @override
  String get createGiftButton => '创建礼品';

  @override
  String get comment_create_gift_review_section => '==== 创建礼品审核部分 ====';

  @override
  String get createGiftReviewTitle => '审核详情';

  @override
  String get createGiftReviewAmount => '金额';

  @override
  String get createGiftReviewWalletName => '钱包名称';

  @override
  String get createGiftReviewCharge => '手续费';

  @override
  String get createGiftReviewTotalAmount => '总金额';

  @override
  String get createGiftReviewBack => '返回';

  @override
  String get createGiftReviewConfirm => '确认';

  @override
  String get comment_create_gift_success_step => '==== 创建礼品成功步骤 ====';

  @override
  String get createGiftSuccessTitle => '创建礼品成功！';

  @override
  String get createGiftSuccessAmount => '金额';

  @override
  String get createGiftSuccessCharge => '手续费';

  @override
  String get createGiftSuccessFinalAmount => '最终金额';

  @override
  String get createGiftSuccessCreatedAt => '创建于';

  @override
  String get createGiftSuccessCreateAgain => '再次创建礼品码';

  @override
  String get createGiftSuccessBackHome => '返回首页';

  @override
  String get comment_create_gift_wallet_section => '==== 创建礼品钱包部分 ====';

  @override
  String get createGiftWalletBalance => '余额';

  @override
  String get createGiftWalletWalletsNotFound => '未找到钱包';

  @override
  String get comment_gift_code_header_section => '==== 礼品码头部部分 ====';

  @override
  String get giftCodeHeaderTitle => '礼品码';

  @override
  String get giftCodeHeaderGiftRedeem => '礼品兑换';

  @override
  String get giftCodeHeaderMyGift => '我的礼品';

  @override
  String get giftCodeHeaderGiftRedeemHistory => '礼品兑换记录';

  @override
  String get comment_gift_history => '==== 礼品记录 ====';

  @override
  String get giftHistoryCreatedAt => '创建于：';

  @override
  String get giftHistoryStatus => '状态： ';

  @override
  String get giftHistoryClaimed => '已领取';

  @override
  String get giftHistoryClaimable => '可领取';

  @override
  String get giftHistoryCodeCopied => '礼品码已复制';

  @override
  String get comment_gift_history_filter_bottom_sheet => '==== 礼品记录筛选底部表单 ====';

  @override
  String get giftHistoryFilterGiftCode => '礼品码';

  @override
  String get giftHistoryFilterButton => '筛选';

  @override
  String get comment_gift_redeem_section => '==== 礼品兑换部分 ====';

  @override
  String get giftRedeemGiftCode => '礼品码';

  @override
  String get giftRedeemButton => '兑换';

  @override
  String get giftRedeemValidation => '请输入礼品码';

  @override
  String get comment_gift_redeem_history => '==== 礼品兑换记录 ====';

  @override
  String get giftRedeemHistoryTitle => '我的兑换记录';

  @override
  String get giftRedeemHistoryCreatedAt => '创建于：';

  @override
  String get giftRedeemHistoryStatus => '状态： ';

  @override
  String get giftRedeemHistoryClaimed => '已领取';

  @override
  String get giftRedeemHistoryClaimable => '可领取';

  @override
  String get giftRedeemHistoryCodeCopied => '礼品码已复制';

  @override
  String get comment_gift_redeem_filter_bottom_sheet => '==== 礼品兑换筛选底部表单 ====';

  @override
  String get giftRedeemFilterCode => '代码';

  @override
  String get giftRedeemFilterButton => '筛选';

  @override
  String get giftRedeemFilterReset => '重置';

  @override
  String get comment_drawer_section => '==== 侧边栏部分 ====';

  @override
  String get drawerDashboard => '仪表板';

  @override
  String get drawerMyWallets => '我的钱包';

  @override
  String get drawerAddMoney => '添加资金';

  @override
  String get drawerCashOut => '提现';

  @override
  String get drawerBillPayments => '账单支付';

  @override
  String get drawerVirtualCards => '虚拟卡';

  @override
  String get drawerPaymentLinks => '支付链接';

  @override
  String get drawerMakePayment => '付款';

  @override
  String get drawerTransfer => '转账';

  @override
  String get drawerWithdraw => '提现';

  @override
  String get drawerExchange => '兑换';

  @override
  String get drawerInviting => '邀请';

  @override
  String get drawerGiftCard => '礼品卡';

  @override
  String get drawerP2pTrading => 'P2P 交易';

  @override
  String get drawerKycVerification => '请验证您的 KYC！';

  @override
  String get comment_end_drawer_section => '==== 结束侧边栏部分 ====';

  @override
  String get endDrawerProfileSettings => '个人设置';

  @override
  String get endDrawerChangePassword => '修改密码';

  @override
  String get endDrawerAllNotification => '所有通知';

  @override
  String get endDrawerHelpSupport => '帮助与支持';

  @override
  String get endDrawerLanguage => '语言';

  @override
  String get endDrawerBiometric => '生物识别';

  @override
  String get endDrawerSignOut => '退出登录';

  @override
  String get endDrawerLanguageNotFound => '未找到语言';

  @override
  String get endDrawerChooseLanguage => '选择语言';

  @override
  String get comment_recent_transaction_details => '==== 最近交易详情 ====';

  @override
  String get transactionDetailsTitle => '交易详情';

  @override
  String get transactionDetailsWallet => '钱包';

  @override
  String get transactionDetailsCharge => '手续费';

  @override
  String get transactionDetailsTransactionId => '交易 ID';

  @override
  String get transactionDetailsMethod => '方式';

  @override
  String get transactionDetailsTotalAmount => '总金额';

  @override
  String get transactionDetailsStatus => '状态';

  @override
  String get transactionDetailsDescription => '描述';

  @override
  String get transactionStatusSuccess => '成功';

  @override
  String get transactionStatusPending => '待处理';

  @override
  String get transactionStatusFailed => '失败';

  @override
  String get comment_wallet_details => '==== 钱包详情 ====';

  @override
  String get walletDetailsHistory => '记录';

  @override
  String get walletDetailsAvailableBalance => '可用余额';

  @override
  String get walletDetailsTopUp => '充值';

  @override
  String get walletDetailsWithdraw => '提现';

  @override
  String get walletDetailsUserDepositNotEnabled => '用户存款未启用';

  @override
  String get walletDetailsUserWithdrawNotEnabled => '用户提现未启用';

  @override
  String get walletDetailsWalletsNotFound => '未找到钱包';

  @override
  String get comment_action_button_section => '==== 操作按钮部分 ====';

  @override
  String get actionButtonTransfer => '转账';

  @override
  String get actionButtonWithdraw => '提现';

  @override
  String get actionButtonPayment => '支付';

  @override
  String get actionButtonExchange => '兑换';

  @override
  String get actionButtonUserTransferNotEnabled => '用户转账未启用';

  @override
  String get actionButtonUserWithdrawNotEnabled => '用户提现未启用';

  @override
  String get actionButtonUserPaymentNotEnabled => '用户支付未启用';

  @override
  String get actionButtonUserExchangeNotEnabled => '用户兑换未启用';

  @override
  String get comment_my_wallet_section => '==== 我的钱包部分 ====';

  @override
  String get myWalletSectionTitle => '我的钱包';

  @override
  String get myWalletTopUp => '充值';

  @override
  String get myWalletWithdraw => '提现';

  @override
  String get myWalletUserDepositNotEnabled => '用户存款未启用';

  @override
  String get myWalletUserWithdrawNotEnabled => '用户提现未启用';

  @override
  String get comment_other_services_section => '==== 其他服务部分 ====';

  @override
  String get otherServicesTitle => '其他服务';

  @override
  String get dynamicPasswordTitle => '动态密码';

  @override
  String get dynamicPasswordDesc => '用于钱包支付的 6 位验证码';

  @override
  String get otherServicesQrCode => '二维码';

  @override
  String get otherServicesAddMoney => '添加资金';

  @override
  String get otherServicesCashOut => '提现';

  @override
  String get otherServicesMakePayment => '付款';

  @override
  String get otherServicesTransactions => '交易';

  @override
  String get otherServicesInvoice => '发票';

  @override
  String get otherServicesRequestMoney => '请求资金';

  @override
  String get otherServicesGift => '礼品';

  @override
  String get otherServicesWallets => '钱包';

  @override
  String get otherServicesWithdraw => '提现';

  @override
  String get otherServicesExchange => '兑换';

  @override
  String get otherServicesTransfer => '转账';

  @override
  String get otherServicesInvite => '邀请';

  @override
  String get otherServicesBillPayment => '账单支付';

  @override
  String get otherServicesVirtualCard => '虚拟卡';

  @override
  String get otherServicesGiftCards => '礼品卡';

  @override
  String get otherServicesP2pTrading => 'P2P 交易';

  @override
  String get otherServicesPaymentLinks => '支付链接';

  @override
  String get otherServicesKycVerification => '请验证您的 KYC！';

  @override
  String get otherServicesUserGiftNotEnabled => '用户礼品未启用';

  @override
  String get otherServicesUserDepositNotEnabled => '用户存款未启用';

  @override
  String get otherServicesUserCashOutNotEnabled => '用户提现未启用';

  @override
  String get otherServicesUserPaymentNotEnabled => '用户支付未启用';

  @override
  String get otherServicesUserRequestMoneyNotEnabled => '用户请求资金未启用';

  @override
  String get otherServicesUserInvoiceNotEnabled => '用户发票未启用';

  @override
  String get comment_recent_transactions_section => '==== 最近交易部分 ====';

  @override
  String get recentTransactionsTitle => '最近';

  @override
  String get comment_section_header => '==== 部分标题 ====';

  @override
  String get sectionHeaderSeeAll => '查看全部';

  @override
  String get comment_sign_up_bonus_popup => '==== 注册奖金弹窗 ====';

  @override
  String get signUpBonusCongratulations => '恭喜！';

  @override
  String get signUpBonusReceived => '您已收到奖金';

  @override
  String get comment_user_profile_section => '==== 用户资料部分 ====';

  @override
  String get userProfileHello => '您好，👋';

  @override
  String get userProfileUid => 'UID：';

  @override
  String get userProfileCopied => '已复制';

  @override
  String get comment_invoice_screen => '==== 发票页面 ====';

  @override
  String get invoiceTitle => '发票';

  @override
  String get invoiceCreateInvoice => '创建发票';

  @override
  String get invoiceAmount => '金额：';

  @override
  String get invoiceCharge => '手续费：';

  @override
  String get invoiceStatus => '状态： ';

  @override
  String get invoicePublished => '已发布';

  @override
  String get invoiceDraft => '草稿';

  @override
  String get invoiceView => '查看';

  @override
  String get invoicePaid => '已支付';

  @override
  String get invoiceUnpaid => '未支付';

  @override
  String get comment_update_invoice => '==== 更新发票 ====';

  @override
  String get updateInvoiceTitle => '更新发票';

  @override
  String get updateInvoiceItems => '发票项目';

  @override
  String get updateInvoiceAddItem => '添加项目';

  @override
  String get updateInvoiceButton => '更新发票';

  @override
  String get comment_update_invoice_add_item => '==== 更新发票添加项目 ====';

  @override
  String get updateInvoiceItemName => '项目名称';

  @override
  String get updateInvoiceQuantity => '数量';

  @override
  String get updateInvoiceUnitPrice => '单价';

  @override
  String get updateInvoiceSubTotal => '小计';

  @override
  String get comment_update_invoice_information => '==== 更新发票信息 ====';

  @override
  String get updateInvoiceInformationTitle => '发票信息';

  @override
  String get updateInvoiceTo => '发票至';

  @override
  String get updateInvoiceEmailAddress => '邮箱地址';

  @override
  String get updateInvoiceAddress => '地址';

  @override
  String get updateInvoiceWallet => '钱包';

  @override
  String get updateInvoiceStatus => '状态';

  @override
  String get updateInvoiceIssueDate => '开具日期';

  @override
  String get updateInvoicePaymentStatus => '支付状态';

  @override
  String get updateInvoiceSelectWallet => '选择钱包';

  @override
  String get updateInvoiceSelectStatus => '选择状态';

  @override
  String get updateInvoiceSelectPaymentStatus => '选择支付状态';

  @override
  String get updateInvoiceWalletNotFound => '未找到钱包';

  @override
  String get updateInvoiceStatusNotFound => '未找到状态';

  @override
  String get updateInvoicePaymentStatusNotFound => '未找到支付状态';

  @override
  String get comment_invoice_status_options => '==== 发票状态选项 ====';

  @override
  String get invoiceStatusDraft => '草稿';

  @override
  String get invoiceStatusPublished => '已发布';

  @override
  String get invoiceStatusPaid => '已支付';

  @override
  String get invoiceStatusUnpaid => '未支付';

  @override
  String get comment_invoice_details => '==== 发票详情 ====';

  @override
  String get invoiceDetailsTitle => '发票';

  @override
  String get invoiceDetailsReference => '编号：';

  @override
  String get invoiceDetailsIssued => '开具：';

  @override
  String get invoiceDetailsName => '名称';

  @override
  String get invoiceDetailsEmail => '邮箱';

  @override
  String get invoiceDetailsCharge => '手续费';

  @override
  String get invoiceDetailsAddress => '地址';

  @override
  String get invoiceDetailsTotalAmount => '总金额';

  @override
  String get invoiceDetailsStatus => '状态';

  @override
  String get invoiceDetailsItemName => '项目名称';

  @override
  String get invoiceDetailsQuantity => '数量';

  @override
  String get invoiceDetailsUnitPrice => '单价';

  @override
  String get invoiceDetailsSubTotal => '小计';

  @override
  String get invoiceDetailsPayNow => '立即支付';

  @override
  String get invoiceDetailsPrintInvoice => '打印发票';

  @override
  String get invoiceDetailsPaid => '已支付';

  @override
  String get invoiceDetailsUnpaid => '未支付';

  @override
  String get comment_invoice_pdf => '==== 发票 PDF ====';

  @override
  String get invoicePdfReference => '编号：';

  @override
  String get invoicePdfIssued => '开具：';

  @override
  String get invoicePdfPaid => '已支付';

  @override
  String get invoicePdfUnpaid => '未支付';

  @override
  String get invoicePdfTotalAmount => '总金额：';

  @override
  String get invoicePdfAmount => '金额：';

  @override
  String get invoicePdfCharge => '手续费：';

  @override
  String get invoicePdfItemName => '项目名称';

  @override
  String get invoicePdfQuantity => '数量';

  @override
  String get invoicePdfUnitPrice => '单价';

  @override
  String get invoicePdfSubtotal => '小计';

  @override
  String get invoicePdfSubtotalLabel => '小计： ';

  @override
  String get invoicePdfChargeLabel => '手续费： ';

  @override
  String get invoicePdfTotalAmountLabel => '总金额： ';

  @override
  String get invoicePdfThanks => '感谢您的购买。';

  @override
  String get comment_create_invoice => '==== 创建发票 ====';

  @override
  String get createInvoiceTitle => '创建发票';

  @override
  String get createInvoiceItems => '发票项目';

  @override
  String get createInvoiceAddItem => '添加项目';

  @override
  String get createInvoiceButton => '创建发票';

  @override
  String get createInvoiceStatusDraft => '草稿';

  @override
  String get comment_create_invoice_add_item_section => '==== 创建发票添加项目部分 ====';

  @override
  String get createInvoiceAddItemSectionItemName => '项目名称';

  @override
  String get createInvoiceAddItemSectionQuantity => '数量';

  @override
  String get createInvoiceAddItemSectionUnitPrice => '单价';

  @override
  String get createInvoiceAddItemSectionSubTotal => '小计';

  @override
  String get comment_create_invoice_information_section => '==== 创建发票信息部分 ====';

  @override
  String get createInvoiceInformationSectionTitle => '发票信息';

  @override
  String get createInvoiceInformationSectionInvoiceTo => '发票至';

  @override
  String get createInvoiceInformationSectionEmailAddress => '邮箱地址';

  @override
  String get createInvoiceInformationSectionAddress => '地址';

  @override
  String get createInvoiceInformationSectionWallet => '钱包';

  @override
  String get createInvoiceInformationSectionStatus => '状态';

  @override
  String get createInvoiceInformationSectionIssueDate => '开具日期';

  @override
  String get createInvoiceInformationSectionWalletNotFound => '未找到钱包';

  @override
  String get createInvoiceInformationSectionWalletHint => '选择钱包';

  @override
  String get createInvoiceInformationSectionStatusTitle => '状态';

  @override
  String get createInvoiceInformationSectionStatusNotFound => '未找到状态';

  @override
  String get createInvoiceInformationSectionStatusDraft => '草稿';

  @override
  String get createInvoiceInformationSectionStatusPublished => '已发布';

  @override
  String get comment_make_payment_screen => '==== 付款页面 ====';

  @override
  String get makePaymentScreenTitle => '付款';

  @override
  String get makePaymentScreenWalletsNotFound => '未找到钱包';

  @override
  String get makePaymentScreenBalance => '余额';

  @override
  String get makePaymentScreenHistory => '付款记录';

  @override
  String get comment_make_payment_amount_step_section => '==== 付款金额步骤部分 ====';

  @override
  String get makePaymentAmountStepSectionMerchantId => '商户 ID';

  @override
  String get makePaymentAmountStepSectionAmount => '金额';

  @override
  String get makePaymentAmountStepSectionMinLimit => '最低';

  @override
  String get makePaymentAmountStepSectionMaxLimit => '和最高';

  @override
  String get makePaymentAmountStepSectionMakePaymentButton => '付款';

  @override
  String get makePaymentAmountStepSectionSavedMerchantsButton => '已保存商户';

  @override
  String get makePaymentAmountStepSectionInvalidQrCodeDigits =>
      '无效的二维码。商户 MID 必须仅为数字。';

  @override
  String get makePaymentAmountStepSectionInvalidQrCodePrefix =>
      '无效的二维码。未找到 MID 前缀。';

  @override
  String get makePaymentAmountStepSectionMerchantsTitle => '商户';

  @override
  String get makePaymentAmountStepSectionAddMerchant => '添加商户';

  @override
  String get makePaymentAmountStepSectionMidLabel => 'MID：';

  @override
  String get makePaymentAmountStepSectionDeleteConfirmationTitle => '您确定吗？';

  @override
  String get makePaymentAmountStepSectionDeleteConfirmationMessage =>
      '您要删除此商户吗？';

  @override
  String get makePaymentAmountStepSectionDeleteButton => '删除';

  @override
  String get makePaymentAmountStepSectionCancelButton => '取消';

  @override
  String get comment_make_payment_review_step_section => '==== 付款审核步骤部分 ====';

  @override
  String get makePaymentReviewStepSectionTitle => '审核详情';

  @override
  String get makePaymentReviewStepSectionAmount => '金额';

  @override
  String get makePaymentReviewStepSectionWallet => '钱包';

  @override
  String get makePaymentReviewStepSectionMerchantAccount => '商户账户';

  @override
  String get makePaymentReviewStepSectionCharge => '手续费';

  @override
  String get makePaymentReviewStepSectionTotalAmount => '总金额';

  @override
  String get makePaymentReviewStepSectionBackButton => '返回';

  @override
  String get makePaymentReviewStepSectionConfirmButton => '确认';

  @override
  String get comment_make_payment_success_step_section => '==== 付款成功步骤部分 ====';

  @override
  String get makePaymentSuccessStepSectionTitle => '付款成功！';

  @override
  String get makePaymentSuccessStepSectionAmount => '金额';

  @override
  String get makePaymentSuccessStepSectionTransactionId => '交易 ID';

  @override
  String get makePaymentSuccessStepSectionWalletName => '钱包名称';

  @override
  String get makePaymentSuccessStepSectionPaymentMethod => '支付方式';

  @override
  String get makePaymentSuccessStepSectionCharge => '手续费';

  @override
  String get makePaymentSuccessStepSectionType => '类型';

  @override
  String get makePaymentSuccessStepSectionFinalAmount => '最终金额';

  @override
  String get makePaymentSuccessStepSectionPaymentAgainButton => '再次付款';

  @override
  String get makePaymentSuccessStepSectionBackHomeButton => '返回首页';

  @override
  String get comment_make_payment_history_screen => '==== 付款记录页面 ====';

  @override
  String get makePaymentHistoryScreenTitle => '付款记录';

  @override
  String get comment_make_payment_filter_bottom_sheet => '==== 付款筛选底部表单 ====';

  @override
  String get makePaymentFilterTransactionId => '交易 ID';

  @override
  String get makePaymentFilterStatus => '状态';

  @override
  String get makePaymentFilterApplyButton => '筛选';

  @override
  String get makePaymentFilterResetButton => '重置';

  @override
  String get comment_qr_code_screen => '==== 二维码页面 ====';

  @override
  String get qrCodeScreenTitle => '我的二维码';

  @override
  String get qrCodeScreenDownloadButton => '下载';

  @override
  String get qrCodeScreenPermissionRequired => '需要权限。请在设置中允许。';

  @override
  String get qrCodeScreenDownloadSuccess => '下载成功！';

  @override
  String get comment_referral_screen => '==== 推荐页面 ====';

  @override
  String get referralScreenTitle => '推荐';

  @override
  String get referralScreenEarnAmount => '赚取';

  @override
  String get referralScreenAfterInviting => '邀请后';

  @override
  String get referralScreenOneMember => '一位成员';

  @override
  String get referralScreenNoCode => '无代码';

  @override
  String get referralScreenCodeCopied => '代码已复制';

  @override
  String get referralScreenShareButton => '分享';

  @override
  String get referralScreenReferredFriends => '已推荐好友';

  @override
  String get comment_referred_friends_screen => '==== 已推荐好友页面 ====';

  @override
  String get referredFriendsScreenTitle => '已推荐好友';

  @override
  String get referredFriendsScreenReferralTreeButton => '推荐树';

  @override
  String get comment_referred_friend_list => '==== 已推荐好友列表 ====';

  @override
  String get referredFriendListJoinedOn => '加入于';

  @override
  String get referredFriendListActive => '活跃';

  @override
  String get referredFriendListInactive => '不活跃';

  @override
  String get comment_referral_tree_screen => '==== 推荐树页面 ====';

  @override
  String get referralTreeScreenTitle => '推荐树';

  @override
  String get comment_request_money_screen => '==== 请求资金页面 ====';

  @override
  String get requestMoneyScreenTitle => '请求资金';

  @override
  String get comment_request_money_amount_step_section =>
      '==== 请求资金金额步骤部分 ====';

  @override
  String get requestMoneyAmountStepSectionRecipientId => '收款人 ID';

  @override
  String get requestMoneyAmountStepSectionRequestAmount => '请求金额';

  @override
  String get requestMoneyAmountStepSectionMin => '最低';

  @override
  String get requestMoneyAmountStepSectionMax => '和最高';

  @override
  String get requestMoneyAmountStepSectionNote => '备注';

  @override
  String get requestMoneyAmountStepSectionRequestMoneyButton => '请求资金';

  @override
  String get requestMoneyAmountStepSectionInvalidQrCodeDigits =>
      '无效的二维码。收款人 UID 必须仅为数字。';

  @override
  String get requestMoneyAmountStepSectionInvalidQrCodePrefix =>
      '无效的二维码。未找到 UID 前缀。';

  @override
  String get comment_request_money_header_section => '==== 请求资金头部部分 ====';

  @override
  String get requestMoneyHeaderSectionTitle => '请求资金';

  @override
  String get requestMoneyHeaderSectionRequestMoneyButton => '请求资金';

  @override
  String get requestMoneyHeaderSectionReceivedRequestButton => '已收到请求';

  @override
  String get requestMoneyHeaderSectionHistory => '请求资金记录';

  @override
  String get comment_request_money_review_step_section =>
      '==== 请求资金审核步骤部分 ====';

  @override
  String get requestMoneyReviewStepSectionTitle => '审核详情';

  @override
  String get requestMoneyReviewStepSectionAmount => '金额';

  @override
  String get requestMoneyReviewStepSectionWalletName => '钱包名称';

  @override
  String get requestMoneyReviewStepSectionRecipientUid => '收款人 UID';

  @override
  String get requestMoneyReviewStepSectionBackButton => '返回';

  @override
  String get requestMoneyReviewStepSectionConfirmButton => '确认';

  @override
  String get comment_request_money_success_step_section =>
      '==== 请求资金成功步骤部分 ====';

  @override
  String get requestMoneySuccessStepSectionTitle => '请求资金成功！';

  @override
  String get requestMoneySuccessStepSectionAmount => '金额';

  @override
  String get requestMoneySuccessStepSectionRecipientName => '收款人姓名';

  @override
  String get requestMoneySuccessStepSectionRequestWalletName => '请求钱包名称';

  @override
  String get requestMoneySuccessStepSectionCharge => '手续费';

  @override
  String get requestMoneySuccessStepSectionFinalAmount => '最终金额';

  @override
  String get requestMoneySuccessStepSectionStatus => '状态';

  @override
  String get requestMoneySuccessStepSectionRequestAgainButton => '再次请求';

  @override
  String get requestMoneySuccessStepSectionBackHomeButton => '返回首页';

  @override
  String get comment_request_money_wallet_section => '==== 请求资金钱包部分 ====';

  @override
  String get requestMoneyWalletSectionBalance => '余额';

  @override
  String get requestMoneyWalletSectionWalletsNotFound => '未找到钱包';

  @override
  String get comment_request_money_history_screen => '==== 请求资金记录页面 ====';

  @override
  String get requestMoneyHistoryScreenTitle => '请求资金记录';

  @override
  String get requestMoneyHistoryRequestedAt => '请求于：';

  @override
  String get requestMoneyHistoryStatus => '状态： ';

  @override
  String get comment_request_money_history_details => '==== 请求资金记录详情 ====';

  @override
  String get requestMoneyHistoryDetailsRequestEmail => '请求邮箱';

  @override
  String get requestMoneyHistoryDetailsCurrency => '货币';

  @override
  String get requestMoneyHistoryDetailsCharge => '手续费';

  @override
  String get requestMoneyHistoryDetailsFinalAmount => '最终金额';

  @override
  String get requestMoneyHistoryDetailsRequestAt => '请求于';

  @override
  String get requestMoneyHistoryDetailsStatus => '状态';

  @override
  String get comment_received_request_screen => '==== 已收到请求页面 ====';

  @override
  String get receivedRequestRequestedAt => '请求于：';

  @override
  String get receivedRequestStatus => '状态： ';

  @override
  String get receivedRequestRejectButton => '拒绝';

  @override
  String get receivedRequestAcceptButton => '接受';

  @override
  String get comment_accept_request_dropdown => '==== 接受请求下拉菜单 ====';

  @override
  String get acceptRequestDropdownTitle => '您确定吗？';

  @override
  String get acceptRequestDropdownMessage => '您要接受此资金请求吗？';

  @override
  String get acceptRequestDropdownPayableAmount => '应付金额：';

  @override
  String get acceptRequestDropdownPayWallet => '支付钱包：';

  @override
  String get acceptRequestDropdownRequesterNote => '请求人备注：';

  @override
  String get acceptRequestDropdownNoteNotFound => '未找到备注';

  @override
  String get acceptRequestDropdownAcceptButton => '接受';

  @override
  String get acceptRequestDropdownCancelButton => '取消';

  @override
  String get comment_received_request_details => '==== 已收到请求详情 ====';

  @override
  String get receivedRequestDetailsRequestEmail => '请求邮箱';

  @override
  String get receivedRequestDetailsCurrency => '货币';

  @override
  String get receivedRequestDetailsCharge => '手续费';

  @override
  String get receivedRequestDetailsFinalAmount => '最终金额';

  @override
  String get receivedRequestDetailsRequestAt => '请求于';

  @override
  String get receivedRequestDetailsStatus => '状态';

  @override
  String get comment_change_password_screen => '==== 修改密码页面 ====';

  @override
  String get changePasswordScreenTitle => '修改密码';

  @override
  String get changePasswordCurrentPassword => '当前密码';

  @override
  String get changePasswordNewPassword => '新密码';

  @override
  String get changePasswordConfirmPassword => '确认密码';

  @override
  String get changePasswordSaveChangesButton => '保存更改';

  @override
  String get comment_id_verification_screen => '==== 身份验证页面 ====';

  @override
  String get idVerificationScreenTitle => 'KYC';

  @override
  String get idVerificationHistoryButton => 'KYC 记录';

  @override
  String get idVerificationCenterTitle => '验证中心';

  @override
  String get idVerificationNothingToSubmit => '您没有需要提交的内容';

  @override
  String get kycStatusVerified => '您已提交文件并通过验证';

  @override
  String get kycStatusPending => '您已提交文件，正在等待批准';

  @override
  String get kycStatusRejected => '您的 KYC 验证失败。请重新提交文件。';

  @override
  String get kycStatusNotSubmitted => '您尚未提交任何 KYC 文件';

  @override
  String get comment_kyc_history_screen => '==== KYC 记录页面 ====';

  @override
  String get kycHistoryScreenTitle => 'KYC 记录';

  @override
  String get kycHistoryDate => '日期：';

  @override
  String get kycHistoryStatus => '状态： ';

  @override
  String get kycHistoryStatusPending => '待处理';

  @override
  String get kycHistoryStatusApproved => '已批准';

  @override
  String get kycHistoryStatusRejected => '已拒绝';

  @override
  String get kycHistoryViewButton => '查看';

  @override
  String get comment_kyc_details_bottom_sheet => '==== KYC 详情底部表单 ====';

  @override
  String get kycDetailsTitle => 'KYC 详情';

  @override
  String get kycDetailsStatus => '状态：';

  @override
  String get kycDetailsCreatedAt => '创建于：';

  @override
  String get kycDetailsMessageFromAdmin => '管理员留言：';

  @override
  String get kycDetailsSubmittedData => '已提交数据';

  @override
  String get kycDetailsStatusPending => '待处理';

  @override
  String get kycDetailsStatusApproved => '已批准';

  @override
  String get kycDetailsStatusRejected => '已拒绝';

  @override
  String get comment_notifications_screen => '==== 通知页面 ====';

  @override
  String get notificationsScreenTitle => '所有通知';

  @override
  String get notificationsMarkAllReadButton => '全部标记为已读';

  @override
  String get comment_profile_settings_screen => '==== 个人设置页面 ====';

  @override
  String get profileSettingsScreenTitle => '个人设置';

  @override
  String get profileSettingsFirstName => '名字';

  @override
  String get profileSettingsLastName => '姓氏';

  @override
  String get profileSettingsUserName => '用户名';

  @override
  String get profileSettingsGender => '性别';

  @override
  String get profileSettingsDateOfBirth => '出生日期';

  @override
  String get profileSettingsEmailAddress => '邮箱地址';

  @override
  String get profileSettingsPhone => '电话';

  @override
  String get profileSettingsCountry => '国家';

  @override
  String get profileSettingsCity => '城市';

  @override
  String get profileSettingsZipCode => '邮编';

  @override
  String get profileSettingsJoiningDate => '加入日期';

  @override
  String get profileSettingsAddress => '地址';

  @override
  String get profileSettingsGenderTitle => '性别';

  @override
  String get profileSettingsGenderNotFound => '未找到性别';

  @override
  String get profileSettingsGenderMale => '男';

  @override
  String get profileSettingsGenderFemale => '女';

  @override
  String get profileSettingsGenderOther => '其他';

  @override
  String get profileSettingsSelectGender => '选择性别';

  @override
  String get profileSettingsCountryTitle => '国家';

  @override
  String get profileSettingsCountryNotFound => '未找到国家';

  @override
  String get profileSettingsSelectCountry => '选择国家';

  @override
  String get profileSettingsSaveChangesButton => '保存更改';

  @override
  String get comment_support_tickets_screen => '==== 支持工单页面 ====';

  @override
  String get supportTicketsScreenTitle => '支持工单';

  @override
  String get supportTicketsCreateTicketButton => '创建工单';

  @override
  String get supportTicketsLastUpdate => '最后更新';

  @override
  String get supportTicketsRequestedAt => '请求于';

  @override
  String get supportTicketsPriorityHigh => '高';

  @override
  String get supportTicketsPriorityMedium => '中';

  @override
  String get supportTicketsPriorityLow => '低';

  @override
  String get supportTicketsStatus => '状态： ';

  @override
  String get supportTicketsStatusOpen => '开放';

  @override
  String get supportTicketsStatusClose => '关闭';

  @override
  String get supportTicketsReplyButton => '回复';

  @override
  String get comment_ticket_details => '==== 工单详情 ====';

  @override
  String get ticketDetailsTitle => '工单详情';

  @override
  String get ticketDetailsTicketId => '工单 ID';

  @override
  String get ticketDetailsCategory => '类别';

  @override
  String get ticketDetailsPriority => '优先级';

  @override
  String get ticketDetailsCreatedOn => '创建于';

  @override
  String get ticketDetailsLastUpdated => '最后更新';

  @override
  String get ticketDetailsPriorityHigh => '高';

  @override
  String get ticketDetailsPriorityMedium => '中';

  @override
  String get ticketDetailsPriorityLow => '低';

  @override
  String get comment_replay_ticket_screen => '==== 回复工单页面 ====';

  @override
  String get replayTicketMarkAsClosedButton => '标记为已关闭';

  @override
  String get replayTicketMessageHint => '输入您的消息...';

  @override
  String get replayTicketEmptyMessageError => '请输入消息';

  @override
  String get replayTicketAttachmentsLabel => '附件：';

  @override
  String get replayTicketUnknownFile => '未知文件';

  @override
  String get replayTicketAttachmentPreviewTitle => '附件预览';

  @override
  String get replayTicketAttachmentError => '出了点问题！';

  @override
  String get comment_add_new_ticket_screen => '==== 添加新工单页面 ====';

  @override
  String get addNewTicketScreenTitle => '创建工单';

  @override
  String get addNewTicketTitle => '标题';

  @override
  String get addNewTicketDescription => '描述';

  @override
  String get addNewTicketAttachments => '附件';

  @override
  String get addNewTicketAttachFile => '附加文件';

  @override
  String get addNewTicketAddButton => '添加工单';

  @override
  String get comment_two_factor_authentication_screen => '==== 双因素认证页面 ====';

  @override
  String get twoFactorAuthenticationScreenTitle => '2FA 认证';

  @override
  String get comment_disable_2fa_section => '==== 禁用 2FA 部分 ====';

  @override
  String get disable2FaSectionTitle => '2FA 认证';

  @override
  String get disable2FaSectionDescription => 'noInternetConnectionRetryButton';

  @override
  String get disable2FaSectionDisableButton => '禁用 2FA';

  @override
  String get disable2FaSectionPasswordRequired => '请输入密码';

  @override
  String get comment_enable_2fa_section => '==== 启用 2FA 部分 ====';

  @override
  String get enable2FaSectionTitle => '2FA 认证';

  @override
  String get enable2FaSectionDescription =>
      '使用 Google Authenticator 应用扫描二维码以启用 2FA';

  @override
  String get enable2FaSectionPinLabel => '来自 Google Authenticator 应用的 PIN';

  @override
  String get enable2FaSectionEnableButton => '启用 2FA';

  @override
  String get enable2FaSectionPinRequired => '请输入 Google 认证 PIN';

  @override
  String get comment_generate_2fa_section => '==== 生成 2FA 部分 ====';

  @override
  String get generate2FaSectionTitle => '2FA 认证';

  @override
  String get generate2FaSectionDescription => '使用双因素认证增强您的账户安全';

  @override
  String get generate2FaSectionGenerateButton => '生成 2FA';

  @override
  String get comment_settings_screen => '==== 设置页面 ====';

  @override
  String get settingsScreenTitle => '设置';

  @override
  String get settingsProfileSettings => '个人设置';

  @override
  String get settingsChangePassword => '修改密码';

  @override
  String get settingsAllNotification => '所有通知';

  @override
  String get settingsTwoFactorAuthentication => '2FA 认证';

  @override
  String get settingsIdVerification => '身份验证';

  @override
  String get settingsSupport => '支持';

  @override
  String get settingsSignOut => '退出登录';

  @override
  String get settingsKycVerified => '已验证';

  @override
  String get settingsKycPending => '待处理';

  @override
  String get settingsKycFailed => '失败';

  @override
  String get settingsKycNotSubmitted => '未提交';

  @override
  String get comment_transactions_screen => '==== 交易页面 ====';

  @override
  String get transactionsScreenTitle => '我的交易';

  @override
  String get comment_transactions_popup => '==== 交易弹窗 ====';

  @override
  String get transactionsPopupDate => '日期';

  @override
  String get transactionsPopupTransactionId => '交易 ID';

  @override
  String get transactionsPopupWalletName => '钱包名称';

  @override
  String get transactionsPopupAmount => '金额';

  @override
  String get transactionsPopupCharge => '手续费';

  @override
  String get transactionsPopupFinalAmount => '最终金额';

  @override
  String get transactionsPopupStatus => '状态';

  @override
  String get comment_transaction_filter_bottom_sheet => '==== 交易筛选底部表单 ====';

  @override
  String get transactionFilterTransactionId => '交易 ID';

  @override
  String get transactionFilterStatus => '状态';

  @override
  String get transactionFilterApplyButton => '筛选';

  @override
  String get transactionFilterResetButton => '重置';

  @override
  String get comment_transfer_screen => '==== 转账页面 ====';

  @override
  String get transferScreenTitle => '转账';

  @override
  String get transferHistoryTransferHistory => '转账记录';

  @override
  String get transferHistoryReceivedHistory => '收到记录';

  @override
  String get comment_transfer_received_history_screen => '==== 转账收到记录页面 ====';

  @override
  String get transferReceivedHistoryScreenTitle => '收到记录';

  @override
  String get comment_transfer_received_filter_bottom_sheet =>
      '==== 转账收到筛选底部表单 ====';

  @override
  String get transferReceivedFilterTransactionId => '交易 ID';

  @override
  String get transferReceivedFilterStatus => '状态';

  @override
  String get transferReceivedFilterApplyButton => '筛选';

  @override
  String get transferReceivedFilterResetButton => '重置';

  @override
  String get comment_transfer_history_screen => '==== 转账记录页面 ====';

  @override
  String get transferHistoryScreenTitle => '转账记录';

  @override
  String get comment_transfer_transaction_filter_bottom_sheet =>
      '==== 转账交易筛选底部表单 ====';

  @override
  String get transferTransactionFilterTransactionId => '交易 ID';

  @override
  String get transferTransactionFilterStatus => '状态';

  @override
  String get transferTransactionFilterApplyButton => '筛选';

  @override
  String get transferTransactionFilterResetButton => '重置';

  @override
  String get comment_transfer_amount_step_section => '==== 转账金额步骤部分 ====';

  @override
  String get transferAmountStepSectionRecipientUid => '收款人 UID';

  @override
  String get transferAmountStepSectionAmount => '金额';

  @override
  String get transferAmountStepSectionMin => '最低';

  @override
  String get transferAmountStepSectionMax => '和最高';

  @override
  String get transferAmountStepSectionTransferMoneyButton => '转账';

  @override
  String get transferAmountStepSectionSavedBeneficiaryButton => '已保存受益人';

  @override
  String get transferAmountStepSectionInvalidQrCodeDigits =>
      '无效的二维码。收款人 UID 必须仅为数字。';

  @override
  String get transferAmountStepSectionInvalidQrCodePrefix =>
      '无效的二维码。未找到 UID 前缀。';

  @override
  String get transferAmountStepSectionBeneficiariesTitle => '受益人';

  @override
  String get transferAmountStepSectionAddBeneficiary => '添加受益人';

  @override
  String get transferAmountStepSectionUidLabel => 'UID：';

  @override
  String get transferAmountStepSectionDeleteConfirmationTitle => '您确定吗？';

  @override
  String get transferAmountStepSectionDeleteConfirmationMessage => '您要删除此受益人吗？';

  @override
  String get transferAmountStepSectionDeleteButton => '删除';

  @override
  String get transferAmountStepSectionCancelButton => '取消';

  @override
  String get comment_transfer_review_step_section => '==== 转账审核步骤部分 ====';

  @override
  String get transferReviewStepSectionTitle => '审核详情';

  @override
  String get transferReviewStepSectionAmount => '金额';

  @override
  String get transferReviewStepSectionWallet => '钱包';

  @override
  String get transferReviewStepSectionRecipientAccount => '收款人账户';

  @override
  String get transferReviewStepSectionCharge => '手续费';

  @override
  String get transferReviewStepSectionTotalAmount => '总金额';

  @override
  String get transferReviewStepSectionBackButton => '返回';

  @override
  String get transferReviewStepSectionConfirmButton => '确认';

  @override
  String get comment_transfer_success_step_section => '==== 转账成功步骤部分 ====';

  @override
  String get transferSuccessStepSectionTitle => '转账成功！';

  @override
  String get transferSuccessStepSectionAmount => '金额';

  @override
  String get transferSuccessStepSectionTransactionId => '交易 ID';

  @override
  String get transferSuccessStepSectionWalletName => '钱包名称';

  @override
  String get transferSuccessStepSectionPaymentMethod => '支付方式';

  @override
  String get transferSuccessStepSectionDateTime => '日期与时间';

  @override
  String get transferSuccessStepSectionName => '姓名';

  @override
  String get transferSuccessStepSectionCharge => '手续费';

  @override
  String get transferSuccessStepSectionTotalAmount => '总金额';

  @override
  String get transferSuccessStepSectionTransferAgainButton => '再次转账';

  @override
  String get transferSuccessStepSectionBackHomeButton => '返回首页';

  @override
  String get comment_transfer_wallet_section => '==== 转账钱包部分 ====';

  @override
  String get transferWalletSectionBalance => '余额';

  @override
  String get transferWalletSectionWalletsNotFound => '未找到钱包';

  @override
  String get comment_wallets_screen => '==== 钱包页面 ====';

  @override
  String get walletsScreenTitle => '我的钱包';

  @override
  String get comment_delete_wallet_bottom_sheet => '==== 删除钱包底部表单 ====';

  @override
  String get deleteWalletBottomSheetTitle => '您确定吗？';

  @override
  String get deleteWalletBottomSheetMessage => '您要删除此钱包吗？';

  @override
  String get deleteWalletBottomSheetDeleteButton => '删除';

  @override
  String get deleteWalletBottomSheetCancelButton => '取消';

  @override
  String get comment_wallet_list_section => '==== 钱包列表部分 ====';

  @override
  String get walletListSectionTopUpButton => '充值';

  @override
  String get walletListSectionWithdrawButton => '提现';

  @override
  String get walletListSectionUserDepositNotEnabled => '用户存款未启用';

  @override
  String get walletListSectionUserWithdrawNotEnabled => '用户提现未启用';

  @override
  String get comment_create_new_wallet_screen => '==== 创建新钱包页面 ====';

  @override
  String get createNewWalletScreenTitle => '创建新钱包';

  @override
  String get createNewWalletCurrency => '货币';

  @override
  String get createNewWalletSelectCurrency => '选择货币';

  @override
  String get createNewWalletCurrencyNotFound => '未找到货币';

  @override
  String get createNewWalletCreateButton => '创建';

  @override
  String get comment_withdraw_screen => '==== 提现页面 ====';

  @override
  String get withdrawScreenTitle => '提现';

  @override
  String get withdrawScreenAddAccountButton => '添加账户';

  @override
  String get comment_withdraw_history_screen => '==== 提现记录页面 ====';

  @override
  String get withdrawHistoryScreenTitle => '提现记录';

  @override
  String get comment_withdraw_transaction_filter_bottom_sheet =>
      '==== 提现交易筛选底部表单 ====';

  @override
  String get withdrawTransactionFilterTransactionId => '交易 ID';

  @override
  String get withdrawTransactionFilterStatus => '状态';

  @override
  String get withdrawTransactionFilterApplyButton => '筛选';

  @override
  String get withdrawTransactionFilterResetButton => '重置';

  @override
  String get comment_delete_account_dropdown_section => '==== 删除账户下拉部分 ====';

  @override
  String get deleteAccountDropdownTitle => '您确定吗？';

  @override
  String get deleteAccountDropdownMessage => '您要删除此账户吗？';

  @override
  String get deleteAccountDropdownDeleteButton => '删除';

  @override
  String get deleteAccountDropdownCancelButton => '取消';

  @override
  String get comment_withdraw_account_filter_bottom_sheet =>
      '==== 提现账户筛选底部表单 ====';

  @override
  String get withdrawAccountFilterMethodName => '方式名称';

  @override
  String get withdrawAccountFilterApplyButton => '筛选';

  @override
  String get comment_withdraw_account_section => '==== 提现账户部分 ====';

  @override
  String get withdrawAccountSectionTitle => '所有账户';

  @override
  String get comment_withdraw_amount_step_section => '==== 提现金额步骤部分 ====';

  @override
  String get withdrawAmountStepSectionWithdrawAccount => '提现账户';

  @override
  String get withdrawAmountStepSectionAmount => '金额';

  @override
  String get withdrawAmountStepSectionMin => '最低';

  @override
  String get withdrawAmountStepSectionMax => '和最高';

  @override
  String get withdrawAmountStepSectionWithdrawMoneyButton => '提现';

  @override
  String get withdrawAmountStepSectionWithdrawAccountTitle => '提现账户';

  @override
  String get withdrawAmountStepSectionNoAccountsFound => '未找到提现账户';

  @override
  String get withdrawAmountStepSectionCurrencyLabel => '货币：';

  @override
  String get withdrawAmountStepSectionMinDescription => '最低：';

  @override
  String get withdrawAmountStepSectionMaxDescription => '最高：';

  @override
  String get comment_withdraw_header_section => '==== 提现头部部分 ====';

  @override
  String get withdrawHeaderSectionTitle => '提现';

  @override
  String get withdrawHeaderSectionWithdrawButton => '提现';

  @override
  String get withdrawHeaderSectionWithdrawAccountButton => '提现账户';

  @override
  String get withdrawHeaderSectionHistory => '提现记录';

  @override
  String get comment_withdraw_review_step_section => '==== 提现审核步骤部分 ====';

  @override
  String get withdrawReviewStepSectionTitle => '审核详情';

  @override
  String get withdrawReviewStepSectionAmount => '金额';

  @override
  String get withdrawReviewStepSectionCharge => '手续费';

  @override
  String get withdrawReviewStepSectionTotalAmount => '总金额';

  @override
  String get withdrawReviewStepSectionBackButton => '返回';

  @override
  String get withdrawReviewStepSectionConfirmButton => '确认';

  @override
  String get comment_withdraw_success_step_section => '==== 提现成功步骤部分 ====';

  @override
  String get withdrawSuccessStepSectionTitle => '提现成功！';

  @override
  String get withdrawSuccessStepSectionAmount => '金额';

  @override
  String get withdrawSuccessStepSectionTransactionId => '交易 ID';

  @override
  String get withdrawSuccessStepSectionCharge => '手续费';

  @override
  String get withdrawSuccessStepSectionTransactionType => '交易类型';

  @override
  String get withdrawSuccessStepSectionFinalAmount => '最终金额';

  @override
  String get withdrawSuccessStepSectionWithdrawAgainButton => '再次提现';

  @override
  String get withdrawSuccessStepSectionBackHomeButton => '返回首页';

  @override
  String get comment_edit_withdraw_account_screen => '==== 编辑提现账户页面 ====';

  @override
  String get editWithdrawAccountTitle => '更新提现账户';

  @override
  String get editWithdrawAccountMethodName => '方式名称';

  @override
  String get editWithdrawAccountMethodNameHint => '输入方式名称';

  @override
  String get editWithdrawAccountFieldHint => '在此输入...';

  @override
  String get editWithdrawAccountGenericFieldHint => '输入';

  @override
  String get editWithdrawAccountUpdateButton => '更新账户';

  @override
  String get comment_create_withdraw_account_screen => '==== 创建提现账户页面 ====';

  @override
  String get createWithdrawAccountTitle => '创建提现账户';

  @override
  String get createWithdrawAccountWallet => '钱包';

  @override
  String get createWithdrawAccountWithdrawMethod => '提现方式';

  @override
  String get createWithdrawAccountMethodName => '方式名称';

  @override
  String get createWithdrawAccountCreateButton => '创建账户';

  @override
  String get createWithdrawAccountWalletsNotFound => '未找到钱包';

  @override
  String get createWithdrawAccountWithdrawMethodTitle => '提现方式';

  @override
  String get createWithdrawAccountWithdrawMethodNotFound => '未找到提现方式';

  @override
  String get createWithdrawAccountFieldHint => '在此输入...';

  @override
  String get comment_dynamic_attachment_preview => '==== 动态附件预览 ====';

  @override
  String get dynamicAttachmentPreviewTitle => '附件预览';

  @override
  String get comment_no_internet_connection => '==== 无网络连接 ====';

  @override
  String get noInternetConnectionTitle => '无网络连接';

  @override
  String get noInternetConnectionMessage => '请检查您的网络设置';

  @override
  String get noInternetConnectionRetryButton => '重试';

  @override
  String get comment_qr_scanner_screen => '==== 二维码扫描页面 ====';

  @override
  String get qrScannerScreenInstruction => '将二维码置于框内进行扫描';

  @override
  String get qrScannerScreenProcessing => '处理中...';

  @override
  String get comment_webview_screen => '==== WebView 页面 ====';

  @override
  String get webViewScreenPaymentSuccessful => '支付成功！';

  @override
  String get webViewScreenPaymentFailed => '支付失败！';

  @override
  String get webViewScreenPaymentCancelled => '支付已取消！';

  @override
  String get comment_common_country_dropdown_bottom_sheet =>
      '==== 通用国家下拉底部表单 ====';

  @override
  String get commonCountryDropdownSearchHint => '搜索';

  @override
  String get commonCountryDropdownNotFound => '未找到国家';

  @override
  String get comment_common_dropdown_bottom_sheet => '==== 通用下拉底部表单 ====';

  @override
  String get commonDropdownSearchHint => '搜索';

  @override
  String get comment_common_dropdown_bottom_sheet_three =>
      '==== 通用下拉底部表单三 ====';

  @override
  String get commonDropdownThreeSearchHint => '搜索';

  @override
  String get comment_common_dropdown_bottom_sheet_two => '==== 通用下拉底部表单二 ====';

  @override
  String get commonDropdownTwoSearchHint => '搜索';

  @override
  String get comment_common_dropdown_wallet_bottom_sheet =>
      '==== 通用钱包下拉底部表单 ====';

  @override
  String get commonDropdownWalletTitle => '选择钱包';

  @override
  String get comment_image_picker_dropdown_bottom_sheet =>
      '==== 图片选择下拉底部表单 ====';

  @override
  String get imagePickerDropdownTitle => '选择图片来源';

  @override
  String get imagePickerDropdownCamera => '相机';

  @override
  String get imagePickerDropdownGallery => '图库';

  @override
  String get comment_multiple_image_picker_dropdown_bottom_sheet =>
      '==== 多图片选择下拉底部表单 ====';

  @override
  String get multipleImagePickerDropdownTitle => '图片来源';

  @override
  String get multipleImagePickerDropdownCamera => '相机';

  @override
  String get multipleImagePickerDropdownGallery => '图库';

  @override
  String get comment_navigation_screen => '==== 导航页面 ====';

  @override
  String get bottomNavHome => '首页';

  @override
  String get bottomNavTransfer => '转账';

  @override
  String get bottomNavGift => '礼品';

  @override
  String get bottomNavSettings => '设置';

  @override
  String get qrInvalidFormat => '无效的二维码格式。仅接受 AID、MID 或 UID 代码。';

  @override
  String get userTransferNotEnabled => '用户转账未启用';

  @override
  String get userGiftNotEnabled => '用户礼品未启用';

  @override
  String get comment_image_picker_controller => '==== 图片选择控制器 ====';

  @override
  String get imagePickerGalleryError => '从图库选择图片失败';

  @override
  String get imagePickerCameraError => '从相机选择图片失败';

  @override
  String get comment_multiple_image_picker_controller => '==== 多图片选择控制器 ====';

  @override
  String get multipleImagePickerGalleryError => '从图库选择图片失败';

  @override
  String get multipleImagePickerCameraError => '从相机选择图片失败';

  @override
  String get comment_biometric_auth_service => '==== 生物识别认证服务 ====';

  @override
  String get biometricDeviceNotSupported => '此设备不支持生物识别。';

  @override
  String get biometricNotEnrolled => '未注册生物识别。请设置指纹';

  @override
  String get biometricUnavailable => '生物识别功能当前不可用。';

  @override
  String get biometricAuthenticationFailed => '生物识别认证失败。';

  @override
  String get biometricCheckFailed => '无法检查生物识别可用性。';

  @override
  String get biometricAuthReason => '验证以登录';

  @override
  String get comment_network_service => '==== 网络服务 ====';

  @override
  String get networkErrorGeneric => '发生意外错误。请重试。';

  @override
  String get networkErrorTimeout => '请求超时。请重试。';

  @override
  String get networkErrorOccurred => '发生错误。请重试。';

  @override
  String get unauthorizedDialogTitle => '未授权';

  @override
  String get unauthorizedDialogDescription => '您无权访问此资源。请重新登录！';

  @override
  String get unauthorizedDialogButton => '确定';

  @override
  String get comment_add_money_controller => '==== 添加资金控制器 ====';

  @override
  String get addMoneySuccess => '资金添加成功';

  @override
  String get addMoneyValidationSelectWallet => '请选择钱包';

  @override
  String get addMoneyValidationSelectGateway => '请选择网关';

  @override
  String get addMoneyValidationEnterAmount => '请输入金额';

  @override
  String get addMoneyValidationAmountGreaterThanZero => '金额必须大于 0';

  @override
  String addMoneyValidationAmountMinimum(Object amount) {
    return '金额不得超过 $amount';
  }

  @override
  String addMoneyValidationAmountMaximum(Object amount) {
    return '金额不得超过 $amount';
  }

  @override
  String addMoneyValidationUploadFile(Object fieldName) {
    return '请为 $fieldName 上传文件';
  }

  @override
  String addMoneyValidationFillField(Object fieldName) {
    return '请填写 $fieldName 字段';
  }

  @override
  String get comment_cash_out_controller => '==== 提现控制器 ====';

  @override
  String get cashOutValidationSelectWallet => '请选择钱包';

  @override
  String get cashOutValidationEnterAgentAid => '请输入代理 AID';

  @override
  String get cashOutValidationEnterAmount => '请输入金额';

  @override
  String cashOutValidationAmountMinimum(Object amount, Object currency) {
    return '最低金额应为 $amount $currency';
  }

  @override
  String cashOutValidationAmountMaximum(Object amount, Object currency) {
    return '最高金额应为 $amount $currency';
  }

  @override
  String get comment_exchange_controller => '==== 兑换控制器 ====';

  @override
  String get exchangeValidationSelectFromWallet => '请选择来源钱包';

  @override
  String get exchangeValidationSelectToWallet => '请选择目标钱包';

  @override
  String get exchangeValidationEnterAmount => '请输入金额';

  @override
  String exchangeValidationAmountMinimum(Object amount, Object currency) {
    return '最低金额应为 $amount $currency';
  }

  @override
  String exchangeValidationAmountMaximum(Object amount, Object currency) {
    return '最高金额应为 $amount $currency';
  }

  @override
  String get comment_create_gift_controller => '==== 创建礼品控制器 ====';

  @override
  String get createGiftValidationSelectWallet => '请选择钱包';

  @override
  String get createGiftValidationEnterAmount => '请输入金额';

  @override
  String createGiftValidationAmountMinimum(Object amount, Object currency) {
    return '最低金额应为 $amount $currency';
  }

  @override
  String createGiftValidationAmountMaximum(Object amount, Object currency) {
    return '最高金额应为 $amount $currency';
  }

  @override
  String get comment_home_controller => '==== 首页控制器 ====';

  @override
  String get homeLanguageChangeFailed => '更改语言失败';

  @override
  String get homeBiometricDeviceNotSupported => '此设备不支持生物识别。';

  @override
  String get homeBiometricAuthenticationFailed => '认证失败。生物识别设置未更改。';

  @override
  String get homeBiometricEnabledSuccess => '生物识别启用成功';

  @override
  String get homeBiometricDisabledSuccess => '生物识别禁用成功';

  @override
  String get homeBiometricNotFoundTitle => '未找到生物识别';

  @override
  String get homeBiometricNotFoundDescription =>
      '此设备上未注册指纹或生物识别。您可以从系统设置中进行设置。';

  @override
  String get homeBiometricOpenSettings => '打开安全设置';

  @override
  String get homeIosBiometricSetup => '请前往 设置 > Face ID 与密码 设置生物识别。';

  @override
  String get comment_create_invoice_controller => '==== 创建发票控制器 ====';

  @override
  String get createInvoiceValidationEnterInvoiceTo => '请输入发票接收人';

  @override
  String get createInvoiceValidationEnterEmailAddress => '请输入邮箱地址';

  @override
  String get createInvoiceValidationEnterAddress => '请输入地址';

  @override
  String get createInvoiceValidationSelectWallet => '请选择钱包';

  @override
  String get createInvoiceValidationSelectStatus => '请选择状态';

  @override
  String get createInvoiceValidationSelectIssueDate => '请选择开具日期';

  @override
  String createInvoiceValidationItemNameRequired(Object itemNumber) {
    return '项目 $itemNumber：名称为必填';
  }

  @override
  String createInvoiceValidationItemQuantityGreaterThanZero(Object itemNumber) {
    return '项目 $itemNumber：数量必须大于 0';
  }

  @override
  String createInvoiceValidationItemUnitPriceGreaterThanZero(
    Object itemNumber,
  ) {
    return '项目 $itemNumber：单价必须大于 0';
  }

  @override
  String get comment_make_payment_controller => '==== 付款控制器 ====';

  @override
  String get makePaymentValidationSelectWallet => '请选择钱包';

  @override
  String get makePaymentValidationEnterMerchantMid => '请输入商户 MID';

  @override
  String get makePaymentValidationEnterAmount => '请输入金额';

  @override
  String makePaymentValidationAmountMinimum(Object amount, Object currency) {
    return '最低金额应为 $amount $currency';
  }

  @override
  String makePaymentValidationAmountMaximum(Object amount, Object currency) {
    return '最高金额应为 $amount $currency';
  }

  @override
  String get comment_request_money_controller => '==== 请求资金控制器 ====';

  @override
  String get requestMoneyValidationSelectWallet => '请选择钱包';

  @override
  String get requestMoneyValidationEnterRecipientUid => '请输入收款人 UID';

  @override
  String get requestMoneyValidationEnterRequestAmount => '请输入请求金额';

  @override
  String requestMoneyValidationAmountMinimum(Object amount, Object currency) {
    return '最低金额应为 $amount $currency';
  }

  @override
  String requestMoneyValidationAmountMaximum(Object amount, Object currency) {
    return '最高金额应为 $amount $currency';
  }

  @override
  String get comment_add_new_ticket_controller => '==== 添加新工单控制器 ====';

  @override
  String get addNewTicketSuccess => '工单创建成功';

  @override
  String get addNewValidationEnterTitle => '请输入标题';

  @override
  String get addNewValidationEnterDescription => '请输入描述';

  @override
  String get comment_change_password_controller => '==== 修改密码控制器 ====';

  @override
  String get changePasswordValidationEnterCurrentPassword => '请输入当前密码';

  @override
  String get changePasswordValidationEnterNewPassword => '请输入新密码';

  @override
  String get changePasswordValidationPasswordMinLength => '密码至少需要 8 个字符';

  @override
  String get changePasswordValidationEnterConfirmPassword => '请输入确认密码';

  @override
  String get changePasswordValidationPasswordsDoNotMatch => '密码不匹配';

  @override
  String get comment_transfer_controller => '==== 转账控制器 ====';

  @override
  String get transferValidationSelectWallet => '请选择钱包';

  @override
  String get transferValidationEnterRecipientUid => '请输入收款人 UID';

  @override
  String get transferValidationEnterAmount => '请输入金额';

  @override
  String transferValidationAmountMinimum(Object amount, Object currency) {
    return '最低金额应为 $amount $currency';
  }

  @override
  String transferValidationAmountMaximum(Object amount, Object currency) {
    return '最高金额应为 $amount $currency';
  }

  @override
  String get comment_create_withdraw_account_controller =>
      '==== 创建提现账户控制器 ====';

  @override
  String createWithdrawAccountFileRequiredError(Object fieldName) {
    return '$fieldName 需要文件';
  }

  @override
  String createWithdrawAccountFieldRequiredError(Object fieldName) {
    return '字段 $fieldName 为必填';
  }

  @override
  String get createWithdrawAccountValidationSelectWallet => '请选择钱包';

  @override
  String get createWithdrawAccountValidationSelectWithdrawMethod => '请选择提现方式';

  @override
  String get createWithdrawAccountValidationEnterMethodName => '请输入方式名称';

  @override
  String createWithdrawAccountValidationUploadFile(Object fieldName) {
    return '请为 $fieldName 上传文件';
  }

  @override
  String createWithdrawAccountValidationFillField(Object fieldName) {
    return '请填写 $fieldName 字段';
  }

  @override
  String get comment_withdraw_controller => '==== 提现控制器 ====';

  @override
  String get withdrawValidationSelectWithdrawAccount => '请选择提现账户';

  @override
  String get withdrawValidationEnterAmount => '请输入金额';

  @override
  String withdrawValidationAmountMinimum(Object amount, Object currency) {
    return '最低金额应为 $amount $currency';
  }

  @override
  String withdrawValidationAmountMaximum(Object amount, Object currency) {
    return '最高金额应为 $amount $currency';
  }

  @override
  String get comment_airtime_controller => '==== 话费控制器 ====';

  @override
  String get airtimeCountryRequired => '请选择国家';

  @override
  String get airtimeServiceRequired => '请选择服务';

  @override
  String get airtimeAmountRequired => '请输入金额';

  @override
  String get airtimeAmountValid => '请输入有效金额';

  @override
  String airtimeDynamicFieldRequired(Object fieldName) {
    return '请输入 $fieldName';
  }

  @override
  String get comment_cable_controller => '==== 有线电视控制器 ====';

  @override
  String get cableCountryRequired => '请选择国家';

  @override
  String get cableServiceRequired => '请选择服务';

  @override
  String get cableAmountRequired => '请输入金额';

  @override
  String get cableAmountValid => '请输入有效金额';

  @override
  String cableDynamicFieldRequired(Object fieldName) {
    return '请输入 $fieldName';
  }

  @override
  String get comment_toll_controller => '==== 通行费控制器 ====';

  @override
  String get tollCountryRequired => '请选择国家';

  @override
  String get tollServiceRequired => '请选择服务';

  @override
  String get tollAmountRequired => '请输入金额';

  @override
  String get tollAmountValid => '请输入有效金额';

  @override
  String tollDynamicFieldRequired(Object fieldName) {
    return '请输入 $fieldName';
  }

  @override
  String get comment_electricity_controller => '==== 电费控制器 ====';

  @override
  String get electricityCountryRequired => '请选择国家';

  @override
  String get electricityServiceRequired => '请选择服务';

  @override
  String get electricityAmountRequired => '请输入金额';

  @override
  String get electricityAmountValid => '请输入有效金额';

  @override
  String electricityDynamicFieldRequired(Object fieldName) {
    return '请输入 $fieldName';
  }

  @override
  String get comment_internet_controller => '==== 互联网控制器 ====';

  @override
  String get internetCountryRequired => '请选择国家';

  @override
  String get internetServiceRequired => '请选择服务';

  @override
  String get internetAmountRequired => '请输入金额';

  @override
  String get internetAmountValid => '请输入有效金额';

  @override
  String internetDynamicFieldRequired(Object fieldName) {
    return '请输入 $fieldName';
  }

  @override
  String get comment_data_bundle_controller => '==== 数据包控制器 ====';

  @override
  String get dataBundleCountryRequired => '请选择国家';

  @override
  String get dataBundleServiceRequired => '请选择服务';

  @override
  String get dataBundleAmountRequired => '请输入金额';

  @override
  String get dataBundleAmountValid => '请输入有效金额';

  @override
  String dataBundleDynamicFieldRequired(Object fieldName) {
    return '请输入 $fieldName';
  }

  @override
  String get comment_airtime_screen => '==== 话费页面 ====';

  @override
  String get airtimeAppBarTitle => '话费';

  @override
  String get comment_airtime_amount_section => '==== 话费金额步骤部分 ====';

  @override
  String get airtimeCountryLabel => '国家';

  @override
  String get airtimeCountryHint => '选择国家';

  @override
  String get airtimeCountrySelectTitle => '选择国家';

  @override
  String get airtimeCountryNotFound => '未找到国家';

  @override
  String get airtimeServiceLabel => '服务';

  @override
  String get airtimeServiceHint => '选择服务';

  @override
  String get airtimeServiceSelectTitle => '选择服务';

  @override
  String get airtimeServiceNotFound => '未找到服务';

  @override
  String get airtimeAmountLabel => '金额';

  @override
  String get airtimePayButton => '立即支付';

  @override
  String get comment_airtime_review_section => '==== 话费审核步骤部分 ====';

  @override
  String get airtimeReviewTitle => '审核详情';

  @override
  String get airtimeReviewAmountLabel => '金额';

  @override
  String get airtimeReviewChargeLabel => '手续费';

  @override
  String get airtimeReviewConversionRateLabel => '兑换率';

  @override
  String get airtimeReviewPayableAmountLabel => '应付金额';

  @override
  String get airtimeReviewBackButton => '返回';

  @override
  String get airtimeReviewConfirmButton => '确认';

  @override
  String get comment_bill_payment_history => '==== 账单支付记录 ====';

  @override
  String get billPaymentHistoryTitle => '账单支付记录';

  @override
  String get comment_bill_payment_details => '==== 账单支付详情表单 ====';

  @override
  String get billPaymentDetailsTitle => '账单支付详情';

  @override
  String get billPaymentDetailsTime => '时间';

  @override
  String get billPaymentDetailsAmount => '金额';

  @override
  String get billPaymentDetailsCharge => '手续费';

  @override
  String get billPaymentDetailsMethod => '方式';

  @override
  String get billPaymentDetailsStatus => '状态';

  @override
  String get comment_cable_screen => '==== 有线电视页面 ====';

  @override
  String get cableTitle => '有线电视';

  @override
  String get comment_cable_amount_section => '==== 有线电视金额步骤部分 ====';

  @override
  String get cableCountryLabel => '国家';

  @override
  String get cableCountryHint => '选择国家';

  @override
  String get cableCountrySelectTitle => '选择国家';

  @override
  String get cableCountryNotFound => '未找到国家';

  @override
  String get cableServiceLabel => '服务';

  @override
  String get cableServiceHint => '选择服务';

  @override
  String get cableServiceSelectTitle => '选择服务';

  @override
  String get cableServiceNotFound => '未找到服务';

  @override
  String get cableAmountLabel => '金额';

  @override
  String get cablePayButton => '立即支付';

  @override
  String get comment_cable_review_section => '==== 有线电视审核步骤部分 ====';

  @override
  String get cableReviewTitle => '审核详情';

  @override
  String get cableReviewAmountLabel => '金额';

  @override
  String get cableReviewChargeLabel => '手续费';

  @override
  String get cableReviewConversionRateLabel => '兑换率';

  @override
  String get cableReviewPayableAmountLabel => '应付金额';

  @override
  String get cableReviewBackButton => '返回';

  @override
  String get cableReviewConfirmButton => '确认';

  @override
  String get comment_toll_screen => '==== 通行费页面 ====';

  @override
  String get tollTitle => '通行费';

  @override
  String get comment_toll_amount_section => '==== 通行费金额步骤部分 ====';

  @override
  String get tollCountryLabel => '国家';

  @override
  String get tollCountryHint => '选择国家';

  @override
  String get tollCountrySelectTitle => '选择国家';

  @override
  String get tollCountryNotFound => '未找到国家';

  @override
  String get tollServiceLabel => '服务';

  @override
  String get tollServiceHint => '选择服务';

  @override
  String get tollServiceSelectTitle => '选择服务';

  @override
  String get tollServiceNotFound => '未找到服务';

  @override
  String get tollAmountLabel => '金额';

  @override
  String get tollPayButton => '立即支付';

  @override
  String get comment_toll_review_section => '==== 通行费审核步骤部分 ====';

  @override
  String get tollReviewTitle => '审核详情';

  @override
  String get tollReviewAmountLabel => '金额';

  @override
  String get tollReviewChargeLabel => '手续费';

  @override
  String get tollReviewConversionRateLabel => '兑换率';

  @override
  String get tollReviewPayableAmountLabel => '应付金额';

  @override
  String get tollReviewBackButton => '返回';

  @override
  String get tollReviewConfirmButton => '确认';

  @override
  String get comment_electricity_screen => '==== 电费页面 ====';

  @override
  String get electricityTitle => '电费';

  @override
  String get comment_electricity_amount_section => '==== 电费金额步骤部分 ====';

  @override
  String get electricityCountryLabel => '国家';

  @override
  String get electricityCountryHint => '选择国家';

  @override
  String get electricityCountrySelectTitle => '选择国家';

  @override
  String get electricityCountryNotFound => '未找到国家';

  @override
  String get electricityServiceLabel => '服务';

  @override
  String get electricityServiceHint => '选择服务';

  @override
  String get electricityServiceSelectTitle => '选择服务';

  @override
  String get electricityServiceNotFound => '未找到服务';

  @override
  String get electricityAmountLabel => '金额';

  @override
  String get electricityPayButton => '立即支付';

  @override
  String get comment_electricity_review_section => '==== 电费审核步骤部分 ====';

  @override
  String get electricityReviewTitle => '审核详情';

  @override
  String get electricityReviewAmountLabel => '金额';

  @override
  String get electricityReviewChargeLabel => '手续费';

  @override
  String get electricityReviewConversionRateLabel => '兑换率';

  @override
  String get electricityReviewPayableAmountLabel => '应付金额';

  @override
  String get electricityReviewBackButton => '返回';

  @override
  String get electricityReviewConfirmButton => '确认';

  @override
  String get comment_internet_screen => '==== 互联网页面 ====';

  @override
  String get internetTitle => '互联网';

  @override
  String get comment_internet_amount_section => '==== 互联网金额步骤部分 ====';

  @override
  String get internetCountryLabel => '国家';

  @override
  String get internetCountryHint => '选择国家';

  @override
  String get internetCountrySelectTitle => '选择国家';

  @override
  String get internetCountryNotFound => '未找到国家';

  @override
  String get internetServiceLabel => '服务';

  @override
  String get internetServiceHint => '选择服务';

  @override
  String get internetServiceSelectTitle => '选择服务';

  @override
  String get internetServiceNotFound => '未找到服务';

  @override
  String get internetAmountLabel => '金额';

  @override
  String get internetPayButton => '立即支付';

  @override
  String get comment_internet_review_section => '==== 互联网审核步骤部分 ====';

  @override
  String get internetReviewTitle => '审核详情';

  @override
  String get internetReviewAmountLabel => '金额';

  @override
  String get internetReviewChargeLabel => '手续费';

  @override
  String get internetReviewConversionRateLabel => '兑换率';

  @override
  String get internetReviewPayableAmountLabel => '应付金额';

  @override
  String get internetReviewBackButton => '返回';

  @override
  String get internetReviewConfirmButton => '确认';

  @override
  String get comment_data_bundle_screen => '==== 数据包页面 ====';

  @override
  String get dataBundleTitle => '数据包';

  @override
  String get comment_data_bundle_amount_section => '==== 数据包金额步骤部分 ====';

  @override
  String get dataBundleCountryLabel => '国家';

  @override
  String get dataBundleCountryHint => '选择国家';

  @override
  String get dataBundleCountrySelectTitle => '选择国家';

  @override
  String get dataBundleCountryNotFound => '未找到国家';

  @override
  String get dataBundleServiceLabel => '服务';

  @override
  String get dataBundleServiceHint => '选择服务';

  @override
  String get dataBundleServiceSelectTitle => '选择服务';

  @override
  String get dataBundleServiceNotFound => '未找到服务';

  @override
  String get dataBundleAmountLabel => '金额';

  @override
  String get dataBundlePayButton => '立即支付';

  @override
  String get comment_data_bundle_review_section => '==== 数据包审核步骤部分 ====';

  @override
  String get dataBundleReviewTitle => '审核详情';

  @override
  String get dataBundleReviewAmountLabel => '金额';

  @override
  String get dataBundleReviewChargeLabel => '手续费';

  @override
  String get dataBundleReviewConversionRateLabel => '兑换率';

  @override
  String get dataBundleReviewPayableAmountLabel => '应付金额';

  @override
  String get dataBundleReviewBackButton => '返回';

  @override
  String get dataBundleReviewConfirmButton => '确认';

  @override
  String get comment_bill_payment_screen => '==== 账单支付主页面 ====';

  @override
  String get billPaymentScreenTitle => '账单支付';

  @override
  String get billPaymentAirtime => '话费';

  @override
  String get billPaymentElectricity => '电费';

  @override
  String get billPaymentInternet => '互联网';

  @override
  String get billPaymentDataBundle => '数据包';

  @override
  String get billPaymentCables => '有线电视';

  @override
  String get billPaymentToll => '通行费';

  @override
  String get comment_create_virtual_card_controller => '==== 创建虚拟卡控制器 ====';

  @override
  String get createCardProviderRequired => '请选择卡提供商';

  @override
  String get createCardHolderRequired => '请选择持卡人';

  @override
  String get createNameRequired => '请输入姓名';

  @override
  String get createEmailRequired => '请输入邮箱';

  @override
  String get createEmailInvalid => '请输入有效的邮箱';

  @override
  String get createPhoneNumberRequired => '请输入电话号码';

  @override
  String get createCountryRequired => '请选择国家';

  @override
  String get createCityRequired => '请输入城市';

  @override
  String get createStateRequired => '请输入州/省';

  @override
  String get createPostalCodeRequired => '请输入邮政编码';

  @override
  String get createAddressRequired => '请输入地址';

  @override
  String get comment_virtual_card_details_controller => '==== 虚拟卡详情控制器 ====';

  @override
  String get cardDetailsEnterAmount => '请输入金额';

  @override
  String get cardDetailsAmountGreaterThanZero => '金额必须大于 0';

  @override
  String cardDetailsAmountMinimumLimit(Object amount) {
    return '金额不得超过 $amount';
  }

  @override
  String cardDetailsAmountMaximumLimit(Object amount) {
    return '金额不得超过 $amount';
  }

  @override
  String get comment_card_holder_tab_section => '==== 持卡人标签部分 ====';

  @override
  String get cardHolderTabExistingCardholders => '现有持卡人';

  @override
  String get cardHolderTabCreateCardholder => '创建持卡人';

  @override
  String get comment_choose_card_holder_section => '==== 选择持卡人部分 ====';

  @override
  String get chooseCardHolderLabel => '持卡人';

  @override
  String get chooseCardHolderDropdownNotFound => '未找到持卡人';

  @override
  String get chooseCardHolderDropdownTitle => '选择持卡人';

  @override
  String get chooseCardHolderButtonCreate => '立即创建';

  @override
  String get comment_choose_card_provider_section => '==== 选择卡提供商部分 ====';

  @override
  String get chooseCardProviderLabel => '卡提供商';

  @override
  String get chooseCardProviderDropdownNotFound => '未找到卡提供商';

  @override
  String get chooseCardProviderDropdownTitle => '选择卡提供商';

  @override
  String get comment_create_new_card_holder_section => '==== 创建新持卡人部分 ====';

  @override
  String get createCardHolderLabelName => '姓名';

  @override
  String get createCardHolderLabelEmail => '邮箱';

  @override
  String get createCardHolderLabelPhoneNumber => '电话号码';

  @override
  String get createCardHolderLabelCountry => '国家';

  @override
  String get createCardHolderDropdownCountryNotFound => '未找到国家';

  @override
  String get createCardHolderDropdownCountryTitle => '选择国家';

  @override
  String get createCardHolderLabelCity => '城市';

  @override
  String get createCardHolderLabelState => '州/省';

  @override
  String get createCardHolderLabelPostalCode => '邮政编码';

  @override
  String get createCardHolderLabelAddress => '地址';

  @override
  String get createCardHolderButtonCreate => '立即创建';

  @override
  String get comment_create_virtual_card_screen => '==== 创建虚拟卡页面 ====';

  @override
  String get createVirtualCardAppBarTitle => '创建新卡';

  @override
  String get comment_get_card_info_screen => '==== 获取卡信息页面 ====';

  @override
  String get getCardInfoAppBarTitle => '获取卡';

  @override
  String get getCardInfoBenefitsTitle => '虚拟卡的好处';

  @override
  String get getCardInfoBenefitSecurityTitle => '更好的安全性';

  @override
  String get getCardInfoBenefitSecuritySubtitle => '您的真实卡号保持隐藏';

  @override
  String get getCardInfoBenefitShoppingTitle => '安全的在线购物';

  @override
  String get getCardInfoBenefitShoppingSubtitle => '仅为在线购物创建虚拟卡';

  @override
  String get getCardInfoBenefitActivationTitle => '快速且简单激活';

  @override
  String get getCardInfoBenefitActivationSubtitle => '无需实体交付';

  @override
  String get getCardInfoButtonContinue => '继续';

  @override
  String get comment_card_details_info => '==== 卡详情信息 ====';

  @override
  String get cardDetailsInfoTitle => '卡详情';

  @override
  String get cardDetailsCardTypeLabel => '卡类型';

  @override
  String get cardDetailsCardTypeValue => '虚拟';

  @override
  String get cardDetailsBillingAddressLabel => '账单地址';

  @override
  String get cardDetailsCardCurrencyLabel => '卡货币';

  @override
  String get bsicardsCardDetailsCurrencyValue => 'USD';

  @override
  String get cardDetailsCardCreatedLabel => '卡创建';

  @override
  String get cardDetailsStatusButtonActive => '活跃';

  @override
  String get cardDetailsStatusButtonInactive => '不活跃';

  @override
  String get comment_card_top_up_bottom_sheet => '==== 卡充值底部表单 ====';

  @override
  String get cardTopUpTitle => '卡余额充值';

  @override
  String get cardTopUpMainWalletBalance => '主钱包余额';

  @override
  String get cardTopUpLabelAmount => '金额';

  @override
  String cardTopUpAmountLimits(Object currency, Object max, Object min) {
    return '最低 $min $currency 最高 $max $currency';
  }

  @override
  String get cardTopUpReviewTopupAmount => '充值金额';

  @override
  String get cardTopUpReviewTopupCharge => '充值手续费';

  @override
  String get cardTopUpReviewTotalTopupBalance => '总金额';

  @override
  String get cardTopUpButtonTopupNow => '立即充值';

  @override
  String get bsicardsTopUpInfoMessage => '请将资金发送至提供的加密地址。交易确认后，余额将添加到您的卡中。';

  @override
  String get bsicardsTopUpCopyButton => '复制';

  @override
  String get bsicardsTopUpCopySuccess => '地址已复制';

  @override
  String get comment_virtual_card_display => '==== 虚拟卡显示 ====';

  @override
  String get virtualCardExpiryDateLabel => '到期日期';

  @override
  String get virtualCardCvcLabel => 'CVC';

  @override
  String get comment_virtual_card_details_screen => '==== 虚拟卡详情页面 ====';

  @override
  String get virtualCardDetailsAppBarTitle => '虚拟卡详情';

  @override
  String get virtualCardDetailsFloatingButton => '添加余额';

  @override
  String get comment_virtual_card_transaction_screen => '==== 虚拟卡交易页面 ====';

  @override
  String get virtualCardTransactionAppBarTitle => '卡交易';

  @override
  String get virtualCardTransactionSyncButton => '同步';

  @override
  String get comment_virtual_card_screen => '==== 虚拟卡页面 ====';

  @override
  String get virtualCardScreenAppBarTitle => '虚拟卡';

  @override
  String get virtualCardCardExpiryDateLabel => '到期日期';

  @override
  String get virtualCardCardCvcLabel => 'CVC';

  @override
  String get virtualCardCreateCardTitle => '创建您的虚拟卡以开始使用';

  @override
  String get virtualCardCreateCardButton => '创建卡';

  @override
  String get comment_verify_passcode_controller => '==== 验证密码控制器 ====';

  @override
  String get verifyPasscodeValidationEnterPasscode => '请输入您的密码';

  @override
  String get comment_change_passcode_bottom_sheet => '==== 修改密码底部表单 ====';

  @override
  String get changePasscodeTitle => '修改密码';

  @override
  String get changePasscodeLabelOldPasscode => '旧密码';

  @override
  String get changePasscodeLabelNewPasscode => '新密码';

  @override
  String get changePasscodeLabelConfirmPasscode => '确认密码';

  @override
  String get changePasscodeButtonChange => '修改密码';

  @override
  String get comment_disable_and_change_passcode_section =>
      '==== 禁用和修改密码部分 ====';

  @override
  String get disableChangePasscodeTitle => '密码';

  @override
  String get disableChangePasscodeButtonChange => '修改密码';

  @override
  String get disableChangePasscodeButtonDisable => '禁用密码';

  @override
  String get comment_disable_passcode_bottom_sheet => '==== 禁用密码底部表单 ====';

  @override
  String get disablePasscodeTitle => '禁用密码';

  @override
  String get disablePasscodeLabelPassword => '密码';

  @override
  String get disablePasscodeButtonDisable => '禁用密码';

  @override
  String get comment_generate_passcode_bottom_sheet => '==== 生成密码底部表单 ====';

  @override
  String get generatePasscodeTitle => '添加密码';

  @override
  String get generatePasscodeLabelPasscode => '密码';

  @override
  String get generatePasscodeLabelConfirmPasscode => '确认密码';

  @override
  String get generatePasscodeButtonConfirm => '确认';

  @override
  String get comment_generate_passcode_section => '==== 生成密码部分 ====';

  @override
  String get generatePasscodeSectionTitle => '密码';

  @override
  String get generatePasscodeSectionDescription => '创建安全密码以快速访问您的账户';

  @override
  String get generatePasscodeSectionButtonGenerate => '生成密码';

  @override
  String get comment_verify_passcode_bottom_sheet => '==== 验证密码底部表单 ====';

  @override
  String get verifyPasscodeTitle => '确认您的密码';

  @override
  String get verifyPasscodeLabelPasscode => '密码';

  @override
  String get verifyPasscodeButtonConfirm => '确认';

  @override
  String get comment_payment_links_amount_section => '==== 支付链接金额部分 ====';

  @override
  String get paymentLinksAmountSectionTitle => '金额';

  @override
  String get paymentLinksCurrencyLabel => '货币';

  @override
  String get paymentLinksCurrencyHint => '选择货币';

  @override
  String get paymentLinksCurrencyDropdownTitle => '货币';

  @override
  String get paymentLinksCurrencyNotFound => '未找到货币';

  @override
  String get paymentLinksNoteLabel => '备注';

  @override
  String get paymentLinksCreateLinkButton => '创建链接';

  @override
  String get comment_payment_links_create_section => '==== 支付链接创建部分 ====';

  @override
  String get paymentLinksInstructionText =>
      '您可以创建无需指定金额或货币的支付链接。付款人可以在付款时填写账户和货币。';

  @override
  String get comment_payment_links_header_section => '==== 支付链接头部部分 ====';

  @override
  String get paymentLinksAppBarTitle => '支付链接';

  @override
  String get paymentLinksTabList => '列表';

  @override
  String get paymentLinksTabCreate => '创建';

  @override
  String get comment_payment_links_history_filter_bottom_sheet =>
      '==== 支付链接记录筛选底部表单 ====';

  @override
  String get paymentLinksFilterNumberLabel => '编号';

  @override
  String get paymentLinksFilterButton => '筛选';

  @override
  String get comment_payment_links_list_section => '==== 支付链接列表部分 ====';

  @override
  String get paymentLinksListItemCreatedAt => '创建于： ';

  @override
  String get paymentLinksListItemStatus => '状态： ';

  @override
  String get paymentLinksStatusPaid => '已支付';

  @override
  String get paymentLinksStatusUnpaid => '未支付';

  @override
  String get paymentLinksCopySuccessToast => '支付链接代码已复制';

  @override
  String get comment_gift_card_header_section => '---- 礼品卡头部部分 ----';

  @override
  String get giftCardHeaderTitle => '礼品卡';

  @override
  String get giftCardHeaderTabCards => '卡';

  @override
  String get giftCardHeaderTabHistory => '记录';

  @override
  String get comment_gift_card_history_filter_bottom_sheet =>
      '---- 礼品卡记录筛选底部表单 ----';

  @override
  String get giftCardHistoryFilterSearchLabel => '搜索';

  @override
  String get giftCardHistoryFilterSearchButton => '搜索';

  @override
  String get comment_gift_card_filter_bottom_sheet => '---- 礼品卡筛选底部表单 ----';

  @override
  String get giftCardFilterGiftCardLabel => '礼品卡';

  @override
  String get giftCardFilterCountryLabel => '国家';

  @override
  String get giftCardFilterCountrySelectTitle => '选择国家';

  @override
  String get giftCardFilterAllOption => '全部';

  @override
  String get giftCardFilterCountryNotFound => '未找到国家';

  @override
  String get giftCardFilterCategoryLabel => '类别';

  @override
  String get giftCardFilterCategorySelectTitle => '选择类别';

  @override
  String get giftCardFilterCategoryNotFound => '未找到类别';

  @override
  String get giftCardFilterSearchButton => '搜索';

  @override
  String get comment_gift_card_history_details => '---- 礼品卡记录详情 ----';

  @override
  String get giftCardHistoryDetailsTitle => '交易详情';

  @override
  String giftCardHistoryQtyLabel(Object qty) {
    return '数量 : $qty';
  }

  @override
  String get giftCardTransactionIdLabel => '交易 ID';

  @override
  String get giftCardProductNameLabel => '产品名称';

  @override
  String get giftCardSenderNameLabel => '发送人姓名';

  @override
  String get giftCardRecipientEmailLabel => '收件人邮箱';

  @override
  String get giftCardRecipientPhoneLabel => '收件人电话';

  @override
  String get giftCardUnitPriceLabel => '单价';

  @override
  String get giftCardTotalAmountLabel => '总金额';

  @override
  String get comment_gift_card_review_details => '---- 礼品卡审核详情 ----';

  @override
  String get giftCardReviewDetailsTitle => '审核详情';

  @override
  String get giftCardSubTotalLabel => '小计';

  @override
  String get giftCardTotalFeeLabel => '总费用';

  @override
  String get giftCardTotalLabel => '总计';

  @override
  String get giftCardReviewBackButton => '返回';

  @override
  String get giftCardReviewPayNowButton => '立即支付';

  @override
  String get comment_gift_card_success_section => '---- 礼品卡成功部分 ----';

  @override
  String get giftCardSuccessTitle => '礼品卡订单已成功下单！';

  @override
  String get giftCardSuccessGiftCardsButton => '礼品卡';

  @override
  String get giftCardSuccessBackHomeButton => '返回首页';

  @override
  String get comment_gift_card_amount_validation => '---- 礼品卡控制器金额验证 ----';

  @override
  String get giftCardAmountRequired => '请输入金额';

  @override
  String get giftCardAmountInvalid => '金额必须大于零';

  @override
  String giftCardAmountMinError(Object min) {
    return '金额不得超过 $min';
  }

  @override
  String giftCardAmountMaxError(Object max) {
    return '金额不得超过 $max';
  }

  @override
  String get comment_gift_card_user_validation => '---- 礼品卡控制器用户验证 ----';

  @override
  String get giftCardEmailRequired => '请输入邮箱';

  @override
  String get giftCardEmailInvalid => '请输入有效的邮箱';

  @override
  String get giftCardCountryRequired => '请选择国家';

  @override
  String get giftCardPhoneRequired => '请输入电话';

  @override
  String get giftCardNameRequired => '请输入姓名';

  @override
  String get comment_gift_card_details_section => '---- 礼品卡详情部分 ----';

  @override
  String get giftCardDetailsTitle => '礼品卡详情';

  @override
  String get giftCardAmountLabel => '金额';

  @override
  String giftCardAmountBetweenLabel(Object currency, Object max, Object min) {
    return '金额介于 $min $currency 和 $max $currency 之间';
  }

  @override
  String get giftCardEmailLabel => '邮箱';

  @override
  String get giftCardCountryLabel => '国家';

  @override
  String get giftCardSelectCountryTitle => '选择国家';

  @override
  String get giftCardCountryNotFound => '未找到国家';

  @override
  String get giftCardPhoneLabel => '电话';

  @override
  String get giftCardYourNameLabel => '您的姓名';

  @override
  String get giftCardQuantityLabel => '数量';

  @override
  String get giftCardBuyNowButton => '立即购买';

  @override
  String get giftCardRedeemInstructionTitle => '兑换说明';

  @override
  String get comment_p2p => '==== P2P ====';

  @override
  String get p2pMyOrder => '我的订单';

  @override
  String get p2pPaymentAccount => '支付账户';

  @override
  String get p2pCreateAd => '创建广告';

  @override
  String get p2pApplyVerification => '申请验证';

  @override
  String get p2pP2p => 'P2P';

  @override
  String get p2pMyOrders => '我的订单';

  @override
  String get p2pPaymentAccounts => '支付账户';

  @override
  String get p2pMyAds => '我的广告';

  @override
  String get p2pSelectAsset => '选择资产';

  @override
  String get p2pSelectFiat => '选择法币';

  @override
  String get p2pBuy => '购买';

  @override
  String get p2pSell => '出售';

  @override
  String get p2pAmount => '金额';

  @override
  String get p2pPayment => '支付';

  @override
  String get p2pOrders => '订单';

  @override
  String get p2pCompletion => '完成';

  @override
  String get p2pLimit => '限额';

  @override
  String get p2pAvailable => '可用';

  @override
  String get p2pOrderDetails => '订单详情';

  @override
  String get p2pNoOrderDetailsFound => '未找到订单详情';

  @override
  String get p2pNoAdDetailsFound => '未找到广告详情';

  @override
  String get p2pPrice => '价格';

  @override
  String get p2pOrderLimit => '订单限额';

  @override
  String get p2pYouPay => '您支付';

  @override
  String get p2pYouSell => '您出售';

  @override
  String get p2pYouReceive => '您收到';

  @override
  String get p2pPaymentMethods => '支付方式';

  @override
  String get p2pLoadingPaymentMethods => '正在加载支付方式...';

  @override
  String get p2pSelectPaymentMethod => '选择支付方式';

  @override
  String get p2pNoPaymentMethodFound => '未找到支付方式';

  @override
  String get p2pAdvertisersTerms => '广告商条款（请仔细阅读）';

  @override
  String get p2pPaymentTimeLimit => '支付时间限制';

  @override
  String get p2pAvgReleaseTime => '平均释放时间';

  @override
  String get p2pNoTermsProvided => '未提供条款';

  @override
  String get p2pOrderNumber => '订单编号';

  @override
  String get p2pSearchOrderNumber => '搜索订单编号';

  @override
  String get p2pOrderNumberCopied => '订单编号已复制';

  @override
  String get p2pCopied => '已复制';

  @override
  String get p2pOrderCreated => '订单已创建';

  @override
  String get p2pFiatAmount => '法币金额';

  @override
  String get p2pReceiveQuantity => '收到数量';

  @override
  String get p2pPaymentMethod => '支付方式';

  @override
  String get p2pChange => '更改';

  @override
  String get p2pRecipient => '收款人';

  @override
  String get p2pView => '查看';

  @override
  String get p2pFilterAmount => '筛选金额';

  @override
  String get p2pEnterAmount => '输入金额';

  @override
  String get p2pFilterPaymentMethod => '筛选支付方式';

  @override
  String get p2pUnableToLoadImage => '无法加载图片';

  @override
  String get p2pUnableToLoadAttachment => '无法加载附件';

  @override
  String get p2pTransferredNotifySeller => '已转账，通知卖家';

  @override
  String get p2pCancelOrder => '取消订单';

  @override
  String get p2pDisputeOrder => '争议订单';

  @override
  String get p2pPaymentReceived => '已收到付款';

  @override
  String get p2pEnterDisputeReason => '输入争议原因';

  @override
  String get p2pWriteYourReason => '写下您的原因...';

  @override
  String get p2pEnterReason => '输入原因';

  @override
  String get p2pReasonIsRequired => '原因为必填';

  @override
  String get p2pCancelOrderConfirmation => '您确定要取消此订单吗？';

  @override
  String get p2pOrderCompleted => '订单已完成';

  @override
  String get p2pOrderCancelled => '订单已取消';

  @override
  String get p2pPendingRelease => '待释放';

  @override
  String get p2pOrderDisputed => '订单已争议';

  @override
  String get p2pOrderExpired => '订单已过期';

  @override
  String get p2pBuyerMarkedAsPaid => '买家标记为已支付';

  @override
  String get p2pOrderCreatedPayTheSellerWithin => '订单已创建，请在规定时间内支付卖家';

  @override
  String get p2pBuyerHasNotPaidYetPaymentDueWithin => '买家尚未支付。付款期限剩余';

  @override
  String get p2pSellerFundsLockedInEscrow => '卖家的资金已锁定在托管中。我们的支持团队将审核证据并尽快回复。';

  @override
  String get p2pYourLockedAssetsInEscrow => '您的锁定资产已在托管中。我们的支持团队将尽快审核此争议。';

  @override
  String get p2pPaymentNotCompletedInAllowedTime => '您未在允许的时间内完成付款。';

  @override
  String get p2pBuyerDidNotCompletePaymentInAllowedTime => '买家未在允许的时间内完成付款。';

  @override
  String p2pConfirmPaymentFrom(Object name) {
    return '确认付款来自（买家：$name）';
  }

  @override
  String get p2pVerifyAmountAndSender => '请验证您账户中的金额和发送人详情，然后继续释放操作。';

  @override
  String get p2pTransferFundsToSeller => '将资金转至下面提供的卖家账户。';

  @override
  String get p2pNotifySeller => '通知卖家';

  @override
  String get p2pConfirmPaymentReceived => '确认已收到付款';

  @override
  String get p2pConfirmPaymentReceivedDescription => '确认收到付款后，点击下面的“已收到付款”按钮。';

  @override
  String get p2pNotifySellerDescription => '付款后，请记得点击“已转账，通知卖家”按钮以便卖家释放加密货币。';

  @override
  String get p2pAllAccount => '所有账户';

  @override
  String get p2pAddPaymentMethod => '添加支付方式';

  @override
  String get p2pEdit => '编辑';

  @override
  String get p2pEditPaymentAccount => '编辑支付账户';

  @override
  String get p2pUpdateAccount => '更新账户';

  @override
  String get p2pCancel => '取消';

  @override
  String get p2pSubmit => '提交';

  @override
  String get p2pBack => '返回';

  @override
  String get p2pNext => '下一步';

  @override
  String get p2pDone => '完成';

  @override
  String get p2pIWantToBuy => '我想购买';

  @override
  String get p2pIWantToSell => '我想出售';

  @override
  String get p2pAsset => '资产';

  @override
  String get p2pWithFiat => '使用法币';

  @override
  String get p2pPriceType => '价格类型';

  @override
  String get p2pYourPrice => '您的价格';

  @override
  String get p2pHighestOrderPrice => '最高订单价格';

  @override
  String get p2pTotalAmount => '总金额';

  @override
  String get p2pSelectAtLeastOnePaymentMethod => '至少选择一种支付方式';

  @override
  String get p2pAdd => '添加';

  @override
  String get p2pMinutes => '分钟';

  @override
  String get p2pTerms => '条款';

  @override
  String get p2pAutomaticReply => '自动回复';

  @override
  String get p2pFixed => '固定';

  @override
  String get p2pFloat => '浮动';

  @override
  String get p2pSelectPriceType => '选择价格类型';

  @override
  String get p2pNoAssetsFound => '未找到资产';

  @override
  String get p2pNoFiatCurrenciesFound => '未找到法币';

  @override
  String get p2pNoPriceTypeFound => '未找到价格类型';

  @override
  String get p2pAdSuccessfullyPosted => '广告发布成功';

  @override
  String get p2pAdsSubmittedUnderReview => '广告已提交，正在审核中。';

  @override
  String get p2pAdPublishedDescription => '您的广告已发布，用户现在可以下单。请注意新订单提示。';

  @override
  String get p2pAdUnderReviewDescription =>
      '您的广告正在审核中。一旦批准，它将被发布，用户可以下单。请注意新订单提示。';

  @override
  String get p2pAdNumber => '广告编号';

  @override
  String get p2pMethod => '方式';

  @override
  String get p2pGoToMyAds => '前往我的广告';

  @override
  String get p2pEligibilityValidationFailed => '资格验证失败';

  @override
  String get p2pPleaseFulfillRequirements => '请满足以下要求：';

  @override
  String get p2pNotEligibleCreateAd => '您当前不符合创建广告的资格。';

  @override
  String get p2pCompletedTradeQty => '已完成交易数量';

  @override
  String get p2pStatus => '状态';

  @override
  String get p2pAdsView => '广告查看';

  @override
  String get p2pAdNumberTitle => '广告编号';

  @override
  String get p2pType => '类型';

  @override
  String get p2pAssetFiat => '资产/法币';

  @override
  String get p2pPriceExchangeRate => '价格\n汇率';

  @override
  String get p2pLastUpdated => '最后更新';

  @override
  String get p2pCreateTime => '创建时间';

  @override
  String get p2pDeleteAdConfirmation => '您确定要删除此广告吗？';

  @override
  String get p2pFiat => '法币';

  @override
  String get p2pCryptoAmount => '加密货币金额';

  @override
  String get p2pCounterparty => '对手方';

  @override
  String get p2pChat => '聊天';

  @override
  String get p2pNoMessagesYet => '暂无消息';

  @override
  String get p2pTypeYourMessage => '输入您的消息...';

  @override
  String get p2pCamera => '相机';

  @override
  String get p2pGallery => '图库';

  @override
  String get p2pAttachment => '附件';

  @override
  String get p2pUser => '用户';

  @override
  String get p2pYouAreVerifiedTrader => '您是已验证交易者';

  @override
  String get p2pVerifiedTraderStatusActive => '您的已验证交易者状态为活跃。';

  @override
  String get p2pVerificationUnderReview => '验证正在审核中';

  @override
  String get p2pVerificationRequestUnderReview => '您的验证请求当前正在审核中。';

  @override
  String get p2pSubmittedOn => '提交于';

  @override
  String get p2pVerificationDataUnavailable => '验证数据不可用';

  @override
  String get p2pPleaseRefreshAndTryAgain => '请刷新并重试。';

  @override
  String get p2pPreviousVerificationRejected => '之前的验证请求已被拒绝';

  @override
  String get p2pReason => '原因';

  @override
  String get p2pCorrectInformationApplyAgain => '请更正信息并重新申请。';

  @override
  String get p2pApplyVerificationTitle => '申请验证';

  @override
  String get p2pFillRequiredFieldsVerification => '填写所有必填字段以提交验证。';

  @override
  String get p2pNoVerificationFormFieldsFound => '未找到验证表单字段。';

  @override
  String get p2pSubmitVerification => '提交验证';

  @override
  String p2pEnterField(Object field) {
    return '输入 $field';
  }

  @override
  String get p2pFieldRequired => 'This field is required';

  @override
  String get p2pPleaseUpload => 'Please upload file for this field';

  @override
  String get p2pPleaseFill => 'Please fill this field';

  @override
  String get p2pWriteMessageOrAttach => 'Please write a message or add an attachment';

  @override
  String get p2pVerificationSubmitted => 'Verification submitted successfully';

  @override
  String get p2pCashDollar => 'Cash Dollar';

  @override
  String get p2pInPerson => 'In-Person Exchange';

  @override
  String get p2pMinutes => 'min';

  @override
  String get p2pRecipient => 'Recipient';

  @override
  String get p2pCopied => 'Copied';

  @override
  String get p2pNoPaymentMethodFound2 => 'No payment method found';

  @override
  String get p2pTransferInstruction => 'Open ({paymentMethod}) to transfer {amount}';

  @override
  String get p2pCashTransferInstruction => 'Pay {amount} in cash to the seller';

  @override
  String get p2pInPersonInstruction => 'Meet the seller in person and pay {amount} in cash';

  @override
  String get edit_my_ad => '编辑我的广告';

  @override
  String get amount => '金额';

  @override
  String get total_amount => '总金额';

  @override
  String get min_amount => '最低金额';

  @override
  String get max_amount => '最高金额';

  @override
  String get payment_duration => '支付时长';

  @override
  String get payment_method => '支付方式';

  @override
  String get no_payment_method => '未找到支付方式';

  @override
  String get terms => '条款';

  @override
  String get auto_response => '自动回复消息';

  @override
  String get update => '更新';

  @override
  String get error_ad_invalid => '广告数据无效';

  @override
  String get error_amount_zero => '金额不能为零';

  @override
  String get error_total_amount_zero => '总金额不能为零';

  @override
  String get error_min_zero => '最低金额不能为零';

  @override
  String get error_max_zero => '最高金额不能为零';

  @override
  String get error_min_greater => '最低金额不能大于最高金额';

  @override
  String get error_payment_duration_zero => '支付时长不能为零';

  @override
  String get error_select_payment => '请选择支付方式';

  @override
  String get error_terms_empty => '条款不能为空';

  @override
  String get error_select_asset => '请选择资产';

  @override
  String get error_select_fiat => '请选择法币';

  @override
  String get error_select_price_type => '请选择价格类型';

  @override
  String get error_price_zero => '价格不能为零';

  @override
  String get error_enter_total_amount => '请输入总金额';

  @override
  String get error_enter_min_order => '请输入最低订单限额';

  @override
  String get error_enter_max_order => '请输入最高订单限额';

  @override
  String get error_payment_time_zero => '支付时间不能为零';

  @override
  String get error_enter_terms => '请输入条款';

  @override
  String get filterMyAds => '筛选我的广告';

  @override
  String get status => '状态';

  @override
  String get type => '类型';

  @override
  String get fiatCurrency => '法币';

  @override
  String get assetCurrency => '资产货币';

  @override
  String get reset => '重置';

  @override
  String get search => '搜索';

  @override
  String get select => '选择';

  @override
  String get selectStatus => '选择状态';

  @override
  String get selectType => '选择类型';

  @override
  String get selectFiatCurrency => '选择法币';

  @override
  String get selectAssetCurrency => '选择资产货币';

  @override
  String get noStatusFound => '未找到状态';

  @override
  String get noTypeFound => '未找到类型';

  @override
  String get noDataFound => '未找到数据';

  @override
  String get noFiatCurrencyFound => '未找到法币';

  @override
  String get noAssetCurrencyFound => '未找到资产货币';

  @override
  String get filterPaymentAccount => '筛选支付账户';

  @override
  String get filterMyOrder => '筛选我的订单';

  @override
  String get comment_travel => '==== eCardo 旅行 ====';

  @override
  String get travelTitle => 'eCardo 旅行';

  @override
  String get travelHeroEyebrow => '更好的旅行体验';

  @override
  String get travelHeroTitle => '立即预订下一段旅程';

  @override
  String get travelFlights => '航班';

  @override
  String get travelHotels => '酒店';

  @override
  String get travelEsim => 'eSIM';

  @override
  String get travelRecentActivity => '最近活动';

  @override
  String get travelViewAll => '查看全部';

  @override
  String get travelMainWallet => 'eCardo 主钱包';

  @override
  String get travelWalletSharedDescription => '与你在 eCardo 中使用的同一个安全钱包';

  @override
  String get travelHotelSearch => '酒店搜索';

  @override
  String get travelHotelHero => '入住难忘之地';

  @override
  String get travelDestinationCountry => '目的地国家';

  @override
  String get travelDestinationCity => '城市';

  @override
  String get travelCheckIn => '入住';

  @override
  String get travelCheckOut => '退房';

  @override
  String get travelGuests => '住客';

  @override
  String get travelSearchHotels => '搜索酒店';

  @override
  String get travelRecentSearches => '最近搜索';

  @override
  String get travelHotelResults => '酒店结果';

  @override
  String get travelNoHotelResults => '未找到匹配的酒店。';

  @override
  String get travelStartingPrice => '每次住宿起价';

  @override
  String get travelViewDetails => '查看详情';

  @override
  String get travelHotelDetails => '酒店详情';

  @override
  String get travelOfferUnavailable => '此优惠已不可用。';

  @override
  String get travelReserveHotel => '预订酒店';

  @override
  String get travelIncluded => '已包含';

  @override
  String get travelFree => '免费';

  @override
  String get travelAboutHotel => '关于酒店';

  @override
  String get travelHotelDescription =>
      '精致的城市住宿，提供舒适客房、贴心服务，并可便捷前往主要景点。最终房间内容和政策将由 eCardo Travel API 提供。';

  @override
  String get travelPolicies => '政策';

  @override
  String get travelCancellation => '取消';

  @override
  String get travelCancellationSummary => '在规定截止时间前可免费取消';

  @override
  String get travelFlightSearch => '航班搜索';

  @override
  String get travelFlightHero => '梦想旅程从这里开始';

  @override
  String get travelOrigin => '出发地';

  @override
  String get travelDestination => '目的地';

  @override
  String get travelDepartureDate => '出发日期';

  @override
  String get travelReturnDate => '返程日期';

  @override
  String get travelOneWay => '单程';

  @override
  String get travelRoundTrip => '往返';

  @override
  String get travelAdults => '成人';

  @override
  String get travelChildren => '儿童';

  @override
  String get travelInfants => '婴儿';

  @override
  String get travelCabinClass => '舱位等级';

  @override
  String get travelEconomy => '经济舱';

  @override
  String get travelBusiness => '商务舱';

  @override
  String get travelSearchFlights => '搜索航班';

  @override
  String get travelFlightResults => '航班结果';

  @override
  String get travelNoFlightResults => '未找到匹配的航班。';

  @override
  String get travelAlternativeFlights => '备选航班';

  @override
  String get travelAlternativeFlightsDescription =>
      '你的精确搜索没有匹配结果。以下临近选项仅作为备选；可编辑搜索以更改路线或日期。';

  @override
  String get travelSelectFlight => '选择航班';

  @override
  String get travelSelectReturnFlight => '选择返程航班';

  @override
  String get travelOutboundFlight => '去程航班';

  @override
  String get travelReturnFlight => '返程航班';

  @override
  String get travelFlightDetails => '航班和乘客详情';

  @override
  String get travelContinueToPayment => '继续支付';

  @override
  String get travelPassengerReview => '乘客确认';

  @override
  String get travelPrimaryPassenger => '主要乘客';

  @override
  String get travelPassengerFromProfile => '详情来自你的 eCardo 个人资料';

  @override
  String get travelFareDetails => '票价详情';

  @override
  String get travelBaseFare => '基础票价';

  @override
  String get travelTaxesAndFees => '税费';

  @override
  String get travelTotal => '总计';

  @override
  String get travelBrowseEsimPackages => '浏览 eSIM 套餐';

  @override
  String get travelEsimIntroTitle => '无论去哪里都保持连接';

  @override
  String get travelEsimIntroDescription =>
      '选择数字流量套餐，用 eCardo 主钱包支付，无需更换实体 SIM 卡即可激活。';

  @override
  String get travelEsimInstantTitle => '即时交付';

  @override
  String get travelEsimInstantDescription => '付款后可立即获取激活详情。';

  @override
  String get travelEsimCoverageTitle => '旅行覆盖';

  @override
  String get travelEsimCoverageDescription => '为目的地选择本地或全球套餐。';

  @override
  String get travelEsimTransparentTitle => '透明定价';

  @override
  String get travelEsimTransparentDescription => '付款前查看后端确认的总价。';

  @override
  String get travelEsimPackages => 'eSIM 套餐';

  @override
  String get travelNoEsimPackages => '未找到匹配的 eSIM 套餐。';

  @override
  String get travelChoosePackage => '选择套餐';

  @override
  String get travelMostPopular => '最受欢迎';

  @override
  String get travelSelect => '选择';

  @override
  String travelValidityDays(int days) {
    return '有效期 $days 天';
  }

  @override
  String get travelWalletCheckout => '钱包结账';

  @override
  String get travelBackendConfirmedPrice => '价格由 eCardo Travel 确认';

  @override
  String get travelPaymentMethod => '支付方式';

  @override
  String get travelAvailableBalance => '可用余额';

  @override
  String get travelInsufficientBalance => '你的主钱包余额不足。请充值后返回刷新结账。';

  @override
  String get travelPriceSummary => '价格摘要';

  @override
  String get travelSubtotal => '小计';

  @override
  String get travelWalletPayment => '钱包支付';

  @override
  String get travelCheckoutSafetyNote => '支付将通过幂等预订请求仅提交一次。';

  @override
  String get travelPayFromWallet => '从钱包支付';

  @override
  String get travelAddMoney => '充值';

  @override
  String get travelPaymentFailed => '支付未完成';

  @override
  String get travelPaymentFailedDescription => '你的钱包未被视为已支付。请检查预订并重试。';

  @override
  String get travelHotelVoucher => '酒店凭证';

  @override
  String get travelFlightTicket => '机票';

  @override
  String get travelEsimActivation => 'eSIM 激活';

  @override
  String get travelVoucherReady => '你的酒店确认凭证已准备好。';

  @override
  String get travelTicketReady => '你的机票已出票并准备好。';

  @override
  String get travelEsimReady => '你的 eSIM 已激活，可安装。';

  @override
  String get travelPurchaseSuccessful => '购买成功';

  @override
  String get travelReference => '参考号';

  @override
  String get travelStatus => '状态';

  @override
  String get travelActive => '有效';

  @override
  String get travelConfirmed => '已确认';

  @override
  String get travelCompleted => '已完成';

  @override
  String get travelRefunded => '已退款';

  @override
  String get travelFailed => '失败';

  @override
  String get travelBookingFailed => '预订失败';

  @override
  String get travelBookingFailedDescription => '此预订未完成。再次付款前请查看订单状态。';

  @override
  String get travelBookingRefunded => '预订已退款';

  @override
  String get travelBookingRefundedDescription => '此预订的付款已退回钱包。';

  @override
  String get travelPendingConfirmation => '等待确认';

  @override
  String get travelHotelBookingSubmitted => '酒店预订已提交';

  @override
  String get travelHotelPendingConfirmationDescription =>
      '已收到付款。eCardo Travel 正在向授权供应商确认酒店，然后签发凭证。';

  @override
  String get travelPaidAmount => '已付金额';

  @override
  String get travelActivationDetails => '激活详情';

  @override
  String get travelActivationInstructions =>
      '打开设备蜂窝网络设置，添加 eSIM，并使用 eCardo 后端返回的安全安装详情。';

  @override
  String get travelViewMyBookings => '查看我的预订';

  @override
  String get travelMyBookings => '我的预订';

  @override
  String get travelAllBookings => '所有预订';

  @override
  String get travelMyHotels => '我的酒店';

  @override
  String get travelMyFlights => '我的航班';

  @override
  String get travelMyEsims => '我的 eSIM';

  @override
  String get travelMyHotelsDescription => '已确认住宿和酒店凭证';

  @override
  String get travelMyFlightsDescription => '已预订航班和已出票机票';

  @override
  String get travelMyEsimsDescription => '当前和历史流量套餐';

  @override
  String get travelNoBookings => '你还没有任何旅行预订。';

  @override
  String get travelNoHotels => '你还没有任何酒店预订。';

  @override
  String get travelNoFlights => '你还没有任何航班预订。';

  @override
  String get travelNoEsims => '你还没有任何 eSIM 购买。';

  @override
  String get travelSavedTravelers => '已保存旅客';

  @override
  String get travelNoTravelers => '还没有已保存的旅客。';

  @override
  String get travelAddTraveler => '添加旅客';

  @override
  String get travelEditTraveler => '编辑旅客';

  @override
  String get travelTravelerFullName => '全名';

  @override
  String get travelFirstName => '名';

  @override
  String get travelLastName => '姓';

  @override
  String get travelBirthDate => '出生日期';

  @override
  String get travelPassportExpiry => '护照有效期';

  @override
  String get travelGender => '性别';

  @override
  String get travelMale => '男';

  @override
  String get travelFemale => '女';

  @override
  String get travelNotificationContact => '预订通知';

  @override
  String get travelPhone => '手机号码';

  @override
  String get travelEmail => '电子邮箱';

  @override
  String get travelPassengerDetailsRequired => '请填写所有乘客信息，并添加手机号码或电子邮箱以接收预订更新。';

  @override
  String get travelAdultPassenger => '成人乘客';

  @override
  String get travelChildPassenger => '儿童乘客';

  @override
  String get travelInfantPassenger => '婴儿乘客';

  @override
  String get travelCompleteTravelerDetails => '完善乘客信息';

  @override
  String get travelPassportNumber => '护照号码';

  @override
  String get travelNationalityCode => '国籍代码';

  @override
  String get travelNationalityCodeInvalid => '请输入两位国家代码';

  @override
  String get travelFieldRequired => '此字段为必填项';

  @override
  String get travelSaveTraveler => '保存旅客';

  @override
  String get travelAccount => '旅行账户';

  @override
  String get travelAccountHolder => 'eCardo 会员';

  @override
  String get travelMemberDescription => '共享个人资料、钱包和旅客信息';

  @override
  String get travelMyBookingsDescription => '酒店、航班和有效 eSIM';

  @override
  String get travelSavedTravelersDescription => '安全复用乘客详情';

  @override
  String get travelPersonalInformation => '个人信息';

  @override
  String get travelPersonalInformationDescription => '管理与旅行共享的详情';

  @override
  String get travelHistory => '旅行和钱包历史';

  @override
  String get travelHistoryDescription => '一起查看购买和钱包活动';

  @override
  String get travelNoActivity => '暂无旅行或钱包活动。';

  @override
  String get travelMockIran => '伊朗';

  @override
  String get travelMockTehran => '德黑兰';

  @override
  String get travelMockGuests => '2 位成人，1 位儿童';

  @override
  String get travelMockTehranHotels => '德黑兰酒店';

  @override
  String get travelMockHotelEspinas => 'Espinas Palace 酒店';

  @override
  String get travelMockHotelEspinasLocation => '萨达特阿巴德，德黑兰';

  @override
  String get travelMockHotelParsian => 'Parsian International 酒店';

  @override
  String get travelMockHotelParsianLocation => '瓦利阿斯尔街，德黑兰';

  @override
  String get travelMockHotelVisteria => 'Visteria 酒店';

  @override
  String get travelMockHotelVisteriaLocation => '塔杰里什，德黑兰';

  @override
  String get travelMockTehranAirport => '德黑兰 (THR)';

  @override
  String get travelMockIstanbulAirport => '伊斯坦布尔 (IST)';

  @override
  String get travelMockRouteTehranIstanbul => '德黑兰 → 伊斯坦布尔';

  @override
  String get travelMockFlightTehranIstanbul => '德黑兰至伊斯坦布尔';

  @override
  String get travelMockAirlineOne => 'eCardo Air';

  @override
  String get travelMockAirlineTwo => 'Atlas Airways';

  @override
  String get travelEsimTurkey => '土耳其 eSIM';

  @override
  String get travelRecommended => '推荐';

  @override
  String get travelBestValue => '最划算';

  @override
  String get travelLuxury => '豪华';

  @override
  String get travelDirect => '直达';

  @override
  String get travelLowestPrice => '最低价';

  @override
  String get travelFeatureBreakfast => '早餐';

  @override
  String get travelFeaturePool => '泳池';

  @override
  String get travelFeatureWifi => 'Wi‑Fi';

  @override
  String get travelFeatureParking => '停车';

  @override
  String get travelFeatureAirportTransfer => '机场接送';

  @override
  String get travelFeatureCabinBag => '随身行李';

  @override
  String get travelFeatureRefundable => '可退款';

  @override
  String get travelActivityFlightPurchase => '购买航班';

  @override
  String get travelActivityEsimPurchase => '购买 eSIM';

  @override
  String get travelActivityWalletTopUp => '钱包充值';

  @override
  String get travelDemoOffer => '演示优惠';

  @override
  String get travelRequiresConfirmation => '需要确认';

  @override
  String get travelHotelBooking => '酒店预订';

  @override
  String get travelReviewStep => '审核';

  @override
  String get travelConfirmationStep => '确认';

  @override
  String get travelReviewConfirmation => '我已查看并确认这些详情';

  @override
  String get travelReviewConfirmationDescription => '创建预订前，请确认旅客、产品、总额和钱包。';

  @override
  String get travelReservationHoldActive => '请在预订过期前完成付款';

  @override
  String get travelReservationExpired => '预订已过期。请重新开始创建新的保留。';

  @override
  String get travelNeedsAttention => '需要处理';

  @override
  String get travelUpcomingAndActive => '即将开始和有效';

  @override
  String get travelCancellationsAndRefunds => '取消和退款';

  @override
  String get travelPaymentPending => '付款待处理';

  @override
  String get travelPaymentProcessing => '付款处理中';

  @override
  String get travelVoucherIssued => '凭证已签发';

  @override
  String get travelCancellationRequested => '已请求取消';

  @override
  String get travelRefundInReview => '退款审核中';

  @override
  String get travelCancelled => '已取消';

  @override
  String get travelExpired => '已过期';

  @override
  String get travelStatusUnavailable => '状态不可用';

  @override
  String get travelBookingCancelled => '预订已取消';

  @override
  String get travelBookingExpired => '预订已过期';

  @override
  String get travelCompletePayment => '完成付款';

  @override
  String get travelPaymentIsProcessing => '付款正在处理';

  @override
  String get travelFlightRequestSubmitted => '航班请求已提交';

  @override
  String get travelEsimRequestSubmitted => 'eSIM 请求已提交';

  @override
  String get travelBookingStatusUnavailable => '预订状态不可用';

  @override
  String get travelBookingCancelledDescription => '此预订已取消。没有可用的有效凭证。';

  @override
  String get travelBookingExpiredDescription => '预订保留在确认前已过期。';

  @override
  String get travelCancellationRequestedDescription => '您的取消请求正在等待供应商权威审核。';

  @override
  String get travelRefundInReviewDescription => '您的退款请求正在审核中。最终金额和时间尚未确认。';

  @override
  String get travelPaymentPendingDescription => '此预订的付款尚未确认。';

  @override
  String get travelPaymentProcessingDescription => '钱包结果仍在验证中。请勿再次提交付款。';

  @override
  String get travelSupplierPendingDescription => '已收到付款，但供应商确认或旅行文件尚未准备好。';

  @override
  String get travelUnknownStatusDescription => '无法识别最新预订状态。请先刷新“我的预订”。';

  @override
  String get travelConfirmedArtifactPendingDescription => '预订已确认，但凭证或机票尚不可用。';

  @override
  String get travelStatusReference => '状态参考';

  @override
  String get travelRequestRefund => '申请退款';

  @override
  String get travelCancelBooking => '取消预订';

  @override
  String get travelPurchaseDate => '购买日期';

  @override
  String get travelSupplierReference => '供应商参考';

  @override
  String get travelBookingNumber => '预订编号';

  @override
  String get travelVoucherNumber => '凭证编号';

  @override
  String get travelRoom => '房间';

  @override
  String get travelRooms => '房间数';

  @override
  String get travelBoard => '膳食';

  @override
  String get travelCancellationPolicy => '取消政策';

  @override
  String get travelBeneficiary => '旅客或受益人';

  @override
  String get travelDeparture => '出发';

  @override
  String get travelArrival => '到达';

  @override
  String get travelFlightNumber => '航班号';

  @override
  String get travelAirline => '航空公司';

  @override
  String get travelCabin => '舱位';

  @override
  String get travelBaggage => '行李';

  @override
  String get travelRefundReviewNotice => '这会发送审核请求。取消和退款不会立即完成，且可能产生供应商罚金。';

  @override
  String get travelReason => '原因';

  @override
  String get travelReasonPlansChanged => '旅行计划变更';

  @override
  String get travelReasonBookingMistake => '预订错误';

  @override
  String get travelReasonPersonal => '个人原因';

  @override
  String get travelAdditionalNoteOptional => '附加备注（可选）';

  @override
  String get travelKeepBooking => '保留预订';

  @override
  String get travelSubmitRequest => '提交请求';

  @override
  String get travelCancellationUnavailable => '当前状态下无法取消此预订。';

  @override
  String get travelRefundRequestAwaitingReview => '您的取消和退款请求正在等待审核。';

  @override
  String get travelPriceLowToHigh => '价格：从低到高';

  @override
  String get travelPriceHighToLow => '价格：从高到低';

  @override
  String get travelRatingHighToLow => '评分：从高到低';

  @override
  String get travelAllRatings => '所有评分';

  @override
  String get travelRating => '评分';

  @override
  String get travelSortAndFilter => '排序和筛选';

  @override
  String get travelShortestDuration => '最短时长';

  @override
  String get travelNonRefundable => '不可退款';

  @override
  String get travelEsimDeviceReadinessTitle => '检查设备兼容性';

  @override
  String get travelEsimDeviceReadinessDescription =>
      '购买前，请确认您的设备支持 eSIM，并且未锁定其他移动套餐。';

  @override
  String get travelEsimCompatibilityNotice =>
      '购买套餐不保证设备兼容。只有后端标记 eSIM 就绪后才会显示安装详情。';

  @override
  String get travelEsimValidity => '有效期';

  @override
  String get travelEsimActivationReady => '您的 eSIM 安装详情已准备好。';

  @override
  String get travelPaymentReceived => '已收到付款';

  @override
  String get travelPaymentReceivedDescription =>
      '已收到付款。eCardo Travel 正在完成供应商确认，然后签发最终文件。';

  @override
  String get travelSearchFailedDescription => '搜索未完成。如有之前结果，将继续显示；请编辑搜索或重试。';

  @override
  String get travelReservationFailedDescription => '无法创建预订。此应用会话未从您的钱包扣款。';

  @override
  String get travelRefundFailedDescription => '取消或退款请求未提交。请查看预订并重试。';

  @override
  String get travelNoPaymentAttemptedAfterExpiry => '此过期保留在本应用会话中未尝试付款，也未扣款。';

  @override
  String get travelLastUpdated => '最后更新';

  @override
  String get travelJourneySearch => '搜索';

  @override
  String get travelJourneyCompare => '比较';

  @override
  String get travelJourneyReview => '核对';

  @override
  String get travelJourneyPay => '支付';

  @override
  String get travelHotelSearchGuidance => '选择目的地、日期和入住人数。结果与可订状态始终来自旅行后端。';

  @override
  String get travelHotelResultsGuidance => '打开选项前，请比较后端返回的价格、评分、设施、位置、房型和政策。';

  @override
  String get travelHotelDetailsGuidance => '继续前，请核对住宿、房型、入住人数、价格和取消政策。';

  @override
  String get travelFlightSearchGuidance => '选择航线、日期和乘客人数。航班余位和票价始终来自旅行后端。';

  @override
  String get travelFlightResultsGuidance =>
      '选择前，请比较后端返回的时间、航空公司、舱位、行李、票价和退改信息。';

  @override
  String get travelFlightDetailsGuidance => '继续前，请核对航班、票价组成、行李、乘客人数和取消政策。';

  @override
  String travelSelectedForComparison(int count) {
    return '已选择 $count 项';
  }

  @override
  String get travelCompare => '比较';

  @override
  String get travelCompareLimit => '每次最多可比较三个选项。';

  @override
  String get travelCompareHotels => '比较酒店';

  @override
  String get travelCompareFlights => '比较航班';

  @override
  String get travelComparisonUsesBackendFacts => '仅显示后端返回的事实，不推测缺失信息。';

  @override
  String get travelAddress => '地址';

  @override
  String get travelAircraft => '机型';

  @override
  String get travelDescription => '说明';

  @override
  String get travelDuration => '时长';

  @override
  String get travelRefundPolicy => '退款政策';

  @override
  String get travelPostPurchaseGuidance =>
      '请保留订单编号，刷新“我的预订”查看状态变化，并仅使用后端已签发的旅行凭证。';
  @override
  String get remittanceTitle => 'International Remittance';
  @override
  String get remittanceHistoryTitle => 'Remittance History';
  @override
  String get remittanceDetailsTitle => 'Remittance Details';
  @override
  String get remittanceSelectPayoutMethod => 'Select Payout Method';
  @override
  String get remittanceNoMethods => 'No remittance methods available.\nPlease try again later.';
  @override
  String get remittanceSendAmount => 'Send Amount';
  @override
  String get remittanceSendCurrency => '发送货币';
  @override
  String get remittanceSelectSendCurrency => '选择发送货币';
  @override
  String get remittanceLoadingCurrencies => '正在加载货币…';
  @override
  String get remittanceNoCurrencies => '没有可用货币';
  @override
  String get remittanceEnterAmount => 'Enter amount';
  @override
  String get remittanceUnknownMethod => 'Unknown';
  @override
  String remittanceRateLocked(int seconds) => 'Rate locked: ${seconds}s';
  @override
  String get remittanceExchangeRate => 'Exchange Rate';
  @override
  String get remittanceReceiveAmount => 'Receive Amount';
  @override
  String get remittanceSystemFee => 'System Fee';
  @override
  String get remittanceTotalPayable => 'Total Payable';
  @override
  String get remittanceGetQuote => 'Get Quote';
  @override
  String get remittanceStepAmount => 'Amount';
  @override
  String get remittanceStepSender => 'Sender';
  @override
  String get remittanceStepReceiver => 'Receiver';
  @override
  String get remittanceStepReview => 'Review';
  @override
  String get remittanceStepDone => 'Done';
  @override
  String get remittanceSenderInfo => 'Sender Information';
  @override
  String get remittanceSelectCountry => 'Select country';
  @override
  String get remittanceSenderTypeIndividual => 'Individual';
  @override
  String get remittanceSenderTypeBusiness => 'Business';
  @override
  String get remittanceSenderName => 'Full Name';
  @override
  String get remittanceSenderPhone => 'Phone Number';
  @override
  String get remittanceSenderIdNumber => 'ID Number';
  @override
  String get remittanceReceiverInfo => 'Receiver Information';
  @override
  String get remittancePayoutDetails => 'Payout Details';
  @override
  String get remittancePayoutDetailsHint => 'Fill in the fields relevant to the selected payout method.';
  @override
  String get remittanceReceiverName => 'Full Name';
  @override
  String get remittanceReceiverPhone => 'Phone Number';
  @override
  String get remittanceBankName => 'Bank Name';
  @override
  String get remittanceAccountNumber => 'Account Number';
  @override
  String get remittanceIban => 'IBAN';
  @override
  String get remittanceSwift => 'SWIFT Code';
  @override
  String get remittanceShabaNumber => 'SHABA Number';
  @override
  String get remittanceUsdtAddress => 'USDT Address';
  @override
  String get remittanceAlipayAccount => 'Alipay Account';
  @override
  String get remittanceWechatAccount => 'WeChat Account';
  @override
  String get remittanceReviewConfirm => 'Review & Confirm';
  @override
  String get remittanceReviewHint => 'Please review all details before submitting your remittance request.';
  @override
  String get remittanceTermsNotice => 'By submitting, you agree to our remittance terms. The rate is locked for 15 minutes. You will need to upload KYC documents and payment receipt after submission.';
  @override
  String get remittanceReviewSender => 'Sender';
  @override
  String get remittanceReviewReceiver => 'Receiver';
  @override
  String get remittanceReviewPayment => 'Payment';
  @override
  String get remittanceRequestSubmitted => 'Request Submitted!';
  @override
  String get remittanceRequestCreated => 'Your remittance request has been created.';
  @override
  String get remittanceUploadDocuments => 'Upload Documents';
  @override
  String get remittanceUploadHint => 'Upload your KYC documents and payment receipt to proceed.';
  @override
  String get remittanceAddDocument => 'Add Document';
  @override
  String get remittanceDocumentType => 'Document Type';
  @override
  String get remittanceDocTypeKyc => 'KYC Document';
  @override
  String get remittanceDocTypePaymentReceipt => 'Payment Receipt';
  @override
  String get remittanceDocTypePayoutReceipt => 'Payout Receipt';
  @override
  String get remittanceDocTypeOther => 'Other';
  @override
  String get remittanceCancel => 'Cancel';
  @override
  String get remittanceAdd => 'Add';
  @override
  String get remittanceTakePhoto => '拍照';
  @override
  String get remittanceChooseFromGallery => '从相册选择';
  @override
  String get remittanceChooseFile => '选择文件';
  @override
  String get remittanceErrFileNotFound => '所选文件不存在';
  @override
  String get remittanceErrPickFile => '无法选取文件';
  @override
  String get remittanceErrNoValidFiles => '没有可上传的有效文件。请重新选择您的文档。';
  @override
  String get remittanceContinue => 'Continue';
  @override
  String get remittanceSubmitRequest => 'Submit Request';
  @override
  String get remittanceUploading => 'Uploading...';
  @override
  String get remittanceRefresh => 'Refresh';
  @override
  String get remittanceNoHistory => 'No remittances yet';
  @override
  String get remittanceNoHistoryHint => 'Your remittance history will appear here.';
  @override
  String get remittanceSend => 'Send';
  @override
  String get remittanceReceive => 'Receive';
  @override
  String get remittanceDate => 'Date';
  @override
  String get remittanceNotFound => 'Remittance not found';
  @override
  String get remittanceStatusFinalized => 'This request is finalized.';
  @override
  String get remittanceStatusProcessing => 'Your request is being processed.';
  @override
  String get remittanceStatusActionNeeded => 'Please complete the required steps.';
  @override
  String get remittanceDetailsSectionSender => 'Sender Information';
  @override
  String get remittanceDetailsSectionReceiver => 'Receiver Information';
  @override
  String get remittanceDetailsSectionPayment => 'Payment Details';
  @override
  String get remittanceDetailsSectionTimeline => 'Status Timeline';
  @override
  String get remittanceErrLoadMethods => 'Failed to load methods';
  @override
  String get remittanceErrSelectPayout => 'Please select a payout method';
  @override
  String get remittanceErrInvalidAmount => 'Please enter a valid amount';
  @override
  String get remittanceErrSelectSendCurrency => 'Please select a send currency';
  @override
  String get remittanceErrQuoteFailed => 'Quote failed';
  @override
  String get remittanceErrRequestQuoteFirst => 'Please request a quote first';
  @override
  String get remittanceErrQuoteExpired => 'Quote expired. Please request a new one.';
  @override
  String get remittanceErrSenderInfo => 'Please complete sender information';
  @override
  String get remittanceErrReceiverInfo => 'Please complete receiver information';
  @override
  String get remittanceErrSubmissionFailed => 'Submission failed';
  @override
  String get remittanceErrNoRemittance => 'No remittance to upload to';
  @override
  String get remittanceErrAddDocument => 'Please add at least one document';
  @override
  String get remittanceErrUploadFailed => 'Upload failed';
  @override
  String get remittanceErrLoadDetails => 'Failed to load details';
  @override
  String get remittanceErrCompleteSender => 'Please complete all sender fields';
  @override
  String get remittanceErrCompleteReceiver => 'Please complete all receiver fields';
  @override
  String get remittanceSuccessUploaded => 'Documents uploaded successfully';
  @override
  String get remittanceError => 'Error';
  @override
  String get remittanceStatusDraft => 'Draft';
  @override
  String get remittanceStatusWaitingInformation => 'Waiting Information';
  @override
  String get remittanceStatusWaitingDocuments => 'Waiting Documents';
  @override
  String get remittanceStatusWaitingPayment => 'Waiting Payment';
  @override
  String get remittanceStatusPaymentReviewing => 'Payment Reviewing';
  @override
  String get remittanceStatusInProcess => 'In Process';
  @override
  String get remittanceStatusDestinationProcessing => 'Destination Processing';
  @override
  String get remittanceStatusDestinationPaid => 'Destination Paid';
  @override
  String get remittanceStatusCompleted => 'Completed';
  @override
  String get remittanceStatusRejected => 'Rejected';
  @override
  String get remittanceStatusExpired => 'Expired';
  @override
  String get remittanceStatusCancelled => 'Cancelled';
  @override
  String get remittanceStatusRefundRequested => 'Refund Requested';
  @override
  String get remittanceStatusRefundCompleted => 'Refund Completed';
  @override
  String get remittanceStatusUnknown => 'Unknown';
}
