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
