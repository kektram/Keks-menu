# **Kek's menu 0.4.8.0**

## **Improvements**```md
### Removed anti chat spoof
> Not as reliable as I would like

### Removed modded name detection
> 2take1 have session mismatch

### Removed hotkeys
> Made obsolete by newest improvements to regular 2take1 hotkeys

### Removed "send to random mission"
### Whitelisting people now also whitelists them from the script's modder detections & any feature that kicks people
### Fixed chatbot & chat judger integrity checker being absurdly slow, causing seconds of freezing
### Fixed "give car godmode" stopping the player's vehicle
### Fixed "Shoot entity| get model name of entity", getting ped instead of vehicle
### Fixed vehicle gun error if you have no personal vehicle
### Fixed "Nearby cars have no collision" turning off collision too slowly & not removing collision from attachments
### Fixed incompatibility with cheese UI, it was affecting rimuru's script
### Updated autoexec to load scripts after trusted mode setting is toggled on
### Send army now also sends a jet
### Fixed crash when loading corrupted text from player history files
> If there are more cases of this, they now raise an error instead of a crash.

### Fixed an issue where HSW vehicle upgrades caused white boxes to be spawned, crashing other players
> Affected Banshee, Sentinel XS
> These vehicles will receive less upgrades (horn, bumpers etc)
> This issue is also present in 2take1's spawner (if max vehicle on)

### Script event features now work on yourself
### Big overhaul to lots of features
> Menyoo & ini spawner is much more complete
> Added 1 second delay for spawning maps to allow unused models to leave memory
> Fixed maps / vehicles spawning in wrong due to wrong rotation order
> Fixed "Set where you spawn" not working on maps saved by the script
> As a side effect, the new rotation order will invalidate maps/vehicles saved in previous versions of the script
> Default menyoo maps have been updated to be saved with new rotation order

### Trolling entities no longer leave memory by itself
> This prevents accumulation of entities; it was causing crashes

```

**New features**```md
### !bounty chat command
> Bounties now work despite being script host, so this feature could finally be added

### !jet chat command
### Send kek chopper to session is back
### Send jet to session
### Send kek_menu_log.log to error-log-share discord channel
> This is to make it easier to share your error logs to me
> You must be in the discord server for this to work

### Send errors caught to me automatically
> This is optional, you can use the script without http permissions.

### Auto update kek's menu
> This is optional, you can use the script without http permissions.
> It will check for update whenever you run the script

### Menyoo map saver->Save only mission entities
> This allows to save maps from the likes of rockstar while ignoring all irrelevant entities
```

** From now on, you must turn on trusted mode **
> This is necessary to call gta natives


# **Kek's menu 0.4.8.0**

## **Improvements**```md
### Removed anti chat spoof
> Not as reliable as I would like

### Removed modded name detection
> 2take1 have session mismatch

### Removed hotkeys
> Made obsolete by newest improvements to regular 2take1 hotkeys

### Removed "send to random mission"
### Whitelisting people now also whitelists them from the script's modder detections & any feature that kicks people
### Fixed chatbot & chat judger integrity checker being absurdly slow, causing seconds of freezing
### Fixed "give car godmode" stopping the player's vehicle
### Fixed "Shoot entity| get model name of entity", getting ped instead of vehicle
### Fixed vehicle gun error if you have no personal vehicle
### Fixed "Nearby cars have no collision" turning off collision too slowly & not removing collision from attachments
### Fixed incompatibility with cheese UI, it was affecting rimuru's script
### Updated autoexec to load scripts after trusted mode setting is toggled on
### Send army now also sends a jet
### Fixed crash when loading corrupted text from player history files
> If there are more cases of this, they now raise an error instead of a crash.

### Fixed an issue where HSW vehicle upgrades caused white boxes to be spawned, crashing other players
> Affected Banshee, Sentinel XS
> These vehicles will receive less upgrades (horn, bumpers etc)
> This issue is also present in 2take1's spawner (if max vehicle on)

### Script event features now work on yourself
### Big overhaul to lots of features
> Menyoo & ini spawner is much more complete
> Added 1 second delay for spawning maps to allow unused models to leave memory
> Fixed maps / vehicles spawning in wrong due to wrong rotation order
> Fixed "Set where you spawn" not working on maps saved by the script
> As a side effect, the new rotation order will invalidate maps/vehicles saved in previous versions of the script
> Default menyoo maps have been updated to be saved with new rotation order

### Trolling entities no longer leave memory by itself
> This prevents accumulation of entities; it was causing crashes

```

**New features**```md
### !bounty chat command
> Bounties now work despite being script host, so this feature could finally be added

### !jet chat command
### Send kek chopper to session is back
### Send jet to session
### Send kek_menu_log.log to error-log-share discord channel
> This is to make it easier to share your error logs to me
> You must be in the discord server for this to work

### Send errors caught to me automatically
> This is optional, you can use the script without http permissions.

### Auto update kek's menu
> This is optional, you can use the script without http permissions.
> It will check for update whenever you run the script

### Menyoo map saver->Save only mission entities
> This allows to save maps from the likes of rockstar while ignoring all irrelevant entities
```

** From now on, you must turn on trusted mode **
> This is necessary to call gta natives
