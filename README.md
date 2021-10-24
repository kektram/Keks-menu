<h1 align="center">Kek's menu</h1>

> Kek's menu is a 2take1 lua script.<br/>
> The aim is to deliver a script that is stable and fills the gaps in the vanilla feature set of 2take1.<br/>
> Whether you like to mess with people, help people out or just try to be low-key, this script offers something useful.<br/>
> Kek's menu is available in 10 languages.<br/>
> 
> The feature list will be structured like the script is.<br/>
> This means you can figure out where features are located based on the structure of this document.<br/>
> Example: General settings > Settings > Save to default<br/>
> If there's anything confusing or vague in the feature list, feel free to suggest improvements.<br/>
> I'm open to people translating this to another language. You have to speak the language fluently.<br/>
>
> The feature list isn't finished yet.

<h2 align="center">Kek's menu discord</h2>

> Get support<br/>
> Lots of resources such as packs of xml vehicles<br/>
> Get the latest version of Moist's script<br/>
> Share your creations related to Kek's menu

[Join the kek's menu discord](https://discord.gg/CPSgPz4D7X "Kek's menu Discord")

## Table of contents

### [Feature list](#Feature-list-1)

### [How to install](#How-to-install-1)

## How to install
	1. Open keks_menu.zip
	2. Drag all the files to C:\Users\USERNAME\AppData\Roaming\PopstarDevs\2Take1Menu\scripts

## Updating to a new version
	1. Delete scripts\Kek's menu.lua
	2. Delete scripts\kek_menu_stuff\kekMenuLibs
	3. Open keks_menu.zip
	4. Drag kek's menu.lua into the scripts folder
	5. Open the kek_menu_stuff folder inside of keks_menu.zip
	6. Drag kekMenuLibs to scripts\kek_menu_stuff

## Feature list

### Table of contents

#### [General settings](#General-settings-1)

#### [Modder detection](#Modder-detection-1)

### General settings

> Miscellaneous settings and how to save your settings.

#### Settings

##### Save to default
	Overwrites the kekSettings.ini file and the current settings become the defaults.

##### New profile
	Creates a new settings profile.
	These can be loaded and saved to. Very similar to 2take1 setting profiles.

##### Setting profiles
	Load
	Rename
	Save
	Delete

#### Script loader
	Turn it on / off
	Empty the script loader
	Add a script
	Remove a script

#### Hotkeys

##### Notifications
	Toggle whether to show a notification whenever a hotkey is pressed or not

##### Hotkey mode
	Before setting hotkeys, make sure you have set the right hotkey mode.
	If it's set to keyboard, it looks for keyboard input. If it's set to controller, it looks for controller input.
	This means that setting the wrong input mode before setting hotkeys will lead to unpredictable behaviour.

##### Setting hotkeys
	A hotkey can be bound to 1 - 3 keys
	Holding down a hotkey for 550ms will loop the feature every 80ms
	The script uses gta 5's input system, so some keys can't be set as hotkeys.

##### Keys that can be set as hotkeys
	A-Y (WITH EXCEPTION OF i, j and o)
	Up, Down, Left, Right
	f1 - f11 (f4 is not supported)
	1 - 9
	Num 4 - Num 9
	Scroll down, Scroll up
	Lmouse, Rmouse
	Page down, Page up
	Num plus, Num minus
	Alt
	Shift
	Break
	Ctrl
	Space
	Insert
	Caps lock
	Delete
	Tab
	Backspace
	Esc
	Home
	Enter

#### Language configuration
	To change your language, just click on one of the "set X as default language" and reset lua state.

#### Script quick access
	This will make accessing all features faster.
	Normally, you need to: Script features > Kek's menu > Session trolling
	After turning on quick access, it becomes: Script features > Session trolling

### Modder detection

> Detection of modders, the blacklist and what to do against detected modders.<br/>
> Friends are excluded from all the options in this category by default

#### Which modder detections are on

##### Godmode detection
	Detects people with godmode status on + doing multiple things that can't be done when legit players are in godmode

##### Modded name detection
	Detects people with illegal characters in the name
	Detects too short / long names
	If multiple people have the same illegal name, it won't trigger the detection

##### Check people's stats
	Based on a system of severity
	To triggers it detection, the person must have a severity of 3 or higher

###### Severity table
> Suspicious amount of money = 1<br/>
> Suspicious rank = 1<br/>
> Suspicious kd = 1<br/>
> Negative stats = 3<br/>
> Modded armor = 3

##### Detect any modded spectate
	Detects if someone is spectating people while not being inside of an interior and is alive

#### Blacklist
	Add to blacklist
		Type in name, rid, ip and reason

	Remove from blacklist
	Add session to blacklist
	Remove session from blacklist
	Blacklist notifications

#### Turn all on or off
	This feature is in Modder logging and auto kicker settings
	If 1 or more setting is on, everything is turned off.
	If nothing is on, everything is turned on.

#### Log modders with selected tags to blacklist

#### Modder logging settings
	A list of all possible modder detections
	Select which to log

#### Auto kicker
	Automatically kicks out people based on the auto kicker settings. Will use host kick if available.
	Get notified when the auto kicker is triggered

#### Auto kicker settings
	A list of all possible modder detections
	Select which detection will trigger the auto kicker
