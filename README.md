# Two Dimensional Game Library
## About the TDGameLib


### ---------------info---------------
this is a library to make games easier to develop in CCTweaked (minecraft mod)<br><br>

made for CCTweaked Versions 1.16.x to 1.20.x

### ---------------how to set up---------------
start by adding the package to your project via<br><br>
```lua
os.loadAPI("TDGameLib.lua")
```

or<br>
```lua
require("TDGameLib")
```

(though i did not get that to work!)<br>

now to create an actual "game" you have to make an object that holds all the data of the game to do that use<br>
```lua
local namespace = TDgameLib.gameLib:create(arguments... )
```

which will then cerate an object under your **namespace**

<p> for this case i will call the object 'gameLib'</p>

### ---------------functions---------------

#### Game FrameWork based functions
```lua
gameLib:create(gameName: any, useMonitor: boolean|nil, monitorFilter: table|nil, pixelSize: number|nil, screenStartX: number|nil, screenStartY: number|nil, screenEndX: number|nil, screenEndY: number|nil)
```
##### description:
###### creates a framework for a 2D game

##### arguments:
>gameName: name of the game given to the game.gameName

>useMonitor: if true will make the game render on a connected monitor. defaults to false if not provided

> pixelSize: is the size of a pixel on a monitor can range from 0.5 to 5 (REQUIRES MONITOR)

> monitorFilter: is the name of the monitor that gets picked (REQUIRES MONITOR)

> screenStartX: is the X coordinate at which the render starts, defaults to 1 if not provided

> screenStartY: is the Y coordinate at which the render starts, defaults to 1 if not provided

> screenEndX: is the X coordinate at which the render ends, defaults to output object width if not provided

> screenEndY: is the Y coordinate at which the render ends, defaults to output object height if not provided

##### returns:
>gameENV: an object which is the game Framework

<br><br><br>

```lua
gameLib:quit(restart: boolean|nil, exitMessage: any, exitMessageColor: any)
```
##### description:
###### ends the game and removes the framework
##### arguments:
> restart: if true restarts the computer otherwise just resets the terminal/monitor. If not provided defaults to false

<br><br><br>

```lua
gameLib:useDataFile(fileDir: string)
```
##### description:
###### lets you load in game assets from a .data(.html and .xml mix: tag based) notation file. Will return an error if the .data file has invalid data or something went wrong whilst adding or grouping objects
##### arguments:
> fileDir: the directory of the file that you want to load

<br><br><br>

```lua
gameLib:makeDataFile(fileDir: string, compact: boolean|nil)
```
##### description:
###### lets you take all objects & groups and turn them into a .data(.html and .xml mix: tag based) file
##### arguments:
>fileDir: is the directory where the file will be saved

>compact: if true will compact the content into one line useful for space saving otherwise uses indentation for readability. defaults to false if not provided

<br>

#### gameMEM based Functions
<br>

```lua
gameLib:setGameMEMValue(lvl: string, value: any)
```
##### description:
###### lets you set a value in the Game Matrix/Memory to save values that are accessible to the gameLib
##### arguments:
>lvl: is a string that gives it the hierarchy e.g: "test.string"

>value: is the value that in our case 'test.string' is set to e.g: value="hello world"

<br><br><br>

```lua
gameLib:getGameMEMValue(place: string|nil)
```
##### description:
###### lets you look inside the self.gameMEM hierarchy
##### arguments:
> place: place to look in the self.gameMEM hierarchy

##### Returns:
>table: will return all values from the given place on in the hierarchy or self.gameMEM if place is nil

<br>

#### image based functions

<br>

```lua
gameLib:loadImage(imgDir: string)
```
##### description:
###### lets you load in a .nfp correctly!
##### arguments:
>imgDir: is the path that get's loaded as image table

##### Returns:
>image: the image as Matrix made of color values (read about color values [here](https://tweaked.cc/module/colors.html))
