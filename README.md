# Year View

**Year-at-a-glance calendar companion** for **macOS, iOS, and iPadOS**.

Year View is intentionally read-only: it displays events from Apple Calendar (EventKit) and deep-links to native apps for viewing/creating/editing.

## Docs

- `Documentation/GETTING_STARTED.md`
- `Documentation/ARCHITECTURE.md`
- `Documentation/API.md`
- `Documentation/LAUNCH.md`
- `Documentation/APP-STORE.md`

## Development

### Requirements

- Xcode 15+
- iOS 17+ / macOS 14+

### Open the project

- Open `YearView.xcodeproj`

### Build targets

Main target:
- `YearView` (multiplatform iOS/iPadOS/macOS app)

## CI

GitHub Actions builds the main target on macOS runners via `.github/workflows/ci.yml`.
