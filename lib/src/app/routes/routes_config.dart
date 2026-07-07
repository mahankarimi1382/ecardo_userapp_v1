import 'package:qunzo_user/src/presentation/screens/bill_payment/view/bill_payment_history/bill_payment_history.dart';
import 'package:qunzo_user/src/presentation/screens/bill_payment/view/data_bundle/data_bundle.dart';
import 'package:qunzo_user/src/presentation/screens/bill_payment/view/internet/internet.dart';
import 'package:qunzo_user/src/presentation/screens/bill_payment/view/toll/toll.dart';
import 'package:qunzo_user/src/presentation/screens/gift_card/view/gift_card_screen.dart';
import 'package:qunzo_user/src/presentation/screens/p2p/view/p2p_view.dart';
import 'package:qunzo_user/src/presentation/screens/payment_links/view/payment_links_screen.dart';
import 'package:qunzo_user/src/presentation/screens/virtual_card/view/create_virtual_card/create_virtual_card.dart';
import 'package:qunzo_user/src/presentation/screens/virtual_card/view/get_card_info/get_card_info.dart';
import 'package:qunzo_user/src/presentation/screens/virtual_card/view/virtual_card_details/virtual_card_details.dart';
import 'package:qunzo_user/src/presentation/screens/virtual_card/view/virtual_card_transaction/virtual_card_transaction.dart';
import 'package:qunzo_user/src/presentation/widgets/maintenance_mode.dart';

import '../../presentation/screens/add_money/view/add_money_history/add_money_history.dart';
import '../../presentation/screens/add_money/view/add_money_screen.dart';
import '../../presentation/screens/authentication/forgot_password/view/forgot_password_screen.dart';
import '../../presentation/screens/authentication/forgot_password/view/sub_sections/forgot_password_pin_verification.dart';
import '../../presentation/screens/authentication/forgot_password/view/sub_sections/reset_password.dart';
import '../../presentation/screens/authentication/sign_in/view/sign_in_screen.dart';
import '../../presentation/screens/authentication/sign_in/view/sub_sections/two_factor_auth.dart';
import '../../presentation/screens/authentication/sign_up/view/auth_id_verification/auth_id_verification_screen.dart';
import '../../presentation/screens/authentication/sign_up/view/email/email_screen.dart';
import '../../presentation/screens/authentication/sign_up/view/personal_info/personal_info_screen.dart';
import '../../presentation/screens/authentication/sign_up/view/set_up_password/set_up_password_screen.dart';
import '../../presentation/screens/authentication/sign_up/view/sign_up_status/sign_up_status_screen.dart';
import '../../presentation/screens/authentication/sign_up/view/verify_email/verify_email_screen.dart';
import '../../presentation/screens/authentication/splash/view/splash_screen.dart';
import '../../presentation/screens/authentication/welcome/view/welcome_screen.dart';
import '../../presentation/screens/beneficiary/view/create_beneficiary/create_beneficiary_screen.dart';
import '../../presentation/screens/beneficiary/view/update_beneficiary/update_beneficiary_screen.dart';
import '../../presentation/screens/bill_payment/view/airtime/airtime.dart';
import '../../presentation/screens/bill_payment/view/bill_payment_screen.dart';
import '../../presentation/screens/bill_payment/view/cable/cable.dart';
import '../../presentation/screens/bill_payment/view/electricity/electricity.dart';
import '../../presentation/screens/cash_out/view/cash_out_history/cash_out_history.dart';
import '../../presentation/screens/cash_out/view/cash_out_screen.dart';
import '../../presentation/screens/exchange/view/exchange_history/exchange_history.dart';
import '../../presentation/screens/exchange/view/exchange_screen.dart';
import '../../presentation/screens/gift_code/view/gift_code_screen.dart';
import '../../presentation/screens/gift_code/view/gift_redeem_history/gift_redeem_history.dart';
import '../../presentation/screens/gift_code/view/sub_sections/gift_history.dart';
import '../../presentation/screens/home/view/sub_sections/wallet_details/wallet_details.dart';
import '../../presentation/screens/make_payment/view/make_payment_history/make_payment_history.dart';
import '../../presentation/screens/make_payment/view/make_payment_screen.dart';
import '../../presentation/screens/qr_code/view/qr_code_screen.dart';
import '../../presentation/screens/referral/view/referral_screen.dart';
import '../../presentation/screens/referral/view/referral_tree/referral_tree.dart';
import '../../presentation/screens/referral/view/referred_friends/referred_friends.dart';
import '../../presentation/screens/request_money/view/request_money_history/request_money_history.dart';
import '../../presentation/screens/request_money/view/request_money_screen.dart';
import '../../presentation/screens/settings/view/change_password/change_password.dart';
import '../../presentation/screens/settings/view/id_verification/id_verification.dart';
import '../../presentation/screens/settings/view/id_verification/kyc_history/kyc_history.dart';
import '../../presentation/screens/settings/view/notifications/notifications.dart';
import '../../presentation/screens/settings/view/profile_settings/profile_settings.dart';
import '../../presentation/screens/settings/view/support_tickets/add_new_ticket/add_new_ticket.dart';
import '../../presentation/screens/settings/view/support_tickets/support_tickets.dart';
import '../../presentation/screens/settings/view/two_factor_authentication/two_factor_authentication.dart';
import '../../presentation/screens/transactions/view/transactions_screen.dart';
import '../../presentation/screens/transfer/view/transfer_history/transfer_history.dart';
import '../../presentation/screens/transfer/view/transfer_received_history/transfer_received_history.dart';
import '../../presentation/screens/transfer/view/transfer_screen.dart';
import '../../presentation/screens/virtual_card/view/virtual_card_screen.dart';
import '../../presentation/screens/wallets/view/create_new_wallet/create_new_wallet.dart';
import '../../presentation/screens/wallets/view/wallets_screen.dart';
import '../../presentation/screens/withdraw/view/withdraw_history/withdraw_history.dart';
import '../../presentation/screens/withdraw/view/withdraw_screen.dart';
import '../../presentation/widgets/no_internet_connection.dart';
import '../navigation/navigation_screen.dart';

