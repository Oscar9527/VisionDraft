# VisionDraft v0.2.1

## Added

- Portable Windows release refreshed with the latest desktop runtime.
- Safer local AI key handling through a platform secret store fallback on Windows.

## Improved

- PDF export preview now uses page-based wheel navigation in the validated desktop build.
- Windows packaging flow is more reproducible and now bundles the required runtime plugin files consistently.
- Desktop file and document services were refactored toward a cleaner cross-platform boundary for the ongoing Android work.

## Fixed

- Fixed the validated export preview behavior so wheel input turns pages instead of zooming the PDF preview.
- Fixed Windows runtime packaging issues that previously caused missing plugin DLL launch failures.
- Fixed repository-side project path and bundle handling for the current desktop workflow.

## Known Limitations

- This release still targets Windows desktop as the primary public deliverable.
- The installer asset is not attached in this patch release; portable package remains the primary downloadable artifact.
