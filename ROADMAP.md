# macos.rb/ROADMAP.md

The discrete jobs are in TODO. This holds the direction: what is larger than one change, or not yet decided.

## Accounts as configuration profiles

Mail (IMAP and SMTP), calendar (CalDAV) and contacts (CardDAV) accounts, written as configuration profiles and installed through MDM, macOS no longer installing a profile from the command line nor keeping its accounts in a plist which can be edited.

Undecided:

- Whether reading the accounts already set up belongs here too, it wanting Full Disk Access.
- How a profile's payloads are described: YAML, Ruby, or both.

## The Wi-Fi connection

airport -I is deprecated, and from macOS 14.4 on reports nothing, so MacOS::Apple80211 reads system_profiler SPAirPortDataType where airport gives nothing. That needs no privileges, but gives the channel and security in its own form, rather than airport's, and no network name, macOS redacting it from any program without location access.

Undecided:

- Whether to get the network's name back, through wdutil info, which wants sudo, or by asking for location access.
- Whether channel and link_auth give airport's form whichever source they come from.
- Whether Apple80211 keeps its name once it no longer reads Apple80211.framework's tool.

## Naming

An instance of MacOS::IfConfig is a network interface, which its name doesn't say.

Undecided:

- Whether to rename it, MacOS::NetworkInterface say, keeping IfConfig as an alias for a while, and when.
