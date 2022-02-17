**# Kek's menu 0.4.6.5

## **Improvements**```md
### Anti chat spam
> Removed indivual player cooldown (was 90 seconds)
> Now considers message length & number of messages when figuring out if someone is spamming
> A message is equivalent to 85 + number of characters
> Spam detection is triggered if the count reaches 500 or more
> Spam tracker is now reset after 600ms of no chat instead of 1200ms intervals
> Same message in a row detection now requires messages below 10 characters to be sent 5 times in a row and 10 or more characters 3 times.
> Removed "Crash" & "Crash & add to timeout" reactions

### Fixed "kick vote kickers" not working if someone vote kicks multiple times
### Added missing feedback messages "You can't use this on yourself."
```
It doesn't matter if you download via the green button or in releases, they're identical.