**# Kek's menu 0.4.6.0**

**## Improvements**```md
### Entity manager now displays if vehicle is player vehicle
### Fixed set bounty on individual player
### No objects are blacklisted from being spawned anymore
### Removed chat judger "blame for killing session", revenge "kill session" & aim protection "Cage" reaction
### Removed spawn menyoo vehicle in player features
### Vehicle & weapon blacklist settings can now be saved to setting profiles
### Bounties now work on yourself
### Some features are now disabled in singleplayer
### Fixed autoexec being overwritten if not using kek's menu script loader (on startup)
### Fixed colored xenon lights always being white
### Crash
> Fixed not working if player in vehicle (and far away), apartment or perico
> Added feedback to tell if failing to clean up
> More stealthy (invisible and no collision) & more likely to successfully clean up

### Blacklist 
> Now continuously updates as player gets marked for modder flags (unless custom reason is set)
> Reapply or not reapply modder marks
> Fixed bug where host spoofing session's name, scid or ip causing every player joining to be "recognized in blacklist"

### Chat commands
> !offtheradar & !neverwanted now has <on / off> parameter
> New command !votekick
> Send chat commands list to team / all

### Menyoo
> Full rework of menyoo spawner & parser
> Fixed menyoo map & vehicle "refresh list"
> Map saver can now save vehicles & peds
> Tells you if spawns are stopped due to reaching entity limits & how many entities were spawned
> Support for scenarios, animations, movement clipsets, clearing world, weather & loading / removing multiple ipls
> Support for map editor maps & a new variation of menyoo maps
> Fixed many things not being applied, like vehicle mods

### Player history
> Also known as - displays names the player has used. Shows what ip / rid was linked to their name
> Times seen & also known as can be configured whether to check rid, name & ip
> Shows blacklist reason of player & if they're added to join timeout
> Scroll through chatlog -> Takes data from chat logger
> Click on message to copy to clipboard
> Click on "Scroll through messages" to copy the whole page
```

**## New features**```md
### Send to eclipse
### Reset settings to defaults
### Ini vehicle spawner
> Identical user interface to menyoo vehicle spawner except no save button
> Supports 5 very different types & 5 additional types who're older / newer versons of aforementioned types

### Mark as modder
> Press mark again on same flag to unmark
```