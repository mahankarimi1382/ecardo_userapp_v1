import json
import csv
import os

base_dir = os.path.abspath(".")
output_page_inventory = os.path.join(base_dir, "docs", "uiux", "PAGE_INVENTORY.csv")
audit_matrix_path = r"C:\Users\talas\OneDrive\Desktop\ecardo\docs\uiux_upgrade_pack_20261019\ecardo_uiux_upgrade_pack\03_PAGE_INVENTORY_AND_AUDIT_MATRIX.csv"

with open("tools/routes_classified.json", "r", encoding="utf-8") as f:
    routes = json.load(f)

# Ensure docs/uiux exists
os.makedirs(os.path.dirname(output_page_inventory), exist_ok=True)

# Generate PAGE_INVENTORY.csv
# Headers: id,domain,route_constant,route_path,screen_file,controller_file,binding_file,priority,notes

page_rows = []
for i, r in enumerate(routes, 1):
    pid = f"PAGE-{i:03d}"
    domain = r['domain']
    r_const = r['route_constant']
    r_path = r['route_path']
    screen_f = r['screen_file']
    
    # Clean controller files
    ctrl_files = []
    for cf in r['controller_files']:
        if not cf.startswith("UNKNOWN") and os.path.exists(cf):
            ctrl_files.append(cf)
    
    # Special inline cases
    if r_const == "BaseRoute.replayTicket" and not ctrl_files:
        ctrl_files = ["lib/src/presentation/screens/settings/controller/reply_ticket_controller.dart"]
    elif r_const == "BaseRoute.appUpdate" and not ctrl_files:
        ctrl_files = ["lib/src/presentation/screens/app_update/controller/app_update_controller.dart"]
        
    ctrl_str = ";".join(dict.fromkeys(ctrl_files)) if ctrl_files else "none"
    
    # Clean binding files
    b_files = []
    for bf in r['binding_files']:
        if not bf.startswith("UNKNOWN") and os.path.exists(bf):
            b_files.append(bf)
    b_str = ";".join(dict.fromkeys(b_files)) if b_files else "none"
    
    priority = r['priority']
    notes = r['notes']
    if r_const == "BaseRoute.replayTicket":
        notes += " (Controller registered inline via Get.put)"
    elif r_const == "BaseRoute.navigation":
        notes += " (Bottom navigation shell registering 8 bindings)"
    elif r_const == "BaseRoute.localeTransition":
        notes += " (Language switch waypoint without controller to avoid tree crash)"

    page_rows.append([
        pid,
        domain,
        r_const,
        r_path,
        screen_f,
        ctrl_str,
        b_str,
        priority,
        notes
    ])

with open(output_page_inventory, "w", encoding="utf-8", newline="") as f:
    writer = csv.writer(f)
    writer.writerow([
        "id",
        "domain",
        "route_constant",
        "route_path",
        "screen_file",
        "controller_file",
        "binding_file",
        "priority",
        "notes"
    ])
    writer.writerows(page_rows)

print(f"Generated {output_page_inventory} with {len(page_rows)} routes.")

