# Issue: Build Times Regressed After Adding Analytics

## TL;DR
- Build step count jumped from ~2000 (v1.2) to ~7000 after adding Analytics; Debug and Release now take minutes.
- Likely driven by new Firebase Analytics + transitive deps (gRPC/BoringSSL/abseil/leveldb) and heavier Debug dSYM settings.

## Current State
- Xcode header shows ~7000 steps vs ~2000 previously.
- Builds take minutes (both Debug and Release).
- Regression started after adding Analytics.

## Expected Outcome
- Build steps and wall time return to near pre-Analytics levels (seconds, not minutes), or at least materially faster.

## Relevant Files
- ios-swift/Notelayer/Podfile
- ios-swift/Notelayer/Pods/Target Support Files/Pods-Notelayer/Pods-Notelayer.debug.xcconfig
- ios-swift/Notelayer/Notelayer.xcodeproj/project.pbxproj

## Notes / Hypotheses
- Firebase Analytics pulls in large transitive deps (gRPC-C++, BoringSSL, abseil, leveldb), which add thousands of compile steps.
- Debug config is set to generate dSYMs (DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym") which can significantly slow Debug builds.
- Podfile sets CLANG_DISABLE_DEPENDENCY_SCAN = YES, which may reduce incremental build effectiveness.

## Labels
- Type: improvement
- Priority: normal
- Effort: medium
