# **Kek's menu 0.4.6.7**

## **Improvements**```md
### All features spawning vehicles now spawn distance away relative to vehicle size & vehicle you're in's size
### All features changing gravity is now a slider to change gravity amount (-980.0 to 980.0)
### Fixed unfreezing of entities not reactivating physics until you interact with the entity (vehicle stuck inside the ground)
### Fixed entity manager filtering out entities that spawned after the filter was set, despite fitting filter
### Fixed ini spawner[2take1 inis] failing to set neon lights
### Added "Clear all owned entities" to menyoo map & xml/ini vehicle spawner
### Army, clown vans & kek's chopper now clears entities still in memory when you toggle the features off
### Optimized log modders & auto kicker
### Fixed deleting entities (every feature that does it)
> Not waiting long enough to get control of entity
> Used to wait up to 50ms, now waits up to 500ms with a few exceptions
> Waits up to 50ms like before if it takes over 10 seconds to clear a group of entities (Will happen if a modder is blocking control requests)

### Kek's chopper
> Fixed shooting vehicles colliding with each other
> The chopper & pilot now have collision & are no longer in godmode
> Fixed continuing to shoot vehicles despite chopper / pilot dead
```

**New features**```md
### Swap nearby vehicles to police
```