# Accrued

Accrued is a small native macOS menu-bar utility that makes scheduled salaried compensation visible during the workday. It is schedule-based: it does not inspect activity, track time, connect to calendars, or model taxes and deductions.

It supports macOS 13 or newer, annual or monthly compensation, one shared schedule for selected weekdays, and the current system locale/time zone.
The menu-bar amount can be configured to show today, the current week, month, or year; the panel includes all four periods.

## Run in Xcode

Open `Accrued.xcodeproj` in Xcode, select the Accrued scheme, and press Run. The app appears only in the menu bar; it intentionally has no Dock icon. Choose Settings from the menu-bar panel to edit the schedule and compensation.

## Command-line build and tests

```sh
xcodebuild -project Accrued.xcodeproj -scheme Accrued -configuration Debug build
xcodebuild -project Accrued.xcodeproj -scheme Accrued -configuration Debug test
```

The distributable app is at `dist/Accrued.app`. To produce it after a successful build:

```sh
xcodebuild -project Accrued.xcodeproj -scheme Accrued -configuration Debug \
  -derivedDataPath build build
ditto build/Build/Products/Debug/Accrued.app dist/Accrued.app
```

You can copy it to `/Applications` in Finder or with `cp -R dist/Accrued.app /Applications/`. Because this app is unsigned, macOS Gatekeeper will warn when it is opened from a public/untrusted distribution; use the contextual Open command or remove the quarantine attribute only when you trust the source.

## Limitations

Version 1 does not include launch-at-login, holidays, split shifts, lunch deductions, calendar integration, PTO, clock-in/out, pausing, networking, accounts, or a database.
