# Travel Screen Map

| Design file | Flutter screen | Navigation |
| --- | --- | --- |
| `ecardo_home_screen_redesign` | `TravelHomeScreen` | Super-app entry to hotel, flight, eSIM, activity, wallet, and account |
| `2` | `HotelSearchScreen` | Travel Home → Hotel Search |
| `1` | `HotelResultsScreen` | Hotel Search → Hotel Results |
| `3` | `HotelDetailsScreen` | Hotel Results → Hotel Details |
| `6` | `TravelOrdersScreen` filtered to hotels | Account → My Hotels |
| `7` | `TravelConfirmationScreen` for hotel | Checkout → Hotel Voucher |
| `14` | `FlightSearchScreen` | Travel Home → Flight Search |
| `13` | `FlightResultsScreen` | Flight Search → Flight Results |
| `8` | `FlightDetailsScreen` and `TravelCheckoutScreen` | Results → Passenger Review → Checkout |
| `9` | `TravelOrdersScreen` filtered to flights | Account → My Flights |
| `10` | `TravelConfirmationScreen` for flight | Checkout → Flight Ticket |
| `esim_2` | `EsimIntroScreen` | Travel Home → eSIM Introduction |
| `esim_1` | `EsimPackagesScreen` | Introduction → Package Selection |
| `esim_3` | `TravelConfirmationScreen` for eSIM | Checkout → Activation Details |
| `4` | `TravelOrdersScreen` filtered to eSIMs | Account → My eSIMs |
| `11` | `TravelersScreen` | Account → Saved Travelers |
| `12` | Existing authenticated `BaseRoute.profileSettings` | Account → Personal Information |
| `15` | `TravelAccountScreen` | Travel Home → Account Hub |
| `5` | `TravelHistoryScreen` | Account → Combined Travel and Wallet History |

## Primary Navigation

- Hotel: Home → Search → Results → Details → Wallet Checkout → Voucher
- Flight: Home → Search → Results → Passenger/Fare Review → Wallet Checkout → Ticket
- eSIM: Home → Introduction → Packages → Wallet Checkout → Activation Details

## Shared Components

- `TravelPage`: existing eCardo app bars plus a consistent responsive page shell.
- `TravelCard`: rounded surface, border, shadow, and optional tap behavior.
- `TravelFieldTile`: normalized search input presentation.
- `TravelSectionHeader`: section title and optional action.
- `CommonButton`: existing application button and loading behavior.
- Product helpers: hotel purple, flight blue, eSIM yellow, shared icons, LTR money/reference formatting.
