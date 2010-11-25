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

newEntity{
	define_as = "BASE_SCROLL",
	slot = "INBELT", use_no_wear=true,
	type = "scroll", subtype="scroll",
	unided_name = "scroll", id_by_type = true,
	display = "?", color=colors.WHITE, image="object/scroll.png",
	encumber = 0.1,
	stacking = true,
	use_sound = "actions/read",
	use_no_blind = true,
	use_no_silence = true,
	is_magic_device = true,
	fire_destroy = {{10,1}, {20,2}, {40,5}, {60,10}, {120,20}},
	desc = [[Magical scrolls can have wildly different effects! Most of them function better with a high Magic score]],
	egos = "/data/general/objects/egos/scrolls.lua", egos_chance = resolvers.mbonus(10, 5),
}

newEntity{
	define_as = "BASE_INFUSION",
	type = "scroll", subtype="infusion", add_name = " [#INSCRIPTION#]",
	unided_name = "infusion", id_by_type = true,
	display = "?", color=colors.LIGHT_GREEN, image="object/rune_green.png",
	encumber = 0.1,
	use_sound = "actions/read",
	use_no_blind = true,
	use_no_silence = true,
	fire_destroy = {{100,1}, {200,2}, {400,5}, {600,10}, {1200,20}},
	desc = [[Natural infusions may be grafted onto your body, granting you an on-demand ability.]],
	egos = "/data/general/objects/egos/infusions.lua", egos_chance = resolvers.mbonus(30, 5),

	use_simple = { name="inscribe your skin with the infusion.", use = function(self, who, inven, item)
		if who:setInscription(nil, self.inscription_talent, self.inscription_data, true, true, {obj=self, inven=inven, item=item}) then
			return "destroy", true
		end
	end}
}

newEntity{
	define_as = "BASE_RUNE",
	type = "scroll", subtype="rune", add_name = " [#INSCRIPTION#]",
	unided_name = "rune", id_by_type = true,
	display = "?", color=colors.LIGHT_BLUE, image="object/rune_red.png",
	encumber = 0.1,
	use_sound = "actions/read",
	use_no_blind = true,
	use_no_silence = true,
	is_magic_device = true,
	fire_destroy = {{10,1}, {20,2}, {40,5}, {60,10}, {120,20}},
	desc = [[Magical runes may be inscribes onto your body, granting you an on-demand ability.]],
	egos = "/data/general/objects/egos/infusions.lua", egos_chance = resolvers.mbonus(30, 5),

	use_simple = { name="inscribe your skin with the rune.", use = function(self, who, inven, item)
		if who:setInscription(nil, self.inscription_talent, self.inscription_data, true, true, {obj=self, inven=inven, item=item}) then
			return "destroy", true
		end
	end}
}

newEntity{
	define_as = "BASE_LORE",
	type = "lore", subtype="lore", not_in_stores=true,
	unided_name = "scroll", identified=true,
	display = "?", color=colors.ANTIQUE_WHITE, image="object/scroll-lore.png",
	encumber = 0.1,
	desc = [[This parchement contains some lore.]],
}

newEntity{ base = "BASE_INFUSION",
	name = "healing infusion",
	level_range = {7, 50},
	rarity = 16,
	cost = 10,
	material_level = 1,

	inscription_data = {
		cooldown = resolvers.rngrange(5, 10),
		heal = resolvers.mbonus_level(400, 40, function(e, v) return v * 0.06 end),
		use_stat_mod = 2.7,
	},
	inscription_talent = "INFUSION:_HEALING",
}

newEntity{ base = "BASE_INFUSION",
	name = "regeneration infusion",
	level_range = {1, 50},
	rarity = 15,
	cost = 10,
	material_level = 1,

	inscription_data = {
		cooldown = resolvers.rngrange(12, 17),
		dur = 5,
		heal = resolvers.mbonus_level(550, 60, function(e, v) return v * 0.06 end),
		use_stat_mod = 3.4,
	},
	inscription_talent = "INFUSION:_REGENERATION",
}

