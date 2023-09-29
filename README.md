# obs-meeting-cost
This is a Lua script for OBS Studio that sets a text source as a meeting cost calculator.

Based off of [obs-advanced-timer](https://github.com/cg2121/obs-advanced-timer).

## Using the script
Inside OBS:
1. Create a "Text (GDI)+" or "Text (Freetype2)" source, specifying the name
2. In the "Tools" menu, select "Scripts".
3. Select "+" under "Loaded scripts"
4. Find & select "meeting-cost.lua"
5. Configure as you wish
6. Click start to start the timer

## Configuration
* Initial Cost: Specify the initial cost for the meeting (Default: 0.0)
* Average hourly rate: Average salary per hour for the participants (Default: 15.00)
* Number of participants: How many people are currently in the meeting (Default: 1)
* Show the participant count: Should the number of participants be show in the text (Default: false)
* Text prefix: What text to show before the dollar amount (Default: "This meeting has cost") 
* Text suffix: What text to show after the dollar amount (Default: "thus far.")
* Text source: Name of the text source in OBS

## Hotkeys
The following hotkeys can be registered:
* Reset Timer
* Pause/Resume
* Increment meeting participants
* Decrement meeting participants

## Examples
![basic scene](screenshots/scene.png)
![configuration](screenshots/config.png)
