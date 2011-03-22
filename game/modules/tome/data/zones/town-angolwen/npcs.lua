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

local Talents = require("engine.interface.ActorTalents")

newEntity{ define_as = "SUPREME_ARCHMAGE_LINANIIL",
	type = "humanoid", subtype = "human",
	display = "p",
	faction = "angolwen",
	name = "Linaniil, Supreme Archmage of Angolwen", color=colors.VIOLET, unique = true,
	desc = [[A tall, pale woman dressed in a revealing silk robe. Her gaze is so intense it seems to burn.]],
	level_range = {50, nil}, exp_worth = 2,
	rank = 4,
	size_category = 3,
	female = true,
	mana_regen = 120,
	max_mana = 20000,
	max_life = 750, life_rating = 34, fixed_rating = true,
	infravision = 20,
	stats = { str=10, dex=15, cun=42, mag=26, con=14 },
	instakill_immune = 1,
	teleport_immune = 1,
	move_others=true,
	combat_spellpower = 30,
	anger_emote = "Remove @himher@!",

	open_door = true,

	autolevel = "caster",
	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", },
	ai_tactic = resolvers.tactic"ranged",
	resolvers.inscriptions(5, {}),
	resolvers.inscriptions(1, {"manasurge rune"}),

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	resolvers.drops{chance=100, nb=5, {tome_drops="boss"} },

	resists = {[DamageType.FIRE]=100, [DamageType.LIGHTNING]=100},

	resolvers.equip{
		{type="weapon", subtype="staff", autoreq=true, tome_drops="boss"},
		{type="armor", subtype="cloth", autoreq=true, tome_drops="boss"},
	},

	talent_cd_reduction = {all=23},
	resolvers.talents{
		[Talents.T_WILDFIRE]=5,
		[Talents.T_FLAME]=5,
		[Talents.T_FLAMESHOCK]=5,
		[Talents.T_BURNING_WAKE]=5,
		[Talents.T_CLEANSING_FLAMES]=5,
		[Talents.T_MANATHRUST]=5,
		[Talents.T_ARCANE_POWER]=5,
		[Talents.T_DISRUPTION_SHIELD]=5,
		[Talents.T_FREEZE]=5,
		[Talents.T_SHOCK]=5,
		[Talents.T_TEMPEST]=5,
		[Talents.T_HURRICANE]=5,
		[Talents.T_ESSENCE_OF_SPEED]=5,
		[Talents.T_PHASE_DOOR]=5,
		[Talents.T_TELEPORT]=5,
		[Talents.T_KEEN_SENSES]=5,
		[Talents.T_PREMONITION]=5,
	},
	resolvers.sustains_at_birth(),

	can_talk = "angolwen-leader",
}

newEntity{
	define_as = "BASE_NPC_ANGOLWEN_TOWN",
	type = "humanoid", subtype = resolvers.rngtable{"human","shalore","halfling"},
	display = "p", color=colors.WHITE,
	faction = "angolwen",
	anger_emote = "Catch @himher@!",

	resolvers.racial(),

	combat = { dam=resolvers.rngavg(1,2), atk=2, apr=0, dammod={str=0.4} },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },
	lite = 3,

	life_rating = 11,
	rank = 2,
	size_category = 3,

	open_door = true,

	autolevel = "caster",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_dmap", talent_in=3, },
	energy = { mod=1 },
	stats = { str=8, dex=8, mag=16, wil=18, con=10 },

	emote_random = resolvers.emote_random{allow_backup_guardian=true},
}

newEntity{ base = "BASE_NPC_ANGOLWEN_TOWN",
	name = "apprentice mage", color=colors.RED,
	desc = [[An apprentice, learning the ways of the arcane arts.]],
	level_range = {1, nil}, exp_worth = 1,
	rarity = 3,
	max_life = resolvers.rngavg(70,80),
	resolvers.equip{
		{type="weapon", subtype="staff", autoreq=true},
		{type="armor", subtype="cloth", autoreq=true},
	},
	combat_armor = 2, combat_def = 0,
	resolvers.talents{ [Talents.T_MANATHRUST]=2, [Talents.T_FREEZE]=1, },
}

newEntity{ base = "BASE_NPC_ANGOLWEN_TOWN",
	name = "pyromancer", color=colors.LIGHT_RED,
	desc = [[An archmage specialized in fire magic.]],
	level_range = {1, nil}, exp_worth = 1,
	rarity = 3,
	max_life = resolvers.rngavg(70,80),
	resolvers.equip{
		{type="weapon", subtype="staff", autoreq=true},
		{type="armor", subtype="cloth", autoreq=true},
	},
	combat_armor = 2, combat_def = 0,
	resolvers.talents{ [Talents.T_FLAME]=3, [Talents.T_WILDFIRE]=3, [Talents.T_BURNING_WAKE]=3, [Talents.T_BLASTWAVE]=3, },
}

newEntity{ base = "BASE_NPC_ANGOLWEN_TOWN",
	name = "cryomancer", color=colors.LIGHT_BLUE,
	desc = [[An archmage specialized in ice magic.]],
	level_range = {1, nil}, exp_worth = 1,
	rarity = 3,
	max_life = resolvers.rngavg(70,80),
	resolvers.equip{
		{type="weapon", subtype="staff", autoreq=true},
		{type="armor", subtype="cloth", autoreq=true},
	},
	combat_armor = 2, combat_def = 0,
	resolvers.talents{ [Talents.T_ICE_SHARDS]=3, [Talents.T_UTTERCOLD]=3, [Talents.T_FREEZE]=3, [Talents.T_FROZEN_GROUND]=3, },
}

newEntity{ base = "BASE_NPC_ANGOLWEN_TOWN",
	name = "geomancer", color=colors.UMBER,
	desc = [[An archmage specialized in earth magic.]],
	level_range = {1, nil}, exp_worth = 1,
	rarity = 3,
	max_life = resolvers.rngavg(70,80),
	resolvers.equip{
		{type="weapon", subtype="staff", autoreq=true},
		{type="armor", subtype="cloth", autoreq=true},
	},
	combat_armor = 2, combat_def = 0,
	resolvers.talents{ [Talents.T_EARTHEN_MISSILES]=3, [Talents.T_CRYSTALLINE_FOCUS]=3, [Talents.T_BODY_OF_STONE]=3, [Talents.T_STRIKE]=3, },
}

newEntity{ base = "BASE_NPC_ANGOLWEN_TOWN",
	name = "tempest", color=colors.WHITE,
	desc = [[An archmage specialized in lightning magic.]],
	level_range = {1, nil}, exp_worth = 1,
	rarity = 3,
	max_life = resolvers.rngavg(70,80),
	resolvers.equip{
		{type="weapon", subtype="staff", autoreq=true},
		{type="armor", subtype="cloth", autoreq=true},
	},
	combat_armor = 2, combat_def = 0,
	resolvers.talents{ [Talents.T_LIGHTNING]=3, [Talents.T_TEMPEST]=3, [Talents.T_HURRICANE]=3, [Talents.T_SHOCK]=3, },
}
