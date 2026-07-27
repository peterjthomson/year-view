# Year View

**Year-at-a-glance calendar companion** for **macOS, iOS, and iPadOS**.

Year View is intentionally read-only: it displays events from Apple Calendar (EventKit) and deep-links to native apps for viewing/creating/editing.

<img width="2752" height="2064" alt="iPad Screenshot 1" src="https://github.com/user-attachments/assets/0489c616-dc74-4531-9c66-043770549b7a" />

## Download

**iOS & iPadOS App Store:** [Year View Planner](https://apps.apple.com/us/app/year-view-planner/id6757597694)

**macOS App Store:** [Year View Planner](https://apps.apple.com/us/app/year-view-planner/id6757597694?platform=mac)

**macOS direct download:** [Download the latest macOS release](https://github.com/peterjthomson/year-view/releases/latest) — notarized and signed, universal binary (Apple Silicon + Intel)

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
- `YearViewTests` (unit tests)

## CI

GitHub Actions builds the iOS and macOS app and runs the unit test suite via `.github/workflows/ci.yml`.
