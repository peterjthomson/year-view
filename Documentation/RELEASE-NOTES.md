# Release notes

## 1.4.0

- Show multiple events in separate rows in the Months view when space permits
  ([#9](https://github.com/peterjthomson/year-view/issues/9)).
- Add a saved 1–24 pt event text size setting for Months and Year views. Choose
  1 pt for thin colored lines without titles
  ([#10](https://github.com/peterjthomson/year-view/issues/10)).
- Preserve multi-day bars through overlapping events, exclude all-day events
  from the week after they end, and prevent timed events ending at midnight from
  extending into the next day.
- Show hidden-event counts, or a dot in very compact cells, when events do not
  fit. Select a day to see all its events.
- Fix an empty day-detail sheet on the first day selection after launch.
- Open day details from search results while preserving the search underneath.

### Validation note for issue #11

The overlap and week-boundary failures were reproduced with failing tests before
the fixes. The standalone date ranges inferred from the
[#11 screenshots](https://github.com/peterjthomson/year-view/issues/11) already
passed on the starting branch. The reporter's original event data is still
needed to confirm that the reported case has the same cause.
