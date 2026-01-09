# Year View

**Year-at-a-glance calendar companion** for **macOS, iOS, iPadOS, watchOS**, plus **widgets**.

Year View is intentionally read-only: it displays events from Apple Calendar (EventKit) and deep-links to native apps for viewing/creating/editing.

## Docs

- `Documentation/GETTING_STARTED.md`
- `Documentation/ARCHITECTURE.md`
- `Documentation/API.md`
- `Documentation/LAUNCH.md`

## Development

### Requirements

- Xcode 15+
- iOS 17+ / macOS 14+ / watchOS 10+

### Open the project

- Open `YearView.xcodeproj`

### Build targets

Main targets in this repo:
- `YearView` (multiplatform app)
- `YearViewWidgetExtension` (widgets)
- `YearView Watch App` (watchOS)

## CI

GitHub Actions builds the main targets on macOS runners via `.github/workflows/ci.yml`.