# Now update 03_PAGE_INVENTORY_AND_AUDIT_MATRIX.csv
matrix_route_mapping = [
    # Row 1: Home/dashboard overview
    "BaseRoute.navigation (/navigation_route)",
    # Row 2: Account summary/portfolio
    "BaseRoute.walletsDetails (/wallet_details_route)",
    # Row 3: Quick action router
    "BaseRoute.services (/services_route)",
    # Row 4: Wallet/account list
    "BaseRoute.wallets (/wallets_route)",
    # Row 5: Wallet/account detail
    "BaseRoute.walletsDetails (/wallet_details_route)",
    # Row 6: Create wallet/account
    "BaseRoute.createNewWallet (/create_new_wallet_route)",
    # Row 7: Switch account/currency
    "BaseRoute.wallets (/wallets_route)",
    # Row 8: Wallet address/details
    "BaseRoute.walletsDetails (/wallet_details_route)",
    # Row 9: Card list
    "BaseRoute.virtualCard (/virtual_card_route)",
    # Row 10: Card detail
    "BaseRoute.virtualCardDetails (/virtual_card_details_route)",
    # Row 11: Create virtual card
    "BaseRoute.createVirtualCard (/create_virtual_card_route)",
    # Row 12: Card review/initial funding
    "BaseRoute.getCardInfo (/get_card_info_route)",
    # Row 13: Card funding/top-up
    "BaseRoute.virtualCardTransaction (/virtual_card_transaction_route)",
    # Row 14: Freeze/unfreeze/limits
    "BaseRoute.virtualCardDetails (/virtual_card_details_route)",
    # Row 15: Transfer form
    "BaseRoute.transfer (/transfer_route)",
    # Row 16: Transfer review
    "BaseRoute.transfer (/transfer_route)",
    # Row 17: Transfer passcode/auth
    "BaseRoute.dynamicPassword (/dynamic_password_route)",
    # Row 18: Transfer result/status
    "BaseRoute.transferHistory (/transfer_history_route)",
    # Row 19: P2P pay/request
    "BaseRoute.p2pTrading (/p2p_trading_route)",
    # Row 20: Beneficiary/contact list
    "BaseRoute.createBeneficiary (/create_beneficiary_route); BaseRoute.updateBeneficiary (/update_beneficiary_route)",
    # Row 21: Exchange form
    "BaseRoute.exchange (/exchange_route)",
    # Row 22: Exchange quote/review
    "BaseRoute.exchange (/exchange_route)",
    # Row 23: Exchange result/reconcile
    "BaseRoute.exchangeHistory (/exchange_history_route)",
    # Row 24: Withdraw form/review
    "BaseRoute.withdraw (/withdraw_route)",
    # Row 25: Cash-out agent flow
    "BaseRoute.cashOut (/cash_out_route)",
    # Row 26: Merchant payment/review
    "BaseRoute.makePayment (/make_payment_route)",
    # Row 27: QR display/scan
    "BaseRoute.qrCode (/qr_code_route)",
    # Row 28: Request money
    "BaseRoute.requestMoney (/request_money_route)",
    # Row 29: Crypto wallet selector
    "BaseRoute.wallets (/wallets_route)",
    # Row 30: Crypto deposit address/QR
    "BaseRoute.addMoney (/add_money_route)",
    # Row 31: Crypto withdraw review
    "BaseRoute.withdraw (/withdraw_route)",
    # Row 32: Deposit history/status
    "BaseRoute.addMoneyHistory (/add_money_history_route)",
    # Row 33: Network/asset unsupported
    "BaseRoute.walletsDetails (/wallet_details_route)",
    # Row 34: Transaction list
    "BaseRoute.transactions (/transactions_route)",
    # Row 35: Transaction detail
    "BaseRoute.transactions (/transactions_route)",
    # Row 36: Receipt/share/download
    "BaseRoute.transactions (/transactions_route)",
    # Row 37: Bill catalog/list
    "BaseRoute.billPayment (/bill_payment_route)",
    # Row 38: Bill payment review
    "BaseRoute.billPayment (/bill_payment_route); BaseRoute.airtime (/airtime_route); BaseRoute.electricity (/electricity_route); BaseRoute.internet (/internet_route); BaseRoute.dataBundle (/data_bundle_route); BaseRoute.cable (/cable_route); BaseRoute.toll (/toll_route)",
    # Row 39: Travel/service list
    "BaseRoute.travel (/travel_route); BaseRoute.tourHome (/tour_home_route); BaseRoute.commercialProjects (/commercial_projects_route); BaseRoute.boatCatalog (/boat_catalog_route); BaseRoute.localCatalog (/local_catalog_route); BaseRoute.diningCatalog (/dining_catalog_route)",
    # Row 40: Order/booking detail
    "BaseRoute.travelHistory (/travel_history_route); BaseRoute.tourDetail (/tour_detail_route); BaseRoute.tourMyBookings (/tour_my_bookings_route); BaseRoute.commercialProjectDetail (/commercial_project_detail_route); BaseRoute.commercialMyInvestments (/commercial_my_investments_route); BaseRoute.boatVoucher (/boat_voucher_route); BaseRoute.localVoucher (/local_voucher_route); BaseRoute.diningOrderPass (/dining_order_pass_route)",
    # Row 41: Splash/bootstrap
    "BaseRoute.splash (/splash_route)",
    # Row 42: Onboarding/welcome
    "BaseRoute.welcome (/welcome_route)",
    # Row 43: Login
    "BaseRoute.signIn (/sign_in_route)",
    # Row 44: OTP/re-send
    "BaseRoute.emailOtpLogin (/email_otp_login_route)",
    # Row 45: Forgot/recover account
    "BaseRoute.forgotPassword (/forgot_password_route); BaseRoute.forgotPasswordPinVerification (/forgot_password_pin_verification_route); BaseRoute.resetPassword (/reset_password_route)",
    # Row 46: Passcode setup/reset
    "BaseRoute.setUpPassword (/set_up_password_route)",
    # Row 47: Biometric unlock
    "BaseRoute.twoFactorAuth (/two_factor_auth_route)",
    # Row 48: Session expired/re-auth
    "BaseRoute.signIn (/sign_in_route)",
    # Row 49: Profile summary/edit
    "BaseRoute.profileSettings (/profile_settings_route)",
    # Row 50: KYC documents/status
    "BaseRoute.kycSubmitWizard (/kyc_submit_wizard_route); BaseRoute.kycHistory (/kyc_history_route); BaseRoute.upgradeRequired (/upgrade_required_route)",
    # Row 51: Security settings dashboard
    "BaseRoute.permissionsSettings (/permissions_settings_route); BaseRoute.twoFactorAuthentication (/two_factor_authentication_route); BaseRoute.changePassword (/change_password_route)",
    # Row 52: Active sessions/device list
    "BaseRoute.deviceSessionsSecurity (/device_sessions_security_route)",
    # Row 53: Notification inbox
    "BaseRoute.notifications (/notifications_route)",
    # Row 54: Rewards/points
    "BaseRoute.referral (/referral_route); BaseRoute.referredFriends (/referred_friends_route); BaseRoute.referralTree (/referral_tree_route)",
    # Row 55: Language selector
    "BaseRoute.localeTransition (/locale_transition_route)",
    # Row 56: Theme/accessibility
    "BaseRoute.profileSettings (/profile_settings_route)",
    # Row 57: Privacy/consent
    "BaseRoute.privacyPolicy (/privacy_policy_route)",
    # Row 58: Help/FAQ
    "BaseRoute.supportTickets (/support_tickets_route)",
    # Row 59: Support tickets/chat
    "BaseRoute.supportTickets (/support_tickets_route); BaseRoute.addNewTicket (/add_new_ticket_route); BaseRoute.replayTicket (/replay_ticket_route)",
    # Row 60: Privacy/terms/about
    "BaseRoute.privacyPolicy (/privacy_policy_route)",
    # Row 61: Network/offline banner
    "BaseRoute.noInternetConnection (/no_internet_connection)",
    # Row 62: Maintenance/feature unavailable
    "BaseRoute.maintenanceMode (/maintenance_mode_route)",
    # Row 63: Generic error/recovery
    "BaseRoute.noInternetConnection (/no_internet_connection)",
    # Row 64: Empty state component
    "BaseRoute.navigation (/navigation_route)",
    # Row 65: Skeleton/loading components
    "BaseRoute.splash (/splash_route)",
    # Row 66: Dialog/bottom sheet family
    "BaseRoute.navigation (/navigation_route)",
    # Row 67: Forms and amount input
    "BaseRoute.transfer (/transfer_route)",
    # Row 68: Navigation/deep links
    "BaseRoute.navigation (/navigation_route)",
    # Row 69: App lock/foreground resume
    "BaseRoute.deviceSessionsSecurity (/device_sessions_security_route)",
    # Row 70: Global search/filter patterns
    "BaseRoute.transactions (/transactions_route)",
]

# Read original matrix
with open(audit_matrix_path, "r", encoding="utf-8-sig") as f:
    reader = csv.reader(f)
    matrix_rows = list(reader)

header = matrix_rows[0]
print(f"Audit matrix header: {header}")

for i, row in enumerate(matrix_rows[1:], 0):
    if i < len(matrix_route_mapping):
        row[3] = matrix_route_mapping[i]

with open(audit_matrix_path, "w", encoding="utf-8", newline="") as f:
    writer = csv.writer(f)
    writer.writerows(matrix_rows)

print(f"Updated {audit_matrix_path} successfully ({len(matrix_rows)-1} rows updated).")
