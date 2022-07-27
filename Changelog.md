# **Kek's menu 0.4.8.0**

## **Improvements**```md
### Removed
> Anti chat spoof
> Modded name detection
> Hotkeys
> Send to random mission
> Log chat & use as chatbot
> !removeweapon chat command

### Bug fixes
> Crash when loading corrupted text from player history files
> Autoexec causing trusted mode not enabled errors despite it being on. You have to delete your old autoexec for the changes to apply.
> Numerous incompatibility issues with other scripts
> "Nearby cars have no collision" turning off collision too slowly & not removing collision from attachments
> "Shoot entity| get model name of entity", getting ped instead of vehicle
> Vehicle gun error if you have no personal vehicle
> Chatbot & chat judger integrity checker being absurdly slow, causing seconds of freezing
> Give car godmode stopping the player's vehicle
> Menyoo map-> "Set where you spawn" not working on maps saved by the script
> Menyoo/ini spawners setting rotations wrong
> Fixed 30k loop

### Whitelisting people now also whitelists them from malicious features
### Send army now also sends a jet
### Script event features now work on yourself
### Teleports now works when players aren't in a vehicle
### Chat judger, Chat logger, anti chat spam & chat commands now takes chat spoofing into account
### Chat commands rework
### Ini vehicles & menyoo maps now supports folders
> No limit on how many folders deep
> Create new folder in-game
> Folders are always on top of the list
> "Refresh" now refreshes all files in current folder & its sub-directories.
> "Refresh" will find new folders & clear removed ones too.

**New features**```md
### !bounty chat command
### !jet chat command
### Send kek chopper to session
### Send jet to session
### Menyoo map saver->Save only mission entities
### Added 12-hour clock option to time OSD
### Display session location info [country, city]
### Counts how many times people run Kek's menu [max once per hour]
### Automatically sends errors to me [max once per hour]

### Search features rework
> Menu, local lua & player features
> Go-to / tell you where they're located

### Kek's menu updater
> Choose to receive beta updates
> Can be turned off

### Translate chat
> Set languages to not translate
> Set language to translate to
> Input text to translate
> Translate your messages {
	Send to team/all chat
	Meant for chinese/korean/russian users, because "Input text to translate" won't accept unicode.
}
```
