                  ----------_____--------------------_____--------------------_____----------
                  ---------/\----\------------------/\----\------------------/\----\---------
                  --------/::\----\----------------/::\----\----------------/::\____\--------
                  -------/::::\----\--------------/::::\----\--------------/::::|---|--------
                  ------/::::::\----\------------/::::::\----\------------/:::::|---|--------
                  -----/:::/\:::\----\----------/:::/\:::\----\----------/::::::|---|--------
                  ----/:::/--\:::\----\--------/:::/--\:::\----\--------/:::/|::|---|--------
                  ---/:::/----\:::\----\------/:::/----\:::\----\------/:::/-|::|---|--------
                  --/:::/----/-\:::\----\----/:::/----/-\:::\----\----/:::/--|::|___|______--
                  -/:::/----/---\:::\----\--/:::/----/---\:::\----\--/:::/---|::::::::\----\-
                  /:::/____/-----\:::\____\/:::/____/-----\:::\____\/:::/----|:::::::::\____\
                  \:::\----\------\::/----/\:::\----\------\::/----/\::/----/-~~~~~/:::/----/
                  -\:::\----\------\/____/--\:::\----\------\/____/--\/____/------/:::/----/-
                  --\:::\----\---------------\:::\----\--------------------------/:::/----/--
                  ---\:::\----\---------------\:::\----\------------------------/:::/----/---
                  ----\:::\----\---------------\:::\----\----------------------/:::/----/----
                  -----\:::\----\---------------\:::\----\--------------------/:::/----/-----
                  ------\:::\----\---------------\:::\----\------------------/:::/----/------
                  -------\:::\____\---------------\:::\____\----------------/:::/----/-------
                  --------\::/----/----------------\::/----/----------------\::/----/--------
                  ---------\/____/------------------\/____/------------------\/____/---------
                  ---------------------------------------------------------------------------
# CCM - Copy and Car Movement Tool Version 2.0.0 for MTA:SA

An easy tool to add NPC-like moving vehicles to your maps without having to write them yourself!

## CCM - Showcase
[![CCM Showcase](https://img.youtube.com/vi/__IljIxGlQg/0.jpg)](https://www.youtube.com/watch?v=__IljIxGlQg "Video Title")

## Installation
> Press the green button on the top right that shows "Code"

> Select "Download ZIP" (Alternativley you can choose to go to releases and select the version you want to download)

> Extract to "YOUR_INSTALLATION_PATH\MTA San Andreas 1.6\server\mods\deathmatch\resources..."

> Next click on "dgs @ 1c4e6a3" and follow the same process as above (Note: you will have to rename the directory to dgs in order to make it work!)

> Start your server and the resource "/start ccm"

> The resource will ask you to add certain permissions so its allowed to modify content and autoupdate itself simply use "/aclrequest allow ccm all"

> Restart your resource with "/restart ccm"

> Enjoy!

## Version 2.0.0
Added the ability to attach unlimited objects to each path recording.  
Added the ability to attach unlimited effects to each path recording.  
Added the ability to attach umlimited texts to each path recording. Use with caution!  
Added the ability to now choose your vehicle settings such as overrideLights, wheelSize, vehicleSmokeTrail(Stuntplane, Cropduster) and more.  
Added the option to spawn endless vehicles that drive over the recorded path.  
Along with this comes a menu to create your own set of vehicles that should spawn at random and then drive over the selected path, an edit box is present to set the spawn interval either with only one
integer or two. If two are chosen each interval will be drawn through math.random(firstInteger, secondInteger).  
This will only work if the first integer is smaller than the second one otherwise it will revert back to its default value of 1 second!  
Added a realtime preview to the object and effect menu, as well as the searchlight and the adjustable property settings.  
Added that menus now stay open once opened.  
Added a camera function while the menu is open use q = right, e = left, w = down, s = up, r = zoom in, f = zoom out(These settings can be changed under the settings menu)  
Added a settings menu with which you can rebind all your keys.  

Relocated reverse path that can now be found inside the additional options menu to make the menu somewhat friendlier to navigate
and also to have the ability to change some options more dynamically such as the aforementioned and endless vehicles.

Changed how you now interact with the menu, before everytime you would enter an edit box it would remove anything that was already written inside of it. Now it will only remove once you double click on the edit box or the default text is present.  

Changed some functions inside the util.lua and cached several functions to help with performance.  

Fixed that trains now work correctly when used independently.  

## Version 1.1.0
The vehicle the player sits in is now recorded properly.
(Height Offset should not be needed anymore)

Vehicles are now created immediatley instead of being created and moved over their path when the player hits the designated marker.

getPedControlAnalogeState is now being tracked while recording the path to properly display left and right vehicle steering.

Adjusted/fixed some minor stuff.

## Version 1.0.2
Added the option to reverse recorded paths.

## Version 1.0.1
Reworked the override functionality to now delete all existing files in the paths folder.

Fixed some minor typos.

## Version 1.0.0
Initial release.
