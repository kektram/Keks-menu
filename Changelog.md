# **Kek's menu 0.4.8.1 bug fix update**

## **Bug fixes**```md
### Fixed error on start-up in ped mapper, if you're co-loading
### Auto adjusting text now scales down if text is too big for the screen
### The script no longer wraps menu.add_feature & menu.add_player_feature globally
### Fixed error on startup for people using the Korean translation
### Fixed searching menu features, raising error for 2take1 standard users

### "Move mini map to people you spectate" Now toggles on "Disable out of bounds death"
> A 2take1 feature which prevents you from dying while you spectate people

### Fixed everything that draws stuff on screen, not adapting to resolutions
> If you play the game in 1440p, you were not affected

### Fixed error that would sometimes occur while clearing your personal vehicles
> "Expected only vehicles in user_vehicles table."

### Fixed menyoo / ini vehicle error when the file tries to set an invalid wheel type.
> The game handles invalid wheel types gracefully, so there wasn't a need to raise an error for it.

```
