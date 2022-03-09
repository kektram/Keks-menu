# **Kek's menu 0.4.6.8**

## **Improvements**```md
### Added is_player_valid checks to every event listener (chat, player join/leave)
> These listeners have invalid players sometimes (this causes errors)
> Could only be replicated when co-loading with a mod menu that have an auto kicker

### Changed all kicks to always use force_remove[desync/break-up/roundhouse kick]
> Previously it would use host kick when possible
> A new mod menu feature has made host kick worse than force_remove

### Fixed vehicle plate text & always f1 wheels only working if "Spawn vehicles maxed" is toggled on
### Fixed a bug where many features failing to set wheel type 
> Replicated only with f1 wheels, might've affected more types
> Affected menyoo / ini spawner
```

**New features**```md

```