newEntity{ base = "BASE_INFUSION",
	name = "wild infusion",
	level_range = {1, 50},
	rarity = 13,
	cost = 20,
	material_level = 1,

	inscription_data = resolvers.generic(function(e)
		return {
			cooldown = rng.range(10, 15),
			dur = rng.mbonus(4, resolvers.current_level, resolvers.mbonus_max_level) + 4,
			power = rng.mbonus(20, resolvers.current_level, resolvers.mbonus_max_level) + 10,
			use_stat_mod = 0.1,
			what = {
				poison = true,
				disease = rng.percent(40) and true or nil,
				curse = rng.percent(40) and true or nil,
				hex = rng.percent(40) and true or nil,
				magical = rng.percent(40) and true or nil,
				physical = rng.percent(40) and true or nil,
				mental = rng.percent(40) and true or nil,
			}
		}
	end),
	inscription_talent = "INFUSION:_WILD",
}

newEntity{ base = "BASE_INFUSION",
	name = "movement infusion",
	level_range = {10, 50},
	rarity = 15,
	cost = 30,
	material_level = 3,

	inscription_data = {
		cooldown = resolvers.rngrange(10, 15),
		dur = resolvers.mbonus_level(5, 2, function(e, v) return v * 1 end),
		use_stat_mod = 0.05,
	},
	inscription_talent = "INFUSION:_MOVEMENT",
}

newEntity{ base = "BASE_INFUSION",
	name = "sun infusion",
	level_range = {1, 50},
	rarity = 13,
	cost = 10,
	material_level = 1,

	inscription_data = {
		cooldown = resolvers.rngrange(6, 12),
		range = resolvers.mbonus_level(5, 5, function(e, v) return v * 0.1 end),
		use_stat_mod = 0.05,
	},
	inscription_talent = "INFUSION:_SUN",
}

newEntity{ base = "BASE_INFUSION",
	name = "strength infusion",
	level_range = {25, 50},
	rarity = 16,
	cost = 40,
	material_level = 3,

	inscription_data = {
		cooldown = resolvers.rngrange(20, 30),
		dur = resolvers.mbonus_level(7, 7),
		power = resolvers.mbonus_level(4, 4, function(e, v) return v * 3 end),
		use_stat_mod = 0.04,
	},
	inscription_talent = "INFUSION:_STRENGTH",
}

newEntity{ base = "BASE_INFUSION",
	name = "will infusion",
	level_range = {25, 50},
	rarity = 16,
	cost = 40,
	material_level = 3,

	inscription_data = {
		cooldown = resolvers.rngrange(20, 30),
		dur = resolvers.mbonus_level(7, 7),
		power = resolvers.mbonus_level(4, 4, function(e, v) return v * 3 end),
		use_stat_mod = 0.04,
	},
	inscription_talent = "INFUSION:_WILL",
}

newEntity{ base = "BASE_RUNE",
	name = "phase door rune",
	level_range = {1, 50},
	rarity = 15,
	cost = 10,
	material_level = 1,

	inscription_data = {
		cooldown = resolvers.rngrange(5, 9),
		range = resolvers.mbonus_level(10, 5, function(e, v) return v * 1 end),
		use_stat_mod = 0.07,
	},
	inscription_talent = "RUNE:_PHASE_DOOR",
}

newEntity{ base = "BASE_RUNE",
	name = "controlled phase door rune",
	level_range = {35, 50},
	rarity = 17,
	cost = 50,
	material_level = 4,

	inscription_data = {
		cooldown = resolvers.rngrange(7, 12),
		range = resolvers.mbonus_level(6, 5, function(e, v) return v * 3 end),
		use_stat_mod = 0.05,
	},
	inscription_talent = "RUNE:_CONTROLLED_PHASE_DOOR",
}

newEntity{ base = "BASE_RUNE",
	name = "teleportation rune",
	level_range = {10, 50},
	rarity = 15,
	cost = 10,
	material_level = 2,

	inscription_data = {
		cooldown = resolvers.rngrange(9, 14),
		range = resolvers.mbonus_level(100, 20, function(e, v) return v * 0.03 end),
		use_stat_mod = 1,
	},
	inscription_talent = "RUNE:_TELEPORTATION",
}

newEntity{ base = "BASE_RUNE",
	name = "shielding rune",
	level_range = {12, 50},
	rarity = 15,
	cost = 20,
	material_level = 3,

	inscription_data = {
		cooldown = resolvers.rngrange(14, 24),
		dur = resolvers.mbonus_level(5, 3),
		power = resolvers.mbonus_level(500, 50, function(e, v) return v * 0.06 end),
		use_stat_mod = 3,
	},
	inscription_talent = "RUNE:_SHIELDING",
}

