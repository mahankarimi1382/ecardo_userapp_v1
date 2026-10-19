import re

files_to_check = [
    ('BaseRoute.welcome', 'lib/src/presentation/screens/authentication/welcome/view/welcome_screen.dart'),
    ('BaseRoute.permissionsSettings', 'lib/src/presentation/screens/settings/view/permissions_settings_screen.dart'),
    ('BaseRoute.privacyPolicy', 'lib/src/presentation/screens/settings/view/privacy_policy_screen.dart'),
    ('BaseRoute.deviceSessionsSecurity', 'lib/src/presentation/screens/device_sessions_security/view/device_sessions_security_screen.dart'),
    ('BaseRoute.replayTicket', 'lib/src/presentation/screens/settings/view/support_tickets/replay_ticket/replay_ticket.dart'),
    ('BaseRoute.noInternetConnection', 'lib/src/presentation/widgets/no_internet_connection.dart'),
    ('BaseRoute.billPayment', 'lib/src/presentation/screens/bill_payment/view/bill_payment_screen.dart'),
    ('BaseRoute.getCardInfo', 'lib/src/presentation/screens/virtual_card/view/get_card_info/get_card_info.dart'),
    ('BaseRoute.maintenanceMode', 'lib/src/presentation/widgets/maintenance_mode.dart'),
    ('BaseRoute.upgradeRequired', 'lib/src/presentation/screens/kyc_level/view/upgrade_required_screen.dart'),
    ('BaseRoute.appUpdate', 'lib/src/presentation/screens/app_update/view/app_update_screen.dart'),
    ('BaseRoute.localeTransition', 'lib/src/app/views/locale_transition_screen.dart'),
    ('BaseRoute.remittanceTrack', 'lib/src/remitv2/screens/remittance_track_screen.dart'),
]

for rname, fpath in files_to_check:
    with open(fpath, 'r', encoding='utf-8') as f:
        content = f.read()
    puts = re.findall(r'Get\.(?:put|lazyPut|find)<([A-Za-z0-9_]+)>', content)
    # also check extends GetView<Foo>
    getview = re.findall(r'extends\s+GetView<([A-Za-z0-9_]+)>', content)
    print(f"{rname}: puts={puts}, getview={getview}")
