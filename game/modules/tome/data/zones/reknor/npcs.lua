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

load("/data/general/npcs/orc.lua", rarity(0))
load("/data/general/npcs/troll.lua", rarity(0))

load("/data/general/npcs/all.lua", rarity(4, 35))

local Talents = require("engine.interface.ActorTalents")

-- The boss of Reknor, no "rarity" field means it will not be randomly generated
newEntity{ define_as = "GOLBUG",
	type = "humanoid", subtype = "orc", unique = true,
	faction = "orc-pride",
	name = "Golbug the Destroyer",
	display = "o", color=colors.VIOLET,
	desc = [[A huge and muscular orc of unknown breed. He looks both menacing and cunning...]],
	level_range = {28, 45}, exp_worth = 2,
	max_life = 350, life_rating = 16, fixed_rating = true,
	max_stamina = 245,
	rank = 5,
	size_category = 3,
	infravision = 20,
	instakill_immune = 1,
	stats = { str=22, dex=19, cun=34, mag=10, con=16 },
	move_others=true,

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, NECK=1, HEAD=1, },
	equipment = resolvers.equip{
		{type="weapon", subtype="mace", ego_chance=100, autoreq=true},
		{type="armor", subtype="shield", ego_chance=100, autoreq=true},
		{type="armor", subtype="head", autoreq=true},
		{type="armor", subtype="massive", ego_chance=50, autoreq=true},
	},
	resolvers.drops{chance=100, nb=5, {ego_chance=100} },
	resolvers.drops{chance=100, nb=1, {type="jewelry", subtype="orb", defined="ORB_MANY_WAYS"} },

	stun_immune = 1,
	see_invisible = 5,

	resolvers.talents{
		[Talents.T_HEAVY_ARMOUR_TRAINING]=1,
		[Talents.T_MASSIVE_ARMOUR_TRAINING]=3,
		[Talents.T_WEAPON_COMBAT]=6,
		[Talents.T_WEAPONS_MASTERY]=6,
		[Talents.T_SHIELD_PUMMEL]=4,
		[Talents.T_RUSH]=4,
		[Talents.T_RIPOSTE]=4,
		[Talents.T_BLINDING_SPEED]=4,
		[Talents.T_OVERPOWER]=3,
		[Talents.T_ASSAULT]=3,
		[Talents.T_SHIELD_WALL]=3,
		[Talents.T_SHIELD_EXPERTISE]=2,

		[Talents.T_BELLOWING_ROAR]=3,
		[Talents.T_WING_BUFFET]=2,
		[Talents.T_FIRE_BREATH]=4,

		[Talents.T_ICE_CLAW]=3,
		[Talents.T_ICY_SKIN]=4,
		[Talents.T_ICE_BREATH]=4,
	},
	resolvers.sustains_at_birth(),

	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { talent_in=2, ai_move="move_astar", },

	on_acquire_target = function(self, who)
		-- Doesnt matter who, jsut assume the player is there
		if not self.has_chatted then
			self.has_chatted = true
			local Chat = require("engine.Chat")
			local chat = Chat.new("golbug-explains", self, game.player)
			chat:invoke()
		end
	end,

	on_die = function(self, who)
		game.state:activateBackupGuardian("LITHFENGEL", 4, 35, "They say that after it has been confirmed orcs still inhabited Reknor, they found a mighty demon there.", function(gen)
			if gen then require("engine.ui.Dialog"):simpleLongPopup("Danger...", "When last you saw it, this cavern was littered with the corpses of orcs that you had slain. Now many, many more corpses carpet the floor, all charred and reeking of sulfur. An orange glow dimly illuminates the far reaches of the cavern to the east.", 400) end
		end)

		world:gainAchievement("DESTROYER_BANE", game.player:resolveSource())
		game.player:setQuestStatus("orc-hunt", engine.Quest.DONE)
		game.player:grantQuest("wild-wild-east")

		-- Add the herald
		local harno = game.zone:makeEntityByName(game.level, "actor", "HARNO")
		game.zone:addEntity(game.level, harno, "actor", 0, 13)
	end,
}

