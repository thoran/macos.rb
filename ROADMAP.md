# macos.rb/ROADMAP.md

The discrete jobs are in TODO, and what is undecided in PROPOSED.md. This holds the direction: what is larger than one change.

## Accounts as configuration profiles

Mail (IMAP and SMTP), calendar (CalDAV) and contacts (CardDAV) accounts, written as configuration profiles and installed through MDM, macOS no longer installing a profile from the command line nor keeping its accounts in a plist which can be edited.

## The Wi-Fi connection

airport -I is deprecated, and from macOS 14.4 on reports nothing, so MacOS::Apple80211 reads system_profiler SPAirPortDataType where airport gives nothing. That needs no privileges, but gives the channel and security in its own form, rather than airport's, and no network name, macOS redacting it from any program without location access.
