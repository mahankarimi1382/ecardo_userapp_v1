## 1.0.57+57

### Auth / Splash
- Biometric button restored on sign-in (hidden when unsupported / revoked)
- Form fade+slide entrance; dark-aware scaffold bg
- Inline validation errors (FA); network-specific login errors
- Login button spinner via CommonButton.isLoading
- After login: enable biometric when available; staged notification permission

### Permissions
- PermissionFlowService: rationale + Settings deep-link; notification/camera/photos JIT
- FCM token re-sync after notification grant

### Notifications
- Channels: ecardo_default (high) + ecardo_financial (max) + legacy channel_id
- Local history (SharedPreferences) survives logout
- Foreground: tray + in-app SnackBar banner + deep-link action

### Dashboard
- Header top inset from MediaQuery (no magic 60)
- UID LTR + copy SnackBar
- Uniform vertical spacing ~20; horizontal pad 16 on header
- Action icons 28px + FittedBox labels
- loadError + retry; skeleton retained; AlwaysScrollable refresh

Agent: external