-- The messager sent by last-hope
newEntity{ define_as = "HARNO",
	type = "humanoid", subtype = "human", unique = true,
	faction = "allied-kingdoms",
	name = "Harno, Herald of Last Hope",
	display = "@", color=colors.LIGHT_BLUE,
	desc = [[This is one of the heralds of Last Hope, he seems to be looking for you.]],
	energy = {mod=2},
	level_range = {40, 40}, exp_worth = 0,
	max_life = 150, life_rating = 12,
	rank = 3,
	infravision = 20,
	stats = { str=10, dex=29, cun=43, mag=10, con=10 },
	move_others=true,

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, NECK=1, HEAD=1, },
	equipment = resolvers.equip{
		{type="weapon", subtype="knife", autoreq=true},
		{type="weapon", subtype="knife", autoreq=true},
	},
	resolvers.drops{chance=100, nb=1, {type="scroll", subtype="scroll", defined="NOTE_FROM_LAST_HOPE"} },

	stun_immune = 1,
	see_invisible = 100,

	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { ai_target="target_player", ai_move="move_astar", },

	can_talk = "message-last-hope",
	can_talk_only_once = true,

	on_die = function(self, who)
		game.logPlayer(game.player, "#LIGHT_RED#You hear a death cry. '%s I have a messag... ARG!'", game.player.name:capitalize())
		game.player:setQuestStatus("orc-hunt", engine.Quest.DONE, "herald-died")
	end,
}

newEntity{ define_as = "LITHFENGEL", -- Lord of Ash; backup guardian
	type = "demon", subtype = "major", unique = true,
	name = "Lithfengel",
	display = "U", color=colors.VIOLET,
	desc = [[A terrible demon of decay and atrophy, drawn to the energy of the farportal. A Balrog of blight!]],
	level_range = {35, 75}, exp_worth = 3,
	max_life = 400, life_rating = 25, fixed_rating = true,
	rank = 4,
	size_category = 5,
	infravision = 30,
	-- The artifact he wields drains life a little, so to compensate:
	life_regen = 0.3,
	stats = { str=20, dex=15, cun=25, mag=25, con=20 },
	poison_immune = 1,
	fear_immune = 1,
	instakill_immune = 1,
	no_breath = 1,
	move_others=true,
	demon = 1,

	on_melee_hit = { [DamageType.BLIGHT] = 45, },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	resolvers.equip{
		{type="weapon", subtype="waraxe", defined="MALEDICTION", autoreq=true},
	},
	resolvers.drops{chance=100, nb=4, {ego_chance=100} },
	resolvers.drops{chance=100, nb=1, {defined="ATHAME_WEST"} },
	resolvers.drops{chance=100, nb=1, {defined="RESONATING_DIAMOND_WEST"} },

	resolvers.talents{
		[Talents.T_ROTTING_DISEASE]=5,
		[Talents.T_DECREPITUDE_DISEASE]=5,
		[Talents.T_WEAKNESS_DISEASE]=5,
		[Talents.T_CATALEPSY]=5,
		[Talents.T_RUSH]=5,
		[Talents.T_MORTAL_TERROR]=5,
		[Talents.T_WEAPON_COMBAT]=10,
		[Talents.T_WEAPONS_MASTERY]=6,
	},
	resolvers.sustains_at_birth(),

	autolevel = "warriormage",
	ai = "dumb_talented_simple", ai_state = { talent_in=2, ai_move="move_astar" },

	on_die = function(self, who)
		if who.resolveSource and who:resolveSource().player and who:resolveSource():hasQuest("east-portal") then
			require("engine.ui.Dialog"):simpleLongPopup("Back and there again", "A careful examination of the balrog's body turns up a Blood-Runed Athame and a Resonating Diamond, both covered in soot and gore but otherwise in good condition.", 400)
		end
	end,
}
