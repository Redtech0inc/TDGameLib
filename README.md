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

(though i did not get require to work! so i use os.loadAPI [p.s.: fight me over it!])<br>

now to create an actual "game" you have to make an object that holds all the data of the game to do that use<br>
```lua
local namespace = TDgameLib.gameLib:create(arguments... )
```

which will then create an object under your **namespace**

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

<br><br><br>

```lua
gameLib:getShapeSprite(shape: string|nil, width: number|nil, height: number|nil, color: number, rightAngled: boolean|nil, side: string|nil)
```
##### description:
###### generates a sprite of geometric shapes
##### arguments:
>shape: is the geometric shape which you want ot generate a sprite for e.g: "circle","triangle","square"

>width: is the width/radius(if it's a circle) of the shape must be provided for shapes: "square" & "circle"

>height: is the height of the shape must be provided for shapes: "square" & "triangle"

>color: is the color of the shape

>rightAngled: will make a triangle right angled. Will default to false if not provided

>side: will determine if the upper or lower half of the right angled triangle is given. Will default to "lower" if not provided

##### Returns:
>img: is the image matrix of the shape

<br><br><br>

```lua
gameLib:turnSprite(sprite: table, times: number)
```
##### description:
###### lets you turn the given sprite in increments of 90 Degrees by the number of times you inputted
##### arguments:
>sprite: is the sprite that gets turned

>times: is the amount of times it will iterate of rotations of 90 degrees

##### Returns:
>sprite: is the rotated matrix of the sprite

<br><br><br>

```lua
gameLib:setBackgroundImage(img: table)
```
##### description:
###### lets you set a background via gameLib:loadImage advised to be the length & width of the terminal
##### arguments:
>img: matrix give by gameLib:loadImage

<br>

#### object based functions

<br>

```lua
gameLib:addSprite(lvl: string, img: table, priority: number|nil, x: number|nil, y: number|nil)
```
##### description:
###### adds a Sprite to the render
##### arguments:
>lvl: is a string that gives it the hierarchy e.g: "test.string"

>img: is the sprite of the game as matrix can be loaded using gameLib:loadImage

>priority: level of priority when rendering will default to the highest when nil higher priority gets rendered over lower

>x: x position of the Sprite (will start rendering at that x pos). defaults to 1 if not provided

>y: y position of the sprite (will start rendering at that y pos). defaults to 1 if not provided

<br><br><br>

```lua
gameLib:addHologram(lvl: string, text: string, textColor: table|nil, textBackgroundColor: table|nil, priority: number|nil, x: number|nil, y: number|nil, dynamic: boolean|nil, wrapped: boolean|nil)
```
##### description:
###### adds a Hologram/Text to the render
##### arguments:
>lvl: is a string that gives it the hierarchy e.g: "test.string"

>text: is the text that is going to be displayed

>textColor: is the text color of the displayed Text. If nil defaults to colors.white

>textBackgroundColor: is the background color of the displayed Text. If not supplied will render with background Color of background

>priority: level of priority when rendering will default to the highest when nil higher priority gets rendered over lower

>x: X position of the Hologram (will print at that x pos). defaults to 1 if not provided

>y: Y position of the Hologram (will print at that y pos). defaults to 1 if not provided

>dynamic: if false will render it behind every sprite but it can not adjust to the sprite background colors. doesn't change the way it collides! will default to true if not provided

>wrapped: if false won't wrap the text when to big (smart wrapping: wraps at last space if there is one in the current line otherwise wraps to screen size). will default to true if not provided

<br><br><br>

```lua
gameLib:changeSpriteData(lvl: string, img: table|nil, x: number|nil, y: number|nil)
```
##### description:
###### lets you manipulate all data of an existing Sprite
##### arguments:
>lvl: is a string that gives it the hierarchy e.g: "test.string"

>img: is the sprite that will be displayed can be loaded from .nfp file through gameLib:loadImage won't change if not supplied

>x: X position on screen that it starts to be rendered at. Won't change if not supplied

>y: Y position on screen that it starts to be rendered at. Won't change if not supplied

<br><br><br>

```lua
gameLib:changeHologramData(lvl: string, text: string|nil, textColor: table|nil, textBackgroundColor: table|nil, x: number|nil, y: number|nil, wrapped: boolean|nil)
```
##### description:
###### lets you manipulate all data fo an existing Hologram
##### arguments:
>lvl: is a string that gives it the hierarchy e.g: "test.string"

>text: is the text that is being displayed. Won't change if not supplied

>textColor: is the color of the displayed text won't change if not supplied

>textBackgroundColor: is the background color of the text that is being displayed. Won't change if not supplied

>x: X position on screen that it gets written at. Won't change if not supplied

>y: Y position on screen that it gets written at. Won't change if not supplied

>wrapped: if false won't wrap the text when to big (smart wrapping: wraps at last space if there is one in the current line otherwise wraps to screen size). Won't change if not supplied

<br><br><br>

```lua
gameLib:cloneObject(lvl: string, priority: number|nil, x: number|nil, y: number|nil, groupClones: boolean|nil)
```
##### description:
###### allows you to make a clone of a sprite this wll create a object that share the same texture as it's parent object
##### arguments:
>lvl: is the string that gives it the hierarchy to clone e.g:"test.string" (only sprites)

>priority: level of priority when rendering will default to the highest when nil higher priority gets rendered over lower. can not be the priority of thr original sprite

>x: X position of the Sprite (will start rendering at that x pos). defaults to 1 if not provided

>y: Y position of the Sprite (will start rendering at that x pos). defaults to 1 if not provided

>groupClones: if true will create/add objects to a group named: lvl+".spriteClone.group"  (e.g: "test.string.spriteClone.group") consisting of the parent object and all it's spriteClones (useful for checking for collisions of parent and spriteClones). defaults to false if not provided

<br><br><br>

```lua
gameLib:groupObjects(groupLvl: string, lvlTable: table)
```
##### description:
###### lets you group objects together. They will still render separately and their behavior won't change at all. Is useful if you want to check for multiple collisions at once or change common data for all objects. 
<b><font color="red">!!! WARNING: groups can contain groups may have impact on other functions like gameLib:isColliding or gameLib:changeGroupData !!!</font></b>

##### arguments:
>groupLvl: is a string that gives it the hierarchy e.g: "test.string"

>lvlTable: is a table of object (= sprites, holograms, clones) hierarchies that are a part of this group e.g: "test.string","test.number",ect...

<br><br><br>

```lua
gameLib:addObjectToGroup(groupLvl: string, lvlTable: table)
```
##### description:
###### lets you add a table of objects to an already existing group
##### arguments:
>groupLvl: is a string that gives it the hierarchy e.g: "test.string"

>lvlTable: is a table of object (= sprites, holograms, clones) hierarchies that get added to this group e.g: "test.string","test.number",ect...

<br><br><br>

```lua
gameLib:changeGroupData(groupLvl: string, x: number|nil, y: number|nil)
```
##### description:
###### lets you change common data of objects (=sprites, hologram, clones)
##### arguments:
>groupLvl: is a string that gives it the hierarchy e.g: "test.string"

>x: is the number that is added to/subtracted(if negative) from the objects X coordinate

>y: is the number that is added to/subtracted(if negative) from the objects Y coordinate

<br><br><br>

```lua
gameLib:removeObject(lvl: string)
```
##### description:
###### lets you remove objects from the render 
<b><font color="red">!!!Will delete all object data!!!</font></b>

##### arguments:
>lvl: is a string that gives it the hierarchy to remove e.g: "test.string"

<br><br><br>

```lua
gameLib:removeObjectFromGroup(groupLvl: string, lvlTable: table)
```
##### description:
###### lets you remove Objects from the group lvl table
##### arguments:
>groupLvl: is a string that gives it the hierarchy e.g: "test.string"

>lvlTable: is a table of object (= sprites, holograms) hierarchies that you want to remove e.g: "test.string","test.number",ect...

<br><br><br>

```lua
gameLib:isColliding(lvl: string, lvl2: string, isTransparent: boolean|nil)
```
##### description:
###### lets you check if an object (including groups) is on top of an other object (including groups) returns true if it is, otherwise it returns false uses bounding boxes. 
<b><font color="red">Waring may fail if supplied, a group containing more groups (due to lua function stacking prevention)!</font></b>
##### arguments:
>lvl: is a string that gives it the hierarchy of the first object (including groups) to check e.g: "test.string"

>lvl2: is a string that gives it the hierarchy of the second object (including groups) to check e.g: "test.number"

>isTransparent: if true an empty space colliding counts as a collision. Defaults to false if not supplied

##### Returns:
>output: boolean

<br><br><br>

```lua
gameLib:isCollidingRaw(xIn: number, yIn:number, lvl: string, isTransparent: boolean|nil)
```
##### description:
###### lets you check if a object (including groups) is rendered at certain X,Y Coordinates.
<b><font color="red">Waring may fail if supplied, a group containing more groups (due to lua function stacking prevention)!</font></b>

##### arguments:
>xIn: is the X coordinate for the collision check

>yIn: is the Y coordinate for the collision check

>lvl: is a string that gives it the hierarchy of the object to check e.g: "test.string"

>isTransparent: if true an empty space colliding counts as a collision. Defaults to false if not supplied

##### Returns:
>output: boolean

<br>

#### rendering based functions

<br>

```lua
gameLib:render()
```
##### description:
###### lets you render the game

<br><br><br>

### added foot notes

<p>
I've added a folder that contains all assets and scripts for  a  game called tunnelRunner.lua! to view click [here](https://github.com/Redtech0inc/TDGameLib/tree/main/0)<br>
it's built to be on a disk<br>
<font color="red">will not work outside of a disk due to many references to directories with "disk/" in the beginning</font>
</p>