class RoutesConfig {
  static const splash = SplashScreen();

  static const welcome = WelcomeScreen();

  static const signIn = SignInScreen();

  static const twoFactorAuth = TwoFactorAuth();

  static const email = EmailScreen();

  static const verifyEmail = VerifyEmailScreen();

  static const personalInfo = PersonalInfoScreen();

  static const authIdVerification = AuthIdVerificationScreen();

  static const forgotPassword = ForgotPasswordScreen();

  static const forgotPasswordPinVerification = ForgotPasswordPinVerification();

  static const resetPassword = ResetPassword();

  static const navigation = NavigationScreen();

  static const signUpStatus = SignUpStatusScreen();

  static const setUpPassword = SetUpPasswordScreen();

  static const wallets = WalletsScreen();

  static const createNewWallet = CreateNewWallet();

  static const qrCode = QrCodeScreen();

  static const addMoney = AddMoneyScreen();

  static const makePayment = MakePaymentScreen();

  static const requestMoney = RequestMoneyScreen();

  static const giftCode = GiftCodeScreen();

  static const transfer = TransferScreen();

  static const cashOut = CashOutScreen();

  static const withdraw = WithdrawScreen();

  static const exchange = ExchangeScreen();

  static const transactions = TransactionsScreen();

  static const referral = ReferralScreen();

  static const referredFriends = ReferredFriends();

  static const referralTree = ReferralTree();

  static const profileSettings = ProfileSettings();

  static const walletDetails = WalletDetails();

  static const changePassword = ChangePassword();

  static const twoFactorAuthentication = TwoFactorAuthentication();

  static const notifications = Notifications();

  static const supportTickets = SupportTickets();

  static const kycHistory = KycHistory();

  static const addNewTicket = AddNewTicket();

  static const giftHistory = GiftHistory();

  static const idVerification = IdVerification();

  static const addMoneyHistory = AddMoneyHistory();

  static const makePaymentHistory = MakePaymentHistory();

  static const transferHistory = TransferHistory();

  static const transferReceivedHistory = TransferReceivedHistory();

  static const cashOutHistory = CashOutHistory();

  static const withdrawHistory = WithdrawHistory();

  static const exchangeHistory = ExchangeHistory();

  static const requestMoneyHistory = RequestMoneyHistory();

  static const giftRedeemHistory = GiftRedeemHistory();

  static const createBeneficiary = CreateBeneficiaryScreen();

  static const updateBeneficiary = UpdateBeneficiaryScreen();

  static const noInternetConnection = NoInternetConnection();

  static const billPayment = BillPaymentScreen();

  static const airtime = Airtime();

  static const electricity = Electricity();

  static const internet = Internet();

  static const dataBundle = DataBundle();

  static const cable = Cable();

  static const toll = Toll();

  static const virtualCard = VirtualCardScreen();

  static const createVirtualCard = CreateVirtualCard();

  static const virtualCardDetails = VirtualCardDetails();

  static const billPaymentHistory = BillPaymentHistory();

  static const getCardInfo = GetCardInfo();

  static const virtualCardTransaction = VirtualCardTransaction();

  static const paymentLinks = PaymentLinksScreen();

  static const giftCard = GiftCardScreen();

  static const maintenanceMode = MaintenanceMode();

  static const p2pTrading = P2pViewScreen();
}
