-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010 Nicolas Casalini
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
--
-- Nicolas Casalini "DarkGod"
-- darkgod@te4.org

startx = 0
starty = 40
endx = 0
endy = 40

-- defineTile section
defineTile("#", "HARDWALL")
defineTile("~", "DEEP_WATER")
defineTile("<", "GRASS_UP_WILDERNESS")
defineTile("_", "OLD_FLOOR")
defineTile(".", "GRASS")
defineTile("t", {"TREE","TREE2","TREE3","TREE4","TREE5","TREE6","TREE7","TREE8","TREE9","TREE10","TREE11","TREE12","TREE13","TREE14","TREE15","TREE16","TREE17","TREE18","TREE19","TREE20"})

quickEntity('2', {show_tooltip=true, name="Armour Smith", display='2', color=colors.UMBER, resolvers.store("ARMOR"), image="terrain/wood_store_armor.png"})
quickEntity('3', {show_tooltip=true, name="Weapon Smith", display='3', color=colors.UMBER, resolvers.store("WEAPON"), image="terrain/wood_store_weapon.png"})
quickEntity('4', {show_tooltip=true, name="Alchemist", display='4', color=colors.LIGHT_BLUE, resolvers.store("POTION"), image="terrain/wood_store_potion.png"})
quickEntity('5', {show_tooltip=true, name="Scribe", display='5', color=colors.WHITE, resolvers.store("SCROLL"), image="terrain/wood_store_book.png"})

-- addSpot section

-- addZone section

-- ASCII map section
return [[
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
~~~~~~~~~~~~~~~~~~~~~~~###~~~~~~~~~~~~~~~~~~~~~~~~
~~~~~~~~~~~~~~~~~~~~~~##_##~~~~~~~~~~~~~~~~~~~~~~~
~~~~~~~~~~~~~~~~~~~~~##___##~~~~~~~~t~~~~~~~~~~~~~
~~~~~~~~~~~t~~~~~~~~~##___##~~~~~~~~~~~~~~~~~~~~~~
~~~~~t~~~~~t~~~~~~~~###___###~~~~~~~~~~~~~t~~~~~~~
~~~~~~~~~~~~~~~~~~~~###___###~~~~~~~~~~~~~~~~~~~~~
~~~~~~~~~~~~~~~t~~~####___####~~~t~~~~~~~~~~~~~~~~
~~~~~~~~~~~~~~~~~~~####___####~~~~~~~~~~~~~~~~~~~~
~~~~~~~~~t~~~~~~~~~####___####~~~~~~~~~~~~~~~~~~~~
~~~~~~~~~t~~~~~~~~##2##___##3##~~~~~~~~~~~~~~~~~~~
~~~~~~~~~~~~~~~~~~#___________#..~~~......~~~t~~~~
~~~~~~~~~~~~~~~~~~#___________#............~~~~~~~
~~~~~~~~~~~~~~~~~~#___________#.....tttt...~~~~~~~
~~~~........~~~~~~#___________#.....ttttt.~~~~~~~~
~~~............~~~#___________#......ttttt~~~~~~~~
~~...............##___________##......ttt..~~~~~~~
~~....ttt........#__#########__#...........~~~~~~~
~....ttt.........#_###########_#...........~~~~~~~
~...ttt.....######__#########__######.......~~~~~~
~...t....####_______________________####......~~~~
~......###_______#_____..._____#_______###.....~~~
~.....##________###___.....___###________##....~~~
~....##_________###__..ttt..__###_________##...~~~
~....___________##5__..ttt..__4##___________...~~~
~....##_________###__..ttt..__###_________##...~~~
~~....##________###___.....___###________##.....~~
~~.....###_______#_____..._____#_______###......~~
~~.......####_______________________####........~~
~~..........######__#########__######..........~~~
~~...............#_###########_#...............~~~
~.....t.tt.......#__#########__#...............~~~
~....ttttt.......##___________##..............~~~~
~....ttttt........#___________#......tt.......~~~~
~~...tttt.....t...#___________#.....tttt.....~~~~~
~~...tt.......t...#___________#....ttttt....~~~~~~
~.............t...#___________#...tttttt....~~~~~~
~.................#___________#...tttt......~~~~~~
~..........tt.t...#####___#####..tttt.......~~~~~~
.....tt....t.......####___####...ttt.......~~~~t~~
<...ttt...t....tt..####___####.............~~~~~~~
...tttt............####___####...........~~~~~~~~~
~..tttt....~~.......###___###.........~~~~~~~~~~~~
~..tttt....~~.......###___###........~~~~~~~~~~~~~
~~........~~~~.......##___##........~~~~~~~~~~~~~~
~~.......~~~~~~~.....##___##........~~~~~~~~~~~~~~
~~~..~~~~~~~~~~~~.....##_##........~~~~~~~~~~t~~~~
~~~~~~~~~~~~~~~~~~~~~..###.....~~~~~~~~~~~~~~~~~~~
~~~~~~~~~~~~~~~~~~~~~~.......~~~~~~~~~~~t~~~~~~~~~
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~]]