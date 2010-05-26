-- ToME - Tales of Middle-Earth
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

newBirthDescriptor{
	type = "class",
	name = "Divine",
	desc = {
		"Divine.",
	},
	descriptor_choices =
	{
		subclass =
		{
			__ALL__ = "never",
			['Sun Paladin'] = function() return profile.mod.allow_build.divine_sun_paladin and "allow" or "never" end,
		},
	},
	copy = {
		-- All mages are of angolwen faction
		faction = "sunwall",
	},
}

newBirthDescriptor{
	type = "subclass",
	name = "Sun Paladin",
	desc = {
		"Wohhha",
		"Their most important stats are: Magic and Willpower",
	},
	stats = { mag=2, str=2, dex=2, },
	talents_types = {
		["divine/sun"]={true, 0.3},
		["divine/chants"]={true, 0.3},
		["divine/glyphs"]={true, 0.3},
		["divine/combat"]={true, 0.3},
		["divine/light"]={true, 0.3},
	},
	talents = {
	},
	copy = {
		max_life = 110,
		life_rating = 12,
		resolvers.equip{ id=true,
			{type="weapon", subtype="mace", name="iron mace", autoreq=true},
			{type="armor", subtype="massive", name="iron plate armour", autoreq=true}
		},
	},
}
