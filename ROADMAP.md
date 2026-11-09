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

## What SystemProfiler gives

Each field of system_profiler's software overview has three methods in MacOS::SystemProfiler: one ending in _data, the field as given, one in _string, and a bare name. They differ only for System Version and Kernel Version, where _string gives the version alone and the bare name a Version. For the other seven, the three are the same.

Undecided, and waiting for a minor version or 1.0, since either way system_version and kernel_version would no longer return a Version:

- Whether a field has one method, giving the field as given unless an argument asks for another form, as system_version(as: :string) or system_version(as: :version). Only two fields have anything to interpret, and what is returned would turn on the argument.
- Or whether each method gives only the field as given, with no argument, and the interpreting is done outside SystemProfiler under names of its own, as MacOS.version is now, or in a class of its own. SystemProfiler would then give what system_profiler gives.
- Whether the names follow system_profiler's labels, as now, or the keys of its JSON (os_version, local_host_name, secure_vm, system_integrity, uptime), once SystemProfiler reads that. The leaning is the labels.

## Naming

An instance of MacOS::IfConfig is a network interface, which its name doesn't say.

Undecided:

- Whether to rename it, MacOS::NetworkInterface say, keeping IfConfig as an alias for a while, and when.
