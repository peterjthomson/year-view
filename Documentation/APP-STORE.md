# App Store Connect Settings

This document provides the recommended settings for submitting Year View to the App Store.

## App Information

### Basic Info

| Field | Value |
|-------|-------|
| **Name** | Year View |
| **Subtitle** | Your Year at a Glance |
| **Bundle ID** | `com.yearview.app` |
| **SKU** | `yearview-ios-macos` |
| **Primary Language** | English (U.S.) |
| **Category** | Productivity |
| **Secondary Category** | Utilities (optional) |

### Content Rights

- [ ] Does your app contain, show, or access third-party content? **No**
- [ ] Does this app use encryption? **No** (unless using Google Calendar OAuth, then **Yes - exempt**)

---

## Age Rating

Answer all questions **No** to receive a **4+** rating.

| Question | Answer |
|----------|--------|
| Cartoon or Fantasy Violence | None |
| Realistic Violence | None |
| Prolonged Graphic or Sadistic Realistic Violence | None |
| Profanity or Crude Humor | None |
| Mature/Suggestive Themes | None |
| Horror/Fear Themes | None |
| Medical/Treatment Information | None |
| Alcohol, Tobacco, or Drug Use or References | None |
| Simulated Gambling | None |
| Sexual Content or Nudity | None |
| Graphic Sexual Content and Nudity | None |
| Unrestricted Web Access | No |
| Gambling and Contests | No |

**Expected Rating:** 4+

---

## App Privacy (Nutrition Label)

Year View collects **no data**. Select the following in App Store Connect:

### Data Collection

**"Data Not Collected"**

When asked "Do you or your third-party partners collect data from this app?", select **No**.

### Privacy Policy URL

You must provide a privacy policy URL even though no data is collected.

**Required:** Host `Documentation/PRIVACY.md` at a public URL, such as:
- GitHub Pages: `https://yourusername.github.io/year-view/PRIVACY`
- Your website: `https://yoursite.com/yearview/privacy`

### Calendar Access Explanation

Even though you select "Data Not Collected", App Review may ask about calendar access. Prepare this response:

> Year View uses Apple's EventKit framework to read calendar data directly from the user's device. No calendar data is transmitted to our servers or any third party. All processing occurs on-device. Users control which calendars are visible within the app, and can revoke access at any time via iOS/macOS Privacy settings.

---

## Screenshots Required

### iPhone

| Display Size | Dimensions | Devices |
|--------------|------------|---------|
| 6.7" | 1290 × 2796 | iPhone 15 Pro Max, 15 Plus, 14 Pro Max |
| 6.5" | 1284 × 2778 | iPhone 14 Plus, 13 Pro Max, 12 Pro Max |

**Note:** 6.7" screenshots also cover 6.1" devices. 6.5" screenshots are required for older devices.

### iPad

| Display Size | Dimensions | Devices |
|--------------|------------|---------|
| 12.9" (6th gen) | 2048 × 2732 | iPad Pro 12.9" |

**Note:** 12.9" screenshots also cover 11" iPad Pro and iPad Air.

### Mac

| Dimensions | Notes |
|------------|-------|
| 1280 × 800 minimum | Up to 2880 × 1800 |

**Recommended:** 2560 × 1600 (Retina-scaled)

### Screenshot Content

Suggested screenshots:
1. **Year Grid** - Full year displayed
2. **Day Detail** - Tap a day to see events
3. **Multiple Calendars** - Show calendar selection
4. **Customization** - Settings/color options

---

## App Review Information

### Demo Account

**Not required** - Year View uses device calendars, no login needed.

### Notes for Reviewer

Include this in the App Review Notes field:

```
Year View is a read-only calendar visualization app. It displays events from 
the user's existing calendars (via EventKit) in a year-at-a-glance format.

Key points for review:
• Calendar permission is required to display events
• No account or sign-in required
• All event creation/editing opens the native Calendar app via deep link
• No data is collected or transmitted to servers
• The app works offline once calendar access is granted

To test:
1. Grant calendar access when prompted
2. If no events exist, create a few in the Calendar app first
3. Return to Year View to see them displayed

```

### Contact Information

Provide a valid email for App Review to contact you if needed.

---

## Pricing and Availability

### Price

**Free** (no in-app purchases for v1.0)

### Availability

- [x] All territories (175 countries)
- [ ] Pre-order: No

### Distribution

- [x] iPhone
- [x] iPad
- [x] Mac (Apple Silicon and Intel via Universal)

---

## Version Information

### What's New (v1.0)

```
Introducing Year View — see your entire year at a glance.

• Five beautiful layouts: Year View, Month Rows, Grid, Row, and List
• Works with all your calendars: iCloud, Google, Exchange, and more
• Customizable colors for backgrounds, text, and gridlines
• Tap any day to see events, tap an event to open in Calendar
• Video call detection for Zoom, Meet, Teams, and Webex
• Full dark mode support
• Privacy-first: all data stays on your device
```

### Promotional Text (170 chars, can be updated without new build)

```
See your entire year in one beautiful view. Year View is the calendar companion that brings clarity to your schedule without the clutter.
```

---

## Build Settings Checklist

Before uploading your build, verify:

- [ ] **Version number** matches marketing version (e.g., 1.0)
- [ ] **Build number** is incremented from any previous uploads
- [ ] **App icon** is included (1024×1024 for iOS, all sizes for macOS)
- [ ] **Launch screen** is configured (or uses SwiftUI automatic)
- [ ] **Capabilities** match entitlements (Calendar, Network Client)
- [ ] **Archive** is created with "Generic iOS Device" or "Any Mac"

### Entitlements Reminder

Ensure `YearView.entitlements` contains:

```xml
<key>com.apple.security.app-sandbox</key>
<true/>
<key>com.apple.security.personal-information.calendars</key>
<true/>
<key>com.apple.security.network.client</key>
<true/>
```

---

## Common Rejection Reasons to Avoid

### 1. Missing Privacy Policy URL
**Prevention:** Host the privacy policy before submission.

### 2. Guideline 5.1.1 - Data Collection Disclosure
**Prevention:** Even though you collect nothing, be prepared to explain calendar access.

### 3. Guideline 2.1 - App Completeness
**Prevention:** Ensure the app works without an internet connection (EventKit is local).

### 4. Guideline 4.0 - Design (Minimum Functionality)
**Prevention:** Year View provides clear value beyond the native Calendar app (year-at-a-glance visualization). Highlight this in marketing.

### 5. Missing App Icon
**Prevention:** Add all required icon sizes before archiving.

---

## TestFlight Checklist

Before submitting for App Review, test via TestFlight:

- [ ] Fresh install (no prior calendar permission)
- [ ] Permission granted flow
- [ ] Permission denied flow (error message shown)
- [ ] Year navigation (swipe, year picker)
- [ ] Day detail view (tap day, see events)
- [ ] Event tap (opens Calendar app)
- [ ] Calendar selection (toggle calendars)
- [ ] Search functionality
- [ ] Settings persistence (survives app restart)
- [ ] Dark mode appearance
- [ ] iPad multitasking (Split View, Slide Over)
- [ ] Mac menu bar functionality
- [ ] Mac keyboard shortcuts

---

## Post-Submission

### Expected Timeline

- **App Review:** 24-48 hours typically
- **If rejected:** Address feedback and resubmit
- **If approved:** Release immediately or schedule

### After Approval

1. Update your privacy policy URL to the live App Store link
2. Announce on social media (see MARKETING.md)
3. Monitor App Store Connect for crash reports
4. Respond to user reviews
