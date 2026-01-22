# Privacy Policy

**Effective Date:** January 10, 2026  
**Last Updated:** January 10, 2026

## Overview

Year View ("the App") is a read-only calendar visualization app for macOS, iOS, and iPadOS. We are committed to protecting your privacy. This Privacy Policy explains how the App handles your information.

**The most important thing to know:** Year View does not collect, store, or transmit any of your personal data to our servers. All your data stays on your device.

## Data Collection and Storage

### What We Do NOT Collect

- We do **not** collect personal information
- The app does **not** include analytics or telemetry SDKs
- The app does **not** include crash-reporting SDKs
- We do **not** track your location
- We do **not** use advertising or ad tracking
- We do **not** have user accounts or registration
- We do **not** operate any servers that receive your data

### What Is Stored Locally on Your Device

The App stores the following data **locally on your device only**:

| Data Type | Storage Method | Purpose |
|-----------|----------------|---------|
| Calendar visibility | UserDefaults | Remember which calendars you've enabled |
| Last viewed year | UserDefaults | Saved locally (the app still opens to the current year) |
| Google OAuth tokens (if enabled) | Keychain | Securely authenticate with Google Calendar |

This data never leaves your device and is not accessible to us.

## Calendar Data Access

### Apple Calendar (EventKit)

Year View uses Apple's EventKit framework to read calendar data. This is a secure, on-device API provided by Apple:

- Calendar data is accessed **directly from your device's calendar database**
- No calendar data is transmitted to our servers
- We request **read-only** access to your calendars
- You control which calendars Year View can access through iOS/macOS Settings
- You can revoke calendar access at any time in your device's Privacy settings

### Google Calendar (Optional / Experimental)

If Google Calendar integration is enabled and you choose to connect a Google account:

- Authentication occurs **directly between your device and Google's servers** using OAuth 2.0
- We use read-only scopes (`calendar.readonly` and `calendar.events.readonly`)
- OAuth tokens are stored **securely in your device's Keychain**—they are never sent to us
- Calendar data is fetched **directly from Google's API to your device**
- We do not act as an intermediary and have no access to your Google data
- You can disconnect Google at any time, which removes stored tokens from your device
- Google's privacy practices are governed by [Google's Privacy Policy](https://policies.google.com/privacy)

### Event Creation and Editing

Year View is intentionally **read-only**. When you want to create or edit events, the App opens your native Calendar app using deep links. We never modify your calendar data directly.

## Third-Party Services

### Apple

- **EventKit**: On-device calendar access (no network transmission)
- **App Store**: App distribution and optional in-app purchases (governed by [Apple's Privacy Policy](https://www.apple.com/legal/privacy/))

### Google (Optional / Experimental)

- **Google Calendar API**: Direct device-to-Google communication for users who connect their Google account
- **Google OAuth**: Authentication handled directly by Google
- See [Google's Privacy Policy](https://policies.google.com/privacy) for how Google handles your data

We do not use any other third-party analytics, advertising, or tracking services.

## Data Security

- **Local Storage**: All local data is stored using Apple's secure UserDefaults and Keychain APIs
- **Keychain**: OAuth tokens are stored in the device's encrypted Keychain, protected by your device passcode/biometrics
- **No Transmission**: Since we don't collect data, there is no data transmission to secure
- **Transport Security**: Any network requests to Google Calendar API use HTTPS/TLS encryption

## Children's Privacy

Year View does not collect personal information from anyone, including children under 13. The App is safe for users of all ages.

## Your Rights and Choices

### Managing Calendar Access

You can manage Year View's access to your calendars at any time:

**iOS/iPadOS:**
Settings → Privacy & Security → Calendars → Year View

**macOS:**
System Settings → Privacy & Security → Calendars → Year View

### Deleting Local Data

To remove all locally stored preferences:
1. Delete the Year View app from your device
2. All associated UserDefaults data is automatically removed
3. Keychain items (Google tokens) are removed with app deletion

### Google Account Disconnection

To disconnect your Google account:
1. Sign out within Year View's settings, or
2. Revoke Year View's access at [Google Account Permissions](https://myaccount.google.com/permissions)

## Data Retention

- **Local preferences**: Retained until you delete the app or clear app data
- **Google tokens**: Retained until you sign out or delete the app
- **Calendar data**: Not retained—read fresh from EventKit (and Google API, if enabled) each time

We retain no data on any servers because we do not operate data-collecting servers.

## Changes to This Privacy Policy

We may update this Privacy Policy from time to time. We will notify you of any changes by:
- Updating the "Last Updated" date at the top of this policy
- Including release notes in App Store updates when significant changes occur

We encourage you to review this Privacy Policy periodically.

## Contact Us

If you have any questions about this Privacy Policy or Year View's privacy practices, please contact us:

**Email:** [your-email@example.com]

## Summary

| Question | Answer |
|----------|--------|
| Do you collect my data? | **No** |
| Do you sell my data? | **No** (we don't have it) |
| Do you use analytics? | **No** |
| Do you show ads? | **No** |
| Where is my data stored? | **On your device only** |
| Can I delete my data? | **Yes**, delete the app |
| Is my calendar data sent to your servers? | **No**, never |

---

*This privacy policy applies to Year View for iOS, iPadOS, and macOS.*
