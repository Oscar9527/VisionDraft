# VisionDraft v0.2.2

Baseline comparison: `v0.2.1`

## Added

- Added live preview editing for the shot sheet title.
- Added X/Y position sliders for fine-grained shot sheet title placement.
- Added grouped drag-and-move behavior for multiple selected shots in batch mode.

## Improved

- Scene headers in the shot sheet are now rendered as merged, centered full-width rows for clearer separation.
- Removed extra explanatory copy from the project library and export surfaces to keep the UI cleaner.
- Improved the Windows packaging flow so a missing `native_assets` directory no longer breaks the install staging step.

## Fixed

- Fixed the issue where shot sheet title edits did not refresh the preview immediately.
- Fixed the fallback behavior that still showed `分镜单` after the title field was cleared.
- Fixed the Windows release build pipeline so fresh desktop release packages are generated successfully.

## Known Limitations

- The current public deliverable still targets Windows desktop first.
- Android work is still in progress and this release does not include Android build artifacts.
