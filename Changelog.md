# **Kek's menu 0.4.7.0**

## **Improvements**```md
### Removed
> Teleport to Eclipse (both player & session versions)
> Teleport session to random apartments
> Send session to random missions
> "Turn all on or off" in auto kicker & modder log flag settings
> !votekick chat command

### Bug fixes
> Max & repair nearby cars
> Bug where "max nearby vehicles" teleported / slung vehicles around
> Bugs affecting all vehicle player features
> Error in "Log chat & add to bot" & "vehicle blacklist"
> Give flamethrower not teleporting you back if it failed to get control
> Clone vehicle spawning clone in unknown location
> Bmx being visible for one frame when toggling on vehicle fly
> Vehicle fly tilting vehicle sideways when disabling it while slung forward
> Clear owned entities, delete all entities (entity manager) & clear entities on reset lua state, clearing your vehicle if it has any attachments
> "Block passive" on individual players not unblocking when toggled off
> Blacklist recognizing people you had never met prior to the current session when loading the script
> Crashes related to error handling & notifications, when the message contains invalid utf8
> Chat spammer spamming at set spam speed + 150ms. Now it's set spam speed only. (2.5x faster spamming at lowest setting.)
> Player history; "chat log" error
> Fixed modders being able to crash you by spamming the chat (if u had all chat features toggled on. This is now safe. Now max 1 running chat thread per player, per chat feature)

### Entity manager
> Removed "Follow entity"
> Added attach players submenu with rotation & offset settings

### Added around 150 different notifications to notification spam
> 2x more notifications per second (1000ms -> 500ms interval)

### Menyoo maps
> Now visible to other players if the map contains 80 or less objects
> Option to automatically clear owned entities before spawning menyoo maps
> Beware, map entities cause many false positives in relation to crash protex

### "Log 2take1 notifications to console" now has the option to apply filter to it
### Improved filter for log / display 2take1 notifications
### Added clear ptfx to clear entities
### Lock player inside now also has the ability to unlock their car (will unlock if their car is locked and vice versa)
### Reviving engine is now instant instead of a 5 second delay waiting for the game
### Player history now logs player again if ip, name or scid has changed opposed to only if name changed (or if you haven't met player in a day)
```

**New features**```md
### Respawn vehicle after death 
> Player feature & session wide
> Works with any vehicle you set it to
> Clears old vehicle (if it's still in memory)

### Get notified if someone typing in chat & when they stopped typing
### Anti chat spoof / illegal message
> Illegal message example: A chat spammer
> It will send a message with a bunch of newline characters to make their illegal message disappear
> Option to only detect if they sent an illegal message and not retaliate
> Certain menues messes with how messages are sent & therefore detects all messages they send
```