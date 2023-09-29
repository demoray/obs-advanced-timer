# obs-meeting-cost
This is a Lua script for OBS Studio that sets a text source as a meeting cost calculator.

Have you ever asked "Is this meeting in the best interest of the company?"

One way to think about this question is based on how much the meeting has cost.
This OBS script calculates the current cost of a meeting based on a
configurable number of participants and average salary, writing the results
into an OBS text source.

You too can have a rolling dollar value like this added to your meetings:
> This meeting has cost $XXX.YY thus far.

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
* Average salary: Average salary, assuming working 3 week vacation, 40 hour work week.  (Default: $100,000.00)
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
