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
# CCM - Copy and Car Movement Tool Version 1.1.0 for MTA:SA

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
