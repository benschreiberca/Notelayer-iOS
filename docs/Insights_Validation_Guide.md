# Insights Validation Guide

This guide covers validation for the `Insights` tab implementation.

## Automated Checks

Run from repository root:

```bash
cd ios-swift/Notelayer
xcodebuild -workspace Notelayer.xcworkspace -scheme NotelayerInsightsTests -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 17' test
xcodebuild -workspace Notelayer.xcworkspace -scheme Notelayer -configuration Debug -destination 'generic/platform=iOS Simulator' ARCHS=arm64 ONLY_ACTIVE_ARCH=YES COMPILER_INDEX_STORE_ENABLE=NO build
```

## Unit Test Coverage

`NotelayerInsightsTests` validates:

- snapshot totals and oldest-open task logic
- rolling window boundary inclusion (`7/30/60/180/365` semantics)
- category stats including uncategorized and zero-count categories
- category-level calendar export rate denominator math
- timezone-offset bucket behavior (DST transition scenarios)
- feature ranking tie-break determinism
- gap classification (`Unused` / `Underused` / `Used`)
- telemetry scope isolation across users
- raw-event compaction into aggregate buckets
- stress fixture aggregation over `5,000` tasks and `50,000` telemetry events

## Accessibility Checklist (Manual)

Run these checks in the simulator and on at least one device:

- Dynamic Type:
  - verify Insights overview cards and segmented window picker at default and largest accessibility text sizes
  - verify trend card header reflows in accessibility text sizes (title + segmented control)
- Contrast:
  - verify chart lines and text are readable in Light and Dark appearance modes
  - verify cards and metric pills remain legible against theme backgrounds
- Differentiate Without Color:
  - enable `Settings > Accessibility > Display & Text Size > Differentiate Without Color`
  - verify trend/time-of-day charts remain interpretable via line styles + legend
- Reduce Motion:
  - enable `Settings > Accessibility > Motion > Reduce Motion`
  - verify trend/time-of-day charts use reduced animation interpolation and no jarring transitions
- VoiceOver:
  - confirm focus order flows top-to-bottom through coverage, totals, overview charts, and drill-down links
  - confirm chart accessibility labels/values are announced with meaningful summaries

## Performance Fixture Notes

The stress fixture used by tests (`InsightsStressFixture`) generates deterministic high-volume input:

- `5,000` tasks
- `50,000` telemetry events

The corresponding unit test confirms the snapshot is produced with expected shape and completes under a guarded threshold to catch severe regressions.

For release profiling, use Instruments Time Profiler on physical device and validate these targets:

- initial Insights load (`<= 350ms` p95) for fixture-sized datasets
- window toggle response (`<= 120ms` p95)
- drill-down navigation/render (`<= 180ms` p95)

## Known Limits (v1)

- app-usage telemetry is local to each device (not cross-device merged)
- app-usage timeline starts from rollout on each device (no historical backfill before telemetry)
- task-history metrics use available task records, including tasks currently marked done
