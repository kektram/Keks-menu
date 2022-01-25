**# Kek's menu 0.4.6.0**

**## Improvements**```md
### Entity manager now displays if vehicle is player vehicle
### Fixed set bounty on individual player
### No peds or objects are blacklisted from being spawned anymore
### Removed chat judger "blame for killing session" reaction
### Removed revenge "kill session" reaction
### Removed aim protection "Cage" reaction
### Vehicle & weapon blacklist settings can now be saved to setting profiles.
### Fixed problems affecting all script events that cause crashes & other stuff
### Bounties now work on yourself
### Optimized memory usage with memoization, changing how all strings are used & rework / removal of bad functions.
### Fixed individual player horn boost crash if player leaves
### Fixed vehicle fly not working properly if vehicle limits were reached or entities being deleted
### Unicode support (chinese, korean, arabic etc)
> Chat judger now has limited support. Magic characters (%d, %w etc) won't work. It only uses unicode search if relevant)
> Translations are now retrieved properly without corrupting bytes (this caused crashes)

### Blacklist 
> Now continuously updates as player gets marked for more flags (unless custom reason is set)
> Reapply or not reapply modder marks
> Fixed bug where host spoofing session's name, scid or ip causing every player joining to be "recognized in blacklist"

### Chat commands
> Removed repeat parameter
> !otr renamed to !offtheradar
> !apartmentinvite renamed to !apartmentteleport
> !offtheradar & !neverwanted now has <on / off> parameter
> New command "!votekick" -> If 3 people vote to kick someone, they're kicked.
> Send chat commands list to team / all

### Menyoo
> Fixed menyoo map & vehicle "refresh list"
> Map saver can now save vehicles & peds
> Now tells how many entities were spawned out of total. Peds, vehicles, objects & invalid model hashes.
> Now tells you if spawns are stopped due to reaching entity limits
> Added support for scenarios, animations & movement clipsets
> Added support for weather
> Now handles error where menyoo maps or vehicles are put in wrong menyoo folders
> Fixed vehicle mods not being applied [Applied to clone vehicle too.]

### Player history
> "Also known as" - displays all names a player has used. Shows you what ip / rid was linked to their name.
> Times seen & "also known as" can be configured whether to check rid, name & ip. Previously only rid was checked.
> Fixed bug where player names containing '|' would cause some issues.
> Shows blacklist reason of player
> Shows if added to join timeout
> Scroll through chatlog -> Takes data from chat logger. Retrieves all entries matching all known names.
```

**## New features**```md
### Send to eclipse
### Reset settings to defaults

### Mark as modder
> Press mark again on same flag to unmark.
```