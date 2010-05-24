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

-- Load other misc things
load("/data/talents/misc/npcs.lua")

-- race & classes
newTalentType{ type="base/class", name = "class", hide = true, description = "The basic talents defining a class." }
newTalentType{ type="base/race", name = "race", hide = true, description = "The various racial bonuses a character can have." }

newTalent{
	name = "Mana Pool",
	type = {"base/class", 1},
	info = "Allows you to have a mana pool. Mana is used to cast all spells.",
	mode = "passive",
	hide = true,
}
newTalent{
	name = "Vim Pool",
	type = {"base/class", 1},
	info = "Allows you to have a vim pool. Vim is used by corruptions.",
	mode = "passive",
	hide = true,
}
newTalent{
	name = "Stamina Pool",
	type = {"base/class", 1},
	info = "Allows you to have a stamina pool. Stamina is used to activate special combat attacks.",
	mode = "passive",
	hide = true,
}
newTalent{
	name = "Equilibrium Pool",
	type = {"base/class", 1},
	info = "Allows you to have an equilibrium pool. Equilibrium is used to mesure your balance with nature and the use of wild gifts.",
	mode = "passive",
	hide = true,
}

newTalent{
	name = "Improved Health I",
	type = {"base/race", 1},
	info = "Improves the number of health points per level.",
	mode = "passive",
	hide = true,
}
newTalent{
	name = "Improved Health II",
	type = {"base/race", 1},
	info = "Improves the number of health points per level.",
	mode = "passive",
	hide = true,
}
newTalent{
	name = "Improved Health III",
	type = {"base/race", 1},
	info = "Improves the number of health points per level.",
	mode = "passive",
	hide = true,
}
newTalent{
	name = "Decreased Health I",
	type = {"base/race", 1},
	info = "Improves the number of health points per level.",
	mode = "passive",
	hide = true,
}
newTalent{
	name = "Decreased Health II",
	type = {"base/race", 1},
	info = "Improves the number of health points per level.",
	mode = "passive",
	hide = true,
}
newTalent{
	name = "Decreased Health III",
	type = {"base/race", 1},
	info = "Improves the number of health points per level.",
	mode = "passive",
	hide = true,
}

-- Mages class talent, teleport to angolwen
newTalent{
	short_name = "TELEPORT_ANGOLWEN",
	name = "Teleport: Angolwen",
	type = {"base/class", 1},
	cooldown = 1000,
	action = function(self, t)
		if not self:canBe("worldport") then
			game.logPlayer(self, "The spell fizzles...")
			return
		end

		local seen = false
		-- Check for visible monsters, only see LOS actors, so telepathy wont prevent it
		core.fov.calc_circle(self.x, self.y, 20, function(_, x, y) return game.level.map:opaque(x, y) end, function(_, x, y)
			local actor = game.level.map(x, y, game.level.map.ACTOR)
			if actor and actor ~= self then seen = true end
		end, nil)
		if seen then
			game.log("There are creatures that could be watching you, you can not take the risk.")
			return
		end

		game:changeLevel(1, "town-angolwen")
		return true
	end,
	info = [[Allows a mage to teleport to the secret town of Angolwen.
	You have studied the magic arts there and have been granted a special portal spell to teleport there.
	Nobody must learn about this spell and so it should never be used while seen by any creatures.]]
}

-- Dunadan's power, a "weak" regeneration
newTalent{
	short_name = "DUNADAN_HEAL",
	name = "King's Gift",
	type = {"base/race", 1},
	cooldown = 50,
	action = function(self, t)
		self:setEffect(self.EFF_REGENERATION, 10, {power=5 + self:getWil() * 0.5})
		return true
	end,
	info = function(self)
		return ([[Call upon the gift of the Kings to regenerate your body for %d life every turn for 10 turns.
		The life healed will increase with the Willpower stat]]):format(5 + self:getWil() * 0.5)
	end,
}

-- Nandor's power, a temporary speedup
newTalent{
	short_name = "NANDOR_SPEED",
	name = "Grace of the Eldar",
	type = {"base/race", 1},
	cooldown = 50,
	action = function(self, t)
		self:setEffect(self.EFF_SPEED, 8, {power=0.20 + self:getDex() / 80})
		return true
	end,
	info = function(self)
		return ([[Call upon the grace of the Eldar to increase your general speed by %d%% for 8 turns.
		The speed bonus will increase with the Dexterity stat]]):format((0.20 + self:getDex() / 80) * 100)
	end,
}

-- Dwarf's power, a temporary stone shield
newTalent{
	short_name = "DWARF_RESILIENCE",
	name = "Resilience of the Dwarves",
	type = {"base/race", 1},
	cooldown = 50,
	action = function(self, t)
		self:setEffect(self.EFF_DWARVEN_RESILIENCE, 8, {
			armor=5 + self:getCon() / 5,
			physical=10 + self:getCon() / 5,
			spell=10 + self:getCon() / 5,
		})
		return true
	end,
	info = function(self)
		return ([[Call upon the legendary resilience of the Dwarven race to increase your armor(+%d), spell(+%d) and physical(+%d) resistances for 8 turns.
		The bonus will increase with the Constitution stat]]):format(5 + self:getCon() / 5, 10 + self:getCon() / 5, 10 + self:getCon() / 5)
	end,
}

-- Hobbit's power, temporary crit bonus
newTalent{
	short_name = "HOBBIT_LUCK",
	name = "Luck of the Little Folk",
	type = {"base/race", 1},
	cooldown = 50,
	action = function(self, t)
		self:setEffect(self.EFF_HOBBIT_LUCK, 5, {
			physical=20 + self:getCun() / 2,
			spell=20 + self:getCun() / 2,
		})
		return true
	end,
	info = function(self)
		return ([[Call upon the luck and cunning of the Little Folk to increase your physical and spell critical strike chance by %d%% for 5 turns.
		The bonus will increase with the Constitution stat]]):format(10 + self:getCon() / 5, 10 + self:getCon() / 5)
	end,
}

-- Orc's power: temporary damage increase
newTalent{
	short_name = "ORC_FURY",
	name = "Orcish Fury",
	type = {"base/race", 1},
	cooldown = 50,
	action = function(self, t)
		self:setEffect(self.EFF_ORC_FURY, 5, {power=10 + self:getWil(20)})
		return true
	end,
	info = function(self)
		return ([[Summons your lust for blood and destruction, increasing all damage by %d for 5 turns.
		The bonus will increase with the Willpower stat]]):format(10 + self:getWil(20))
	end,
}
