# macos.rb/PROPOSED.md

The discrete jobs are in TODO, and the direction in ROADMAP.md. This holds what is undecided.

## Accounts as configuration profiles

- Whether reading the accounts already set up belongs here too, it wanting Full Disk Access.
- How a profile's payloads are described: YAML, Ruby, or both.

## The Wi-Fi connection

- Whether to get the network's name back, through wdutil info, which wants sudo, or by asking for location access.
- Whether channel and link_auth give airport's form whichever source they come from.
- Whether Apple80211 keeps its name once it no longer reads Apple80211.framework's tool.

## Naming

An instance of MacOS::IfConfig is a network interface, which its name doesn't say.

- Whether to rename it, MacOS::NetworkInterface say, keeping IfConfig as an alias for a while, and when.

## Without Version

MacOS.version and MacOS.kernel_version return a Version, taken from Version 0.14.0, which brings Array#second, Module#alias_methods and String#capture into every program loading macos.rb.

- Whether Version goes, or stays for MacOS.version and MacOS.kernel_version alone.

## A second form of shortcut for NSUserKeyEquivalents

assign_keys takes a shortcut as an Array, one key to an element, case ignored. A second form would be a String, after NeXTSTEP: the key as a character, Command implied, a capital meaning Shift, so D for Shift-Command-D, written @$d, as GNUstep's NSMenuItemCell and NSMenu treat it. macOS's menu symbols (⇧⌘D) are ruled out.

Settled, should it be done: it has a method of its own, rather than being told apart by type, since assign_keys already takes a lone String as one enumerated key, and a slip in YAML (keys: D) would load as another shortcut without complaint. The two forms can't mix within one Array, D meaning d in one and Shift-d in the other. A config gives them under fields of their own, :keys: for the Array and :key_equivalent: for the String, so as existing configs are unchanged.

- Whether to do it, in a minor version.
- Whether the String also takes GNUstep's + and ^ for Alternate and Control, or only Command and Shift, the rest left to the Array.
- The method's name: assign_key_equivalent, say.

## Disk images with a licence agreement

hdiutil attach shows an image's licence agreement and waits for an answer, so the output of hdiutil attach -plist is no longer the plist alone, and MacOS::Dmg.mount can't read it.

- Whether Dmg answers for its caller, accepting an agreement unread; or shows it and asks; or raises, leaving the image to be mounted by hand.

## The 1.0 tidy

- Whether a library which has no instances, as Apple80211, DiskUtil, Keychain and USBFlashDrive have none, is a module, as Applications, SystemProfiler, Users and VPN are.
- Whether the _data and _string aliases go.
- Whether a field which macOS gives as Yes or No is given as true or false.
