import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @comment_common_maintenance.
  ///
  /// In en, this message translates to:
  /// **'==== Maintenance ===='**
  String get comment_common_maintenance;

  /// No description provided for @maintenanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Under Maintenance'**
  String get maintenanceTitle;

  /// No description provided for @maintenanceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We\'re performing scheduled maintenance to improve your experience.'**
  String get maintenanceSubtitle;

  /// No description provided for @comment_common_alert_bottom_sheet.
  ///
  /// In en, this message translates to:
  /// **'==== Alert Bottom Sheet ===='**
  String get comment_common_alert_bottom_sheet;

  /// No description provided for @alertBottonSheetConfirmButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get alertBottonSheetConfirmButton;

  /// No description provided for @alertBottonSheetCancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get alertBottonSheetCancelButton;

  /// No description provided for @comment_all_controller_load_Error.
  ///
  /// In en, this message translates to:
  /// **'==== All Controller Load Error ===='**
  String get comment_all_controller_load_Error;

  /// No description provided for @allControllerLoadError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong!'**
  String get allControllerLoadError;

  /// No description provided for @comment_common_exit_application.
  ///
  /// In en, this message translates to:
  /// **'==== Exit Application ===='**
  String get comment_common_exit_application;

  /// No description provided for @exitApplicationTitle.
  ///
  /// In en, this message translates to:
  /// **'Exit Application'**
  String get exitApplicationTitle;

  /// No description provided for @exitApplicationMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to exit the application?'**
  String get exitApplicationMessage;

  /// No description provided for @comment_common_dropdown.
  ///
  /// In en, this message translates to:
  /// **'==== Common Dropdown ===='**
  String get comment_common_dropdown;

  /// No description provided for @commonDropdownSelectGender.
  ///
  /// In en, this message translates to:
  /// **'Select Gender'**
  String get commonDropdownSelectGender;

  /// No description provided for @commonDropdownGender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get commonDropdownGender;

  /// No description provided for @commonDropdownGenderNotFound.
  ///
  /// In en, this message translates to:
  /// **'Gender not found'**
  String get commonDropdownGenderNotFound;

  /// No description provided for @commonDropdownMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get commonDropdownMale;

  /// No description provided for @commonDropdownFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get commonDropdownFemale;

  /// No description provided for @commonDropdownOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get commonDropdownOther;

  /// No description provided for @comment_welcome.
  ///
  /// In en, this message translates to:
  /// **'==== Welcome Screen ===='**
  String get comment_welcome;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Qunzo'**
  String get welcomeTitle;

  /// No description provided for @welcomeDescription.
  ///
  /// In en, this message translates to:
  /// **'Qunzo Empowers you with Multi-Wallet Management, Instant Swaps, and Secure Transactions.'**
  String get welcomeDescription;

  /// No description provided for @welcomeSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get welcomeSignIn;

  /// No description provided for @welcomeCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get welcomeCreateAccount;

  /// No description provided for @comment_sign_in.
  ///
  /// In en, this message translates to:
  /// **'==== Sign In Screen ===='**
  String get comment_sign_in;

  /// No description provided for @signInWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back!'**
  String get signInWelcomeBack;

  /// No description provided for @signInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Join and take control of your finances today'**
  String get signInSubtitle;

  /// No description provided for @signInEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get signInEmail;

  /// No description provided for @signInPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get signInPassword;

  /// No description provided for @signInForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forget password'**
  String get signInForgotPassword;

  /// No description provided for @signInButton.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signInButton;

  /// No description provided for @signInNotRegistered.
  ///
  /// In en, this message translates to:
  /// **'Not registered yet? '**
  String get signInNotRegistered;

  /// No description provided for @signInCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get signInCreateAccount;

  /// No description provided for @signInBiometricErrorFirstTime.
  ///
  /// In en, this message translates to:
  /// **'First Sign In with Email and Password'**
  String get signInBiometricErrorFirstTime;

  /// No description provided for @signInBiometricErrorNotEnabled.
  ///
  /// In en, this message translates to:
  /// **'Your biometric is not enabled'**
  String get signInBiometricErrorNotEnabled;

  /// No description provided for @signInRegistrationDisabled.
  ///
  /// In en, this message translates to:
  /// **'Registration is disabled'**
  String get signInRegistrationDisabled;

  /// No description provided for @signInValidationEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'The email field is required'**
  String get signInValidationEmailRequired;

  /// No description provided for @signInValidationPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'The password field is required'**
  String get signInValidationPasswordRequired;

  /// No description provided for @comment_two_factor_auth.
  ///
  /// In en, this message translates to:
  /// **'==== Two Factor Authentication Screen ===='**
  String get comment_two_factor_auth;

  /// No description provided for @twoFactorAuthTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify Two FA'**
  String get twoFactorAuthTitle;

  /// No description provided for @twoFactorAuthSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter code via google authenticator app'**
  String get twoFactorAuthSubtitle;

  /// No description provided for @twoFactorAuthEnterOtp.
  ///
  /// In en, this message translates to:
  /// **'Enter OTP'**
  String get twoFactorAuthEnterOtp;

  /// No description provided for @twoFactorAuthVerifyButton.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get twoFactorAuthVerifyButton;

  /// No description provided for @twoFactorAuthBackTo.
  ///
  /// In en, this message translates to:
  /// **'Back to? '**
  String get twoFactorAuthBackTo;

  /// No description provided for @twoFactorAuthSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get twoFactorAuthSignIn;

  /// No description provided for @twoFactorAuthOtpRequired.
  ///
  /// In en, this message translates to:
  /// **'The otp field is required'**
  String get twoFactorAuthOtpRequired;

  /// No description provided for @comment_forgot_password.
  ///
  /// In en, this message translates to:
  /// **'==== Forgot Password Screen ===='**
  String get comment_forgot_password;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Your Password'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Don\'t worry! It happens. Enter your email to reset your password.'**
  String get forgotPasswordSubtitle;

  /// No description provided for @forgotPasswordEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get forgotPasswordEmail;

  /// No description provided for @forgotPasswordButton.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get forgotPasswordButton;

  /// No description provided for @forgotPasswordBackTo.
  ///
  /// In en, this message translates to:
  /// **'Back to? '**
  String get forgotPasswordBackTo;

  /// No description provided for @forgotPasswordSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get forgotPasswordSignIn;

  /// No description provided for @forgotPasswordEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'The email field is required'**
  String get forgotPasswordEmailRequired;

  /// No description provided for @comment_forgot_password_pin_verification.
  ///
  /// In en, this message translates to:
  /// **'==== Forgot Password Pin Verification Screen ===='**
  String get comment_forgot_password_pin_verification;

  /// No description provided for @forgotPasswordPinVerifyTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify Email'**
  String get forgotPasswordPinVerifyTitle;

  /// No description provided for @forgotPasswordPinOtpSent.
  ///
  /// In en, this message translates to:
  /// **'OTP sent to '**
  String get forgotPasswordPinOtpSent;

  /// No description provided for @forgotPasswordPinEnterOtp.
  ///
  /// In en, this message translates to:
  /// **'Enter OTP'**
  String get forgotPasswordPinEnterOtp;

  /// No description provided for @forgotPasswordPinOtpCountdown.
  ///
  /// In en, this message translates to:
  /// **'OTP in'**
  String get forgotPasswordPinOtpCountdown;

  /// No description provided for @forgotPasswordPinVerifyButton.
  ///
  /// In en, this message translates to:
  /// **'Verify OTP'**
  String get forgotPasswordPinVerifyButton;

  /// No description provided for @forgotPasswordPinDidNotReceive.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive the code? '**
  String get forgotPasswordPinDidNotReceive;

  /// No description provided for @forgotPasswordPinResend.
  ///
  /// In en, this message translates to:
  /// **'Resend'**
  String get forgotPasswordPinResend;

  /// No description provided for @forgotPasswordPinOtpRequired.
  ///
  /// In en, this message translates to:
  /// **'The otp field is required'**
  String get forgotPasswordPinOtpRequired;

  /// No description provided for @comment_reset_password.
  ///
  /// In en, this message translates to:
  /// **'==== Reset Password Screen ===='**
  String get comment_reset_password;

  /// No description provided for @resetPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPasswordTitle;

  /// No description provided for @resetPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Write your password and confirm password.'**
  String get resetPasswordSubtitle;

  /// No description provided for @resetPasswordPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get resetPasswordPassword;

  /// No description provided for @resetPasswordConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get resetPasswordConfirmPassword;

  /// No description provided for @resetPasswordButton.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get resetPasswordButton;

  /// No description provided for @resetPasswordAlreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get resetPasswordAlreadyHaveAccount;

  /// No description provided for @resetPasswordSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get resetPasswordSignIn;

  /// No description provided for @resetPasswordValidationRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get resetPasswordValidationRequired;

  /// No description provided for @resetPasswordValidationMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get resetPasswordValidationMinLength;

  /// No description provided for @resetPasswordValidationConfirmRequired.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get resetPasswordValidationConfirmRequired;

  /// No description provided for @resetPasswordValidationMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords don\'t match'**
  String get resetPasswordValidationMismatch;

  /// No description provided for @comment_auth_id_verification.
  ///
  /// In en, this message translates to:
  /// **'==== Auth ID Verification Screen ===='**
  String get comment_auth_id_verification;

  /// No description provided for @authIdVerificationInvalidFieldType.
  ///
  /// In en, this message translates to:
  /// **'Invalid field type'**
  String get authIdVerificationInvalidFieldType;

  /// No description provided for @authIdVerificationUnknownFieldType.
  ///
  /// In en, this message translates to:
  /// **'Unknown field type: '**
  String get authIdVerificationUnknownFieldType;

  /// No description provided for @comment_camera_type_section.
  ///
  /// In en, this message translates to:
  /// **'==== Camera Type Section ===='**
  String get comment_camera_type_section;

  /// No description provided for @cameraTypeBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get cameraTypeBack;

  /// No description provided for @cameraTypeNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get cameraTypeNotAvailable;

  /// No description provided for @cameraTypeButton.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get cameraTypeButton;

  /// No description provided for @cameraTypeSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get cameraTypeSkip;

  /// No description provided for @comment_file_type_section.
  ///
  /// In en, this message translates to:
  /// **'==== File Type Section ===='**
  String get comment_file_type_section;

  /// No description provided for @fileTypeBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get fileTypeBack;

  /// No description provided for @fileTypeNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get fileTypeNotAvailable;

  /// No description provided for @fileTypeChooseFile.
  ///
  /// In en, this message translates to:
  /// **'Choose File'**
  String get fileTypeChooseFile;

  /// No description provided for @fileTypeSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get fileTypeSkip;

  /// No description provided for @comment_front_camera_type_section.
  ///
  /// In en, this message translates to:
  /// **'==== Front Camera Type Section ===='**
  String get comment_front_camera_type_section;

  /// No description provided for @frontCameraTypeBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get frontCameraTypeBack;

  /// No description provided for @frontCameraTypeNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get frontCameraTypeNotAvailable;

  /// No description provided for @frontCameraTypeButton.
  ///
  /// In en, this message translates to:
  /// **'Front Camera'**
  String get frontCameraTypeButton;

  /// No description provided for @frontCameraTypeSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get frontCameraTypeSkip;

  /// No description provided for @comment_kyc_submission_section.
  ///
  /// In en, this message translates to:
  /// **'==== KYC Submission Section ===='**
  String get comment_kyc_submission_section;

  /// No description provided for @kycSubmissionIdVerification.
  ///
  /// In en, this message translates to:
  /// **'ID Verification'**
  String get kycSubmissionIdVerification;

  /// No description provided for @kycSubmissionSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get kycSubmissionSubmit;

  /// No description provided for @kycSubmissionNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get kycSubmissionNext;

  /// No description provided for @kycSubmissionReUpload.
  ///
  /// In en, this message translates to:
  /// **'Re Upload'**
  String get kycSubmissionReUpload;

  /// No description provided for @kycSubmissionRetake.
  ///
  /// In en, this message translates to:
  /// **'Retake'**
  String get kycSubmissionRetake;

  /// No description provided for @comment_email_screen.
  ///
  /// In en, this message translates to:
  /// **'==== Email Screen ===='**
  String get comment_email_screen;

  /// No description provided for @emailScreenCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Your Account'**
  String get emailScreenCreateAccount;

  /// No description provided for @emailScreenSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Join and take control of your finances today'**
  String get emailScreenSubtitle;

  /// No description provided for @emailScreenEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailScreenEmail;

  /// No description provided for @emailScreenContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get emailScreenContinue;

  /// No description provided for @emailScreenAlreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get emailScreenAlreadyHaveAccount;

  /// No description provided for @emailScreenSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get emailScreenSignIn;

  /// No description provided for @emailScreenEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter an email'**
  String get emailScreenEmailRequired;

  /// No description provided for @comment_personal_info_screen.
  ///
  /// In en, this message translates to:
  /// **'==== Personal Info Screen ===='**
  String get comment_personal_info_screen;

  /// No description provided for @personalInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Information'**
  String get personalInfoTitle;

  /// No description provided for @personalInfoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your legal information to continue.'**
  String get personalInfoSubtitle;

  /// No description provided for @personalInfoFirstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get personalInfoFirstName;

  /// No description provided for @personalInfoLastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get personalInfoLastName;

  /// No description provided for @personalInfoUserName.
  ///
  /// In en, this message translates to:
  /// **'User Name'**
  String get personalInfoUserName;

  /// No description provided for @personalInfoCountry.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get personalInfoCountry;

  /// No description provided for @personalInfoSelectCountry.
  ///
  /// In en, this message translates to:
  /// **'Select Country'**
  String get personalInfoSelectCountry;

  /// No description provided for @personalInfoPhoneNo.
  ///
  /// In en, this message translates to:
  /// **'Phone No'**
  String get personalInfoPhoneNo;

  /// No description provided for @personalInfoReferralCode.
  ///
  /// In en, this message translates to:
  /// **'Referral Code'**
  String get personalInfoReferralCode;

  /// No description provided for @personalInfoContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get personalInfoContinue;

  /// No description provided for @personalInfoValidationFirstNameRequired.
  ///
  /// In en, this message translates to:
  /// **'First name is required'**
  String get personalInfoValidationFirstNameRequired;

  /// No description provided for @personalInfoValidationLastNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Last name is required'**
  String get personalInfoValidationLastNameRequired;

  /// No description provided for @personalInfoValidationUserNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Username is required'**
  String get personalInfoValidationUserNameRequired;

  /// No description provided for @personalInfoValidationCountryRequired.
  ///
  /// In en, this message translates to:
  /// **'Country is required'**
  String get personalInfoValidationCountryRequired;

  /// No description provided for @personalInfoValidationPhoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Phone number is required'**
  String get personalInfoValidationPhoneRequired;

  /// No description provided for @personalInfoValidationReferralCodeRequired.
  ///
  /// In en, this message translates to:
  /// **'Referral code is required'**
  String get personalInfoValidationReferralCodeRequired;

  /// No description provided for @personalInfoValidationGenderRequired.
  ///
  /// In en, this message translates to:
  /// **'Gender is required'**
  String get personalInfoValidationGenderRequired;

  /// No description provided for @comment_setup_password_screen.
  ///
  /// In en, this message translates to:
  /// **'==== Setup Password Screen ===='**
  String get comment_setup_password_screen;

  /// No description provided for @setupPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Setup Password'**
  String get setupPasswordTitle;

  /// No description provided for @setupPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create a strong password and confirm it'**
  String get setupPasswordSubtitle;

  /// No description provided for @setupPasswordPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get setupPasswordPassword;

  /// No description provided for @setupPasswordConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get setupPasswordConfirmPassword;

  /// No description provided for @setupPasswordAgreeTerms.
  ///
  /// In en, this message translates to:
  /// **'I agree with the '**
  String get setupPasswordAgreeTerms;

  /// No description provided for @setupPasswordTermsConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get setupPasswordTermsConditions;

  /// No description provided for @setupPasswordButton.
  ///
  /// In en, this message translates to:
  /// **'Setup Password'**
  String get setupPasswordButton;

  /// No description provided for @setupPasswordValidationRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get setupPasswordValidationRequired;

  /// No description provided for @setupPasswordValidationMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get setupPasswordValidationMinLength;

  /// No description provided for @setupPasswordValidationConfirmRequired.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get setupPasswordValidationConfirmRequired;

  /// No description provided for @setupPasswordValidationMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords don\'t match'**
  String get setupPasswordValidationMismatch;

  /// No description provided for @setupPasswordValidationTermsRequired.
  ///
  /// In en, this message translates to:
  /// **'Please accept terms and conditions'**
  String get setupPasswordValidationTermsRequired;

  /// No description provided for @comment_sign_up_status_screen.
  ///
  /// In en, this message translates to:
  /// **'==== Sign Up Status Screen ===='**
  String get comment_sign_up_status_screen;

  /// No description provided for @signUpStatusTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Current Status'**
  String get signUpStatusTitle;

  /// No description provided for @signUpStatusSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A Quick 4-Step Process to Keep Your Qunzo Account Secure'**
  String get signUpStatusSubtitle;

  /// No description provided for @signUpStatusStep.
  ///
  /// In en, this message translates to:
  /// **'Step'**
  String get signUpStatusStep;

  /// No description provided for @signUpStatusEmailVerification.
  ///
  /// In en, this message translates to:
  /// **'Email Verification'**
  String get signUpStatusEmailVerification;

  /// No description provided for @signUpStatusSetupPassword.
  ///
  /// In en, this message translates to:
  /// **'Setup Password'**
  String get signUpStatusSetupPassword;

  /// No description provided for @signUpStatusPersonalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal Info'**
  String get signUpStatusPersonalInfo;

  /// No description provided for @signUpStatusVerification.
  ///
  /// In en, this message translates to:
  /// **'Verification'**
  String get signUpStatusVerification;

  /// No description provided for @signUpStatusInReview.
  ///
  /// In en, this message translates to:
  /// **'In Review'**
  String get signUpStatusInReview;

  /// No description provided for @signUpStatusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get signUpStatusRejected;

  /// No description provided for @signUpStatusNoReason.
  ///
  /// In en, this message translates to:
  /// **'No reason provided'**
  String get signUpStatusNoReason;

  /// No description provided for @signUpStatusNextStep.
  ///
  /// In en, this message translates to:
  /// **'Next Step'**
  String get signUpStatusNextStep;

  /// No description provided for @signUpStatusSubmitAgain.
  ///
  /// In en, this message translates to:
  /// **'Submit Again'**
  String get signUpStatusSubmitAgain;

  /// No description provided for @signUpStatusDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get signUpStatusDashboard;

  /// No description provided for @signUpStatusBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get signUpStatusBack;

  /// No description provided for @signUpStatusErrorProcessing.
  ///
  /// In en, this message translates to:
  /// **'Error processing next step. Please try again.'**
  String get signUpStatusErrorProcessing;

  /// No description provided for @signUpStatusVerificationTypeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Verification Type Is Empty!'**
  String get signUpStatusVerificationTypeEmpty;

  /// No description provided for @signUpStatusErrorLoadingTypes.
  ///
  /// In en, this message translates to:
  /// **'Error loading verification types. Please try again.'**
  String get signUpStatusErrorLoadingTypes;

  /// No description provided for @signUpStatusDropdownTwoVerificationNotFound.
  ///
  /// In en, this message translates to:
  /// **'Verification Type Not Found'**
  String get signUpStatusDropdownTwoVerificationNotFound;

  /// No description provided for @comment_verify_email_screen.
  ///
  /// In en, this message translates to:
  /// **'==== Verify Email Screen ===='**
  String get comment_verify_email_screen;

  /// No description provided for @verifyEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify Email'**
  String get verifyEmailTitle;

  /// No description provided for @verifyEmailOtpSent.
  ///
  /// In en, this message translates to:
  /// **'OTP sent to '**
  String get verifyEmailOtpSent;

  /// No description provided for @verifyEmailEnterOtp.
  ///
  /// In en, this message translates to:
  /// **'Enter OTP'**
  String get verifyEmailEnterOtp;

  /// No description provided for @verifyEmailResendAvailable.
  ///
  /// In en, this message translates to:
  /// **'Resend available in'**
  String get verifyEmailResendAvailable;

  /// No description provided for @verifyEmailRequestNewOtp.
  ///
  /// In en, this message translates to:
  /// **'You can request a new OTP now'**
  String get verifyEmailRequestNewOtp;

  /// No description provided for @verifyEmailButton.
  ///
  /// In en, this message translates to:
  /// **'Verify Email'**
  String get verifyEmailButton;

  /// No description provided for @verifyEmailDidNotReceive.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive the code? '**
  String get verifyEmailDidNotReceive;

  /// No description provided for @verifyEmailResend.
  ///
  /// In en, this message translates to:
  /// **'Resend'**
  String get verifyEmailResend;

  /// No description provided for @verifyEmailOtpRequired.
  ///
  /// In en, this message translates to:
  /// **'The otp field is required'**
  String get verifyEmailOtpRequired;

  /// No description provided for @comment_add_money_screen.
  ///
  /// In en, this message translates to:
  /// **'==== Add Money Screen ===='**
  String get comment_add_money_screen;

  /// No description provided for @addMoneyTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Money'**
  String get addMoneyTitle;

  /// No description provided for @addMoneyBalance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get addMoneyBalance;

  /// No description provided for @addMoneyHistory.
  ///
  /// In en, this message translates to:
  /// **'Add Money History'**
  String get addMoneyHistory;

  /// No description provided for @addMoneyWalletsNotFound.
  ///
  /// In en, this message translates to:
  /// **'Wallets Not Found'**
  String get addMoneyWalletsNotFound;

  /// No description provided for @comment_add_money_amount_step.
  ///
  /// In en, this message translates to:
  /// **'==== Add Money Amount Step ===='**
  String get comment_add_money_amount_step;

  /// No description provided for @addMoneyGateway.
  ///
  /// In en, this message translates to:
  /// **'Gateway'**
  String get addMoneyGateway;

  /// No description provided for @addMoneyGatewayNotFound.
  ///
  /// In en, this message translates to:
  /// **'Gateway not found'**
  String get addMoneyGatewayNotFound;

  /// No description provided for @addMoneySelectGateway.
  ///
  /// In en, this message translates to:
  /// **'Select Gateway'**
  String get addMoneySelectGateway;

  /// No description provided for @addMoneyCharge.
  ///
  /// In en, this message translates to:
  /// **'Charge:'**
  String get addMoneyCharge;

  /// No description provided for @addMoneyAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get addMoneyAmount;

  /// No description provided for @addMoneyMin.
  ///
  /// In en, this message translates to:
  /// **'Minimum'**
  String get addMoneyMin;

  /// No description provided for @addMoneyMax.
  ///
  /// In en, this message translates to:
  /// **'and Maximum'**
  String get addMoneyMax;

  /// No description provided for @addMoneyWriteHere.
  ///
  /// In en, this message translates to:
  /// **'Write here...'**
  String get addMoneyWriteHere;

  /// No description provided for @addMoneyAddMoneyButton.
  ///
  /// In en, this message translates to:
  /// **'Add Money'**
  String get addMoneyAddMoneyButton;

  /// No description provided for @comment_add_money_pending_step.
  ///
  /// In en, this message translates to:
  /// **'==== Add Money Pending Step ===='**
  String get comment_add_money_pending_step;

  /// No description provided for @addMoneyPendingTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Deposit Process Is\nPending'**
  String get addMoneyPendingTitle;

  /// No description provided for @addMoneyPendingAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get addMoneyPendingAmount;

  /// No description provided for @addMoneyPendingTransactionId.
  ///
  /// In en, this message translates to:
  /// **'Transaction ID'**
  String get addMoneyPendingTransactionId;

  /// No description provided for @addMoneyPendingWalletName.
  ///
  /// In en, this message translates to:
  /// **'Wallet Name'**
  String get addMoneyPendingWalletName;

  /// No description provided for @addMoneyPendingPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get addMoneyPendingPaymentMethod;

  /// No description provided for @addMoneyPendingCharge.
  ///
  /// In en, this message translates to:
  /// **'Charge'**
  String get addMoneyPendingCharge;

  /// No description provided for @addMoneyPendingType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get addMoneyPendingType;

  /// No description provided for @addMoneyPendingFinalAmount.
  ///
  /// In en, this message translates to:
  /// **'Final Amount'**
  String get addMoneyPendingFinalAmount;

  /// No description provided for @addMoneyPendingDepositAgain.
  ///
  /// In en, this message translates to:
  /// **'Deposit Again'**
  String get addMoneyPendingDepositAgain;

  /// No description provided for @addMoneyPendingBackHome.
  ///
  /// In en, this message translates to:
  /// **'Back Home'**
  String get addMoneyPendingBackHome;

  /// No description provided for @comment_add_money_review_step.
  ///
  /// In en, this message translates to:
  /// **'==== Add Money Review Step ===='**
  String get comment_add_money_review_step;

  /// No description provided for @addMoneyReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Review Details'**
  String get addMoneyReviewTitle;

  /// No description provided for @addMoneyReviewAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get addMoneyReviewAmount;

  /// No description provided for @addMoneyReviewWalletName.
  ///
  /// In en, this message translates to:
  /// **'Wallet Name'**
  String get addMoneyReviewWalletName;

  /// No description provided for @addMoneyReviewPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get addMoneyReviewPaymentMethod;

  /// No description provided for @addMoneyReviewCharge.
  ///
  /// In en, this message translates to:
  /// **'Charge'**
  String get addMoneyReviewCharge;

  /// No description provided for @addMoneyReviewTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get addMoneyReviewTotal;

  /// No description provided for @addMoneyReviewBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get addMoneyReviewBack;

  /// No description provided for @addMoneyReviewConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get addMoneyReviewConfirm;

  /// No description provided for @addMoneyReviewNoFileUploaded.
  ///
  /// In en, this message translates to:
  /// **'No file uploaded'**
  String get addMoneyReviewNoFileUploaded;

  /// No description provided for @comment_add_money_success_step.
  ///
  /// In en, this message translates to:
  /// **'==== Add Money Success Step ===='**
  String get comment_add_money_success_step;

  /// No description provided for @addMoneySuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Deposit Money Success!'**
  String get addMoneySuccessTitle;

  /// No description provided for @addMoneySuccessAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get addMoneySuccessAmount;

  /// No description provided for @addMoneySuccessTransactionId.
  ///
  /// In en, this message translates to:
  /// **'Transection ID'**
  String get addMoneySuccessTransactionId;

  /// No description provided for @addMoneySuccessCharge.
  ///
  /// In en, this message translates to:
  /// **'Charge'**
  String get addMoneySuccessCharge;

  /// No description provided for @addMoneySuccessTransactionType.
  ///
  /// In en, this message translates to:
  /// **'Transaction Type'**
  String get addMoneySuccessTransactionType;

  /// No description provided for @addMoneySuccessFinalAmount.
  ///
  /// In en, this message translates to:
  /// **'Final Amount'**
  String get addMoneySuccessFinalAmount;

  /// No description provided for @addMoneySuccessAddMoneyAgain.
  ///
  /// In en, this message translates to:
  /// **'Add Money Again'**
  String get addMoneySuccessAddMoneyAgain;

  /// No description provided for @addMoneySuccessBackHome.
  ///
  /// In en, this message translates to:
  /// **'Back Home'**
  String get addMoneySuccessBackHome;

  /// No description provided for @comment_add_money_history.
  ///
  /// In en, this message translates to:
  /// **'==== Add Money History ===='**
  String get comment_add_money_history;

  /// No description provided for @addMoneyHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Money History'**
  String get addMoneyHistoryTitle;

  /// No description provided for @comment_add_money_filter_bottom_sheet.
  ///
  /// In en, this message translates to:
  /// **'==== Add Money Filter Bottom Sheet ===='**
  String get comment_add_money_filter_bottom_sheet;

  /// No description provided for @addMoneyFilterTransactionId.
  ///
  /// In en, this message translates to:
  /// **'Transactions ID'**
  String get addMoneyFilterTransactionId;

  /// No description provided for @addMoneyFilterStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get addMoneyFilterStatus;

  /// No description provided for @addMoneyFilterSuccess.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get addMoneyFilterSuccess;

  /// No description provided for @addMoneyFilterPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get addMoneyFilterPending;

  /// No description provided for @addMoneyFilterFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get addMoneyFilterFailed;

  /// No description provided for @addMoneyFilterButton.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get addMoneyFilterButton;

  /// No description provided for @addMoneyFilterReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get addMoneyFilterReset;

  /// No description provided for @comment_create_beneficiary_screen.
  ///
  /// In en, this message translates to:
  /// **'==== Create Beneficiary Screen ===='**
  String get comment_create_beneficiary_screen;

  /// No description provided for @createBeneficiaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Create New'**
  String get createBeneficiaryTitle;

  /// No description provided for @createBeneficiaryAccountNumber.
  ///
  /// In en, this message translates to:
  /// **'Account Number'**
  String get createBeneficiaryAccountNumber;

  /// No description provided for @createBeneficiaryNickName.
  ///
  /// In en, this message translates to:
  /// **'Nick Name'**
  String get createBeneficiaryNickName;

  /// No description provided for @createBeneficiaryCreateButton.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get createBeneficiaryCreateButton;

  /// No description provided for @createBeneficiaryValidationAccountNumber.
  ///
  /// In en, this message translates to:
  /// **'Fill up account number'**
  String get createBeneficiaryValidationAccountNumber;

  /// No description provided for @createBeneficiaryValidationNickName.
  ///
  /// In en, this message translates to:
  /// **'Fill up nick name'**
  String get createBeneficiaryValidationNickName;

  /// No description provided for @comment_update_beneficiary_screen.
  ///
  /// In en, this message translates to:
  /// **'==== Update Beneficiary Screen ===='**
  String get comment_update_beneficiary_screen;

  /// No description provided for @updateBeneficiaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get updateBeneficiaryTitle;

  /// No description provided for @updateBeneficiaryNickName.
  ///
  /// In en, this message translates to:
  /// **'Nick Name'**
  String get updateBeneficiaryNickName;

  /// No description provided for @updateBeneficiaryUpdateButton.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get updateBeneficiaryUpdateButton;

  /// No description provided for @updateBeneficiaryValidationNickName.
  ///
  /// In en, this message translates to:
  /// **'Fill up nick name'**
  String get updateBeneficiaryValidationNickName;

  /// No description provided for @comment_account_user_types.
  ///
  /// In en, this message translates to:
  /// **'==== Account User Types ===='**
  String get comment_account_user_types;

  /// No description provided for @accountUserMerchant.
  ///
  /// In en, this message translates to:
  /// **'Merchant'**
  String get accountUserMerchant;

  /// No description provided for @accountUserBeneficiary.
  ///
  /// In en, this message translates to:
  /// **'Beneficiary'**
  String get accountUserBeneficiary;

  /// No description provided for @accountUserAgent.
  ///
  /// In en, this message translates to:
  /// **'Agent'**
  String get accountUserAgent;

  /// No description provided for @comment_cash_out_screen.
  ///
  /// In en, this message translates to:
  /// **'==== Cash Out Screen ===='**
  String get comment_cash_out_screen;

  /// No description provided for @cashOutTitle.
  ///
  /// In en, this message translates to:
  /// **'Cash Out From Agent'**
  String get cashOutTitle;

  /// No description provided for @cashOutHistory.
  ///
  /// In en, this message translates to:
  /// **'Cash Out History'**
  String get cashOutHistory;

  /// No description provided for @comment_cash_out_amount_step.
  ///
  /// In en, this message translates to:
  /// **'==== Cash Out Amount Step ===='**
  String get comment_cash_out_amount_step;

  /// No description provided for @cashOutAgentId.
  ///
  /// In en, this message translates to:
  /// **'Agent ID'**
  String get cashOutAgentId;

  /// No description provided for @cashOutAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get cashOutAmount;

  /// No description provided for @cashOutMin.
  ///
  /// In en, this message translates to:
  /// **'Minimum'**
  String get cashOutMin;

  /// No description provided for @cashOutMax.
  ///
  /// In en, this message translates to:
  /// **'and Maximum'**
  String get cashOutMax;

  /// No description provided for @cashOutButton.
  ///
  /// In en, this message translates to:
  /// **'Cash Out'**
  String get cashOutButton;

  /// No description provided for @cashOutSavedAgents.
  ///
  /// In en, this message translates to:
  /// **'Saved Agents'**
  String get cashOutSavedAgents;

  /// No description provided for @cashOutAgents.
  ///
  /// In en, this message translates to:
  /// **'Agents'**
  String get cashOutAgents;

  /// No description provided for @cashOutAddAgent.
  ///
  /// In en, this message translates to:
  /// **'Add Agent'**
  String get cashOutAddAgent;

  /// No description provided for @cashOutAid.
  ///
  /// In en, this message translates to:
  /// **'AID:'**
  String get cashOutAid;

  /// No description provided for @cashOutQrInvalidDigits.
  ///
  /// In en, this message translates to:
  /// **'Invalid QR code. Agent AID must be digits only.'**
  String get cashOutQrInvalidDigits;

  /// No description provided for @cashOutQrInvalidPrefix.
  ///
  /// In en, this message translates to:
  /// **'Invalid QR code. AID prefix not found.'**
  String get cashOutQrInvalidPrefix;

  /// No description provided for @cashOutDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure?'**
  String get cashOutDeleteConfirm;

  /// No description provided for @cashOutDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'You want to delete this agent?'**
  String get cashOutDeleteMessage;

  /// No description provided for @cashOutDeleteButton.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get cashOutDeleteButton;

  /// No description provided for @cashOutCancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cashOutCancelButton;

  /// No description provided for @comment_cash_out_review_step.
  ///
  /// In en, this message translates to:
  /// **'==== Cash Out Review Step ===='**
  String get comment_cash_out_review_step;

  /// No description provided for @cashOutReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Review Details'**
  String get cashOutReviewTitle;

  /// No description provided for @cashOutReviewAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get cashOutReviewAmount;

  /// No description provided for @cashOutReviewWallet.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get cashOutReviewWallet;

  /// No description provided for @cashOutReviewAgentAccount.
  ///
  /// In en, this message translates to:
  /// **'Agent Account'**
  String get cashOutReviewAgentAccount;

  /// No description provided for @cashOutReviewCharge.
  ///
  /// In en, this message translates to:
  /// **'Charge'**
  String get cashOutReviewCharge;

  /// No description provided for @cashOutReviewTotalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get cashOutReviewTotalAmount;

  /// No description provided for @cashOutReviewBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get cashOutReviewBack;

  /// No description provided for @cashOutReviewConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get cashOutReviewConfirm;

  /// No description provided for @comment_cash_out_success_step.
  ///
  /// In en, this message translates to:
  /// **'==== Cash Out Success Step ===='**
  String get comment_cash_out_success_step;

  /// No description provided for @cashOutSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Cash Out Success!'**
  String get cashOutSuccessTitle;

  /// No description provided for @cashOutSuccessAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get cashOutSuccessAmount;

  /// No description provided for @cashOutSuccessTransactionId.
  ///
  /// In en, this message translates to:
  /// **'Transection ID'**
  String get cashOutSuccessTransactionId;

  /// No description provided for @cashOutSuccessWalletName.
  ///
  /// In en, this message translates to:
  /// **'Wallet Name'**
  String get cashOutSuccessWalletName;

  /// No description provided for @cashOutSuccessPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get cashOutSuccessPaymentMethod;

  /// No description provided for @cashOutSuccessCharge.
  ///
  /// In en, this message translates to:
  /// **'Charge'**
  String get cashOutSuccessCharge;

  /// No description provided for @cashOutSuccessType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get cashOutSuccessType;

  /// No description provided for @cashOutSuccessFinalAmount.
  ///
  /// In en, this message translates to:
  /// **'Final Amount'**
  String get cashOutSuccessFinalAmount;

  /// No description provided for @cashOutSuccessCashOutAgain.
  ///
  /// In en, this message translates to:
  /// **'Cash Out Again'**
  String get cashOutSuccessCashOutAgain;

  /// No description provided for @cashOutSuccessBackHome.
  ///
  /// In en, this message translates to:
  /// **'Back Home'**
  String get cashOutSuccessBackHome;

  /// No description provided for @comment_cash_out_wallets_section.
  ///
  /// In en, this message translates to:
  /// **'==== Cash Out Wallets Section ===='**
  String get comment_cash_out_wallets_section;

  /// No description provided for @cashOutWalletsBalance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get cashOutWalletsBalance;

  /// No description provided for @cashOutWalletsNotFound.
  ///
  /// In en, this message translates to:
  /// **'Wallets Not Found'**
  String get cashOutWalletsNotFound;

  /// No description provided for @comment_cash_out_history.
  ///
  /// In en, this message translates to:
  /// **'==== Cash Out History ===='**
  String get comment_cash_out_history;

  /// No description provided for @cashOutHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Cash Out History'**
  String get cashOutHistoryTitle;

  /// No description provided for @comment_cash_out_filter_bottom_sheet.
  ///
  /// In en, this message translates to:
  /// **'==== Cash Out Filter Bottom Sheet ===='**
  String get comment_cash_out_filter_bottom_sheet;

  /// No description provided for @cashOutFilterTransactionId.
  ///
  /// In en, this message translates to:
  /// **'Transactions ID'**
  String get cashOutFilterTransactionId;

  /// No description provided for @cashOutFilterStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get cashOutFilterStatus;

  /// No description provided for @cashOutFilterButton.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get cashOutFilterButton;

  /// No description provided for @cashOutFilterReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get cashOutFilterReset;

  /// No description provided for @comment_exchange_screen.
  ///
  /// In en, this message translates to:
  /// **'==== Exchange Screen ===='**
  String get comment_exchange_screen;

  /// No description provided for @exchangeTitle.
  ///
  /// In en, this message translates to:
  /// **'Exchange Wallet'**
  String get exchangeTitle;

  /// No description provided for @exchangeHistory.
  ///
  /// In en, this message translates to:
  /// **'Exchange History'**
  String get exchangeHistory;

  /// No description provided for @comment_exchange_amount_step.
  ///
  /// In en, this message translates to:
  /// **'==== Exchange Amount Step ===='**
  String get comment_exchange_amount_step;

  /// No description provided for @exchangeAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get exchangeAmount;

  /// No description provided for @exchangeMin.
  ///
  /// In en, this message translates to:
  /// **'Minimum'**
  String get exchangeMin;

  /// No description provided for @exchangeMax.
  ///
  /// In en, this message translates to:
  /// **'and Maximum'**
  String get exchangeMax;

  /// No description provided for @exchangeButton.
  ///
  /// In en, this message translates to:
  /// **'Exchange'**
  String get exchangeButton;

  /// No description provided for @comment_exchange_review_step.
  ///
  /// In en, this message translates to:
  /// **'==== Exchange Review Step ===='**
  String get comment_exchange_review_step;

  /// No description provided for @exchangeReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Review Details'**
  String get exchangeReviewTitle;

  /// No description provided for @exchangeReviewAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get exchangeReviewAmount;

  /// No description provided for @exchangeReviewFromWallet.
  ///
  /// In en, this message translates to:
  /// **'From Wallet'**
  String get exchangeReviewFromWallet;

  /// No description provided for @exchangeReviewCharge.
  ///
  /// In en, this message translates to:
  /// **'Charge'**
  String get exchangeReviewCharge;

  /// No description provided for @exchangeReviewTotalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get exchangeReviewTotalAmount;

  /// No description provided for @exchangeReviewToWallet.
  ///
  /// In en, this message translates to:
  /// **'To Wallet'**
  String get exchangeReviewToWallet;

  /// No description provided for @exchangeReviewExchangeRate.
  ///
  /// In en, this message translates to:
  /// **'Exchange Rate'**
  String get exchangeReviewExchangeRate;

  /// No description provided for @exchangeReviewExchangeAmount.
  ///
  /// In en, this message translates to:
  /// **'Exchange Amount'**
  String get exchangeReviewExchangeAmount;

  /// No description provided for @exchangeReviewBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get exchangeReviewBack;

  /// No description provided for @exchangeReviewConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get exchangeReviewConfirm;

  /// No description provided for @comment_exchange_success_step.
  ///
  /// In en, this message translates to:
  /// **'==== Exchange Success Step ===='**
  String get comment_exchange_success_step;

  /// No description provided for @exchangeSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Exchange Success!'**
  String get exchangeSuccessTitle;

  /// No description provided for @exchangeSuccessAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get exchangeSuccessAmount;

  /// No description provided for @exchangeSuccessTransactionId.
  ///
  /// In en, this message translates to:
  /// **'Transaction ID'**
  String get exchangeSuccessTransactionId;

  /// No description provided for @exchangeSuccessPayAmount.
  ///
  /// In en, this message translates to:
  /// **'Pay Amount'**
  String get exchangeSuccessPayAmount;

  /// No description provided for @exchangeSuccessConvertedAmount.
  ///
  /// In en, this message translates to:
  /// **'Converted Amount'**
  String get exchangeSuccessConvertedAmount;

  /// No description provided for @exchangeSuccessCharge.
  ///
  /// In en, this message translates to:
  /// **'Charge'**
  String get exchangeSuccessCharge;

  /// No description provided for @exchangeSuccessDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get exchangeSuccessDate;

  /// No description provided for @exchangeSuccessFinalAmount.
  ///
  /// In en, this message translates to:
  /// **'Final Amount'**
  String get exchangeSuccessFinalAmount;

  /// No description provided for @exchangeSuccessExchangeAgain.
  ///
  /// In en, this message translates to:
  /// **'Exchange Again'**
  String get exchangeSuccessExchangeAgain;

  /// No description provided for @exchangeSuccessBackHome.
  ///
  /// In en, this message translates to:
  /// **'Back Home'**
  String get exchangeSuccessBackHome;

  /// No description provided for @comment_exchange_wallet_section.
  ///
  /// In en, this message translates to:
  /// **'==== Exchange Wallet Section ===='**
  String get comment_exchange_wallet_section;

  /// No description provided for @exchangeWalletBalance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get exchangeWalletBalance;

  /// No description provided for @exchangeWalletsNotFound.
  ///
  /// In en, this message translates to:
  /// **'Wallets Not Found'**
  String get exchangeWalletsNotFound;

  /// No description provided for @comment_exchange_wallet_to_wallet.
  ///
  /// In en, this message translates to:
  /// **'==== Exchange Wallet To Wallet ===='**
  String get comment_exchange_wallet_to_wallet;

  /// No description provided for @exchangeWalletToWallet.
  ///
  /// In en, this message translates to:
  /// **'Wallet to Wallet'**
  String get exchangeWalletToWallet;

  /// No description provided for @exchangeFromWallet.
  ///
  /// In en, this message translates to:
  /// **'From Wallet'**
  String get exchangeFromWallet;

  /// No description provided for @exchangeToWallet.
  ///
  /// In en, this message translates to:
  /// **'To Wallet'**
  String get exchangeToWallet;

  /// No description provided for @exchangeRate.
  ///
  /// In en, this message translates to:
  /// **'Exchange Rate: '**
  String get exchangeRate;

  /// No description provided for @exchangeWalletToWalletWalletsNotFound.
  ///
  /// In en, this message translates to:
  /// **'Wallets Not Found'**
  String get exchangeWalletToWalletWalletsNotFound;

  /// No description provided for @comment_exchange_history.
  ///
  /// In en, this message translates to:
  /// **'==== Exchange History ===='**
  String get comment_exchange_history;

  /// No description provided for @exchangeHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Exchange History'**
  String get exchangeHistoryTitle;

  /// No description provided for @comment_exchange_filter_bottom_sheet.
  ///
  /// In en, this message translates to:
  /// **'==== Exchange Filter Bottom Sheet ===='**
  String get comment_exchange_filter_bottom_sheet;

  /// No description provided for @exchangeFilterTransactionId.
  ///
  /// In en, this message translates to:
  /// **'Transactions ID'**
  String get exchangeFilterTransactionId;

  /// No description provided for @exchangeFilterStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get exchangeFilterStatus;

  /// No description provided for @exchangeFilterButton.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get exchangeFilterButton;

  /// No description provided for @exchangeFilterReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get exchangeFilterReset;

  /// No description provided for @comment_gift_code_screen.
  ///
  /// In en, this message translates to:
  /// **'==== Gift Code Screen ===='**
  String get comment_gift_code_screen;

  /// No description provided for @giftCodeTitle.
  ///
  /// In en, this message translates to:
  /// **'Gift Code'**
  String get giftCodeTitle;

  /// No description provided for @giftCodeCreateGift.
  ///
  /// In en, this message translates to:
  /// **'Create Gift'**
  String get giftCodeCreateGift;

  /// No description provided for @comment_create_gift_amount_step.
  ///
  /// In en, this message translates to:
  /// **'==== Create Gift Amount Step ===='**
  String get comment_create_gift_amount_step;

  /// No description provided for @createGiftAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get createGiftAmount;

  /// No description provided for @createGiftMin.
  ///
  /// In en, this message translates to:
  /// **'Minimum'**
  String get createGiftMin;

  /// No description provided for @createGiftMax.
  ///
  /// In en, this message translates to:
  /// **'and Maximum'**
  String get createGiftMax;

  /// No description provided for @createGiftButton.
  ///
  /// In en, this message translates to:
  /// **'Create Gift'**
  String get createGiftButton;

  /// No description provided for @comment_create_gift_review_section.
  ///
  /// In en, this message translates to:
  /// **'==== Create Gift Review Section ===='**
  String get comment_create_gift_review_section;

  /// No description provided for @createGiftReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Review Details'**
  String get createGiftReviewTitle;

  /// No description provided for @createGiftReviewAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get createGiftReviewAmount;

  /// No description provided for @createGiftReviewWalletName.
  ///
  /// In en, this message translates to:
  /// **'Wallet Name'**
  String get createGiftReviewWalletName;

  /// No description provided for @createGiftReviewCharge.
  ///
  /// In en, this message translates to:
  /// **'Charge'**
  String get createGiftReviewCharge;

  /// No description provided for @createGiftReviewTotalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get createGiftReviewTotalAmount;

  /// No description provided for @createGiftReviewBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get createGiftReviewBack;

  /// No description provided for @createGiftReviewConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get createGiftReviewConfirm;

  /// No description provided for @comment_create_gift_success_step.
  ///
  /// In en, this message translates to:
  /// **'==== Create Gift Success Step ===='**
  String get comment_create_gift_success_step;

  /// No description provided for @createGiftSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Gift Success!'**
  String get createGiftSuccessTitle;

  /// No description provided for @createGiftSuccessAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get createGiftSuccessAmount;

  /// No description provided for @createGiftSuccessCharge.
  ///
  /// In en, this message translates to:
  /// **'Charge'**
  String get createGiftSuccessCharge;

  /// No description provided for @createGiftSuccessFinalAmount.
  ///
  /// In en, this message translates to:
  /// **'Final Amount'**
  String get createGiftSuccessFinalAmount;

  /// No description provided for @createGiftSuccessCreatedAt.
  ///
  /// In en, this message translates to:
  /// **'Created At'**
  String get createGiftSuccessCreatedAt;

  /// No description provided for @createGiftSuccessCreateAgain.
  ///
  /// In en, this message translates to:
  /// **'Create Gift Code Again'**
  String get createGiftSuccessCreateAgain;

  /// No description provided for @createGiftSuccessBackHome.
  ///
  /// In en, this message translates to:
  /// **'Back Home'**
  String get createGiftSuccessBackHome;

  /// No description provided for @comment_create_gift_wallet_section.
  ///
  /// In en, this message translates to:
  /// **'==== Create Gift Wallet Section ===='**
  String get comment_create_gift_wallet_section;

  /// No description provided for @createGiftWalletBalance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get createGiftWalletBalance;

  /// No description provided for @createGiftWalletWalletsNotFound.
  ///
  /// In en, this message translates to:
  /// **'Wallets Not Found'**
  String get createGiftWalletWalletsNotFound;

  /// No description provided for @comment_gift_code_header_section.
  ///
  /// In en, this message translates to:
  /// **'==== Gift Code Header Section ===='**
  String get comment_gift_code_header_section;

  /// No description provided for @giftCodeHeaderTitle.
  ///
  /// In en, this message translates to:
  /// **'Gift Code'**
  String get giftCodeHeaderTitle;

  /// No description provided for @giftCodeHeaderGiftRedeem.
  ///
  /// In en, this message translates to:
  /// **'Gift Redeem'**
  String get giftCodeHeaderGiftRedeem;

  /// No description provided for @giftCodeHeaderMyGift.
  ///
  /// In en, this message translates to:
  /// **'My Gift'**
  String get giftCodeHeaderMyGift;

  /// No description provided for @giftCodeHeaderGiftRedeemHistory.
  ///
  /// In en, this message translates to:
  /// **'Gift Redeem History'**
  String get giftCodeHeaderGiftRedeemHistory;

  /// No description provided for @comment_gift_history.
  ///
  /// In en, this message translates to:
  /// **'==== Gift History ===='**
  String get comment_gift_history;

  /// No description provided for @giftHistoryCreatedAt.
  ///
  /// In en, this message translates to:
  /// **'Created At:'**
  String get giftHistoryCreatedAt;

  /// No description provided for @giftHistoryStatus.
  ///
  /// In en, this message translates to:
  /// **'Status: '**
  String get giftHistoryStatus;

  /// No description provided for @giftHistoryClaimed.
  ///
  /// In en, this message translates to:
  /// **'Claimed'**
  String get giftHistoryClaimed;

  /// No description provided for @giftHistoryClaimable.
  ///
  /// In en, this message translates to:
  /// **'Claimable'**
  String get giftHistoryClaimable;

  /// No description provided for @giftHistoryCodeCopied.
  ///
  /// In en, this message translates to:
  /// **'Gift Code Copied'**
  String get giftHistoryCodeCopied;

  /// No description provided for @comment_gift_history_filter_bottom_sheet.
  ///
  /// In en, this message translates to:
  /// **'==== Gift History Filter Bottom Sheet ===='**
  String get comment_gift_history_filter_bottom_sheet;

  /// No description provided for @giftHistoryFilterGiftCode.
  ///
  /// In en, this message translates to:
  /// **'Gift Code'**
  String get giftHistoryFilterGiftCode;

  /// No description provided for @giftHistoryFilterButton.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get giftHistoryFilterButton;

  /// No description provided for @comment_gift_redeem_section.
  ///
  /// In en, this message translates to:
  /// **'==== Gift Redeem Section ===='**
  String get comment_gift_redeem_section;

  /// No description provided for @giftRedeemGiftCode.
  ///
  /// In en, this message translates to:
  /// **'Gift Code'**
  String get giftRedeemGiftCode;

  /// No description provided for @giftRedeemButton.
  ///
  /// In en, this message translates to:
  /// **'Redeem'**
  String get giftRedeemButton;

  /// No description provided for @giftRedeemValidation.
  ///
  /// In en, this message translates to:
  /// **'Please enter an gift code'**
  String get giftRedeemValidation;

  /// No description provided for @comment_gift_redeem_history.
  ///
  /// In en, this message translates to:
  /// **'==== Gift Redeem History ===='**
  String get comment_gift_redeem_history;

  /// No description provided for @giftRedeemHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'My Redeem History'**
  String get giftRedeemHistoryTitle;

  /// No description provided for @giftRedeemHistoryCreatedAt.
  ///
  /// In en, this message translates to:
  /// **'Created At:'**
  String get giftRedeemHistoryCreatedAt;

  /// No description provided for @giftRedeemHistoryStatus.
  ///
  /// In en, this message translates to:
  /// **'Status: '**
  String get giftRedeemHistoryStatus;

  /// No description provided for @giftRedeemHistoryClaimed.
  ///
  /// In en, this message translates to:
  /// **'Claimed'**
  String get giftRedeemHistoryClaimed;

  /// No description provided for @giftRedeemHistoryClaimable.
  ///
  /// In en, this message translates to:
  /// **'Claimable'**
  String get giftRedeemHistoryClaimable;

  /// No description provided for @giftRedeemHistoryCodeCopied.
  ///
  /// In en, this message translates to:
  /// **'Gift Code Copied'**
  String get giftRedeemHistoryCodeCopied;

  /// No description provided for @comment_gift_redeem_filter_bottom_sheet.
  ///
  /// In en, this message translates to:
  /// **'==== Gift Redeem Filter Bottom Sheet ===='**
  String get comment_gift_redeem_filter_bottom_sheet;

  /// No description provided for @giftRedeemFilterCode.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get giftRedeemFilterCode;

  /// No description provided for @giftRedeemFilterButton.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get giftRedeemFilterButton;

  /// No description provided for @giftRedeemFilterReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get giftRedeemFilterReset;

  /// No description provided for @comment_drawer_section.
  ///
  /// In en, this message translates to:
  /// **'==== Drawer Section ===='**
  String get comment_drawer_section;

  /// No description provided for @drawerDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get drawerDashboard;

  /// No description provided for @drawerMyWallets.
  ///
  /// In en, this message translates to:
  /// **'My Wallets'**
  String get drawerMyWallets;

  /// No description provided for @drawerAddMoney.
  ///
  /// In en, this message translates to:
  /// **'Add Money'**
  String get drawerAddMoney;

  /// No description provided for @drawerCashOut.
  ///
  /// In en, this message translates to:
  /// **'Cash Out'**
  String get drawerCashOut;

  /// No description provided for @drawerBillPayments.
  ///
  /// In en, this message translates to:
  /// **'Bill Payments'**
  String get drawerBillPayments;

  /// No description provided for @drawerVirtualCards.
  ///
  /// In en, this message translates to:
  /// **'Virtual Cards'**
  String get drawerVirtualCards;

  /// No description provided for @drawerPaymentLinks.
  ///
  /// In en, this message translates to:
  /// **'Payment Links'**
  String get drawerPaymentLinks;

  /// No description provided for @drawerMakePayment.
  ///
  /// In en, this message translates to:
  /// **'Make Payment'**
  String get drawerMakePayment;

  /// No description provided for @drawerTransfer.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get drawerTransfer;

  /// No description provided for @drawerWithdraw.
  ///
  /// In en, this message translates to:
  /// **'Withdraw'**
  String get drawerWithdraw;

  /// No description provided for @drawerExchange.
  ///
  /// In en, this message translates to:
  /// **'Exchange'**
  String get drawerExchange;

  /// No description provided for @drawerInviting.
  ///
  /// In en, this message translates to:
  /// **'Inviting'**
  String get drawerInviting;

  /// No description provided for @drawerGiftCard.
  ///
  /// In en, this message translates to:
  /// **'Gift Card'**
  String get drawerGiftCard;

  /// No description provided for @drawerP2pTrading.
  ///
  /// In en, this message translates to:
  /// **'P2P Trading'**
  String get drawerP2pTrading;

  /// No description provided for @drawerKycVerification.
  ///
  /// In en, this message translates to:
  /// **'Please verify your KYC!'**
  String get drawerKycVerification;

  /// No description provided for @comment_end_drawer_section.
  ///
  /// In en, this message translates to:
  /// **'==== End Drawer Section ===='**
  String get comment_end_drawer_section;

  /// No description provided for @endDrawerProfileSettings.
  ///
  /// In en, this message translates to:
  /// **'Profile Settings'**
  String get endDrawerProfileSettings;

  /// No description provided for @endDrawerChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get endDrawerChangePassword;

  /// No description provided for @endDrawerAllNotification.
  ///
  /// In en, this message translates to:
  /// **'All Notification'**
  String get endDrawerAllNotification;

  /// No description provided for @endDrawerHelpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get endDrawerHelpSupport;

  /// No description provided for @endDrawerLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get endDrawerLanguage;

  /// No description provided for @endDrawerBiometric.
  ///
  /// In en, this message translates to:
  /// **'Biometric'**
  String get endDrawerBiometric;

  /// No description provided for @endDrawerSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get endDrawerSignOut;

  /// No description provided for @endDrawerLanguageNotFound.
  ///
  /// In en, this message translates to:
  /// **'Language not found'**
  String get endDrawerLanguageNotFound;

  /// No description provided for @endDrawerChooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose Language'**
  String get endDrawerChooseLanguage;

  /// No description provided for @comment_recent_transaction_details.
  ///
  /// In en, this message translates to:
  /// **'==== Recent Transaction Details ===='**
  String get comment_recent_transaction_details;

  /// No description provided for @transactionDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Transaction Details'**
  String get transactionDetailsTitle;

  /// No description provided for @transactionDetailsWallet.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get transactionDetailsWallet;

  /// No description provided for @transactionDetailsCharge.
  ///
  /// In en, this message translates to:
  /// **'Charge'**
  String get transactionDetailsCharge;

  /// No description provided for @transactionDetailsTransactionId.
  ///
  /// In en, this message translates to:
  /// **'Transaction ID'**
  String get transactionDetailsTransactionId;

  /// No description provided for @transactionDetailsMethod.
  ///
  /// In en, this message translates to:
  /// **'Method'**
  String get transactionDetailsMethod;

  /// No description provided for @transactionDetailsTotalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get transactionDetailsTotalAmount;

  /// No description provided for @transactionDetailsStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get transactionDetailsStatus;

  /// No description provided for @transactionDetailsDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get transactionDetailsDescription;

  /// No description provided for @transactionStatusSuccess.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get transactionStatusSuccess;

  /// No description provided for @transactionStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get transactionStatusPending;

  /// No description provided for @transactionStatusFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get transactionStatusFailed;

  /// No description provided for @comment_wallet_details.
  ///
  /// In en, this message translates to:
  /// **'==== Wallet Details ===='**
  String get comment_wallet_details;

  /// No description provided for @walletDetailsHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get walletDetailsHistory;

  /// No description provided for @walletDetailsAvailableBalance.
  ///
  /// In en, this message translates to:
  /// **'AVAILABLE BALANCE'**
  String get walletDetailsAvailableBalance;

  /// No description provided for @walletDetailsTopUp.
  ///
  /// In en, this message translates to:
  /// **'Top Up'**
  String get walletDetailsTopUp;

  /// No description provided for @walletDetailsWithdraw.
  ///
  /// In en, this message translates to:
  /// **'Withdraw'**
  String get walletDetailsWithdraw;

  /// No description provided for @walletDetailsUserDepositNotEnabled.
  ///
  /// In en, this message translates to:
  /// **'User Deposit Not Enabled'**
  String get walletDetailsUserDepositNotEnabled;

  /// No description provided for @walletDetailsUserWithdrawNotEnabled.
  ///
  /// In en, this message translates to:
  /// **'User Withdraw Not Enabled'**
  String get walletDetailsUserWithdrawNotEnabled;

  /// No description provided for @walletDetailsWalletsNotFound.
  ///
  /// In en, this message translates to:
  /// **'Wallets Not Found'**
  String get walletDetailsWalletsNotFound;

  /// No description provided for @comment_action_button_section.
  ///
  /// In en, this message translates to:
  /// **'==== Action Button Section ===='**
  String get comment_action_button_section;

  /// No description provided for @actionButtonTransfer.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get actionButtonTransfer;

  /// No description provided for @actionButtonWithdraw.
  ///
  /// In en, this message translates to:
  /// **'Withdraw'**
  String get actionButtonWithdraw;

  /// No description provided for @actionButtonPayment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get actionButtonPayment;

  /// No description provided for @actionButtonExchange.
  ///
  /// In en, this message translates to:
  /// **'Exchange'**
  String get actionButtonExchange;

  /// No description provided for @actionButtonUserTransferNotEnabled.
  ///
  /// In en, this message translates to:
  /// **'User Transfer Not Enabled'**
  String get actionButtonUserTransferNotEnabled;

  /// No description provided for @actionButtonUserWithdrawNotEnabled.
  ///
  /// In en, this message translates to:
  /// **'User Withdraw Not Enabled'**
  String get actionButtonUserWithdrawNotEnabled;

  /// No description provided for @actionButtonUserPaymentNotEnabled.
  ///
  /// In en, this message translates to:
  /// **'User Payment Not Enabled'**
  String get actionButtonUserPaymentNotEnabled;

  /// No description provided for @actionButtonUserExchangeNotEnabled.
  ///
  /// In en, this message translates to:
  /// **'User Exchange Not Enabled'**
  String get actionButtonUserExchangeNotEnabled;

  /// No description provided for @comment_my_wallet_section.
  ///
  /// In en, this message translates to:
  /// **'==== My Wallet Section ===='**
  String get comment_my_wallet_section;

  /// No description provided for @myWalletSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'My Wallets'**
  String get myWalletSectionTitle;

  /// No description provided for @myWalletTopUp.
  ///
  /// In en, this message translates to:
  /// **'Top Up'**
  String get myWalletTopUp;

  /// No description provided for @myWalletWithdraw.
  ///
  /// In en, this message translates to:
  /// **'Withdraw'**
  String get myWalletWithdraw;

  /// No description provided for @myWalletUserDepositNotEnabled.
  ///
  /// In en, this message translates to:
  /// **'User Deposit Not Enabled'**
  String get myWalletUserDepositNotEnabled;

  /// No description provided for @myWalletUserWithdrawNotEnabled.
  ///
  /// In en, this message translates to:
  /// **'User Withdraw Not Enabled'**
  String get myWalletUserWithdrawNotEnabled;

  /// No description provided for @comment_other_services_section.
  ///
  /// In en, this message translates to:
  /// **'==== Other Services Section ===='**
  String get comment_other_services_section;

  /// No description provided for @otherServicesTitle.
  ///
  /// In en, this message translates to:
  /// **'Other Services'**
  String get otherServicesTitle;

  /// No description provided for @otherServicesQrCode.
  ///
  /// In en, this message translates to:
  /// **'QR Code'**
  String get otherServicesQrCode;

  /// No description provided for @otherServicesAddMoney.
  ///
  /// In en, this message translates to:
  /// **'Add Money'**
  String get otherServicesAddMoney;

  /// No description provided for @otherServicesCashOut.
  ///
  /// In en, this message translates to:
  /// **'Cash Out'**
  String get otherServicesCashOut;

  /// No description provided for @otherServicesMakePayment.
  ///
  /// In en, this message translates to:
  /// **'Make Payment'**
  String get otherServicesMakePayment;

  /// No description provided for @otherServicesTransactions.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get otherServicesTransactions;

  /// No description provided for @otherServicesInvoice.
  ///
  /// In en, this message translates to:
  /// **'Invoice'**
  String get otherServicesInvoice;

  /// No description provided for @otherServicesRequestMoney.
  ///
  /// In en, this message translates to:
  /// **'Request Money'**
  String get otherServicesRequestMoney;

  /// No description provided for @otherServicesGift.
  ///
  /// In en, this message translates to:
  /// **'Gift'**
  String get otherServicesGift;

  /// No description provided for @otherServicesWallets.
  ///
  /// In en, this message translates to:
  /// **'Wallets'**
  String get otherServicesWallets;

  /// No description provided for @otherServicesWithdraw.
  ///
  /// In en, this message translates to:
  /// **'Withdraw'**
  String get otherServicesWithdraw;

  /// No description provided for @otherServicesExchange.
  ///
  /// In en, this message translates to:
  /// **'Exchange'**
  String get otherServicesExchange;

  /// No description provided for @otherServicesTransfer.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get otherServicesTransfer;

  /// No description provided for @otherServicesInvite.
  ///
  /// In en, this message translates to:
  /// **'Invite'**
  String get otherServicesInvite;

  /// No description provided for @otherServicesBillPayment.
  ///
  /// In en, this message translates to:
  /// **'Bill Payment'**
  String get otherServicesBillPayment;

  /// No description provided for @otherServicesVirtualCard.
  ///
  /// In en, this message translates to:
  /// **'Virtual Cards'**
  String get otherServicesVirtualCard;

  /// No description provided for @otherServicesGiftCards.
  ///
  /// In en, this message translates to:
  /// **'Gift Cards'**
  String get otherServicesGiftCards;

  /// No description provided for @otherServicesP2pTrading.
  ///
  /// In en, this message translates to:
  /// **'P2P Trading'**
  String get otherServicesP2pTrading;

  /// No description provided for @otherServicesPaymentLinks.
  ///
  /// In en, this message translates to:
  /// **'Payment Links'**
  String get otherServicesPaymentLinks;

  /// No description provided for @otherServicesKycVerification.
  ///
  /// In en, this message translates to:
  /// **'Please verify your KYC!'**
  String get otherServicesKycVerification;

  /// No description provided for @otherServicesUserGiftNotEnabled.
  ///
  /// In en, this message translates to:
  /// **'User Gift Not Enabled'**
  String get otherServicesUserGiftNotEnabled;

  /// No description provided for @otherServicesUserDepositNotEnabled.
  ///
  /// In en, this message translates to:
  /// **'User Deposit Not Enabled'**
  String get otherServicesUserDepositNotEnabled;

  /// No description provided for @otherServicesUserCashOutNotEnabled.
  ///
  /// In en, this message translates to:
  /// **'User Cash Out Not Enabled'**
  String get otherServicesUserCashOutNotEnabled;

  /// No description provided for @otherServicesUserPaymentNotEnabled.
  ///
  /// In en, this message translates to:
  /// **'User Payment Not Enabled'**
  String get otherServicesUserPaymentNotEnabled;

  /// No description provided for @otherServicesUserRequestMoneyNotEnabled.
  ///
  /// In en, this message translates to:
  /// **'User Request Money Not Enabled'**
  String get otherServicesUserRequestMoneyNotEnabled;

  /// No description provided for @otherServicesUserInvoiceNotEnabled.
  ///
  /// In en, this message translates to:
  /// **'User Invoice Money Not Enabled'**
  String get otherServicesUserInvoiceNotEnabled;

  /// No description provided for @comment_recent_transactions_section.
  ///
  /// In en, this message translates to:
  /// **'==== Recent Transactions Section ===='**
  String get comment_recent_transactions_section;

  /// No description provided for @recentTransactionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get recentTransactionsTitle;

  /// No description provided for @comment_section_header.
  ///
  /// In en, this message translates to:
  /// **'==== Section Header ===='**
  String get comment_section_header;

  /// No description provided for @sectionHeaderSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get sectionHeaderSeeAll;

  /// No description provided for @comment_sign_up_bonus_popup.
  ///
  /// In en, this message translates to:
  /// **'==== Sign Up Bonus Popup ===='**
  String get comment_sign_up_bonus_popup;

  /// No description provided for @signUpBonusCongratulations.
  ///
  /// In en, this message translates to:
  /// **'Congratulations!'**
  String get signUpBonusCongratulations;

  /// No description provided for @signUpBonusReceived.
  ///
  /// In en, this message translates to:
  /// **'You have received bonus'**
  String get signUpBonusReceived;

  /// No description provided for @comment_user_profile_section.
  ///
  /// In en, this message translates to:
  /// **'==== User Profile Section ===='**
  String get comment_user_profile_section;

  /// No description provided for @userProfileHello.
  ///
  /// In en, this message translates to:
  /// **'Hello, 👋'**
  String get userProfileHello;

  /// No description provided for @userProfileUid.
  ///
  /// In en, this message translates to:
  /// **'UID:'**
  String get userProfileUid;

  /// No description provided for @userProfileCopied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get userProfileCopied;

  /// No description provided for @comment_invoice_screen.
  ///
  /// In en, this message translates to:
  /// **'==== Invoice Screen ===='**
  String get comment_invoice_screen;

  /// No description provided for @invoiceTitle.
  ///
  /// In en, this message translates to:
  /// **'Invoice'**
  String get invoiceTitle;

  /// No description provided for @invoiceCreateInvoice.
  ///
  /// In en, this message translates to:
  /// **'Create Invoice'**
  String get invoiceCreateInvoice;

  /// No description provided for @invoiceAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount:'**
  String get invoiceAmount;

  /// No description provided for @invoiceCharge.
  ///
  /// In en, this message translates to:
  /// **'Charge:'**
  String get invoiceCharge;

  /// No description provided for @invoiceStatus.
  ///
  /// In en, this message translates to:
  /// **'Status: '**
  String get invoiceStatus;

  /// No description provided for @invoicePublished.
  ///
  /// In en, this message translates to:
  /// **'Published'**
  String get invoicePublished;

  /// No description provided for @invoiceDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get invoiceDraft;

  /// No description provided for @invoiceView.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get invoiceView;

  /// No description provided for @invoicePaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get invoicePaid;

  /// No description provided for @invoiceUnpaid.
  ///
  /// In en, this message translates to:
  /// **'Unpaid'**
  String get invoiceUnpaid;

  /// No description provided for @comment_update_invoice.
  ///
  /// In en, this message translates to:
  /// **'==== Update Invoice ===='**
  String get comment_update_invoice;

  /// No description provided for @updateInvoiceTitle.
  ///
  /// In en, this message translates to:
  /// **'Update Invoice'**
  String get updateInvoiceTitle;

  /// No description provided for @updateInvoiceItems.
  ///
  /// In en, this message translates to:
  /// **'Invoice Items'**
  String get updateInvoiceItems;

  /// No description provided for @updateInvoiceAddItem.
  ///
  /// In en, this message translates to:
  /// **'Add Item'**
  String get updateInvoiceAddItem;

  /// No description provided for @updateInvoiceButton.
  ///
  /// In en, this message translates to:
  /// **'Update Invoice'**
  String get updateInvoiceButton;

  /// No description provided for @comment_update_invoice_add_item.
  ///
  /// In en, this message translates to:
  /// **'==== Update Invoice Add Item ===='**
  String get comment_update_invoice_add_item;

  /// No description provided for @updateInvoiceItemName.
  ///
  /// In en, this message translates to:
  /// **'Item Name'**
  String get updateInvoiceItemName;

  /// No description provided for @updateInvoiceQuantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get updateInvoiceQuantity;

  /// No description provided for @updateInvoiceUnitPrice.
  ///
  /// In en, this message translates to:
  /// **'Unit Price'**
  String get updateInvoiceUnitPrice;

  /// No description provided for @updateInvoiceSubTotal.
  ///
  /// In en, this message translates to:
  /// **'Sub Total'**
  String get updateInvoiceSubTotal;

  /// No description provided for @comment_update_invoice_information.
  ///
  /// In en, this message translates to:
  /// **'==== Update Invoice Information ===='**
  String get comment_update_invoice_information;

  /// No description provided for @updateInvoiceInformationTitle.
  ///
  /// In en, this message translates to:
  /// **'Invoice Information'**
  String get updateInvoiceInformationTitle;

  /// No description provided for @updateInvoiceTo.
  ///
  /// In en, this message translates to:
  /// **'Invoice To'**
  String get updateInvoiceTo;

  /// No description provided for @updateInvoiceEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get updateInvoiceEmailAddress;

  /// No description provided for @updateInvoiceAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get updateInvoiceAddress;

  /// No description provided for @updateInvoiceWallet.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get updateInvoiceWallet;

  /// No description provided for @updateInvoiceStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get updateInvoiceStatus;

  /// No description provided for @updateInvoiceIssueDate.
  ///
  /// In en, this message translates to:
  /// **'Issue Date'**
  String get updateInvoiceIssueDate;

  /// No description provided for @updateInvoicePaymentStatus.
  ///
  /// In en, this message translates to:
  /// **'Payment Status'**
  String get updateInvoicePaymentStatus;

  /// No description provided for @updateInvoiceSelectWallet.
  ///
  /// In en, this message translates to:
  /// **'Select Wallet'**
  String get updateInvoiceSelectWallet;

  /// No description provided for @updateInvoiceSelectStatus.
  ///
  /// In en, this message translates to:
  /// **'Select Status'**
  String get updateInvoiceSelectStatus;

  /// No description provided for @updateInvoiceSelectPaymentStatus.
  ///
  /// In en, this message translates to:
  /// **'Select Payment Status'**
  String get updateInvoiceSelectPaymentStatus;

  /// No description provided for @updateInvoiceWalletNotFound.
  ///
  /// In en, this message translates to:
  /// **'Wallet not found'**
  String get updateInvoiceWalletNotFound;

  /// No description provided for @updateInvoiceStatusNotFound.
  ///
  /// In en, this message translates to:
  /// **'Status not found'**
  String get updateInvoiceStatusNotFound;

  /// No description provided for @updateInvoicePaymentStatusNotFound.
  ///
  /// In en, this message translates to:
  /// **'Payment status not found'**
  String get updateInvoicePaymentStatusNotFound;

  /// No description provided for @comment_invoice_status_options.
  ///
  /// In en, this message translates to:
  /// **'==== Invoice Status Options ===='**
  String get comment_invoice_status_options;

  /// No description provided for @invoiceStatusDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get invoiceStatusDraft;

  /// No description provided for @invoiceStatusPublished.
  ///
  /// In en, this message translates to:
  /// **'Published'**
  String get invoiceStatusPublished;

  /// No description provided for @invoiceStatusPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get invoiceStatusPaid;

  /// No description provided for @invoiceStatusUnpaid.
  ///
  /// In en, this message translates to:
  /// **'Unpaid'**
  String get invoiceStatusUnpaid;

  /// No description provided for @comment_invoice_details.
  ///
  /// In en, this message translates to:
  /// **'==== Invoice Details ===='**
  String get comment_invoice_details;

  /// No description provided for @invoiceDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Invoice'**
  String get invoiceDetailsTitle;

  /// No description provided for @invoiceDetailsReference.
  ///
  /// In en, this message translates to:
  /// **'Ref:'**
  String get invoiceDetailsReference;

  /// No description provided for @invoiceDetailsIssued.
  ///
  /// In en, this message translates to:
  /// **'Issued:'**
  String get invoiceDetailsIssued;

  /// No description provided for @invoiceDetailsName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get invoiceDetailsName;

  /// No description provided for @invoiceDetailsEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get invoiceDetailsEmail;

  /// No description provided for @invoiceDetailsCharge.
  ///
  /// In en, this message translates to:
  /// **'Charge'**
  String get invoiceDetailsCharge;

  /// No description provided for @invoiceDetailsAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get invoiceDetailsAddress;

  /// No description provided for @invoiceDetailsTotalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get invoiceDetailsTotalAmount;

  /// No description provided for @invoiceDetailsStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get invoiceDetailsStatus;

  /// No description provided for @invoiceDetailsItemName.
  ///
  /// In en, this message translates to:
  /// **'Item Name'**
  String get invoiceDetailsItemName;

  /// No description provided for @invoiceDetailsQuantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get invoiceDetailsQuantity;

  /// No description provided for @invoiceDetailsUnitPrice.
  ///
  /// In en, this message translates to:
  /// **'Unit Price'**
  String get invoiceDetailsUnitPrice;

  /// No description provided for @invoiceDetailsSubTotal.
  ///
  /// In en, this message translates to:
  /// **'Sub Total'**
  String get invoiceDetailsSubTotal;

  /// No description provided for @invoiceDetailsPayNow.
  ///
  /// In en, this message translates to:
  /// **'Pay Now'**
  String get invoiceDetailsPayNow;

  /// No description provided for @invoiceDetailsPrintInvoice.
  ///
  /// In en, this message translates to:
  /// **'Print Invoice'**
  String get invoiceDetailsPrintInvoice;

  /// No description provided for @invoiceDetailsPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get invoiceDetailsPaid;

  /// No description provided for @invoiceDetailsUnpaid.
  ///
  /// In en, this message translates to:
  /// **'Unpaid'**
  String get invoiceDetailsUnpaid;

  /// No description provided for @comment_invoice_pdf.
  ///
  /// In en, this message translates to:
  /// **'==== Invoice PDF ===='**
  String get comment_invoice_pdf;

  /// No description provided for @invoicePdfReference.
  ///
  /// In en, this message translates to:
  /// **'Ref:'**
  String get invoicePdfReference;

  /// No description provided for @invoicePdfIssued.
  ///
  /// In en, this message translates to:
  /// **'Issued:'**
  String get invoicePdfIssued;

  /// No description provided for @invoicePdfPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get invoicePdfPaid;

  /// No description provided for @invoicePdfUnpaid.
  ///
  /// In en, this message translates to:
  /// **'Unpaid'**
  String get invoicePdfUnpaid;

  /// No description provided for @invoicePdfTotalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total Amount:'**
  String get invoicePdfTotalAmount;

  /// No description provided for @invoicePdfAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount:'**
  String get invoicePdfAmount;

  /// No description provided for @invoicePdfCharge.
  ///
  /// In en, this message translates to:
  /// **'Charge:'**
  String get invoicePdfCharge;

  /// No description provided for @invoicePdfItemName.
  ///
  /// In en, this message translates to:
  /// **'Item Name'**
  String get invoicePdfItemName;

  /// No description provided for @invoicePdfQuantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get invoicePdfQuantity;

  /// No description provided for @invoicePdfUnitPrice.
  ///
  /// In en, this message translates to:
  /// **'Unit Price'**
  String get invoicePdfUnitPrice;

  /// No description provided for @invoicePdfSubtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get invoicePdfSubtotal;

  /// No description provided for @invoicePdfSubtotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Subtotal: '**
  String get invoicePdfSubtotalLabel;

  /// No description provided for @invoicePdfChargeLabel.
  ///
  /// In en, this message translates to:
  /// **'Charge: '**
  String get invoicePdfChargeLabel;

  /// No description provided for @invoicePdfTotalAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Total Amount: '**
  String get invoicePdfTotalAmountLabel;

  /// No description provided for @invoicePdfThanks.
  ///
  /// In en, this message translates to:
  /// **'Thanks for the purchase.'**
  String get invoicePdfThanks;

  /// No description provided for @comment_create_invoice.
  ///
  /// In en, this message translates to:
  /// **'==== Create Invoice ===='**
  String get comment_create_invoice;

  /// No description provided for @createInvoiceTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Invoice'**
  String get createInvoiceTitle;

  /// No description provided for @createInvoiceItems.
  ///
  /// In en, this message translates to:
  /// **'Invoice Items'**
  String get createInvoiceItems;

  /// No description provided for @createInvoiceAddItem.
  ///
  /// In en, this message translates to:
  /// **'Add Item'**
  String get createInvoiceAddItem;

  /// No description provided for @createInvoiceButton.
  ///
  /// In en, this message translates to:
  /// **'Create Invoice'**
  String get createInvoiceButton;

  /// No description provided for @createInvoiceStatusDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get createInvoiceStatusDraft;

  /// No description provided for @comment_create_invoice_add_item_section.
  ///
  /// In en, this message translates to:
  /// **'==== Create Invoice Add Item Section ===='**
  String get comment_create_invoice_add_item_section;

  /// No description provided for @createInvoiceAddItemSectionItemName.
  ///
  /// In en, this message translates to:
  /// **'Item Name'**
  String get createInvoiceAddItemSectionItemName;

  /// No description provided for @createInvoiceAddItemSectionQuantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get createInvoiceAddItemSectionQuantity;

  /// No description provided for @createInvoiceAddItemSectionUnitPrice.
  ///
  /// In en, this message translates to:
  /// **'Unit Price'**
  String get createInvoiceAddItemSectionUnitPrice;

  /// No description provided for @createInvoiceAddItemSectionSubTotal.
  ///
  /// In en, this message translates to:
  /// **'Sub Total'**
  String get createInvoiceAddItemSectionSubTotal;

  /// No description provided for @comment_create_invoice_information_section.
  ///
  /// In en, this message translates to:
  /// **'==== Create Invoice Information Section ===='**
  String get comment_create_invoice_information_section;

  /// No description provided for @createInvoiceInformationSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Invoice Information'**
  String get createInvoiceInformationSectionTitle;

  /// No description provided for @createInvoiceInformationSectionInvoiceTo.
  ///
  /// In en, this message translates to:
  /// **'Invoice To'**
  String get createInvoiceInformationSectionInvoiceTo;

  /// No description provided for @createInvoiceInformationSectionEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get createInvoiceInformationSectionEmailAddress;

  /// No description provided for @createInvoiceInformationSectionAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get createInvoiceInformationSectionAddress;

  /// No description provided for @createInvoiceInformationSectionWallet.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get createInvoiceInformationSectionWallet;

  /// No description provided for @createInvoiceInformationSectionStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get createInvoiceInformationSectionStatus;

  /// No description provided for @createInvoiceInformationSectionIssueDate.
  ///
  /// In en, this message translates to:
  /// **'Issue Date'**
  String get createInvoiceInformationSectionIssueDate;

  /// No description provided for @createInvoiceInformationSectionWalletNotFound.
  ///
  /// In en, this message translates to:
  /// **'Wallets Not Found'**
  String get createInvoiceInformationSectionWalletNotFound;

  /// No description provided for @createInvoiceInformationSectionWalletHint.
  ///
  /// In en, this message translates to:
  /// **'Select Wallet'**
  String get createInvoiceInformationSectionWalletHint;

  /// No description provided for @createInvoiceInformationSectionStatusTitle.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get createInvoiceInformationSectionStatusTitle;

  /// No description provided for @createInvoiceInformationSectionStatusNotFound.
  ///
  /// In en, this message translates to:
  /// **'Status not found'**
  String get createInvoiceInformationSectionStatusNotFound;

  /// No description provided for @createInvoiceInformationSectionStatusDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get createInvoiceInformationSectionStatusDraft;

  /// No description provided for @createInvoiceInformationSectionStatusPublished.
  ///
  /// In en, this message translates to:
  /// **'Published'**
  String get createInvoiceInformationSectionStatusPublished;

  /// No description provided for @comment_make_payment_screen.
  ///
  /// In en, this message translates to:
  /// **'==== Make Payment Screen ===='**
  String get comment_make_payment_screen;

  /// No description provided for @makePaymentScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Make Payment'**
  String get makePaymentScreenTitle;

  /// No description provided for @makePaymentScreenWalletsNotFound.
  ///
  /// In en, this message translates to:
  /// **'Wallets Not Found'**
  String get makePaymentScreenWalletsNotFound;

  /// No description provided for @makePaymentScreenBalance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get makePaymentScreenBalance;

  /// No description provided for @makePaymentScreenHistory.
  ///
  /// In en, this message translates to:
  /// **'Make Payment History'**
  String get makePaymentScreenHistory;

  /// No description provided for @comment_make_payment_amount_step_section.
  ///
  /// In en, this message translates to:
  /// **'==== Make Payment Amount Step Section ===='**
  String get comment_make_payment_amount_step_section;

  /// No description provided for @makePaymentAmountStepSectionMerchantId.
  ///
  /// In en, this message translates to:
  /// **'Merchant ID'**
  String get makePaymentAmountStepSectionMerchantId;

  /// No description provided for @makePaymentAmountStepSectionAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get makePaymentAmountStepSectionAmount;

  /// No description provided for @makePaymentAmountStepSectionMinLimit.
  ///
  /// In en, this message translates to:
  /// **'Minimum'**
  String get makePaymentAmountStepSectionMinLimit;

  /// No description provided for @makePaymentAmountStepSectionMaxLimit.
  ///
  /// In en, this message translates to:
  /// **'and Maximum'**
  String get makePaymentAmountStepSectionMaxLimit;

  /// No description provided for @makePaymentAmountStepSectionMakePaymentButton.
  ///
  /// In en, this message translates to:
  /// **'Make Payment'**
  String get makePaymentAmountStepSectionMakePaymentButton;

  /// No description provided for @makePaymentAmountStepSectionSavedMerchantsButton.
  ///
  /// In en, this message translates to:
  /// **'Saved Merchants'**
  String get makePaymentAmountStepSectionSavedMerchantsButton;

  /// No description provided for @makePaymentAmountStepSectionInvalidQrCodeDigits.
  ///
  /// In en, this message translates to:
  /// **'Invalid QR code. Merchant MID must be digits only.'**
  String get makePaymentAmountStepSectionInvalidQrCodeDigits;

  /// No description provided for @makePaymentAmountStepSectionInvalidQrCodePrefix.
  ///
  /// In en, this message translates to:
  /// **'Invalid QR code. MID prefix not found.'**
  String get makePaymentAmountStepSectionInvalidQrCodePrefix;

  /// No description provided for @makePaymentAmountStepSectionMerchantsTitle.
  ///
  /// In en, this message translates to:
  /// **'Merchants'**
  String get makePaymentAmountStepSectionMerchantsTitle;

  /// No description provided for @makePaymentAmountStepSectionAddMerchant.
  ///
  /// In en, this message translates to:
  /// **'Add Merchant'**
  String get makePaymentAmountStepSectionAddMerchant;

  /// No description provided for @makePaymentAmountStepSectionMidLabel.
  ///
  /// In en, this message translates to:
  /// **'MID:'**
  String get makePaymentAmountStepSectionMidLabel;

  /// No description provided for @makePaymentAmountStepSectionDeleteConfirmationTitle.
  ///
  /// In en, this message translates to:
  /// **'Are you sure?'**
  String get makePaymentAmountStepSectionDeleteConfirmationTitle;

  /// No description provided for @makePaymentAmountStepSectionDeleteConfirmationMessage.
  ///
  /// In en, this message translates to:
  /// **'You want to delete this merchant?'**
  String get makePaymentAmountStepSectionDeleteConfirmationMessage;

  /// No description provided for @makePaymentAmountStepSectionDeleteButton.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get makePaymentAmountStepSectionDeleteButton;

  /// No description provided for @makePaymentAmountStepSectionCancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get makePaymentAmountStepSectionCancelButton;

  /// No description provided for @comment_make_payment_review_step_section.
  ///
  /// In en, this message translates to:
  /// **'==== Make Payment Review Step Section ===='**
  String get comment_make_payment_review_step_section;

  /// No description provided for @makePaymentReviewStepSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Review Details'**
  String get makePaymentReviewStepSectionTitle;

  /// No description provided for @makePaymentReviewStepSectionAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get makePaymentReviewStepSectionAmount;

  /// No description provided for @makePaymentReviewStepSectionWallet.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get makePaymentReviewStepSectionWallet;

  /// No description provided for @makePaymentReviewStepSectionMerchantAccount.
  ///
  /// In en, this message translates to:
  /// **'Merchant Account'**
  String get makePaymentReviewStepSectionMerchantAccount;

  /// No description provided for @makePaymentReviewStepSectionCharge.
  ///
  /// In en, this message translates to:
  /// **'Charge'**
  String get makePaymentReviewStepSectionCharge;

  /// No description provided for @makePaymentReviewStepSectionTotalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get makePaymentReviewStepSectionTotalAmount;

  /// No description provided for @makePaymentReviewStepSectionBackButton.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get makePaymentReviewStepSectionBackButton;

  /// No description provided for @makePaymentReviewStepSectionConfirmButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get makePaymentReviewStepSectionConfirmButton;

  /// No description provided for @comment_make_payment_success_step_section.
  ///
  /// In en, this message translates to:
  /// **'==== Make Payment Success Step Section ===='**
  String get comment_make_payment_success_step_section;

  /// No description provided for @makePaymentSuccessStepSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment Success!'**
  String get makePaymentSuccessStepSectionTitle;

  /// No description provided for @makePaymentSuccessStepSectionAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get makePaymentSuccessStepSectionAmount;

  /// No description provided for @makePaymentSuccessStepSectionTransactionId.
  ///
  /// In en, this message translates to:
  /// **'Transection ID'**
  String get makePaymentSuccessStepSectionTransactionId;

  /// No description provided for @makePaymentSuccessStepSectionWalletName.
  ///
  /// In en, this message translates to:
  /// **'Wallet Name'**
  String get makePaymentSuccessStepSectionWalletName;

  /// No description provided for @makePaymentSuccessStepSectionPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get makePaymentSuccessStepSectionPaymentMethod;

  /// No description provided for @makePaymentSuccessStepSectionCharge.
  ///
  /// In en, this message translates to:
  /// **'Charge'**
  String get makePaymentSuccessStepSectionCharge;

  /// No description provided for @makePaymentSuccessStepSectionType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get makePaymentSuccessStepSectionType;

  /// No description provided for @makePaymentSuccessStepSectionFinalAmount.
  ///
  /// In en, this message translates to:
  /// **'Final Amount'**
  String get makePaymentSuccessStepSectionFinalAmount;

  /// No description provided for @makePaymentSuccessStepSectionPaymentAgainButton.
  ///
  /// In en, this message translates to:
  /// **'Payment Again'**
  String get makePaymentSuccessStepSectionPaymentAgainButton;

  /// No description provided for @makePaymentSuccessStepSectionBackHomeButton.
  ///
  /// In en, this message translates to:
  /// **'Back Home'**
  String get makePaymentSuccessStepSectionBackHomeButton;

  /// No description provided for @comment_make_payment_history_screen.
  ///
  /// In en, this message translates to:
  /// **'==== Make Payment History Screen ===='**
  String get comment_make_payment_history_screen;

  /// No description provided for @makePaymentHistoryScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment History'**
  String get makePaymentHistoryScreenTitle;

  /// No description provided for @comment_make_payment_filter_bottom_sheet.
  ///
  /// In en, this message translates to:
  /// **'==== Make Payment Filter Bottom Sheet ===='**
  String get comment_make_payment_filter_bottom_sheet;

  /// No description provided for @makePaymentFilterTransactionId.
  ///
  /// In en, this message translates to:
  /// **'Transactions ID'**
  String get makePaymentFilterTransactionId;

  /// No description provided for @makePaymentFilterStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get makePaymentFilterStatus;

  /// No description provided for @makePaymentFilterApplyButton.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get makePaymentFilterApplyButton;

  /// No description provided for @makePaymentFilterResetButton.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get makePaymentFilterResetButton;

  /// No description provided for @comment_qr_code_screen.
  ///
  /// In en, this message translates to:
  /// **'==== QR Code Screen ===='**
  String get comment_qr_code_screen;

  /// No description provided for @qrCodeScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'My QR Code'**
  String get qrCodeScreenTitle;

  /// No description provided for @qrCodeScreenDownloadButton.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get qrCodeScreenDownloadButton;

  /// No description provided for @qrCodeScreenPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Permission is required. Please allow it in settings.'**
  String get qrCodeScreenPermissionRequired;

  /// No description provided for @qrCodeScreenDownloadSuccess.
  ///
  /// In en, this message translates to:
  /// **'Downloaded successfully!'**
  String get qrCodeScreenDownloadSuccess;

  /// No description provided for @comment_referral_screen.
  ///
  /// In en, this message translates to:
  /// **'==== Referral Screen ===='**
  String get comment_referral_screen;

  /// No description provided for @referralScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Referral'**
  String get referralScreenTitle;

  /// No description provided for @referralScreenEarnAmount.
  ///
  /// In en, this message translates to:
  /// **'Earn'**
  String get referralScreenEarnAmount;

  /// No description provided for @referralScreenAfterInviting.
  ///
  /// In en, this message translates to:
  /// **'After Inviting'**
  String get referralScreenAfterInviting;

  /// No description provided for @referralScreenOneMember.
  ///
  /// In en, this message translates to:
  /// **'One Member'**
  String get referralScreenOneMember;

  /// No description provided for @referralScreenNoCode.
  ///
  /// In en, this message translates to:
  /// **'No Code'**
  String get referralScreenNoCode;

  /// No description provided for @referralScreenCodeCopied.
  ///
  /// In en, this message translates to:
  /// **'Code Copied'**
  String get referralScreenCodeCopied;

  /// No description provided for @referralScreenShareButton.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get referralScreenShareButton;

  /// No description provided for @referralScreenReferredFriends.
  ///
  /// In en, this message translates to:
  /// **'Referred Friends'**
  String get referralScreenReferredFriends;

  /// No description provided for @comment_referred_friends_screen.
  ///
  /// In en, this message translates to:
  /// **'==== Referred Friends Screen ===='**
  String get comment_referred_friends_screen;

  /// No description provided for @referredFriendsScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Referred Friends'**
  String get referredFriendsScreenTitle;

  /// No description provided for @referredFriendsScreenReferralTreeButton.
  ///
  /// In en, this message translates to:
  /// **'Referral Tree'**
  String get referredFriendsScreenReferralTreeButton;

  /// No description provided for @comment_referred_friend_list.
  ///
  /// In en, this message translates to:
  /// **'==== Referred Friend List ===='**
  String get comment_referred_friend_list;

  /// No description provided for @referredFriendListJoinedOn.
  ///
  /// In en, this message translates to:
  /// **'Joined on'**
  String get referredFriendListJoinedOn;

  /// No description provided for @referredFriendListActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get referredFriendListActive;

  /// No description provided for @referredFriendListInactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get referredFriendListInactive;

  /// No description provided for @comment_referral_tree_screen.
  ///
  /// In en, this message translates to:
  /// **'==== Referral Tree Screen ===='**
  String get comment_referral_tree_screen;

  /// No description provided for @referralTreeScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Referral Tree'**
  String get referralTreeScreenTitle;

  /// No description provided for @comment_request_money_screen.
  ///
  /// In en, this message translates to:
  /// **'==== Request Money Screen ===='**
  String get comment_request_money_screen;

  /// No description provided for @requestMoneyScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Request Money'**
  String get requestMoneyScreenTitle;

  /// No description provided for @comment_request_money_amount_step_section.
  ///
  /// In en, this message translates to:
  /// **'==== Request Money Amount Step Section ===='**
  String get comment_request_money_amount_step_section;

  /// No description provided for @requestMoneyAmountStepSectionRecipientId.
  ///
  /// In en, this message translates to:
  /// **'Recipient ID'**
  String get requestMoneyAmountStepSectionRecipientId;

  /// No description provided for @requestMoneyAmountStepSectionRequestAmount.
  ///
  /// In en, this message translates to:
  /// **'Request Amount'**
  String get requestMoneyAmountStepSectionRequestAmount;

  /// No description provided for @requestMoneyAmountStepSectionMin.
  ///
  /// In en, this message translates to:
  /// **'Minimum'**
  String get requestMoneyAmountStepSectionMin;

  /// No description provided for @requestMoneyAmountStepSectionMax.
  ///
  /// In en, this message translates to:
  /// **'and Maximum'**
  String get requestMoneyAmountStepSectionMax;

  /// No description provided for @requestMoneyAmountStepSectionNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get requestMoneyAmountStepSectionNote;

  /// No description provided for @requestMoneyAmountStepSectionRequestMoneyButton.
  ///
  /// In en, this message translates to:
  /// **'Request Money'**
  String get requestMoneyAmountStepSectionRequestMoneyButton;

  /// No description provided for @requestMoneyAmountStepSectionInvalidQrCodeDigits.
  ///
  /// In en, this message translates to:
  /// **'Invalid QR code. Recipient UID must be digits only.'**
  String get requestMoneyAmountStepSectionInvalidQrCodeDigits;

  /// No description provided for @requestMoneyAmountStepSectionInvalidQrCodePrefix.
  ///
  /// In en, this message translates to:
  /// **'Invalid QR code. UID prefix not found.'**
  String get requestMoneyAmountStepSectionInvalidQrCodePrefix;

  /// No description provided for @comment_request_money_header_section.
  ///
  /// In en, this message translates to:
  /// **'==== Request Money Header Section ===='**
  String get comment_request_money_header_section;

  /// No description provided for @requestMoneyHeaderSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Request Money'**
  String get requestMoneyHeaderSectionTitle;

  /// No description provided for @requestMoneyHeaderSectionRequestMoneyButton.
  ///
  /// In en, this message translates to:
  /// **'Request Money'**
  String get requestMoneyHeaderSectionRequestMoneyButton;

  /// No description provided for @requestMoneyHeaderSectionReceivedRequestButton.
  ///
  /// In en, this message translates to:
  /// **'Received Request'**
  String get requestMoneyHeaderSectionReceivedRequestButton;

  /// No description provided for @requestMoneyHeaderSectionHistory.
  ///
  /// In en, this message translates to:
  /// **'Request Money History'**
  String get requestMoneyHeaderSectionHistory;

  /// No description provided for @comment_request_money_review_step_section.
  ///
  /// In en, this message translates to:
  /// **'==== Request Money Review Step Section ===='**
  String get comment_request_money_review_step_section;

  /// No description provided for @requestMoneyReviewStepSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Review Details'**
  String get requestMoneyReviewStepSectionTitle;

  /// No description provided for @requestMoneyReviewStepSectionAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get requestMoneyReviewStepSectionAmount;

  /// No description provided for @requestMoneyReviewStepSectionWalletName.
  ///
  /// In en, this message translates to:
  /// **'Wallet Name'**
  String get requestMoneyReviewStepSectionWalletName;

  /// No description provided for @requestMoneyReviewStepSectionRecipientUid.
  ///
  /// In en, this message translates to:
  /// **'Recipient UID'**
  String get requestMoneyReviewStepSectionRecipientUid;

  /// No description provided for @requestMoneyReviewStepSectionBackButton.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get requestMoneyReviewStepSectionBackButton;

  /// No description provided for @requestMoneyReviewStepSectionConfirmButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get requestMoneyReviewStepSectionConfirmButton;

  /// No description provided for @comment_request_money_success_step_section.
  ///
  /// In en, this message translates to:
  /// **'==== Request Money Success Step Section ===='**
  String get comment_request_money_success_step_section;

  /// No description provided for @requestMoneySuccessStepSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Request Money Success!'**
  String get requestMoneySuccessStepSectionTitle;

  /// No description provided for @requestMoneySuccessStepSectionAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get requestMoneySuccessStepSectionAmount;

  /// No description provided for @requestMoneySuccessStepSectionRecipientName.
  ///
  /// In en, this message translates to:
  /// **'Recipient Name'**
  String get requestMoneySuccessStepSectionRecipientName;

  /// No description provided for @requestMoneySuccessStepSectionRequestWalletName.
  ///
  /// In en, this message translates to:
  /// **'Request Wallet Name'**
  String get requestMoneySuccessStepSectionRequestWalletName;

  /// No description provided for @requestMoneySuccessStepSectionCharge.
  ///
  /// In en, this message translates to:
  /// **'Charge'**
  String get requestMoneySuccessStepSectionCharge;

  /// No description provided for @requestMoneySuccessStepSectionFinalAmount.
  ///
  /// In en, this message translates to:
  /// **'Final Amount'**
  String get requestMoneySuccessStepSectionFinalAmount;

  /// No description provided for @requestMoneySuccessStepSectionStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get requestMoneySuccessStepSectionStatus;

  /// No description provided for @requestMoneySuccessStepSectionRequestAgainButton.
  ///
  /// In en, this message translates to:
  /// **'Request Again'**
  String get requestMoneySuccessStepSectionRequestAgainButton;

  /// No description provided for @requestMoneySuccessStepSectionBackHomeButton.
  ///
  /// In en, this message translates to:
  /// **'Back Home'**
  String get requestMoneySuccessStepSectionBackHomeButton;

  /// No description provided for @comment_request_money_wallet_section.
  ///
  /// In en, this message translates to:
  /// **'==== Request Money Wallet Section ===='**
  String get comment_request_money_wallet_section;

  /// No description provided for @requestMoneyWalletSectionBalance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get requestMoneyWalletSectionBalance;

  /// No description provided for @requestMoneyWalletSectionWalletsNotFound.
  ///
  /// In en, this message translates to:
  /// **'Wallets Not Found'**
  String get requestMoneyWalletSectionWalletsNotFound;

  /// No description provided for @comment_request_money_history_screen.
  ///
  /// In en, this message translates to:
  /// **'==== Request Money History Screen ===='**
  String get comment_request_money_history_screen;

  /// No description provided for @requestMoneyHistoryScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Request Money History'**
  String get requestMoneyHistoryScreenTitle;

  /// No description provided for @requestMoneyHistoryRequestedAt.
  ///
  /// In en, this message translates to:
  /// **'Requested At:'**
  String get requestMoneyHistoryRequestedAt;

  /// No description provided for @requestMoneyHistoryStatus.
  ///
  /// In en, this message translates to:
  /// **'Status: '**
  String get requestMoneyHistoryStatus;

  /// No description provided for @comment_request_money_history_details.
  ///
  /// In en, this message translates to:
  /// **'==== Request Money History Details ===='**
  String get comment_request_money_history_details;

  /// No description provided for @requestMoneyHistoryDetailsRequestEmail.
  ///
  /// In en, this message translates to:
  /// **'Request Email'**
  String get requestMoneyHistoryDetailsRequestEmail;

  /// No description provided for @requestMoneyHistoryDetailsCurrency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get requestMoneyHistoryDetailsCurrency;

  /// No description provided for @requestMoneyHistoryDetailsCharge.
  ///
  /// In en, this message translates to:
  /// **'Charge'**
  String get requestMoneyHistoryDetailsCharge;

  /// No description provided for @requestMoneyHistoryDetailsFinalAmount.
  ///
  /// In en, this message translates to:
  /// **'Final Amount'**
  String get requestMoneyHistoryDetailsFinalAmount;

  /// No description provided for @requestMoneyHistoryDetailsRequestAt.
  ///
  /// In en, this message translates to:
  /// **'Request At'**
  String get requestMoneyHistoryDetailsRequestAt;

  /// No description provided for @requestMoneyHistoryDetailsStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get requestMoneyHistoryDetailsStatus;

  /// No description provided for @comment_received_request_screen.
  ///
  /// In en, this message translates to:
  /// **'==== Received Request Screen ===='**
  String get comment_received_request_screen;

  /// No description provided for @receivedRequestRequestedAt.
  ///
  /// In en, this message translates to:
  /// **'Requested At:'**
  String get receivedRequestRequestedAt;

  /// No description provided for @receivedRequestStatus.
  ///
  /// In en, this message translates to:
  /// **'Status: '**
  String get receivedRequestStatus;

  /// No description provided for @receivedRequestRejectButton.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get receivedRequestRejectButton;

  /// No description provided for @receivedRequestAcceptButton.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get receivedRequestAcceptButton;

  /// No description provided for @comment_accept_request_dropdown.
  ///
  /// In en, this message translates to:
  /// **'==== Accept Request Dropdown ===='**
  String get comment_accept_request_dropdown;

  /// No description provided for @acceptRequestDropdownTitle.
  ///
  /// In en, this message translates to:
  /// **'Are You Sure?'**
  String get acceptRequestDropdownTitle;

  /// No description provided for @acceptRequestDropdownMessage.
  ///
  /// In en, this message translates to:
  /// **'Do you want to accept this money request?'**
  String get acceptRequestDropdownMessage;

  /// No description provided for @acceptRequestDropdownPayableAmount.
  ///
  /// In en, this message translates to:
  /// **'Payable Amount:'**
  String get acceptRequestDropdownPayableAmount;

  /// No description provided for @acceptRequestDropdownPayWallet.
  ///
  /// In en, this message translates to:
  /// **'Pay Wallet:'**
  String get acceptRequestDropdownPayWallet;

  /// No description provided for @acceptRequestDropdownRequesterNote.
  ///
  /// In en, this message translates to:
  /// **'Requester Note:'**
  String get acceptRequestDropdownRequesterNote;

  /// No description provided for @acceptRequestDropdownNoteNotFound.
  ///
  /// In en, this message translates to:
  /// **'Note Not Found'**
  String get acceptRequestDropdownNoteNotFound;

  /// No description provided for @acceptRequestDropdownAcceptButton.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get acceptRequestDropdownAcceptButton;

  /// No description provided for @acceptRequestDropdownCancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get acceptRequestDropdownCancelButton;

  /// No description provided for @comment_received_request_details.
  ///
  /// In en, this message translates to:
  /// **'==== Received Request Details ===='**
  String get comment_received_request_details;

  /// No description provided for @receivedRequestDetailsRequestEmail.
  ///
  /// In en, this message translates to:
  /// **'Request Email'**
  String get receivedRequestDetailsRequestEmail;

  /// No description provided for @receivedRequestDetailsCurrency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get receivedRequestDetailsCurrency;

  /// No description provided for @receivedRequestDetailsCharge.
  ///
  /// In en, this message translates to:
  /// **'Charge'**
  String get receivedRequestDetailsCharge;

  /// No description provided for @receivedRequestDetailsFinalAmount.
  ///
  /// In en, this message translates to:
  /// **'Final Amount'**
  String get receivedRequestDetailsFinalAmount;

  /// No description provided for @receivedRequestDetailsRequestAt.
  ///
  /// In en, this message translates to:
  /// **'Request At'**
  String get receivedRequestDetailsRequestAt;

  /// No description provided for @receivedRequestDetailsStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get receivedRequestDetailsStatus;

  /// No description provided for @comment_change_password_screen.
  ///
  /// In en, this message translates to:
  /// **'==== Change Password Screen ===='**
  String get comment_change_password_screen;

  /// No description provided for @changePasswordScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePasswordScreenTitle;

  /// No description provided for @changePasswordCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get changePasswordCurrentPassword;

  /// No description provided for @changePasswordNewPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get changePasswordNewPassword;

  /// No description provided for @changePasswordConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get changePasswordConfirmPassword;

  /// No description provided for @changePasswordSaveChangesButton.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get changePasswordSaveChangesButton;

  /// No description provided for @comment_id_verification_screen.
  ///
  /// In en, this message translates to:
  /// **'==== ID Verification Screen ===='**
  String get comment_id_verification_screen;

  /// No description provided for @idVerificationScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'KYC'**
  String get idVerificationScreenTitle;

  /// No description provided for @idVerificationHistoryButton.
  ///
  /// In en, this message translates to:
  /// **'KYC History'**
  String get idVerificationHistoryButton;

  /// No description provided for @idVerificationCenterTitle.
  ///
  /// In en, this message translates to:
  /// **'Verification Center'**
  String get idVerificationCenterTitle;

  /// No description provided for @idVerificationNothingToSubmit.
  ///
  /// In en, this message translates to:
  /// **'You have nothing to submit'**
  String get idVerificationNothingToSubmit;

  /// No description provided for @kycStatusVerified.
  ///
  /// In en, this message translates to:
  /// **'You have submitted your documents and it is verified'**
  String get kycStatusVerified;

  /// No description provided for @kycStatusPending.
  ///
  /// In en, this message translates to:
  /// **'You have submitted your documents and it is awaiting for the approval'**
  String get kycStatusPending;

  /// No description provided for @kycStatusRejected.
  ///
  /// In en, this message translates to:
  /// **'Your KYC verification has failed. Please resubmit the documents.'**
  String get kycStatusRejected;

  /// No description provided for @kycStatusNotSubmitted.
  ///
  /// In en, this message translates to:
  /// **'You have not submitted any KYC documents yet'**
  String get kycStatusNotSubmitted;

  /// No description provided for @comment_kyc_history_screen.
  ///
  /// In en, this message translates to:
  /// **'==== KYC History Screen ===='**
  String get comment_kyc_history_screen;

  /// No description provided for @kycHistoryScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'KYC History'**
  String get kycHistoryScreenTitle;

  /// No description provided for @kycHistoryDate.
  ///
  /// In en, this message translates to:
  /// **'Date:'**
  String get kycHistoryDate;

  /// No description provided for @kycHistoryStatus.
  ///
  /// In en, this message translates to:
  /// **'Status: '**
  String get kycHistoryStatus;

  /// No description provided for @kycHistoryStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get kycHistoryStatusPending;

  /// No description provided for @kycHistoryStatusApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get kycHistoryStatusApproved;

  /// No description provided for @kycHistoryStatusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get kycHistoryStatusRejected;

  /// No description provided for @kycHistoryViewButton.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get kycHistoryViewButton;

  /// No description provided for @comment_kyc_details_bottom_sheet.
  ///
  /// In en, this message translates to:
  /// **'==== KYC Details Bottom Sheet ===='**
  String get comment_kyc_details_bottom_sheet;

  /// No description provided for @kycDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'KYC Details'**
  String get kycDetailsTitle;

  /// No description provided for @kycDetailsStatus.
  ///
  /// In en, this message translates to:
  /// **'Status:'**
  String get kycDetailsStatus;

  /// No description provided for @kycDetailsCreatedAt.
  ///
  /// In en, this message translates to:
  /// **'Created At:'**
  String get kycDetailsCreatedAt;

  /// No description provided for @kycDetailsMessageFromAdmin.
  ///
  /// In en, this message translates to:
  /// **'Message From Admin:'**
  String get kycDetailsMessageFromAdmin;

  /// No description provided for @kycDetailsSubmittedData.
  ///
  /// In en, this message translates to:
  /// **'Submitted Data'**
  String get kycDetailsSubmittedData;

  /// No description provided for @kycDetailsStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get kycDetailsStatusPending;

  /// No description provided for @kycDetailsStatusApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get kycDetailsStatusApproved;

  /// No description provided for @kycDetailsStatusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get kycDetailsStatusRejected;

  /// No description provided for @comment_notifications_screen.
  ///
  /// In en, this message translates to:
  /// **'==== Notifications Screen ===='**
  String get comment_notifications_screen;

  /// No description provided for @notificationsScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'All Notification'**
  String get notificationsScreenTitle;

  /// No description provided for @notificationsMarkAllReadButton.
  ///
  /// In en, this message translates to:
  /// **'Mark All Read'**
  String get notificationsMarkAllReadButton;

  /// No description provided for @comment_profile_settings_screen.
  ///
  /// In en, this message translates to:
  /// **'==== Profile Settings Screen ===='**
  String get comment_profile_settings_screen;

  /// No description provided for @profileSettingsScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile Settings'**
  String get profileSettingsScreenTitle;

  /// No description provided for @profileSettingsFirstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get profileSettingsFirstName;

  /// No description provided for @profileSettingsLastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get profileSettingsLastName;

  /// No description provided for @profileSettingsUserName.
  ///
  /// In en, this message translates to:
  /// **'User Name'**
  String get profileSettingsUserName;

  /// No description provided for @profileSettingsGender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get profileSettingsGender;

  /// No description provided for @profileSettingsDateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get profileSettingsDateOfBirth;

  /// No description provided for @profileSettingsEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get profileSettingsEmailAddress;

  /// No description provided for @profileSettingsPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get profileSettingsPhone;

  /// No description provided for @profileSettingsCountry.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get profileSettingsCountry;

  /// No description provided for @profileSettingsCity.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get profileSettingsCity;

  /// No description provided for @profileSettingsZipCode.
  ///
  /// In en, this message translates to:
  /// **'Zip Code'**
  String get profileSettingsZipCode;

  /// No description provided for @profileSettingsJoiningDate.
  ///
  /// In en, this message translates to:
  /// **'Joining Date'**
  String get profileSettingsJoiningDate;

  /// No description provided for @profileSettingsAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get profileSettingsAddress;

  /// No description provided for @profileSettingsGenderTitle.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get profileSettingsGenderTitle;

  /// No description provided for @profileSettingsGenderNotFound.
  ///
  /// In en, this message translates to:
  /// **'Gender not found'**
  String get profileSettingsGenderNotFound;

  /// No description provided for @profileSettingsGenderMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get profileSettingsGenderMale;

  /// No description provided for @profileSettingsGenderFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get profileSettingsGenderFemale;

  /// No description provided for @profileSettingsGenderOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get profileSettingsGenderOther;

  /// No description provided for @profileSettingsSelectGender.
  ///
  /// In en, this message translates to:
  /// **'Select Gender'**
  String get profileSettingsSelectGender;

  /// No description provided for @profileSettingsCountryTitle.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get profileSettingsCountryTitle;

  /// No description provided for @profileSettingsCountryNotFound.
  ///
  /// In en, this message translates to:
  /// **'Country not found'**
  String get profileSettingsCountryNotFound;

  /// No description provided for @profileSettingsSelectCountry.
  ///
  /// In en, this message translates to:
  /// **'Select Country'**
  String get profileSettingsSelectCountry;

  /// No description provided for @profileSettingsSaveChangesButton.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get profileSettingsSaveChangesButton;

  /// No description provided for @comment_support_tickets_screen.
  ///
  /// In en, this message translates to:
  /// **'==== Support Tickets Screen ===='**
  String get comment_support_tickets_screen;

  /// No description provided for @supportTicketsScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Support Ticket'**
  String get supportTicketsScreenTitle;

  /// No description provided for @supportTicketsCreateTicketButton.
  ///
  /// In en, this message translates to:
  /// **'Create Ticket'**
  String get supportTicketsCreateTicketButton;

  /// No description provided for @supportTicketsLastUpdate.
  ///
  /// In en, this message translates to:
  /// **'Last Update'**
  String get supportTicketsLastUpdate;

  /// No description provided for @supportTicketsRequestedAt.
  ///
  /// In en, this message translates to:
  /// **'Requested At'**
  String get supportTicketsRequestedAt;

  /// No description provided for @supportTicketsPriorityHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get supportTicketsPriorityHigh;

  /// No description provided for @supportTicketsPriorityMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get supportTicketsPriorityMedium;

  /// No description provided for @supportTicketsPriorityLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get supportTicketsPriorityLow;

  /// No description provided for @supportTicketsStatus.
  ///
  /// In en, this message translates to:
  /// **'Status: '**
  String get supportTicketsStatus;

  /// No description provided for @supportTicketsStatusOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get supportTicketsStatusOpen;

  /// No description provided for @supportTicketsStatusClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get supportTicketsStatusClose;

  /// No description provided for @supportTicketsReplyButton.
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get supportTicketsReplyButton;

  /// No description provided for @comment_ticket_details.
  ///
  /// In en, this message translates to:
  /// **'==== Ticket Details ===='**
  String get comment_ticket_details;

  /// No description provided for @ticketDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Ticket Details'**
  String get ticketDetailsTitle;

  /// No description provided for @ticketDetailsTicketId.
  ///
  /// In en, this message translates to:
  /// **'Ticket ID'**
  String get ticketDetailsTicketId;

  /// No description provided for @ticketDetailsCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get ticketDetailsCategory;

  /// No description provided for @ticketDetailsPriority.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get ticketDetailsPriority;

  /// No description provided for @ticketDetailsCreatedOn.
  ///
  /// In en, this message translates to:
  /// **'Created On'**
  String get ticketDetailsCreatedOn;

  /// No description provided for @ticketDetailsLastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last Updated'**
  String get ticketDetailsLastUpdated;

  /// No description provided for @ticketDetailsPriorityHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get ticketDetailsPriorityHigh;

  /// No description provided for @ticketDetailsPriorityMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get ticketDetailsPriorityMedium;

  /// No description provided for @ticketDetailsPriorityLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get ticketDetailsPriorityLow;

  /// No description provided for @comment_replay_ticket_screen.
  ///
  /// In en, this message translates to:
  /// **'==== Replay Ticket Screen ===='**
  String get comment_replay_ticket_screen;

  /// No description provided for @replayTicketMarkAsClosedButton.
  ///
  /// In en, this message translates to:
  /// **'Mark As Closed'**
  String get replayTicketMarkAsClosedButton;

  /// No description provided for @replayTicketMessageHint.
  ///
  /// In en, this message translates to:
  /// **'Type your message...'**
  String get replayTicketMessageHint;

  /// No description provided for @replayTicketEmptyMessageError.
  ///
  /// In en, this message translates to:
  /// **'Please enter an message'**
  String get replayTicketEmptyMessageError;

  /// No description provided for @replayTicketAttachmentsLabel.
  ///
  /// In en, this message translates to:
  /// **'Attachments:'**
  String get replayTicketAttachmentsLabel;

  /// No description provided for @replayTicketUnknownFile.
  ///
  /// In en, this message translates to:
  /// **'Unknown file'**
  String get replayTicketUnknownFile;

  /// No description provided for @replayTicketAttachmentPreviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Attachment Preview'**
  String get replayTicketAttachmentPreviewTitle;

  /// No description provided for @replayTicketAttachmentError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong!'**
  String get replayTicketAttachmentError;

  /// No description provided for @comment_add_new_ticket_screen.
  ///
  /// In en, this message translates to:
  /// **'==== Add New Ticket Screen ===='**
  String get comment_add_new_ticket_screen;

  /// No description provided for @addNewTicketScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Ticket'**
  String get addNewTicketScreenTitle;

  /// No description provided for @addNewTicketTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get addNewTicketTitle;

  /// No description provided for @addNewTicketDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get addNewTicketDescription;

  /// No description provided for @addNewTicketAttachments.
  ///
  /// In en, this message translates to:
  /// **'Attachments'**
  String get addNewTicketAttachments;

  /// No description provided for @addNewTicketAttachFile.
  ///
  /// In en, this message translates to:
  /// **'Attach File'**
  String get addNewTicketAttachFile;

  /// No description provided for @addNewTicketAddButton.
  ///
  /// In en, this message translates to:
  /// **'Add Ticket'**
  String get addNewTicketAddButton;

  /// No description provided for @comment_two_factor_authentication_screen.
  ///
  /// In en, this message translates to:
  /// **'==== Two Factor Authentication Screen ===='**
  String get comment_two_factor_authentication_screen;

  /// No description provided for @twoFactorAuthenticationScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'2FA Authentication'**
  String get twoFactorAuthenticationScreenTitle;

  /// No description provided for @comment_disable_2fa_section.
  ///
  /// In en, this message translates to:
  /// **'==== Disable 2FA Section ===='**
  String get comment_disable_2fa_section;

  /// No description provided for @disable2FaSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'2FA Authentication'**
  String get disable2FaSectionTitle;

  /// No description provided for @disable2FaSectionDescription.
  ///
  /// In en, this message translates to:
  /// **'noInternetConnectionRetryButton'**
  String get disable2FaSectionDescription;

  /// No description provided for @disable2FaSectionDisableButton.
  ///
  /// In en, this message translates to:
  /// **'Disable 2FA'**
  String get disable2FaSectionDisableButton;

  /// No description provided for @disable2FaSectionPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter an password'**
  String get disable2FaSectionPasswordRequired;

  /// No description provided for @comment_enable_2fa_section.
  ///
  /// In en, this message translates to:
  /// **'==== Enable 2FA Section ===='**
  String get comment_enable_2fa_section;

  /// No description provided for @enable2FaSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'2FA Authentication'**
  String get enable2FaSectionTitle;

  /// No description provided for @enable2FaSectionDescription.
  ///
  /// In en, this message translates to:
  /// **'Scan the QR code with Google Authenticator\nApp to enable 2FA'**
  String get enable2FaSectionDescription;

  /// No description provided for @enable2FaSectionPinLabel.
  ///
  /// In en, this message translates to:
  /// **'The PIN From Google Authenticator App'**
  String get enable2FaSectionPinLabel;

  /// No description provided for @enable2FaSectionEnableButton.
  ///
  /// In en, this message translates to:
  /// **'Enable 2FA'**
  String get enable2FaSectionEnableButton;

  /// No description provided for @enable2FaSectionPinRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter an google authentication pin'**
  String get enable2FaSectionPinRequired;

  /// No description provided for @comment_generate_2fa_section.
  ///
  /// In en, this message translates to:
  /// **'==== Generate 2FA Section ===='**
  String get comment_generate_2fa_section;

  /// No description provided for @generate2FaSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'2FA Authentication'**
  String get generate2FaSectionTitle;

  /// No description provided for @generate2FaSectionDescription.
  ///
  /// In en, this message translates to:
  /// **'Enhance your account security with two-factor authentication'**
  String get generate2FaSectionDescription;

  /// No description provided for @generate2FaSectionGenerateButton.
  ///
  /// In en, this message translates to:
  /// **'Generate 2FA'**
  String get generate2FaSectionGenerateButton;

  /// No description provided for @comment_settings_screen.
  ///
  /// In en, this message translates to:
  /// **'==== Settings Screen ===='**
  String get comment_settings_screen;

  /// No description provided for @settingsScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsScreenTitle;

  /// No description provided for @settingsProfileSettings.
  ///
  /// In en, this message translates to:
  /// **'Profile Settings'**
  String get settingsProfileSettings;

  /// No description provided for @settingsChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get settingsChangePassword;

  /// No description provided for @settingsAllNotification.
  ///
  /// In en, this message translates to:
  /// **'All Notification'**
  String get settingsAllNotification;

  /// No description provided for @settingsTwoFactorAuthentication.
  ///
  /// In en, this message translates to:
  /// **'2FA Authentication'**
  String get settingsTwoFactorAuthentication;

  /// No description provided for @settingsIdVerification.
  ///
  /// In en, this message translates to:
  /// **'ID Verification'**
  String get settingsIdVerification;

  /// No description provided for @settingsSupport.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get settingsSupport;

  /// No description provided for @settingsSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get settingsSignOut;

  /// No description provided for @settingsKycVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get settingsKycVerified;

  /// No description provided for @settingsKycPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get settingsKycPending;

  /// No description provided for @settingsKycFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get settingsKycFailed;

  /// No description provided for @settingsKycNotSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Not Submitted'**
  String get settingsKycNotSubmitted;

  /// No description provided for @comment_transactions_screen.
  ///
  /// In en, this message translates to:
  /// **'==== Transactions Screen ===='**
  String get comment_transactions_screen;

  /// No description provided for @transactionsScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'My Transactions'**
  String get transactionsScreenTitle;

  /// No description provided for @comment_transactions_popup.
  ///
  /// In en, this message translates to:
  /// **'==== Transactions Popup ===='**
  String get comment_transactions_popup;

  /// No description provided for @transactionsPopupDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get transactionsPopupDate;

  /// No description provided for @transactionsPopupTransactionId.
  ///
  /// In en, this message translates to:
  /// **'Transaction ID'**
  String get transactionsPopupTransactionId;

  /// No description provided for @transactionsPopupWalletName.
  ///
  /// In en, this message translates to:
  /// **'Wallet Name'**
  String get transactionsPopupWalletName;

  /// No description provided for @transactionsPopupAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get transactionsPopupAmount;

  /// No description provided for @transactionsPopupCharge.
  ///
  /// In en, this message translates to:
  /// **'Charge'**
  String get transactionsPopupCharge;

  /// No description provided for @transactionsPopupFinalAmount.
  ///
  /// In en, this message translates to:
  /// **'Final Amount'**
  String get transactionsPopupFinalAmount;

  /// No description provided for @transactionsPopupStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get transactionsPopupStatus;

  /// No description provided for @comment_transaction_filter_bottom_sheet.
  ///
  /// In en, this message translates to:
  /// **'==== Transaction Filter Bottom Sheet ===='**
  String get comment_transaction_filter_bottom_sheet;

  /// No description provided for @transactionFilterTransactionId.
  ///
  /// In en, this message translates to:
  /// **'Transactions ID'**
  String get transactionFilterTransactionId;

  /// No description provided for @transactionFilterStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get transactionFilterStatus;

  /// No description provided for @transactionFilterApplyButton.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get transactionFilterApplyButton;

  /// No description provided for @transactionFilterResetButton.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get transactionFilterResetButton;

  /// No description provided for @comment_transfer_screen.
  ///
  /// In en, this message translates to:
  /// **'==== Transfer Screen ===='**
  String get comment_transfer_screen;

  /// No description provided for @transferScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Transfer Money'**
  String get transferScreenTitle;

  /// No description provided for @transferHistoryTransferHistory.
  ///
  /// In en, this message translates to:
  /// **'Transfer History'**
  String get transferHistoryTransferHistory;

  /// No description provided for @transferHistoryReceivedHistory.
  ///
  /// In en, this message translates to:
  /// **'Received History'**
  String get transferHistoryReceivedHistory;

  /// No description provided for @comment_transfer_received_history_screen.
  ///
  /// In en, this message translates to:
  /// **'==== Transfer Received History Screen ===='**
  String get comment_transfer_received_history_screen;

  /// No description provided for @transferReceivedHistoryScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Received History'**
  String get transferReceivedHistoryScreenTitle;

  /// No description provided for @comment_transfer_received_filter_bottom_sheet.
  ///
  /// In en, this message translates to:
  /// **'==== Transfer Received Filter Bottom Sheet ===='**
  String get comment_transfer_received_filter_bottom_sheet;

  /// No description provided for @transferReceivedFilterTransactionId.
  ///
  /// In en, this message translates to:
  /// **'Transactions ID'**
  String get transferReceivedFilterTransactionId;

  /// No description provided for @transferReceivedFilterStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get transferReceivedFilterStatus;

  /// No description provided for @transferReceivedFilterApplyButton.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get transferReceivedFilterApplyButton;

  /// No description provided for @transferReceivedFilterResetButton.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get transferReceivedFilterResetButton;

  /// No description provided for @comment_transfer_history_screen.
  ///
  /// In en, this message translates to:
  /// **'==== Transfer History Screen ===='**
  String get comment_transfer_history_screen;

  /// No description provided for @transferHistoryScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Transfer History'**
  String get transferHistoryScreenTitle;

  /// No description provided for @comment_transfer_transaction_filter_bottom_sheet.
  ///
  /// In en, this message translates to:
  /// **'==== Transfer Transaction Filter Bottom Sheet ===='**
  String get comment_transfer_transaction_filter_bottom_sheet;

  /// No description provided for @transferTransactionFilterTransactionId.
  ///
  /// In en, this message translates to:
  /// **'Transactions ID'**
  String get transferTransactionFilterTransactionId;

  /// No description provided for @transferTransactionFilterStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get transferTransactionFilterStatus;

  /// No description provided for @transferTransactionFilterApplyButton.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get transferTransactionFilterApplyButton;

  /// No description provided for @transferTransactionFilterResetButton.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get transferTransactionFilterResetButton;

  /// No description provided for @comment_transfer_amount_step_section.
  ///
  /// In en, this message translates to:
  /// **'==== Transfer Amount Step Section ===='**
  String get comment_transfer_amount_step_section;

  /// No description provided for @transferAmountStepSectionRecipientUid.
  ///
  /// In en, this message translates to:
  /// **'Recipient UID'**
  String get transferAmountStepSectionRecipientUid;

  /// No description provided for @transferAmountStepSectionAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get transferAmountStepSectionAmount;

  /// No description provided for @transferAmountStepSectionMin.
  ///
  /// In en, this message translates to:
  /// **'Minimum'**
  String get transferAmountStepSectionMin;

  /// No description provided for @transferAmountStepSectionMax.
  ///
  /// In en, this message translates to:
  /// **'and Maximum'**
  String get transferAmountStepSectionMax;

  /// No description provided for @transferAmountStepSectionTransferMoneyButton.
  ///
  /// In en, this message translates to:
  /// **'Transfer Money'**
  String get transferAmountStepSectionTransferMoneyButton;

  /// No description provided for @transferAmountStepSectionSavedBeneficiaryButton.
  ///
  /// In en, this message translates to:
  /// **'Saved Beneficiary'**
  String get transferAmountStepSectionSavedBeneficiaryButton;

  /// No description provided for @transferAmountStepSectionInvalidQrCodeDigits.
  ///
  /// In en, this message translates to:
  /// **'Invalid QR code. Recipient UID must be digits only.'**
  String get transferAmountStepSectionInvalidQrCodeDigits;

  /// No description provided for @transferAmountStepSectionInvalidQrCodePrefix.
  ///
  /// In en, this message translates to:
  /// **'Invalid QR code. UID prefix not found.'**
  String get transferAmountStepSectionInvalidQrCodePrefix;

  /// No description provided for @transferAmountStepSectionBeneficiariesTitle.
  ///
  /// In en, this message translates to:
  /// **'Beneficiaries'**
  String get transferAmountStepSectionBeneficiariesTitle;

  /// No description provided for @transferAmountStepSectionAddBeneficiary.
  ///
  /// In en, this message translates to:
  /// **'Add Beneficiary'**
  String get transferAmountStepSectionAddBeneficiary;

  /// No description provided for @transferAmountStepSectionUidLabel.
  ///
  /// In en, this message translates to:
  /// **'UID:'**
  String get transferAmountStepSectionUidLabel;

  /// No description provided for @transferAmountStepSectionDeleteConfirmationTitle.
  ///
  /// In en, this message translates to:
  /// **'Are you sure?'**
  String get transferAmountStepSectionDeleteConfirmationTitle;

  /// No description provided for @transferAmountStepSectionDeleteConfirmationMessage.
  ///
  /// In en, this message translates to:
  /// **'You want to delete this beneficiary?'**
  String get transferAmountStepSectionDeleteConfirmationMessage;

  /// No description provided for @transferAmountStepSectionDeleteButton.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get transferAmountStepSectionDeleteButton;

  /// No description provided for @transferAmountStepSectionCancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get transferAmountStepSectionCancelButton;

  /// No description provided for @comment_transfer_review_step_section.
  ///
  /// In en, this message translates to:
  /// **'==== Transfer Review Step Section ===='**
  String get comment_transfer_review_step_section;

  /// No description provided for @transferReviewStepSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Review Details'**
  String get transferReviewStepSectionTitle;

  /// No description provided for @transferReviewStepSectionAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get transferReviewStepSectionAmount;

  /// No description provided for @transferReviewStepSectionWallet.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get transferReviewStepSectionWallet;

  /// No description provided for @transferReviewStepSectionRecipientAccount.
  ///
  /// In en, this message translates to:
  /// **'Recipient Account'**
  String get transferReviewStepSectionRecipientAccount;

  /// No description provided for @transferReviewStepSectionCharge.
  ///
  /// In en, this message translates to:
  /// **'Charge'**
  String get transferReviewStepSectionCharge;

  /// No description provided for @transferReviewStepSectionTotalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get transferReviewStepSectionTotalAmount;

  /// No description provided for @transferReviewStepSectionBackButton.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get transferReviewStepSectionBackButton;

  /// No description provided for @transferReviewStepSectionConfirmButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get transferReviewStepSectionConfirmButton;

  /// No description provided for @comment_transfer_success_step_section.
  ///
  /// In en, this message translates to:
  /// **'==== Transfer Success Step Section ===='**
  String get comment_transfer_success_step_section;

  /// No description provided for @transferSuccessStepSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Transfer Money Success!'**
  String get transferSuccessStepSectionTitle;

  /// No description provided for @transferSuccessStepSectionAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get transferSuccessStepSectionAmount;

  /// No description provided for @transferSuccessStepSectionTransactionId.
  ///
  /// In en, this message translates to:
  /// **'Transection ID'**
  String get transferSuccessStepSectionTransactionId;

  /// No description provided for @transferSuccessStepSectionWalletName.
  ///
  /// In en, this message translates to:
  /// **'Wallet Name'**
  String get transferSuccessStepSectionWalletName;

  /// No description provided for @transferSuccessStepSectionPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get transferSuccessStepSectionPaymentMethod;

  /// No description provided for @transferSuccessStepSectionDateTime.
  ///
  /// In en, this message translates to:
  /// **'Date & Time'**
  String get transferSuccessStepSectionDateTime;

  /// No description provided for @transferSuccessStepSectionName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get transferSuccessStepSectionName;

  /// No description provided for @transferSuccessStepSectionCharge.
  ///
  /// In en, this message translates to:
  /// **'Charge'**
  String get transferSuccessStepSectionCharge;

  /// No description provided for @transferSuccessStepSectionTotalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get transferSuccessStepSectionTotalAmount;

  /// No description provided for @transferSuccessStepSectionTransferAgainButton.
  ///
  /// In en, this message translates to:
  /// **'Transfer Again'**
  String get transferSuccessStepSectionTransferAgainButton;

  /// No description provided for @transferSuccessStepSectionBackHomeButton.
  ///
  /// In en, this message translates to:
  /// **'Back Home'**
  String get transferSuccessStepSectionBackHomeButton;

  /// No description provided for @comment_transfer_wallet_section.
  ///
  /// In en, this message translates to:
  /// **'==== Transfer Wallet Section ===='**
  String get comment_transfer_wallet_section;

  /// No description provided for @transferWalletSectionBalance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get transferWalletSectionBalance;

  /// No description provided for @transferWalletSectionWalletsNotFound.
  ///
  /// In en, this message translates to:
  /// **'Wallets Not Found'**
  String get transferWalletSectionWalletsNotFound;

  /// No description provided for @comment_wallets_screen.
  ///
  /// In en, this message translates to:
  /// **'==== Wallets Screen ===='**
  String get comment_wallets_screen;

  /// No description provided for @walletsScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'My Wallets'**
  String get walletsScreenTitle;

  /// No description provided for @comment_delete_wallet_bottom_sheet.
  ///
  /// In en, this message translates to:
  /// **'==== Delete Wallet Bottom Sheet ===='**
  String get comment_delete_wallet_bottom_sheet;

  /// No description provided for @deleteWalletBottomSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Are you sure?'**
  String get deleteWalletBottomSheetTitle;

  /// No description provided for @deleteWalletBottomSheetMessage.
  ///
  /// In en, this message translates to:
  /// **'You want to delete this wallet?'**
  String get deleteWalletBottomSheetMessage;

  /// No description provided for @deleteWalletBottomSheetDeleteButton.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteWalletBottomSheetDeleteButton;

  /// No description provided for @deleteWalletBottomSheetCancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get deleteWalletBottomSheetCancelButton;

  /// No description provided for @comment_wallet_list_section.
  ///
  /// In en, this message translates to:
  /// **'==== Wallet List Section ===='**
  String get comment_wallet_list_section;

  /// No description provided for @walletListSectionTopUpButton.
  ///
  /// In en, this message translates to:
  /// **'Top Up'**
  String get walletListSectionTopUpButton;

  /// No description provided for @walletListSectionWithdrawButton.
  ///
  /// In en, this message translates to:
  /// **'Withdraw'**
  String get walletListSectionWithdrawButton;

  /// No description provided for @walletListSectionUserDepositNotEnabled.
  ///
  /// In en, this message translates to:
  /// **'User Deposit Not Enabled'**
  String get walletListSectionUserDepositNotEnabled;

  /// No description provided for @walletListSectionUserWithdrawNotEnabled.
  ///
  /// In en, this message translates to:
  /// **'User Withdraw Not Enabled'**
  String get walletListSectionUserWithdrawNotEnabled;

  /// No description provided for @comment_create_new_wallet_screen.
  ///
  /// In en, this message translates to:
  /// **'==== Create New Wallet Screen ===='**
  String get comment_create_new_wallet_screen;

  /// No description provided for @createNewWalletScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Create New Wallet'**
  String get createNewWalletScreenTitle;

  /// No description provided for @createNewWalletCurrency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get createNewWalletCurrency;

  /// No description provided for @createNewWalletSelectCurrency.
  ///
  /// In en, this message translates to:
  /// **'Select Currency'**
  String get createNewWalletSelectCurrency;

  /// No description provided for @createNewWalletCurrencyNotFound.
  ///
  /// In en, this message translates to:
  /// **'Currency not found'**
  String get createNewWalletCurrencyNotFound;

  /// No description provided for @createNewWalletCreateButton.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get createNewWalletCreateButton;

  /// No description provided for @comment_withdraw_screen.
  ///
  /// In en, this message translates to:
  /// **'==== Withdraw Screen ===='**
  String get comment_withdraw_screen;

  /// No description provided for @withdrawScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Withdraw Money'**
  String get withdrawScreenTitle;

  /// No description provided for @withdrawScreenAddAccountButton.
  ///
  /// In en, this message translates to:
  /// **'Add Account'**
  String get withdrawScreenAddAccountButton;

  /// No description provided for @comment_withdraw_history_screen.
  ///
  /// In en, this message translates to:
  /// **'==== Withdraw History Screen ===='**
  String get comment_withdraw_history_screen;

  /// No description provided for @withdrawHistoryScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Withdraw History'**
  String get withdrawHistoryScreenTitle;

  /// No description provided for @comment_withdraw_transaction_filter_bottom_sheet.
  ///
  /// In en, this message translates to:
  /// **'==== Withdraw Transaction Filter Bottom Sheet ===='**
  String get comment_withdraw_transaction_filter_bottom_sheet;

  /// No description provided for @withdrawTransactionFilterTransactionId.
  ///
  /// In en, this message translates to:
  /// **'Transactions ID'**
  String get withdrawTransactionFilterTransactionId;

  /// No description provided for @withdrawTransactionFilterStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get withdrawTransactionFilterStatus;

  /// No description provided for @withdrawTransactionFilterApplyButton.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get withdrawTransactionFilterApplyButton;

  /// No description provided for @withdrawTransactionFilterResetButton.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get withdrawTransactionFilterResetButton;

  /// No description provided for @comment_delete_account_dropdown_section.
  ///
  /// In en, this message translates to:
  /// **'==== Delete Account Dropdown Section ===='**
  String get comment_delete_account_dropdown_section;

  /// No description provided for @deleteAccountDropdownTitle.
  ///
  /// In en, this message translates to:
  /// **'Are you sure?'**
  String get deleteAccountDropdownTitle;

  /// No description provided for @deleteAccountDropdownMessage.
  ///
  /// In en, this message translates to:
  /// **'You want to delete this account?'**
  String get deleteAccountDropdownMessage;

  /// No description provided for @deleteAccountDropdownDeleteButton.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteAccountDropdownDeleteButton;

  /// No description provided for @deleteAccountDropdownCancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get deleteAccountDropdownCancelButton;

  /// No description provided for @comment_withdraw_account_filter_bottom_sheet.
  ///
  /// In en, this message translates to:
  /// **'==== Withdraw Account Filter Bottom Sheet ===='**
  String get comment_withdraw_account_filter_bottom_sheet;

  /// No description provided for @withdrawAccountFilterMethodName.
  ///
  /// In en, this message translates to:
  /// **'Method Name'**
  String get withdrawAccountFilterMethodName;

  /// No description provided for @withdrawAccountFilterApplyButton.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get withdrawAccountFilterApplyButton;

  /// No description provided for @comment_withdraw_account_section.
  ///
  /// In en, this message translates to:
  /// **'==== Withdraw Account Section ===='**
  String get comment_withdraw_account_section;

  /// No description provided for @withdrawAccountSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'All Account'**
  String get withdrawAccountSectionTitle;

  /// No description provided for @comment_withdraw_amount_step_section.
  ///
  /// In en, this message translates to:
  /// **'==== Withdraw Amount Step Section ===='**
  String get comment_withdraw_amount_step_section;

  /// No description provided for @withdrawAmountStepSectionWithdrawAccount.
  ///
  /// In en, this message translates to:
  /// **'Withdraw Account'**
  String get withdrawAmountStepSectionWithdrawAccount;

  /// No description provided for @withdrawAmountStepSectionAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get withdrawAmountStepSectionAmount;

  /// No description provided for @withdrawAmountStepSectionMin.
  ///
  /// In en, this message translates to:
  /// **'Minimum'**
  String get withdrawAmountStepSectionMin;

  /// No description provided for @withdrawAmountStepSectionMax.
  ///
  /// In en, this message translates to:
  /// **'and Maximum'**
  String get withdrawAmountStepSectionMax;

  /// No description provided for @withdrawAmountStepSectionWithdrawMoneyButton.
  ///
  /// In en, this message translates to:
  /// **'Withdraw Money'**
  String get withdrawAmountStepSectionWithdrawMoneyButton;

  /// No description provided for @withdrawAmountStepSectionWithdrawAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Withdraw Account'**
  String get withdrawAmountStepSectionWithdrawAccountTitle;

  /// No description provided for @withdrawAmountStepSectionNoAccountsFound.
  ///
  /// In en, this message translates to:
  /// **'No withdraw accounts found'**
  String get withdrawAmountStepSectionNoAccountsFound;

  /// No description provided for @withdrawAmountStepSectionCurrencyLabel.
  ///
  /// In en, this message translates to:
  /// **'Currency:'**
  String get withdrawAmountStepSectionCurrencyLabel;

  /// No description provided for @withdrawAmountStepSectionMinDescription.
  ///
  /// In en, this message translates to:
  /// **'Min:'**
  String get withdrawAmountStepSectionMinDescription;

  /// No description provided for @withdrawAmountStepSectionMaxDescription.
  ///
  /// In en, this message translates to:
  /// **'Max:'**
  String get withdrawAmountStepSectionMaxDescription;

  /// No description provided for @comment_withdraw_header_section.
  ///
  /// In en, this message translates to:
  /// **'==== Withdraw Header Section ===='**
  String get comment_withdraw_header_section;

  /// No description provided for @withdrawHeaderSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Withdraw Money'**
  String get withdrawHeaderSectionTitle;

  /// No description provided for @withdrawHeaderSectionWithdrawButton.
  ///
  /// In en, this message translates to:
  /// **'Withdraw'**
  String get withdrawHeaderSectionWithdrawButton;

  /// No description provided for @withdrawHeaderSectionWithdrawAccountButton.
  ///
  /// In en, this message translates to:
  /// **'Withdraw Account'**
  String get withdrawHeaderSectionWithdrawAccountButton;

  /// No description provided for @withdrawHeaderSectionHistory.
  ///
  /// In en, this message translates to:
  /// **'Withdraw History'**
  String get withdrawHeaderSectionHistory;

  /// No description provided for @comment_withdraw_review_step_section.
  ///
  /// In en, this message translates to:
  /// **'==== Withdraw Review Step Section ===='**
  String get comment_withdraw_review_step_section;

  /// No description provided for @withdrawReviewStepSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Review Details'**
  String get withdrawReviewStepSectionTitle;

  /// No description provided for @withdrawReviewStepSectionAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get withdrawReviewStepSectionAmount;

  /// No description provided for @withdrawReviewStepSectionCharge.
  ///
  /// In en, this message translates to:
  /// **'Charge'**
  String get withdrawReviewStepSectionCharge;

  /// No description provided for @withdrawReviewStepSectionTotalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get withdrawReviewStepSectionTotalAmount;

  /// No description provided for @withdrawReviewStepSectionBackButton.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get withdrawReviewStepSectionBackButton;

  /// No description provided for @withdrawReviewStepSectionConfirmButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get withdrawReviewStepSectionConfirmButton;

  /// No description provided for @comment_withdraw_success_step_section.
  ///
  /// In en, this message translates to:
  /// **'==== Withdraw Success Step Section ===='**
  String get comment_withdraw_success_step_section;

  /// No description provided for @withdrawSuccessStepSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Withdraw Money Success!'**
  String get withdrawSuccessStepSectionTitle;

  /// No description provided for @withdrawSuccessStepSectionAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get withdrawSuccessStepSectionAmount;

  /// No description provided for @withdrawSuccessStepSectionTransactionId.
  ///
  /// In en, this message translates to:
  /// **'Transection ID'**
  String get withdrawSuccessStepSectionTransactionId;

  /// No description provided for @withdrawSuccessStepSectionCharge.
  ///
  /// In en, this message translates to:
  /// **'Charge'**
  String get withdrawSuccessStepSectionCharge;

  /// No description provided for @withdrawSuccessStepSectionTransactionType.
  ///
  /// In en, this message translates to:
  /// **'Transaction Type'**
  String get withdrawSuccessStepSectionTransactionType;

  /// No description provided for @withdrawSuccessStepSectionFinalAmount.
  ///
  /// In en, this message translates to:
  /// **'Final Amount'**
  String get withdrawSuccessStepSectionFinalAmount;

  /// No description provided for @withdrawSuccessStepSectionWithdrawAgainButton.
  ///
  /// In en, this message translates to:
  /// **'Withdraw Money Again'**
  String get withdrawSuccessStepSectionWithdrawAgainButton;

  /// No description provided for @withdrawSuccessStepSectionBackHomeButton.
  ///
  /// In en, this message translates to:
  /// **'Back Home'**
  String get withdrawSuccessStepSectionBackHomeButton;

  /// No description provided for @comment_edit_withdraw_account_screen.
  ///
  /// In en, this message translates to:
  /// **'==== Edit Withdraw Account Screen ===='**
  String get comment_edit_withdraw_account_screen;

  /// No description provided for @editWithdrawAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Update Withdraw Account'**
  String get editWithdrawAccountTitle;

  /// No description provided for @editWithdrawAccountMethodName.
  ///
  /// In en, this message translates to:
  /// **'Method Name'**
  String get editWithdrawAccountMethodName;

  /// No description provided for @editWithdrawAccountMethodNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter method name'**
  String get editWithdrawAccountMethodNameHint;

  /// No description provided for @editWithdrawAccountFieldHint.
  ///
  /// In en, this message translates to:
  /// **'Write here...'**
  String get editWithdrawAccountFieldHint;

  /// No description provided for @editWithdrawAccountGenericFieldHint.
  ///
  /// In en, this message translates to:
  /// **'Enter'**
  String get editWithdrawAccountGenericFieldHint;

  /// No description provided for @editWithdrawAccountUpdateButton.
  ///
  /// In en, this message translates to:
  /// **'Update Account'**
  String get editWithdrawAccountUpdateButton;

  /// No description provided for @comment_create_withdraw_account_screen.
  ///
  /// In en, this message translates to:
  /// **'==== Create Withdraw Account Screen ===='**
  String get comment_create_withdraw_account_screen;

  /// No description provided for @createWithdrawAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Withdraw Account'**
  String get createWithdrawAccountTitle;

  /// No description provided for @createWithdrawAccountWallet.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get createWithdrawAccountWallet;

  /// No description provided for @createWithdrawAccountWithdrawMethod.
  ///
  /// In en, this message translates to:
  /// **'Withdraw Method'**
  String get createWithdrawAccountWithdrawMethod;

  /// No description provided for @createWithdrawAccountMethodName.
  ///
  /// In en, this message translates to:
  /// **'Method Name'**
  String get createWithdrawAccountMethodName;

  /// No description provided for @createWithdrawAccountCreateButton.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createWithdrawAccountCreateButton;

  /// No description provided for @createWithdrawAccountWalletsNotFound.
  ///
  /// In en, this message translates to:
  /// **'Wallets Not Found'**
  String get createWithdrawAccountWalletsNotFound;

  /// No description provided for @createWithdrawAccountWithdrawMethodTitle.
  ///
  /// In en, this message translates to:
  /// **'Withdraw Method'**
  String get createWithdrawAccountWithdrawMethodTitle;

  /// No description provided for @createWithdrawAccountWithdrawMethodNotFound.
  ///
  /// In en, this message translates to:
  /// **'Withdraw method not found'**
  String get createWithdrawAccountWithdrawMethodNotFound;

  /// No description provided for @createWithdrawAccountFieldHint.
  ///
  /// In en, this message translates to:
  /// **'Write here...'**
  String get createWithdrawAccountFieldHint;

  /// No description provided for @comment_dynamic_attachment_preview.
  ///
  /// In en, this message translates to:
  /// **'==== Dynamic Attachment Preview ===='**
  String get comment_dynamic_attachment_preview;

  /// No description provided for @dynamicAttachmentPreviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Attachment Preview'**
  String get dynamicAttachmentPreviewTitle;

  /// No description provided for @comment_no_internet_connection.
  ///
  /// In en, this message translates to:
  /// **'==== No Internet Connection ===='**
  String get comment_no_internet_connection;

  /// No description provided for @noInternetConnectionTitle.
  ///
  /// In en, this message translates to:
  /// **'No Internet Connection'**
  String get noInternetConnectionTitle;

  /// No description provided for @noInternetConnectionMessage.
  ///
  /// In en, this message translates to:
  /// **'Please check your network settings'**
  String get noInternetConnectionMessage;

  /// No description provided for @noInternetConnectionRetryButton.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get noInternetConnectionRetryButton;

  /// No description provided for @comment_qr_scanner_screen.
  ///
  /// In en, this message translates to:
  /// **'==== QR Scanner Screen ===='**
  String get comment_qr_scanner_screen;

  /// No description provided for @qrScannerScreenInstruction.
  ///
  /// In en, this message translates to:
  /// **'Place QR code within the frame to scan'**
  String get qrScannerScreenInstruction;

  /// No description provided for @qrScannerScreenProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get qrScannerScreenProcessing;

  /// No description provided for @comment_webview_screen.
  ///
  /// In en, this message translates to:
  /// **'==== WebView Screen ===='**
  String get comment_webview_screen;

  /// No description provided for @webViewScreenPaymentSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Payment Successful!'**
  String get webViewScreenPaymentSuccessful;

  /// No description provided for @webViewScreenPaymentFailed.
  ///
  /// In en, this message translates to:
  /// **'Payment Failed!'**
  String get webViewScreenPaymentFailed;

  /// No description provided for @webViewScreenPaymentCancelled.
  ///
  /// In en, this message translates to:
  /// **'Payment was cancelled!'**
  String get webViewScreenPaymentCancelled;

  /// No description provided for @comment_common_country_dropdown_bottom_sheet.
  ///
  /// In en, this message translates to:
  /// **'==== Common Country Dropdown Bottom Sheet ===='**
  String get comment_common_country_dropdown_bottom_sheet;

  /// No description provided for @commonCountryDropdownSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get commonCountryDropdownSearchHint;

  /// No description provided for @commonCountryDropdownNotFound.
  ///
  /// In en, this message translates to:
  /// **'Country not found'**
  String get commonCountryDropdownNotFound;

  /// No description provided for @comment_common_dropdown_bottom_sheet.
  ///
  /// In en, this message translates to:
  /// **'==== Common Dropdown Bottom Sheet ===='**
  String get comment_common_dropdown_bottom_sheet;

  /// No description provided for @commonDropdownSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get commonDropdownSearchHint;

  /// No description provided for @comment_common_dropdown_bottom_sheet_three.
  ///
  /// In en, this message translates to:
  /// **'==== Common Dropdown Bottom Sheet Three ===='**
  String get comment_common_dropdown_bottom_sheet_three;

  /// No description provided for @commonDropdownThreeSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get commonDropdownThreeSearchHint;

  /// No description provided for @comment_common_dropdown_bottom_sheet_two.
  ///
  /// In en, this message translates to:
  /// **'==== Common Dropdown Bottom Sheet Two ===='**
  String get comment_common_dropdown_bottom_sheet_two;

  /// No description provided for @commonDropdownTwoSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get commonDropdownTwoSearchHint;

  /// No description provided for @comment_common_dropdown_wallet_bottom_sheet.
  ///
  /// In en, this message translates to:
  /// **'==== Common Dropdown Wallet Bottom Sheet ===='**
  String get comment_common_dropdown_wallet_bottom_sheet;

  /// No description provided for @commonDropdownWalletTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Wallet'**
  String get commonDropdownWalletTitle;

  /// No description provided for @comment_image_picker_dropdown_bottom_sheet.
  ///
  /// In en, this message translates to:
  /// **'==== Image Picker Dropdown Bottom Sheet ===='**
  String get comment_image_picker_dropdown_bottom_sheet;

  /// No description provided for @imagePickerDropdownTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Image Source'**
  String get imagePickerDropdownTitle;

  /// No description provided for @imagePickerDropdownCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get imagePickerDropdownCamera;

  /// No description provided for @imagePickerDropdownGallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get imagePickerDropdownGallery;

  /// No description provided for @comment_multiple_image_picker_dropdown_bottom_sheet.
  ///
  /// In en, this message translates to:
  /// **'==== Multiple Image Picker Dropdown Bottom Sheet ===='**
  String get comment_multiple_image_picker_dropdown_bottom_sheet;

  /// No description provided for @multipleImagePickerDropdownTitle.
  ///
  /// In en, this message translates to:
  /// **'Image Source'**
  String get multipleImagePickerDropdownTitle;

  /// No description provided for @multipleImagePickerDropdownCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get multipleImagePickerDropdownCamera;

  /// No description provided for @multipleImagePickerDropdownGallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get multipleImagePickerDropdownGallery;

  /// No description provided for @comment_navigation_screen.
  ///
  /// In en, this message translates to:
  /// **'==== Navigation Screen ===='**
  String get comment_navigation_screen;

  /// No description provided for @bottomNavHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get bottomNavHome;

  /// No description provided for @bottomNavTransfer.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get bottomNavTransfer;

  /// No description provided for @bottomNavGift.
  ///
  /// In en, this message translates to:
  /// **'Gift'**
  String get bottomNavGift;

  /// No description provided for @bottomNavSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get bottomNavSettings;

  /// No description provided for @qrInvalidFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid QR format. Only AID, MID, or UID codes are accepted.'**
  String get qrInvalidFormat;

  /// No description provided for @userTransferNotEnabled.
  ///
  /// In en, this message translates to:
  /// **'User Transfer Not Enabled'**
  String get userTransferNotEnabled;

  /// No description provided for @userGiftNotEnabled.
  ///
  /// In en, this message translates to:
  /// **'User Gift Not Enabled'**
  String get userGiftNotEnabled;

  /// No description provided for @comment_image_picker_controller.
  ///
  /// In en, this message translates to:
  /// **'==== Image Picker Controller ===='**
  String get comment_image_picker_controller;

  /// No description provided for @imagePickerGalleryError.
  ///
  /// In en, this message translates to:
  /// **'Failed to pick image from gallery'**
  String get imagePickerGalleryError;

  /// No description provided for @imagePickerCameraError.
  ///
  /// In en, this message translates to:
  /// **'Failed to pick image from camera'**
  String get imagePickerCameraError;

  /// No description provided for @comment_multiple_image_picker_controller.
  ///
  /// In en, this message translates to:
  /// **'==== Multiple Image Picker Controller ===='**
  String get comment_multiple_image_picker_controller;

  /// No description provided for @multipleImagePickerGalleryError.
  ///
  /// In en, this message translates to:
  /// **'Failed to pick image from gallery'**
  String get multipleImagePickerGalleryError;

  /// No description provided for @multipleImagePickerCameraError.
  ///
  /// In en, this message translates to:
  /// **'Failed to pick image from camera'**
  String get multipleImagePickerCameraError;

  /// No description provided for @comment_biometric_auth_service.
  ///
  /// In en, this message translates to:
  /// **'==== Biometric Auth Service ===='**
  String get comment_biometric_auth_service;

  /// No description provided for @biometricDeviceNotSupported.
  ///
  /// In en, this message translates to:
  /// **'This device does not support biometrics.'**
  String get biometricDeviceNotSupported;

  /// No description provided for @biometricNotEnrolled.
  ///
  /// In en, this message translates to:
  /// **'No biometric enrolled. Please set up fingerprint'**
  String get biometricNotEnrolled;

  /// No description provided for @biometricUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Biometric features are currently unavailable.'**
  String get biometricUnavailable;

  /// No description provided for @biometricAuthenticationFailed.
  ///
  /// In en, this message translates to:
  /// **'Biometric authentication failed.'**
  String get biometricAuthenticationFailed;

  /// No description provided for @biometricCheckFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to check biometric availability.'**
  String get biometricCheckFailed;

  /// No description provided for @biometricAuthReason.
  ///
  /// In en, this message translates to:
  /// **'Authenticate to log in'**
  String get biometricAuthReason;

  /// No description provided for @comment_network_service.
  ///
  /// In en, this message translates to:
  /// **'==== Network Service ===='**
  String get comment_network_service;

  /// No description provided for @networkErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred. Please try again.'**
  String get networkErrorGeneric;

  /// No description provided for @networkErrorTimeout.
  ///
  /// In en, this message translates to:
  /// **'Request timed out. Please try again.'**
  String get networkErrorTimeout;

  /// No description provided for @networkErrorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred. Please try again.'**
  String get networkErrorOccurred;

  /// No description provided for @unauthorizedDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Unauthorized'**
  String get unauthorizedDialogTitle;

  /// No description provided for @unauthorizedDialogDescription.
  ///
  /// In en, this message translates to:
  /// **'You are not authorized to access this resource. Please log in again!'**
  String get unauthorizedDialogDescription;

  /// No description provided for @unauthorizedDialogButton.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get unauthorizedDialogButton;

  /// No description provided for @comment_add_money_controller.
  ///
  /// In en, this message translates to:
  /// **'==== Add Money Controller ===='**
  String get comment_add_money_controller;

  /// No description provided for @addMoneySuccess.
  ///
  /// In en, this message translates to:
  /// **'Money added successfully'**
  String get addMoneySuccess;

  /// No description provided for @addMoneyValidationSelectWallet.
  ///
  /// In en, this message translates to:
  /// **'Please select a wallet'**
  String get addMoneyValidationSelectWallet;

  /// No description provided for @addMoneyValidationSelectGateway.
  ///
  /// In en, this message translates to:
  /// **'Please select a gateway'**
  String get addMoneyValidationSelectGateway;

  /// No description provided for @addMoneyValidationEnterAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter an amount'**
  String get addMoneyValidationEnterAmount;

  /// No description provided for @addMoneyValidationAmountGreaterThanZero.
  ///
  /// In en, this message translates to:
  /// **'Amount must be greater than 0'**
  String get addMoneyValidationAmountGreaterThanZero;

  /// No description provided for @addMoneyValidationAmountMinimum.
  ///
  /// In en, this message translates to:
  /// **'Amount must not exceed {amount}'**
  String addMoneyValidationAmountMinimum(Object amount);

  /// No description provided for @addMoneyValidationAmountMaximum.
  ///
  /// In en, this message translates to:
  /// **'Amount must not exceed {amount}'**
  String addMoneyValidationAmountMaximum(Object amount);

  /// No description provided for @addMoneyValidationUploadFile.
  ///
  /// In en, this message translates to:
  /// **'Please upload a file for {fieldName}'**
  String addMoneyValidationUploadFile(Object fieldName);

  /// No description provided for @addMoneyValidationFillField.
  ///
  /// In en, this message translates to:
  /// **'Please fill in the {fieldName} field'**
  String addMoneyValidationFillField(Object fieldName);

  /// No description provided for @comment_cash_out_controller.
  ///
  /// In en, this message translates to:
  /// **'==== Cash Out Controller ===='**
  String get comment_cash_out_controller;

  /// No description provided for @cashOutValidationSelectWallet.
  ///
  /// In en, this message translates to:
  /// **'Please select a wallet'**
  String get cashOutValidationSelectWallet;

  /// No description provided for @cashOutValidationEnterAgentAid.
  ///
  /// In en, this message translates to:
  /// **'Please enter an Agent AID'**
  String get cashOutValidationEnterAgentAid;

  /// No description provided for @cashOutValidationEnterAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter an amount'**
  String get cashOutValidationEnterAmount;

  /// No description provided for @cashOutValidationAmountMinimum.
  ///
  /// In en, this message translates to:
  /// **'Minimum amount should be {amount} {currency}'**
  String cashOutValidationAmountMinimum(Object amount, Object currency);

  /// No description provided for @cashOutValidationAmountMaximum.
  ///
  /// In en, this message translates to:
  /// **'Maximum amount should be {amount} {currency}'**
  String cashOutValidationAmountMaximum(Object amount, Object currency);

  /// No description provided for @comment_exchange_controller.
  ///
  /// In en, this message translates to:
  /// **'==== Exchange Controller ===='**
  String get comment_exchange_controller;

  /// No description provided for @exchangeValidationSelectFromWallet.
  ///
  /// In en, this message translates to:
  /// **'Please select a from wallet'**
  String get exchangeValidationSelectFromWallet;

  /// No description provided for @exchangeValidationSelectToWallet.
  ///
  /// In en, this message translates to:
  /// **'Please select a to wallet'**
  String get exchangeValidationSelectToWallet;

  /// No description provided for @exchangeValidationEnterAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter an amount'**
  String get exchangeValidationEnterAmount;

  /// No description provided for @exchangeValidationAmountMinimum.
  ///
  /// In en, this message translates to:
  /// **'Minimum amount should be {amount} {currency}'**
  String exchangeValidationAmountMinimum(Object amount, Object currency);

  /// No description provided for @exchangeValidationAmountMaximum.
  ///
  /// In en, this message translates to:
  /// **'Maximum amount should be {amount} {currency}'**
  String exchangeValidationAmountMaximum(Object amount, Object currency);

  /// No description provided for @comment_create_gift_controller.
  ///
  /// In en, this message translates to:
  /// **'==== Create Gift Controller ===='**
  String get comment_create_gift_controller;

  /// No description provided for @createGiftValidationSelectWallet.
  ///
  /// In en, this message translates to:
  /// **'Please select a wallet'**
  String get createGiftValidationSelectWallet;

  /// No description provided for @createGiftValidationEnterAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter an amount'**
  String get createGiftValidationEnterAmount;

  /// No description provided for @createGiftValidationAmountMinimum.
  ///
  /// In en, this message translates to:
  /// **'Minimum amount should be {amount} {currency}'**
  String createGiftValidationAmountMinimum(Object amount, Object currency);

  /// No description provided for @createGiftValidationAmountMaximum.
  ///
  /// In en, this message translates to:
  /// **'Maximum amount should be {amount} {currency}'**
  String createGiftValidationAmountMaximum(Object amount, Object currency);

  /// No description provided for @comment_home_controller.
  ///
  /// In en, this message translates to:
  /// **'==== Home Controller ===='**
  String get comment_home_controller;

  /// No description provided for @homeLanguageChangeFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to change language'**
  String get homeLanguageChangeFailed;

  /// No description provided for @homeBiometricDeviceNotSupported.
  ///
  /// In en, this message translates to:
  /// **'This device does not support biometrics.'**
  String get homeBiometricDeviceNotSupported;

  /// No description provided for @homeBiometricAuthenticationFailed.
  ///
  /// In en, this message translates to:
  /// **'Authentication failed. Biometric setting not changed.'**
  String get homeBiometricAuthenticationFailed;

  /// No description provided for @homeBiometricEnabledSuccess.
  ///
  /// In en, this message translates to:
  /// **'Biometric enabled successfully'**
  String get homeBiometricEnabledSuccess;

  /// No description provided for @homeBiometricDisabledSuccess.
  ///
  /// In en, this message translates to:
  /// **'Biometric disabled successfully'**
  String get homeBiometricDisabledSuccess;

  /// No description provided for @homeBiometricNotFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Biometric Not Found'**
  String get homeBiometricNotFoundTitle;

  /// No description provided for @homeBiometricNotFoundDescription.
  ///
  /// In en, this message translates to:
  /// **'No fingerprint or biometric is enrolled on this device. You can set it up from the system settings.'**
  String get homeBiometricNotFoundDescription;

  /// No description provided for @homeBiometricOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Security Settings'**
  String get homeBiometricOpenSettings;

  /// No description provided for @homeIosBiometricSetup.
  ///
  /// In en, this message translates to:
  /// **'Please go to Settings > Face ID & Passcode to set up biometrics.'**
  String get homeIosBiometricSetup;

  /// No description provided for @comment_create_invoice_controller.
  ///
  /// In en, this message translates to:
  /// **'==== Create Invoice Controller ===='**
  String get comment_create_invoice_controller;

  /// No description provided for @createInvoiceValidationEnterInvoiceTo.
  ///
  /// In en, this message translates to:
  /// **'Please enter an invoice to'**
  String get createInvoiceValidationEnterInvoiceTo;

  /// No description provided for @createInvoiceValidationEnterEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Please enter an email address'**
  String get createInvoiceValidationEnterEmailAddress;

  /// No description provided for @createInvoiceValidationEnterAddress.
  ///
  /// In en, this message translates to:
  /// **'Please enter an address'**
  String get createInvoiceValidationEnterAddress;

  /// No description provided for @createInvoiceValidationSelectWallet.
  ///
  /// In en, this message translates to:
  /// **'Please select a wallet'**
  String get createInvoiceValidationSelectWallet;

  /// No description provided for @createInvoiceValidationSelectStatus.
  ///
  /// In en, this message translates to:
  /// **'Please select a status'**
  String get createInvoiceValidationSelectStatus;

  /// No description provided for @createInvoiceValidationSelectIssueDate.
  ///
  /// In en, this message translates to:
  /// **'Please select an issue date'**
  String get createInvoiceValidationSelectIssueDate;

  /// No description provided for @createInvoiceValidationItemNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Item {itemNumber}: Name is required'**
  String createInvoiceValidationItemNameRequired(Object itemNumber);

  /// No description provided for @createInvoiceValidationItemQuantityGreaterThanZero.
  ///
  /// In en, this message translates to:
  /// **'Item {itemNumber}: Quantity must be greater than 0'**
  String createInvoiceValidationItemQuantityGreaterThanZero(Object itemNumber);

  /// No description provided for @createInvoiceValidationItemUnitPriceGreaterThanZero.
  ///
  /// In en, this message translates to:
  /// **'Item {itemNumber}: Unit Price must be greater than 0'**
  String createInvoiceValidationItemUnitPriceGreaterThanZero(Object itemNumber);

  /// No description provided for @comment_make_payment_controller.
  ///
  /// In en, this message translates to:
  /// **'==== Make Payment Controller ===='**
  String get comment_make_payment_controller;

  /// No description provided for @makePaymentValidationSelectWallet.
  ///
  /// In en, this message translates to:
  /// **'Please select a wallet'**
  String get makePaymentValidationSelectWallet;

  /// No description provided for @makePaymentValidationEnterMerchantMid.
  ///
  /// In en, this message translates to:
  /// **'Please enter an merchant mid'**
  String get makePaymentValidationEnterMerchantMid;

  /// No description provided for @makePaymentValidationEnterAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter an amount'**
  String get makePaymentValidationEnterAmount;

  /// No description provided for @makePaymentValidationAmountMinimum.
  ///
  /// In en, this message translates to:
  /// **'Minimum amount should be {amount} {currency}'**
  String makePaymentValidationAmountMinimum(Object amount, Object currency);

  /// No description provided for @makePaymentValidationAmountMaximum.
  ///
  /// In en, this message translates to:
  /// **'Maximum amount should be {amount} {currency}'**
  String makePaymentValidationAmountMaximum(Object amount, Object currency);

  /// No description provided for @comment_request_money_controller.
  ///
  /// In en, this message translates to:
  /// **'==== Request Money Controller ===='**
  String get comment_request_money_controller;

  /// No description provided for @requestMoneyValidationSelectWallet.
  ///
  /// In en, this message translates to:
  /// **'Please select a wallet'**
  String get requestMoneyValidationSelectWallet;

  /// No description provided for @requestMoneyValidationEnterRecipientUid.
  ///
  /// In en, this message translates to:
  /// **'Please enter an recipient uid'**
  String get requestMoneyValidationEnterRecipientUid;

  /// No description provided for @requestMoneyValidationEnterRequestAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter an request amount'**
  String get requestMoneyValidationEnterRequestAmount;

  /// No description provided for @requestMoneyValidationAmountMinimum.
  ///
  /// In en, this message translates to:
  /// **'Minimum amount should be {amount} {currency}'**
  String requestMoneyValidationAmountMinimum(Object amount, Object currency);

  /// No description provided for @requestMoneyValidationAmountMaximum.
  ///
  /// In en, this message translates to:
  /// **'Maximum amount should be {amount} {currency}'**
  String requestMoneyValidationAmountMaximum(Object amount, Object currency);

  /// No description provided for @comment_add_new_ticket_controller.
  ///
  /// In en, this message translates to:
  /// **'==== Add New Ticket Controller ===='**
  String get comment_add_new_ticket_controller;

  /// No description provided for @addNewTicketSuccess.
  ///
  /// In en, this message translates to:
  /// **'Ticket created successfully'**
  String get addNewTicketSuccess;

  /// No description provided for @addNewValidationEnterTitle.
  ///
  /// In en, this message translates to:
  /// **'Please enter a title'**
  String get addNewValidationEnterTitle;

  /// No description provided for @addNewValidationEnterDescription.
  ///
  /// In en, this message translates to:
  /// **'Please enter a description'**
  String get addNewValidationEnterDescription;

  /// No description provided for @comment_change_password_controller.
  ///
  /// In en, this message translates to:
  /// **'==== Change Password Controller ===='**
  String get comment_change_password_controller;

  /// No description provided for @changePasswordValidationEnterCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter an current password'**
  String get changePasswordValidationEnterCurrentPassword;

  /// No description provided for @changePasswordValidationEnterNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter an new password'**
  String get changePasswordValidationEnterNewPassword;

  /// No description provided for @changePasswordValidationPasswordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get changePasswordValidationPasswordMinLength;

  /// No description provided for @changePasswordValidationEnterConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter an confirm password'**
  String get changePasswordValidationEnterConfirmPassword;

  /// No description provided for @changePasswordValidationPasswordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get changePasswordValidationPasswordsDoNotMatch;

  /// No description provided for @comment_transfer_controller.
  ///
  /// In en, this message translates to:
  /// **'==== Transfer Controller ===='**
  String get comment_transfer_controller;

  /// No description provided for @transferValidationSelectWallet.
  ///
  /// In en, this message translates to:
  /// **'Please select a wallet'**
  String get transferValidationSelectWallet;

  /// No description provided for @transferValidationEnterRecipientUid.
  ///
  /// In en, this message translates to:
  /// **'Please enter an recipient uid'**
  String get transferValidationEnterRecipientUid;

  /// No description provided for @transferValidationEnterAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter an amount'**
  String get transferValidationEnterAmount;

  /// No description provided for @transferValidationAmountMinimum.
  ///
  /// In en, this message translates to:
  /// **'Minimum amount should be {amount} {currency}'**
  String transferValidationAmountMinimum(Object amount, Object currency);

  /// No description provided for @transferValidationAmountMaximum.
  ///
  /// In en, this message translates to:
  /// **'Maximum amount should be {amount} {currency}'**
  String transferValidationAmountMaximum(Object amount, Object currency);

  /// No description provided for @comment_create_withdraw_account_controller.
  ///
  /// In en, this message translates to:
  /// **'==== Create Withdraw Account Controller ===='**
  String get comment_create_withdraw_account_controller;

  /// No description provided for @createWithdrawAccountFileRequiredError.
  ///
  /// In en, this message translates to:
  /// **'File required for {fieldName}'**
  String createWithdrawAccountFileRequiredError(Object fieldName);

  /// No description provided for @createWithdrawAccountFieldRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Field {fieldName} is required'**
  String createWithdrawAccountFieldRequiredError(Object fieldName);

  /// No description provided for @createWithdrawAccountValidationSelectWallet.
  ///
  /// In en, this message translates to:
  /// **'Please select a wallet'**
  String get createWithdrawAccountValidationSelectWallet;

  /// No description provided for @createWithdrawAccountValidationSelectWithdrawMethod.
  ///
  /// In en, this message translates to:
  /// **'Please select a withdraw method'**
  String get createWithdrawAccountValidationSelectWithdrawMethod;

  /// No description provided for @createWithdrawAccountValidationEnterMethodName.
  ///
  /// In en, this message translates to:
  /// **'Please enter an method name'**
  String get createWithdrawAccountValidationEnterMethodName;

  /// No description provided for @createWithdrawAccountValidationUploadFile.
  ///
  /// In en, this message translates to:
  /// **'Please upload a file for {fieldName}'**
  String createWithdrawAccountValidationUploadFile(Object fieldName);

  /// No description provided for @createWithdrawAccountValidationFillField.
  ///
  /// In en, this message translates to:
  /// **'Please fill in the {fieldName} field'**
  String createWithdrawAccountValidationFillField(Object fieldName);

  /// No description provided for @comment_withdraw_controller.
  ///
  /// In en, this message translates to:
  /// **'==== Withdraw Controller ===='**
  String get comment_withdraw_controller;

  /// No description provided for @withdrawValidationSelectWithdrawAccount.
  ///
  /// In en, this message translates to:
  /// **'Please select a withdraw account'**
  String get withdrawValidationSelectWithdrawAccount;

  /// No description provided for @withdrawValidationEnterAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter an amount'**
  String get withdrawValidationEnterAmount;

  /// No description provided for @withdrawValidationAmountMinimum.
  ///
  /// In en, this message translates to:
  /// **'Minimum amount should be {amount} {currency}'**
  String withdrawValidationAmountMinimum(Object amount, Object currency);

  /// No description provided for @withdrawValidationAmountMaximum.
  ///
  /// In en, this message translates to:
  /// **'Maximum amount should be {amount} {currency}'**
  String withdrawValidationAmountMaximum(Object amount, Object currency);

  /// No description provided for @comment_airtime_controller.
  ///
  /// In en, this message translates to:
  /// **'==== Airtime Controller ===='**
  String get comment_airtime_controller;

  /// No description provided for @airtimeCountryRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select a Country'**
  String get airtimeCountryRequired;

  /// No description provided for @airtimeServiceRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select a service'**
  String get airtimeServiceRequired;

  /// No description provided for @airtimeAmountRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter an amount'**
  String get airtimeAmountRequired;

  /// No description provided for @airtimeAmountValid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount'**
  String get airtimeAmountValid;

  /// No description provided for @airtimeDynamicFieldRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter {fieldName}'**
  String airtimeDynamicFieldRequired(Object fieldName);

  /// No description provided for @comment_cable_controller.
  ///
  /// In en, this message translates to:
  /// **'==== Cable Controller ===='**
  String get comment_cable_controller;

  /// No description provided for @cableCountryRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select a Country'**
  String get cableCountryRequired;

  /// No description provided for @cableServiceRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select a service'**
  String get cableServiceRequired;

  /// No description provided for @cableAmountRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter an amount'**
  String get cableAmountRequired;

  /// No description provided for @cableAmountValid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount'**
  String get cableAmountValid;

  /// No description provided for @cableDynamicFieldRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter {fieldName}'**
  String cableDynamicFieldRequired(Object fieldName);

  /// No description provided for @comment_toll_controller.
  ///
  /// In en, this message translates to:
  /// **'==== Toll Controller ===='**
  String get comment_toll_controller;

  /// No description provided for @tollCountryRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select a Country'**
  String get tollCountryRequired;

  /// No description provided for @tollServiceRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select a service'**
  String get tollServiceRequired;

  /// No description provided for @tollAmountRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter an amount'**
  String get tollAmountRequired;

  /// No description provided for @tollAmountValid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount'**
  String get tollAmountValid;

  /// No description provided for @tollDynamicFieldRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter {fieldName}'**
  String tollDynamicFieldRequired(Object fieldName);

  /// No description provided for @comment_electricity_controller.
  ///
  /// In en, this message translates to:
  /// **'==== Electricity Controller ===='**
  String get comment_electricity_controller;

  /// No description provided for @electricityCountryRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select a Country'**
  String get electricityCountryRequired;

  /// No description provided for @electricityServiceRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select a service'**
  String get electricityServiceRequired;

  /// No description provided for @electricityAmountRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter an amount'**
  String get electricityAmountRequired;

  /// No description provided for @electricityAmountValid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount'**
  String get electricityAmountValid;

  /// No description provided for @electricityDynamicFieldRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter {fieldName}'**
  String electricityDynamicFieldRequired(Object fieldName);

  /// No description provided for @comment_internet_controller.
  ///
  /// In en, this message translates to:
  /// **'==== Internet Controller ===='**
  String get comment_internet_controller;

  /// No description provided for @internetCountryRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select a Country'**
  String get internetCountryRequired;

  /// No description provided for @internetServiceRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select a service'**
  String get internetServiceRequired;

  /// No description provided for @internetAmountRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter an amount'**
  String get internetAmountRequired;

  /// No description provided for @internetAmountValid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount'**
  String get internetAmountValid;

  /// No description provided for @internetDynamicFieldRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter {fieldName}'**
  String internetDynamicFieldRequired(Object fieldName);

  /// No description provided for @comment_data_bundle_controller.
  ///
  /// In en, this message translates to:
  /// **'==== Data Bundle Controller ===='**
  String get comment_data_bundle_controller;

  /// No description provided for @dataBundleCountryRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select a Country'**
  String get dataBundleCountryRequired;

  /// No description provided for @dataBundleServiceRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select a service'**
  String get dataBundleServiceRequired;

  /// No description provided for @dataBundleAmountRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter an amount'**
  String get dataBundleAmountRequired;

  /// No description provided for @dataBundleAmountValid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount'**
  String get dataBundleAmountValid;

  /// No description provided for @dataBundleDynamicFieldRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter {fieldName}'**
  String dataBundleDynamicFieldRequired(Object fieldName);

  /// No description provided for @comment_airtime_screen.
  ///
  /// In en, this message translates to:
  /// **'==== Airtime Screen ===='**
  String get comment_airtime_screen;

  /// No description provided for @airtimeAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Airtime'**
  String get airtimeAppBarTitle;

  /// No description provided for @comment_airtime_amount_section.
  ///
  /// In en, this message translates to:
  /// **'==== Airtime Amount Step Section ===='**
  String get comment_airtime_amount_section;

  /// No description provided for @airtimeCountryLabel.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get airtimeCountryLabel;

  /// No description provided for @airtimeCountryHint.
  ///
  /// In en, this message translates to:
  /// **'Select Country'**
  String get airtimeCountryHint;

  /// No description provided for @airtimeCountrySelectTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Country'**
  String get airtimeCountrySelectTitle;

  /// No description provided for @airtimeCountryNotFound.
  ///
  /// In en, this message translates to:
  /// **'Country Not Found'**
  String get airtimeCountryNotFound;

  /// No description provided for @airtimeServiceLabel.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get airtimeServiceLabel;

  /// No description provided for @airtimeServiceHint.
  ///
  /// In en, this message translates to:
  /// **'Select Service'**
  String get airtimeServiceHint;

  /// No description provided for @airtimeServiceSelectTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Service'**
  String get airtimeServiceSelectTitle;

  /// No description provided for @airtimeServiceNotFound.
  ///
  /// In en, this message translates to:
  /// **'Service Not Found'**
  String get airtimeServiceNotFound;

  /// No description provided for @airtimeAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get airtimeAmountLabel;

  /// No description provided for @airtimePayButton.
  ///
  /// In en, this message translates to:
  /// **'Pay Now'**
  String get airtimePayButton;

  /// No description provided for @comment_airtime_review_section.
  ///
  /// In en, this message translates to:
  /// **'==== Airtime Review Step Section ===='**
  String get comment_airtime_review_section;

  /// No description provided for @airtimeReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Review Details'**
  String get airtimeReviewTitle;

  /// No description provided for @airtimeReviewAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get airtimeReviewAmountLabel;

  /// No description provided for @airtimeReviewChargeLabel.
  ///
  /// In en, this message translates to:
  /// **'Charge'**
  String get airtimeReviewChargeLabel;

  /// No description provided for @airtimeReviewConversionRateLabel.
  ///
  /// In en, this message translates to:
  /// **'Conversion Rate'**
  String get airtimeReviewConversionRateLabel;

  /// No description provided for @airtimeReviewPayableAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Payable Amount'**
  String get airtimeReviewPayableAmountLabel;

  /// No description provided for @airtimeReviewBackButton.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get airtimeReviewBackButton;

  /// No description provided for @airtimeReviewConfirmButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get airtimeReviewConfirmButton;

  /// No description provided for @comment_bill_payment_history.
  ///
  /// In en, this message translates to:
  /// **'==== Bill Payment History ===='**
  String get comment_bill_payment_history;

  /// No description provided for @billPaymentHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Bill Payment History'**
  String get billPaymentHistoryTitle;

  /// No description provided for @comment_bill_payment_details.
  ///
  /// In en, this message translates to:
  /// **'==== Bill Payment Details Sheet ===='**
  String get comment_bill_payment_details;

  /// No description provided for @billPaymentDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Bill Payment Details'**
  String get billPaymentDetailsTitle;

  /// No description provided for @billPaymentDetailsTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get billPaymentDetailsTime;

  /// No description provided for @billPaymentDetailsAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get billPaymentDetailsAmount;

  /// No description provided for @billPaymentDetailsCharge.
  ///
  /// In en, this message translates to:
  /// **'Charge'**
  String get billPaymentDetailsCharge;

  /// No description provided for @billPaymentDetailsMethod.
  ///
  /// In en, this message translates to:
  /// **'Method'**
  String get billPaymentDetailsMethod;

  /// No description provided for @billPaymentDetailsStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get billPaymentDetailsStatus;

  /// No description provided for @comment_cable_screen.
  ///
  /// In en, this message translates to:
  /// **'==== Cable Screen ===='**
  String get comment_cable_screen;

  /// No description provided for @cableTitle.
  ///
  /// In en, this message translates to:
  /// **'Cable'**
  String get cableTitle;

  /// No description provided for @comment_cable_amount_section.
  ///
  /// In en, this message translates to:
  /// **'==== Cable Amount Step Section ===='**
  String get comment_cable_amount_section;

  /// No description provided for @cableCountryLabel.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get cableCountryLabel;

  /// No description provided for @cableCountryHint.
  ///
  /// In en, this message translates to:
  /// **'Select Country'**
  String get cableCountryHint;

  /// No description provided for @cableCountrySelectTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Country'**
  String get cableCountrySelectTitle;

  /// No description provided for @cableCountryNotFound.
  ///
  /// In en, this message translates to:
  /// **'Country Not Found'**
  String get cableCountryNotFound;

  /// No description provided for @cableServiceLabel.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get cableServiceLabel;

  /// No description provided for @cableServiceHint.
  ///
  /// In en, this message translates to:
  /// **'Select Service'**
  String get cableServiceHint;

  /// No description provided for @cableServiceSelectTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Service'**
  String get cableServiceSelectTitle;

  /// No description provided for @cableServiceNotFound.
  ///
  /// In en, this message translates to:
  /// **'Service Not Found'**
  String get cableServiceNotFound;

  /// No description provided for @cableAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get cableAmountLabel;

  /// No description provided for @cablePayButton.
  ///
  /// In en, this message translates to:
  /// **'Pay Now'**
  String get cablePayButton;

  /// No description provided for @comment_cable_review_section.
  ///
  /// In en, this message translates to:
  /// **'==== Cable Review Step Section ===='**
  String get comment_cable_review_section;

  /// No description provided for @cableReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Review Details'**
  String get cableReviewTitle;

  /// No description provided for @cableReviewAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get cableReviewAmountLabel;

  /// No description provided for @cableReviewChargeLabel.
  ///
  /// In en, this message translates to:
  /// **'Charge'**
  String get cableReviewChargeLabel;

  /// No description provided for @cableReviewConversionRateLabel.
  ///
  /// In en, this message translates to:
  /// **'Conversion Rate'**
  String get cableReviewConversionRateLabel;

  /// No description provided for @cableReviewPayableAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Payable Amount'**
  String get cableReviewPayableAmountLabel;

  /// No description provided for @cableReviewBackButton.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get cableReviewBackButton;

  /// No description provided for @cableReviewConfirmButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get cableReviewConfirmButton;

  /// No description provided for @comment_toll_screen.
  ///
  /// In en, this message translates to:
  /// **'==== Toll Screen ===='**
  String get comment_toll_screen;

  /// No description provided for @tollTitle.
  ///
  /// In en, this message translates to:
  /// **'Toll'**
  String get tollTitle;

  /// No description provided for @comment_toll_amount_section.
  ///
  /// In en, this message translates to:
  /// **'==== Toll Amount Step Section ===='**
  String get comment_toll_amount_section;

  /// No description provided for @tollCountryLabel.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get tollCountryLabel;

  /// No description provided for @tollCountryHint.
  ///
  /// In en, this message translates to:
  /// **'Select Country'**
  String get tollCountryHint;

  /// No description provided for @tollCountrySelectTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Country'**
  String get tollCountrySelectTitle;

  /// No description provided for @tollCountryNotFound.
  ///
  /// In en, this message translates to:
  /// **'Country Not Found'**
  String get tollCountryNotFound;

  /// No description provided for @tollServiceLabel.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get tollServiceLabel;

  /// No description provided for @tollServiceHint.
  ///
  /// In en, this message translates to:
  /// **'Select Service'**
  String get tollServiceHint;

  /// No description provided for @tollServiceSelectTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Service'**
  String get tollServiceSelectTitle;

  /// No description provided for @tollServiceNotFound.
  ///
  /// In en, this message translates to:
  /// **'Service Not Found'**
  String get tollServiceNotFound;

  /// No description provided for @tollAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get tollAmountLabel;

  /// No description provided for @tollPayButton.
  ///
  /// In en, this message translates to:
  /// **'Pay Now'**
  String get tollPayButton;

  /// No description provided for @comment_toll_review_section.
  ///
  /// In en, this message translates to:
  /// **'==== Toll Review Step Section ===='**
  String get comment_toll_review_section;

  /// No description provided for @tollReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Review Details'**
  String get tollReviewTitle;

  /// No description provided for @tollReviewAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get tollReviewAmountLabel;

  /// No description provided for @tollReviewChargeLabel.
  ///
  /// In en, this message translates to:
  /// **'Charge'**
  String get tollReviewChargeLabel;

  /// No description provided for @tollReviewConversionRateLabel.
  ///
  /// In en, this message translates to:
  /// **'Conversion Rate'**
  String get tollReviewConversionRateLabel;

  /// No description provided for @tollReviewPayableAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Payable Amount'**
  String get tollReviewPayableAmountLabel;

  /// No description provided for @tollReviewBackButton.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get tollReviewBackButton;

  /// No description provided for @tollReviewConfirmButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get tollReviewConfirmButton;

  /// No description provided for @comment_electricity_screen.
  ///
  /// In en, this message translates to:
  /// **'==== Electricity Screen ===='**
  String get comment_electricity_screen;

  /// No description provided for @electricityTitle.
  ///
  /// In en, this message translates to:
  /// **'Electricity'**
  String get electricityTitle;

  /// No description provided for @comment_electricity_amount_section.
  ///
  /// In en, this message translates to:
  /// **'==== Electricity Amount Step Section ===='**
  String get comment_electricity_amount_section;

  /// No description provided for @electricityCountryLabel.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get electricityCountryLabel;

  /// No description provided for @electricityCountryHint.
  ///
  /// In en, this message translates to:
  /// **'Select Country'**
  String get electricityCountryHint;

  /// No description provided for @electricityCountrySelectTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Country'**
  String get electricityCountrySelectTitle;

  /// No description provided for @electricityCountryNotFound.
  ///
  /// In en, this message translates to:
  /// **'Country Not Found'**
  String get electricityCountryNotFound;

  /// No description provided for @electricityServiceLabel.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get electricityServiceLabel;

  /// No description provided for @electricityServiceHint.
  ///
  /// In en, this message translates to:
  /// **'Select Service'**
  String get electricityServiceHint;

  /// No description provided for @electricityServiceSelectTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Service'**
  String get electricityServiceSelectTitle;

  /// No description provided for @electricityServiceNotFound.
  ///
  /// In en, this message translates to:
  /// **'Service Not Found'**
  String get electricityServiceNotFound;

  /// No description provided for @electricityAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get electricityAmountLabel;

  /// No description provided for @electricityPayButton.
  ///
  /// In en, this message translates to:
  /// **'Pay Now'**
  String get electricityPayButton;

  /// No description provided for @comment_electricity_review_section.
  ///
  /// In en, this message translates to:
  /// **'==== Electricity Review Step Section ===='**
  String get comment_electricity_review_section;

  /// No description provided for @electricityReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Review Details'**
  String get electricityReviewTitle;

  /// No description provided for @electricityReviewAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get electricityReviewAmountLabel;

  /// No description provided for @electricityReviewChargeLabel.
  ///
  /// In en, this message translates to:
  /// **'Charge'**
  String get electricityReviewChargeLabel;

  /// No description provided for @electricityReviewConversionRateLabel.
  ///
  /// In en, this message translates to:
  /// **'Conversion Rate'**
  String get electricityReviewConversionRateLabel;

  /// No description provided for @electricityReviewPayableAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Payable Amount'**
  String get electricityReviewPayableAmountLabel;

  /// No description provided for @electricityReviewBackButton.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get electricityReviewBackButton;

  /// No description provided for @electricityReviewConfirmButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get electricityReviewConfirmButton;

  /// No description provided for @comment_internet_screen.
  ///
  /// In en, this message translates to:
  /// **'==== Internet Screen ===='**
  String get comment_internet_screen;

  /// No description provided for @internetTitle.
  ///
  /// In en, this message translates to:
  /// **'Internet'**
  String get internetTitle;

  /// No description provided for @comment_internet_amount_section.
  ///
  /// In en, this message translates to:
  /// **'==== Internet Amount Step Section ===='**
  String get comment_internet_amount_section;

  /// No description provided for @internetCountryLabel.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get internetCountryLabel;

  /// No description provided for @internetCountryHint.
  ///
  /// In en, this message translates to:
  /// **'Select Country'**
  String get internetCountryHint;

  /// No description provided for @internetCountrySelectTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Country'**
  String get internetCountrySelectTitle;

  /// No description provided for @internetCountryNotFound.
  ///
  /// In en, this message translates to:
  /// **'Country Not Found'**
  String get internetCountryNotFound;

  /// No description provided for @internetServiceLabel.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get internetServiceLabel;

  /// No description provided for @internetServiceHint.
  ///
  /// In en, this message translates to:
  /// **'Select Service'**
  String get internetServiceHint;

  /// No description provided for @internetServiceSelectTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Service'**
  String get internetServiceSelectTitle;

  /// No description provided for @internetServiceNotFound.
  ///
  /// In en, this message translates to:
  /// **'Service Not Found'**
  String get internetServiceNotFound;

  /// No description provided for @internetAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get internetAmountLabel;

  /// No description provided for @internetPayButton.
  ///
  /// In en, this message translates to:
  /// **'Pay Now'**
  String get internetPayButton;

  /// No description provided for @comment_internet_review_section.
  ///
  /// In en, this message translates to:
  /// **'==== Internet Review Step Section ===='**
  String get comment_internet_review_section;

  /// No description provided for @internetReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Review Details'**
  String get internetReviewTitle;

  /// No description provided for @internetReviewAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get internetReviewAmountLabel;

  /// No description provided for @internetReviewChargeLabel.
  ///
  /// In en, this message translates to:
  /// **'Charge'**
  String get internetReviewChargeLabel;

  /// No description provided for @internetReviewConversionRateLabel.
  ///
  /// In en, this message translates to:
  /// **'Conversion Rate'**
  String get internetReviewConversionRateLabel;

  /// No description provided for @internetReviewPayableAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Payable Amount'**
  String get internetReviewPayableAmountLabel;

  /// No description provided for @internetReviewBackButton.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get internetReviewBackButton;

  /// No description provided for @internetReviewConfirmButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get internetReviewConfirmButton;

  /// No description provided for @comment_data_bundle_screen.
  ///
  /// In en, this message translates to:
  /// **'==== Data Bundle Screen ===='**
  String get comment_data_bundle_screen;

  /// No description provided for @dataBundleTitle.
  ///
  /// In en, this message translates to:
  /// **'Data Bundle'**
  String get dataBundleTitle;

  /// No description provided for @comment_data_bundle_amount_section.
  ///
  /// In en, this message translates to:
  /// **'==== Data Bundle Amount Step Section ===='**
  String get comment_data_bundle_amount_section;

  /// No description provided for @dataBundleCountryLabel.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get dataBundleCountryLabel;

  /// No description provided for @dataBundleCountryHint.
  ///
  /// In en, this message translates to:
  /// **'Select Country'**
  String get dataBundleCountryHint;

  /// No description provided for @dataBundleCountrySelectTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Country'**
  String get dataBundleCountrySelectTitle;

  /// No description provided for @dataBundleCountryNotFound.
  ///
  /// In en, this message translates to:
  /// **'Country Not Found'**
  String get dataBundleCountryNotFound;

  /// No description provided for @dataBundleServiceLabel.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get dataBundleServiceLabel;

  /// No description provided for @dataBundleServiceHint.
  ///
  /// In en, this message translates to:
  /// **'Select Service'**
  String get dataBundleServiceHint;

  /// No description provided for @dataBundleServiceSelectTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Service'**
  String get dataBundleServiceSelectTitle;

  /// No description provided for @dataBundleServiceNotFound.
  ///
  /// In en, this message translates to:
  /// **'Service Not Found'**
  String get dataBundleServiceNotFound;

  /// No description provided for @dataBundleAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get dataBundleAmountLabel;

  /// No description provided for @dataBundlePayButton.
  ///
  /// In en, this message translates to:
  /// **'Pay Now'**
  String get dataBundlePayButton;

  /// No description provided for @comment_data_bundle_review_section.
  ///
  /// In en, this message translates to:
  /// **'==== Data Bundle Review Step Section ===='**
  String get comment_data_bundle_review_section;

  /// No description provided for @dataBundleReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Review Details'**
  String get dataBundleReviewTitle;

  /// No description provided for @dataBundleReviewAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get dataBundleReviewAmountLabel;

  /// No description provided for @dataBundleReviewChargeLabel.
  ///
  /// In en, this message translates to:
  /// **'Charge'**
  String get dataBundleReviewChargeLabel;

  /// No description provided for @dataBundleReviewConversionRateLabel.
  ///
  /// In en, this message translates to:
  /// **'Conversion Rate'**
  String get dataBundleReviewConversionRateLabel;

  /// No description provided for @dataBundleReviewPayableAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Payable Amount'**
  String get dataBundleReviewPayableAmountLabel;

  /// No description provided for @dataBundleReviewBackButton.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get dataBundleReviewBackButton;

  /// No description provided for @dataBundleReviewConfirmButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get dataBundleReviewConfirmButton;

  /// No description provided for @comment_bill_payment_screen.
  ///
  /// In en, this message translates to:
  /// **'==== Bill Payment Main Screen ===='**
  String get comment_bill_payment_screen;

  /// No description provided for @billPaymentScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Bill Payments'**
  String get billPaymentScreenTitle;

  /// No description provided for @billPaymentAirtime.
  ///
  /// In en, this message translates to:
  /// **'Airtime'**
  String get billPaymentAirtime;

  /// No description provided for @billPaymentElectricity.
  ///
  /// In en, this message translates to:
  /// **'Electricity'**
  String get billPaymentElectricity;

  /// No description provided for @billPaymentInternet.
  ///
  /// In en, this message translates to:
  /// **'Internet'**
  String get billPaymentInternet;

  /// No description provided for @billPaymentDataBundle.
  ///
  /// In en, this message translates to:
  /// **'Data Bundle'**
  String get billPaymentDataBundle;

  /// No description provided for @billPaymentCables.
  ///
  /// In en, this message translates to:
  /// **'Cables'**
  String get billPaymentCables;

  /// No description provided for @billPaymentToll.
  ///
  /// In en, this message translates to:
  /// **'Toll'**
  String get billPaymentToll;

  /// No description provided for @comment_create_virtual_card_controller.
  ///
  /// In en, this message translates to:
  /// **'==== Create Virtual Card Controller ===='**
  String get comment_create_virtual_card_controller;

  /// No description provided for @createCardProviderRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select card provider'**
  String get createCardProviderRequired;

  /// No description provided for @createCardHolderRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select card holder'**
  String get createCardHolderRequired;

  /// No description provided for @createNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter name'**
  String get createNameRequired;

  /// No description provided for @createEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter email'**
  String get createEmailRequired;

  /// No description provided for @createEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get createEmailInvalid;

  /// No description provided for @createPhoneNumberRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter phone number'**
  String get createPhoneNumberRequired;

  /// No description provided for @createCountryRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select country'**
  String get createCountryRequired;

  /// No description provided for @createCityRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter city'**
  String get createCityRequired;

  /// No description provided for @createStateRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter state'**
  String get createStateRequired;

  /// No description provided for @createPostalCodeRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter postal code'**
  String get createPostalCodeRequired;

  /// No description provided for @createAddressRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter address'**
  String get createAddressRequired;

  /// No description provided for @comment_virtual_card_details_controller.
  ///
  /// In en, this message translates to:
  /// **'==== Virtual Card Details Controller ===='**
  String get comment_virtual_card_details_controller;

  /// No description provided for @cardDetailsEnterAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter an amount'**
  String get cardDetailsEnterAmount;

  /// No description provided for @cardDetailsAmountGreaterThanZero.
  ///
  /// In en, this message translates to:
  /// **'Amount must be greater than 0'**
  String get cardDetailsAmountGreaterThanZero;

  /// No description provided for @cardDetailsAmountMinimumLimit.
  ///
  /// In en, this message translates to:
  /// **'Amount must not exceed {amount}'**
  String cardDetailsAmountMinimumLimit(Object amount);

  /// No description provided for @cardDetailsAmountMaximumLimit.
  ///
  /// In en, this message translates to:
  /// **'Amount must not exceed {amount}'**
  String cardDetailsAmountMaximumLimit(Object amount);

  /// No description provided for @comment_card_holder_tab_section.
  ///
  /// In en, this message translates to:
  /// **'==== Card Holder Tab Section ===='**
  String get comment_card_holder_tab_section;

  /// No description provided for @cardHolderTabExistingCardholders.
  ///
  /// In en, this message translates to:
  /// **'Existing Cardholders'**
  String get cardHolderTabExistingCardholders;

  /// No description provided for @cardHolderTabCreateCardholder.
  ///
  /// In en, this message translates to:
  /// **'Create Cardholder'**
  String get cardHolderTabCreateCardholder;

  /// No description provided for @comment_choose_card_holder_section.
  ///
  /// In en, this message translates to:
  /// **'==== Choose Card Holder Section ===='**
  String get comment_choose_card_holder_section;

  /// No description provided for @chooseCardHolderLabel.
  ///
  /// In en, this message translates to:
  /// **'Card Holder'**
  String get chooseCardHolderLabel;

  /// No description provided for @chooseCardHolderDropdownNotFound.
  ///
  /// In en, this message translates to:
  /// **'Card holder not found'**
  String get chooseCardHolderDropdownNotFound;

  /// No description provided for @chooseCardHolderDropdownTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Card Holder'**
  String get chooseCardHolderDropdownTitle;

  /// No description provided for @chooseCardHolderButtonCreate.
  ///
  /// In en, this message translates to:
  /// **'Create Now'**
  String get chooseCardHolderButtonCreate;

  /// No description provided for @comment_choose_card_provider_section.
  ///
  /// In en, this message translates to:
  /// **'==== Choose Card Provider Section ===='**
  String get comment_choose_card_provider_section;

  /// No description provided for @chooseCardProviderLabel.
  ///
  /// In en, this message translates to:
  /// **'Card Provider'**
  String get chooseCardProviderLabel;

  /// No description provided for @chooseCardProviderDropdownNotFound.
  ///
  /// In en, this message translates to:
  /// **'Card provider not found'**
  String get chooseCardProviderDropdownNotFound;

  /// No description provided for @chooseCardProviderDropdownTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Card Provider'**
  String get chooseCardProviderDropdownTitle;

  /// No description provided for @comment_create_new_card_holder_section.
  ///
  /// In en, this message translates to:
  /// **'==== Create New Card Holder Section ===='**
  String get comment_create_new_card_holder_section;

  /// No description provided for @createCardHolderLabelName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get createCardHolderLabelName;

  /// No description provided for @createCardHolderLabelEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get createCardHolderLabelEmail;

  /// No description provided for @createCardHolderLabelPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get createCardHolderLabelPhoneNumber;

  /// No description provided for @createCardHolderLabelCountry.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get createCardHolderLabelCountry;

  /// No description provided for @createCardHolderDropdownCountryNotFound.
  ///
  /// In en, this message translates to:
  /// **'Country not found'**
  String get createCardHolderDropdownCountryNotFound;

  /// No description provided for @createCardHolderDropdownCountryTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Country'**
  String get createCardHolderDropdownCountryTitle;

  /// No description provided for @createCardHolderLabelCity.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get createCardHolderLabelCity;

  /// No description provided for @createCardHolderLabelState.
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get createCardHolderLabelState;

  /// No description provided for @createCardHolderLabelPostalCode.
  ///
  /// In en, this message translates to:
  /// **'Postal Code'**
  String get createCardHolderLabelPostalCode;

  /// No description provided for @createCardHolderLabelAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get createCardHolderLabelAddress;

  /// No description provided for @createCardHolderButtonCreate.
  ///
  /// In en, this message translates to:
  /// **'Create Now'**
  String get createCardHolderButtonCreate;

  /// No description provided for @comment_create_virtual_card_screen.
  ///
  /// In en, this message translates to:
  /// **'==== Create Virtual Card Screen ===='**
  String get comment_create_virtual_card_screen;

  /// No description provided for @createVirtualCardAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Create New Card'**
  String get createVirtualCardAppBarTitle;

  /// No description provided for @comment_get_card_info_screen.
  ///
  /// In en, this message translates to:
  /// **'==== Get Card Info Screen ===='**
  String get comment_get_card_info_screen;

  /// No description provided for @getCardInfoAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Get Card'**
  String get getCardInfoAppBarTitle;

  /// No description provided for @getCardInfoBenefitsTitle.
  ///
  /// In en, this message translates to:
  /// **'Benefits of virtual cards'**
  String get getCardInfoBenefitsTitle;

  /// No description provided for @getCardInfoBenefitSecurityTitle.
  ///
  /// In en, this message translates to:
  /// **'Better Security'**
  String get getCardInfoBenefitSecurityTitle;

  /// No description provided for @getCardInfoBenefitSecuritySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your real card number stays hidden'**
  String get getCardInfoBenefitSecuritySubtitle;

  /// No description provided for @getCardInfoBenefitShoppingTitle.
  ///
  /// In en, this message translates to:
  /// **'Safe Online Shopping'**
  String get getCardInfoBenefitShoppingTitle;

  /// No description provided for @getCardInfoBenefitShoppingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create virtual cards only for online purchases'**
  String get getCardInfoBenefitShoppingSubtitle;

  /// No description provided for @getCardInfoBenefitActivationTitle.
  ///
  /// In en, this message translates to:
  /// **'Fast & Easy Activation'**
  String get getCardInfoBenefitActivationTitle;

  /// No description provided for @getCardInfoBenefitActivationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'No physical delivery needed'**
  String get getCardInfoBenefitActivationSubtitle;

  /// No description provided for @getCardInfoButtonContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get getCardInfoButtonContinue;

  /// No description provided for @comment_card_details_info.
  ///
  /// In en, this message translates to:
  /// **'==== Card Details Info ===='**
  String get comment_card_details_info;

  /// No description provided for @cardDetailsInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Card Details'**
  String get cardDetailsInfoTitle;

  /// No description provided for @cardDetailsCardTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Card Type'**
  String get cardDetailsCardTypeLabel;

  /// No description provided for @cardDetailsCardTypeValue.
  ///
  /// In en, this message translates to:
  /// **'Virtual'**
  String get cardDetailsCardTypeValue;

  /// No description provided for @cardDetailsBillingAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Billing Address'**
  String get cardDetailsBillingAddressLabel;

  /// No description provided for @cardDetailsCardCurrencyLabel.
  ///
  /// In en, this message translates to:
  /// **'Card Currency'**
  String get cardDetailsCardCurrencyLabel;

  /// No description provided for @bsicardsCardDetailsCurrencyValue.
  ///
  /// In en, this message translates to:
  /// **'USD'**
  String get bsicardsCardDetailsCurrencyValue;

  /// No description provided for @cardDetailsCardCreatedLabel.
  ///
  /// In en, this message translates to:
  /// **'Card Created'**
  String get cardDetailsCardCreatedLabel;

  /// No description provided for @cardDetailsStatusButtonActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get cardDetailsStatusButtonActive;

  /// No description provided for @cardDetailsStatusButtonInactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get cardDetailsStatusButtonInactive;

  /// No description provided for @comment_card_top_up_bottom_sheet.
  ///
  /// In en, this message translates to:
  /// **'==== Card Top Up Bottom Sheet ===='**
  String get comment_card_top_up_bottom_sheet;

  /// No description provided for @cardTopUpTitle.
  ///
  /// In en, this message translates to:
  /// **'Card Balance Top Up'**
  String get cardTopUpTitle;

  /// No description provided for @cardTopUpMainWalletBalance.
  ///
  /// In en, this message translates to:
  /// **'Main Wallet Balance'**
  String get cardTopUpMainWalletBalance;

  /// No description provided for @cardTopUpLabelAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get cardTopUpLabelAmount;

  /// No description provided for @cardTopUpAmountLimits.
  ///
  /// In en, this message translates to:
  /// **'Minimum {min} {currency} Maximum {max} {currency}'**
  String cardTopUpAmountLimits(Object currency, Object max, Object min);

  /// No description provided for @cardTopUpReviewTopupAmount.
  ///
  /// In en, this message translates to:
  /// **'Topup Amount'**
  String get cardTopUpReviewTopupAmount;

  /// No description provided for @cardTopUpReviewTopupCharge.
  ///
  /// In en, this message translates to:
  /// **'Topup Charge'**
  String get cardTopUpReviewTopupCharge;

  /// No description provided for @cardTopUpReviewTotalTopupBalance.
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get cardTopUpReviewTotalTopupBalance;

  /// No description provided for @cardTopUpButtonTopupNow.
  ///
  /// In en, this message translates to:
  /// **'Topup Now'**
  String get cardTopUpButtonTopupNow;

  /// No description provided for @bsicardsTopUpInfoMessage.
  ///
  /// In en, this message translates to:
  /// **'Please send your funds to the provided crypto address. Once your transaction is confirmed, the balance will be added to your card.'**
  String get bsicardsTopUpInfoMessage;

  /// No description provided for @bsicardsTopUpCopyButton.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get bsicardsTopUpCopyButton;

  /// No description provided for @bsicardsTopUpCopySuccess.
  ///
  /// In en, this message translates to:
  /// **'Address copied'**
  String get bsicardsTopUpCopySuccess;

  /// No description provided for @comment_virtual_card_display.
  ///
  /// In en, this message translates to:
  /// **'==== Virtual Card Display ===='**
  String get comment_virtual_card_display;

  /// No description provided for @virtualCardExpiryDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Expiry Date'**
  String get virtualCardExpiryDateLabel;

  /// No description provided for @virtualCardCvcLabel.
  ///
  /// In en, this message translates to:
  /// **'CVC'**
  String get virtualCardCvcLabel;

  /// No description provided for @comment_virtual_card_details_screen.
  ///
  /// In en, this message translates to:
  /// **'==== Virtual Card Details Screen ===='**
  String get comment_virtual_card_details_screen;

  /// No description provided for @virtualCardDetailsAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Virtual Card Details'**
  String get virtualCardDetailsAppBarTitle;

  /// No description provided for @virtualCardDetailsFloatingButton.
  ///
  /// In en, this message translates to:
  /// **'Add Balance'**
  String get virtualCardDetailsFloatingButton;

  /// No description provided for @comment_virtual_card_transaction_screen.
  ///
  /// In en, this message translates to:
  /// **'==== Virtual Card Transaction Screen ===='**
  String get comment_virtual_card_transaction_screen;

  /// No description provided for @virtualCardTransactionAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Card Transactions'**
  String get virtualCardTransactionAppBarTitle;

  /// No description provided for @virtualCardTransactionSyncButton.
  ///
  /// In en, this message translates to:
  /// **'Sync'**
  String get virtualCardTransactionSyncButton;

  /// No description provided for @comment_virtual_card_screen.
  ///
  /// In en, this message translates to:
  /// **'==== Virtual Card Screen ===='**
  String get comment_virtual_card_screen;

  /// No description provided for @virtualCardScreenAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Virtual Cards'**
  String get virtualCardScreenAppBarTitle;

  /// No description provided for @virtualCardCardExpiryDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Expiry Date'**
  String get virtualCardCardExpiryDateLabel;

  /// No description provided for @virtualCardCardCvcLabel.
  ///
  /// In en, this message translates to:
  /// **'CVC'**
  String get virtualCardCardCvcLabel;

  /// No description provided for @virtualCardCreateCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Create your virtual card to get started'**
  String get virtualCardCreateCardTitle;

  /// No description provided for @virtualCardCreateCardButton.
  ///
  /// In en, this message translates to:
  /// **'Create Card'**
  String get virtualCardCreateCardButton;

  /// No description provided for @comment_verify_passcode_controller.
  ///
  /// In en, this message translates to:
  /// **'==== Verify Passcode Controller ===='**
  String get comment_verify_passcode_controller;

  /// No description provided for @verifyPasscodeValidationEnterPasscode.
  ///
  /// In en, this message translates to:
  /// **'Please enter your passcode'**
  String get verifyPasscodeValidationEnterPasscode;

  /// No description provided for @comment_change_passcode_bottom_sheet.
  ///
  /// In en, this message translates to:
  /// **'==== Change Passcode Bottom Sheet ===='**
  String get comment_change_passcode_bottom_sheet;

  /// No description provided for @changePasscodeTitle.
  ///
  /// In en, this message translates to:
  /// **'Change Passcode'**
  String get changePasscodeTitle;

  /// No description provided for @changePasscodeLabelOldPasscode.
  ///
  /// In en, this message translates to:
  /// **'Old Passcode'**
  String get changePasscodeLabelOldPasscode;

  /// No description provided for @changePasscodeLabelNewPasscode.
  ///
  /// In en, this message translates to:
  /// **'New Passcode'**
  String get changePasscodeLabelNewPasscode;

  /// No description provided for @changePasscodeLabelConfirmPasscode.
  ///
  /// In en, this message translates to:
  /// **'Confirm Passcode'**
  String get changePasscodeLabelConfirmPasscode;

  /// No description provided for @changePasscodeButtonChange.
  ///
  /// In en, this message translates to:
  /// **'Change Passcode'**
  String get changePasscodeButtonChange;

  /// No description provided for @comment_disable_and_change_passcode_section.
  ///
  /// In en, this message translates to:
  /// **'==== Disable and Change Passcode Section ===='**
  String get comment_disable_and_change_passcode_section;

  /// No description provided for @disableChangePasscodeTitle.
  ///
  /// In en, this message translates to:
  /// **'Passcode'**
  String get disableChangePasscodeTitle;

  /// No description provided for @disableChangePasscodeButtonChange.
  ///
  /// In en, this message translates to:
  /// **'Change Passcode'**
  String get disableChangePasscodeButtonChange;

  /// No description provided for @disableChangePasscodeButtonDisable.
  ///
  /// In en, this message translates to:
  /// **'Disable Passcode'**
  String get disableChangePasscodeButtonDisable;

  /// No description provided for @comment_disable_passcode_bottom_sheet.
  ///
  /// In en, this message translates to:
  /// **'==== Disable Passcode Bottom Sheet ===='**
  String get comment_disable_passcode_bottom_sheet;

  /// No description provided for @disablePasscodeTitle.
  ///
  /// In en, this message translates to:
  /// **'Disable Passcode'**
  String get disablePasscodeTitle;

  /// No description provided for @disablePasscodeLabelPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get disablePasscodeLabelPassword;

  /// No description provided for @disablePasscodeButtonDisable.
  ///
  /// In en, this message translates to:
  /// **'Disable Passcode'**
  String get disablePasscodeButtonDisable;

  /// No description provided for @comment_generate_passcode_bottom_sheet.
  ///
  /// In en, this message translates to:
  /// **'==== Generate Passcode Bottom Sheet ===='**
  String get comment_generate_passcode_bottom_sheet;

  /// No description provided for @generatePasscodeTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Passcode'**
  String get generatePasscodeTitle;

  /// No description provided for @generatePasscodeLabelPasscode.
  ///
  /// In en, this message translates to:
  /// **'Passcode'**
  String get generatePasscodeLabelPasscode;

  /// No description provided for @generatePasscodeLabelConfirmPasscode.
  ///
  /// In en, this message translates to:
  /// **'Confirm Passcode'**
  String get generatePasscodeLabelConfirmPasscode;

  /// No description provided for @generatePasscodeButtonConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get generatePasscodeButtonConfirm;

  /// No description provided for @comment_generate_passcode_section.
  ///
  /// In en, this message translates to:
  /// **'==== Generate Passcode Section ===='**
  String get comment_generate_passcode_section;

  /// No description provided for @generatePasscodeSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Passcode'**
  String get generatePasscodeSectionTitle;

  /// No description provided for @generatePasscodeSectionDescription.
  ///
  /// In en, this message translates to:
  /// **'Create a secure passcode for quick access to your account'**
  String get generatePasscodeSectionDescription;

  /// No description provided for @generatePasscodeSectionButtonGenerate.
  ///
  /// In en, this message translates to:
  /// **'Generate Passcode'**
  String get generatePasscodeSectionButtonGenerate;

  /// No description provided for @comment_verify_passcode_bottom_sheet.
  ///
  /// In en, this message translates to:
  /// **'==== Verify Passcode Bottom Sheet ===='**
  String get comment_verify_passcode_bottom_sheet;

  /// No description provided for @verifyPasscodeTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Your Passcode'**
  String get verifyPasscodeTitle;

  /// No description provided for @verifyPasscodeLabelPasscode.
  ///
  /// In en, this message translates to:
  /// **'Passcode'**
  String get verifyPasscodeLabelPasscode;

  /// No description provided for @verifyPasscodeButtonConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get verifyPasscodeButtonConfirm;

  /// No description provided for @comment_payment_links_amount_section.
  ///
  /// In en, this message translates to:
  /// **'==== Payment Links Amount Section ===='**
  String get comment_payment_links_amount_section;

  /// No description provided for @paymentLinksAmountSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get paymentLinksAmountSectionTitle;

  /// No description provided for @paymentLinksCurrencyLabel.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get paymentLinksCurrencyLabel;

  /// No description provided for @paymentLinksCurrencyHint.
  ///
  /// In en, this message translates to:
  /// **'Select Currency'**
  String get paymentLinksCurrencyHint;

  /// No description provided for @paymentLinksCurrencyDropdownTitle.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get paymentLinksCurrencyDropdownTitle;

  /// No description provided for @paymentLinksCurrencyNotFound.
  ///
  /// In en, this message translates to:
  /// **'Currency Not Found'**
  String get paymentLinksCurrencyNotFound;

  /// No description provided for @paymentLinksNoteLabel.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get paymentLinksNoteLabel;

  /// No description provided for @paymentLinksCreateLinkButton.
  ///
  /// In en, this message translates to:
  /// **'Create Link'**
  String get paymentLinksCreateLinkButton;

  /// No description provided for @comment_payment_links_create_section.
  ///
  /// In en, this message translates to:
  /// **'==== Payment Links Create Section ===='**
  String get comment_payment_links_create_section;

  /// No description provided for @paymentLinksInstructionText.
  ///
  /// In en, this message translates to:
  /// **'You can create a payment link without specifying an amount or currency. The payer can fill up account, currency while making the payment.'**
  String get paymentLinksInstructionText;

  /// No description provided for @comment_payment_links_header_section.
  ///
  /// In en, this message translates to:
  /// **'==== Payment Links Header Section ===='**
  String get comment_payment_links_header_section;

  /// No description provided for @paymentLinksAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment Links'**
  String get paymentLinksAppBarTitle;

  /// No description provided for @paymentLinksTabList.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get paymentLinksTabList;

  /// No description provided for @paymentLinksTabCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get paymentLinksTabCreate;

  /// No description provided for @comment_payment_links_history_filter_bottom_sheet.
  ///
  /// In en, this message translates to:
  /// **'==== Payment Links History Filter Bottom Sheet ===='**
  String get comment_payment_links_history_filter_bottom_sheet;

  /// No description provided for @paymentLinksFilterNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Number'**
  String get paymentLinksFilterNumberLabel;

  /// No description provided for @paymentLinksFilterButton.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get paymentLinksFilterButton;

  /// No description provided for @comment_payment_links_list_section.
  ///
  /// In en, this message translates to:
  /// **'==== Payment Links List Section ===='**
  String get comment_payment_links_list_section;

  /// No description provided for @paymentLinksListItemCreatedAt.
  ///
  /// In en, this message translates to:
  /// **'Create At: '**
  String get paymentLinksListItemCreatedAt;

  /// No description provided for @paymentLinksListItemStatus.
  ///
  /// In en, this message translates to:
  /// **'Status: '**
  String get paymentLinksListItemStatus;

  /// No description provided for @paymentLinksStatusPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paymentLinksStatusPaid;

  /// No description provided for @paymentLinksStatusUnpaid.
  ///
  /// In en, this message translates to:
  /// **'Unpaid'**
  String get paymentLinksStatusUnpaid;

  /// No description provided for @paymentLinksCopySuccessToast.
  ///
  /// In en, this message translates to:
  /// **'Payment Link Code Copied'**
  String get paymentLinksCopySuccessToast;

  /// No description provided for @comment_gift_card_header_section.
  ///
  /// In en, this message translates to:
  /// **'---- Gift Card Header Section ----'**
  String get comment_gift_card_header_section;

  /// No description provided for @giftCardHeaderTitle.
  ///
  /// In en, this message translates to:
  /// **'Gift Card'**
  String get giftCardHeaderTitle;

  /// No description provided for @giftCardHeaderTabCards.
  ///
  /// In en, this message translates to:
  /// **'Cards'**
  String get giftCardHeaderTabCards;

  /// No description provided for @giftCardHeaderTabHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get giftCardHeaderTabHistory;

  /// No description provided for @comment_gift_card_history_filter_bottom_sheet.
  ///
  /// In en, this message translates to:
  /// **'---- Gift Card History Filter Bottom Sheet ----'**
  String get comment_gift_card_history_filter_bottom_sheet;

  /// No description provided for @giftCardHistoryFilterSearchLabel.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get giftCardHistoryFilterSearchLabel;

  /// No description provided for @giftCardHistoryFilterSearchButton.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get giftCardHistoryFilterSearchButton;

  /// No description provided for @comment_gift_card_filter_bottom_sheet.
  ///
  /// In en, this message translates to:
  /// **'---- Gift Card Filter Bottom Sheet ----'**
  String get comment_gift_card_filter_bottom_sheet;

  /// No description provided for @giftCardFilterGiftCardLabel.
  ///
  /// In en, this message translates to:
  /// **'Gift Card'**
  String get giftCardFilterGiftCardLabel;

  /// No description provided for @giftCardFilterCountryLabel.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get giftCardFilterCountryLabel;

  /// No description provided for @giftCardFilterCountrySelectTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Country'**
  String get giftCardFilterCountrySelectTitle;

  /// No description provided for @giftCardFilterAllOption.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get giftCardFilterAllOption;

  /// No description provided for @giftCardFilterCountryNotFound.
  ///
  /// In en, this message translates to:
  /// **'Country not found'**
  String get giftCardFilterCountryNotFound;

  /// No description provided for @giftCardFilterCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get giftCardFilterCategoryLabel;

  /// No description provided for @giftCardFilterCategorySelectTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Category'**
  String get giftCardFilterCategorySelectTitle;

  /// No description provided for @giftCardFilterCategoryNotFound.
  ///
  /// In en, this message translates to:
  /// **'Category not found'**
  String get giftCardFilterCategoryNotFound;

  /// No description provided for @giftCardFilterSearchButton.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get giftCardFilterSearchButton;

  /// No description provided for @comment_gift_card_history_details.
  ///
  /// In en, this message translates to:
  /// **'---- Gift Card History Details ----'**
  String get comment_gift_card_history_details;

  /// No description provided for @giftCardHistoryDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Transaction Details'**
  String get giftCardHistoryDetailsTitle;

  /// No description provided for @giftCardHistoryQtyLabel.
  ///
  /// In en, this message translates to:
  /// **'QTY : {qty}'**
  String giftCardHistoryQtyLabel(Object qty);

  /// No description provided for @giftCardTransactionIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Transaction ID'**
  String get giftCardTransactionIdLabel;

  /// No description provided for @giftCardProductNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Product Name'**
  String get giftCardProductNameLabel;

  /// No description provided for @giftCardSenderNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Sender Name'**
  String get giftCardSenderNameLabel;

  /// No description provided for @giftCardRecipientEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Recipient Email'**
  String get giftCardRecipientEmailLabel;

  /// No description provided for @giftCardRecipientPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Recipient Phone'**
  String get giftCardRecipientPhoneLabel;

  /// No description provided for @giftCardUnitPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Unit Price'**
  String get giftCardUnitPriceLabel;

  /// No description provided for @giftCardTotalAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get giftCardTotalAmountLabel;

  /// No description provided for @comment_gift_card_review_details.
  ///
  /// In en, this message translates to:
  /// **'---- Gift Card Review Details ----'**
  String get comment_gift_card_review_details;

  /// No description provided for @giftCardReviewDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Review Details'**
  String get giftCardReviewDetailsTitle;

  /// No description provided for @giftCardSubTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Sub Total'**
  String get giftCardSubTotalLabel;

  /// No description provided for @giftCardTotalFeeLabel.
  ///
  /// In en, this message translates to:
  /// **'Total Fee'**
  String get giftCardTotalFeeLabel;

  /// No description provided for @giftCardTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get giftCardTotalLabel;

  /// No description provided for @giftCardReviewBackButton.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get giftCardReviewBackButton;

  /// No description provided for @giftCardReviewPayNowButton.
  ///
  /// In en, this message translates to:
  /// **'Pay Now'**
  String get giftCardReviewPayNowButton;

  /// No description provided for @comment_gift_card_success_section.
  ///
  /// In en, this message translates to:
  /// **'---- Gift Card Success Section ----'**
  String get comment_gift_card_success_section;

  /// No description provided for @giftCardSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Gift Card Order Successfully Placed!'**
  String get giftCardSuccessTitle;

  /// No description provided for @giftCardSuccessGiftCardsButton.
  ///
  /// In en, this message translates to:
  /// **'Gift Cards'**
  String get giftCardSuccessGiftCardsButton;

  /// No description provided for @giftCardSuccessBackHomeButton.
  ///
  /// In en, this message translates to:
  /// **'Back Home'**
  String get giftCardSuccessBackHomeButton;

  /// No description provided for @comment_gift_card_amount_validation.
  ///
  /// In en, this message translates to:
  /// **'---- Gift Card Controller Amount Validation ----'**
  String get comment_gift_card_amount_validation;

  /// No description provided for @giftCardAmountRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter an amount'**
  String get giftCardAmountRequired;

  /// No description provided for @giftCardAmountInvalid.
  ///
  /// In en, this message translates to:
  /// **'Amount must be greater than zero'**
  String get giftCardAmountInvalid;

  /// No description provided for @giftCardAmountMinError.
  ///
  /// In en, this message translates to:
  /// **'Amount must not exceed {min}'**
  String giftCardAmountMinError(Object min);

  /// No description provided for @giftCardAmountMaxError.
  ///
  /// In en, this message translates to:
  /// **'Amount must not exceed {max}'**
  String giftCardAmountMaxError(Object max);

  /// No description provided for @comment_gift_card_user_validation.
  ///
  /// In en, this message translates to:
  /// **'---- Gift Card Controller User Validation ----'**
  String get comment_gift_card_user_validation;

  /// No description provided for @giftCardEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter an email'**
  String get giftCardEmailRequired;

  /// No description provided for @giftCardEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get giftCardEmailInvalid;

  /// No description provided for @giftCardCountryRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select a country'**
  String get giftCardCountryRequired;

  /// No description provided for @giftCardPhoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a phone'**
  String get giftCardPhoneRequired;

  /// No description provided for @giftCardNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name'**
  String get giftCardNameRequired;

  /// No description provided for @comment_gift_card_details_section.
  ///
  /// In en, this message translates to:
  /// **'---- Gift Card Details Section ----'**
  String get comment_gift_card_details_section;

  /// No description provided for @giftCardDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Gift Card Details'**
  String get giftCardDetailsTitle;

  /// No description provided for @giftCardAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get giftCardAmountLabel;

  /// No description provided for @giftCardAmountBetweenLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount between {min} {currency} and {max} {currency}'**
  String giftCardAmountBetweenLabel(Object currency, Object max, Object min);

  /// No description provided for @giftCardEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get giftCardEmailLabel;

  /// No description provided for @giftCardCountryLabel.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get giftCardCountryLabel;

  /// No description provided for @giftCardSelectCountryTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Country'**
  String get giftCardSelectCountryTitle;

  /// No description provided for @giftCardCountryNotFound.
  ///
  /// In en, this message translates to:
  /// **'Country not found'**
  String get giftCardCountryNotFound;

  /// No description provided for @giftCardPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get giftCardPhoneLabel;

  /// No description provided for @giftCardYourNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Your Name'**
  String get giftCardYourNameLabel;

  /// No description provided for @giftCardQuantityLabel.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get giftCardQuantityLabel;

  /// No description provided for @giftCardBuyNowButton.
  ///
  /// In en, this message translates to:
  /// **'Buy Now'**
  String get giftCardBuyNowButton;

  /// No description provided for @giftCardRedeemInstructionTitle.
  ///
  /// In en, this message translates to:
  /// **'Redeem Instruction'**
  String get giftCardRedeemInstructionTitle;

  /// No description provided for @comment_p2p.
  ///
  /// In en, this message translates to:
  /// **'==== P2P ===='**
  String get comment_p2p;

  /// No description provided for @p2pMyOrder.
  ///
  /// In en, this message translates to:
  /// **'My Order'**
  String get p2pMyOrder;

  /// No description provided for @p2pPaymentAccount.
  ///
  /// In en, this message translates to:
  /// **'Payment Account'**
  String get p2pPaymentAccount;

  /// No description provided for @p2pCreateAd.
  ///
  /// In en, this message translates to:
  /// **'Create Ad'**
  String get p2pCreateAd;

  /// No description provided for @p2pApplyVerification.
  ///
  /// In en, this message translates to:
  /// **'Apply Verification'**
  String get p2pApplyVerification;

  /// No description provided for @p2pP2p.
  ///
  /// In en, this message translates to:
  /// **'P2P'**
  String get p2pP2p;

  /// No description provided for @p2pMyOrders.
  ///
  /// In en, this message translates to:
  /// **'My Orders'**
  String get p2pMyOrders;

  /// No description provided for @p2pPaymentAccounts.
  ///
  /// In en, this message translates to:
  /// **'Payment Accounts'**
  String get p2pPaymentAccounts;

  /// No description provided for @p2pMyAds.
  ///
  /// In en, this message translates to:
  /// **'My Ads'**
  String get p2pMyAds;

  /// No description provided for @p2pSelectAsset.
  ///
  /// In en, this message translates to:
  /// **'Select Asset'**
  String get p2pSelectAsset;

  /// No description provided for @p2pSelectFiat.
  ///
  /// In en, this message translates to:
  /// **'Select Fiat'**
  String get p2pSelectFiat;

  /// No description provided for @p2pBuy.
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get p2pBuy;

  /// No description provided for @p2pSell.
  ///
  /// In en, this message translates to:
  /// **'Sell'**
  String get p2pSell;

  /// No description provided for @p2pAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get p2pAmount;

  /// No description provided for @p2pPayment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get p2pPayment;

  /// No description provided for @p2pOrders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get p2pOrders;

  /// No description provided for @p2pCompletion.
  ///
  /// In en, this message translates to:
  /// **'Completion'**
  String get p2pCompletion;

  /// No description provided for @p2pLimit.
  ///
  /// In en, this message translates to:
  /// **'Limit'**
  String get p2pLimit;

  /// No description provided for @p2pAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get p2pAvailable;

  /// No description provided for @p2pOrderDetails.
  ///
  /// In en, this message translates to:
  /// **'Order Details'**
  String get p2pOrderDetails;

  /// No description provided for @p2pNoOrderDetailsFound.
  ///
  /// In en, this message translates to:
  /// **'No order details found'**
  String get p2pNoOrderDetailsFound;

  /// No description provided for @p2pNoAdDetailsFound.
  ///
  /// In en, this message translates to:
  /// **'No ad details found'**
  String get p2pNoAdDetailsFound;

  /// No description provided for @p2pPrice.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get p2pPrice;

  /// No description provided for @p2pOrderLimit.
  ///
  /// In en, this message translates to:
  /// **'Order Limit'**
  String get p2pOrderLimit;

  /// No description provided for @p2pYouPay.
  ///
  /// In en, this message translates to:
  /// **'You Pay'**
  String get p2pYouPay;

  /// No description provided for @p2pYouSell.
  ///
  /// In en, this message translates to:
  /// **'You Sell'**
  String get p2pYouSell;

  /// No description provided for @p2pYouReceive.
  ///
  /// In en, this message translates to:
  /// **'You Receive'**
  String get p2pYouReceive;

  /// No description provided for @p2pPaymentMethods.
  ///
  /// In en, this message translates to:
  /// **'Payment Methods'**
  String get p2pPaymentMethods;

  /// No description provided for @p2pLoadingPaymentMethods.
  ///
  /// In en, this message translates to:
  /// **'Loading payment methods...'**
  String get p2pLoadingPaymentMethods;

  /// No description provided for @p2pSelectPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Select Payment Method'**
  String get p2pSelectPaymentMethod;

  /// No description provided for @p2pNoPaymentMethodFound.
  ///
  /// In en, this message translates to:
  /// **'No payment method found'**
  String get p2pNoPaymentMethodFound;

  /// No description provided for @p2pAdvertisersTerms.
  ///
  /// In en, this message translates to:
  /// **'Advertisers\' Terms (Please read carefully)'**
  String get p2pAdvertisersTerms;

  /// No description provided for @p2pPaymentTimeLimit.
  ///
  /// In en, this message translates to:
  /// **'Payment Time Limit'**
  String get p2pPaymentTimeLimit;

  /// No description provided for @p2pAvgReleaseTime.
  ///
  /// In en, this message translates to:
  /// **'Avg. Release Time'**
  String get p2pAvgReleaseTime;

  /// No description provided for @p2pNoTermsProvided.
  ///
  /// In en, this message translates to:
  /// **'No terms provided'**
  String get p2pNoTermsProvided;

  /// No description provided for @p2pOrderNumber.
  ///
  /// In en, this message translates to:
  /// **'Order number'**
  String get p2pOrderNumber;

  /// No description provided for @p2pSearchOrderNumber.
  ///
  /// In en, this message translates to:
  /// **'Search Order number'**
  String get p2pSearchOrderNumber;

  /// No description provided for @p2pOrderNumberCopied.
  ///
  /// In en, this message translates to:
  /// **'Order number copied'**
  String get p2pOrderNumberCopied;

  /// No description provided for @p2pCopied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get p2pCopied;

  /// No description provided for @p2pOrderCreated.
  ///
  /// In en, this message translates to:
  /// **'Order Created'**
  String get p2pOrderCreated;

  /// No description provided for @p2pFiatAmount.
  ///
  /// In en, this message translates to:
  /// **'Fiat Amount'**
  String get p2pFiatAmount;

  /// No description provided for @p2pReceiveQuantity.
  ///
  /// In en, this message translates to:
  /// **'Receive Quantity'**
  String get p2pReceiveQuantity;

  /// No description provided for @p2pPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get p2pPaymentMethod;

  /// No description provided for @p2pChange.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get p2pChange;

  /// No description provided for @p2pRecipient.
  ///
  /// In en, this message translates to:
  /// **'Recipient'**
  String get p2pRecipient;

  /// No description provided for @p2pView.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get p2pView;

  /// No description provided for @p2pFilterAmount.
  ///
  /// In en, this message translates to:
  /// **'Filter Amount'**
  String get p2pFilterAmount;

  /// No description provided for @p2pEnterAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter Amount'**
  String get p2pEnterAmount;

  /// No description provided for @p2pFilterPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Filter Payment Method'**
  String get p2pFilterPaymentMethod;

  /// No description provided for @p2pUnableToLoadImage.
  ///
  /// In en, this message translates to:
  /// **'Unable to load image'**
  String get p2pUnableToLoadImage;

  /// No description provided for @p2pUnableToLoadAttachment.
  ///
  /// In en, this message translates to:
  /// **'Unable to load attachment'**
  String get p2pUnableToLoadAttachment;

  /// No description provided for @p2pTransferredNotifySeller.
  ///
  /// In en, this message translates to:
  /// **'Transferred, Notify Seller'**
  String get p2pTransferredNotifySeller;

  /// No description provided for @p2pCancelOrder.
  ///
  /// In en, this message translates to:
  /// **'Cancel Order'**
  String get p2pCancelOrder;

  /// No description provided for @p2pDisputeOrder.
  ///
  /// In en, this message translates to:
  /// **'Dispute Order'**
  String get p2pDisputeOrder;

  /// No description provided for @p2pPaymentReceived.
  ///
  /// In en, this message translates to:
  /// **'Payment Received'**
  String get p2pPaymentReceived;

  /// No description provided for @p2pEnterDisputeReason.
  ///
  /// In en, this message translates to:
  /// **'Enter Dispute Reason'**
  String get p2pEnterDisputeReason;

  /// No description provided for @p2pWriteYourReason.
  ///
  /// In en, this message translates to:
  /// **'Write your reason...'**
  String get p2pWriteYourReason;

  /// No description provided for @p2pEnterReason.
  ///
  /// In en, this message translates to:
  /// **'Enter Reason'**
  String get p2pEnterReason;

  /// No description provided for @p2pReasonIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Reason is required'**
  String get p2pReasonIsRequired;

  /// No description provided for @p2pCancelOrderConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel this order?'**
  String get p2pCancelOrderConfirmation;

  /// No description provided for @p2pOrderCompleted.
  ///
  /// In en, this message translates to:
  /// **'Order Completed'**
  String get p2pOrderCompleted;

  /// No description provided for @p2pOrderCancelled.
  ///
  /// In en, this message translates to:
  /// **'Order Cancelled'**
  String get p2pOrderCancelled;

  /// No description provided for @p2pPendingRelease.
  ///
  /// In en, this message translates to:
  /// **'Pending Release'**
  String get p2pPendingRelease;

  /// No description provided for @p2pOrderDisputed.
  ///
  /// In en, this message translates to:
  /// **'Order Disputed'**
  String get p2pOrderDisputed;

  /// No description provided for @p2pOrderExpired.
  ///
  /// In en, this message translates to:
  /// **'Order Expired'**
  String get p2pOrderExpired;

  /// No description provided for @p2pBuyerMarkedAsPaid.
  ///
  /// In en, this message translates to:
  /// **'Buyer Marked as Paid'**
  String get p2pBuyerMarkedAsPaid;

  /// No description provided for @p2pOrderCreatedPayTheSellerWithin.
  ///
  /// In en, this message translates to:
  /// **'Order Created, Pay the Seller within'**
  String get p2pOrderCreatedPayTheSellerWithin;

  /// No description provided for @p2pBuyerHasNotPaidYetPaymentDueWithin.
  ///
  /// In en, this message translates to:
  /// **'Buyer has not paid yet. Payment due within'**
  String get p2pBuyerHasNotPaidYetPaymentDueWithin;

  /// No description provided for @p2pSellerFundsLockedInEscrow.
  ///
  /// In en, this message translates to:
  /// **'The seller\'s funds are locked in escrow. Our support team will review the evidence and respond shortly.'**
  String get p2pSellerFundsLockedInEscrow;

  /// No description provided for @p2pYourLockedAssetsInEscrow.
  ///
  /// In en, this message translates to:
  /// **'Your locked assets are in escrow. Our support team will review this dispute shortly.'**
  String get p2pYourLockedAssetsInEscrow;

  /// No description provided for @p2pPaymentNotCompletedInAllowedTime.
  ///
  /// In en, this message translates to:
  /// **'You did not complete the payment within the allowed time.'**
  String get p2pPaymentNotCompletedInAllowedTime;

  /// No description provided for @p2pBuyerDidNotCompletePaymentInAllowedTime.
  ///
  /// In en, this message translates to:
  /// **'Buyer did not complete payment in allowed time.'**
  String get p2pBuyerDidNotCompletePaymentInAllowedTime;

  /// No description provided for @p2pConfirmPaymentFrom.
  ///
  /// In en, this message translates to:
  /// **'Confirm that the payment is from (buyer by: {name})'**
  String p2pConfirmPaymentFrom(Object name);

  /// No description provided for @p2pVerifyAmountAndSender.
  ///
  /// In en, this message translates to:
  /// **'Please verify the amount and sender details in your account, then continue with release action.'**
  String get p2pVerifyAmountAndSender;

  /// No description provided for @p2pTransferFundsToSeller.
  ///
  /// In en, this message translates to:
  /// **'Transfer the funds to the seller\'s account provided below.'**
  String get p2pTransferFundsToSeller;

  /// No description provided for @p2pNotifySeller.
  ///
  /// In en, this message translates to:
  /// **'Notify Seller'**
  String get p2pNotifySeller;

  /// No description provided for @p2pConfirmPaymentReceived.
  ///
  /// In en, this message translates to:
  /// **'Confirm Payment received'**
  String get p2pConfirmPaymentReceived;

  /// No description provided for @p2pConfirmPaymentReceivedDescription.
  ///
  /// In en, this message translates to:
  /// **'After confirming that payment has been received, click the \"Payment Received\" button below.'**
  String get p2pConfirmPaymentReceivedDescription;

  /// No description provided for @p2pNotifySellerDescription.
  ///
  /// In en, this message translates to:
  /// **'After payment, remember to click the \'Transferred, Notify Seller\' button to facilitate the crypto release by the seller.'**
  String get p2pNotifySellerDescription;

  /// No description provided for @p2pAllAccount.
  ///
  /// In en, this message translates to:
  /// **'All Account'**
  String get p2pAllAccount;

  /// No description provided for @p2pAddPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Add Payment Method'**
  String get p2pAddPaymentMethod;

  /// No description provided for @p2pEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get p2pEdit;

  /// No description provided for @p2pEditPaymentAccount.
  ///
  /// In en, this message translates to:
  /// **'Edit Payment Account'**
  String get p2pEditPaymentAccount;

  /// No description provided for @p2pUpdateAccount.
  ///
  /// In en, this message translates to:
  /// **'Update Account'**
  String get p2pUpdateAccount;

  /// No description provided for @p2pCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get p2pCancel;

  /// No description provided for @p2pSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get p2pSubmit;

  /// No description provided for @p2pBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get p2pBack;

  /// No description provided for @p2pNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get p2pNext;

  /// No description provided for @p2pDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get p2pDone;

  /// No description provided for @p2pIWantToBuy.
  ///
  /// In en, this message translates to:
  /// **'I want to Buy'**
  String get p2pIWantToBuy;

  /// No description provided for @p2pIWantToSell.
  ///
  /// In en, this message translates to:
  /// **'I want to Sell'**
  String get p2pIWantToSell;

  /// No description provided for @p2pAsset.
  ///
  /// In en, this message translates to:
  /// **'Asset'**
  String get p2pAsset;

  /// No description provided for @p2pWithFiat.
  ///
  /// In en, this message translates to:
  /// **'With Fiat'**
  String get p2pWithFiat;

  /// No description provided for @p2pPriceType.
  ///
  /// In en, this message translates to:
  /// **'Price Type'**
  String get p2pPriceType;

  /// No description provided for @p2pYourPrice.
  ///
  /// In en, this message translates to:
  /// **'Your Price'**
  String get p2pYourPrice;

  /// No description provided for @p2pHighestOrderPrice.
  ///
  /// In en, this message translates to:
  /// **'Highest Order Price'**
  String get p2pHighestOrderPrice;

  /// No description provided for @p2pTotalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get p2pTotalAmount;

  /// No description provided for @p2pSelectAtLeastOnePaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Select at least one payment method'**
  String get p2pSelectAtLeastOnePaymentMethod;

  /// No description provided for @p2pAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get p2pAdd;

  /// No description provided for @p2pMinutes.
  ///
  /// In en, this message translates to:
  /// **'Minutes'**
  String get p2pMinutes;

  /// No description provided for @p2pTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms'**
  String get p2pTerms;

  /// No description provided for @p2pAutomaticReply.
  ///
  /// In en, this message translates to:
  /// **'Automatic Reply'**
  String get p2pAutomaticReply;

  /// No description provided for @p2pFixed.
  ///
  /// In en, this message translates to:
  /// **'Fixed'**
  String get p2pFixed;

  /// No description provided for @p2pFloat.
  ///
  /// In en, this message translates to:
  /// **'Float'**
  String get p2pFloat;

  /// No description provided for @p2pSelectPriceType.
  ///
  /// In en, this message translates to:
  /// **'Select Price Type'**
  String get p2pSelectPriceType;

  /// No description provided for @p2pNoAssetsFound.
  ///
  /// In en, this message translates to:
  /// **'No assets found'**
  String get p2pNoAssetsFound;

  /// No description provided for @p2pNoFiatCurrenciesFound.
  ///
  /// In en, this message translates to:
  /// **'No fiat currencies found'**
  String get p2pNoFiatCurrenciesFound;

  /// No description provided for @p2pNoPriceTypeFound.
  ///
  /// In en, this message translates to:
  /// **'No price type found'**
  String get p2pNoPriceTypeFound;

  /// No description provided for @p2pAdSuccessfullyPosted.
  ///
  /// In en, this message translates to:
  /// **'Ad Successfully Posted'**
  String get p2pAdSuccessfullyPosted;

  /// No description provided for @p2pAdsSubmittedUnderReview.
  ///
  /// In en, this message translates to:
  /// **'Ads submitted and under reviewing.'**
  String get p2pAdsSubmittedUnderReview;

  /// No description provided for @p2pAdPublishedDescription.
  ///
  /// In en, this message translates to:
  /// **'Your Ad has been published and users can now place order. Please pay attention to the prompt for new orders.'**
  String get p2pAdPublishedDescription;

  /// No description provided for @p2pAdUnderReviewDescription.
  ///
  /// In en, this message translates to:
  /// **'Your Ad is under review. Once approved, it will be published and users can place order. Please pay attention to the prompt for new orders.'**
  String get p2pAdUnderReviewDescription;

  /// No description provided for @p2pAdNumber.
  ///
  /// In en, this message translates to:
  /// **'Ad number'**
  String get p2pAdNumber;

  /// No description provided for @p2pMethod.
  ///
  /// In en, this message translates to:
  /// **'Method'**
  String get p2pMethod;

  /// No description provided for @p2pGoToMyAds.
  ///
  /// In en, this message translates to:
  /// **'Go To My Ads'**
  String get p2pGoToMyAds;

  /// No description provided for @p2pEligibilityValidationFailed.
  ///
  /// In en, this message translates to:
  /// **'Eligibility Validation Failed'**
  String get p2pEligibilityValidationFailed;

  /// No description provided for @p2pPleaseFulfillRequirements.
  ///
  /// In en, this message translates to:
  /// **'Please fulfill the following requirements:'**
  String get p2pPleaseFulfillRequirements;

  /// No description provided for @p2pNotEligibleCreateAd.
  ///
  /// In en, this message translates to:
  /// **'You are currently not eligible to create an ad.'**
  String get p2pNotEligibleCreateAd;

  /// No description provided for @p2pCompletedTradeQty.
  ///
  /// In en, this message translates to:
  /// **'Completed Trade QTY'**
  String get p2pCompletedTradeQty;

  /// No description provided for @p2pStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get p2pStatus;

  /// No description provided for @p2pAdsView.
  ///
  /// In en, this message translates to:
  /// **'Ads View'**
  String get p2pAdsView;

  /// No description provided for @p2pAdNumberTitle.
  ///
  /// In en, this message translates to:
  /// **'Ad Number'**
  String get p2pAdNumberTitle;

  /// No description provided for @p2pType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get p2pType;

  /// No description provided for @p2pAssetFiat.
  ///
  /// In en, this message translates to:
  /// **'Asset/Fiat'**
  String get p2pAssetFiat;

  /// No description provided for @p2pPriceExchangeRate.
  ///
  /// In en, this message translates to:
  /// **'Price\nExchange Rate'**
  String get p2pPriceExchangeRate;

  /// No description provided for @p2pLastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last Updated'**
  String get p2pLastUpdated;

  /// No description provided for @p2pCreateTime.
  ///
  /// In en, this message translates to:
  /// **'Create Time'**
  String get p2pCreateTime;

  /// No description provided for @p2pDeleteAdConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this ad?'**
  String get p2pDeleteAdConfirmation;

  /// No description provided for @p2pFiat.
  ///
  /// In en, this message translates to:
  /// **'Fiat'**
  String get p2pFiat;

  /// No description provided for @p2pCryptoAmount.
  ///
  /// In en, this message translates to:
  /// **'Crypto Amount'**
  String get p2pCryptoAmount;

  /// No description provided for @p2pCounterparty.
  ///
  /// In en, this message translates to:
  /// **'Counterparty'**
  String get p2pCounterparty;

  /// No description provided for @p2pChat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get p2pChat;

  /// No description provided for @p2pNoMessagesYet.
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get p2pNoMessagesYet;

  /// No description provided for @p2pTypeYourMessage.
  ///
  /// In en, this message translates to:
  /// **'Type your message...'**
  String get p2pTypeYourMessage;

  /// No description provided for @p2pCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get p2pCamera;

  /// No description provided for @p2pGallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get p2pGallery;

  /// No description provided for @p2pAttachment.
  ///
  /// In en, this message translates to:
  /// **'Attachment'**
  String get p2pAttachment;

  /// No description provided for @p2pUser.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get p2pUser;

  /// No description provided for @p2pYouAreVerifiedTrader.
  ///
  /// In en, this message translates to:
  /// **'You are a verified trader'**
  String get p2pYouAreVerifiedTrader;

  /// No description provided for @p2pVerifiedTraderStatusActive.
  ///
  /// In en, this message translates to:
  /// **'Your verified trader status is active.'**
  String get p2pVerifiedTraderStatusActive;

  /// No description provided for @p2pVerificationUnderReview.
  ///
  /// In en, this message translates to:
  /// **'Verification under review'**
  String get p2pVerificationUnderReview;

  /// No description provided for @p2pVerificationRequestUnderReview.
  ///
  /// In en, this message translates to:
  /// **'Your verification request is currently under review.'**
  String get p2pVerificationRequestUnderReview;

  /// No description provided for @p2pSubmittedOn.
  ///
  /// In en, this message translates to:
  /// **'Submitted on'**
  String get p2pSubmittedOn;

  /// No description provided for @p2pVerificationDataUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Verification data unavailable'**
  String get p2pVerificationDataUnavailable;

  /// No description provided for @p2pPleaseRefreshAndTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Please refresh and try again.'**
  String get p2pPleaseRefreshAndTryAgain;

  /// No description provided for @p2pPreviousVerificationRejected.
  ///
  /// In en, this message translates to:
  /// **'Previous verification request was rejected'**
  String get p2pPreviousVerificationRejected;

  /// No description provided for @p2pReason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get p2pReason;

  /// No description provided for @p2pCorrectInformationApplyAgain.
  ///
  /// In en, this message translates to:
  /// **'Please correct the information and apply again.'**
  String get p2pCorrectInformationApplyAgain;

  /// No description provided for @p2pApplyVerificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Apply Verification'**
  String get p2pApplyVerificationTitle;

  /// No description provided for @p2pFillRequiredFieldsVerification.
  ///
  /// In en, this message translates to:
  /// **'Fill out all required fields to submit verification.'**
  String get p2pFillRequiredFieldsVerification;

  /// No description provided for @p2pNoVerificationFormFieldsFound.
  ///
  /// In en, this message translates to:
  /// **'No verification form fields found.'**
  String get p2pNoVerificationFormFieldsFound;

  /// No description provided for @p2pSubmitVerification.
  ///
  /// In en, this message translates to:
  /// **'Submit Verification'**
  String get p2pSubmitVerification;

  /// No description provided for @p2pEnterField.
  ///
  /// In en, this message translates to:
  /// **'Enter {field}'**
  String p2pEnterField(Object field);

  /// No description provided for @edit_my_ad.
  ///
  /// In en, this message translates to:
  /// **'Edit My Ad'**
  String get edit_my_ad;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @total_amount.
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get total_amount;

  /// No description provided for @min_amount.
  ///
  /// In en, this message translates to:
  /// **'Min Amount'**
  String get min_amount;

  /// No description provided for @max_amount.
  ///
  /// In en, this message translates to:
  /// **'Max Amount'**
  String get max_amount;

  /// No description provided for @payment_duration.
  ///
  /// In en, this message translates to:
  /// **'Payment duration'**
  String get payment_duration;

  /// No description provided for @payment_method.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get payment_method;

  /// No description provided for @no_payment_method.
  ///
  /// In en, this message translates to:
  /// **'No payment method found'**
  String get no_payment_method;

  /// No description provided for @terms.
  ///
  /// In en, this message translates to:
  /// **'Terms'**
  String get terms;

  /// No description provided for @auto_response.
  ///
  /// In en, this message translates to:
  /// **'Auto Response Message'**
  String get auto_response;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @error_ad_invalid.
  ///
  /// In en, this message translates to:
  /// **'Ad data is invalid'**
  String get error_ad_invalid;

  /// No description provided for @error_amount_zero.
  ///
  /// In en, this message translates to:
  /// **'Amount can not be zero'**
  String get error_amount_zero;

  /// No description provided for @error_total_amount_zero.
  ///
  /// In en, this message translates to:
  /// **'Total amount can not be zero'**
  String get error_total_amount_zero;

  /// No description provided for @error_min_zero.
  ///
  /// In en, this message translates to:
  /// **'Min amount can not be zero'**
  String get error_min_zero;

  /// No description provided for @error_max_zero.
  ///
  /// In en, this message translates to:
  /// **'Max amount can not be zero'**
  String get error_max_zero;

  /// No description provided for @error_min_greater.
  ///
  /// In en, this message translates to:
  /// **'Min amount can not be greater than max amount'**
  String get error_min_greater;

  /// No description provided for @error_payment_duration_zero.
  ///
  /// In en, this message translates to:
  /// **'Payment duration can not be zero'**
  String get error_payment_duration_zero;

  /// No description provided for @error_select_payment.
  ///
  /// In en, this message translates to:
  /// **'Please select payment method'**
  String get error_select_payment;

  /// No description provided for @error_terms_empty.
  ///
  /// In en, this message translates to:
  /// **'Terms can not be empty'**
  String get error_terms_empty;

  /// No description provided for @error_select_asset.
  ///
  /// In en, this message translates to:
  /// **'Please select asset'**
  String get error_select_asset;

  /// No description provided for @error_select_fiat.
  ///
  /// In en, this message translates to:
  /// **'Please select fiat'**
  String get error_select_fiat;

  /// No description provided for @error_select_price_type.
  ///
  /// In en, this message translates to:
  /// **'Please select price type'**
  String get error_select_price_type;

  /// No description provided for @error_price_zero.
  ///
  /// In en, this message translates to:
  /// **'Price can not be zero'**
  String get error_price_zero;

  /// No description provided for @error_enter_total_amount.
  ///
  /// In en, this message translates to:
  /// **'Please enter total amount'**
  String get error_enter_total_amount;

  /// No description provided for @error_enter_min_order.
  ///
  /// In en, this message translates to:
  /// **'Please enter minimum order limit'**
  String get error_enter_min_order;

  /// No description provided for @error_enter_max_order.
  ///
  /// In en, this message translates to:
  /// **'Please enter maximum order limit'**
  String get error_enter_max_order;

  /// No description provided for @error_payment_time_zero.
  ///
  /// In en, this message translates to:
  /// **'Payment time can not be zero'**
  String get error_payment_time_zero;

  /// No description provided for @error_enter_terms.
  ///
  /// In en, this message translates to:
  /// **'Please enter terms'**
  String get error_enter_terms;

  /// No description provided for @filterMyAds.
  ///
  /// In en, this message translates to:
  /// **'Filter My Ads'**
  String get filterMyAds;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @fiatCurrency.
  ///
  /// In en, this message translates to:
  /// **'Fiat Currency'**
  String get fiatCurrency;

  /// No description provided for @assetCurrency.
  ///
  /// In en, this message translates to:
  /// **'Asset Currency'**
  String get assetCurrency;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// No description provided for @selectStatus.
  ///
  /// In en, this message translates to:
  /// **'Select Status'**
  String get selectStatus;

  /// No description provided for @selectType.
  ///
  /// In en, this message translates to:
  /// **'Select Type'**
  String get selectType;

  /// No description provided for @selectFiatCurrency.
  ///
  /// In en, this message translates to:
  /// **'Select Fiat Currency'**
  String get selectFiatCurrency;

  /// No description provided for @selectAssetCurrency.
  ///
  /// In en, this message translates to:
  /// **'Select Asset Currency'**
  String get selectAssetCurrency;

  /// No description provided for @noStatusFound.
  ///
  /// In en, this message translates to:
  /// **'No status found'**
  String get noStatusFound;

  /// No description provided for @noTypeFound.
  ///
  /// In en, this message translates to:
  /// **'No type found'**
  String get noTypeFound;

  /// No description provided for @noDataFound.
  ///
  /// In en, this message translates to:
  /// **'No Data found'**
  String get noDataFound;

  /// No description provided for @noFiatCurrencyFound.
  ///
  /// In en, this message translates to:
  /// **'No fiat currency found'**
  String get noFiatCurrencyFound;

  /// No description provided for @noAssetCurrencyFound.
  ///
  /// In en, this message translates to:
  /// **'No asset currency found'**
  String get noAssetCurrencyFound;

  /// No description provided for @filterPaymentAccount.
  ///
  /// In en, this message translates to:
  /// **'Filter Payment Account'**
  String get filterPaymentAccount;

  /// No description provided for @filterMyOrder.
  ///
  /// In en, this message translates to:
  /// **'Filter My Order'**
  String get filterMyOrder;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
