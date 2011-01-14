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

newTalent{
	name = "Celerity",
	type = {"chronomancy/temporal-archery", 1},
	require = temporal_req1,
	points = 5,
	paradox = 3,
	stamina = 6,
	cooldown = 20, 
	tactical = {
		BUFF = 10,
	},
	no_energy = true,
	getPower = function(self, t) return 1 - 1 / (1 + ((10 + ((self:getTalentLevel(t) * 10) * getParadoxModifier(self, pm)))/ 100)) end,
	action = function(self, t)
		self:setEffect(self.EFF_CELERITY, 5, {power=t.getPower(self, t)})
		return true
	end,
	info = function(self, t)
		local power = t.getPower(self, t)
		return ([[Increases the caster's movement speed by %d%% for the next 5 turns.
		Additionally switching weapons takes no time while Celerity is active.]]):format(power * 100)
	end,
}

newTalent{
	name = "Precognizant Aim",
	type = {"chronomancy/temporal-archery", 2},
	require = temporal_req2,
	points = 5,
	stamina = 8,
	paradox = 3,
	cooldown = 6,
	no_energy = "fake",
	range = 20,
	requires_target = true,
	getResistPenalty = function(self, t) return 10 + (10 * self:getTalentLevelRaw(t)) end,
	action = function(self, t)
		local targets = self:archeryAcquireTargets()
		if not targets then return end
		self:setEffect(self.EFF_PRECOGNIZANT_AIM, 1, {power=t.getResistPenalty(self, t)})
		self:archeryShoot(targets, t, nil, {mult=self:combatTalentWeaponDamage(t, 1, 1.5) * getParadoxModifier(self, pm)})
		return true
	end,
	info = function(self, t)
		local penalty = t.getResistPenalty(self, t)
		local weapon = 100 * (self:combatTalentWeaponDamage(t, 1, 1.5) * getParadoxModifier(self, pm))
		return ([[You glimpse into the future and fire, increasing your physical resistance penetration by %d%% for a turn and firing a single shot doing %d%% damage.]])
		:format(penalty, weapon)
	end,
}

newTalent{
	name = "Quick Shot",
	type = {"chronomancy/temporal-archery", 3},
	require = temporal_req3,
	points = 5,
	stamina = 8, 
	paradox = 6,
	cooldown = function(self, t) return 18 - 2 * self:getTalentLevelRaw(t) end,
	no_energy = "fake",
	range = 20,
	requires_target = true,
	action = function(self, t)
		local old = self.energy.value
		local targets = self:archeryAcquireTargets()
		if not targets then return end
		self:archeryShoot(targets, t, nil, {mult=self:combatTalentWeaponDamage(t, 1, 1.5) * getParadoxModifier(self, pm)})
		self.energy.value = old
		return true
	end,
	info = function(self, t)
		local weapon = 100 * (self:combatTalentWeaponDamage(t, 1, 1.5) * getParadoxModifier(self, pm))
		return ([[A quick shot, doing %d%% damage.]]):format(weapon)
	end,
}

newTalent{
	name = "Phase Shot",
	type = {"chronomancy/temporal-archery", 4},
	require = temporal_req4,
	points = 5,
	stamina = 15,
	paradox = 6,
	cooldown = 10,
	no_energy = "fake",
	range = 20,
	requires_target = true,
	action = function(self, t)
		local targets = self:archeryAcquireTargets({type="beam"}, {one_shot=true})
		if not targets then return end
		self:archeryShoot(targets, t, {type="beam"}, {mult=self:combatTalentWeaponDamage(t, 1, 1.5) * getParadoxModifier(self, pm), damtype=DamageType.TEMPORAL})
		return true
	end,
	info = function(self, t)
		local weapon = 100 * (self:combatTalentWeaponDamage(t, 1, 1.5) * getParadoxModifier(self, pm))
		return ([[You fire a shot that phases out of time, hitting all targets in a beam for %d%% weapon damage as temporal damage.]]):
		format(weapon)
	end
}