newEntity{ base = "BASE_RUNE",
	name = "invisibility rune",
	level_range = {18, 50},
	rarity = 19,
	cost = 40,
	material_level = 3,

	inscription_data = {
		cooldown = resolvers.rngrange(14, 24),
		dur = resolvers.mbonus_level(9, 4, function(e, v) return v * 1 end),
		power = resolvers.mbonus_level(8, 7, function(e, v) return v * 1 end),
		use_stat_mod = 0.08,
		nb_uses = resolvers.mbonus_level(7, 4),
	},
	inscription_talent = "RUNE:_INVISIBILITY",
}

newEntity{ base = "BASE_RUNE",
	name = "speed rune",
	level_range = {23, 50},
	rarity = 16,
	cost = 40,
	material_level = 3,

	inscription_data = {
		cooldown = resolvers.rngrange(14, 24),
		dur = resolvers.mbonus_level(4, 3),
		power = resolvers.mbonus_level(30, 30, function(e, v) return v * 0.3 end),
		use_stat_mod = 0.3,
		nb_uses = resolvers.mbonus_level(7, 4),
	},
	inscription_talent = "RUNE:_SPEED",
}

newEntity{ base = "BASE_RUNE",
	name = "vision rune",
	level_range = {15, 50},
	rarity = 16,
	cost = 30,
	material_level = 2,

	inscription_data = {
		cooldown = resolvers.rngrange(20, 30),
		range = resolvers.mbonus_level(10, 8),
		dur = resolvers.mbonus_level(20, 12),
		power = resolvers.mbonus_level(20, 10, function(e, v) return v * 0.3 end),
		use_stat_mod = 0.14,
	},
	inscription_talent = "RUNE:_VISION",
}

newEntity{ base = "BASE_RUNE",
	name = "heat beam rune",
	level_range = {25, 50},
	rarity = 16,
	cost = 20,
	material_level = 3,

	inscription_data = {
		cooldown = resolvers.rngrange(15, 25),
		range = resolvers.mbonus_level(5, 4),
		power = resolvers.mbonus_level(300, 60, function(e, v) return v * 0.1 end),
		use_stat_mod = 1.8,
	},
	inscription_talent = "RUNE:_HEAT_BEAM",
}

newEntity{ base = "BASE_RUNE",
	name = "frozen spear rune",
	level_range = {25, 50},
	rarity = 16,
	cost = 20,
	material_level = 3,

	inscription_data = {
		cooldown = resolvers.rngrange(15, 25),
		range = resolvers.mbonus_level(5, 4),
		power = resolvers.mbonus_level(300, 60, function(e, v) return v * 0.1 end),
		use_stat_mod = 1.8,
	},
	inscription_talent = "RUNE:_FROZEN_SPEAR",
}

newEntity{ base = "BASE_RUNE",
	name = "acid wave rune",
	level_range = {25, 50},
	rarity = 16,
	cost = 20,
	material_level = 3,

	inscription_data = {
		cooldown = resolvers.rngrange(15, 25),
		range = resolvers.mbonus_level(3, 2),
		power = resolvers.mbonus_level(250, 40, function(e, v) return v * 0.1 end),
		use_stat_mod = 1.8,
	},
	inscription_talent = "RUNE:_ACID_WAVE",
}

newEntity{ base = "BASE_RUNE",
	name = "lightning rune",
	level_range = {25, 50},
	rarity = 16,
	cost = 20,
	material_level = 3,

	inscription_data = {
		cooldown = resolvers.rngrange(15, 25),
		range = resolvers.mbonus_level(5, 4),
		power = resolvers.mbonus_level(280, 50, function(e, v) return v * 0.1 end),
		use_stat_mod = 1.8,
	},
	inscription_talent = "RUNE:_LIGHTNING",
}

newEntity{ base = "BASE_RUNE",
	name = "manasurge rune",
	level_range = {1, 50},
	rarity = 22,
	cost = 10,
	material_level = 1,

	inscription_data = {
		cooldown = resolvers.rngrange(20, 30),
		dur = 10,
		mana = resolvers.mbonus_level(1200, 600, function(e, v) return v * 0.003 end),
		use_stat_mod = 4,
	},
	inscription_talent = "RUNE:_MANASURGE",
}
