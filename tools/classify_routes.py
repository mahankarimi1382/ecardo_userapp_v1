import json
import csv

with open("tools/routes_summary.json", "r", encoding="utf-8") as f:
    routes = json.load(f)

# Define domain and priority rules
def classify_route(r):
    name = r['route_constant'].replace('BaseRoute.', '')
    path = r['route_path']
    widget = r['screen_widget']
    
    # Defaults
    domain = "General"
    priority = "P1"
    notes = ""
    
    # Auth
    if name in ['root', 'splash']:
        domain = "Auth" if name == 'splash' else "Global State"
        priority = "P1"
        notes = "App bootstrap & splash screen" if name == 'splash' else "App root entry point"
    elif name in ['welcome']:
        domain = "Auth"
        priority = "P2"
        notes = "Onboarding welcome carousel / landing"
    elif name in ['signIn', 'emailOtpLogin', 'twoFactorAuth']:
        domain = "Auth"
        priority = "P0"
        notes = "Primary authentication & MFA challenge"
    elif name in ['email', 'verifyEmail', 'signUpStatus', 'setUpPassword', 'personalInfo', 'authIdVerification']:
        domain = "Auth"
        priority = "P0" if name in ['email', 'verifyEmail', 'setUpPassword'] else "P1"
        notes = f"User registration flow: {name}"
    elif name in ['forgotPassword', 'forgotPasswordPinVerification', 'resetPassword']:
        domain = "Auth"
        priority = "P0" if name == 'resetPassword' else "P1"
        notes = f"Password recovery flow: {name}"
        
    # Home & Hub
    elif name == 'navigation':
        domain = "Home"
        priority = "P0"
        notes = "Main shell with bottom navigation bar & dashboard tabs"
    elif name == 'services':
        domain = "Home"
        priority = "P1"
        notes = "Services hub grid for all modular financial and travel services"
        
    # Wallets
    elif name in ['wallets', 'walletsDetails', 'createNewWallet']:
        domain = "Wallets"
        priority = "P0" if name in ['wallets', 'walletsDetails'] else "P1"
        notes = f"Wallet management: {name}"
        
    # Transfers
    elif name in ['transfer', 'transferHistory', 'transferReceivedHistory']:
        domain = "Transfers"
        priority = "P0" if name == 'transfer' else "P1"
        notes = f"Money transfer & history: {name}"
    elif name in ['requestMoney', 'requestMoneyHistory']:
        domain = "Transfers"
        priority = "P1"
        notes = f"Request money & history: {name}"
    elif name in ['createBeneficiary', 'updateBeneficiary']:
        domain = "Transfers"
        priority = "P1"
        notes = f"Beneficiary management: {name}"
        
    # Payments
    elif name in ['addMoney', 'addMoneyHistory']:
        domain = "Payments"
        priority = "P0" if name == 'addMoney' else "P1"
        notes = f"Deposit / Add money flow: {name}"
    elif name in ['makePayment', 'makePaymentHistory']:
        domain = "Payments"
        priority = "P0" if name == 'makePayment' else "P1"
        notes = f"Merchant payment flow: {name}"
    elif name == 'qrCode':
        domain = "Payments"
        priority = "P1"
        notes = "QR code display and scanning"
    elif name == 'paymentLinks':
        domain = "Payments"
        priority = "P1"
        notes = "Payment links creation and management"
        
    # Cards
    elif name in ['virtualCard', 'createVirtualCard', 'virtualCardDetails', 'getCardInfo', 'virtualCardTransaction']:
        domain = "Cards"
        priority = "P0" if name in ['virtualCard', 'createVirtualCard', 'virtualCardDetails', 'virtualCardTransaction'] else "P1"
        notes = f"Virtual card operations: {name}"
    elif name in ['giftCard', 'giftCode', 'giftHistory', 'giftRedeemHistory']:
        domain = "Cards"
        priority = "P1" if name in ['giftCard', 'giftCode'] else "P2"
        notes = f"Gift cards & gift codes: {name}"
        
    # Withdraw & Cash Out
    elif name in ['withdraw', 'withdrawHistory']:
        domain = "Withdraw/Cash out"
        priority = "P0" if name == 'withdraw' else "P1"
        notes = f"Withdrawal flow: {name}"
    elif name in ['cashOut', 'cashOutHistory']:
        domain = "Withdraw/Cash out"
        priority = "P0" if name == 'cashOut' else "P1"
        notes = f"Cash-out flow: {name}"
        
    # Exchange
    elif name in ['exchange', 'exchangeHistory']:
        domain = "Exchange"
        priority = "P0" if name == 'exchange' else "P1"
        notes = f"Currency exchange flow: {name}"
        
    # Activity
    elif name == 'transactions':
        domain = "Activity"
        priority = "P0"
        notes = "Transaction history and activity audit log"
        
    # Bills / Utility Payments
    elif name in ['billPayment', 'billPaymentHistory', 'airtime', 'electricity', 'internet', 'dataBundle', 'cable', 'toll']:
        domain = "Bills/Services"
        priority = "P0" if name in ['airtime', 'electricity', 'internet'] else "P1"
        notes = f"Utility & bill payment: {name}"
        
    # P2P
    elif name == 'p2pTrading':
        domain = "P2P"
        priority = "P0"
        notes = "Peer-to-peer crypto and fiat trading"
        
    # Remittance
    elif name in ['remittance', 'remittanceHistory', 'remittanceDetails', 'remittanceTrack']:
        domain = "Remittance"
        priority = "P0" if name == 'remittance' else "P1"
        notes = f"Cross-border remittance flow: {name}"
        
    # KYC & Profile
    elif name in ['kycHistory', 'idVerification', 'kycSubmitWizard', 'upgradeRequired']:
        domain = "KYC/Profile"
        priority = "P0" if name == 'kycSubmitWizard' else "P1"
        notes = f"KYC verification & tier upgrade: {name}"
    elif name == 'profileSettings':
        domain = "KYC/Profile"
        priority = "P1"
        notes = "User profile settings & account info"
        
    # Security
    elif name in ['changePassword', 'twoFactorAuthentication', 'dynamicPassword', 'deviceSessionsSecurity', 'permissionsSettings']:
        domain = "Security"
        priority = "P0" if name in ['dynamicPassword'] else ("P1" if name in ['changePassword', 'twoFactorAuthentication'] else "P2")
        notes = f"Security controls & authentication: {name}"
        
    # Notifications
    elif name == 'notifications':
        domain = "Notifications"
        priority = "P1"
        notes = "In-app notifications inbox"
        
    # Rewards / Referral
    elif name in ['referral', 'referredFriends', 'referralTree']:
        domain = "Rewards"
        priority = "P2"
        notes = f"Referral & reward program: {name}"
        
    # Support
    elif name in ['supportTickets', 'addNewTicket', 'replayTicket']:
        domain = "Support"
        priority = "P1"
        notes = f"Customer support tickets: {name}"
        
    # Global State / Settings
    elif name in ['privacyPolicy']:
        domain = "Legal"
        priority = "P2"
        notes = "Privacy policy & legal terms"
    elif name in ['localeTransition']:
        domain = "Settings"
        priority = "P2"
        notes = "Locale switch waypoint screen"
    elif name in ['noInternetConnection', 'maintenanceMode', 'appUpdate']:
        domain = "Global State"
        priority = "P1"
        notes = f"Global app state & exception handler: {name}"
        
    # Tours
    elif name.startswith('tour'):
        domain = "Tours"
        priority = "P0" if name in ['tourBook', 'tourPayment'] else ("P1" if name in ['tourDetail', 'tourHome', 'tourMyBookings'] else "P2")
        notes = f"Tour booking module: {name}"
        
    # Escrow
    elif name.startswith('escrow'):
        domain = "Escrow"
        priority = "P0" if name in ['escrowCreate', 'escrowPayment'] else "P1"
        notes = f"Escrow safe transaction module: {name}"
        
    # Visa
    elif name.startswith('visa'):
        domain = "Visa"
        priority = "P1" if name in ['visaHome', 'visaDetail', 'visaList'] else "P2"
        notes = f"Visa assistance service: {name}"
        
    # Stock
    elif name.startswith('stock'):
        domain = "Stock"
        priority = "P0" if name in ['stockOrder', 'stockConfirm'] else "P1"
        notes = f"Stock trading module: {name}"
        
    # Loan
    elif name.startswith('loan'):
        domain = "Loan"
        priority = "P0" if name in ['loanApplication', 'loanConfirm'] else "P1"
        notes = f"Loan & micro-credit module: {name}"
        
    # Guarantee
    elif name.startswith('guarantee'):
        domain = "Guarantee"
        priority = "P0" if name in ['guaranteeApplication', 'guaranteeConfirm'] else "P1"
        notes = f"Bank guarantee service: {name}"
        
    # Rental
    elif name.startswith('rental'):
        domain = "Rental"
        priority = "P1" if name in ['rentalHome', 'rentalDetail'] else "P2"
        notes = f"Car rental booking service: {name}"
        
    # License
    elif name.startswith('license'):
        domain = "License"
        priority = "P1" if name in ['licenseStore', 'licenseMyLicenses'] else "P2"
        notes = f"Software license store: {name}"
        
    # Commercial
    elif name.startswith('commercial'):
        domain = "Commercial"
        priority = "P0" if name == 'commercialInvestCheckout' else "P1"
        notes = f"Commercial equity & investment module: {name}"
        
    # Travel
    elif name.startswith('travel') or name.startswith('boat') or name.startswith('local') or name.startswith('dining'):
        domain = "Travel"
        priority = "P0" if name in ['diningOrderPass'] else "P1"
        notes = f"Travel & lifestyle service: {name}"
        
    return domain, priority, notes

# Verify classification
for r in routes:
    d, p, n = classify_route(r)
    r['domain'] = d
    r['priority'] = p
    r['notes'] = n

domain_counts = {}
priority_counts = {}
for r in routes:
    d = r['domain']
    p = r['priority']
    domain_counts[d] = domain_counts.get(d, 0) + 1
    priority_counts[p] = priority_counts.get(p, 0) + 1

print("Domain counts:")
for d, c in sorted(domain_counts.items(), key=lambda x: -x[1]):
    print(f"  {d}: {c}")

print("\nPriority counts:")
for p, c in sorted(priority_counts.items()):
    print(f"  {p}: {c}")

with open("tools/routes_classified.json", "w", encoding="utf-8") as f:
    json.dump(routes, f, indent=2, ensure_ascii=False)
