### Added
- Added `assets/questions.json` to store quiz questions externally.
- Added a project `CHANGELOG.md`.

### Changed
- Reworked the quiz app structure to use JSON-driven questions instead of hardcoded data.
- Updated Flutter dependencies and asset configuration in `pubspec.yaml` / `pubspec.lock`.
- Updated iOS/macOS project files to match the new app structure and dependencies.
- Updated repository configuration files (`.gitignore`, `.gitattributes`).

### Removed
- Removed legacy quiz screens/widgets and summary components that were replaced by the new structure.
- Removed obsolete question data/model files that are no longer used.
- Removed the default/unused widget test.